-- Smoke test: every vendored library resolves via its require path.
-- Run from the repo root with `luajit tests/lib_smoke.lua` (or inside LÖVE).
-- None of these touch `love.*` at load time, so plain Lua is enough.

package.path = package.path .. ";./?.lua;./?/init.lua"

local libs = {
	"lib.hump.gamestate",
	"lib.hump.timer",
	"lib.hump.camera",
	"lib.flux",
	"lib.lume",
	"lib.suit",
}

for _, name in ipairs(libs) do
	assert(require(name), name .. " failed to load")
	print("ok: " .. name)
end

print("all libraries loaded")
