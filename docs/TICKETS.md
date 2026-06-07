# Slimebound Siege Micro-Ticket Backlog

## Ticket Rules

Each ticket should be small enough to implement in about 10 lines of code or less.

If a ticket feels larger than that, split it before coding.

Ticket IDs use:

```text
major.minor.micro
```

Example:

```text
1.4.3
```

## 1.1 Documentation Foundation

- `1.1.1` Create `docs/ARCHITECTURE.md`.
- `1.1.2` Create `docs/TICKETS.md`.
- `1.1.3` Link architecture doc from README.
- `1.1.4` Link ticket doc from README.
- `1.1.5` Add "one village MVP" section to `GAME_DESIGN.md`.
- `1.1.6` Add "10-line ticket rule" to `GAME_DESIGN.md`.
- `1.1.7` Add "COC-style targeting" note to `GAME_DESIGN.md`.
- `1.1.8` Add first playable acceptance list to README.

## 1.2 Library Planning

- `1.2.1` Add `lib/README.md`.
- `1.2.2` List `hump` source URL.
- `1.2.3` List `STI` source URL.
- `1.2.4` List `Jumper` source URL.
- `1.2.5` List `tiny-ecs` source URL.
- `1.2.6` List `SUIT` source URL.
- `1.2.7` List `baton` source URL.
- `1.2.8` List `lume` source URL.
- `1.2.9` List `flux` source URL.
- `1.2.10` List `anim8` source URL.
- `1.2.11` Add vendoring rule: copy source into `lib/`.
- `1.2.12` Add fallback rule for libraries that fail to integrate.

## 1.3 Folder Structure

- `1.3.1` Create `assets/maps/`.
- `1.3.2` Create `assets/sprites/`.
- `1.3.3` Create `assets/audio/`.
- `1.3.4` Create `src/core/`.
- `1.3.5` Create `src/data/`.
- `1.3.6` Create `src/states/`.
- `1.3.7` Create `src/systems/`.
- `1.3.8` Create `src/ui/`.
- `1.3.9` Add `.gitkeep` to empty asset folders.
- `1.3.10` Add `.gitkeep` to empty source folders.

## 1.4 Vendor Libraries

- `1.4.1` Vendor `hump/gamestate.lua`.
- `1.4.2` Vendor `hump/camera.lua`.
- `1.4.3` Vendor `hump/timer.lua`.
- `1.4.4` Vendor `STI`.
- `1.4.5` Vendor `Jumper`.
- `1.4.6` Vendor `tiny-ecs`.
- `1.4.7` Vendor `SUIT`.
- `1.4.8` Vendor `baton`.
- `1.4.9` Vendor `lume`.
- `1.4.10` Vendor `flux`.
- `1.4.11` Vendor `anim8`.
- `1.4.12` Add one Lua require smoke file for `hump`.
- `1.4.13` Add one Lua require smoke file for `STI`.
- `1.4.14` Add one Lua require smoke file for `Jumper`.
- `1.4.15` Add one Lua require smoke file for `tiny-ecs`.
- `1.4.16` Add one Lua require smoke file for `SUIT`.
- `1.4.17` Add one Lua require smoke file for `baton`.
- `1.4.18` Add one Lua require smoke file for `lume`.
- `1.4.19` Add one Lua require smoke file for `flux`.
- `1.4.20` Add one Lua require smoke file for `anim8`.

## 1.5 Game State Setup

- `1.5.1` Create empty `BootState`.
- `1.5.2` Create empty `BattleState`.
- `1.5.3` Create empty `ResultState`.
- `1.5.4` Require hump gamestate in `game.lua`.
- `1.5.5` Switch from placeholder scene to `BootState`.
- `1.5.6` Make `BootState` enter `BattleState`.
- `1.5.7` Add `enter` method to `BattleState`.
- `1.5.8` Add `update` method to `BattleState`.
- `1.5.9` Add `draw` method to `BattleState`.
- `1.5.10` Add restart transition to `ResultState`.

## 1.6 Input Setup

- `1.6.1` Create `src/core/input.lua`.
- `1.6.2` Require baton in input module.
- `1.6.3` Map key `1` to `select_goblin`.
- `1.6.4` Map key `2` to `select_ogre`.
- `1.6.5` Map key `3` to `select_imp`.
- `1.6.6` Map left click to `deploy`.
- `1.6.7` Map right click to `cancel`.
- `1.6.8` Map `r` to `restart`.
- `1.6.9` Map `tab` to `debug`.
- `1.6.10` Expose input update function.

## 1.7 Map Creation

- `1.7.1` Create `assets/maps/village_01.tmx` in Tiled.
- `1.7.2` Add `ground` layer.
- `1.7.3` Add `buildings` layer.
- `1.7.4` Add `collision` layer.
- `1.7.5` Add `deployment` layer.
- `1.7.6` Add `objects` layer.
- `1.7.7` Add object `core`.
- `1.7.8` Add object `tower_01`.
- `1.7.9` Add object `guard_01`.
- `1.7.10` Add object `resource_hut_01`.
- `1.7.11` Add wall tiles to collision layer.
- `1.7.12` Add edge tiles to deployment layer.

## 1.8 Map Loading

- `1.8.1` Create `src/core/map_loader.lua`.
- `1.8.2` Require STI in map loader.
- `1.8.3` Load `village_01.tmx`.
- `1.8.4` Return map object from loader.
- `1.8.5` Draw map in BattleState.
- `1.8.6` Read collision layer.
- `1.8.7` Store blocked tile list.
- `1.8.8` Read deployment layer.
- `1.8.9` Store deployment tile list.
- `1.8.10` Read object layer.
- `1.8.11` Store named map objects.

## 1.9 Entity World

- `1.9.1` Create `src/core/world.lua`.
- `1.9.2` Require tiny-ecs.
- `1.9.3` Create ECS world factory.
- `1.9.4` Add system registration function.
- `1.9.5` Add entity add helper.
- `1.9.6` Add entity remove helper.
- `1.9.7` Store ECS world in BattleState.

## 1.10 Components

- `1.10.1` Add `Position` component table.
- `1.10.2` Add `Health` component table.
- `1.10.3` Add `Team` component table.
- `1.10.4` Add `Renderable` component table.
- `1.10.5` Add `Targeting` component table.
- `1.10.6` Add `Path` component table.
- `1.10.7` Add `Movement` component table.
- `1.10.8` Add `Attack` component table.
- `1.10.9` Add `Building` component table.
- `1.10.10` Add `Blocker` component table.

## 1.11 Unit Data

- `1.11.1` Create `src/data/units.lua`.
- `1.11.2` Add Goblin name.
- `1.11.3` Add Goblin HP.
- `1.11.4` Add Goblin speed.
- `1.11.5` Add Goblin melee damage.
- `1.11.6` Add Goblin target priority.
- `1.11.7` Add Ogre name.
- `1.11.8` Add Ogre HP.
- `1.11.9` Add Ogre speed.
- `1.11.10` Add Ogre melee damage.
- `1.11.11` Add Ogre target priority.
- `1.11.12` Add Imp name.
- `1.11.13` Add Imp HP.
- `1.11.14` Add Imp speed.
- `1.11.15` Add Imp ranged damage.
- `1.11.16` Add Imp target priority.

## 1.12 Building Data

- `1.12.1` Create `src/data/buildings.lua`.
- `1.12.2` Add core data.
- `1.12.3` Add tower data.
- `1.12.4` Add resource hut data.
- `1.12.5` Add wall data.
- `1.12.6` Add guard data.
- `1.12.7` Add building HP values.
- `1.12.8` Add tower range.
- `1.12.9` Add tower damage.
- `1.12.10` Add guard damage.

## 1.13 Entity Factories

- `1.13.1` Create monster factory file.
- `1.13.2` Add Goblin factory.
- `1.13.3` Add Ogre factory.
- `1.13.4` Add Imp factory.
- `1.13.5` Create building factory file.
- `1.13.6` Add core factory.
- `1.13.7` Add tower factory.
- `1.13.8` Add resource hut factory.
- `1.13.9` Add wall factory.
- `1.13.10` Add guard factory.

## 1.14 Village Spawning

- `1.14.1` Spawn core from map object.
- `1.14.2` Spawn tower from map object.
- `1.14.3` Spawn guard from map object.
- `1.14.4` Spawn resource hut from map object.
- `1.14.5` Spawn walls from collision/building data.
- `1.14.6` Add spawned entities to ECS world.
- `1.14.7` Log missing required objects.

## 1.15 Deployment

- `1.15.1` Add selected unit state.
- `1.15.2` Add starting Goblin count.
- `1.15.3` Add starting Ogre count.
- `1.15.4` Add starting Imp count.
- `1.15.5` Select Goblin on key `1`.
- `1.15.6` Select Ogre on key `2`.
- `1.15.7` Select Imp on key `3`.
- `1.15.8` Convert mouse position to tile.
- `1.15.9` Check tile is deployment tile.
- `1.15.10` Spawn selected monster on valid click.
- `1.15.11` Decrease selected monster count.
- `1.15.12` Reject spawn if count is zero.

## 1.16 Pathfinding

- `1.16.1` Create path grid from map size.
- `1.16.2` Mark collision tiles blocked.
- `1.16.3` Mark wall entities blocked.
- `1.16.4` Require Jumper.
- `1.16.5` Create pathfinder.
- `1.16.6` Add helper for nearest adjacent tile.
- `1.16.7` Add helper for path request.
- `1.16.8` Store path nodes on entity.
- `1.16.9` Clear path when target dies.
- `1.16.10` Rebuild grid after wall destruction.

## 1.17 Targeting System

- `1.17.1` Create `TargetSystem`.
- `1.17.2` Filter monster entities.
- `1.17.3` Skip monsters with dead targets.
- `1.17.4` Read target priority list.
- `1.17.5` Find alive entities by priority type.
- `1.17.6` Pick nearest reachable target.
- `1.17.7` Store target on monster.
- `1.17.8` Clear target if none found.

## 1.18 Movement System

- `1.18.1` Create `MoveSystem`.
- `1.18.2` Filter entities with path and movement.
- `1.18.3` Read current path node.
- `1.18.4` Move toward node.
- `1.18.5` Advance node when reached.
- `1.18.6` Stop when path ends.
- `1.18.7` Update tile position after node change.

## 1.19 Attack System

- `1.19.1` Create `AttackSystem`.
- `1.19.2` Filter entities with attack and target.
- `1.19.3` Decrease cooldown timer.
- `1.19.4` Check target range.
- `1.19.5` Deal damage when timer ends.
- `1.19.6` Reset cooldown timer.
- `1.19.7` Add ranged placeholder effect.

## 1.20 Defense System

- `1.20.1` Create `DefenseSystem`.
- `1.20.2` Make tower find nearest monster.
- `1.20.3` Make tower attack in range.
- `1.20.4` Make guard find nearest monster.
- `1.20.5` Make guard path to monster.
- `1.20.6` Make guard melee in range.
- `1.20.7` Clear defender target when monster dies.

## 1.21 Health System

- `1.21.1` Create `HealthSystem`.
- `1.21.2` Find entities with HP <= 0.
- `1.21.3` Mark dead entities.
- `1.21.4` Remove dead non-core entities.
- `1.21.5` Keep core entity for win detection.
- `1.21.6` Trigger grid rebuild after wall death.

## 1.22 Win/Loss System

- `1.22.1` Create `WinLossSystem`.
- `1.22.2` Detect core HP <= 0.
- `1.22.3` Enter ResultState on victory.
- `1.22.4` Count alive monster entities.
- `1.22.5` Count remaining squad units.
- `1.22.6` Enter ResultState on defeat.
- `1.22.7` Store result reason.

## 1.23 Rendering

- `1.23.1` Create `RenderSystem`.
- `1.23.2` Sort entities by screen Y.
- `1.23.3` Draw monster placeholders.
- `1.23.4` Draw building placeholders.
- `1.23.5` Draw defender placeholders.
- `1.23.6` Draw projectile placeholders.
- `1.23.7` Draw health bars.
- `1.23.8` Draw selected tile highlight.

## 1.24 Battle UI

- `1.24.1` Create battle UI module.
- `1.24.2` Require SUIT.
- `1.24.3` Draw selected monster label.
- `1.24.4` Draw Goblin count.
- `1.24.5` Draw Ogre count.
- `1.24.6` Draw Imp count.
- `1.24.7` Draw core HP.
- `1.24.8` Draw restart button.
- `1.24.9` Draw debug toggle.
- `1.24.10` Wire restart button.

## 1.25 Debug Overlays

- `1.25.1` Add debug flag.
- `1.25.2` Toggle debug with Tab.
- `1.25.3` Draw collision tiles.
- `1.25.4` Draw deployment tiles.
- `1.25.5` Draw monster paths.
- `1.25.6` Draw target lines.
- `1.25.7` Draw tower range.

## 1.26 Result Screen

- `1.26.1` Store result type.
- `1.26.2` Store result reason.
- `1.26.3` Draw victory title.
- `1.26.4` Draw defeat title.
- `1.26.5` Draw result reason.
- `1.26.6` Add restart button.
- `1.26.7` Restart into BattleState.

## 1.27 Camera

- `1.27.1` Require hump camera.
- `1.27.2` Create battle camera.
- `1.27.3` Attach camera before map draw.
- `1.27.4` Detach camera before UI draw.
- `1.27.5` Add arrow key pan.
- `1.27.6` Add camera reset key.
- `1.27.7` Clamp camera to map bounds.

## 1.28 Feedback

- `1.28.1` Require flux.
- `1.28.2` Add floating damage number entity.
- `1.28.3` Tween damage number upward.
- `1.28.4` Fade damage number out.
- `1.28.5` Add tower attack flash.
- `1.28.6` Add core damage flash.
- `1.28.7` Add deployment click feedback.

## 1.29 Dialogue Planning

- `1.29.1` Create `docs/DIALOGUE.md`.
- `1.29.2` Describe Ink/Tinta target.
- `1.29.3` Write intro scene outline.
- `1.29.4` Write slime first-wakeup beat.
- `1.29.5` Write first-village setup beat.
- `1.29.6` Write post-victory beat.
- `1.29.7` Define fallback Lua dialogue format.

## 1.30 First Playable Acceptance

- `1.30.1` Run `make check`.
- `1.30.2` Launch `love .`.
- `1.30.3` Confirm map renders.
- `1.30.4` Confirm all three unit hotkeys work.
- `1.30.5` Confirm valid deployment works.
- `1.30.6` Confirm invalid deployment is rejected.
- `1.30.7` Confirm Goblin targets resource hut.
- `1.30.8` Confirm Ogre targets wall/core.
- `1.30.9` Confirm Imp targets guard/tower.
- `1.30.10` Confirm tower attacks monsters.
- `1.30.11` Confirm guard chases monsters.
- `1.30.12` Confirm core destruction wins.
- `1.30.13` Confirm all monsters dying loses.
- `1.30.14` Confirm restart works.

## Future Epics After 1.x

- `2.x` Rewards and resource economy.
- `3.x` Merge screen.
- `4.x` Slime evolution.
- `5.x` Region map.
- `6.x` Story/dialogue integration.
- `7.x` Sprite animation.
- `8.x` Audio and polish.
- `9.x` Save/load.
- `10.x` Packaging and release.

