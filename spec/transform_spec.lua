local with_dev
with_dev = require("spec.helpers").with_dev
describe("moonscript.transform.destructure", function()
  local extract_assign_names
  with_dev(function()
    extract_assign_names = require("moonscriptplus.transform.destructure").extract_assign_names
  end)
  it("extracts names from table destructure", function()
    local des = {
      "table",
      {
        {
          {
            "key_literal",
            "hi"
          },
          {
            "ref",
            "hi"
          }
        },
        {
          {
            "key_literal",
            "world"
          },
          {
            "ref",
            "world"
          }
        }
      }
    }
    return assert.same({
      {
        {
          "ref",
          "hi"
        },
        {
          {
            "dot",
            "hi"
          }
        }
      },
      {
        {
          "ref",
          "world"
        },
        {
          {
            "dot",
            "world"
          }
        }
      }
    }, extract_assign_names(des))
  end)
  return it("extracts names from array destructure", function()
    local des = {
      "table",
      {
        {
          {
            "ref",
            "hi"
          }
        }
      }
    }
    return assert.same({
      {
        {
          "ref",
          "hi"
        },
        {
          {
            "index",
            {
              "number",
              1
            }
          }
        }
      }
    }, extract_assign_names(des))
  end)
end)
return describe("moonscript.transform.statements", function()
  local last_stm, transform_last_stm, Run
  with_dev(function()
    do
      local _obj_0 = require("moonscriptplus.transform.statements")
      last_stm, transform_last_stm, Run = _obj_0.last_stm, _obj_0.transform_last_stm, _obj_0.Run
    end
  end)
  describe("last_stm", function()
    it("gets last statement from empty list", function()
      return assert.same(nil, (last_stm({ })))
    end)
    it("gets last statement", function()
      local stms = {
        {
          "ref",
          "butt_world"
        },
        {
          "ref",
          "hello_world"
        }
      }
      local stm, idx, t = last_stm(stms)
      assert(stms[2] == stm)
      assert.same(2, idx)
      return assert(stms == t)
    end)
    it("gets last statement ignoring run", function()
      local stms = {
        {
          "ref",
          "butt_world"
        },
        {
          "ref",
          "hello_world"
        },
        Run(function(self)
          return print("hi")
        end)
      }
      local stm, idx, t = last_stm(stms)
      assert(stms[2] == stm)
      assert.same(2, idx)
      return assert(stms == t)
    end)
    return it("gets last from within group", function()
      local stms = {
        {
          "ref",
          "butt_world"
        },
        {
          "group",
          {
            {
              "ref",
              "hello_world"
            },
            {
              "ref",
              "cool_world"
            }
          }
        }
      }
      local last = stms[2][2][2]
      local stm, idx, t = last_stm(stms)
      assert(stm == last, "should get last")
      assert.same(2, idx)
      return assert(t == stms[2][2], "should get correct table")
    end)
  end)
  return describe("transform_last_stm", function()
    it("transforms empty stms", function()
      local before = { }
      local after = transform_last_stm(before, function(n)
        return {
          "wrapped",
          n
        }
      end)
      assert.same(before, after)
      return assert(before ~= after)
    end)
    it("transforms stms", function()
      local before = {
        {
          "ref",
          "butt_world"
        },
        {
          "ref",
          "hello_world"
        }
      }
      local transformer
      transformer = function(n)
        return n
      end
      local after = transform_last_stm(before, transformer)
      return assert.same({
        {
          "ref",
          "butt_world"
        },
        {
          "transform",
          {
            "ref",
            "hello_world"
          },
          transformer
        }
      }, after)
    end)
    return it("transforms empty stms ignoring runs", function()
      local before = {
        {
          "ref",
          "butt_world"
        },
        {
          "ref",
          "hello_world"
        },
        Run(function(self)
          return print("hi")
        end)
      }
      local transformer
      transformer = function(n)
        return n
      end
      local after = transform_last_stm(before, transformer)
      return assert.same({
        {
          "ref",
          "butt_world"
        },
        {
          "transform",
          {
            "ref",
            "hello_world"
          },
          transformer
        },
        before[3]
      }, after)
    end)
  end)
end)
