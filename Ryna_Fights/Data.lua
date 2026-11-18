-- Data: the app's fights file, read once at login. The Ryna app writes Interface/AddOns/Ryna_Core/Data/fights.lua
-- (its fights_data.rs has the whole shape) and the core hands it out through Ryna.Data.Get("fights", 1):
--
--   RynaData_fights = { version = 1, writtenAt, flavor, items = { fight, ... } }   newest first
--   fight = { at, length, kind, zone, pulls, step, steps, boss, result, by,
--             me = { done, taken, heal, died }, first = blow, deaths = { { name, ms, row }, ... },
--             players = { { name, class, pet, done, taken, heal, doneSteps, takenSteps }, ... },
--             otherPlayers = { n, done, taken, heal },
--             enemies = { { name, nth, done, taken, targets = { { row or name, fromMs, ms }, ... }, more }, ... },
--             otherEnemies = { n, done, taken } }
--   blow  = { by = "group" | "enemy", who, whoNth, pet, on, onNth, with, t, miss, close, answer = blow }
--
-- Everything is read defensively: the file is the app's, but a half-written or hand-edited one must not
-- error the window, so a fight without a start or a length is skipped, a row that isn't a table is
-- skipped, a name that isn't a string reads as unknown, and every number is checked. A table of another
-- version is ignored whole (D.why = "version": the app or the addon is behind), a missing one is
-- "absent", and a core without Ryna.Data is "core". Steps arrive as shares from 0 to 100 of the fight's
-- biggest; they are kept as 0..1 under a square root, so a small amount still shows as a block (the
-- agreed mockup draws them so).

local _, ns = ...
if ns.off then return end

local D = {}
ns.Data = D

D.VERSION = 1   -- the table's version this addon reads (the app's fights_data::VERSION)
D.MAX_STEPS = 48
D.list = {}
D.version = 0   -- moves at every Load, so the window rebuilds its rows

local function num(v, default)
  if type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge then return v end
  return default
end

local function str(v)
  if type(v) == "string" and v ~= "" and not ns.IsSecret(v) then return v end
  return nil
end

local function count(v)
  v = num(v, 0)
  if v < 0 then return 0 end
  return math.floor(v)
end

-- Steps as the strip draws them: 0..1, square-rooted, at most `steps` (and 48) long.
local function steps(list, n)
  local out = {}
  if type(list) ~= "table" then return out end
  for i = 1, math.min(n, D.MAX_STEPS) do
    local v = num(list[i], 0)
    if v < 0 then v = 0 elseif v > 100 then v = 100 end
    out[i] = math.sqrt(v / 100)
  end
  return out
end

local function blow(b, depth)
  if type(b) ~= "table" then return nil end
  local by = b.by == "enemy" and "enemy" or (b.by == "group" and "group" or nil)
  if not by then return nil end
  local out = {
    by = by, who = str(b.who), whoNth = num(b.whoNth), pet = str(b.pet), on = str(b.on), onNth = num(b.onNth),
    with = str(b.with), t = math.max(0, num(b.t, 0)), miss = b.miss == true, close = b.close == true,
  }
  if depth < 1 then out.answer = blow(b.answer, depth + 1) end
  return out
end

local function folded(o)
  if type(o) ~= "table" or count(o.n) < 1 then return nil end
  return { n = count(o.n), done = count(o.done), taken = count(o.taken), heal = count(o.heal) }
end

-- One fight of the file, checked, or nil when it isn't one.
function D.Fight(f)
  if type(f) ~= "table" then return nil end
  local at, length = num(f.at), num(f.length)
  if not at or not length or length < 0 then return nil end
  local n = math.min(count(f.steps), D.MAX_STEPS)
  local out = {
    at = at, length = length, kind = (f.kind == "boss" or f.kind == "trash") and f.kind or "world",
    zone = str(f.zone), boss = str(f.boss), pulls = math.max(1, count(f.pulls)),
    result = (f.result == "kill" or f.result == "wipe") and f.result or nil,
    step = math.max(1, num(f.step, 1000)), steps = n, by = str(f.by),
    first = blow(f.first, 0), deaths = {}, players = {}, enemies = {},
    otherPlayers = folded(f.otherPlayers), otherEnemies = folded(f.otherEnemies),
  }
  if type(f.me) == "table" then
    out.me = { done = count(f.me.done), taken = count(f.me.taken), heal = count(f.me.heal), died = num(f.me.died) }
  end
  for _, p in ipairs(type(f.players) == "table" and f.players or {}) do
    if type(p) == "table" then
      out.players[#out.players + 1] = {
        name = str(p.name), class = str(p.class), pet = count(p.pet),
        done = count(p.done), taken = count(p.taken), heal = count(p.heal),
        doneSteps = steps(p.doneSteps, n), takenSteps = steps(p.takenSteps, n), deaths = {},
      }
    end
  end
  -- A pet's owner must be a row before it; anything else reads as no owner.
  for i, p in ipairs(out.players) do
    if p.pet >= i or p.pet > #out.players then p.pet = 0 end
  end
  for _, d in ipairs(type(f.deaths) == "table" and f.deaths or {}) do
    if type(d) == "table" and num(d[2]) then
      local row = count(d[3])
      if row > #out.players then row = 0 end
      local death = { name = str(d[1]), t = math.max(0, d[2]), row = row }
      out.deaths[#out.deaths + 1] = death
      if row > 0 then table.insert(out.players[row].deaths, death.t) end
    end
  end
  for _, e in ipairs(type(f.enemies) == "table" and f.enemies or {}) do
    if type(e) == "table" then
      local enemy = { name = str(e.name), nth = num(e.nth), done = count(e.done), taken = count(e.taken),
        targets = {}, more = count(e.more) }
      for _, s in ipairs(type(e.targets) == "table" and e.targets or {}) do
        if type(s) == "table" then
          local who = s[1]
          local row = type(who) == "number" and count(who) or 0
          if row > #out.players then row = 0 end
          local name = row == 0 and str(who) or nil
          if row > 0 or name then
            enemy.targets[#enemy.targets + 1] = { row = row, name = name, from = math.max(0, num(s[2], 0)),
              ms = math.max(0, num(s[3], 0)) }
          end
        end
      end
      out.enemies[#out.enemies + 1] = enemy
    end
  end
  return out
end

-- At login: the table, or why not ("core": no Ryna.Data; "absent"; "version"), and its fights.
function D.Load()
  local data = ns.API.Data
  D.table, D.why, D.list = nil, nil, {}
  D.version = D.version + 1
  if type(data) ~= "table" or type(data.Get) ~= "function" then
    D.why = "core"
    return
  end
  local t, why = data.Get("fights", D.VERSION)
  if not t then
    D.why = why or "absent"
    return
  end
  D.table = t
  for _, f in ipairs(t.items) do
    local fight = D.Fight(f)
    if fight then D.list[#D.list + 1] = fight end
  end
end

-- When the file was written (unix seconds), or nil.
function D.WrittenAt()
  local t = D.table
  if type(t) ~= "table" then return nil end
  return num(t.writtenAt)
end
