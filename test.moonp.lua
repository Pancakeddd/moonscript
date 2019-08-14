local z = setmetatable({ }, {
  __index = function(self, k)
    return require(tostring("data") .. "." .. tostring(k))
  end
})
