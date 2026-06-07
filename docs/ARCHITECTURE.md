# Slimebound Siege Architecture

## Goal

Build the first playable version as a tiny Clash of Clans-style monster raid:

- One isometric village.
- Player deploys monsters from map edges.
- Monsters automatically choose targets by priority.
- Village defenses attack back.
- The raid ends in victory or defeat.

The first implementation should prove the full game loop with placeholder art and very small commits.

## MVP Definition

The first MVP is **one village**, not the whole game.

It should include:

- One handmade isometric Tiled map.
- One deployment edge.
- Three monster types.
- One wall line.
- One resource hut.
- One tower.
- One guard.
- One village core.
- Win/loss result screen.

It should not include:

- Merge system.
- World map.
- Save/load.
- Multiple villages.
- Final art.
- Full story dialogue.
- Complex economy.

Those come after the raid loop works.

## Technical Stack

### Required

- **Love2D**: game loop, drawing, input, audio, window.
- **Lua**: game logic.
- **Tiled**: village map editor.
- **STI**: load and draw Tiled maps in Love2D.
- **hump**: game states, camera, timers.
- **tiny-ecs**: entities and systems.
- **Jumper**: tile pathfinding.
- **SUIT**: MVP/debug UI.
- **baton**: input mapping.
- **lume**: helper functions.
- **flux**: small tweens and UI/gameplay effects.
- **anim8**: later sprite animation.

### Planned Later

- **Ink/Tinta**: story and branching dialogue.
- Audio helper library if Love2D audio management becomes repetitive.
- Packaging helpers for release builds.

## Folder Layout

Target structure:

```text
assets/
  maps/
  sprites/
  audio/
docs/
  GAME_DESIGN.md
  ARCHITECTURE.md
  TICKETS.md
lib/
  hump/
  sti/
  jumper/
  tiny-ecs.lua
  suit.lua
  baton.lua
  lume.lua
  flux.lua
  anim8.lua
src/
  core/
  data/
  states/
  systems/
  ui/
```

## Runtime Flow

```text
main.lua
  -> src/game.lua
    -> BootState
      -> BattleState
        -> ResultState
```

### BootState

Responsible for:

- Loading libraries.
- Loading basic config.
- Entering `BattleState`.

### BattleState

Responsible for:

- Loading village map.
- Creating ECS world.
- Spawning buildings and defenders.
- Handling player deployment.
- Updating systems.
- Drawing map, entities, and UI.
- Detecting win/loss.

### ResultState

Responsible for:

- Showing victory/defeat.
- Showing simple summary.
- Restarting the battle.

## Entity Model

Use `tiny-ecs` for raid gameplay.

Entities:

- Monster.
- Building.
- Wall.
- Tower.
- Guard.
- Projectile/effect.

Common components:

```text
Position      tileX, tileY, worldX, worldY
Health        hp, maxHp
Team          monster or village
Renderable    shape/sprite/color
Targeting     priorities
Path          nodes, currentNode
Movement      speed
Attack        damage, range, cooldown, timer, kind
Building      buildingType
Blocker       blocksPath
```

Do not overbuild components before they are needed. Add components only when a ticket needs them.

## Map Model

The first village map should be handmade in Tiled.

Required layers:

- `ground`: visual tiles.
- `buildings`: visual map structures.
- `collision`: blocked tiles.
- `deployment`: tiles where monsters can be deployed.
- `objects`: named objects for tower, guard, core, resource hut.

Required object names:

```text
core
tower_01
guard_01
resource_hut_01
```

Required custom properties:

```text
type
hp
team
```

## Monster Types

### Goblin

Purpose: resource raider.

Target priority:

1. Resource hut.
2. Village core.
3. Nearest building.

Combat:

- Melee.
- Low HP.
- Fast movement.

### Ogre

Purpose: wall breaker and tank.

Target priority:

1. Wall blocking path.
2. Village core.
3. Tower.

Combat:

- Melee.
- High HP.
- Slow movement.
- Bonus damage to walls.

### Imp

Purpose: ranged attacker.

Target priority:

1. Guard.
2. Tower.
3. Village core.

Combat:

- Ranged.
- Medium speed.
- Low HP.

## Village Defenders

### Tower

Behavior:

- Does not move.
- Targets nearest monster in range.
- Deals ranged damage on cooldown.

### Guard

Behavior:

- Starts at object position.
- Targets nearest monster.
- Paths toward monster.
- Attacks in melee range.

## Targeting Rules

Each monster chooses targets by priority list.

Algorithm:

1. Read monster priority list.
2. Find alive entities matching first priority.
3. If any exist, choose nearest reachable target.
4. If none exist, try next priority.
5. If no target exists, idle.

Distance is tile distance for target choice.

Reachability uses Jumper pathfinding.

## Pathfinding Rules

Use a grid based on map tiles.

Blocked tiles:

- Walls.
- Buildings.
- Collision layer tiles.

Melee units path to an adjacent open tile next to the target.

Ranged units path until the target is within attack range.

If a target dies:

- Clear current target.
- Clear path.
- Re-target next update.

If a path becomes blocked:

- Request a new path.

## Combat Rules

Attack timing:

- Each attacker has a cooldown.
- Timer decreases during update.
- If target is in range and timer <= 0, deal damage.
- Reset timer to cooldown.

Damage:

- Subtract HP from target.
- If HP <= 0, mark entity dead.
- Cleanup system removes dead entities.

Win condition:

- Village core HP reaches 0.

Loss condition:

- No deployed monsters alive.
- No squad units remaining to deploy.

## UI Rules

MVP UI uses SUIT.

Required battle UI:

- Selected monster type.
- Remaining Goblins.
- Remaining Ogres.
- Remaining Imps.
- Core HP.
- Restart button.
- Debug overlay toggle.

Controls:

```text
1: select Goblin
2: select Ogre
3: select Imp
Left click: deploy selected monster on valid deployment tile
Right click or Escape: cancel / quit depending state
R: restart battle
Tab: toggle debug overlays
```

## Development Rules

Every implementation ticket should be tiny.

Target:

- No ticket should require more than 10 lines of code.
- If it needs more, split the ticket.
- Prefer many small commits over one big feature commit.

Allowed ticket result examples:

- Add one empty file.
- Add one require.
- Add one component.
- Add one system stub.
- Add one field to unit data.
- Add one draw call.
- Add one acceptance test.

Avoid:

- "Implement combat."
- "Add pathfinding."
- "Build the UI."

Those are too large and must be split.

## Acceptance Criteria For First Playable

The first playable village is done when:

- The map loads.
- Buildings and defenders spawn from map data.
- Player can select and deploy all three monster types.
- Monsters choose targets by priority.
- Monsters path around blocked tiles.
- Monsters attack targets.
- Tower attacks monsters.
- Guard chases and attacks monsters.
- Destroying the core triggers victory.
- Losing all monsters triggers defeat.
- Restart works.
- `make check` passes.

