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
    erase_current = {
      order = 1,
      type = "execute",
      name = L["Clean current character"],
      desc = L["Erase current character data"],
      func = function()
        for player,time in pairs(AllTimePlayedDB) do
          if (type(time) == 'number') then
            if (UnitName("player") == player) then
              AllTimePlayedDB[player] = nil
            end
          end
        end
      end,
    },
    erase_others = {
      order = 2,
      type = "execute",
      name = L["Clean others characters"],
      desc = L["Erase others characters data"],
      func = function()
        for player,time in pairs(AllTimePlayedDB) do
          if (type(time) == 'number') then
            if not (UnitName("player") == player) then
              AllTimePlayedDB[player] = nil
            end
          end
        end
      end,
    },
    col = {
      name = L["Colors"],
      type = "group",
      order = 10,
      args = {
        col_header = {
          order = 1,
          type = "header",
          name = L["Color in minimap button"],
        },
        col_current = {
          order = 2,
          type = "input",
          name = L["Current character"],
          desc = L["Color of current character"],
          validate = function(info, value) return VerifHexa(value) end,
          get = function(info) return AllTimePlayed.db.profile.colcurrent end,
          set = function(info, value) AllTimePlayed.db.profile.colcurrent = value end
        },
        col_others = {
          order = 3,
          type = "input",
          name = L["Others characters"],
          desc = L["Color of others characters"],
          validate = function(info, value) return VerifHexa(value) end,
          get = function(info) return AllTimePlayed.db.profile.colothers end,
          set = function(info, value) AllTimePlayed.db.profile.colothers = value end
        },
        col_total = {
          order = 4,
          type = "input",
          name = L["Total"],
          desc = L["Color of total"],
          validate = function(info, value) return VerifHexa(value) end,
          get = function(info) return AllTimePlayed.db.profile.coltotal end,
          set = function(info, value) AllTimePlayed.db.profile.coltotal = value end
        },
        col_chat_header = {
          order = 5,
          type = "header",
          name = L["Color in chat"]
        },
        col_chat_current = {
          order = 6,
          type = "input",
          name = L["Current character"],
          desc = L["Color of current character"],
          validate = function(info, value) return VerifHexa(value) end,
          get = function(info) return AllTimePlayed.db.profile.colchatcurrent end,
          set = function(info, value) AllTimePlayed.db.profile.colchatcurrent = value end
        },
        col_chat_others = {
          order = 7,
          type = "input",
          name = L["Others characters"],
          desc = L["Color of others characters"],
          validate = function(info, value) return VerifHexa(value) end,
          get = function(info) return AllTimePlayed.db.profile.colchatothers end,
          set = function(info, value) AllTimePlayed.db.profile.colchatothers = value end
        },
        col_chat_total = {
          order = 8,
          type = "input",
          name = L["Total"],
          desc = L["Color of total"],
          validate = function(info, value) return VerifHexa(value) end,
          get = function(info) return AllTimePlayed.db.profile.colchattotal end,
          set = function(info, value) AllTimePlayed.db.profile.colchattotal = value end
        },
      }
    },
    faq = {
      name = L["FAQ"],
      desc = L["Frequently Asked Questions"],
      type = "group",
      order = 1000,
      args = {
        line1 = {
          type = "description",
          name = "|cffffd200" .. L["What is AllTimePlayed ?"] .. "|r",
          order = 1
        },
        line2 = {
          type = "description",
          name = L["It's an addon which record the played time per character. It give multiple way to print the info to the user."] .. "\n",
          order = 2
        },
        line3 = {
          type = "description",
          name = "|cffffd200" .. L["When data are updated ?"] .. "|r",
          order = 3
        },
        line4 = {
          type = "description",
          name = L["Data are updated when"] .. " :",
          order = 4
        },
        line5 = {
          type = "description",
          name = " - " .. L["You log in."] .. "\n - " .. L["You log out."] .. "\n - " .. L["You change of zone."] .. "\n - " .. L["You reload your UI."] .. "\n - " .. L["You execute the /played command."] .. "\n",
          order = 5
        },
        line6 = {
          type = "description",
          name = "|cffffd200" .. L["I have found a bug, how can I contact you ?"],
          order = 6
        },
        line7 = {
          type = "description",
          name = L["You can create an issue on my github |cffffff78<https://github.com/lamboley/AllTimePlayed>|r"] .. "\n",
          order = 7
        }
      }
    }
  }
}

local defaults = {
  profile = {
    minimap = { hide = false },
    colcurrent = "ffff00",
    colothers = "808080",
    coltotal = "008000",
    colchatcurrent = "ffff00",
    colchatothers = "ffff00",
    colchattotal = "ffff00",
  }
}

function AllTimePlayed:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("AllTimePlayedDB", defaults)

  LibStub("AceConfig-3.0"):RegisterOptionsTable("AllTimePlayed", myOptions)
  AceConfigDialog:SetDefaultSize("AllTimePlayed", 760, 295)

  LibStub("LibDBIcon-1.0"):Register("AllTimePlayed", LDBObj, self.db.profile.minimap)
  self:RegisterEvent("TIME_PLAYED_MSG")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("PLAYER_LEAVING_WORLD")
  self:RegisterEvent("ZONE_CHANGED")

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
        tooltip:SetCell(line, 1, "|cff" .. self.db.profile.colothers .. player .. ": ", "LEFT", 1)
        tooltip:SetCell(line, 2, "|cff" .. self.db.profile.colothers .. SecondsToDays(time), "RIGHT")
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
function AllTimePlayed:PLAYER_ENTERING_WORLD() RequestPlayed() end
function AllTimePlayed:PLAYER_LEAVING_WORLD() RequestPlayed() end
function AllTimePlayed:ZONE_CHANGED() RequestPlayed() end

function VerifHexa(value)
  if string.match(value, "^%x%x%x%x%x%x$") then
    return true
  else
    return L["ERROR - Should be a hexadecimal code"]
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
      if (UnitName("player") == player) then
        print("|cff" .. AllTimePlayed.db.profile.colchatcurrent .. player .. " : " .. SecondsToDays(time))
      else
        print("|cff" .. AllTimePlayed.db.profile.colchatothers .. player .. " : " .. SecondsToDays(time))
      end
      totaltime = totaltime + time
    end
  end
  print("|cff" .. AllTimePlayed.db.profile.colchattotal .. L["Total time played"] .. " : " .. SecondsToDays(totaltime) )
end

function SecondsToDays(inputSeconds)
  days = math.floor(inputSeconds/86400)
  hours = math.floor((bit.mod(inputSeconds,86400))/3600)
  minutes = math.floor(bit.mod((bit.mod(inputSeconds,86400)),3600)/60)
  seconds = math.floor(bit.mod(bit.mod((bit.mod(inputSeconds,86400)),3600),60))
 return days .. L[" days, "] .. hours .. L[" hours, "] .. minutes .. L[" minutes, "] .. seconds .. L[" seconds"]
end
