local with_dev
with_dev = require("spec.helpers").with_dev
return describe("moon", function()
  local moon
  with_dev(function()
    moon = require("moon")
  end)
  it("should determine correct type", function()
    local Test
    do
      local _class_0
      local _base_0 = { }
      _base_0.__index = _base_0
      _class_0 = setmetatable({
        __init = function() end,
        __base = _base_0,
        __name = "Test"
      }, {
        __index = _base_0,
        __call = function(cls, ...)
          local _self_0 = setmetatable({}, _base_0)
          cls.__init(_self_0, ...)
          return _self_0
        end
      })
      _base_0.__class = _class_0
      Test = _class_0
    end
    local things = {
      Test,
      Test(),
      1,
      true,
      nil,
      "hello"
    }
    local types
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #things do
        local t = things[_index_0]
        _accum_0[_len_0] = moon.type(t)
        _len_0 = _len_0 + 1
      end
      types = _accum_0
    end
    return assert.same(types, {
      Test,
      Test,
      "number",
      "boolean",
      "nil",
      "string"
    })
  end)
  it("should get upvalue", function()
    local fn
    do
      local hello = "world"
      fn = function()
        return hello
      end
    end
    return assert.same(moon.debug.upvalue(fn, "hello"), "world")
  end)
  it("should set upvalue", function()
    local fn
    do
      local hello = "world"
      fn = function()
        return hello
      end
    end
    moon.debug.upvalue(fn, "hello", "foobar")
    return assert.same(fn(), "foobar")
  end)
  it("should run with scope", function()
    local scope = {
      hello = function() end
    }
    spy.on(scope, "hello")
    moon.run_with_scope((function()
      return hello()
    end), scope)
    return assert.spy(scope.hello).was.called()
  end)
  it("should have access to old environment", function()
    local scope = { }
    local res = moon.run_with_scope((function()
      return math
    end), scope)
    return assert.same(res, math)
  end)
  it("should created bound proxy", function()
    local Hello
    do
      local _class_0
      local _base_0 = {
        state = 10,
        method = function(self, val)
          return "the state: " .. tostring(self.state) .. ", the val: " .. tostring(val)
        end
      }
      _base_0.__index = _base_0
      _class_0 = setmetatable({
        __init = function() end,
        __base = _base_0,
        __name = "Hello"
      }, {
        __index = _base_0,
        __call = function(cls, ...)
          local _self_0 = setmetatable({}, _base_0)
          cls.__init(_self_0, ...)
          return _self_0
        end
      })
      _base_0.__class = _class_0
      Hello = _class_0
    end
    local hello = Hello()
    local bound = moon.bind_methods(hello)
    return assert.same(bound.method("xxx"), "the state: 10, the val: xxx")
  end)
  it("should create defaulted table", function()
    local fib = moon.defaultbl({
      [0] = 0,
      [1] = 1
    }, function(self, i)
      return self[i - 1] + self[i - 2]
    end)
    local _ = fib[7]
    return assert.same(fib, {
      [0] = 0,
      1,
      1,
      2,
      3,
      5,
      8,
      13
    })
  end)
  it("should extend", function()
    local t1 = {
      hello = "world's",
      cool = "shortest"
    }
    local t2 = {
      cool = "boots",
      cowboy = "hat"
    }
    local out = moon.extend(t1, t2)
    return assert.same({
      out.hello,
      out.cool,
      out.cowboy
    }, {
      "world's",
      "shortest",
      "hat"
    })
  end)
  it("should make a copy", function()
    local x = {
      "hello",
      yeah = "man"
    }
    local y = moon.copy(x)
    x[1] = "yikes"
    x.yeah = "woman"
    return assert.same(y, {
      "hello",
      yeah = "man"
    })
  end)
  it("should mixin", function()
    local TestModule
    do
      local _class_0
      local _base_0 = {
        show_var = function(self)
          return "var is: " .. tostring(self.var)
        end
      }
      _base_0.__index = _base_0
      _class_0 = setmetatable({
        __init = function(self, var)
          self.var = var
        end,
        __base = _base_0,
        __name = "TestModule"
      }, {
        __index = _base_0,
        __call = function(cls, ...)
          local _self_0 = setmetatable({}, _base_0)
          cls.__init(_self_0, ...)
          return _self_0
        end
      })
      _base_0.__class = _class_0
      TestModule = _class_0
    end
    local Second
    do
      local _class_0
      local _base_0 = { }
      _base_0.__index = _base_0
      _class_0 = setmetatable({
        __init = function(self)
          return moon.mixin(self, TestModule, "hi")
        end,
        __base = _base_0,
        __name = "Second"
      }, {
        __index = _base_0,
        __call = function(cls, ...)
          local _self_0 = setmetatable({}, _base_0)
          cls.__init(_self_0, ...)
          return _self_0
        end
      })
      _base_0.__class = _class_0
      Second = _class_0
    end
    local obj = Second()
    return assert.same(obj:show_var(), "var is: hi")
  end)
  it("should mixin object", function()
    local First
    do
      local _class_0
      local _base_0 = {
        val = 10,
        get_val = function(self)
          return "the val: " .. tostring(self.val)
        end
      }
      _base_0.__index = _base_0
      _class_0 = setmetatable({
        __init = function() end,
        __base = _base_0,
        __name = "First"
      }, {
        __index = _base_0,
        __call = function(cls, ...)
          local _self_0 = setmetatable({}, _base_0)
          cls.__init(_self_0, ...)
          return _self_0
        end
      })
      _base_0.__class = _class_0
      First = _class_0
    end
    local Second
    do
      local _class_0
      local _base_0 = {
        val = 20
      }
      _base_0.__index = _base_0
      _class_0 = setmetatable({
        __init = function(self)
          return moon.mixin_object(self, First(), {
            "get_val"
          })
        end,
        __base = _base_0,
        __name = "Second"
      }, {
        __index = _base_0,
        __call = function(cls, ...)
          local _self_0 = setmetatable({}, _base_0)
          cls.__init(_self_0, ...)
          return _self_0
        end
      })
      _base_0.__class = _class_0
      Second = _class_0
    end
    local obj = Second()
    return assert.same(obj:get_val(), "the val: 10")
  end)
  it("should mixin table", function()
    local a = {
      hello = "world",
      cat = "dog"
    }
    local b = {
      cat = "mouse",
      foo = "bar"
    }
    moon.mixin_table(a, b)
    return assert.same(a, {
      hello = "world",
      cat = "mouse",
      foo = "bar"
    })
  end)
  return it("should fold", function()
    local numbers = {
      4,
      3,
      5,
      6,
      7,
      2,
      3
    }
    local sum = moon.fold(numbers, function(a, b)
      return a + b
    end)
    return assert.same(sum, 30)
  end)
end)
