# Vendored libraries

Third-party LÖVE/Lua libraries are **vendored** (committed into the repo) so the game
builds and runs offline with no package manager. All are MIT-licensed and used unmodified.

## Contents

| Path            | Library | Modules used        | Source                                                  |
| --------------- | ------- | ------------------- | ------------------------------------------------------- |
| `hump/`         | hump    | gamestate, timer, camera | https://github.com/vrld/hump                       |
| `flux.lua`      | flux    | (single file)       | https://github.com/rxi/flux                             |
| `lume.lua`      | lume    | (single file)       | https://github.com/rxi/lume                             |
| `suit/`         | SUIT    | (package, via `init.lua`) | https://github.com/vrld/SUIT                      |

Vendored from each project's `master` branch on 2026-06-07.

## How to `require`

Paths are repo-relative, matching the project's `require("src.foo.bar")` convention:

```lua
local Gamestate = require("lib.hump.gamestate")
local Timer     = require("lib.hump.timer")
local Camera    = require("lib.hump.camera")
local flux      = require("lib.flux")
local lume      = require("lib.lume")
local suit      = require("lib.suit") -- resolves lib/suit/init.lua
```

## Vendoring + fallback rules

- **Vendor, don't depend.** Copy the source files in; never add a network/luarocks step
  to the build. The repo must clone-and-run.
- **Unmodified upstream.** Keep vendored files byte-for-byte from upstream so they can be
  re-pulled. If a local patch is unavoidable, mark it with a `-- PATCH:` comment and note
  it here.
- **Keep the LICENSE.** Vendor each library's license alongside it (e.g. `suit/license.txt`).
- **Minimal surface.** Vendor only the modules we use (hump ships many; we take three).
- **Lint exclusion.** `lib/` is excluded from luacheck (see `.luacheckrc`); we don't style
  third-party code.
- **Fallback for missing libs.** If a vendored file is absent or fails to load, fail loudly
  at startup with the missing `require` path — never silently stub it. `tests/lib_smoke.lua`
  is the canonical check that every library resolves.
- **Updating.** Re-download from the source URL above into the same path, re-run the smoke
  test, and update the "Vendored from … on …" date.
