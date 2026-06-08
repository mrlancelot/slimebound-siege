---
description: Implement one Slimebound Siege ticket by ID (reads the backlog + design docs + existing code, then codes it)
argument-hint: <ticket-id> [extra notes]   e.g. 1.1.1
---

You are implementing a **single ticket** from the Slimebound Siege build backlog.

**Target:** $ARGUMENTS

`$ARGUMENTS` is a ticket ID like `1.1.1` (optionally followed by extra notes/instructions).
If no ID was given, ask which ticket and stop.

The backlog is here (read it to find the ticket):

@docs/TICKETS.md

Follow these steps precisely.

## 1. Locate the ticket
Find the ID in `docs/TICKETS.md`. Read its **epic header** and the **milestone Goal /
Done-when** so you understand the context and acceptance. If the ID does not exist, list the
nearest matching tickets and stop.

## 2. Read the design (only what's relevant)
Read the sections the ticket depends on — do not restate them, just use them:
- `docs/ARCHITECTURE.md` — module layout, data shapes, runtime flow, the **pure-resolver** contract, controls.
- `docs/GAME_DESIGN.md` — mechanics and numbers (siege math, economy, elements).
- `docs/MONSTERS.md` — card families, monster types, abilities, merge recipes.
- `docs/STORY.md` / `docs/DIALOGUE.md` — for narrative / dialogue tickets.

## 3. Inspect existing code
Read the files the ticket touches and their neighbors (`src/`, `tests/`, `main.lua`,
`conf.lua`, `lib/`). Build on what earlier tickets already created; reuse existing
modules/helpers; match the surrounding style.

## 4. Implement exactly this ticket — nothing more
- **Tiny-ticket rule:** about 10 lines of code. If it genuinely needs more, implement the
  smallest correct version and note what you deliberately deferred. Do **not** silently pull
  in later tickets.
- Put files at the paths named in the ticket / ARCHITECTURE (`src/core`, `src/data`,
  `src/combat`, `src/states`, `src/ui`, `tests`).
- Keep logic **pure** where ARCHITECTURE says so — `src/combat/resolver.lua` and siege math
  must have **no `love.*` calls** so they stay unit-testable.
- **Presentation over logic:** UI reads colors from `src/ui/theme.lua`; animations/sound are
  event-driven and must be skippable (reduce-motion). They never change resolution.
- **Conventions:** LÖVE 11.x / LuaJIT (`love` is a global); **tabs** for indentation; double
  quotes; modules are `local M = {}` returning the table; `require("src.foo.bar")` paths.
  Honor `.luarc.json`, `stylua.toml`, `.editorconfig` (LF endings, final newline).

## 5. Verify
- Run `./build.ps1 check` (Windows) or `make check` (mac/Linux) — syntax/lint must pass.
- If you touched the resolver or other pure logic, run/extend the tests in `tests/` with
  `lua`/`luajit` if available.
- For a runnable change, say how to see it: `./build.ps1 run` (or `love .`). For **UI/visual**
  tickets, ask me to run it and paste a screenshot, and adjust to any screenshot I give you.

## 6. Report briefly
- **Ticket ID** + one line on what you did.
- **Files** created/changed.
- **Verification** result (check / tests).
- **Next ticket** ID in sequence, so I can just approve it.

Do **not** commit unless I ask. If the ticket is ambiguous, or blocked by an unfinished
prerequisite, say so and propose the prerequisite ticket instead of guessing.
