vim.g.mapleader = " "
local verify = require("nvimtrainer.verify")

local function make_buf(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  return buf
end

describe("verify.check", function()
  it("passes a state exercise when buffer matches target", function()
    local buf = make_buf({ "le  noir dort" })
    local exo = { check = "state", target_lines = { "le  noir dort" }, expected_keys = "diw" }
    local r = verify.check(exo, buf, "diw")
    assert.is_true(r.passed)
    assert.is_true(r.technique)
  end)

  it("fails a state exercise when buffer differs", function()
    local buf = make_buf({ "le chat noir dort" })
    local exo = { check = "state", target_lines = { "le  noir dort" } }
    local r = verify.check(exo, buf, "x")
    assert.is_false(r.passed)
  end)

  it("marks technique false when keys differ but state is right", function()
    local buf = make_buf({ "le  noir dort" })
    local exo = { check = "state", target_lines = { "le  noir dort" }, expected_keys = "diw" }
    local r = verify.check(exo, buf, "dwdw")
    assert.is_true(r.passed)
    assert.is_false(r.technique)
  end)

  it("passes a keys exercise when captured keys match expected", function()
    local buf = make_buf({ "anything" })
    local exo = { check = "keys", expected_keys = "diw" }
    local r = verify.check(exo, buf, "diw")
    assert.is_true(r.passed)
  end)

  it("normalizes termcodes for leader-style keymaps", function()
    local buf = make_buf({ "x" })
    -- " ff" is what on_key captures when leader is <space> and you press <leader>ff
    local exo = { check = "keys", expected_keys = "<leader>ff" }
    local r = verify.check(exo, buf, " ff")
    assert.is_true(r.passed)
  end)
end)
