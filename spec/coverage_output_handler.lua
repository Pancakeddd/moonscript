local load_line_table
load_line_table = function(chunk_name)
  local to_lua
  to_lua = require("moonscriptplus.base").to_lua
  if not (chunk_name:match("^@")) then
    return 
  end
  local fname = chunk_name:sub(2)
  local file = assert(io.open(fname))
  local code = file:read("*a")
  file:close()
  local c, ltable = to_lua(code)
  if not (c) then
    return nil, ltable
  end
  local line_tables = require("moonscriptplus.line_tables")
  line_tables[chunk_name] = ltable
  return true
end
return function(options)
  local busted = require("busted")
  local handler = require("busted.outputHandlers.utfTerminal")(options)
  local spec_name
  local coverage = require("moonscriptplus.cmd.coverage")
  local cov = coverage.CodeCoverage()
  busted.subscribe({
    "test",
    "start"
  }, function(context)
    return cov:start()
  end)
  busted.subscribe({
    "test",
    "end"
  }, function()
    return cov:stop()
  end)
  busted.subscribe({
    "suite",
    "end"
  }, function(context)
    local line_counts = { }
    for chunk_name, counts in pairs(cov.line_counts) do
      local _continue_0 = false
      repeat
        if not (chunk_name:match("^@$./") or chunk_name:match("@[^/]")) then
          _continue_0 = true
          break
        end
        if chunk_name:match("^@spec/") then
          _continue_0 = true
          break
        end
        if chunk_name:match("%.lua$") then
          chunk_name = chunk_name:gsub("lua$", "moon")
          if not (load_line_table(chunk_name)) then
            _continue_0 = true
            break
          end
        end
        line_counts[chunk_name] = counts
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
    cov.line_counts = line_counts
    return cov:format_results()
  end)
  return handler
end
