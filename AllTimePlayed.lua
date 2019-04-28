local addon = LibStub("AceAddon-3.0"):NewAddon("AllTimePlayed", "AceConsole-3.0", "AceEvent-3.0")
local icon = LibStub("LibDBIcon-1.0")
local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("AllTimePlayed!", {
  type = "data source",
  text = "AllTimePlayed!",
  icon = "Interface\\Icons\\INV_Eng_Clockworkegg",
})

AllTimePlayedDB = AllTimePlayedDB or {}
local playedAddon = true

local o = ChatFrame_DisplayTimePlayed
ChatFrame_DisplayTimePlayed = function(...)
  if (playedAddon) then
    playedAddon = false
    return
  end
  return o(...)
end

function ldb:OnEnter(motion) ShowPlaytime() end

function addon:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("AllTimePlayedDB", {
    profile = {
      minimap = {
        hide =  false,
      },
    },
  })
  icon:Register("AllTimePlayed!", ldb, self.db.profile.minimap)
  self:RegisterEvent("TIME_PLAYED_MSG")
end

function addon:TIME_PLAYED_MSG(name, total, currentLevel) AllTimePlayedDB[UnitName("player")] = total end

function ShowPlaytime()
  playedAddon = true
  RequestTimePlayed()

  local totaltime = 0
  for player,time in pairs(AllTimePlayedDB) do
    if (type(time) == 'number') then
      print("|cffffff00"..player.." : "..secondsToDays(time) )
      totaltime = totaltime + time
    end
  end

  print("|cffffff00Temps de jeu total : "..secondsToDays(totaltime) )
end

function secondsToDays(inputSeconds)
  d = math.floor(inputSeconds/86400)
  h = math.floor((bit.mod(inputSeconds,86400))/3600)
  m = math.floor(bit.mod((bit.mod(inputSeconds,86400)),3600)/60)
  s = math.floor(bit.mod(bit.mod((bit.mod(inputSeconds,86400)),3600),60))
 return  d.." jours, "..h.." heures, "..m.." minutes, "..s.." secondes"
end
