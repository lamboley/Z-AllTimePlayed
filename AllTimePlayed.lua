local AllTimePlayed = LibStub("AceAddon-3.0"):NewAddon("AllTimePlayed", "AceConsole-3.0", "AceEvent-3.0")

AllTimePlayedDB = AllTimePlayedDB or {}
local playedAllTimePlayed = false

local o = ChatFrame_DisplayTimePlayed
ChatFrame_DisplayTimePlayed = function(...)
  if (playedAllTimePlayed) then
    playedAllTimePlayed = false
    return
  end
  return o(...)
end

local L = LibStub("AceLocale-3.0"):GetLocale("AllTimePlayed")

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibQTip = LibStub("LibQTip-1.0")
local LDBObj = LibStub("LibDataBroker-1.1"):NewDataObject("AllTimePlayed", {
    type = "data source",
    text = "AllTimePlayed",
    icon = "Interface\\Icons\\INV_Eng_Clockworkegg",
    OnEnter = function(motion) AllTimePlayed:DrawTooltip(motion) end,
    OnLeave = function() AllTimePlayed:HideTooltip() end,
    OnClick = function (_, button)
      if button == 'LeftButton' then
        ShowPlaytime()
      elseif button == 'RightButton' then
        if AceConfigDialog.OpenFrames["AllTimePlayed"] then
          AceConfigDialog:Close("AllTimePlayed")
        else
          AceConfigDialog:Open("AllTimePlayed")
        end
      end
    end
  })


local myOptions = {
  type = "group",
  name = "AllTimePlayed",
  childGroups = "tree",
  plugins = {},
  args = {
    kb = {
      order = 1,
      type = "execute",
      name = L["Clean data"],
      desc = L["Erase all data saved"],
      func = function()
        for player,time in pairs(AllTimePlayedDB) do
          if (type(time) == 'number') then
            AllTimePlayedDB[player] = nil
          end
        end
      end,
    },
    desc = {
      name = L["Description"],
      type = "group",
      order = 9999,
      args = {
        line1 = {
          type = "description",
          name = "|cffffd200" .. L["What does AllTimePlayed ?"] .. "|r",
          order = 1,
        },
        line2 = {
          type = "description",
          name = L["It show the played time for all characters when pointer is on the minimap button."],
          order = 2,
        },
      }
    }
  }
}

function AllTimePlayed:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("AllTimePlayedDB", { global = { minimap = { hide = false }}})

  LibStub("AceConfig-3.0"):RegisterOptionsTable("AllTimePlayed", myOptions)
  AceConfigDialog:SetDefaultSize("AllTimePlayed", 680, 560)

  LibStub("LibDBIcon-1.0"):Register("AllTimePlayed", LDBObj, self.db.profile.minimap)
  self:RegisterEvent("TIME_PLAYED_MSG")

  RequestPlayed()
end

function AllTimePlayed:DrawTooltip(anchor)
  RequestPlayed()

  if not self.tooltip then self.tooltip = LibQTip:Acquire("AllTimePlayedTooltip", 2) end

  local totaltime = 0
  local tooltip = self.tooltip
  tooltip:SetScale(0.90)
  tooltip:Clear()
  tooltip:SmartAnchorTo(anchor)

  for player,time in pairs(AllTimePlayedDB) do
    if (type(time) == 'number') then
      line, column = tooltip:AddLine()
      if (UnitName("player") == player) then
        tooltip:SetCell(line, 1, "|cffffff00" .. player .. ": ", "LEFT", 1)
        tooltip:SetCell(line, 2, "|cffffff00" .. SecondsToDays(time), "RIGHT")
      else
        tooltip:SetCell(line, 1, "|cff808080" .. player .. ": ", "LEFT", 1)
        tooltip:SetCell(line, 2, "|cff808080" .. SecondsToDays(time), "RIGHT")
      end
      totaltime = totaltime + time
    end
  end

  line, column = tooltip:AddLine()
  tooltip:SetCell(line, 1, "|cff008000" .. L["Total:"], "LEFT", 1)
  tooltip:SetCell(line, 2, "|cff008000" .. SecondsToDays(totaltime), "RIGHT")

  tooltip:UpdateScrolling()
  tooltip:Show()
end

function AllTimePlayed:HideTooltip() self.tooltip:Hide() end
function AllTimePlayed:TIME_PLAYED_MSG(name, total, currentLevel) AllTimePlayedDB[UnitName("player")] = total end

function RequestPlayed()
  playedAllTimePlayed = true
  RequestTimePlayed()
end

function ShowPlaytime()
  RequestPlayed()

  local totaltime = 0
  for player,time in pairs(AllTimePlayedDB) do
    if (type(time) == 'number') then
      print("|cffffff00" .. player .. " : " .. SecondsToDays(time) )
      totaltime = totaltime + time
    end
  end
  print("|cffffff00" .. L["Total time played"] .. " : " .. SecondsToDays(totaltime) )
end

function SecondsToDays(inputSeconds)
  days = math.floor(inputSeconds/86400)
  hours = math.floor((bit.mod(inputSeconds,86400))/3600)
  minutes = math.floor(bit.mod((bit.mod(inputSeconds,86400)),3600)/60)
  seconds = math.floor(bit.mod(bit.mod((bit.mod(inputSeconds,86400)),3600),60))
 return days .. L[" days, "] .. hours .. L[" hours, "] .. minutes .. L[" minutes, "] .. seconds .. L[" seconds"]
end
