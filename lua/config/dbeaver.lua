-- Reads DBeaver's connection store and turns it into vim-dadbod connections,
-- so dadbod-ui shows the same databases as DBeaver without duplicating secrets.
--
-- Passwords are decrypted at runtime from `credentials-config.json` (AES-128-CBC
-- with DBeaver's built-in key, first 16 bytes = IV) through `openssl`; nothing is
-- written to disk. If decryption fails, URLs are built without a password and
-- psql falls back to ~/.pgpass / PGPASSWORD.
local M = {}

local WORKSPACE = vim.fn.expand("~/.local/share/DBeaverData/workspace6/General/.dbeaver")
-- DBeaver's default credentials key (public, hardcoded in DBeaver itself).
local DBEAVER_KEY = "babb4a9f774ab853c96c2d653dfe544a"
-- Connections whose name matches one of these patterns open in read-only transactions.
M.read_only_patterns = { "^[Pp]rod" }

local function read_file(path)
  local fd = io.open(path, "rb")
  if not fd then
    return nil
  end
  local content = fd:read("*a")
  fd:close()
  return content
end

local function urlencode(str)
  return (str:gsub("[^%w%-%._~]", function(c)
    return string.format("%%%02X", c:byte())
  end))
end

local function decrypt_credentials()
  local raw = read_file(WORKSPACE .. "/credentials-config.json")
  if not raw or #raw <= 16 or vim.fn.executable("openssl") == 0 then
    return {}
  end
  local iv = raw:sub(1, 16):gsub(".", function(c)
    return string.format("%02x", c:byte())
  end)
  local res = vim
    .system({ "openssl", "enc", "-d", "-aes-128-cbc", "-K", DBEAVER_KEY, "-iv", iv }, { stdin = raw:sub(17) })
    :wait()
  if res.code ~= 0 then
    return {}
  end
  local ok, decoded = pcall(vim.json.decode, res.stdout)
  return ok and decoded or {}
end

local function is_read_only(name)
  for _, pattern in ipairs(M.read_only_patterns) do
    if name:match(pattern) then
      return true
    end
  end
  return false
end

local function postgres_url(conn, creds)
  local cfg = conn.configuration or {}
  local auth = ""
  if creds.user and creds.user ~= "" then
    auth = urlencode(creds.user)
    if creds.password and creds.password ~= "" then
      auth = auth .. ":" .. urlencode(creds.password)
    end
    auth = auth .. "@"
  end
  local url
  if cfg.host then
    url = string.format(
      "postgresql://%s%s:%s/%s",
      auth,
      cfg.host,
      cfg.port or "5432",
      cfg.database or "postgres"
    )
  elseif cfg.url then
    -- function replacement: the encoded password contains `%`, special in gsub repl strings
    url = cfg.url:gsub("^jdbc:", ""):gsub("^postgresql://", function()
      return "postgresql://" .. auth
    end)
  else
    return nil
  end
  if is_read_only(conn.name) then
    url = url .. (url:find("?", 1, true) and "&" or "?") .. "options=-c%20default_transaction_read_only%3Don"
  end
  return url
end

--- Returns DBeaver connections as a dadbod `g:dbs` list: { { name = ..., url = ... }, ... }.
function M.connections()
  local raw = read_file(WORKSPACE .. "/data-sources.json")
  if not raw then
    return {}
  end
  local ok, sources = pcall(vim.json.decode, raw)
  if not ok or type(sources.connections) ~= "table" then
    return {}
  end
  local credentials = decrypt_credentials()

  local dbs = {}
  for id, conn in pairs(sources.connections) do
    local creds = (credentials[id] or {})["#connection"] or {}
    local url
    if conn.driver and conn.driver:match("^postgres") then
      url = postgres_url(conn, creds)
    elseif conn.driver and conn.driver:match("^sqlite") then
      local path = (conn.configuration or {}).database
      url = path and ("sqlite:" .. path) or nil
    end
    if url then
      local name = conn.name .. (is_read_only(conn.name) and " [RO]" or "")
      table.insert(dbs, { name = name, url = url })
    end
  end
  table.sort(dbs, function(a, b)
    return a.name < b.name
  end)
  return dbs
end

return M
