local unpack
unpack = require("moonscriptplus.util").unpack
describe("comprehension", function()
  it("should double every number", function()
    local input = {
      1,
      2,
      3,
      4,
      5,
      6
    }
    local output_1
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _, i in pairs(input) do
        _accum_0[_len_0] = i * 2
        _len_0 = _len_0 + 1
      end
      output_1 = _accum_0
    end
    local output_2
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #input do
        local i = input[_index_0]
        _accum_0[_len_0] = i * 2
        _len_0 = _len_0 + 1
      end
      output_2 = _accum_0
    end
    return assert.same(output_1, {
      2,
      4,
      6,
      8,
      10,
      12
    })
  end)
  it("should create a slice", function()
    local input = {
      1,
      2,
      3,
      4,
      5,
      6
    }
    local slice_1
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _max_0 = 3
      for _index_0 = 1, _max_0 < 0 and #input + _max_0 or _max_0 do
        local i = input[_index_0]
        _accum_0[_len_0] = i
        _len_0 = _len_0 + 1
      end
      slice_1 = _accum_0
    end
    local slice_2
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _max_0 = 3
      for _index_0 = 1, _max_0 < 0 and #input + _max_0 or _max_0 do
        local i = input[_index_0]
        _accum_0[_len_0] = i
        _len_0 = _len_0 + 1
      end
      slice_2 = _accum_0
    end
    local slice_3
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 3, #input do
        local i = input[_index_0]
        _accum_0[_len_0] = i
        _len_0 = _len_0 + 1
      end
      slice_3 = _accum_0
    end
    local slice_4
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #input do
        local i = input[_index_0]
        _accum_0[_len_0] = i
        _len_0 = _len_0 + 1
      end
      slice_4 = _accum_0
    end
    local slice_5
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #input, 2 do
        local i = input[_index_0]
        _accum_0[_len_0] = i
        _len_0 = _len_0 + 1
      end
      slice_5 = _accum_0
    end
    local slice_6
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 2, #input, 2 do
        local i = input[_index_0]
        _accum_0[_len_0] = i
        _len_0 = _len_0 + 1
      end
      slice_6 = _accum_0
    end
    assert.same(slice_1, {
      1,
      2,
      3
    })
    assert.same(slice_1, slice_2)
    assert.same(slice_3, {
      3,
      4,
      5,
      6
    })
    assert.same(slice_4, input)
    assert.same(slice_5, {
      1,
      3,
      5
    })
    return assert.same(slice_6, {
      2,
      4,
      6
    })
  end)
  return it("should be able to assign to self", function()
    local input = {
      1,
      2,
      3,
      4
    }
    local output = input
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #output do
        local i = output[_index_0]
        _accum_0[_len_0] = i * 2
        _len_0 = _len_0 + 1
      end
      output = _accum_0
    end
    assert.same(input, {
      1,
      2,
      3,
      4
    })
    assert.same(output, {
      2,
      4,
      6,
      8
    })
    output = input
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _, i in ipairs(input) do
        _accum_0[_len_0] = i * 2
        _len_0 = _len_0 + 1
      end
      output = _accum_0
    end
    assert.same(input, {
      1,
      2,
      3,
      4
    })
    return assert.same(output, {
      2,
      4,
      6,
      8
    })
  end)
end)
return describe("table comprehension", function()
  it("should copy table", function()
    local input = {
      1,
      2,
      3,
      hello = "world",
      thing = true
    }
    local output
    do
      local _tbl_0 = { }
      for k, v in pairs(input) do
        _tbl_0[k] = v
      end
      output = _tbl_0
    end
    assert.is_true(input ~= output)
    return assert.same(input, output)
  end)
  it("should support when", function()
    local input = {
      color = "red",
      name = "fast",
      width = 123
    }
    local output
    do
      local _tbl_0 = { }
      for k, v in pairs(input) do
        if k ~= "color" then
          _tbl_0[k] = v
        end
      end
      output = _tbl_0
    end
    return assert.same(output, {
      name = "fast",
      width = 123
    })
  end)
  it("should do unpack", function()
    local input = {
      4,
      9,
      16,
      25
    }
    local output
    do
      local _tbl_0 = { }
      for _index_0 = 1, #input do
        local i = input[_index_0]
        _tbl_0[i] = math.sqrt(i)
      end
      output = _tbl_0
    end
    return assert.same(output, {
      [4] = 2,
      [9] = 3,
      [16] = 4,
      [25] = 5
    })
  end)
  return it("should use multiple return values", function()
    local input = {
      {
        "hello",
        "world"
      },
      {
        "foo",
        "bar"
      }
    }
    local output
    do
      local _tbl_0 = { }
      for _index_0 = 1, #input do
        local tuple = input[_index_0]
        local _key_0, _val_0 = unpack(tuple)
        _tbl_0[_key_0] = _val_0
      end
      output = _tbl_0
    end
    return assert.same(output, {
      foo = "bar",
      hello = "world"
    })
  end)
end)
