local print
print = function() end
if (function()
  print("hello world")
  return print("who is this")
end) then
  local _ = true
  _ = true
  _ = true
  _ = true
  print(dead.world)
  print("okay now")
  print("this is wrong")
  print("this is wrong")
  print("this is wrong")
  print("this is wrong")
  print("this is wrong")
  print("this is wrong")
  return print("this is wrong")
end
