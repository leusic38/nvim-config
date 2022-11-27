_G.dump = function(...)
  print(vim.inspect(...))
end

_G.prequire = function(...)
  local status, lib = pcall(require, ...)
  if status then
    return lib
  end
  return nil
end

local M = {} -- The module to export

local cmd = vim.cmd

local opts = { noremap = true, silent = false }
local generic_opts = {
  insert_mode = { noremap = true, silent = true },
  normal_mode = opts,
  visual_mode = opts,
  visual_block_mode = opts,
  command_mode = opts,
  term_mode = { silent = false },
}

local mode_adapters = {
  insert_mode = "i",
  normal_mode = "n",
  term_mode = "t",
  visual_mode = "v",
  visual_block_mode = "x",
  command_mode = "c",
}


-- We will create a few autogroup, this function will help to avoid
-- always writing cmd('augroup' .. group) etc..
function M.create_augroup(autocmds, name)
  cmd ('augroup ' .. name)
  cmd('autocmd!')
  for _, autocmd in ipairs(autocmds) do
    cmd('autocmd ' .. table.concat(autocmd, ' '))
  end
  cmd('augroup END')
end

-- Add a apth to the rtp
function M.add_rtp(path)
  local rtp = vim.o.rtp
  rtp = rtp .. ',' .. path
end
function M.set_keymaps(mode, key, val)
  local isCmd= val[4]
  local buf= val[3]
  local options = #val >=2 and val[2] or generic_opts[mode]
  local action = val[1]
  mode = mode_adapters[mode] and mode_adapters[mode] or mode
  if isCmd then
    action = "<cmd>"..action.."<cr>"  
  end
  if buf then
    vim.api.nvim_buf_set_keymap(buf, mode, key, action, options)
  else
    vim.api.nvim_set_keymap(mode, key, action, options)
  end
end

function M.map(mode, keymaps)
  for k, v in pairs(keymaps) do
    M.set_keymaps(mode, k, v)
  end
end

function M.t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.exists(list, val)
  local set = {}
  for _, l in ipairs(list) do
    set[l] = true
  end
  return set[val]
end

function M.log(msg, hl, name)
  name = name or "Neovim"
  hl = hl or "Todo"
  vim.api.nvim_echo({ { name .. ": ", hl }, { msg } }, true, {})
end

function M.warn(msg, name)
  vim.notify(msg, vim.log.levels.WARN, { title = name })
end

function M.error(msg, name)
  vim.notify(msg, vim.log.levels.ERROR, { title = name })
end

function M.info(msg, name)
  vim.notify(msg, vim.log.levels.INFO, { title = name })
end

-- We want to be able to access utils in all our configuration files
-- so we add the module to the _G global variable.
_G.utils = M
return M -- Export the module
