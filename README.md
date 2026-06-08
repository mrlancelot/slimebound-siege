# Slimebound Siege

A Lua + Love2D **roguelike siege deckbuilder**. You play a person reincarnated as a weak
slime on the monster side of a fantasy war-game, commanding a horde to raid fortified
human towns by playing poker hands as siege assaults — `attack = ranks × combo × element`.
Inspired by poker-scoring roguelikes, built around three original verbs: multi-structure
sieges, merge-to-evolve your deck, and a town that fights back.

The project is in a documentation-first design phase. Sources of truth:

- [Game Design Bible](docs/GAME_DESIGN.md) — mechanics, cards, siege combat, run structure
- [Monster Roster](docs/MONSTERS.md) — the card pool (families, monster types, abilities)
- [Story Bible](docs/STORY.md) — premise, characters, acts, endings
- [Architecture](docs/ARCHITECTURE.md) — tech stack and code structure
- [Tickets](docs/TICKETS.md) — the micro-ticket MVP backlog
- [Dialogue Plan](docs/DIALOGUE.md) — dialogue format and first beats

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
src/core/             deck, run, save, rng
src/data/             cards, elements, structures, towns, jokers, events
src/combat/           pure-Lua combo + siege resolver
src/states/           menu, run/map, combat, shop, event, result
src/ui/               card rendering, town column, hud
tests/                resolver unit tests
assets/               card art, audio
lib/                  third-party Lua libraries (hump, flux, lume, SUIT)
```

## Current Starting Point

The Love2D app shows a simple design-phase placeholder. The project is mid-pivot from an
earlier isometric prototype to the siege deckbuilder described in the docs above; code for
the deckbuilder MVP is built ticket-by-ticket from [docs/TICKETS.md](docs/TICKETS.md).
