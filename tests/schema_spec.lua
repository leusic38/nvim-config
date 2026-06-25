local schema = require("nvimtrainer.corpus.schema")

describe("corpus.schema.validate", function()
  local DELETE = {}  -- sentinel: passing this value removes the key
  local function valid_exo(over)
    local t = {
      id = "x-1", title = "t", category = "motions", difficulty = 1,
      start_lines = { "a" }, target_lines = { "a" },
    }
    for k, v in pairs(over or {}) do
      if v == DELETE then
        t[k] = nil
      else
        t[k] = v
      end
    end
    return t
  end

  it("accepts a well-formed list", function()
    local ok, err = schema.validate({ valid_exo() })
    assert.is_true(ok)
    assert.is_nil(err)
  end)

  it("rejects a missing required field", function()
    local bad = valid_exo({ id = DELETE })
    local ok, err = schema.validate({ bad })
    assert.is_false(ok)
    assert.is_truthy(err:match("id"))
  end)

  it("rejects duplicate ids", function()
    local ok, err = schema.validate({ valid_exo(), valid_exo() })
    assert.is_false(ok)
    assert.is_truthy(err:match("duplicate"))
  end)

  it("requires expected_keys when check == 'keys'", function()
    local ok, err = schema.validate({ valid_exo({ check = "keys", expected_keys = DELETE }) })
    assert.is_false(ok)
    assert.is_truthy(err:match("expected_keys"))
  end)

  it("requires target_lines when check == 'state'", function()
    local ok, err = schema.validate({ valid_exo({ target_lines = DELETE }) })
    assert.is_false(ok)
    assert.is_truthy(err:match("target_lines"))
  end)
end)
