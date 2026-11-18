-- The Fights section (Data.lua, Story.lua, Window.lua) against the fake client the window tests use
-- (test/fake_client.lua), with the real core addon and the app's own output as the
-- file (test/fixtures/fights.lua, written by fights_data's test in cores/wow/core: every name in it is
-- made up). From the repository root, with Lua 5.1 (what the game runs) or later:
--
--   lua5.1 test/fights_test.lua
--
-- It proves: the list's rows, tiles and footer from the file; a fight's sentences for each first-blow
-- case (the group's spell, a swing, a pet's, a miss, too close to call, the enemy's, none) and its
-- deaths; the header's buttons going earlier and later; the strips' values, colours and skulls; the
-- "was attacking" text; the enemies past three folded and opened; an absent file, one of another
-- version, an empty list and malformed rows; nothing in chat, no errors, never the word "threat".
-- luacheck: ignore 1

local CORE = (os.getenv("RYNA_CORE") or ".core/Ryna_Core") .. "/"
local ADDON = "Ryna_Fights/"
local F = dofile("test/fake_client.lua")
local plain = F.Plain

local failures, checks = 0, 0
local function check(cond, what)
  checks = checks + 1
  if not cond then
    failures = failures + 1
    print("FAIL: " .. what)
  end
end
local function eq(got, want, what)
  check(got == want, what .. ": got " .. tostring(got) .. ", want " .. tostring(want))
end
local function near(got, want, what)
  check(type(got) == "number" and math.abs(got - want) < 1e-9,
    what .. ": got " .. tostring(got) .. ", want " .. tostring(want))
end

F.Install({ now = 1800003600 })
_G.UnitGUID = function(unit) if unit == "player" then return "Player-1-0000000D" end end
_G.UnitName = function(unit) if unit == "player" then return "Dela" end end
_G.C_AddOns = { GetAddOnMetadata = function() return "0.0.0" end }
_G.RAID_CLASS_COLORS.SHAMAN = { r = 0, g = 0.44, b = 0.87, colorStr = "ff0070dd" }
_G.RAID_CLASS_COLORS.PRIEST = { colorStr = "ffffffff" }
_G.RED_FONT_COLOR = { r = 1, g = 0.125, b = 0.125 }
_G.RynaDB = { schema = 1, settings = {}, journal = {}, characters = {
  -- A character of this account the file names without a class: coloured from the saved file.
  ["Player-1-0000000C"] = { fullName = "Corin-Ashby", class = "PALADIN" },
} }

local core, mod = {}, {}
F.LoadAddon(CORE, "Ryna_Core", core)
F.LoadAddon(ADDON, "Ryna_Fights", mod)
dofile("test/fixtures/fights.lua")
F.Fire("ADDON_LOADED", "Ryna_Core")
F.Fire("PLAYER_LOGIN")
F.DropTimers()

local R = _G.Ryna
local D, S, W = mod.Data, mod.Story, mod.Window
local Wn = core.Window

-- The story, case by case ------------------------------------------------------------------------------

local function story(first, deaths)
  return D.Fight({ at = 1, length = 30000, steps = 30, step = 1000, first = first, deaths = deaths or {} })
end
eq(S.First(story({ by = "group", who = "Aster Vale", on = "Harbor Brute", with = "Flame Lash", t = 8000 })),
  "Aster Vale opened with Flame Lash on Harbor Brute at 0:08.", "the group opens with a spell")
eq(S.First(story({ by = "group", who = "Corin Ashby", on = "Harbor Brute", onNth = 2, t = 61000 })),
  "Corin Ashby opened with a melee swing on Harbor Brute 2 at 1:01.", "a swing, on the second of two")
eq(S.First(story({ by = "group", who = "Ember Quill", pet = "Wolf", on = "Quay Rat", with = "Bite", t = 0 })),
  "Ember Quill's Wolf opened with Bite on Quay Rat at 0:00.", "a player's pet")
eq(S.First(story({ by = "group", who = "Bryn Holloway", on = "Quay Rat", with = "Shadow Dart", t = 2000,
  miss = true })),
  "Bryn Holloway opened with Shadow Dart on Quay Rat at 0:02, and missed.", "a miss")
eq(S.First(story({ by = "group", who = "Bryn Holloway", on = "Quay Rat", t = 2000, close = true })),
  "Bryn Holloway opened with a melee swing on Quay Rat at 0:02. The enemy struck back within a quarter second.",
  "too close to call")
local enemyFirst = story({ by = "enemy", who = "Dockside Cutter", whoNth = 1, on = "Corin Ashby", t = 0, miss = true,
  close = true, answer = { by = "enemy", who = "x", on = "y", t = 1 } })
eq(S.First(enemyFirst), "Dockside Cutter 1 opened with a melee swing on Corin Ashby at 0:00, and missed. "
  .. "The group struck back within a quarter second.", "the enemy strikes first: it says who struck, not who pulled")
eq(S.Answer(enemyFirst), nil, "an enemy's first blow has no answer")
eq(S.First(story(nil)), "The log shows no blow between the group and an enemy.", "no blow at all")
eq(S.First(story({ by = "nobody" })), "The log shows no blow between the group and an enemy.", "a blow of no side")
eq(S.Answer(story({ by = "group", who = "A", on = "B", t = 1,
  answer = { by = "enemy", who = "Dockside Cutter", whoNth = 2, on = "Dela Marsh", t = 10000 } })),
  "Dockside Cutter 2 went for Dela Marsh at 0:10.", "the enemy's answer")
eq(S.Deaths(story(nil, {})), "Nobody died.", "no deaths")
eq(S.Deaths(story(nil, { { "Dela Marsh", 26000, 0 } })), "Dela died at 0:26.", "one death, by first name")
local seven = {}
for i = 1, 7 do seven[i] = { "Raider" .. i .. " Long", i * 1000, 0 } end
eq(S.Deaths(story(nil, seven)),
  "Raider1 died at 0:01, Raider2 at 0:02, Raider3 at 0:03, Raider4 at 0:04, Raider5 at 0:05, and 2 more.",
  "five named, the rest counted")
eq(S.Clock(754000), "12:34", "minutes and seconds")

-- The list ---------------------------------------------------------------------------------------------

eq(D.why, nil, "the file is read")
eq(#D.list, 2, "two fights")
check(R.Window.Open("fights"), "the window opens on Fights")
local f = Wn.frame
eq(f.title:GetText(), "Fights", "the list's title")
eq(f.headCells[1]:GetText(), "When", "the list's columns")
local function row(r) return f.rows[r] end
local function cell(r, c) return plain(row(r).cols[c]:GetText()) end
eq(cell(1, 1), "50 minutes ago", "newest first, when in the window's age wording")
eq(cell(1, 2), "Captain Gull", "a boss by its name")
eq(cell(1, 3), "0:04", "its length")
eq(cell(1, 4), "Kill", "its result")
eq(cell(1, 5), "0", "your damage done")
eq(cell(2, 2), "Saltmire Docks, trash", "trash by its zone")
eq(cell(2, 4), "", "no result but a boss's")
eq(cell(2, 5) .. " " .. cell(2, 6), "0 600", "your done and taken")
check(not row(3):IsShown(), "two rows")
eq(f.tiles[1].value:GetText(), "2", "tile: fights")
eq(f.tiles[2].value:GetText() .. " " .. f.tiles[2].sub:GetText(), "1 of 1 try", "tile: bosses killed of tries")
eq(f.tiles[3].value:GetText(), "1", "tile: your deaths")
eq(f.footer:GetText(),
  "From your combat log, as the Ryna app read it, as of 45 minutes ago; newer fights appear after /reload.",
  "the footer: the log, as of the file's writtenAt")
check(f.picker:IsShown() and f.search:IsShown(), "the list keeps the picker and the search box")
-- The picker narrows to a character's own fights; the search to a name.
Wn.Choose("Player-1-0000000C")
eq(f.empty:GetText(), "None of these fights was logged by this character.", "another character logged none")
Wn.Choose(nil)
Wn.Search("gull")
eq(#Wn.views.fights.sorted, 1, "the search finds the boss")
Wn.Search("")
-- A row's tooltip.
row(2)._scripts.OnEnter(row(2))
local tip = table.concat(_G.GameTooltip:Texts(), "\n")
check(tip:find("Saltmire Docks, trash", 1, true) and tip:find("Aster Vale opened with", 1, true),
  "a row's tooltip: " .. tip)
row(2)._scripts.OnLeave(row(2))

-- A fight ----------------------------------------------------------------------------------------------

F.Click(row(2))
eq(f.title:GetText(), "Fights › Saltmire Docks, trash", "the fight's title")
eq(f.say[1]:GetText(), "Aster Vale opened with Flame Lash on Harbor Brute at 0:08.", "the first blow")
eq(f.say[2]:GetText(), "Dockside Cutter went for Dela Marsh at 0:10.", "the enemy's answer")
eq(f.say[3]:GetText(), "Dela died at 0:26, Aster at 0:29, Corin at 0:32.", "the deaths in order")
check(f.say[3]._color[1] < 1, "the deaths line is dimmer")
check(not f.picker:IsShown() and not f.search:IsShown(), "the buttons take the picker's and the search box's place")
eq(f.navTexts[1]:GetText(), "0:36 · 5 players", "its length and players")
local buttons = {}
for _, b in ipairs(f.navButtons) do if b:IsShown() then buttons[b:GetText()] = b end end
check(buttons["‹ Earlier"] and not buttons["‹ Earlier"]:IsEnabled(), "the oldest fight: no earlier one")
check(buttons["Later ›"] and buttons["Later ›"]:IsEnabled(), "a later one")
check(buttons["All fights"] ~= nil, "and the way back")
eq(f.tiles[1]:IsShown(), false, "no tiles on a fight")

-- Rows: the axis, then the players, the enemies' heading and the enemies.
local axis = row(1)
check(axis.data.axis, "the first row is the clock")
eq(axis.strips[4].labels[1]:GetText(), "0:00", "the clock starts at 0:00")
eq(axis.strips[4].labels[10]:GetText(), "0:09", "a quarter in")
local aster = row(2)
eq(cell(2, 1) .. "|" .. cell(2, 2) .. "|" .. cell(2, 3), "Aster Vale|120|660", "the first blow's player first")
eq(aster.cols[1]:GetText():sub(1, 10), "|cff0070dd", "in the class colour the app gave")
local st = aster.strips[4]
near(st.top[9]._height, math.sqrt(23 / 100) * 7, "done above: the square root of the share, half the strip")
near(st.below[29]._height, 7, "taken below: the biggest step, a full half")
eq(st.top[9]._colorTexture[1] .. "," .. st.top[9]._colorTexture[3], "0,0.87", "done in the class colour")
eq(st.below[29]._colorTexture[2], 0.125, "taken in the game's red")
check(st.marks[1]:IsShown(), "a skull where Aster died")
near(st.marks[1]._points[1][4], (30 - 0.5) * (288 - 8) / 36, "at 0:29, block 30")
check(not st.marks[2] or not st.marks[2]:IsShown(), "one death, one skull")
eq(cell(4, 1), "  Wolf", "the wolf under its owner")
eq(cell(4, 3), "55", "holding what it took, both of its GUIDs")
eq(row(6).cols[1]:GetText():sub(1, 10), Wn.ClassColor("PALADIN"), "a class from this account's saved file")
local bryn = row(5)
eq(bryn.cols[1]:GetText():sub(1, 2), "Br", "no class known: the window's own colour")
eq(bryn.strips[4].top[12]._colorTexture[1], 0.26, "and the window's own blue for done")
check(row(8).data.header, "the enemies' heading")
eq(cell(8, 4), "Was attacking, in order", "its last column")
eq(cell(9, 1), "Harbor Brute", "the enemy that mattered most first")
eq(cell(9, 4), "Aster 4s › Ember 3s › Corin 7s › Ember 2s", "whom it was attacking, in order, with seconds")
eq(cell(10, 4), "Dela 2s › Wolf 2s › Dela 9s › Aster 4s › Wolf", "a wolf and a moment under a second")
check(not row(11):IsShown(), "two enemies, nothing folded")
row(9)._scripts.OnEnter(row(9))
tip = plain(table.concat(_G.GameTooltip:Texts(), "\n"))
check(tip:find("Was attacking, in order:", 1, true), "the enemy's tooltip lists whom it attacked: " .. tip)
row(9)._scripts.OnLeave(row(9))

-- Earlier and later.
F.Click(buttons["Later ›"])
eq(f.title:GetText(), "Fights › Captain Gull, kill", "later: the boss")
eq(f.say[1]:GetText(), "Dockside Cutter opened with a melee swing on Corin Ashby at 0:00, and missed.",
  "an enemy that struck first")
eq(f.say[2]:GetText(), "Nobody died.", "no answer line when the enemy opened; nobody died")
for _, b in ipairs(f.navButtons) do if b:IsShown() then buttons[b:GetText()] = b end end
check(not buttons["Later ›"]:IsEnabled() and buttons["‹ Earlier"]:IsEnabled(), "the newest: earlier only")
F.Click(buttons["All fights"])
eq(f.title:GetText(), "Fights", "back to the list")
check(f.picker:IsShown(), "with its picker")

-- Many enemies: three shown, the rest folded, a click opens them -----------------------------------------

local function enemy(i)
  return { name = "Deep Ward " .. i, done = 10 * i, taken = 100 - i, targets = { { 1, 0, 1500 } }, more = 0 }
end
_G.RynaData_fights = { version = 1, writtenAt = 1800003000, flavor = "wowf", items = {
  { at = 1800003000, length = 10000, kind = "world", zone = "Saltmire Docks", step = 1000, steps = 10,
    by = "Player-1-0000000D",
    players = { { name = "Dela Marsh", class = "PRIEST", done = 5, taken = 5, heal = 0, doneSteps = { 100 },
      takenSteps = {} } },
    enemies = { enemy(1), enemy(2), enemy(3), enemy(4), enemy(5) },
    otherEnemies = { n = 2, done = 7, taken = 8 }, otherPlayers = { n = 3, done = 1, taken = 2, heal = 0 } },
  "not a fight", { at = "no" }, { at = 1, length = -5 },
} }
D.Load()
eq(#D.list, 1, "malformed fights skipped")
W.Show(1)
eq(f.title:GetText(), "Fights › Saltmire Docks, open world", "an open-world fight")
eq(f.say[1]:GetText(), "The log shows no blow between the group and an enemy.", "no first blow in the file")
eq(cell(3, 1), "3 more players", "players past the file's rows")
eq(cell(8, 1) .. "|" .. cell(8, 2) .. "|" .. cell(8, 3), "4 more enemies|97|199", "two hidden plus two not kept")
F.Click(row(8))
eq(cell(9, 1), "Deep Ward 5", "a click lists them all")
eq(cell(10, 1), "2 more enemies", "and says what the file didn't keep")
F.Click(row(10))
eq(cell(9, 1), "Deep Ward 5", "that row opens nothing more")

-- Absent, another version, an empty list -----------------------------------------------------------------

_G.RynaData_fights = nil
D.Load()
W.Show(nil)
eq(D.why, "absent", "no file: absent")
eq(f.empty:GetText(), "Fights appear here once the Ryna app has read your combat log and the game is reloaded.",
  "the empty line says what to do, in game")
eq(f.footer:GetText(), "From your combat log, as the Ryna app reads it; newer fights appear after /reload.",
  "and the footer")
check(not f.tiles[1]:IsShown(), "no tiles for nothing")
_G.RynaData_fights = { version = 2, writtenAt = 1, items = { { at = 1, length = 1 } } }
D.Load()
W.Show(nil)
eq(D.why, "version", "another version")
eq(#D.list, 0, "read as absent")
eq(f.empty:GetText(), "The fights file is from another version: update the Ryna app and the addon.", "and why")
eq(f.footer:GetText(), "The fights file is from another version: update the Ryna app and the addon.", "the footer too")
_G.RynaData_fights = { version = 1, writtenAt = 1800000000, items = {} }
D.Load()
W.Show(nil)
eq(D.why, nil, "an empty file is a file")
eq(f.empty:GetText(), "Fights appear here once the Ryna app has read your combat log and the game is reloaded.",
  "an empty list")
eq(f.footer:GetText(),
  "From your combat log, as the Ryna app read it, as of 1 hour ago; newer fights appear after /reload.",
  "with its age")
_G.RynaData_fights = { version = 1, items = { { at = 1, length = 1000, steps = 1, players = { "x", { name = 5 } },
  enemies = { { name = "Ghost", targets = { "x", { 99, 0, 1 }, { "Someone Else", 0, 1000 } } } },
  deaths = { { "A", "no" }, { "B", 10, 99 } } } } }
D.Load()
W.Show(1)
eq(#D.list[1].players, 1, "a row that isn't a table skipped")
eq(cell(2, 1), "someone", "a name that isn't a string: someone")
eq(#D.list[1].deaths, 1, "a death without a time skipped")
eq(D.list[1].deaths[1].row, 0, "a death's row past the rows: none")
eq(#D.list[1].enemies[1].targets, 1, "targets: odd ones skipped, a name kept")
check(f.footer:GetText():find("as the Ryna app reads it", 1, true), "no writtenAt: no age claimed")

-- Old core: nothing registers --------------------------------------------------------------------------

local saved = R.Window.MAX_SAY
R.Window.MAX_SAY = nil
check(not W.Available(), "a core without the fight pieces can't draw Fights")
R.Window.MAX_SAY = saved

-- Never "threat", never a website, nothing in chat, no errors.
for _, fr in ipairs(F.frames) do
  local t = type(fr._text) == "string" and fr._text:lower() or ""
  check(not t:find("threat", 1, true), "never the word threat: " .. t)
  check(not t:find("ryna.io", 1, true), "never a website: " .. t)
end
check(#F.chat == 0, "nothing in chat: " .. table.concat(F.chat, " / "))
check(core.errors.count == 0, "no errors caught: " .. tostring(core.errors.last))
print(string.format("fights: %d checks, %d failed", checks, failures))
os.exit(failures == 0 and 0 or 1)
