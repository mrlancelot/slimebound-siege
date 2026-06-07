# Slimebound Siege - Game Design Bible

## Working Title

**Slimebound Siege**

Other possible titles:

- Reborn as the Horde Core
- Mythic Siege
- I Woke Up as the Horde
- Slime Overlord: Kingdom Siege
- Monster Raid

The working title should stay flexible until the first playable vertical slice has a clearer tone.

## High Concept

An ordinary person from Earth is hit by Truck-kun and wakes up inside a fantasy strategy game as a weak slime. This is not the heroic side of the game. The player has been reborn on the monster side of a reverse tower defense world, where human towns are already built and defended.

To survive, the slime must gather mythical creatures, raid fortified settlements, absorb power, merge monsters into stronger forms, and push deeper into kingdoms that were designed to destroy creatures like them.

The game is an isometric 2.5D base assault game built in Lua with Love2D.

## Core Fantasy

Start as a weak slime. Become the mind behind a mythical horde.

The player should feel like they are slowly learning the rules of a game world from the inside. At first, they are fragile and confused. Over time, they become a strategist, a commander, and eventually a force that kingdoms plan around.

The fantasy is not just "be evil." The stronger emotional pitch is:

- A person trapped in an unfamiliar world.
- A slime body with strange absorb/evolve powers.
- Monsters who are feared, hunted, and pushed to the edges of civilization.
- Human kingdoms that see all monsters as resources, threats, or test subjects.
- A growing horde that becomes a found family, army, and political force.

## Genre Pillars

### Isometric Base Assault

Each level is a pre-built human settlement with defenses already placed. The player studies the map, chooses monsters, and deploys them from valid outside tiles.

### Monster Merging

Monsters are not only bought and upgraded. They can be merged into stronger or hybrid forms, creating a sense of experimentation.

### Slime Evolution

The main character is a slime commander who can absorb traits, memories, essence, or materials after battle. This creates long-term progression separate from individual monster units.

### Kingdom Conquest

The world map starts with weak edge villages and grows into fortified inner towns, regional capitals, sacred cities, and anti-monster research zones.

## Story Premise

The protagonist is an exhausted person from Earth who dies in a sudden traffic accident. In the last moment, they remember a strategy game they had been playing: a fantasy defense game where human towns survived waves of monsters.

They wake up in darkness with no arms, no legs, and no human voice. Their body is a small slime in the wild borderlands. A translucent game-like interface appears, but the menu is broken, incomplete, and written as if the player is on the enemy side.

The world calls them a "horde core," a rare monster capable of guiding lesser creatures through instinct, mana, and absorbed memories.

The first human village attacks nearby monsters for bounty money. The slime survives by gathering a few weak creatures and raiding the village before it can organize a purge.

That first raid reveals the truth: the slime is inside a world built around siege rules, town defenses, monster counters, unit roles, rewards, and progression. If the slime does not grow, the kingdoms will wipe out every monster nest on the frontier.

## Tone

The tone should mix strategy, dark comedy, and progression fantasy.

Avoid making the player purely cruel. The human kingdoms can be dangerous and oppressive, but individual humans can still be scared, normal, foolish, brave, greedy, or kind. The monster side should have personality and warmth.

The story should leave room for:

- Funny isekai moments.
- Tactical planning.
- Monster companion personalities.
- Strange fantasy politics.
- Serious stakes when kingdoms escalate.

## Main Character

### The Slime

The slime is the player's avatar and strategic identity. It does not need to be a direct combat powerhouse at the start.

Early slime traits:

- Weak body.
- Can absorb residue from defeated enemies and destroyed structures.
- Can sense monster instincts.
- Can spend essence to unlock commands.
- Can merge or mutate allied monsters.
- Can read fragments of the world's game-like rules.

Long-term slime evolution paths:

- **Commander Core**: better deployment, more squad control, more army capacity.
- **Absorber Core**: gains traits from enemies, structures, traps, and bosses.
- **Alchemist Core**: improves merging, hybrid forms, and resource conversion.
- **Warden Core**: builds monster camps, protects allied creatures, unlocks defense between raids.

## World Structure

The world is divided into kingdoms and regions. Each region has a difficulty gradient from border settlements to capital strongholds.

### Frontier Farmlands

Purpose: Tutorial region.

Human defenses:

- Fences.
- Watch posts.
- Militia.
- Wooden arrow towers.
- Basic gates.

Monster unlocks:

- Goblins.
- Slimes.
- Orcs.

### Iron Marches

Purpose: First real resistance.

Human defenses:

- Stone walls.
- Crossbow towers.
- Patrol guards.
- Spike traps.
- Armored gatehouses.

Monster unlocks:

- Ogres.
- Shield goblins.
- Burrowers.

### Sun Dominion

Purpose: Anti-monster magic.

Human defenses:

- Priests.
- Holy shrines.
- Fire towers.
- Burning oil.
- Wards that weaken regeneration.

Monster unlocks:

- Shamans.
- Trolls.
- Hex slimes.

### Frost Holds

Purpose: Movement disruption and terrain.

Human defenses:

- Slow fields.
- Ice walls.
- Long-range ballista towers.
- Frozen choke points.

Monster unlocks:

- Harpies.
- Frost ogres.
- Tunnel beasts.

### Crown Engine Capital

Purpose: Late-game escalation.

Human defenses:

- Cannons.
- Elite knights.
- Mage towers.
- Anti-slime machines.
- Research labs.
- Boss commanders.

Monster unlocks:

- Wyverns.
- Ancient trolls.
- Named champion monsters.

## Core Gameplay Loop

1. Pick a town on the region map.
2. Scout the town layout.
3. Review rewards, defenses, and deployment zones.
4. Choose a monster squad.
5. Deploy monsters from valid outside tiles.
6. Monsters advance using simple behaviors.
7. Town defenses fire, spawn guards, trigger traps, and block paths.
8. Destroy buildings, steal resources, or reach the town core.
9. Earn gold, essence, materials, and monster fragments.
10. Merge, recruit, evolve, and prepare for the next town.

## Battle Flow

### Scout Phase

The player sees the isometric town before committing units.

The scout view should show:

- Town core.
- Defenses.
- Walls.
- Roads.
- Resource buildings.
- Deployment edge.
- Known traps.
- Unknown suspicious tiles.

### Squad Phase

The player selects monsters from their available roster. Early versions can use a fixed squad limit. Later versions can use army capacity or command points.

Example:

```text
6 Goblins
2 Orcs
1 Ogre
1 Slime Familiar
```

### Deployment Phase

The player places monsters on valid edge tiles. Some monsters may require specific deployment rules.

Examples:

- Ground monsters deploy on roads, grass, or dirt.
- Flying monsters deploy from cliff or sky-edge tiles.
- Burrowers deploy from soft ground.
- Slime-linked units must be deployed near the slime's influence.

### Assault Phase

After deployment, monsters act mostly on their own. The player's decisions are in preparation, placement, timing, and later special commands.

Early behavior should be simple:

- Move toward target.
- Attack if in range.
- Re-path if blocked.
- Die at zero HP.

### Result Phase

The battle ends when:

- The town core falls.
- The player destroys enough of the town to retreat with rewards.
- All deployed monsters are defeated.
- A turn/time limit expires.

## Win And Reward Model

The game can support partial success.

Possible star system:

```text
1 star: destroy 50% of town value
2 stars: destroy the town core
3 stars: destroy all key structures
```

Rewards:

- **Gold**: recruit basic monsters and buy camp upgrades.
- **Essence**: slime evolution and rare abilities.
- **Meat**: recruit beasts and sustain large monsters.
- **Scrap**: armor, siege traits, shield units.
- **Mana Shards**: magic monsters, shamans, hybrid upgrades.
- **Relics**: unlock special monster lines or story progression.

For early development, use only gold and essence.

## Monster Roles

### Goblin

Cheap, fast, fragile. Good at raiding resource buildings. Weak against towers.

### Orc

Balanced frontline unit. Attacks nearby enemies and buildings.

### Ogre

Slow tank and wall breaker. Draws tower fire and opens paths.

### Slime Familiar

Small extension of the player. Can absorb residue and support merging.

### Harpy

Flying unit. Ignores walls but is vulnerable to archers and anti-air towers.

### Shaman

Support unit. Buffs nearby monsters and weakens holy defenses.

### Troll

Regenerating bruiser. Strong in long fights but expensive to field.

### Wyvern

Late-game flying siege unit. Powerful but countered by ballistae and mages.

## Merge System

Merging should feel like discovering monster recipes, not only upgrading numbers.

Simple merges:

```text
Goblin + Goblin = Hobgoblin
Orc + Orc = Brute Orc
Ogre + Ogre = Stone Ogre
Slime + Slime = Greater Slime
```

Hybrid merges:

```text
Goblin + Harpy = Winged Goblin
Ogre + Slime = Ooze Giant
Shaman + Slime = Hex Slime
Orc + Ogre = War Brute
Troll + Shaman = Rune Troll
```

Merge design rules:

- Every merge should change behavior, not just stats.
- Early merges should be easy to understand.
- Rare merges should require special materials or story unlocks.
- Failed experiments should not permanently punish the player early on.

## Chess-Like Tactical Ideas

The game can borrow from chess without becoming chess.

Useful tactical patterns:

- Towers threaten tiles in simple readable shapes.
- Some monsters move in fixed or patterned routes.
- Deployment tiles matter as much as stats.
- Certain units counter specific defense patterns.
- The player can read the board before acting.

Example monster movement identities:

- Goblins prefer zigzag routes through weak tiles.
- Ogres move straight toward walls and gates.
- Harpies cross diagonally over blocked terrain.
- Slimes ooze to adjacent residue or damaged structures.
- Shamans follow allied clusters instead of leading.

## Visual Direction

The game should use a 2.5D isometric tile view.

Early visuals:

- Diamond tiles.
- Simple colored unit markers.
- Blocky towers and buildings.
- Clear range overlays.

Later visuals:

- Tiled isometric maps.
- Animated monster sprites.
- Distinct kingdom architecture.
- Readable attack effects.
- UI panels for squad, resources, and battle results.

## Technical Direction

Engine:

- Lua.
- Love2D 11.x.

Planned libraries:

- **hump** for camera, game states, timers, and vectors.
- **anim8** for sprite-sheet animation.
- **Tiled** for map creation.
- **STI** for loading Tiled maps in Love2D.

Development approach:

- Start with Love2D built-ins and simple Lua tables.
- Prove gameplay rules before adding map/editor complexity.
- Keep logic tile-based even when visuals are isometric.
- Add libraries only when the feature needs them.

## Development Roadmap

### Phase 0: Design Foundation

Goal: lock the story, gameplay pillars, first region, first unit set, and technical constraints.

Deliverables:

- This design bible.
- First vertical slice plan.
- First region content list.
- Initial unit/defense stat sheet.

### Phase 1: Core Battle Prototype

Goal: prove one raid.

Features:

- Isometric grid.
- One town core.
- One tower.
- One monster.
- Auto movement.
- HP and damage.
- Win/loss state.

### Phase 2: Tactical Prototype

Goal: make decisions interesting.

Features:

- Deployment tiles.
- Two or three monster types.
- Two defenses.
- Walls.
- Basic target priorities.
- Simple rewards.

### Phase 3: Progression Prototype

Goal: make battles connect.

Features:

- Gold and essence.
- Recruit screen.
- Merge screen.
- Slime evolution menu.
- Three linked towns.

### Phase 4: Vertical Slice

Goal: one polished mini-region.

Features:

- Frontier Farmlands region map.
- Five towns.
- One boss town.
- Tiled maps through STI.
- Basic sprite animation through anim8.
- Save/load.
- Music and sound pass.

### Phase 5: Production Expansion

Goal: build toward the full game over several months.

Features:

- More regions.
- More monster lines.
- More defenses.
- Story events.
- Balance pass.
- UI polish.
- Accessibility pass.
- Packaging and release pipeline.

## First Vertical Slice Target

The first real vertical slice should not try to build the whole game.

Recommended target:

- One region: Frontier Farmlands.
- Three normal villages.
- One fortified trade town.
- One region boss village.
- Four player units: Goblin, Orc, Ogre, Slime Familiar.
- Three defenses: Arrow Tower, Militia Hut, Wooden Wall.
- Two resources: Gold and Essence.
- One merge screen with three recipes.
- One slime evolution choice.

## Open Questions

These should be decided before production expands:

- Is the player slime visible on every battlefield or mostly represented through UI?
- Can monsters permanently die, or do they return after battle?
- Is the story comedic, serious, or evenly mixed?
- Does the player conquer towns permanently or raid and move on?
- Are humans always enemies, or can some factions ally with the slime?
- Should battles be fully real-time, turn-stepped, or pausable real-time?

