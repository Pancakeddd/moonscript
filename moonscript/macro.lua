local Macros
do
  local _class_0
  local _base_0 = {
    add_macro = function(self, name, value)
      self.macros[name] = value
    end,
    is_macro = function(self, name)
      if self.macros[name] then
        return true
      end
      return false
    end,
    get_macro = function(self, name)
      return self.macros[name]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.macros = { }
    end,
    __base = _base_0,
    __name = "Macros"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Macros = _class_0
end
local m = Macros()
return m
