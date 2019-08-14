local Transformer
Transformer = require("moonscript.transform.transformer").Transformer
local build, ntype, smart_node
do
  local _obj_0 = require("moonscript.types")
  build, ntype, smart_node = _obj_0.build, _obj_0.ntype, _obj_0.smart_node
end
local NameProxy
NameProxy = require("moonscript.transform.names").NameProxy
local Accumulator, default_accumulator
do
  local _obj_0 = require("moonscript.transform.accumulator")
  Accumulator, default_accumulator = _obj_0.Accumulator, _obj_0.default_accumulator
end
local lua_keywords
lua_keywords = require("moonscript.data").lua_keywords
local Run, transform_last_stm, implicitly_return, chain_is_stub
do
  local _obj_0 = require("moonscript.transform.statements")
  Run, transform_last_stm, implicitly_return, chain_is_stub = _obj_0.Run, _obj_0.transform_last_stm, _obj_0.implicitly_return, _obj_0.chain_is_stub
end
local parse_str = require("moonscript.parse").string
local construct_comprehension
construct_comprehension = require("moonscript.transform.comprehension").construct_comprehension
local insert
insert = table.insert
local unpack, dump, dumpsimple
do
  local _obj_0 = require("moonscript.util")
  unpack, dump, dumpsimple = _obj_0.unpack, _obj_0.dump, _obj_0.dumpsimple
end
local reverse
reverse = function(t)
  local nt = { }
  for i = #t, 1, -1 do
    nt[#t - i + 1] = t[i]
  end
  return nt
end
return Transformer({
  ["for"] = default_accumulator,
  ["while"] = default_accumulator,
  foreach = default_accumulator,
  ["do"] = function(self, node)
    return build.block_exp(node[2])
  end,
  decorated = function(self, node)
    return self.transform.statement(node)
  end,
  class = function(self, node)
    return build.block_exp({
      node
    })
  end,
  string = function(self, node)
    local delim = node[2]
    local convert_part
    convert_part = function(part)
      if type(part) == "string" or part == nil then
        return {
          "string",
          delim,
          part or ""
        }
      else
        return build.chain({
          base = "tostring",
          {
            "call",
            {
              part[2]
            }
          }
        })
      end
    end
    if #node <= 3 then
      if type(node[3]) == "string" then
        return node
      else
        return convert_part(node[3])
      end
    end
    local e = {
      "exp",
      convert_part(node[3])
    }
    for i = 4, #node do
      insert(e, "..")
      insert(e, convert_part(node[i]))
    end
    return e
  end,
  comprehension = function(self, node)
    local a = Accumulator()
    node = self.transform.statement(node, function(exp)
      return a:mutate_body({
        exp
      })
    end)
    return a:wrap(node)
  end,
  tblcomprehension = function(self, node)
    local explist, clauses = unpack(node, 2)
    local key_exp, value_exp = unpack(explist)
    local accum = NameProxy("tbl")
    local inner
    if value_exp then
      local dest = build.chain({
        base = accum,
        {
          "index",
          key_exp
        }
      })
      inner = {
        build.assign_one(dest, value_exp)
      }
    else
      local key_name, val_name = NameProxy("key"), NameProxy("val")
      local dest = build.chain({
        base = accum,
        {
          "index",
          key_name
        }
      })
      inner = {
        build.assign({
          names = {
            key_name,
            val_name
          },
          values = {
            key_exp
          }
        }),
        build.assign_one(dest, val_name)
      }
    end
    return build.block_exp({
      build.assign_one(accum, build.table()),
      construct_comprehension(inner, clauses),
      accum
    })
  end,
  fndef = function(self, node)
    smart_node(node)
    node.body = transform_last_stm(node.body, implicitly_return(self))
    node.body = {
      Run(function(self)
        return self:listen("varargs", function() end)
      end),
      unpack(node.body)
    }
    return node
  end,
  ["if"] = function(self, node)
    return build.block_exp({
      node
    })
  end,
  unless = function(self, node)
    return build.block_exp({
      node
    })
  end,
  with = function(self, node)
    return build.block_exp({
      node
    })
  end,
  switch = function(self, node)
    return build.block_exp({
      node
    })
  end,
  pipe = function(self, node)
    local z = node[2]
    for _index_0 = 2, #node do
      local v = node[_index_0]
      local is_call = false
      for _index_1 = 1, #v do
        local th = v[_index_1]
        if th[1] and th[1] == "call" then
          is_call = true
        end
      end
      if (v[1] == "ref" or (v[1] == "chain" and v[2][1] == "ref" and not is_call)) and _index_0 > 2 then
        local previous_node = node[_index_0 - 1]
        local zy = z
        z = {
          "chain"
        }
        for _index_1 = 2, #v do
          local vz = v[_index_1]
          z[#z + 1] = vz
        end
        z[#z + 1] = {
          "call",
          {
            zy
          }
        }
      elseif _index_0 > 2 then
        local previous_node = node[_index_0 - 1]
        local zy = z
        z = {
          "chain"
        }
        for _index_1 = 2, #v do
          local vz = v[_index_1]
          if vz[1] and vz[1] == "call" then
            break
          end
          z[#z + 1] = vz
        end
        local call = nil
        for _index_1 = 1, #v do
          local th = v[_index_1]
          if th[1] and th[1] == "call" then
            call = th
          end
        end
        local args = {
          zy
        }
        local _list_0 = call[2]
        for _index_1 = 1, #_list_0 do
          local arg = _list_0[_index_1]
          args[#args + 1] = arg
        end
        z[#z + 1] = {
          "call",
          args
        }
      end
    end
    return z
  end,
  quote = function(self, node)
    return dumpsimple(node[2][1], self)
  end,
  chain = function(self, node)
    if self.macros:is_macro(node[2][2]) then
      local mname = node[2][2]
      local macro = self.macros:get_macro(mname)
      local z
      do
        local _with_0 = self:block(self:line("return function(builder, node)"))
        _with_0:stms(macro)
        z = _with_0
      end
      local rend = z:render(self:lines()):flatten()
      local code = ""
      for _index_0 = 1, #rend do
        local f = rend[_index_0]
        code = code .. f
      end
      print(code)
      local builder = setmetatable({
        literal = function(x)
          z = parse_str(x)
          if z then
            return self.transform.statement(z[1])
          end
        end,
        value = function(x)
          if ntype(x) == "string" then
            return "\"" .. tostring(x[3]) .. "\""
          end
          return x[2]
        end
      }, {
        __index = function(t, k)
          if not (t[k]) then
            return function(self, ...)
              return {
                k,
                ...
              }
            end
          else
            return t[k]
          end
        end
      })
      local mfun = loadstring(code)()
      return mfun(builder, node[#node][2])
    end
    for i = 2, #node do
      local part = node[i]
      if ntype(part) == "dot" and lua_keywords[part[2]] then
        node[i] = {
          "index",
          {
            "string",
            '"',
            part[2]
          }
        }
      end
    end
    if ntype(node[2]) == "string" then
      node[2] = {
        "parens",
        node[2]
      }
    end
    if chain_is_stub(node) then
      local base_name = NameProxy("base")
      local fn_name = NameProxy("fn")
      local colon = table.remove(node)
      local is_super = ntype(node[2]) == "ref" and node[2][2] == "super"
      return build.block_exp({
        build.assign({
          names = {
            base_name
          },
          values = {
            node
          }
        }),
        build.assign({
          names = {
            fn_name
          },
          values = {
            build.chain({
              base = base_name,
              {
                "dot",
                colon[2]
              }
            })
          }
        }),
        build.fndef({
          args = {
            {
              "..."
            }
          },
          body = {
            build.chain({
              base = fn_name,
              {
                "call",
                {
                  is_super and "self" or base_name,
                  "..."
                }
              }
            })
          }
        })
      })
    end
  end,
  block_exp = function(self, node)
    local body = unpack(node, 2)
    local fn = nil
    local arg_list = { }
    fn = smart_node(build.fndef({
      body = {
        Run(function(self)
          return self:listen("varargs", function()
            insert(arg_list, "...")
            insert(fn.args, {
              "..."
            })
            return self:unlisten("varargs")
          end)
        end),
        unpack(body)
      }
    }))
    return build.chain({
      base = {
        "parens",
        fn
      },
      {
        "call",
        arg_list
      }
    })
  end
})
