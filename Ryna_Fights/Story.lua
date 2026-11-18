-- Story: a fight told in sentences, the part of its detail above the rows. Pure: it reads a fight as
-- Data.lua checked it and calls nothing in the client.
--
--   "Aster Vale opened with Flame Lash on Harbor Brute at 0:08."   the first blow, whichever side struck it
--   "Dockside Cutter went for Dela Marsh at 0:10."                 the enemy's answer, when the group opened
--   "Dela died at 0:26, Aster at 0:29, Corin at 0:32."            deaths in order (first names), dimmer
--
-- The wording claims no more than the log shows. The log has no casts begun, auras or positions, so a
-- pull by walking into range shows only as the enemy's first swing: the sentence says who struck first
-- ("opened with"), never who pulled. When the other side struck within a quarter second the log's order
-- may not be the game's, and the sentence says so. A swing is "a melee swing"; a miss says it missed.

local _, ns = ...
if ns.off then return end
local L = ns.L
local N = ns.N

local S = {}
ns.Story = S

S.DEATHS = 5 -- deaths named in the sentence; the rest are counted

-- "0:08", "12:05": minutes and seconds from the fight's start.
function S.Clock(ms)
  local secs = math.floor((tonumber(ms) or 0) / 1000)
  if secs < 0 then secs = 0 end
  return string.format("%d:%02d", math.floor(secs / 60), secs % 60)
end

-- A name, or the word for one the log didn't give.
function S.Name(name)
  if type(name) == "string" and name ~= "" then return name end
  return L["someone"]
end

-- The first word of a name ("Dela Marsh" -> "Dela"), for the short places.
function S.Short(name)
  if type(name) ~= "string" or name == "" then return L["someone"] end
  return name:match("^(%S+)") or name
end

-- An enemy with its number among the same-named ones ("Dockside Cutter 2").
function S.Enemy(name, nth)
  name = S.Name(name)
  if type(nth) == "number" and nth > 0 then return string.format(L["%s %d"], name, nth) end
  return name
end

-- Who swung a blow: the enemy, the player, or the player's pet.
local function striker(b)
  if b.by == "enemy" then return S.Enemy(b.who, b.whoNth) end
  if b.pet then return string.format(L["%s's %s"], S.Name(b.who), b.pet) end
  return S.Name(b.who)
end

local function target(b)
  if b.by == "group" then return S.Enemy(b.on, b.onNth) end
  return S.Name(b.on)
end

-- The first blow's sentence, or the one that says there was none.
function S.First(fight)
  local b = type(fight) == "table" and fight.first or nil
  if type(b) ~= "table" then return L["The log shows no blow between the group and an enemy."] end
  local with = b.with or L["a melee swing"]
  local key = b.miss and N("%s opened with %s on %s at %s, and missed.") or N("%s opened with %s on %s at %s.")
  local text = string.format(L[key], striker(b), with, target(b), S.Clock(b.t))
  if b.close then
    text = text .. " " .. (b.by == "group" and L["The enemy struck back within a quarter second."]
      or L["The group struck back within a quarter second."])
  end
  return text
end

-- The enemy's answer when the group opened, or nil.
function S.Answer(fight)
  local b = type(fight) == "table" and fight.first or nil
  local a = type(b) == "table" and b.by == "group" and b.answer or nil
  if type(a) ~= "table" then return nil end
  return string.format(L["%s went for %s at %s."], S.Enemy(a.who, a.whoNth), S.Name(a.on), S.Clock(a.t))
end

-- Deaths in order: "Dela died at 0:26, Aster at 0:29, and 3 more.", or "Nobody died."
function S.Deaths(fight)
  local list = type(fight) == "table" and fight.deaths or nil
  if type(list) ~= "table" or #list == 0 then return L["Nobody died."] end
  local parts = { string.format(L["%s died at %s"], S.Short(list[1].name), S.Clock(list[1].t)) }
  for i = 2, math.min(#list, S.DEATHS) do
    parts[#parts + 1] = string.format(L[", %s at %s"], S.Short(list[i].name), S.Clock(list[i].t))
  end
  local text = table.concat(parts)
  if #list > S.DEATHS then text = text .. string.format(L[", and %d more"], #list - S.DEATHS) end
  return text .. "."
end

-- The detail's lines (the window's `say`): the first blow, the answer when there is one, the deaths.
function S.Lines(fight)
  local out = { S.First(fight) }
  local answer = S.Answer(fight)
  if answer then out[#out + 1] = answer end
  out[#out + 1] = { text = S.Deaths(fight), dim = true }
  return out
end
