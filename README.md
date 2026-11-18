# Fights by Ryna

A mod of [Ryna](https://github.com/Ryna-Mods/ryna) for World of Warcraft: Forever. A Fights section in Ryna's window, in the manner of a damage meter: your recent fights, looked at
afterwards.

- **For each fight**: who struck first and who died when, every player's damage done and taken over
  the fight, and whom each enemy was attacking.
- **Built from your own combat log** as the Ryna app reads it (Ryna Core's `Data/fights.lua`, which
  the game reads at login or `/reload`), so it needs the Ryna app.
- It names the players who were in those fights, and stays on this computer.
- `/ryna fights` opens it.

Nothing in chat, nothing done for you.

## Installing

Fights needs **Ryna Core** (the folder `Ryna_Core`). Get both one of these ways:

- **With the Ryna app** ([download](https://github.com/MaddisonM79/ryna_agent/releases/latest)),
  which installs them and keeps them up to date.
- **The bundle**: every Ryna addon in one zip, from
  [Ryna-Mods/ryna](https://github.com/Ryna-Mods/ryna/releases/latest).
- **By hand**: this repository's releases hold `Ryna_Fights-<version>.zip`; unzip it into
  `Interface/AddOns` beside `Ryna_Core`.

## Working on it

`Ryna_Fights/` is the addon. Its tests (`test/`) run it against a fake client and the real core
addon, the oldest one Fights claims to work with ([`core.json`](core.json)), which
`node scripts/core.mjs` fetches into `.core/`.

`test/fixtures/fights.lua` is the Ryna app's own output, written by a test in ryna_agent
(`fights_data`); it is copied here unchanged, never edited.

```bash
scripts/check.sh
```

That is everything CI runs: luacheck, the strings (`tools/strings.mjs`: every string the code uses
is in `Locales/enUS.lua` and in each locale's template) and the tests. It needs Lua (5.1 is what the
game runs), [luacheck](https://github.com/lunarmodules/luacheck) and Node.

The core API level Fights needs is `## X-Ryna-API` in [`Ryna_Fights.toc`](Ryna_Fights/Ryna_Fights.toc);
its version is `## Version` there, and nowhere else. A release is a signed tag `vX.Y.Z` that matches
it; the bundle then names that release in its `bundle.json`
([how](https://github.com/Ryna-Mods/ryna/blob/main/RELEASING.md)).

## Where it came from

Fights was written in [MaddisonM79/ryna_agent](https://github.com/MaddisonM79/ryna_agent)
(`mods/wow/fights`), and its history up to 0.5.0 is there. Bugs and requests go to
[ryna_agent's issues](https://github.com/MaddisonM79/ryna_agent/issues).

## Licence

MIT.
