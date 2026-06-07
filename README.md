# Slimebound Siege

A Lua + Love2D project for an isometric mythical horde strategy game.

The project is currently in a documentation-first design phase. The main source of truth is:

- [Game Design Bible](docs/GAME_DESIGN.md)

## Requirements

- Lua, for syntax checks
- Love2D, for running the game

On macOS with Homebrew:

```sh
brew install lua
brew install --cask love
```

If Love2D is installed somewhere custom, run with:

```sh
LOVE=/Applications/love.app/Contents/MacOS/love make run
```

## Commands

```sh
make run      # launch the game
make check    # parse-check Lua files
make package  # create build/slimebound-siege.love
make clean    # remove build output
```

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
