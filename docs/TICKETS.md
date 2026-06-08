# Slimebound Siege - Build Backlog

The implementation backlog for the **one-commit siege deckbuilder**. Design lives in
[GAME_DESIGN.md](GAME_DESIGN.md), [MONSTERS.md](MONSTERS.md), and [STORY.md](STORY.md);
code shape in [ARCHITECTURE.md](ARCHITECTURE.md). Tickets reference those instead of
restating them.

## Principles

- **Tiny tickets** - each is ~10 lines of code or less. If it feels bigger, split it.
- **Walking-skeleton order** - reach a playable end-to-end thread first (M1), then thicken.
- **Data-driven** - cards, monster abilities, town fight-back, and dialogue beats are
  **data tables + a few generic handlers**. New content = add a data row (and a handler
  only for a genuinely new effect *kind*). This is what keeps later content tiny.
- **DRY** - point at the design docs for content; don't restate it here.
- IDs are `milestone.epic.ticket` (e.g. `2.3.1` = milestone 2, epic 3, ticket 1).
- Near milestones are fully ticketed; far milestones (M5-M7) are compact epics with a
  **Done when**, detailed only when they come up.

---

## M0 - Foundations

**Goal:** the project boots into an empty state machine. **Done when:** `love .` opens a
Menu state and `make check` / `build.ps1 check` passes.

### 0.1 Folders & libraries
- `0.1.1` Create `src/core/`, `src/data/`, `src/combat/`, `src/states/`, `src/ui/`, `tests/`.
- `0.1.2` Create `assets/cards/`, `assets/audio/`; add `.gitkeep` to empty folders.
- `0.1.3` Add `lib/README.md` with vendoring + fallback rules.
- `0.1.4` Vendor `hump` (gamestate, timer, camera) and list its source URL.
- `0.1.5` Vendor `flux`, `lume`, `SUIT` and list their source URLs.
- `0.1.6` Add a one-`require` smoke file per library (hump/flux/lume/SUIT).

### 0.2 State machine
- `0.2.1` Require hump gamestate in `game.lua`.
- `0.2.2` Create empty `MenuState`, `CombatState`, `ResultState`.
- `0.2.3` Switch `main.lua` from the placeholder scene to `MenuState`.
- `0.2.4` `MenuState` -> start a siege (enter `CombatState`).
- `0.2.5` Add `enter/update/draw` stubs to each state.
- `0.2.6` Add `Result -> Combat` restart transition.

---

## M1 - Walking Skeleton

**Goal:** the steel thread - win or lose a one-lane siege on screen. No sculpt, elements,
or abilities yet. **Done when:** draw 7 -> put a combo in one lane -> commit -> Core
falls = victory screen; out of options = defeat; restart works; resolver tests pass.

### 1.1 Cards & deck (minimal)
- `1.1.1` `src/data/families.lua` (suit -> family) and rank-value table (2-10, J=11, Q=12, K=13, A=14).
- `1.1.2` `src/data/cards.lua` card shape `{suit, rank, element, monsterType}`.
- `1.1.3` `src/core/rng.lua` (seedable).
- `1.1.4` `src/core/deck.lua`: build from a card list, shuffle (seeded), draw to hand size 7.
- `1.1.5` 52-card vocabulary generator (tests/debug) + a tiny fixed test deck.

### 1.2 Pure resolver (start the core)
- `1.2.1` `src/combat/resolver.lua` (no Love2D calls).
- `1.2.2` `evaluateCombo(cards)` - high card, pair, three of a kind.
- `1.2.3` Add straight, flush, full house, four of a kind, straight flush.
- `1.2.4` `rankSum(cards)`; `resolveLane(cards, structure)` -> `{attack, destroyed}` (type-mult stubbed to 1).
- `1.2.5` `resolveCommit(lanes, town)` -> per-lane results; town conquered if Core lane destroyed it.

### 1.3 Resolver tests
- `1.3.1` `tests/resolver_spec.lua` (plain Lua asserts) + wire into `make check` / `build.ps1 check`.
- `1.3.2` Test each combo tier's mult and `rankSum`.
- `1.3.3` Test "1 low card clears a DEF-3 wall" and an overkill case.

### 1.4 Skeleton combat + screens
- `1.4.1` `src/data/towns.lua` with one hardcoded town (a Wall + a Core).
- `1.4.2` `CombatState`: draw 7, render hand + structures (placeholder rects).
- `1.4.3` Select cards into one lane; commit calls `resolveCommit`.
- `1.4.4` Core destroyed -> `ResultState` victory; no win + no cards -> defeat.
- `1.4.5` `ResultState` shows victory/defeat + restart button.

---

## M2 - The One-Commit Siege (depth)

**Goal:** the full combat from [GAME_DESIGN.md](GAME_DESIGN.md) "Siege Combat". **Done
when:** scout -> draw 7 -> 2 sculpt turns (exchange <=3) under fight-back -> assign lanes to
independent structures -> commit with elements -> Core = conquer / shortfall = expedition-HP
damage or retreat.

### 2.1 Structures, towns, elements
- `2.1.1` `src/data/elements.lua` (Fire/Acid/Physical damage; Frost/Poison utility).
- `2.1.2` `src/data/structures.lua` `{name, def, material, element, rule}` + Wood Wall, Iron Gate, Stone Tower, Town Core.
- `2.1.3` Expand `towns.lua` to a 3-4 **independent**-structure Frontier town.
- `2.1.4` `src/data/matchups.lua` - the 5x5 element/material table (see GAME_DESIGN).
- `2.1.5` `typeMultiplier(element, material)` in the resolver (replaces the M1 stub).
- `2.1.6` Frost effect: `frostReduction` lowers target DEF before compare.
- `2.1.7` Poison effect: ignore the x0.5 resist case.

### 2.2 Sculpt + commit loop
- `2.2.1` `src/combat/siege.lua` - town instance + per-structure `destroyed` flags.
- `2.2.2` Track sculpt turns left (2) and exchanges remaining (3).
- `2.2.3` Exchange: toss selected cards, redraw, decrement budget; reshuffle discard when draw empties.
- `2.2.4` Lane assignment: cards -> structureId (any lane -> any structure).
- `2.2.5` Commit applies all lanes via `resolveCommit`.
- `2.2.6` Bonus loot (gold/essence) for destroyed non-core structures.

### 2.3 Expedition HP, fight-back, outcome
- `2.3.1` Track expedition HP (start 30) on the run/slime.
- `2.3.2` Fight-back step fires each sculpt turn (one rule per town for now).
- `2.3.3` Rule: reinforce a structure's DEF.
- `2.3.4` Rule: lock a suit for the commit.
- `2.3.5` Rule: wound a card in hand (reduce its rank).
- `2.3.6` Rule: chip expedition HP.
- `2.3.7` Outcome: Core destroyed -> victory; Core survives -> expedition-HP damage; HP 0 or keep unbeaten -> retreat.

### 2.4 Combat UI
- `2.4.1` `src/ui/card.lua` - card face (rank, suit glyph, element pip).
- `2.4.2` Draw the 7-card hand + selection state.
- `2.4.3` `src/ui/town_view.lua` - independent structure cards as lane targets.
- `2.4.4` Highlight the lane a selected card is assigned to.
- `2.4.5` Live lane breakdown `rankSum x combo x type` (+/- effects).
- `2.4.6` Sculpt turns left + exchanges remaining; expedition-HP bar.
- `2.4.7` Assign-lane / exchange / commit input handling (see ARCHITECTURE controls).

### 2.5 Starting deck (explicit)
- `2.5.1` `src/data/starter_deck.lua` - exactly 16 cards: 4 Goblins (3/5/6/8), 4 Brutes
  (4/6/7/9), 4 Slimes (2/4/6/8), 3 Casters (3/5/7), 1 Slime Core (Ace); elements spread
  across Fire/Acid/Physical/Frost/Poison. (Tuning starting point.)

---

## M3 - Monster Abilities (data-driven)

**Goal:** every monster type in [MONSTERS.md](MONSTERS.md) has its commit-time ability.
**Done when:** abilities resolve as lane modifiers and the Imp can split into two lanes.

### 3.1 Effect framework
- `3.1.1` Define an `effects` table: `kind -> handler(ctx)` applied during `resolveLane` / `resolveCommit`.
- `3.1.2` Attach an `ability` (effect-kind + params) to each monster type in `monsters.lua`.
- `3.1.3` Handler hooks: pre-lane (DEF/rank tweaks), lane-mult, post-destroy (heal/loot), commit-wide.

### 3.2 Family abilities (one tiny ticket each, per MONSTERS.md)
- `3.2.1`-`3.2.6` Clubs: Runt, Sneak, Raider, Pack-leader, Goblin Boss, Goblin Khan.
- `3.2.7`-`3.2.12` Spades: Orcling, Orc Grunt, Ogre, Troll, Berserker, War Brute.
- `3.2.13`-`3.2.18` Hearts: Slime, Slime Spitter, Hex Slime, Greater Slime, Slime Familiar, Slime Core (wild).
- `3.2.19`-`3.2.24` Diamonds: Imp (multi-lane), Acolyte, Shaman, Dragonkin, Frost Mage, Wyvern.
- `3.2.25` Merged-monster abilities (Hobgoblin, Stone Ogre, Greater Slime, Hexling, Ember Brute, Hex Slime).
- `3.2.26` Tests: one assert per ability kind.

---

## M4 - The Expedition (the run)

**Goal:** a full single-town expedition - node map, shop, merge, companions, cores,
rewards. **Done when:** pick a core -> traverse ~8-12 nodes -> recruit/merge along the way
-> beat the keep = town conquered; retreat ends the run.

### 4.1 Expedition + node map
- `4.1.1` `src/core/expedition.lua` (deck, horde, gold, node, seed).
- `4.1.2` `ExpeditionState` renders + navigates a branching node map (~8-12 nodes).
- `4.1.3` Node types: Defense, Keep(boss), Recruit, Merge, Event, Rest, Training, Alchemy.
- `4.1.4` Enter `CombatState` from Defense/Keep nodes; return outcome.
- `4.1.5` Keep won -> town conquered (report out); HP 0 / keep lost -> retreat ends expedition.

### 4.2 Slime cores
- `4.2.1` `src/data/cores.lua` (Commander/Absorber/Alchemist/Warden).
- `4.2.2` Commander effect: **+1 exchange** (4 total). (Hand size stays 7.)
- `4.2.3` Core selection in `MenuState`; store on the run.

### 4.3 Shop, merge, rewards, companions
- `4.3.1` `ShopState`: offer cards for gold; add a bought card to the deck.
- `4.3.2` Reward amounts: keep win +50 gold/+10 essence; non-core +10 gold; card ~25g, companion ~60g.
- `4.3.3` `src/combat/merge.lua` recipe table + Goblin+Goblin=Hobgoblin and one hybrid (Slime+Caster=Hex Slime).
- `4.3.4` Merge node: consume fused cards, add the result.
- `4.3.5` Horde: 3 slots; recruit the first named companion (loyal goblin) at a camp.
- `4.3.6` Apply companion passives as commit-wide effect-handlers (reuse 3.1 framework).
- `4.3.7` Rest node (heal expedition HP); Training node (raise a combo mult for the run); Alchemy node (re-type/bump a card).

### 4.4 First-playable acceptance
- `4.4.1` Lanes target any structure; Imp splits; town fights back; Core wins; shortfall retreats.
- `4.4.2` A full expedition completes (cores -> nodes -> shop/merge -> keep), restart works, `check` + tests pass.

---

## M5 - The Campaign (overworld + meta + save)

**Goal:** the persistent layer that wraps expeditions. **Done when:** conquering towns
sticks on a kingdom map, the slime/meta persist, and a campaign saves/loads.

- `5.1` `OverworldState`: 5 kingdoms x several towns; pick a town -> launch an expedition.
- `5.2` Conquest persistence + HQ on conquered land; kingdom unlock gating by difficulty.
- `5.3` Slime-core leveling via story milestones; carries between expeditions.
- `5.4` Meta-unlocks: draftable card/companion pool, starting kits, boons.
- `5.5` `src/core/save.lua` - serialize/deserialize the `Campaign` table (lume.serialize); save slot(s).

---

## M6 - The Story

**Goal:** the narrative from [STORY.md](STORY.md)/[DIALOGUE.md](DIALOGUE.md) in-game via the
diegetic broken-UI narrator. **Done when:** Act I plays through dialogue + Event nodes, allies
recruit, companions can fall, and endings branch.

- `6.1` Dialogue engine: load Lua-table beats (`src/data/dialogue/`), render box + choices, set run/campaign flags. Overlay via the hump gamestate **stack** (on top of combat/overworld).
- `6.2` Broken-UI narrator styling (system/slime/character voices; glitch + patch-note flourishes).
- `6.3` Act I beats (Commute, Wakeup, First Siege, First Defector, Rules Reveal) as data files.
- `6.4` Event nodes run beats + apply choice effects; human-defector recruitment + ally effect.
- `6.5` Companion arcs + **permadeath scene variants** (alive/fallen lines keyed off flags); merge-sacrifice + special-boss loss.
- `6.6` Acts II-III beats (Knight-Commander, Inquisitor, Frost Warden, Crown Engine/Architect).
- `6.7` Three endings (Conqueror / Coexistence / Break-the-Engine) gated on ally + conquest flags.
- `6.8` Migrate branching beats to Ink/Tinta where it pays off (keep Lua fallback).

---

## M7 - Content & Polish

**Goal:** ship-quality breadth. **Done when:** all kingdoms are populated, balanced, and the
game looks/sounds/packages well.

- `7.1` Full town/kingdom roster + per-kingdom DEF scaling (Frontier x1 -> Crown x3) and fight-back stacks.
- `7.2` Full element/ability/economy balance pass (data-driven tuning).
- `7.3` Card art + `anim8` animation (card play, merges, kingdom backdrops).
- `7.4` Audio: sfx (commit, structure break, fight-back), per-kingdom music, narrator stings.
- `7.5` Accessibility pass (colorblind-safe suits/elements, text scale, input remap).
- `7.6` Packaging/release pipeline (`make package` / `build.ps1 package`) for Windows + macOS.

---

## Coverage map (every system/story has a home)

- **Combat core**: M1-M2 - resolver, sculpt, lanes, elements, fight-back, HP, UI.
- **Cards/deck**: M1 (deck/draw) + M2.5 (starter) + M4.3 (shop/merge) + M5.4 (meta pool).
- **Monster abilities**: M3 (all families + merged + Imp split).
- **Run loop**: M4 - nodes, cores, shop, merge, companions, rewards, Rest/Training/Alchemy.
- **Campaign/meta/save**: M5.
- **Story** (narrator, acts, companions, defectors, endings, dialogue, Ink): M6.
- **Art/audio/balance/accessibility/packaging**: M7.
