# Slimebound Siege

A Lua + Love2D project for an isometric mythical horde strategy game.

The project is currently in a documentation-first design phase. The main source of truth is:

- [Game Design Bible](docs/GAME_DESIGN.md)

## Requirements

- Love2D 11.5, for running the game
- Lua (or luacheck), for syntax checks

The project is cross-platform: develop on macOS or Windows interchangeably.

### macOS (Homebrew)

```sh
brew install lua
brew install --cask love
```

If Love2D is installed somewhere custom:

```sh
LOVE=/Applications/love.app/Contents/MacOS/love make run
```

### Windows

Install Love2D from <https://love2d.org> (or `winget install LOVE.LOVE`). If
`love.exe` is not on `PATH`, set its location for one session:

```powershell
$env:LOVE = "C:\Program Files\LOVE\love.exe"
```

## Commands

On macOS/Linux (Make):

```sh
make run      # launch the game
make check    # parse-check Lua files
make package  # create build/slimebound-siege.love
make clean    # remove build output
```

On Windows (PowerShell):

```powershell
./build.ps1 run
./build.ps1 check
./build.ps1 package
./build.ps1 clean
```

From VS Code on either OS, run the equivalents from the Command Palette via
**Tasks: Run Task** → `love: run` / `check` / `package` / `clean`.

## Project Layout

```text
conf.lua              Love2D window and runtime config
main.lua              Love2D callback entrypoint
src/game.lua          Game state and callback routing
src/scenes/           Prototype scenes
assets/               Images, fonts, sounds, maps
lib/                  Third-party Lua libraries
```

## Current Starting Point

The Love2D app currently shows a simple design-phase placeholder. The previous one-level prototype has been removed so the game can restart from the larger story and systems direction.
