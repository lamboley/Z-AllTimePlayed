local addon = LibStub("AceAddon-3.0"):NewAddon("AllTimePlayed", "AceConsole-3.0", "AceEvent-3.0")
local icon = LibStub("LibDBIcon-1.0")
local lqt = LibStub("LibQTip-1.0")
local ldb = LibStub("LibDataBroker-1.1"):NewDataObject("AllTimePlayed!", {
  type = "data source",
  text = "AllTimePlayed!",
  icon = "Interface\\Icons\\INV_Eng_Clockworkegg",
})

function addon:DrawTooltip(anchor)
  RequestPlayed()
  local totaltime = 0

  if not self.tooltip then
    self.tooltip = lqt:Acquire("AllTimePlayedTooltip", 2)
  end

  local tooltip = self.tooltip
  tooltip:SetScale(0.90)
  tooltip:Clear()
  tooltip:SmartAnchorTo(anchor)

  for player,time in pairs(AllTimePlayedDB) do
    if (type(time) == 'number') then
      line, column = tooltip:AddLine()
      tooltip:SetCell(line, 1, player..": ", "LEFT", 1)
      tooltip:SetCell(line, 2, secondsToDays(time), "RIGHT")
      totaltime = totaltime + time
    end
  end

  line, column = tooltip:AddLine()
  tooltip:SetCell(line, 1, "Total: ", "LEFT", 1)
  tooltip:SetCell(line, 2, secondsToDays(totaltime), "RIGHT")

  tooltip:UpdateScrolling()

  tooltip:Show()
end

function addon:CloseTooltips()
  self.tooltip:Hide()
end

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

function ldb:OnClick()
  ShowPlaytime()
end

function ldb:OnEnter(motion)
  addon:DrawTooltip(self)
end

function ldb:OnLeave()
  addon:CloseTooltips()
end

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

function RequestPlayed()
  playedAddon = true
  RequestTimePlayed()
end

function ShowPlaytime()
  RequestPlayed()

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
