# Slimebound Siege - Monster Roster (Card Pool)

The card pool the deck is drawn from. Mechanics live in
[GAME_DESIGN.md](GAME_DESIGN.md); this is the content list.

## How a Card Works

A card is one monster, described by three independent things:

- **Suit = family** - sets the monster's **role and ability style** (not its element).
- **Rank = power** - the base value summed in a combo (2-10; J/Q/K champions; Ace = Slime
  Core). Ranks within a band share a monster type and ability; the rank is the card's
  value.
- **Element = a free tag** - any of Fire / Acid / Physical (damage) or Frost / Poison
  (utility), assigned per card and changeable via Alchemy. **Elements are fully
  decoupled from family**, so any monster can be any element.

**Every monster type has an ability.** Abilities are *mechanical* and **commit-time** -
they resolve when you commit your hand (a **lane** = the cards aimed at one structure).
They do not use draw/scry/"next turn" hooks, because a town is one sculpt-and-commit (see
the One-Commit Siege in [GAME_DESIGN.md](GAME_DESIGN.md)). The element handles damage
matchup and the Frost/Poison effects on its own axis. (★ marks champions.)

## Clubs - Goblins (swarm & card economy)

| Band | Monster | Ability |
|---|---|---|
| 2-3 | Goblin Runt | +1 attack per other Goblin in its lane |
| 4-5 | Goblin Sneak | +5 attack if alone in its lane (lone raider) |
| 6-7 | Goblin Raider | +3 attack if its lane has 2+ Clubs |
| 8-10 | Pack-leader | pairs in your commit gain +1 mult |
| J | Goblin Boss ★ | +1 mult per other Club across all lanes |
| K | Goblin Khan ★ | flush lanes deal double |

## Spades - Brutes (raw power, core-breaking, durability)

| Band | Monster | Ability |
|---|---|---|
| 2-3 | Orcling | +2 attack vs Wall structures |
| 4-6 | Orc Grunt | ignores 2 points of a structure's reinforce/armor |
| 7-8 | Ogre | +50% attack vs Wall/Gate structures |
| 9-10 | Troll | heal 2 slime HP when its lane destroys a structure |
| J | Berserker ★ | +1 mult per 6 total rank in its lane |
| K | War Brute ★ | double attack when its lane targets the Core |

## Hearts - Slimes (flex, copy, sustain, Ace synergy)

| Band | Monster | Ability |
|---|---|---|
| 2-4 | Slime | if exchanged during sculpt, returns to your hand (sticky) |
| 5-6 | Slime Spitter | -2 DEF to its target before the lane resolves |
| 6-8 | Hex Slime | its lane ignores the target's reinforce/armor |
| 9-10 | Greater Slime | counts as a pair by itself in its lane |
| J/Q | Slime Familiar ★ | copies the rank of the highest other card in its lane |
| A | Slime Core ★ | wild - counts as any suit and any rank |

## Diamonds - Casters (reach & control)

| Band | Monster | Ability |
|---|---|---|
| 2-4 | Imp | may be committed to two lanes at once |
| 5-6 | Acolyte | +1 mult per Caster in your commit |
| 6-8 | Shaman | +2 mult to its own lane |
| 8-10 | Dragonkin | overkill attack carries to another structure you choose |
| J | Frost Mage ★ | -5 DEF to its target (deep freeze) |
| K | Wyvern ★ | double attack vs the Core |

## Merged Monsters (examples)

Merges combine two cards into a stronger one (see the Merge System in
[GAME_DESIGN.md](GAME_DESIGN.md)). Merged cards keep an ability and gain a stronger one.

```text
Goblin + Goblin       = Hobgoblin     (counts as two cards for flush/straight)
Ogre + Ogre           = Stone Ogre    (+50% attack vs all structures)
Slime + Slime         = Greater Slime (counts as a pair by itself)
Goblin + Caster       = Hexling       (may split into two lanes, +1 mult)
Brute + Caster(Fire)  = Ember Brute   (+50% vs Walls/Gates; overkill carries)
Slime + Caster        = Hex Slime     (-3 DEF to target and ignores its armor)
```

## Build / Balance Notes

- "Every type has an ability" + "fully free elements" is the deepest option and the most
  to balance. **MVP order**: implement the resolver and a **subset** of abilities first
  (start with the simplest: Goblin Runt, Orc Grunt, Slime, Imp, plus 1-2 champions), then
  layer the rest. Element tags can be implemented before per-card abilities.
- Keep ability text short and readable; prefer effects that read at a glance during a
  fight.
- Abilities that touch the same axis as elements (material/damage) are avoided on purpose;
  families own *mechanics*, elements own *matchup*.
