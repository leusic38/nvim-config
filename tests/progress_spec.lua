local progress = require("nvimtrainer.progress")

describe("progress.weight", function()
  it("ranks unseen highest", function()
    assert.is_true(progress.weight(nil) > progress.weight({ seen = 1, passed = 1, failed = 0 }))
  end)

  it("ranks failed higher than passed", function()
    local failed = { seen = 3, passed = 0, failed = 3 }
    local passed = { seen = 3, passed = 3, failed = 0 }
    assert.is_true(progress.weight(failed) > progress.weight(passed))
  end)
end)

describe("progress.record_into", function()
  it("increments counters for a pass with technique", function()
    local data = {}
    progress.record_into(data, "x-1", { passed = true, technique = true }, 1000)
    assert.equals(1, data["x-1"].seen)
    assert.equals(1, data["x-1"].passed)
    assert.equals(0, data["x-1"].failed)
    assert.equals(1, data["x-1"].technique_hits)
    assert.equals(1000, data["x-1"].last_ts)
  end)

  it("increments failed on a miss", function()
    local data = {}
    progress.record_into(data, "x-1", { passed = false, technique = false }, 2000)
    assert.equals(1, data["x-1"].seen)
    assert.equals(1, data["x-1"].failed)
  end)
end)

describe("progress.pick", function()
  it("is deterministic with an injected rng and respects weights", function()
    local exos = { { id = "seen" }, { id = "unseen" } }
    local data = { seen = { seen = 5, passed = 5, failed = 0 } }
    -- rng returns the very top of the weight range -> must land on the heaviest (unseen)
    local rng = function(n) return n end
    local picked = progress.pick(exos, data, rng)
    assert.equals("unseen", picked.id)
  end)
end)
