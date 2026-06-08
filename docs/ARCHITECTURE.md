# Slimebound Siege Architecture

## Goal

Build the first playable version as a tiny roguelike **siege deckbuilder**:

- A growing deck of monster cards (drawn from a 52-card vocabulary; suit = family, rank,
  plus an element axis). The deck starts small and grows via drafts/merges (Marching Deck).
- A town made of stacked structures, each with DEF and a material/element.
- The player plays poker combos as siege assaults; `attack = ranks x combo x type`.
- Lanes break independent structures; destroying the Town Core conquers the town.
- The town fights back between assaults.
- The siege ends in victory (core destroyed) or defeat (out of hands).

The first implementation should prove the full siege loop with placeholder card art and
very small commits.

## MVP Definition

The first MVP is **one siege**, not the whole game.

It should include:

- A starting deck (~16 cards from the 52-card vocabulary: suit + rank + element), rendered
  as placeholder cards.
- The One-Commit loop: draw 7 -> 2 sculpt turns (exchange <=3) -> commit lanes.
- One town of 3-4 **independent** structures (Wall / Gate / Tower / Core).
- A **pure-Lua lane + siege resolver**.
- One element matchup table (incl. Frost DEF-reduction, Poison ignore-resist).
- One "town fights back" (sculpt-phase) rule.
- Win (Core destroyed) / shortfall result screen + restart.

It should not include:

- The full element roster.
- The whole 5-kingdom run map.
- Named-companion story arcs.
- Final art.
- Save/load polish.
- Training/Alchemy nodes.

Those come after the siege loop works.

## Technical Stack

### Required

- **Love2D**: game loop, drawing, input, audio, window.
- **Lua**: game logic.
- **hump**: game states (`gamestate`), camera, timers.
- **flux**: card tweens and small UI/gameplay effects.
- **lume**: helper functions (tables, math, serialization helpers).
- **SUIT**: menus, shop, and debug UI (or a small custom immediate-mode UI).

### Planned Later

- **anim8**: card/sprite animation once there is art.
- **Ink/Tinta**: branching dialogue (see [DIALOGUE.md](DIALOGUE.md)).
- Audio and packaging helpers as needed.

### Deliberately Dropped

The earlier isometric plan required **Tiled, STI, Jumper, and tiny-ecs movement**. A
deckbuilder needs none of these - there is no map, no pathfinding, and no real-time
entity simulation. They are removed from the dependency plan.

## Folder Layout

Target structure:

```text
assets/
  cards/        placeholder card art later
  audio/
docs/
  GAME_DESIGN.md
  STORY.md
  ARCHITECTURE.md
  TICKETS.md
  DIALOGUE.md
lib/
  hump/
  flux.lua
  lume.lua
  suit.lua
src/
  core/         deck, run, save, rng
  data/         cards, elements, structures, towns, jokers, events
  combat/       the pure resolver + siege state
  states/       menu, run/map, combat, shop, event, result
  ui/           card rendering, town column, hud
tests/
  resolver_spec.lua
```

## Runtime Flow

```text
main.lua
  -> src/game.lua
    -> MenuState           (title, pick Slime Core, new/continue campaign)
      -> OverworldState    (persistent map of kingdoms; pick a target)
        -> ExpeditionState (a fresh roguelike node run)
          -> CombatState   (a siege)
          -> ShopState     (recruit camp)
          -> EventState    (story + choices)
          -> ResultState   (expedition victory/defeat summary)
        (win -> conquer that town on the overworld; lose -> retreat, keep prior territory)
```

### MenuState

- Title screen, Slime Core selection, start or continue a campaign.

### OverworldState (persistent / the campaign save)

- Owns what persists: conquered territory, slime core + level, banked essence, story
  flags, and meta-unlocks (draftable card/companion pool, starting kits, boons).
- The player picks the next kingdom/town to invade, which launches an expedition.
- This is the layer that is serialized to the save file.

### ExpeditionState (a fresh roguelike run)

- Owns the per-expedition state: the starting deck (scaled by launch territory + core +
  unlocks), the branching node map, gold, the horde, and run flags.
- Routes the player into Combat / Shop / Event / Merge / Rest nodes and back.
- The deck is built during the expedition and **discarded when it ends** (win, lose, or
  retreat). On win, it reports the conquered territory + meta rewards back to the
  overworld; on loss the slime retreats and only meta/territory persist.

### CombatState (One-Commit Siege)

- Loads a town (a list of independent structure definitions) and shows it (scout).
- Draws a **7-card hand** from the expedition deck.
- Runs **2 sculpt turns**: the player exchanges up to 3 cards total; the town's predetermined
  fight-back fires each sculpt turn (reinforce DEF / lock a suit / wound a card / chip slime HP).
- Handles **lane allocation**: the player splits the 7 cards into lanes, one combo per
  targeted structure (any lane -> any structure).
- On **commit**, calls the resolver per lane and applies all results at once.
- Detects victory (Core destroyed -> town conquered) / shortfall (Core survives -> slime
  takes HP damage; on a keep, retreat). Non-core structures destroyed award bonus loot.

### ResultState

- Shows victory/defeat and a summary; returns to the run (or ends it on a fatal defeat).

## Data Model

Plain Lua tables - no ECS needed.

### Card

```text
Card        suit, rank, element, id
            (suit -> family; rank -> value; element -> matchup tag)
            merged cards add: name, effects, sourceCards
```

### Structure

```text
Structure   name, hp, armor, material, element, keywords, destroyed
            hp        damage pool to deplete (was "def")
            armor     flat reduction: damage = max(0, attack - armor)
            keywords  { shield, regen=N, thorns=N, ward="Fire" } (see M2.7)
            (front -> back order in the town gives Reach/siege layers)
```

### Town

```text
Town        name, region, structures (front -> back), fightBackRule, rewards
```

### Horde companion (Joker)

```text
Companion   name, family/element bias, passive effect, alive, storyId
```

### Campaign state (persistent - serialized to the save file)

```text
Campaign    core, coreLevel, territory[], essence, unlocks[], storyFlags[]
```

### Expedition state (transient - lives only for one run, not saved long-term)

```text
Expedition  deck, horde, gold, region, node, seed, runFlags, tokens
            tokens    { coin = N, die = N } gamble consumables (see M2.7)
```

Add fields only when a ticket needs them.

## Combat Resolver (the core, pure)

The resolver is a **pure function** - no Love2D calls, no globals - so it can be unit
tested with plain `lua`/`luajit`.

A **lane** is the set of cards aimed at one structure. The resolver scores one lane; the
commit step scores every lane at once.

```text
evaluateCombo(cards)      -> { kind = "flush", mult = 5, rankSum = 27 }
typeMultiplier(element, structureMaterial) -> 2.0 | 1.0 | 0.5
resolveLane(cards, structure)
    combo  = evaluateCombo(cards)
    elem   = dominantElement(cards)
    type   = typeMultiplier(elem, structure.material)
    def    = structure.def - frostReduction(cards)        -- Frost lowers DEF
    attack = combo.rankSum * combo.mult * type
    if hasPoison(cards) then attack = ignoreResist(attack, type, cards) end
    return { attack = attack, destroyed = attack >= def, combo, type, element = elem }

resolveCommit(lanes, town)            -- lanes: { [structureId] = cards }
    -> per-lane results; town conquered if the Core lane destroyed it
```

Combo tiers (initial): high card (1), pair (2), three of a kind (3), straight (4),
flush (5), full house (6), four of a kind (7), straight flush (8).

`dominantElement(cards)` picks the element used for the matchup (e.g. the majority
element of the lane; ties resolved by a documented rule).

Elements are **3 damage + 2 utility** (all pure in the resolver):

- **Fire / Acid / Physical**: damage only, via `typeMultiplier`.
- **Frost**: `frostReduction` lowers the target structure's effective DEF before compare.
- **Poison**: `ignoreResist` - the lane's damage is not reduced by the x0.5 resist case.

Per-monster **abilities** (see MONSTERS.md) are applied as lane modifiers around this core
(extra attack, mult, DEF reduction, multi-lane, etc.).

**Combat-depth additions (M2.7), all kept pure:** the lane uses `damage = max(0, attack -
armor)` and `destroyed = damage >= hp` (HP/armor replace the bare DEF threshold); structure
**keywords** (Shield/Regen/Thorns/Ward) and **Reach** layering are read from the structure/town.
**Gamble tokens** stay out of the resolver: the **die (+1..6)** and **coin (x1.5 / x0.5)** are
rolled by `siege.lua` via `rng.lua` and passed into `resolveLane` as per-lane `bonusAdd` /
`bonusMult` modifiers, so the resolver remains deterministic and unit-testable.

## Targeting Rules

- Structures are **independent targets**, but ordered **front -> back** for **Reach** (M2.7):
  a back structure can be targeted only if the structures in front are destroyed, or the lane
  has a **Caster (Diamonds)** for reach.
- The **Core** is the back-most, highest-HP target; destroying it conquers the town.
- Non-core structures are optional: destroying them grants bonus loot, not access.
- A monster may only occupy one lane, except abilities that explicitly allow more (Imp).

## Town-Fights-Back Rules

The town acts during the player's **2 sculpt turns** (its only window before the commit).
MVP supports one rule per town; later towns combine several:

- Reinforce a structure's DEF.
- Lock a suit for the commit.
- Wound a card in hand (reduce its rank).
- Chip the slime's expedition HP.

Boss keeps carry the strongest, stacked rules.

## Combat End Rules

Victory:

- Town Core destroyed by its lane on commit -> town conquered.

Shortfall / defeat:

- Core survives the commit -> the slime takes expedition-HP damage; the node holds.
- (Expedition-level) the slime's expedition HP reaches zero, or the **keep** is not taken
  -> the slime **retreats**: the expedition ends, its deck/gains are lost, but the campaign
  and held territory persist.

## UI Rules

MVP UI uses SUIT (or a small custom immediate-mode UI).

Required combat UI:

- The 7-card hand with selection state.
- The town drawn as structure cards (DEF, material, rule), each a droppable lane target.
- The live attack breakdown for the pending lane (`rankSum x combo x type`, +/- effects).
- Sculpt turns left and exchanges remaining (of 3).
- Assign-to-lane / exchange / commit buttons.
- Restart and a debug overlay toggle.

Controls (initial):

```text
Left click   : select/deselect a card; click a structure to assign the lane
E            : exchange selected cards (during sculpt; costs from the 3-card budget)
Enter        : end sculpt turn / COMMIT all lanes
R            : restart siege
Tab          : toggle debug overlay
Esc          : back / quit depending on state
```

## Development Rules

Every implementation ticket should be tiny.

Target:

- No ticket should require more than about 10 lines of code.
- If it needs more, split the ticket.
- Prefer many small commits over one big feature commit.

Allowed ticket result examples:

- Add one empty file.
- Add one require.
- Add one data field.
- Add one resolver branch.
- Add one draw call.
- Add one acceptance test.

Avoid: "Implement combat.", "Add the resolver.", "Build the UI." - too large; split them.

## Acceptance Criteria For First Playable

The first playable siege is done when:

- A starting deck builds and a 7-card hand draws.
- The town renders as independent structure cards from data.
- The player can sculpt: exchange up to 3 cards over 2 sculpt turns.
- The player can assign cards into lanes (any lane -> any structure) and commit.
- The resolver computes `rankSum x combo x type` (+ Frost/Poison) and shows the breakdown.
- A lane destroys its structure when `attack >= DEF`.
- The town fights back during sculpt with at least one rule.
- Destroying the Core triggers victory; non-core structures award bonus loot.
- A surviving Core triggers shortfall/retreat.
- Restart works.
- The resolver has passing unit tests.
- `make check` / `./build.ps1 check` passes.
