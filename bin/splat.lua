local lfs = require("lfs")
local alt_getopt = require("alt_getopt")
local insert, concat
do
  local _obj_0 = table
  insert, concat = _obj_0.insert, _obj_0.concat
end
local dump, split
do
  local _obj_0 = require("moonscriptplus.util")
  dump, split = _obj_0.dump, _obj_0.split
end
local opts, ind = alt_getopt.get_opts(arg, "l:", {
  load = "l"
})
if not arg[ind] then
  print("usage: splat [-l module_names] directory [directories...]")
  os.exit()
end
local dirs
do
  local _accum_0 = { }
  local _len_0 = 1
  local _list_0 = arg
  for _index_0 = ind, #_list_0 do
    local a = _list_0[_index_0]
    _accum_0[_len_0] = a
    _len_0 = _len_0 + 1
  end
  dirs = _accum_0
end
local normalize
normalize = function(path)
  return path:match("(.-)/*$") .. "/"
end
local scan_directory
scan_directory = function(root, patt, collected)
  if collected == nil then
    collected = { }
  end
  root = normalize(root)
  for fname in lfs.dir(root) do
    if not fname:match("^%.") then
      local full_path = root .. fname
      if lfs.attributes(full_path, "mode") == "directory" then
        scan_directory(full_path, patt, collected)
      else
        if full_path:match(patt) then
          insert(collected, full_path)
        end
      end
    end
  end
  return collected
end
local path_to_module_name
path_to_module_name = function(path)
  return (path:match("(.-)%.lua"):gsub("/", "."))
end
local each_line
each_line = function(text)
  local yield
  yield = coroutine.yield
  return coroutine.wrap(function()
    local start = 1
    while true do
      local pos, after = text:find("\n", start, true)
      if not pos then
        break
      end
      yield(text:sub(start, pos - 1))
      start = after + 1
    end
    yield(text:sub(start, #text))
    return nil
  end)
end
local write_module
write_module = function(name, text)
  print("package.preload['" .. name .. "'] = function()")
  for line in each_line(text) do
    print("  " .. line)
  end
  return print("end")
end
local modules = { }
for _index_0 = 1, #dirs do
  local dir = dirs[_index_0]
  local files = scan_directory(dir, "%.lua$")
  local chunks
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_1 = 1, #files do
      local path = files[_index_1]
      local module_name = path_to_module_name(path)
      local content = io.open(path):read("*a")
      modules[module_name] = true
      local _value_0 = {
        module_name,
        content
      }
      _accum_0[_len_0] = _value_0
      _len_0 = _len_0 + 1
    end
    chunks = _accum_0
  end
  for _index_1 = 1, #chunks do
    local chunk = chunks[_index_1]
    local name, content = unpack(chunk)
    local base = name:match("(.-)%.init")
    if base and not modules[base] then
      modules[base] = true
      name = base
    end
    write_module(name, content)
  end
end
if opts.l then
  local _list_0 = split(opts.l, ",")
  for _index_0 = 1, #_list_0 do
    local module_name = _list_0[_index_0]
    if modules[module_name] then
      print(([[package.preload["%s"]()]]):format(module_name))
    end
  end
end
