-- Luacheck configuration for a Love2D (LuaJIT) project.
std = "luajit"

-- Love2D injects the global `love` table.
read_globals = {
	"love",
}

max_line_length = 100

exclude_files = {
	"build/",
	"lib/",
}
