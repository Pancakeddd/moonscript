local with_dev
with_dev = require("spec.helpers").with_dev
return describe("moonscript.base", function()
  with_dev()
  return it("should create moonpath", function()
    local path = ";./?.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;/usr/lib/lua/5.1/?.luac;/home/leafo/.luarocks/lua/5.1/?.lua"
    local create_moonpath
    create_moonpath = require("moonscriptplus.base").create_moonpath
    return assert.same("./?.moon;/usr/share/lua/5.1/?.moon;/usr/share/lua/5.1/?/init.moon;/home/leafo/.luarocks/lua/5.1/?.moon", create_moonpath(path))
  end)
end)
