-- Window: the Fights section of Ryna's window (the core's Ryna.Window), under Combat and gold, in two
-- views (docs/ryna-agent-cores-mods.md 7.5, "The fight timeline", and the mockup agreed 2026-11-15):
--
--   The list    the fights in the app's file, newest first: when (its age), what (the boss's name, else
--               the zone and "trash" or "open world"), its length, a boss's result, and your own damage
--               done and taken; tiles for the fights, the bosses killed and your deaths. The character
--               picker narrows it to the fights one of your characters logged; the search box to a name.
--               A click on a row opens that fight.
--   A fight     its story in sentences above the rows (Story.lua; the window's `say`); the header's
--               buttons in place of the picker and the search box: its length and players, "‹ Earlier",
--               "Later ›" and "All fights" (the window's `buttons`); then a row per player (and per pet
--               that took damage, under its owner): the name in its class colour where known, damage done
--               and taken, and a two-line strip over the fight's clock, done above in the class colour
--               (else the window's own blue), taken below in the game's red, a skull where they died;
--               then a row per enemy: done, taken, and whom it was attacking, in order, with seconds.
--               Three enemies show; a row for the rest opens them all.
--
-- The footer says where the numbers come from and how old they are: the combat log as the Ryna app read
-- it, as of the file's writtenAt; newer fights appear after /reload, since the game reads the file only
-- at login and /reload. Never the word "threat": the enemy rows say whom it was attacking.
--
-- With a core whose window lacks the fight pieces (Ryna.Window.MAX_SAY: cores after 0.4.2), nothing
-- registers and /ryna fights says the core is too old.

local _, ns = ...
if ns.off then return end
local L = ns.L

local W = {}
ns.Window = W

local KEY = "fights"
local ENEMIES_SHOWN = 3
local D, S = ns.Data, ns.Story

W.selected = nil -- the fight on screen (its place in ns.Data.list), nil for the list
W.expanded = false -- every enemy shown, not just the first three

local function RW() return ns.API.Window end

function W.Available()
  local rw = RW()
  return type(rw) == "table" and type(rw.AddSection) == "function" and type(rw.MAX_SAY) == "number"
end

-- Text -------------------------------------------------------------------------------------------------

local function number(n)
  n = math.floor((tonumber(n) or 0) + 0.5)
  local text = ns.Try(ns.Fn("BreakUpLargeNumbers"), n)
  if type(text) == "string" and not ns.IsSecret(text) then return text end
  local s = tostring(math.abs(n)):reverse():gsub("(%d%d%d)", "%1,"):reverse()
  if s:sub(1, 1) == "," then s = s:sub(2) end
  return (n < 0 and "-" or "") .. s
end
W.Number = number

-- What a fight was: the boss, else its zone and the kind of fight.
function W.What(f)
  if f.boss then return f.boss end
  local zone = f.zone or L["somewhere"]
  if f.kind == "trash" then return string.format(L["%s, trash"], zone) end
  return string.format(L["%s, open world"], zone)
end

function W.Result(f)
  if f.result == "kill" then return L["Kill"] end
  if f.result == "wipe" then return L["Wipe"] end
  return ""
end

local function resultColor(f)
  if f.result == "kill" then return "|cff40c040" end
  if f.result == "wipe" then return "|cffe04040" end
  return ""
end

-- Players in the fight: its rows that aren't pets, and the folded ones.
function W.Players(f)
  local n = 0
  for _, p in ipairs(f.players) do
    if p.pet == 0 then n = n + 1 end
  end
  return n + (f.otherPlayers and f.otherPlayers.n or 0)
end

-- The class of a row: the file's (the app knows its accounts' characters), else a character of this
-- account by name (the saved file; the log itself never says).
local byName
function W.ClassOf(p)
  if p.class then return p.class end
  if p.pet > 0 or not p.name then return nil end
  if not byName then
    byName = {}
    local db = ns.API.DB()
    for _, rec in pairs(type(db) == "table" and type(db.characters) == "table" and db.characters or {}) do
      local name = type(rec) == "table" and ns.Plain(ns.NonEmpty(rec.fullName)) or nil
      if name and type(rec.class) == "string" then byName[name:gsub("%-", " ")] = rec.class end
    end
  end
  return byName[p.name]
end

-- { r, g, b } of a class, from the client's RAID_CLASS_COLORS, or nil.
local function classRGB(class)
  local colors = _G.RAID_CLASS_COLORS
  local c = type(class) == "string" and type(colors) == "table" and colors[class] or nil
  if type(c) ~= "table" then return nil end
  if type(c.r) == "number" then return { c.r, c.g, c.b } end
  local hex = type(c.colorStr) == "string" and c.colorStr:match("^%x%x(%x%x%x%x%x%x)$")
  if hex then
    return { tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255 }
  end
  return nil
end

-- The game's red, for damage taken, or nil (the window's own muted red).
local function red()
  local c = _G.RED_FONT_COLOR
  if type(c) == "table" and type(c.r) == "number" and type(c.g) == "number" and type(c.b) == "number" then
    return { c.r, c.g, c.b }
  end
  return nil
end

local function colored(class, text)
  if not class then return text end
  return RW().ClassColor(class) .. text .. "|r"
end

-- An enemy's name as its row says it, in the game's hostile colour where the client has it.
local function enemyColor()
  local c = type(_G.FACTION_BAR_COLORS) == "table" and _G.FACTION_BAR_COLORS[2] or nil
  if type(c) == "table" and type(c.r) == "number" then
    return string.format("|cff%02x%02x%02x", math.floor(c.r * 255 + 0.5), math.floor(c.g * 255 + 0.5),
      math.floor(c.b * 255 + 0.5))
  end
  return nil
end

-- Whom an enemy was attacking, in order: "Corin 9s › Aster › Dela 4s" (names in class colours).
function W.Attacking(f, e)
  local parts = {}
  for _, t in ipairs(e.targets) do
    local p = t.row > 0 and f.players[t.row] or nil
    local name = S.Short(p and p.name or t.name)
    if p then name = colored(W.ClassOf(p), name) end
    local secs = math.floor(t.ms / 1000 + 0.5)
    parts[#parts + 1] = secs >= 1 and string.format(L["%s %ds"], name, secs) or name
  end
  if e.more > 0 then parts[#parts + 1] = string.format(L["%d more"], e.more) end
  if #parts == 0 then return L["nobody of the group"] end
  return table.concat(parts, " › ")
end

-- The fights a context lists: every one, or the ones a character logged, matching the search.
function W.Indices(ctx)
  local out = {}
  for i, f in ipairs(D.list) do
    if (ctx.all or f.by == ctx.character) and RW().Match(W.What(f), ctx.search) then out[#out + 1] = i end
  end
  return out
end

-- The fight the detail shows, or nil (none chosen, or gone with a reload).
function W.Selected()
  return W.selected and D.list[W.selected] or nil
end

function W.Show(index)
  W.selected = index
  W.expanded = false
  RW().Refresh(KEY)
end

-- The list --------------------------------------------------------------------------------------------

local LIST_COLUMNS = {
  { title = L["When"], width = 104 },
  { title = L["What"], width = 216 },
  { title = L["Length"], width = 56, justify = "RIGHT" },
  { title = L["Result"], width = 64 },
  { title = L["Done"], width = 78, justify = "RIGHT" },
  { title = L["Taken"], width = 78, justify = "RIGHT" },
}

function W.ListRows(ctx)
  local rows = {}
  for _, i in ipairs(W.Indices(ctx)) do
    local f = D.list[i]
    local me = f.me
    rows[#rows + 1] = {
      index = i, fight = f,
      cells = { "", W.What(f), S.Clock(f.length), resultColor(f) .. W.Result(f) .. (f.result and "|r" or ""),
        me and number(me.done) or "", me and number(me.taken) or "" },
      sort = { f.at, W.What(f):lower(), f.length, W.Result(f):lower(), me and me.done or nil, me and me.taken or nil },
    }
  end
  return rows
end

function W.ListTiles(ctx)
  local n, kills, tries, died = 0, 0, 0, 0
  for _, i in ipairs(W.Indices(ctx)) do
    local f = D.list[i]
    n = n + 1
    if f.kind == "boss" then
      tries = tries + 1
      if f.result == "kill" then kills = kills + 1 end
    end
    if f.me and f.me.died then died = died + 1 end
  end
  if n == 0 then return nil end
  return {
    { label = L["Fights"], value = number(n) },
    { label = L["Bosses killed"], value = number(kills),
      sub = tries > 0 and ns.Plural(tries, L["of %d try"], L["of %d tries"]) or nil },
    { label = L["Your deaths"], value = number(died) },
  }
end

-- A fight ---------------------------------------------------------------------------------------------

local DETAIL_COLUMNS = {
  { title = L["Players"], width = 168, sort = false },
  { title = L["Done"], width = 70, justify = "RIGHT", sort = false },
  { title = L["Taken"], width = 70, justify = "RIGHT", sort = false },
  { title = "", width = 288, kind = "strip", sort = false },
}

-- The row naming the fight's clock under the strips' heading.
local function axisRow(f)
  local labels = {}
  for q = 0, 3 do
    local i = math.floor(f.steps * q / 4) + 1
    if i <= f.steps then labels[i] = S.Clock((i - 1) * f.step) end
  end
  return { axis = true, cells = { "", "", "" }, strips = { [4] = { count = f.steps, labels = labels } } }
end

-- The block a time falls in, 1..steps.
local function blockAt(f, ms)
  return math.max(1, math.min(f.steps, math.floor(ms / f.step) + 1))
end

function W.DetailRows(f)
  local rows = { axisRow(f) }
  local taken = red()
  for r, p in ipairs(f.players) do
    local class = W.ClassOf(p)
    local name = S.Name(p.name)
    if p.pet > 0 then name = "  " .. name end
    local marks = {}
    for _, t in ipairs(p.deaths) do marks[#marks + 1] = blockAt(f, t) end
    rows[#rows + 1] = {
      kind = "player", row = r, player = p, fight = f,
      cells = { name, number(p.done), number(p.taken) },
      color = class and RW().ClassColor(class) or (p.pet > 0 and "|cffb0b0b0" or nil),
      strips = { [4] = { form = "height", values = p.doneSteps, below = p.takenSteps, color = classRGB(class),
        belowColor = taken, count = f.steps, marks = marks } },
    }
  end
  if f.otherPlayers then
    local o = f.otherPlayers
    rows[#rows + 1] = { kind = "otherPlayers", cells = { ns.Plural(o.n, L["%d more player"], L["%d more players"]),
      number(o.done), number(o.taken) } }
  end
  rows[#rows + 1] = { header = true, cells = { L["Enemies"], L["Done"], L["Taken"], L["Was attacking, in order"] } }
  local shown = W.expanded and #f.enemies or math.min(#f.enemies, ENEMIES_SHOWN)
  local hostile = enemyColor()
  for i = 1, shown do
    local e = f.enemies[i]
    rows[#rows + 1] = { kind = "enemy", enemy = e, fight = f, color = hostile,
      cells = { S.Enemy(e.name, e.nth), number(e.done), number(e.taken), W.Attacking(f, e) } }
  end
  local hidden, done, takenSum = #f.enemies - shown, 0, 0
  for i = shown + 1, #f.enemies do
    done, takenSum = done + f.enemies[i].done, takenSum + f.enemies[i].taken
  end
  local other = f.otherEnemies
  if hidden > 0 then
    local n = hidden + (other and other.n or 0)
    rows[#rows + 1] = { kind = "moreEnemies", open = true,
      cells = { ns.Plural(n, L["%d more enemy"], L["%d more enemies"]), number(done + (other and other.done or 0)),
        number(takenSum + (other and other.taken or 0)), L["Click to list them."] } }
  elseif other then
    rows[#rows + 1] = { kind = "moreEnemies",
      cells = { ns.Plural(other.n, L["%d more enemy"], L["%d more enemies"]), number(other.done), number(other.taken),
        L["Not kept: the file keeps the eight that mattered most."] } }
  end
  return rows
end

-- The header's buttons on a fight: its length and players, Earlier, Later, All fights.
function W.Buttons(ctx)
  local f = W.Selected()
  if not f then return nil end
  local earlier, later
  for _, i in ipairs(W.Indices({ all = ctx.all, character = ctx.character, search = "" })) do
    if i > W.selected and not earlier then earlier = i end
    if i < W.selected then later = i end
  end
  return {
    { label = S.Clock(f.length) .. " · " .. ns.Plural(W.Players(f), L["%d player"], L["%d players"]) },
    { label = L["‹ Earlier"], disabled = earlier == nil, width = 84,
      click = function() if earlier then W.Show(earlier) end end },
    { label = L["Later ›"], disabled = later == nil, width = 76,
      click = function() if later then W.Show(later) end end },
    { label = L["All fights"], width = 84, click = function() W.Show(nil) end },
  }
end

-- Tooltips ----------------------------------------------------------------------------------------------

local function line(tip, left, right)
  tip:AddDoubleLine(left, right, 0.8, 0.8, 0.8, 1, 1, 1)
end

function W.Tooltip(row, tip)
  local f = row.fight
  if row.index and f then
    tip:AddLine(W.What(f), 1, 1, 1)
    line(tip, L["When"], date("%Y-%m-%d %H:%M", f.at))
    line(tip, L["Length"], S.Clock(f.length))
    line(tip, L["Players"], number(W.Players(f)))
    if f.result then line(tip, L["Result"], W.Result(f)) end
    if f.me then
      line(tip, L["Your damage done"], number(f.me.done))
      line(tip, L["Your damage taken"], number(f.me.taken))
      line(tip, L["Your healing done"], number(f.me.heal))
    end
    line(tip, L["Deaths"], number(#f.deaths))
    tip:AddLine(S.First(f), 1, 1, 1, true)
  elseif row.kind == "player" then
    local p = row.player
    tip:AddLine(colored(W.ClassOf(p), S.Name(p.name)), 1, 1, 1)
    if p.pet > 0 and f.players[p.pet] then
      tip:AddLine(string.format(L["%s's pet: its damage done is in its owner's row."], S.Name(f.players[p.pet].name)),
        0.8, 0.8, 0.8, true)
    end
    line(tip, L["Damage done"], number(p.done))
    line(tip, L["Damage taken"], number(p.taken))
    line(tip, L["Healing done"], number(p.heal))
    for _, t in ipairs(p.deaths) do line(tip, L["Died at"], S.Clock(t)) end
  elseif row.kind == "enemy" then
    local e = row.enemy
    tip:AddLine(S.Enemy(e.name, e.nth), 1, 1, 1)
    line(tip, L["Damage done"], number(e.done))
    line(tip, L["Damage taken"], number(e.taken))
    if #e.targets > 0 then tip:AddLine(L["Was attacking, in order:"], 1, 0.82, 0) end
    for _, t in ipairs(e.targets) do
      local p = t.row > 0 and f.players[t.row] or nil
      local name = S.Name(p and p.name or t.name)
      if p then name = colored(W.ClassOf(p), name) end
      line(tip, name, string.format(L["%s to %s"], S.Clock(t.from), S.Clock(t.from + t.ms)))
    end
    if e.more > 0 then tip:AddLine(string.format(L["and %d more"], e.more), 0.8, 0.8, 0.8) end
  end
end

-- The section -------------------------------------------------------------------------------------------

function W.Why()
  if D.why == "version" then
    return L["The fights file is from another version: update the Ryna app and the addon."]
  end
  if D.why == "core" then return L["Fights needs a newer Ryna core: update the Ryna app."] end
  return nil
end

function W.Footer()
  local why = W.Why()
  if why then return why end
  local at = D.WrittenAt()
  if not D.table or not at then
    return L["From your combat log, as the Ryna app reads it; newer fights appear after /reload."]
  end
  return string.format(L["From your combat log, as the Ryna app read it, as of %s; newer fights appear after /reload."],
    ns.Ago(at) or L["an unknown time"])
end

function W.Empty(ctx)
  local why = W.Why()
  if why then return why end
  if #D.list > 0 and not ctx.all then return L["None of these fights was logged by this character."] end
  return L["Fights appear here once the Ryna app has read your combat log and the game is reloaded."]
end

function W.Spec()
  return {
    key = KEY, group = "combat", label = L["Fights"], order = 10,
    characters = "all",
    title = function()
      local f = W.Selected()
      if not f then return L["Fights"] end
      local what = W.What(f)
      if f.result then what = string.format(L["%s, %s"], what, W.Result(f):lower()) end
      return string.format(L["Fights › %s"], what)
    end,
    version = function() return tostring(D.version) .. ":" .. tostring(W.selected) .. ":" .. tostring(W.expanded) end,
    columns = function() return W.Selected() and DETAIL_COLUMNS or LIST_COLUMNS end,
    rows = function(ctx)
      local f = W.Selected()
      if f then return W.DetailRows(f) end
      return W.ListRows(ctx)
    end,
    fill = function(row)
      if row.index and row.fight then row.cells[1] = ns.Ago(row.fight.at) or "" end
    end,
    tiles = function(ctx)
      if W.Selected() then return nil end
      return W.ListTiles(ctx)
    end,
    say = function()
      local f = W.Selected()
      if not f then return nil end
      return S.Lines(f)
    end,
    buttons = function(ctx) return W.Buttons(ctx) end,
    tooltip = function(row, tip) W.Tooltip(row, tip) end,
    click = function(row)
      if row.index then
        W.Show(row.index)
      elseif row.open then
        W.expanded = true
        RW().Refresh(KEY)
      end
    end,
    footer = function() return W.Footer() end,
    empty = function(ctx) return W.Empty(ctx) end,
  }
end

-- At login: the section, when the core's window can draw it.
function W.Register()
  if W.registered or not W.Available() then return end
  W.registered = RW().AddSection(W.Spec()) and true or false
  byName = nil
end

-- Opens the window on Fights (its list). Returns false when the core can't draw it.
function W.Open()
  if not W.registered then return false end
  W.selected, W.expanded = nil, false
  return RW().Open(KEY) and true or false
end
