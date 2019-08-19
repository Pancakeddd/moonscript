local lpeg = require("lpeg")
local mark
mark = function(name, ...)
  return {
    name,
    ...
  }
end
local grammar = lpeg.P({
  "main",
  main = lpeg.V("factor"),
  factor = z
})
return 
