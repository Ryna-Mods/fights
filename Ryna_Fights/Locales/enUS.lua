-- English (enUS): every string Fights by Ryna shows, keyed by the English text itself. `true` means "the
-- text is the key"; ns.L returns the key for anything no locale file translates, so English is always
-- the fallback. The other Locales/*.lua files are templates for translators, generated from this one:
-- after adding, changing or removing a string here, run (from the repository root)
--
--   node cores/wow/addon/tools/strings.mjs --templates
--
-- which rewrites them with the same keys, keeping every translation already in them. Without
-- --templates it only checks that this list matches what the code uses (L["..."] and N("...")).
-- Debug lines (ns.Debug) are English on purpose and are not listed. A key the core addon's
-- Locales/enUS.lua already has isn't repeated here: Fights' L falls back to it. Never the word
-- "threat": the enemy rows say whom an enemy was attacking.

local _, ns = ...
if ns.off then return end
local L = ns.L

-- Init.lua
-- /ryna's help line for the command.
L["/ryna fights: your recent fights in Ryna's window"] = true
-- Said when /ryna fights is typed with a core whose window can't draw the section.
L["Fights needs a newer Ryna core: update the Ryna app."] = true

-- Window.lua: the section's name in the rail, its title, and a fight's title. %s: what the fight was.
L["Fights"] = true
L["Fights › %s"] = true
-- A boss's name and its result ("Captain Gull, kill"). %s: the name; %s: the result, lower case.
L["%s, %s"] = true
-- What a fight was when it wasn't a boss. %s: the zone.
L["%s, trash"] = true
L["%s, open world"] = true
-- The zone when the log never named it.
L["somewhere"] = true
-- A boss fight's result.
L["Kill"] = true
L["Wipe"] = true
-- The list's columns.
L["When"] = true
L["What"] = true
L["Length"] = true
L["Result"] = true
L["Done"] = true
L["Taken"] = true
-- The list's tiles. "of %d tries": how many boss fights there were.
L["Bosses killed"] = true
L["of %d try"] = true
L["of %d tries"] = true
L["Your deaths"] = true
-- A list row's tooltip.
L["Players"] = true
L["Your damage done"] = true
L["Your damage taken"] = true
L["Your healing done"] = true
L["Deaths"] = true
-- The header on a fight: its length and how many players; then the buttons.
L["%d player"] = true
L["%d players"] = true
L["‹ Earlier"] = true
L["Later ›"] = true
L["All fights"] = true
-- A fight's rows: players past the file's 25 rows, folded; the enemies' heading.
L["%d more player"] = true
L["%d more players"] = true
L["Enemies"] = true
L["Was attacking, in order"] = true
-- Enemies past the three shown (a click lists them), or past the eight the file keeps.
L["%d more enemy"] = true
L["%d more enemies"] = true
L["Click to list them."] = true
L["Not kept: the file keeps the eight that mattered most."] = true
-- Whom an enemy was attacking: a name and for how many seconds ("Corin 9s"); more than the file keeps.
L["%s %ds"] = true
L["%d more"] = true
L["nobody of the group"] = true
-- A player's and an enemy's tooltip.
L["%s's pet: its damage done is in its owner's row."] = true
L["Damage done"] = true
L["Damage taken"] = true
L["Healing done"] = true
L["Died at"] = true
L["Was attacking, in order:"] = true
-- From one time to another in the fight ("0:10 to 0:19").
L["%s to %s"] = true
L["and %d more"] = true
-- The footer: where the numbers come from and how old the file is. %s: the core's "2 hours ago".
L["From your combat log, as the Ryna app read it, as of %s; newer fights appear after /reload."] = true
L["From your combat log, as the Ryna app reads it; newer fights appear after /reload."] = true
L["an unknown time"] = true
L["The fights file is from another version: update the Ryna app and the addon."] = true
-- The list with nothing in it.
L["Fights appear here once the Ryna app has read your combat log and the game is reloaded."] = true
L["None of these fights was logged by this character."] = true

-- Story.lua: a fight in sentences. Times are "0:08" (minutes and seconds from the fight's start).
-- The first blow: who struck, with what (a spell's name, or "a melee swing"), on whom, when. It says who
-- struck first, never who pulled: the log can't tell.
L["%s opened with %s on %s at %s."] = true
L["%s opened with %s on %s at %s, and missed."] = true
L["a melee swing"] = true
-- A player's pet: "Ember Quill's Wolf". %s: the player; %s: the pet.
L["%s's %s"] = true
-- An enemy with its number among enemies of the same name ("Dockside Cutter 2").
L["%s %d"] = true
-- After the first blow when the other side struck within a quarter second (the log's order may not be the game's).
L["The enemy struck back within a quarter second."] = true
L["The group struck back within a quarter second."] = true
L["The log shows no blow between the group and an enemy."] = true
-- The enemy's answer when the group struck first. %s: the enemy; %s: whom; %s: when.
L["%s went for %s at %s."] = true
-- Deaths in order: "Dela died at 0:26" then ", Aster at 0:29" for each next one, then ", and 3 more".
L["%s died at %s"] = true
L[", %s at %s"] = true
L[", and %d more"] = true
L["Nobody died."] = true
-- A name the log didn't give.
L["someone"] = true
