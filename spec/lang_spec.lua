local lfs = require("lfs")
local with_dev
with_dev = require("spec.helpers").with_dev
local pattern = ...
local unpack = table.unpack or unpack
local options = {
  in_dir = "spec/inputs",
  out_dir = "spec/outputs",
  input_pattern = "(.*)%.moon$",
  output_ext = ".lua",
  show_timings = os.getenv("TIME"),
  diff = {
    tool = "git diff --no-index --color",
    filter = function(str)
      return table.concat((function()
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = ((function()
          local _accum_1 = { }
          local _len_1 = 1
          for line in str:gmatch("[^\n]+") do
            _accum_1[_len_1] = line
            _len_1 = _len_1 + 1
          end
          return _accum_1
        end)())
        for _index_0 = 5, #_list_0 do
          local l = _list_0[_index_0]
          _accum_0[_len_0] = l
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(), "\n")
    end
  }
}
local timings = { }
local gettime = nil
pcall(function()
  require("socket")
  gettime = socket.gettime
end)
gettime = gettime or os.clock
local benchmark
benchmark = function(fn)
  if gettime then
    local start = gettime()
    local res = {
      fn()
    }
    return gettime() - start, unpack(res)
  else
    return nil, fn()
  end
end
local read_all
read_all = function(fname)
  do
    local f = io.open(fname, "r")
    if f then
      do
        local _with_0 = f:read("*a")
        f:close()
        return _with_0
      end
    end
  end
end
local diff_file
diff_file = function(a_fname, b_fname)
  local out = io.popen(options.diff.tool .. " " .. a_fname .. " " .. b_fname, "r"):read("*a")
  if options.diff.filter then
    out = options.diff.filter(out)
  end
  return out
end
local diff_str
diff_str = function(expected, got)
  local a_tmp = os.tmpname() .. ".expected"
  local b_tmp = os.tmpname() .. ".got"
  do
    local _with_0 = io.open(a_tmp, "w")
    _with_0:write(expected)
    _with_0:close()
  end
  do
    local _with_0 = io.open(b_tmp, "w")
    _with_0:write(got)
    _with_0:close()
  end
  do
    local _with_0 = diff_file(a_tmp, b_tmp)
    os.remove(a_tmp)
    os.remove(b_tmp)
    return _with_0
  end
end
local string_assert
string_assert = function(expected, got)
  if expected ~= got then
    local diff = diff_str(expected, got)
    if os.getenv("HIDE_DIFF") then
      error("string equality assert failed")
    end
    return error("string equality assert failed:\n" .. diff)
  end
end
local input_fname
input_fname = function(base)
  return options.in_dir .. "/" .. base .. ".moon"
end
local output_fname
output_fname = function(base)
  return options.out_dir .. "/" .. base .. options.output_ext
end
local inputs
do
  local _accum_0 = { }
  local _len_0 = 1
  for file in lfs.dir(options.in_dir) do
    local _continue_0 = false
    repeat
      do
        local match = file:match(options.input_pattern)
        if not (match) then
          _continue_0 = true
          break
        end
        _accum_0[_len_0] = match
      end
      _len_0 = _len_0 + 1
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  inputs = _accum_0
end
table.sort(inputs)
return describe("input tests", function()
  local parse, compile
  with_dev(function()
    parse = require("moonscript.parse")
    compile = require("moonscript.compile")
  end)
  for _index_0 = 1, #inputs do
    local name = inputs[_index_0]
    local input = input_fname(name)
    it(input .. " #input", function()
      local file_str = read_all(input_fname(name))
      local parse_time, tree, err = benchmark(function()
        return parse.string(file_str)
      end)
      if err then
        error(err)
      end
      local compile_time, code, pos
      compile_time, code, err, pos = benchmark(function()
        return compile.tree(tree)
      end)
      if not (code) then
        error(compile.format_error(err, pos, file_str))
      end
      table.insert(timings, {
        name,
        parse_time,
        compile_time
      })
      if os.getenv("BUILD") then
        do
          local _with_0 = io.open(output_fname(name), "w")
          _with_0:write(code)
          _with_0:close()
        end
      else
        local expected_str = read_all(output_fname(name))
        if not (expected_str) then
          error("Test not built: " .. input_fname(name))
        end
        string_assert(expected_str, code)
      end
      return nil
    end)
  end
  if options.show_timings then
    return teardown(function()
      local format_time
      format_time = function(sec)
        return ("%.3fms"):format(sec * 1000)
      end
      local col_width = math.max(unpack((function()
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #timings do
          local t = timings[_index_0]
          _accum_0[_len_0] = #t[1]
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)()))
      print("\nTimings:")
      local total_parse, total_compile = 0, 0
      for _index_0 = 1, #timings do
        local tuple = timings[_index_0]
        local name, parse_time, compile_time = unpack(tuple)
        name = name .. (" "):rep(col_width - #name)
        total_parse = total_parse + parse_time
        total_compile = total_compile + compile_time
        print(" * " .. name, "p: " .. format_time(parse_time), "c: " .. format_time(compile_time))
      end
      print("\nTotal:")
      print("    parse:", format_time(total_parse))
      return print("  compile:", format_time(total_compile))
    end)
  end
end)
