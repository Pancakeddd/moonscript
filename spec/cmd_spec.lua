local with_dev
with_dev = require("spec.helpers").with_dev
return describe("moonc", function()
  local moonc
  local dev_loaded = with_dev(function()
    moonc = require("moonscript.cmd.moonc")
  end)
  local same
  same = function(fn, a, b)
    return assert.same(b, fn(a))
  end
  it("should normalize dir", function()
    same(moonc.normalize_dir, "hello/world/", "hello/world/")
    same(moonc.normalize_dir, "hello/world//", "hello/world/")
    same(moonc.normalize_dir, "", "/")
    return same(moonc.normalize_dir, "hello", "hello/")
  end)
  it("should parse dir", function()
    same(moonc.parse_dir, "/hello/world/file", "/hello/world/")
    same(moonc.parse_dir, "/hello/world/", "/hello/world/")
    same(moonc.parse_dir, "world", "")
    return same(moonc.parse_dir, "", "")
  end)
  it("should parse file", function()
    same(moonc.parse_file, "/hello/world/file", "file")
    same(moonc.parse_file, "/hello/world/", "")
    same(moonc.parse_file, "world", "world")
    return same(moonc.parse_file, "", "")
  end)
  it("convert path", function()
    same(moonc.convert_path, "test.moon", "test.lua")
    same(moonc.convert_path, "/hello/file.moon", "/hello/file.lua")
    return same(moonc.convert_path, "/hello/world/file", "/hello/world/file.lua")
  end)
  it("calculate target", function()
    local p = moonc.path_to_target
    assert.same("test.lua", p("test.moon"))
    assert.same("hello/world.lua", p("hello/world.moon"))
    assert.same("compiled/test.lua", p("test.moon", "compiled"))
    assert.same("/home/leafo/test.lua", p("/home/leafo/test.moon"))
    assert.same("compiled/test.lua", p("/home/leafo/test.moon", "compiled"))
    assert.same("/compiled/test.lua", p("/home/leafo/test.moon", "/compiled/"))
    assert.same("moonscript/hello.lua", p("moonscript/hello.moon", nil, "moonscript"))
    assert.same("out/moonscript/hello.lua", p("moonscript/hello.moon", "out", "moonscript"))
    assert.same("out/moonscript/package/hello.lua", p("moonscript/package/hello.moon", "out", "moonscript/"))
    return assert.same("/out/moonscript/package/hello.lua", p("/home/leafo/moonscript/package/hello.moon", "/out", "/home/leafo/moonscript"))
  end)
  it("should compile file text", function()
    return assert.same({
      [[return print('hello')]]
    }, {
      moonc.compile_file_text("print'hello'", {
        fname = "test.moon"
      })
    })
  end)
  describe("watcher", function()
    return describe("inotify watcher", function()
      return it("gets dirs", function()
        local InotifyWacher
        InotifyWacher = require("moonscript.cmd.watchers").InotifyWacher
        local watcher = InotifyWacher({
          {
            "hello.moon",
            "hello.lua"
          },
          {
            "cool/no.moon",
            "cool/no.lua"
          }
        })
        return assert.same({
          "./",
          "cool/"
        }, watcher:get_dirs())
      end)
    end)
  end)
  describe("parse args", function()
    it("parses spec", function()
      local parse_spec
      parse_spec = require("moonscript.cmd.args").parse_spec
      local spec = parse_spec("lt:o:X")
      return assert.same({
        X = { },
        o = {
          value = true
        },
        t = {
          value = true
        },
        l = { }
      }, spec)
    end)
    return it("parses arguments", function()
      local parse_arguments
      parse_arguments = require("moonscript.cmd.args").parse_arguments
      local out, res = parse_arguments({
        "ga:p",
        print = "p"
      }, {
        "hello",
        "word",
        "-gap"
      })
      return assert.same({
        g = true,
        a = true,
        p = true
      }, out)
    end)
  end)
  return describe("stubbed lfs", function()
    local dirs
    before_each(function()
      dirs = { }
      package.loaded.lfs = nil
      dev_loaded["moonscript.cmd.moonc"] = nil
      package.loaded.lfs = {
        mkdir = function(dir)
          return table.insert(dirs, dir)
        end,
        attributes = function()
          return "directory"
        end
      }
      moonc = require("moonscript.cmd.moonc")
    end)
    after_each(function()
      package.loaded.lfs = nil
      dev_loaded["moonscript.cmd.moonc"] = nil
      moonc = require("moonscript.cmd.moonc")
    end)
    return it("should make directory", function()
      moonc.mkdir("hello/world/directory")
      return assert.same({
        "hello",
        "hello/world",
        "hello/world/directory"
      }, dirs)
    end)
  end)
end)
