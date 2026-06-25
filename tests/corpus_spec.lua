local corpus = require("nvimtrainer.corpus")
local schema = require("nvimtrainer.corpus.schema")

describe("corpus.all", function()
  it("merges static sources into a valid, id-unique list", function()
    local list = corpus.all({ include_keymaps = false })
    assert.is_true(#list >= 9) -- 3 motions + 3 textobjects + 3 excmd
    local ok, err = schema.validate(list)
    assert.is_true(ok, err)
  end)

  it("filters by category", function()
    local mo = corpus.by_category("motions", { include_keymaps = false })
    assert.is_true(#mo >= 3)
    for _, e in ipairs(mo) do
      assert.equals("motions", e.category)
    end
  end)
end)
