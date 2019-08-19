package = "moonscriptplus"
version = "dev-1"

source = {
	url = "git://github.com/Pancakeddd/moonscript.git"
}

description = {
	summary = "A programmer friendly language that compiles to Lua",
	detailed = "A programmer friendly language that compiles to Lua",
	homepage = "http://moonscript.org",
	maintainer = "Nathan J. Galler <chaneofcake@gmail.com>",
	license = "MIT"
}

dependencies = {
	"lua >= 5.1",
	"lpeg >= 0.10, ~= 0.11",
	"argparse >= 0.5",
	"luafilesystem >= 1.5"
}

build = {
	type = "builtin",
	modules = {
		["moon"] = "moon/init.lua",
		["moon.all"] = "moon/all.lua",
		["moonscriptplus"] = "moonscriptplus/init.lua",
		["moonscriptplus.macro"] = "moonscriptplus/macro.lua",
		["moonscriptplus.base"] = "moonscriptplus/base.lua",
		["moonscriptplus.cmd.coverage"] = "moonscriptplus/cmd/coverage.lua",
		["moonscriptplus.cmd.lint"] = "moonscriptplus/cmd/lint.lua",
		["moonscriptplus.cmd.moonc"] = "moonscriptplus/cmd/moonc.lua",
		["moonscriptplus.cmd.watchers"] = "moonscriptplus/cmd/watchers.lua",
		["moonscriptplus.compile"] = "moonscriptplus/compile.lua",
		["moonscriptplus.compile.statement"] = "moonscriptplus/compile/statement.lua",
		["moonscriptplus.compile.value"] = "moonscriptplus/compile/value.lua",
		["moonscriptplus.data"] = "moonscriptplus/data.lua",
		["moonscriptplus.dump"] = "moonscriptplus/dump.lua",
		["moonscriptplus.errors"] = "moonscriptplus/errors.lua",
		["moonscriptplus.line_tables"] = "moonscriptplus/line_tables.lua",
		["moonscriptplus.parse"] = "moonscriptplus/parse.lua",
		["moonscriptplus.parse.env"] = "moonscriptplus/parse/env.lua",
		["moonscriptplus.parse.literals"] = "moonscriptplus/parse/literals.lua",
		["moonscriptplus.parse.util"] = "moonscriptplus/parse/util.lua",
		["moonscriptplus.transform"] = "moonscriptplus/transform.lua",
		["moonscriptplus.transform.accumulator"] = "moonscriptplus/transform/accumulator.lua",
		["moonscriptplus.transform.class"] = "moonscriptplus/transform/class.lua",
		["moonscriptplus.transform.comprehension"] = "moonscriptplus/transform/comprehension.lua",
		["moonscriptplus.transform.destructure"] = "moonscriptplus/transform/destructure.lua",
		["moonscriptplus.transform.names"] = "moonscriptplus/transform/names.lua",
		["moonscriptplus.transform.statement"] = "moonscriptplus/transform/statement.lua",
		["moonscriptplus.transform.statements"] = "moonscriptplus/transform/statements.lua",
		["moonscriptplus.transform.transformer"] = "moonscriptplus/transform/transformer.lua",
		["moonscriptplus.transform.value"] = "moonscriptplus/transform/value.lua",
		["moonscriptplus.types"] = "moonscriptplus/types.lua",
		["moonscriptplus.util"] = "moonscriptplus/util.lua",
		["moonscriptplus.version"] = "moonscriptplus/version.lua",
	},
	install = {
		bin = { "bin/moonp", "bin/mooncp" }
	}
}

