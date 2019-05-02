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
    erase = {
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
    col = {
      name = L["Colors"],
      type = "group",
      order = 1,
      args = {
        colc = {
          order = 1,
          type = "input",
          name = L["Current character"],
          desc = L["Color of current character"],
          validate = function(info, value) return VerifHexa(value) end,
          get = function(info) return AllTimePlayed.db.profile.colcurrent end,
          set = function(info, value) AllTimePlayed.db.profile.colcurrent = value end,
        colo = {
          order = 2,
          type = "input",
          name = L["Others characters"],
          desc = L["Color of others characters"],
          validate = function(info, value) return VerifHexa(value) end,
          get = function(info) return AllTimePlayed.db.profile.colother end,
          set = function(info, value) AllTimePlayed.db.profile.colother = value end,
        },
        colt = {
          order = 3,
          type = "input",
          name = L["Total"],
          desc = L["Color of total"],
          validate = function(info, value) return VerifHexa(value) end,
          get = function(info) return AllTimePlayed.db.profile.coltotal end,
          set = function(info, value) AllTimePlayed.db.profile.coltotal = value end,
        },
      }
    },
  }
}

local defaults = {
  profile = {
    minimap = { hide = false },
    colcurrent = "ffff00",
    colother = "808080",
    coltotal = "008000",
  }
}

function AllTimePlayed:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("AllTimePlayedDB", defaults)

  LibStub("AceConfig-3.0"):RegisterOptionsTable("AllTimePlayed", myOptions)
  AceConfigDialog:SetDefaultSize("AllTimePlayed", 860, 660)

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
        tooltip:SetCell(line, 1, "|cff" .. self.db.profile.colcurrent .. player .. ": ", "LEFT", 1)
        tooltip:SetCell(line, 2, "|cff" .. self.db.profile.colcurrent .. SecondsToDays(time), "RIGHT")
      else
        tooltip:SetCell(line, 1, "|cff" .. self.db.profile.colother .. player .. ": ", "LEFT", 1)
        tooltip:SetCell(line, 2, "|cff" .. self.db.profile.colother .. SecondsToDays(time), "RIGHT")
      end
      totaltime = totaltime + time
    end
  end

  line, column = tooltip:AddLine()
  tooltip:SetCell(line, 1, "|cff" .. self.db.profile.coltotal .. L["Total:"], "LEFT", 1)
  tooltip:SetCell(line, 2, "|cff" .. self.db.profile.coltotal .. SecondsToDays(totaltime), "RIGHT")

  tooltip:UpdateScrolling()
  tooltip:Show()
end

function AllTimePlayed:HideTooltip() self.tooltip:Hide() end
function AllTimePlayed:TIME_PLAYED_MSG(name, total, currentLevel) AllTimePlayedDB[UnitName("player")] = total end

function VerifHexa(value)
  if string.match(value, "^%x%x%x%x%x%x$") then
    return true
  else
    return "ERROR - Should be a hexadecimal code"
  end
end

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
