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
- **Presentation over logic** - animations, color, sprites, and sound are driven by *events*
  from the pure combat logic; they never block or change resolution, and can be disabled
  (reduce-motion) without touching rules.
- Near milestones are fully ticketed; the campaign/story epics (M5-M6) stay compact until
  they come up, while presentation (M7-M8) is ticketed in fine detail.

---

## M0 - Foundations

**Goal:** the project boots into an empty state machine. **Done when:** `love .` opens a
Menu state and `make check` / `build.ps1 check` passes.

> **Status: ✅ Complete.**

### 0.1 Folders & libraries
- [x] `0.1.1` Create `src/core/`, `src/data/`, `src/combat/`, `src/states/`, `src/ui/`, `tests/`.
- [x] `0.1.2` Create `assets/cards/`, `assets/audio/`; add `.gitkeep` to empty folders.
- [x] `0.1.3` Add `lib/README.md` with vendoring + fallback rules.
- [x] `0.1.4` Vendor `hump` (gamestate, timer, camera) and list its source URL.
- [x] `0.1.5` Vendor `flux`, `lume`, `SUIT` and list their source URLs.
- [x] `0.1.6` Add a one-`require` smoke file per library (hump/flux/lume/SUIT).

### 0.2 State machine
- [x] `0.2.1` Require hump gamestate in `game.lua`.
- [x] `0.2.2` Create empty `MenuState`, `CombatState`, `ResultState`.
- [x] `0.2.3` Switch `main.lua` from the placeholder scene to `MenuState`.
- [x] `0.2.4` `MenuState` -> start a siege (enter `CombatState`).
- [x] `0.2.5` Add `enter/update/draw` stubs to each state.
- [x] `0.2.6` Add `Result -> Combat` restart transition.

---

## M1 - Walking Skeleton

**Goal:** the steel thread - win or lose a one-lane siege on screen. No sculpt, elements,
or abilities yet. **Done when:** draw 7 -> put a combo in one lane -> commit -> Core
falls = victory screen; out of options = defeat; restart works; resolver tests pass.

> **Status: ✅ Complete.**

### 1.1 Cards & deck (minimal)
- [x] `1.1.1` `src/data/families.lua` (suit -> family) and rank-value table (2-10, J=11, Q=12, K=13, A=14).
- [x] `1.1.2` `src/data/cards.lua` card shape `{suit, rank, element, monsterType}`.
- [x] `1.1.3` `src/core/rng.lua` (seedable).
- [x] `1.1.4` `src/core/deck.lua`: build from a card list, shuffle (seeded), draw to hand size 7.
- [x] `1.1.5` 52-card vocabulary generator (tests/debug) + a tiny fixed test deck.

### 1.2 Pure resolver (start the core)
- [x] `1.2.1` `src/combat/resolver.lua` (no Love2D calls).
- [x] `1.2.2` `evaluateCombo(cards)` - high card, pair, three of a kind.
- [x] `1.2.3` Add straight, flush, full house, four of a kind, straight flush.
- [x] `1.2.4` `rankSum(cards)`; `resolveLane(cards, structure)` -> `{attack, destroyed}` (type-mult stubbed to 1).
- [x] `1.2.5` `resolveCommit(lanes, town)` -> per-lane results; town conquered if Core lane destroyed it.

### 1.3 Resolver tests
- [x] `1.3.1` `tests/resolver_spec.lua` (plain Lua asserts) + wire into `make check` / `build.ps1 check`.
- [x] `1.3.2` Test each combo tier's mult and `rankSum`.
- [x] `1.3.3` Test "1 low card clears a DEF-3 wall" and an overkill case.

### 1.4 Skeleton combat + screens
- [x] `1.4.1` `src/data/towns.lua` with one hardcoded town (a Wall + a Core).
- [x] `1.4.2` `CombatState`: draw 7, render hand + structures (placeholder rects).
- [x] `1.4.3` Select cards into one lane; commit calls `resolveCommit`.
- [x] `1.4.4` Core destroyed -> `ResultState` victory; no win + no cards -> defeat.
- [x] `1.4.5` `ResultState` shows victory/defeat + restart button.

---

## M2 - The One-Commit Siege (depth)

**Goal:** the full combat from [GAME_DESIGN.md](GAME_DESIGN.md) "Siege Combat". **Done
when:** scout -> draw 7 -> 2 sculpt turns (exchange <=3) under fight-back -> assign lanes to
independent structures -> commit with elements -> Core = conquer / shortfall = expedition-HP
damage or retreat.

> **Status: ✅ Complete** — except `2.6.7` (custom `.ttf` font asset still to be added;
> running on the default font via the fallback loader).

### 2.1 Structures, towns, elements
- [x] `2.1.1` `src/data/elements.lua` (Fire/Acid/Physical damage; Frost/Poison utility).
- [x] `2.1.2` `src/data/structures.lua` `{name, def, material, element, rule}` + Wood Wall, Iron Gate, Stone Tower, Town Core.
- [x] `2.1.3` Expand `towns.lua` to a 3-4 **independent**-structure Frontier town.
- [x] `2.1.4` `src/data/matchups.lua` - the 5x5 element/material table (see GAME_DESIGN).
- [x] `2.1.5` `typeMultiplier(element, material)` in the resolver (replaces the M1 stub).
- [x] `2.1.6` Frost effect: `frostReduction` lowers target DEF before compare.
- [x] `2.1.7` Poison effect: ignore the x0.5 resist case.

### 2.2 Sculpt + commit loop
- [x] `2.2.1` `src/combat/siege.lua` - town instance + per-structure `destroyed` flags.
- [x] `2.2.2` Track sculpt turns left (2) and exchanges remaining (3).
- [x] `2.2.3` Exchange: toss selected cards, redraw, decrement budget; reshuffle discard when draw empties.
- [x] `2.2.4` Lane assignment: cards -> structureId (any lane -> any structure).
- [x] `2.2.5` Commit applies all lanes via `resolveCommit`.
- [x] `2.2.6` Bonus loot (gold/essence) for destroyed non-core structures.

### 2.3 Expedition HP, fight-back, outcome
- [x] `2.3.1` Track expedition HP (start 30) on the run/slime.
- [x] `2.3.2` Fight-back step fires each sculpt turn (one rule per town for now).
- [x] `2.3.3` Rule: reinforce a structure's DEF.
- [x] `2.3.4` Rule: lock a suit for the commit.
- [x] `2.3.5` Rule: wound a card in hand (reduce its rank).
- [x] `2.3.6` Rule: chip expedition HP.
- [x] `2.3.7` Outcome: Core destroyed -> victory; Core survives -> expedition-HP damage; HP 0 or keep unbeaten -> retreat.

### 2.4 Combat UI
- [x] `2.4.1` `src/ui/card.lua` - card face (rank, suit glyph, element pip).
- [x] `2.4.2` Draw the 7-card hand + selection state.
- [x] `2.4.3` `src/ui/town_view.lua` - independent structure cards as lane targets.
- [x] `2.4.4` Highlight the lane a selected card is assigned to.
- [x] `2.4.5` Live lane breakdown `rankSum x combo x type` (+/- effects).
- [x] `2.4.6` Sculpt turns left + exchanges remaining; expedition-HP bar.
- [x] `2.4.7` Assign-lane / exchange / commit input handling (see ARCHITECTURE controls).

### 2.5 Starting deck (explicit)
- [x] `2.5.1` `src/data/starter_deck.lua` - exactly 16 cards: 4 Goblins (3/5/6/8), 4 Brutes
  (4/6/7/9), 4 Slimes (2/4/6/8), 3 Casters (3/5/7), 1 Slime Core (Ace); elements spread
  across Fire/Acid/Physical/Frost/Poison. (Tuning starting point.)

### 2.6 Visual theme (minimal, so placeholders read)
- [x] `2.6.1` `src/ui/theme.lua` - one palette table (UI chrome + suits + elements + materials).
- [x] `2.6.2` UI chrome: bg `#15151e`, panel `#2a2a3a`, text `#e8e8ec`, muted `#9a9aa8`, accent `#f0c040`, success `#6aa84f`, danger `#e2554a`.
- [x] `2.6.3` Suit colors: Clubs `#6aa84f`, Spades `#7f8a9b`, Hearts `#d6608f`, Diamonds `#b06fd6`.
- [x] `2.6.4` Element colors: Fire `#e2554a`, Acid `#b6d94c`, Physical `#d8d2c2`, Frost `#5fc7e8`, Poison `#7d4b9c`.
- [x] `2.6.5` Material colors: Wood `#8a5a2b`, Iron `#6d7079`, Stone `#9a9488`, Ice `#b8e0ef`, Holy `#f2e6b3`.
- [x] `2.6.6` `theme.hex(name)` helper -> `{r,g,b}` (0-1) for `love.graphics.setColor`.
- [ ] `2.6.7` Load a pixel/monospace `.ttf` from `assets/`; set as the default font.
  _**TODO (deferred):** keep the LÖVE default font for now. Loader + default-font fallback in
  `theme.applyFont` is already in place — drop a `.ttf` into `assets/` later to finish this._
- [x] `2.6.8` Recolor the card faces, structure cards, and HP bar from `theme` (retire bare rects).

---

## M2.7 - Combat Depth (HP/armor, keywords, reach, gamble)

**Goal:** add deterministic depth + one opt-in gamble so the siege isn't a single pass/fail
threshold. **Done when:** structures use HP + armor, keywords (Shield/Regen/Thorns/Ward) and
Reach layering resolve, and a lane can spend a die (+1-6) or coin (x1.5 / x0.5). See the new
GAME_DESIGN "Siege Combat" subsections. Lands **before** M3 (several abilities build on it).

> **Status: ✅ Complete.**

### 2.7.1 Structure HP + armor
- [x] `2.7.1.1` Add `hp` + `armor` to `src/data/structures.lua` (hp = old def 3/6/9/14) + a
  material armor table (Wood 1, Iron 2, Stone 3, Ice 1, Holy 2 - tuning).
- [x] `2.7.1.2` Resolver: `damage = max(0, attack - armor)`, `destroyed = damage >= hp`; add an
  `ignoreArmor` hook (used by Orc Grunt / Hex Slime in M3).
- [x] `2.7.1.3` `src/ui/town_view.lua`: show HP + armor on the structure card.
- [x] `2.7.1.4` Resolver tests: armor reduces damage; ignore-armor restores it; overkill vs hp.

### 2.7.2 Structure keywords
- [x] `2.7.2.1` `keywords` field on structures + a `kind -> handler` table (reuse the data-driven pattern).
- [x] `2.7.2.2` Shield: immune until the structure in front is destroyed (with Reach).
- [x] `2.7.2.3` Regen N: heal N hp at the start of each sculpt turn (in `siege.endSculpt`).
- [x] `2.7.2.4` Thorns N: a lane that hits it costs the slime N expedition HP on commit.
- [x] `2.7.2.5` Ward <element>: that element deals x0.5 to the structure (resolver).
- [x] `2.7.2.6` UI: keyword badges on the structure card.
- [x] `2.7.2.7` Tests: one assert per keyword.

### 2.7.3 Reach / siege layers
- [x] `2.7.3.1` Front->back order + back-row flag on `towns.lua` structures.
- [x] `2.7.3.2` Reach rule in `siege.assign`: back structure allowed only if front destroyed or
  the lane has a Caster (Diamonds).
- [x] `2.7.3.3` UI: locked/unreachable target indicator.
- [x] `2.7.3.4` Tests: reach blocks/allows assignment correctly.

### 2.7.4 Gamble tokens (coin + die)
- [x] `2.7.4.1` `tokens = { coin = N, die = N }` on the siege/expedition + starting amounts (tuning).
- [x] `2.7.4.2` `siege.applyDie(laneId)` - +1..6 to the lane via the seeded `rng.lua`; consume a die.
- [x] `2.7.4.3` `siege.applyCoin(laneId)` - flip x1.5 / x0.5 on the lane; consume a coin.
- [x] `2.7.4.4` Resolver: accept per-lane `bonusAdd` / `bonusMult` modifiers; order `(attack+add)*mult`.
- [x] `2.7.4.5` Input + UI: spend a token on the targeted lane; show it in the lane breakdown.
- [x] `2.7.4.6` Loot/shop grant tokens (hook into M2.2.6 loot and M4.3 shop).
- [x] `2.7.4.7` Tests: die/coin modifiers apply in the right order; tokens decrement.

---

## M3 - Monster Abilities (data-driven)

**Goal:** every monster type in [MONSTERS.md](MONSTERS.md) has its commit-time ability.
**Done when:** abilities resolve as lane modifiers and the Imp can split into two lanes.

> **Builds on M2.7** - Orc Grunt / Hex Slime use the `ignoreArmor` hook, Casters use Reach,
> Dragonkin carries overkill onto a structure's HP, Frost Mage / Slime Spitter lower HP.

> **Status: ✅ Complete** — all family + merged abilities and the Imp split resolve; abilities
> auto-attach to cards by suit+rank band (`monsters.lua`) and dispatch via `effects.lua`.

### 3.1 Effect framework
- [x] `3.1.1` Define an `effects` table: `kind -> handler(ctx)` applied during `resolveLane` / `resolveCommit`.
- [x] `3.1.2` Attach an `ability` (effect-kind + params) to each monster type in `monsters.lua`.
- [x] `3.1.3` Handler hooks: pre-lane (DEF/rank tweaks), lane-mult, post-destroy (heal/loot), commit-wide.

### 3.2 Family abilities (one tiny ticket each, per MONSTERS.md)
- [x] `3.2.1`-`3.2.6` Clubs: Runt, Sneak, Raider, Pack-leader, Goblin Boss, Goblin Khan.
- [x] `3.2.7`-`3.2.12` Spades: Orcling, Orc Grunt, Ogre, Troll, Berserker, War Brute.
- [x] `3.2.13`-`3.2.18` Hearts: Slime, Slime Spitter, Hex Slime, Greater Slime, Slime Familiar, Slime Core (wild).
- [x] `3.2.19`-`3.2.24` Diamonds: Imp (multi-lane), Acolyte, Shaman, Dragonkin, Frost Mage, Wyvern.
- [x] `3.2.25` Merged-monster abilities (Hobgoblin, Stone Ogre, Greater Slime, Hexling, Ember Brute, Hex Slime).
- [x] `3.2.26` Tests: one assert per ability kind.

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

## M7 - Presentation (sprites, animation, audio)

**Goal:** the game looks and feels alive; logic stays pure (visuals are event-driven).
**Done when:** cards deal/play with tweens, structures react and crumble, elements read at a
glance, and audio backs every key action. All effects respect a reduce-motion flag (M8.3).

### 7.1 Sprites & art pipeline
- `7.1.1` `src/ui/sprites.lua` loader (`love.graphics.newImage`, nearest filter, cached by key).
- `7.1.2` Card-frame sprites: base, selected, and champion frame (J/Q/K/Ace).
- `7.1.3` Suit/family glyph sprites (Clubs/Spades/Hearts/Diamonds).
- `7.1.4` Element pip icons (Fire/Acid/Physical/Frost/Poison), tinted from `theme`.
- `7.1.5` Structure sprites per material (Wood/Iron/Stone/Ice/Holy) + cracked + destroyed frame.
- `7.1.6` Slime avatar sprite + 4 core tints (Commander/Absorber/Alchemist/Warden).
- `7.1.7` Monster art per type (start with colored silhouettes; swap to art later).
- `7.1.8` Kingdom backdrops (5) for combat + overworld.
- `7.1.9` Vendor `anim8`; build grids for multi-frame sprites (slime idle, flame flicker).

### 7.2 Card animations (flux + timer)
- `7.2.1` `src/ui/anim.lua` - wrap `flux` + a small active-tween registry updated each frame.
- `7.2.2` Deal: tween each card from the deck position to its hand slot, staggered.
- `7.2.3` Hover lift; un-hover settle.
- `7.2.4` Select raise; deselect drop.
- `7.2.5` Assign-to-lane: tween the card to the lane slot under its structure.
- `7.2.6` Exchange: toss discarded cards off-screen; slide replacements in.
- `7.2.7` Reshuffle: sweep the discard pile back into the draw pile.
- `7.2.8` **Drag-and-drop assign**: pick up a card and drop it onto a structure to assign its
  lane (drop target highlights on hover; snap-back if dropped on empty space). Replaces the
  click-select -> click-structure flow from M2.4; reuses the 7.2.5 lane tween. Input/presentation
  only - does not change resolution.

### 7.3 Commit & combat juice
- `7.3.1` Commit sequence: resolve lanes one-by-one with a short `timer` delay.
- `7.3.2` Structure hit: shake (flux on a draw offset) + element-tinted flash.
- `7.3.3` Destroy: crumble/fade + a `love.graphics.newParticleSystem` burst.
- `7.3.4` Floating attack/damage numbers (rise + fade out).
- `7.3.5` HP-bar lerp to the new value; low-HP pulse.
- `7.3.6` Fight-back telegraph: the affected structure/card pulses before each sculpt hit.
- `7.3.7` Per-element cue: Fire burn, Acid sizzle, Frost freeze-tint, Poison drip, Physical impact.
- `7.3.8` Screen shake on Core destruction / big overkill (gated by reduce-motion).
- `7.3.9` Combo glow: the hand highlights when the current selection forms a named combo.

### 7.4 Merge & meta animations
- `7.4.1` Merge fusion: two cards spiral together into the result card.
- `7.4.2` Card-gain flourish (recruit/reward card flies into the deck pile).
- `7.4.3` Slime-core selection flourish + evolution level-up effect.

### 7.5 Transitions & overlays
- `7.5.1` State transition fades/slides (Menu / Overworld / Expedition / Combat / Result).
- `7.5.2` Dialogue overlay slide-in/out over the current state (hump gamestate stack).
- `7.5.3` Scout reveal: structures fade/flip in when a town opens.

### 7.6 Audio
- `7.6.1` `src/core/audio.lua` - source loading/pooling + master/sfx/music volumes.
- `7.6.2` SFX: draw, select, deal, exchange, commit, lane resolve.
- `7.6.3` SFX: structure crack, structure destroy, fight-back, low-HP warning.
- `7.6.4` SFX: victory, defeat, button click, per-voice dialogue blip.
- `7.6.5` Music: menu, combat, victory + per-kingdom tracks (5).
- `7.6.6` Narrator stings for broken-UI glitch / achievement beats.
- `7.6.7` Duck music under dialogue and key sfx.

### 7.7 Text & narrator styling
- `7.7.1` Voice text styles (system / slime / character) pulled from `theme`.
- `7.7.2` Broken-UI glitch text effect (jitter / strikethrough / typos) for narrator beats.
- `7.7.3` Patch-note / achievement toast styling.

---

## M8 - Polish & Release

**Goal:** balanced, accessible, shippable. **Done when:** a full campaign is winnable and
fair, accessible, and packaged for both OSes.

- `8.1` Balance pass: per-kingdom DEF scaling (Frontier x1 -> Crown x3), fight-back stacks, element/ability/economy tuning (data only).
- `8.2` Accessibility: colorblind-safe suit/element **shapes** (not color alone), text scale, input remap.
- `8.3` Reduce-motion toggle that gates the M7.3/7.4 shake + heavy tweens.
- `8.4` Settings screen (volumes, accessibility) persisted via save.
- `8.5` Packaging/release (`make package` / `build.ps1 package`) for Windows + macOS.

---

## Coverage map (every system/story has a home)

- **Combat core**: M1-M2 - resolver, sculpt, lanes, elements, fight-back, HP, UI.
- **Cards/deck**: M1 (deck/draw) + M2.5 (starter) + M4.3 (shop/merge) + M5.4 (meta pool).
- **Monster abilities**: M3 (all families + merged + Imp split).
- **Run loop**: M4 - nodes, cores, shop, merge, companions, rewards, Rest/Training/Alchemy.
- **Campaign/meta/save**: M5.
- **Story** (narrator, acts, companions, defectors, endings, dialogue, Ink): M6.
- **Theme/colors**: M2.6 (early) - palette, fonts, recolored placeholders.
- **Presentation** (sprites, card + combat animation, juice, transitions, audio, narrator styling): M7.
- **Polish/release** (balance, accessibility, reduce-motion, settings, packaging): M8.
