local unindent
unindent = function(str)
  local indent = str:match("^%s+")
  if not (indent) then
    return str
  end
  return (str:gsub("\n" .. tostring(indent), "\n"):gsub("%s+$", ""):gsub("^%s+", ""))
end
local in_dev = false
local with_dev
with_dev = function(fn)
  if in_dev then
    error("already in dev mode")
  end
  local make_loader
  make_loader = require("loadkit").make_loader
  local loader = make_loader("lua", nil, "./?.lua")
  local setup, teardown
  do
    local _obj_0 = require("busted")
    setup, teardown = _obj_0.setup, _obj_0.teardown
  end
  local old_require = _G.require
  local dev_cache = { }
  setup(function()
    _G.require = function(mod)
      if dev_cache[mod] then
        return dev_cache[mod]
      end
      local testable = mod:match("moonscript%.") or mod == "moonscript" or mod:match("moon%.") or mod == "moon"
      if testable then
        local fname = assert(loader(mod), "failed to find module: " .. tostring(mod))
        dev_cache[mod] = assert(loadfile(fname))()
        return dev_cache[mod]
      end
      return old_require(mod)
    end
    if fn then
      return fn()
    end
  end)
  teardown(function()
    _G.require = old_require
    in_dev = false
  end)
  return dev_cache
end
return {
  unindent = unindent,
  with_dev = with_dev
}
