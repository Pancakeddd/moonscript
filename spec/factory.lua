local ref
ref = function(name)
  if name == nil then
    name = "val"
  end
  return {
    "ref",
    name
  }
end
local str
str = function(contents, delim)
  if contents == nil then
    contents = "dogzone"
  end
  if delim == nil then
    delim = '"'
  end
  return {
    "string",
    delim,
    contents
  }
end
return {
  ref = ref,
  str = str
}
