local Block
Block = require("moonscriptplus.compile").Block
local ref, str
do
  local _obj_0 = require("spec.factory")
  ref, str = _obj_0.ref, _obj_0.str
end
local SimpleBlock
do
  local _class_0
  local _parent_0 = Block
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      _class_0.__parent.__init(self, ...)
      self.transform = {
        value = function(...)
          return ...
        end,
        statement = function(...)
          return ...
        end
      }
    end,
    __base = _base_0,
    __name = "SimpleBlock",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  SimpleBlock = _class_0
end
local value = require("moonscriptplus.compile.value")
return describe("moonscript.compile", function()
  local compile_node
  compile_node = function(node)
    local block = SimpleBlock()
    block:add(block:value(node))
    local lines = block._lines:flatten()
    if lines[#lines] == "\n" then
      lines[#lines] = nil
    end
    return table.concat(lines)
  end
  return describe("value", function()
    local _list_0 = {
      {
        "ref",
        function()
          return {
            "ref",
            "hello_world"
          }
        end,
        "hello_world"
      },
      {
        "number",
        function()
          return {
            "number",
            "14"
          }
        end,
        "14"
      },
      {
        "minus",
        function()
          return {
            "minus",
            ref()
          }
        end,
        "-val"
      },
      {
        "explist",
        function()
          return {
            "explist",
            ref("a"),
            ref("b"),
            ref("c")
          }
        end,
        "a, b, c"
      },
      {
        "exp",
        function()
          return {
            "exp",
            ref("a"),
            "+",
            ref("b"),
            "!=",
            ref("c")
          }
        end,
        "a + b ~= c"
      },
      {
        "parens",
        function()
          return {
            "parens",
            ref()
          }
        end,
        "(val)"
      },
      {
        "string (single quote)",
        function()
          return {
            "string",
            "'",
            "Hello\\'s world"
          }
        end,
        "'Hello\\'s world'"
      },
      {
        "string (double quote)",
        function()
          return {
            "string",
            '"',
            "Hello's world"
          }
        end,
        [["Hello's world"]]
      },
      {
        "string (lua)",
        function()
          return {
            "string",
            '[==[',
            "Hello's world"
          }
        end,
        "[==[Hello's world]==]"
      },
      {
        "self",
        function()
          return {
            "self",
            ref()
          }
        end,
        "self.val"
      },
      {
        "self_class",
        function()
          return {
            "self_class",
            ref()
          }
        end,
        "self.__class.val"
      },
      {
        "self_class_colon",
        function()
          return {
            "self_class_colon",
            ref()
          }
        end,
        "self.__class:val"
      },
      {
        "not",
        function()
          return {
            "not",
            ref()
          }
        end,
        "not val"
      },
      {
        "length",
        function()
          return {
            "length",
            ref()
          }
        end,
        "#val"
      },
      {
        "length",
        function()
          return {
            "length",
            ref()
          }
        end,
        "#val"
      },
      {
        "bitnot",
        function()
          return {
            "bitnot",
            ref()
          }
        end,
        "~val"
      },
      {
        "chain (single)",
        function()
          return {
            "chain",
            ref()
          }
        end,
        "val"
      },
      {
        "chain (dot)",
        function()
          return {
            "chain",
            ref(),
            {
              "dot",
              "zone"
            }
          }
        end,
        "val.zone"
      },
      {
        "chain (index)",
        function()
          return {
            "chain",
            ref(),
            {
              "index",
              ref("x")
            }
          }
        end,
        "val[x]"
      },
      {
        "chain (call)",
        function()
          return {
            "chain",
            ref(),
            {
              "call",
              {
                ref("arg")
              }
            }
          }
        end,
        "val(arg)"
      },
      {
        "chain",
        function()
          return {
            "chain",
            ref(),
            {
              "dot",
              "one"
            },
            {
              "index",
              str()
            },
            {
              "colon",
              "two"
            },
            {
              "call",
              {
                ref("arg")
              }
            }
          }
        end,
        'val.one["dogzone"]:two(arg)'
      },
      {
        "chain (self receiver)",
        function()
          return {
            "chain",
            {
              "self",
              ref()
            },
            {
              "call",
              {
                ref("arg")
              }
            }
          }
        end,
        "self:val(arg)"
      },
      {
        "fndef (empty)",
        function()
          return {
            "fndef",
            { },
            { },
            "slim",
            { }
          }
        end,
        "function() end"
      }
    }
    for _index_0 = 1, #_list_0 do
      local _des_0 = _list_0[_index_0]
      local name, node, expected
      name, node, expected = _des_0[1], _des_0[2], _des_0[3]
      it("compiles " .. tostring(name), function()
        node = node()
        return assert.same(expected, compile_node(node))
      end)
    end
  end)
end)
