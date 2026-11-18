-- Written by the Ryna companion app from its own reading of your combat log. Edits are overwritten.
-- Data/fights.lua: your most recent fights, newest first, for Ryna's Fights section. It names
-- the players who were in them, and stays on this computer.
RynaData_fights = {
	version = 1,
	writtenAt = 1800000900,
	flavor = "wowf",
	items = {
		{
			at = 1800000600, length = 4000, kind = "boss", zone = "Saltmire Docks", pulls = 1, step = 1000, steps = 4, boss = "Captain Gull", result = "kill", by = "Player-1-0000000D",
			me = { done = 0, taken = 0, heal = 0 },
			first = { by = "enemy", who = "Dockside Cutter", on = "Corin Ashby", t = 0, miss = true },
			deaths = { },
			players = {
				{ name = "Corin Ashby", done = 50, taken = 20, heal = 0, doneSteps = { 0, 0, 100 }, takenSteps = { 0, 0, 0, 100 } },
				{ name = "Aster Vale", class = "SHAMAN", done = 0, taken = 0, heal = 0, doneSteps = {}, takenSteps = {} },
				{ name = "Bryn Holloway", done = 0, taken = 0, heal = 0, doneSteps = {}, takenSteps = {} },
				{ name = "Dela Marsh", class = "PRIEST", done = 0, taken = 0, heal = 0, doneSteps = {}, takenSteps = {} },
				{ name = "Ember Quill", done = 0, taken = 0, heal = 0, doneSteps = {}, takenSteps = {} },
			},
			enemies = {
				{ name = "Dockside Cutter", done = 20, taken = 50, targets = { { 1, 0, 4000 }, }, more = 0 },
			},
		},
		{
			at = 1800000000, length = 36000, kind = "trash", zone = "Saltmire Docks", pulls = 1, step = 1000, steps = 36, by = "Player-1-0000000D",
			me = { done = 0, taken = 600, heal = 40, died = 26000 },
			first = { by = "group", who = "Aster Vale", on = "Harbor Brute", with = "Flame Lash", t = 8000, answer = { by = "enemy", who = "Dockside Cutter", on = "Dela Marsh", t = 10000 } },
			deaths = { { "Dela Marsh", 26000, 6 }, { "Aster Vale", 29000, 1 }, { "Corin Ashby", 32000, 5 }, },
			players = {
				{ name = "Aster Vale", class = "SHAMAN", done = 120, taken = 660, heal = 0, doneSteps = { 0, 0, 0, 0, 0, 0, 0, 0, 23 }, takenSteps = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 100 } },
				{ name = "Ember Quill", done = 1120, taken = 180, heal = 0, doneSteps = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 97, 0, 100 }, takenSteps = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 25 } },
				{ name = "Wolf", pet = 2, done = 0, taken = 55, heal = 0, doneSteps = {}, takenSteps = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9 } },
				{ name = "Bryn Holloway", done = 200, taken = 0, heal = 0, doneSteps = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 39 }, takenSteps = {} },
				{ name = "Corin Ashby", done = 90, taken = 800, heal = 0, doneSteps = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 17 }, takenSteps = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13, 13, 0, 0, 0, 0, 0, 0, 0, 0, 0, 75, 100 } },
				{ name = "Dela Marsh", class = "PRIEST", done = 0, taken = 600, heal = 40, doneSteps = {}, takenSteps = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 18, 0, 0, 20, 0, 0, 23, 75 } },
			},
			enemies = {
				{ name = "Harbor Brute", done = 1040, taken = 1425, targets = { { 1, 10500, 3500 }, { 2, 15000, 3000 }, { 5, 19000, 6500 }, { 2, 34000, 1500 }, }, more = 0 },
				{ name = "Dockside Cutter", done = 1255, taken = 105, targets = { { 6, 10000, 2000 }, { 3, 14000, 2000 }, { 6, 18000, 9000 }, { 1, 27000, 3500 }, { 3, 35600, 400 }, }, more = 0 },
			},
		},
	},
}
