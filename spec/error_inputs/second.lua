local print
print = function() end
if false then
  local _ = true
  _ = true
  _ = true
  _ = true
  return print(hello)
else
  local _ = true
  _ = true
  _ = true
  _ = true
  print("hello world")
  return print(doesnt.exist)
end
