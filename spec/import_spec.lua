return describe("import", function()
  it("should import from table", function()
    local sort, insert
    do
      local _obj_0 = table
      sort, insert = _obj_0.sort, _obj_0.insert
    end
    local t = {
      4,
      2,
      6
    }
    insert(t, 1)
    sort(t)
    return assert.same(t, {
      1,
      2,
      4,
      6
    })
  end)
  it("should import from local", function()
    local thing = {
      var = 10,
      hello = "world",
      func = function(self)
        return self.var
      end
    }
    local hello, func
    hello, func = thing.hello, (function()
      local _base_0 = thing
      local _fn_0 = _base_0.func
      return function(...)
        return _fn_0(_base_0, ...)
      end
    end)()
    assert.same(hello, thing.hello)
    return assert.same(func(), thing.var)
  end)
  return it("should not call source multiple times", function()
    local count = 0
    local source
    source = function()
      count = count + 1
      return {
        hello = "world",
        foo = "bar"
      }
    end
    local hello, foo
    do
      local _obj_0 = source()
      hello, foo = _obj_0.hello, _obj_0.foo
    end
    return assert.same(count, 1)
  end)
end)
