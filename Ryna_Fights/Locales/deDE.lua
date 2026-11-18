-- German (deDE) strings for Fights by Ryna. Loaded on every client, applied only when the game
-- runs in deDE: GetLocale() is "deDE".
--
-- How to translate:
--   - Each line is L["English"] = nil. Replace nil with your text in double quotes:
--       L["Take part in the census"] = "..."
--     A line left as nil shows the English, so a partial translation is fine.
--   - Keep every %s and %d, in the same order (WoW's string.format can't reorder them).
--   - Keep "||" as it is: it prints one "|" in chat. Inside a command (/ryna debug on||off||toggle,
--     /who, /reload) keep the words in English: they are what the player types.
--   - Plurals: a pair like "%d player" / "%d players" is used for 1 / everything else.
--     For a language with more forms, use the wording that reads best for most numbers.
--   - Keys are the English text and must stay exactly as they are; only change the values.
--   - Test: set the client's language (Battle.net -> Settings -> Game Settings -> Text Language,
--     or SET textLocale "deDE" in WTF/Config.wtf, with that language installed), log in, then
--     /ryna, /ryna status and /ryna help.
-- This file is generated from enUS.lua by cores/wow/addon/tools/strings.mjs --templates, which keeps the
-- translations already here; run it after enUS.lua changes.

local _, ns = ...
if ns.off then return end
if ns.Locale() ~= "deDE" then return end
local L = ns.L

-- Init.lua
-- /ryna's help line for the command.
L["/ryna fights: your recent fights in Ryna's window"] = nil
-- Said when /ryna fights is typed with a core whose window can't draw the section.
L["Fights needs a newer Ryna core: update the Ryna app."] = nil

-- Window.lua: the section's name in the rail, its title, and a fight's title. %s: what the fight was.
L["Fights"] = nil
L["Fights › %s"] = nil
-- A boss's name and its result ("Captain Gull, kill"). %s: the name; %s: the result, lower case.
L["%s, %s"] = nil
-- What a fight was when it wasn't a boss. %s: the zone.
L["%s, trash"] = nil
L["%s, open world"] = nil
-- The zone when the log never named it.
L["somewhere"] = nil
-- A boss fight's result.
L["Kill"] = nil
L["Wipe"] = nil
-- The list's columns.
L["When"] = nil
L["What"] = nil
L["Length"] = nil
L["Result"] = nil
L["Done"] = nil
L["Taken"] = nil
-- The list's tiles. "of %d tries": how many boss fights there were.
L["Bosses killed"] = nil
L["of %d try"] = nil
L["of %d tries"] = nil
L["Your deaths"] = nil
-- A list row's tooltip.
L["Players"] = nil
L["Your damage done"] = nil
L["Your damage taken"] = nil
L["Your healing done"] = nil
L["Deaths"] = nil
-- The header on a fight: its length and how many players; then the buttons.
L["%d player"] = nil
L["%d players"] = nil
L["‹ Earlier"] = nil
L["Later ›"] = nil
L["All fights"] = nil
-- A fight's rows: players past the file's 25 rows, folded; the enemies' heading.
L["%d more player"] = nil
L["%d more players"] = nil
L["Enemies"] = nil
L["Was attacking, in order"] = nil
-- Enemies past the three shown (a click lists them), or past the eight the file keeps.
L["%d more enemy"] = nil
L["%d more enemies"] = nil
L["Click to list them."] = nil
L["Not kept: the file keeps the eight that mattered most."] = nil
-- Whom an enemy was attacking: a name and for how many seconds ("Corin 9s"); more than the file keeps.
L["%s %ds"] = nil
L["%d more"] = nil
L["nobody of the group"] = nil
-- A player's and an enemy's tooltip.
L["%s's pet: its damage done is in its owner's row."] = nil
L["Damage done"] = nil
L["Damage taken"] = nil
L["Healing done"] = nil
L["Died at"] = nil
L["Was attacking, in order:"] = nil
-- From one time to another in the fight ("0:10 to 0:19").
L["%s to %s"] = nil
L["and %d more"] = nil
-- The footer: where the numbers come from and how old the file is. %s: the core's "2 hours ago".
L["From your combat log, as the Ryna app read it, as of %s; newer fights appear after /reload."] = nil
L["From your combat log, as the Ryna app reads it; newer fights appear after /reload."] = nil
L["an unknown time"] = nil
L["The fights file is from another version: update the Ryna app and the addon."] = nil
-- The list with nothing in it.
L["Fights appear here once the Ryna app has read your combat log and the game is reloaded."] = nil
L["None of these fights was logged by this character."] = nil

-- Story.lua: a fight in sentences. Times are "0:08" (minutes and seconds from the fight's start).
-- The first blow: who struck, with what (a spell's name, or "a melee swing"), on whom, when. It says who
-- struck first, never who pulled: the log can't tell.
L["%s opened with %s on %s at %s."] = nil
L["%s opened with %s on %s at %s, and missed."] = nil
L["a melee swing"] = nil
-- A player's pet: "Ember Quill's Wolf". %s: the player; %s: the pet.
L["%s's %s"] = nil
-- An enemy with its number among enemies of the same name ("Dockside Cutter 2").
L["%s %d"] = nil
-- After the first blow when the other side struck within a quarter second (the log's order may not be the game's).
L["The enemy struck back within a quarter second."] = nil
L["The group struck back within a quarter second."] = nil
L["The log shows no blow between the group and an enemy."] = nil
-- The enemy's answer when the group struck first. %s: the enemy; %s: whom; %s: when.
L["%s went for %s at %s."] = nil
-- Deaths in order: "Dela died at 0:26" then ", Aster at 0:29" for each next one, then ", and 3 more".
L["%s died at %s"] = nil
L[", %s at %s"] = nil
L[", and %d more"] = nil
L["Nobody died."] = nil
-- A name the log didn't give.
L["someone"] = nil
