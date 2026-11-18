-- Init: Fights registers with the core (Ryna.RegisterMod). Loaded last, so every handler exists. At
-- login it reads the app's fights file (Data.lua) and adds its section to Ryna's window (Window.lua);
-- /ryna fights opens it there.

local _, ns = ...
if ns.off then return end
local L = ns.L

ns.API.RegisterMod({
  id = "fights",
  addon = ns.NAME,
  name = "Fights",
  version = ns.VERSION,
  onLogin = function()
    ns.Run("fights file", ns.Data.Load)
    ns.Run("fights window", ns.Window.Register)
    ns.Debug("fights: %d in the file (%s)", #ns.Data.list, tostring(ns.Data.why or "read"))
  end,
})

local Slash = ns.API.Slash
if type(Slash) == "table" and type(Slash.Add) == "function" then
  Slash.Add({
    word = "fights",
    order = 70,
    help = L["/ryna fights: your recent fights in Ryna's window"],
    run = function()
      if not ns.Window.Open() then ns.Print(L["Fights needs a newer Ryna core: update the Ryna app."]) end
    end,
  })
end
