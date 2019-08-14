local unindent, with_dev
do
  local _obj_0 = require("spec.helpers")
  unindent, with_dev = _obj_0.unindent, _obj_0.with_dev
end
return describe("moonscript.errors", function()
  local moonscript, errors, util, to_lua
  moonscript = require("moonscript.base")
  errors = require("moonscript.errors")
  util = require("moonscript.util")
  to_lua = moonscript.to_lua
  local get_rewritten_line_no
  get_rewritten_line_no = function(fname)
    fname = "spec/error_inputs/" .. tostring(fname) .. ".moon"
    local chunk = moonscript.loadfile(fname)
    local success, err = pcall(chunk)
    if success then
      error("`" .. tostring(fname) .. "` is supposed to have runtime error!")
    end
    local source = tonumber(err:match("^.-:(%d+):"))
    local line_table = assert(require("moonscript.line_tables")["@" .. tostring(fname)], "missing line table")
    return errors.reverse_line_number(fname, line_table, source, { })
  end
  describe("error rewriting", function()
    local tests = {
      ["first"] = 24,
      ["second"] = 16,
      ["third"] = 11
    }
    for name, expected_no in pairs(tests) do
      it("should rewrite line number", function()
        return assert.same(get_rewritten_line_no(name), expected_no)
      end)
    end
  end)
  describe("line map", function()
    it("should create line table", function()
      local moon_code = unindent([[        print "hello world"
        if something
          print "cats"
      ]])
      local lua_code, posmap = assert(to_lua(moon_code))
      return assert.same({
        1,
        23,
        36,
        21
      }, posmap)
    end)
    return it("should create line table for multiline string", function()
      local moon_code = unindent([[        print "one"
        x = [==[
          one
          two
          thre
          yes
          no
        ]==]
        print "two"
      ]])
      local lua_code, posmap = assert(to_lua(moon_code))
      return assert.same({
        [1] = 1,
        [2] = 13,
        [7] = 13,
        [8] = 57
      }, posmap)
    end)
  end)
  return describe("error reporting", function()
    return it("should compile bad code twice", function()
      local code, err = to_lua("{b=5}")
      assert.truthy(err)
      local err2
      code, err2 = to_lua("{b=5}")
      return assert.same(err, err2)
    end)
  end)
end)
