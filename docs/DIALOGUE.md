# Slimebound Siege Dialogue Plan

Narrative context lives in [STORY.md](STORY.md). This document covers how dialogue is
written, formatted, and loaded, plus outlines of the first beats.

## Voice Reminder

Most dialogue is delivered through the **broken, enemy-side game UI** - the slime's wry
modern inner voice reacting to medieval monster warfare. Keep it dark-comedy early,
serious later. Humans are people, not cardboard villains.

## Tooling Target

- **Primary**: [Ink](https://www.inklestudios.com/ink/) authored scripts, loaded in
  Love2D via **Tinta** (a Lua Ink runtime). Ink gives branching, variables, and a clean
  authoring format for the Event-node choices and ally branches.
- **Decision point**: adopt Ink/Tinta when Event nodes need real branching. Until then,
  use the Lua fallback format below so early beats are not blocked on integration.

## Fallback Lua Dialogue Format

A beat is a plain Lua table - no engine dependency, trivial to render and test.

```lua
return {
  id = "wakeup_01",
  speaker = "ui",          -- "ui" | "slime" | a character id
  lines = {
    "[SYSTEM] Welcome, hostile entity.",
    "[SYSTEM] ...that's not right. Let me check the manual.",
    "[SYSTEM] There is no manual.",
  },
  choices = {              -- optional; omit for linear beats
    { text = "Try to stand up.",    goto = "wakeup_02" },
    { text = "Scream internally.",  goto = "wakeup_02", flag = "panicked" },
  },
}
```

Rules:

- `speaker = "ui"` renders as interface text; `"slime"` as inner monologue; a character
  id uses that character's nameplate.
- `goto` names another beat id; omit on the last beat.
- `flag` sets a run flag used later for branching/endings.
- Beats live in `src/data/dialogue/` as one file per scene.

## Beat Outlines (Act I)

### Intro - The Commute That Ends

- Cold open on Earth: tired, ordinary, late. A blur of headlights.
- No gameplay; 4-6 lines establishing the human the slime used to be.

### Wakeup - "Hostile Entity"

- Darkness, no body. The broken UI boots with the wrong audience in mind.
- Comedy of the system narrating the player as the enemy; the "no manual" gag.
- Ends with the slime realizing it can sense nearby creatures (the first horde).

### First Siege - The Bounty Village

- The UI frames the village as a quest objective from the defenders' side.
- Teaches the siege loop in fiction: structures, DEF, "bring the right monster."
- A militia conscript's barked orders humanize the enemy even as you break the gate.

### First Defector - After the Gate Falls

- Post-victory beat. The conscript, terrified, expects to be eaten - and isn't.
- First **ally** flag set; the seed of "human and enemy are not the same word."

### Post-Victory - The Rules Reveal

- The UI awards loot like a defense game and fires a glitched achievement
  (*"First Blood (you weren't supposed to unlock this)"*).
- The slime understands the world runs on rules - and that growing is the only way to
  survive the coming purge.

## Later Acts (stubs to expand)

- **Act II**: Knight-Commander first contact; Inquisitor's "soulless" doctrine vs the
  slime's memories; a companion's possible death beat (permadeath-aware variants).
- **Act III**: the UI starts addressing the *player*, not the slime; Frost Warden
  attrition; the Crown Engine and the Architect; the three ending branches.

## Production Notes

- Write linear beats in the Lua fallback first; convert to Ink only where branching pays
  off.
- Permadeath: scenes referencing a companion need an "alive" and a "fallen" variant keyed
  off run flags.
- Keep most exposition in UI text - cheap to produce, on-theme, and easy to localize
  later.
