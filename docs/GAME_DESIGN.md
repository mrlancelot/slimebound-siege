# Slimebound Siege - Game Design Bible

## Working Title

**Slimebound Siege**

A roguelike **poker-scoring siege deckbuilder**. You play a reincarnated slime
commanding a monster horde, raiding fortified human towns by playing poker hands as
siege assaults.

The working title should stay flexible until the first playable vertical slice has a
clearer tone.

## High Concept

An ordinary person from Earth is hit by Truck-kun and wakes up inside a fantasy strategy
game as a weak slime. This is not the heroic side of the game. The player has been reborn
on the monster side of a world where human towns are already built and defended.

To survive, the slime gathers mythical creatures into a **deck/horde**, raids fortified
settlements, absorbs power, **merges cards into stronger monsters**, and pushes deeper
into kingdoms that were designed to destroy creatures like them.

Mechanically the game is a roguelike deckbuilder built in Lua with Love2D, inspired by
the structure of poker-scoring roguelikes but built around three original verbs:
**multi-structure sieges**, **merge-to-evolve your deck**, and a **town that fights
back**.

## Core Fantasy

Start as a weak slime. Become the mind behind a mythical horde.

At first the player is fragile and confused, learning the world's "game rules" from the
inside through a broken interface. Over time they become a strategist who reads each
town's defenses, brings the right monsters and elements, and grows a personalized horde
that kingdoms plan around.

The fantasy is not just "be evil." The stronger pitch is:

- A person trapped in an unfamiliar world.
- A slime body with strange absorb/evolve/merge powers.
- Monsters who are feared, hunted, and pushed to the edges of civilization.
- Human kingdoms that see all monsters as resources, threats, or test subjects.
- A growing horde that becomes a found family, army, and political force.

## Locked Design Decisions

These were resolved during design and supersede the earlier "Open Questions."

| Topic | Decision |
|---|---|
| Genre | Roguelike poker-scoring siege deckbuilder (original mechanics) |
| Card base | 52-card *vocabulary* (suit = family, rank = power); J/Q/K = champions, **Ace = Slime Core** |
| Deck model | Lean, growing: start ~12-16 cards, optionally grow via drafts/merges (lean = more consistent draws) |
| Combat | **One-Commit Siege**: scout -> draw 7 -> exchange <=3 over 2 sculpt turns -> commit 7 as lane combos |
| Targets | **Independent structures**: any lane hits any structure; Core = conquer, others = bonus loot |
| Elements | **Separate axis** - every card has a family (suit) AND an independent element |
| Siege math | `attack = (sum of ranks) x combo-mult x type-mult` vs a structure's **DEF** |
| Signature pillars | **Merge-to-evolve deck**, **multi-structure sieges**, **town fights back** |
| Hero | Selectable **Slime evolution "decks"** at run start; levels via story |
| Permadeath | At **expedition scope** - fallen cards/companions are lost for that expedition; the Slime always survives a loss |
| Conquest | Permanent - a persistent **overworld**; each kingdom has several towns, conquered ones stick |
| Map | **Two layers**: persistent overworld + a fresh **expedition** = the assault on **one town** (~8-12 nodes, boss = the keep) |
| Expedition deck | **Fresh each expedition** - built during the run, reset after; only territory + meta-unlocks persist |
| Tone | Evenly mixed (dark comedy -> serious stakes) |
| Humans | Some can ally (events, recruitable neutrals, an allied faction) |
| Battle pacing | Turn-based card play (you choose every assault) |
| Slime presence | Protected commander-hero; never lost to a single bad assault |

## Genre Pillars

### Multi-Structure Sieges

A town is not a single score target. It is a set of independent structures - Outer Wall,
Gatehouse, Arrow Tower, Town Core - each with its own **DEF**, **material/element**, and
sometimes a rule. You allocate your hand into lanes to break what you can; the Core is the
prize, the rest is bonus loot. This is where target-priority tactics live.

### Merge-to-Evolve

Matched cards are not only scored - they can be **fused into permanent, stronger monster
cards** that join your deck. Your small starting deck mutates into a personalized horde
over a run. Merging can permanently consume the fused cards.

### Slime Evolution

The slime commander is chosen as one of several **evolution cores** at run start, each
changing the rules of play. The slime levels through story beats between regions. This is
long-term identity progression separate from individual cards.

### Kingdom Conquest

The run climbs through kingdoms (the "antes"), from weak edge villages to fortified inner
towns, regional capitals, sacred cities, and anti-monster research zones. Clearing a
capital permanently unlocks meta-progression for future runs.

## Story Premise

The protagonist is an exhausted person from Earth who dies in a sudden traffic accident.
In the last moment they remember a strategy game they had been playing: a fantasy defense
game where human towns survived waves of monsters.

They wake in darkness with no arms, no legs, and no human voice - a small slime in the
wild borderlands. A translucent, game-like interface appears, but it is broken,
incomplete, and written as if the player is on the *enemy* side.

The world calls them a "horde core," a rare monster capable of guiding lesser creatures
through instinct, mana, and absorbed memories.

The first human village hunts nearby monsters for bounty. The slime survives by gathering
a few weak creatures and sieging the village before it can organize a purge. That first
raid reveals the truth: this world runs on siege rules, town defenses, monster counters,
unit roles, rewards, and progression. If the slime does not grow, the kingdoms will wipe
out every monster nest on the frontier.

The full narrative is in [STORY.md](STORY.md).

## Tone

The tone mixes strategy, dark comedy, and progression fantasy.

Avoid making the player purely cruel. Human kingdoms can be dangerous and oppressive, but
individual humans can still be scared, normal, foolish, brave, greedy, or kind - and some
can ally with the horde. The monster side should have personality and warmth.

The story leaves room for funny isekai moments, tactical planning, monster companion
personalities, strange fantasy politics, and serious stakes when kingdoms escalate.

## Cards

Cards are monsters described by a **suit** (family), a **rank** (power), and an
**element**. The familiar 52 combinations (4 suits x 13 ranks) are the card *vocabulary* -
they are **not** your deck size. The full monster list (types + abilities) is in
[MONSTERS.md](MONSTERS.md).

### Deck (lean, growing)

You do not start with all 52. Each expedition begins with a small **starting deck**
(~12-16 cards, scaled by your core, territory, and meta-unlocks) and can **grow during the
run** through drafts (Recruit camps) and merges. Because each town draws only a 7-card hand
(plus up to 3 exchanges), a **lean deck draws more reliably** - growing adds power but
costs consistency. The deck resets at the end of the expedition.

Each town is one **sculpt-and-commit**: draw a 7-card hand, exchange up to 3 cards over 2
sculpt turns, then commit your 7 as lane combos against the structures (see
[Siege Economy](#siege-economy-one-commit)).

### Suit = Monster Family

- **Clubs - Goblins**: cheap, numerous, low ranks; reward swarms/flushes.
- **Spades - Brutes** (Orc/Ogre/Troll): high single-card value, tanky.
- **Hearts - Slimes**: support - heal, absorb, copy; synergize with the Ace.
- **Diamonds - Casters** (Imp/Shaman/Wyvern): effects, ranged, can reach back-row
  structures.

### Rank = Power Tier

- **2-10**: grunts, raw rank value.
- **Jack / Queen / King**: named champions that carry abilities.
- **Ace**: the **Slime Core** - your hero wildcard; can substitute into combos.

### Element (Separate Axis)

Every card also has an **element**, independent of its family. A Diamond Caster might be
Fire *or* Frost. Poker mechanics use rank + suit (a flush is five of one family); the
element feeds the **type multiplier** against a structure's material and, for two of the
elements, a **secondary effect**. The starting deck spreads elements across suits; merges
and alchemy can re-type cards. (Exact distribution is a tuning detail.)

Five elements, split into **3 damage + 2 utility**:

- **Fire** (damage): strong vs Wood and Ice.
- **Acid** (damage): strong vs Iron and Stone; fizzles on Holy.
- **Physical** (damage): smashes Holy wards; bounces off hard Stone/Iron.
- **Frost** (utility): **freezes its target - reduces that structure's DEF** before the
  lane resolves (brittle); weak vs Ice.
- **Poison** (utility): **ignores resistance** - its damage is not reduced by the x0.5
  resist case, good for cracking resistant materials.

## Siege Combat

Each town is a set of **independent structures**, all predetermined (authored by us):

```text
[ Outer Wall   DEF 3  | Wood  ]
[ Gatehouse    DEF 6  | Iron  ]
[ Arrow Tower  DEF 9  | Stone ]
[ Town Core    DEF 14 | Holy  ]  <- destroy to conquer the town
```

Combat is a single decisive **commit**: you allocate your hand into **lanes** (one combo
per targeted structure) and resolve all at once. Each lane:

```text
lane attack = (sum of lane ranks) x combo-mult x type-mult   (+/- element effects)

combo-mult:  high 1   pair 2   triple 3   straight 4   flush 5   full house 6 ...
type-mult:   strong 2.0    neutral 1.0    resisted 0.5

lane attack >= structure DEF  ->  that structure is destroyed
```

Rules:

- **Independent targets**: any lane can target any structure. The **Core** is just the
  highest-DEF target; destroying it conquers the town. Other structures are **bonus loot**,
  not a gate - break them for extra gold/essence/cards.
- A single low card can clear a small wall ("1 card = 1 structure"); the Core wants a real
  combo and the right element.
- You usually **can't break everything** with 7 cards - the puzzle is choosing what to
  break and what to skip.

### Siege Economy (One-Commit)

A town is resolved in one sculpt-and-commit cycle. All numbers are tuning starting points.

- **Scout**: the town's structures, DEFs, materials, and fight-back are shown up front
  (they are predetermined), so you can plan your hand against them.
- **Hand size**: **7 cards**, drawn from your deck.
- **Sculpt - 2 turns**: each turn you may exchange cards (toss & redraw), up to **3 total**
  across the two turns. The town's **fight-back fires each sculpt turn** (see below), so
  stalling to sculpt has a cost.
- **Commit**: split your 7 cards into lanes (1+ cards each), one combo per targeted
  structure; resolve every lane simultaneously vs the predetermined DEFs.
- **Outcome**:
  - **Core destroyed** -> the town is **conquered** (permanent on the overworld).
  - Non-core structures destroyed -> **bonus loot**.
  - **Core survives** -> the slime takes expedition-HP damage; the node holds. If this was
    the **keep**, the expedition ends in **retreat** (slime survives; held territory stays).
- **Deck consistency note**: because you only draw ~7 (plus up to 3 exchanges) per town, a
  **lean deck draws more reliably**. Growing the deck (drafts/merges) adds power but costs
  consistency - a real risk/reward choice.

### Element Matchups

Structures have materials. Damage multiplier is **strong x2 / neutral x1 / resist x0.5**;
**Poison** ignores the resist case, **Frost** lowers the target structure's DEF.

| Element \ Material | Wood | Iron | Stone | Ice | Holy |
|---|---|---|---|---|---|
| **Fire** | x2 | x1 | x1 | x2 | x1 |
| **Acid** | x1 | x2 | x2 | x1 | x0.5 |
| **Physical** | x1 | x0.5 | x0.5 | x1 | x2 |
| **Frost** (utility) | x1 | x1 | x1 | x0.5 | x1 |
| **Poison** (utility) | x1 | x1 | x1 | x1 | x0.5* |

\* Poison ignores resistance, so its chip damage still lands on Holy.

This makes the **kingdoms** matter: Frost Holds are full of Ice Walls (bring Fire), the
Sun Dominion has Holy Wards that resist Acid Slimes (bring Brutes / Physical).

### Power Curve

Structure DEF ramps within an expedition (early defenses DEF 3-6 -> keep up to ~16) and
per kingdom (rough multipliers Frontier x1 -> Iron x1.5 -> Sun x2 -> Frost x2.5 -> Crown
x3). The player keeps pace through **merges** (higher rank + new effects), **Alchemy**
(bump rank / add element), **Training** (raise a combo multiplier for the run),
**champion** drafts (J/Q/K), and **companion** passives. A healthy run roughly doubles
output every few nodes to match the DEF curve.

### Town Fights Back

The town's **attack** is predetermined and fires **during your 2 sculpt turns** - the only
window before you commit - so sculpting longer means taking more punishment. Each sculpt
turn the town may:

- Reinforce a structure's DEF (+DEF before your commit).
- **Lock a suit** for the commit ("archers pin your Hearts").
- Wound a card in your hand (reduce its rank).
- Chip the slime's expedition HP.

Boss keeps carry the toughest, stacked rules. This is the home for the anti-monster
defenses (Holy Ward, Arrow Tower, Frost choke).

### Structure HP & Armor

To give the siege more texture than a single pass/fail threshold, each structure has two
defensive numbers:

- **HP** - the damage pool you must deplete to destroy it (the old "DEF" values: Wall ~3,
  Gate ~6, Tower ~9, Core ~14 - tuning).
- **Armor** - a **flat reduction** subtracted from each lane's attack before it bites:

```text
damage    = max(0, lane attack - armor)
destroyed = damage >= remaining HP
```

Material armor defaults (tuning): Wood 1, Iron 2, Stone 3, Ice 1, Holy 2. Armor is what makes
the **ignore-armor** abilities (Orc Grunt, Hex Slime) matter, and the HP pool is what lets
**overkill carry** (Dragonkin) and future multi-hit chaining have something to spill into.

### Structure Keywords

Optional per-structure rules (data on the structure), the home for deterministic difficulty:

- **Shield** - immune to damage until the structure **in front of it** is destroyed (pairs
  with Reach, below).
- **Regen N** - regains N HP at the start of each sculpt turn (stalling lets it heal).
- **Thorns N** - any lane that hits it costs the slime **N expedition HP**.
- **Ward <element>** - takes **x0.5** from the warded element (Poison still ignores resist).

### Reach & Siege Layers

Structures are ordered **front -> back**; the **Town Core is back-most**. A lane may target a
back structure only if **every structure in front of it is destroyed**, *or* the lane contains
a **Caster (Diamonds)** card (casters have **reach**). This restores siege-layer target
priority and gives Diamonds a clear role. (Some abilities may also grant reach.)

### Gamble Tokens (Coin & Die)

Opt-in, **limited consumables** (found in loot, bought in the shop) the player may spend on a
single lane before committing - the **only** randomness in combat:

- **Die** - adds **+1..6** to that lane's attack (additive; never wastes a built combo - best
  for squeaking a marginal lane past armor/HP).
- **Coin** - a **flip** on that lane: **heads x1.5, tails x0.5** (a real gamble both ways).

```text
final lane attack = (attack + dieRoll) x coinMult     -- die first, then coin
```

One token of each type per lane. Rolls use the seeded RNG so a siege stays reproducible/testable;
the resolver itself stays pure (the roll is computed by the siege and passed in as a modifier).

## Merge System

Merging should feel like discovering monster recipes, not only upgrading numbers.

Simple merges:

```text
Goblin + Goblin = Hobgoblin
Orc + Orc       = Brute Orc
Ogre + Ogre     = Stone Ogre
Slime + Slime   = Greater Slime
```

Hybrid merges (across family and/or element):

```text
Goblin + Harpy   = Winged Goblin
Ogre + Slime     = Ooze Giant
Shaman + Slime   = Hex Slime
Orc + Ogre       = War Brute
Troll + Shaman   = Rune Troll
Caster(Fire) + Brute = Ember Brute  (re-typed)
```

Merge design rules:

- Every merge should change behavior, not just stats.
- Early merges are easy to understand.
- Rare merges require special materials or story unlocks.
- Failed experiments should not permanently punish the player early on.
- Merging permanently consumes the fused cards (permadeath-aware).

## Horde (Companion Slots)

Alongside your deck you field an **active Horde** of recruited monsters and **named
companions** that passively buff sieges.

- **Slots**: start with **3**, expandable to **5** via meta-unlocks.
- **Earned at**: Recruit camps (gold), Events (story companions), and rare keep rewards.
- **Effects** (passive, they stack):

```text
Goblin Pack : +1 mult per Club played
Dragon Kin  : your Diamond plays deal Fire
Stone Ogre  : +50 attack when you play a pair
War Shaman  : flush combos gain +1 mult
Quartermaster : +1 exchange during sculpt
```

- **Permadeath (controlled)**: companions are lost only when **you choose** (sacrificed at
  a merge altar for a powerful fusion), in **scripted story beats**, or to **special boss
  rules** - never to ordinary combat. A lost companion frees its slot for the rest of the
  expedition; a story death also removes it from the campaign's unlock pool and rewrites
  later scenes.

## Slime Evolution Cores (Hero)

At run start the player picks a Slime Core, each changing the rules of the run:

- **Commander Core**: extra plays per town / bonus to large combos.
- **Absorber Core**: steal cards from conquered towns.
- **Alchemist Core**: stronger merges and card re-typing.
- **Warden Core**: healing and survivability between fights.

The slime levels via story beats between regions.

## Run Structure

The game has **two map layers**: a persistent overworld and a fresh roguelike expedition.

### Overworld (persistent)

A map of the five kingdoms, mostly linear by difficulty with some branching:

```text
Frontier Farmlands -> Iron Marches -> Sun Dominion -> Frost Holds -> Crown Engine Capital
```

Each kingdom contains **several towns/strongholds**; conquering all of a kingdom's towns
opens the next kingdom. Conquered towns stay yours and become supply/recruit points (your
HQ on conquered land). What **persists** on the overworld: conquered territory, the
slime's evolution core and its level, story progress, banked **essence**, and
**meta-unlocks** (the pool of cards and companions you can draft, starting kits, and
boons).

Between expeditions, at HQ, the player spends persistent resources to unlock draftable
cards/companions and starting boons, evolve the slime, and advance the story, then picks
the next **town** to invade.

### Expedition (a fresh roguelike run)

One expedition = the assault on **one overworld town**. It is a branching **node path** of
**~8-12 nodes** built from a starting deck (a basic kit scaled by your launch territory,
chosen core, and unlocks). The nodes are the town's approach and layered defenses -
patrols, outposts, supply camps, events - culminating in a **boss node: the town's keep**
(the full multi-structure siege). Target length is ~35-50 minutes.

Node types:

- **Defense** (siege combat): an outpost, patrol, or wall line - a small siege
  (a structure or two). The recurring core combat encounter.
- **Keep** (boss siege): the town's core - the full Wall->Gate->Tower->Core fight with the
  toughest fight-back rules. Ends the expedition; winning conquers the town.
- **Recruit camp** (shop): draft cards and horde companions for this expedition.
- **Merge altar**: fuse cards into stronger monsters.
- **Event**: story beats and choices - where humans can ally.
- **Rest**: heal / evolve.
- **Training**: level a poker combo for this expedition.
- **Alchemy**: re-type or transform cards.

The deck is **built during the expedition and reset afterward** - only territory and
meta-unlocks carry over. **Permadeath** is at expedition scope: cards and companions that
fall are gone for that run. **Winning** permanently conquers the territory and grants
meta rewards. **Losing** (or retreating) costs the expedition deck and its gains, but the
Slime always survives and the territory you already held stays conquered - you regroup at
HQ and try again.

## World Structure

Each region has a difficulty gradient and a defensive identity that the element/structure
system expresses.

### Frontier Farmlands

Tutorial region. Defenses: fences, watch posts, militia, wooden arrow towers, basic
gates. Monster families introduced: Goblins, Slimes, Brutes.

### Iron Marches

First real resistance. Defenses: stone walls, crossbow towers, patrol guards, spike
traps, armored gatehouses. Introduces tougher Brutes and shielded units.

### Sun Dominion

Anti-monster magic. Defenses: priests, holy shrines, fire towers, burning oil, wards that
resist Slimes and weaken regeneration. Introduces Casters and Hex Slimes.

### Frost Holds

Movement and tempo disruption. Defenses: slow auras, ice walls, long-range ballista,
frozen choke points. Bring Fire. Introduces Frost-typed monsters.

### Crown Engine Capital

Late-game escalation. Defenses: cannons, elite knights, mage towers, anti-slime machines,
research labs, boss commanders. The seat of the Crown Engine. Introduces Wyverns and named
champions.

## Win and Reward Model

A town is conquered when its **Town Core** is destroyed. Partial sieges can still grant
salvage if you retreat after breaking some structures.

Rewards:

- **Gold**: recruit cards and horde companions at camps.
- **Essence**: slime evolution and rare abilities.
- **Relics**: unlock special monster lines or story progression.

For early development, use only **gold** and **essence**.

## Visual Direction

Early visuals are functional and card-first:

- Cards rendered as colored panels showing rank, suit/family glyph, and an element pip.
- The town drawn as a vertical stack of structure cards with DEF, material, and rules.
- Clear attack math feedback (the `ranks x combo x type` breakdown shown on play).

Later visuals: monster art on cards, animated card play and merges, distinct kingdom
backdrops, readable damage numbers, and polished UI panels for horde, shop, and results.

## Technical Direction

Engine:

- Lua.
- Love2D 11.x.

Planned libraries:

- **hump** for game states, camera, and timers.
- **flux** for card tweens and UI/gameplay effects.
- **lume** for helper functions.
- **SUIT** (or a small custom immediate-mode UI) for menus and the shop.
- **anim8** later, for sprite/card animation.

Deliberately dropped from the earlier isometric plan: Tiled, STI, Jumper, and tiny-ecs
movement - the deckbuilder needs none of them.

Development approach:

- Keep the **combo + siege resolver a pure Lua function** so it can be unit-tested.
- Prove the siege loop with placeholder card art before adding content.
- Add libraries only when a feature needs them.

## Development Roadmap

### Phase 0: Design Foundation

Lock the story, mechanics, first region, first card/element set, and constraints.
Deliverables: this bible, [STORY.md](STORY.md), [ARCHITECTURE.md](ARCHITECTURE.md),
[TICKETS.md](TICKETS.md).

### Phase 1: Siege Proof

One structure, one hand, the pure resolver computing `ranks x combo x type` vs DEF,
win/lose, restart.

### Phase 2: The Siege

A 3-4 independent-structure town with lane allocation, one "town fights back" rule, and a
basic element matchup table.

### Phase 3: The Run

A short ante (small -> big -> boss town), a recruit shop, a merge altar, and Slime Core
selection.

### Phase 4: Vertical Slice

The full Frontier Farmlands region: several towns, one boss capital, the recruit/merge/
event/rest node map, save/load, basic sound.

### Phase 5: Production Expansion

More regions, more card/element/horde content, story events and dialogue, balance pass,
UI polish, accessibility, packaging.

## First Vertical Slice Target

The first real vertical slice should not try to build the whole game.

Recommended target:

- One region: Frontier Farmlands, **one town** to conquer.
- A short expedition (~5-6 nodes for the MVP; the full ~8-12 comes later) ending in the
  town's keep.
- One Slime Core to start with (Commander).
- A small starting deck (~16 cards) across the four families, with a small element set
  (Fire / Acid / Physical / Poison) and a basic matchup table; it grows via drafts/merges.
- Multi-structure towns (Wall / Gate / Tower / Core).
- One "town fights back" rule per town tier.
- Merge altar with three recipes.
- Recruit camp with a few cards and one horde companion.
- Two resources: Gold and Essence.
- Win/loss + result screen + restart.
