local ZAllTimePlayed = LibStub("AceAddon-3.0"):NewAddon(
  "ZAllTimePlayed",
  "AceConsole-3.0",
  "AceEvent-3.0"
)

local playedZAllTimePlayed = false

local o = ChatFrame_DisplayTimePlayed
ChatFrame_DisplayTimePlayed = function(...)
  if (playedZAllTimePlayed) then
    playedZAllTimePlayed = false
    return
  end
  return o(...)
end

local L = LibStub("AceLocale-3.0"):GetLocale("ZAllTimePlayed")

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibQTip = LibStub("LibQTip-1.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local LDBObj = LibStub("LibDataBroker-1.1"):NewDataObject("ZAllTimePlayed", {
  type = "data source",
  text = "ZAllTimePlayed",
  icon = "Interface\\Icons\\INV_Eng_Clockworkegg",
  OnEnter = function(motion)
    ZAllTimePlayed:DrawTooltip(motion)
  end,
  OnLeave = function()
    ZAllTimePlayed:HideTooltip()
  end,
  OnClick = function (_, button)
    if button == 'LeftButton' then
      ShowPlaytime()
    elseif button == 'RightButton' then
      ZAllTimePlayed:MenuOnOpen()
    end
  end
})

local myOptions = {
  type = "group",
  name = "ZAllTimePlayed",
  childGroups = "tree",
  plugins = {},
  args = {
    erase_current = {
      order = 1,
      type = "execute",
      name = L["Nettoyer le personnage courant"],
      desc = L["Efface les données du personnage courant"],
      func = function()
        for player,time in pairs(ZAllTimePlayedDB) do
          if (type(time) == 'number') then
            if (UnitName("player") == player) then
              ZAllTimePlayedDB[player] = nil
            end
          end
        end
      end,
    },
    erase_others = {
      order = 2,
      type = "execute",
      name = L["Nettoyer les autres personnages"],
      desc = L["Efface les données des autres personnages"],
      func = function()
        for player,time in pairs(ZAllTimePlayedDB) do
          if (type(time) == 'number') then
            if not (UnitName("player") == player) then
              ZAllTimePlayedDB[player] = nil
            end
          end
        end
      end,
    },
    format_time = {
      order = 3,
      type = "select",
      name = L["Format du temps"],
      desc = L["Selectionne le format de temps"],
      get = function(_)
        return ZAllTimePlayed.db.profile.format
      end,
      set = function(_, value)
        ZAllTimePlayed.db.profile.format = value
      end,
      values = {
        days = L["Jours"],
        hours = L["Heures"],
        minutes = L["Minutes"],
        seconds = L["Secondes"]
      },
    },
    minimapIcon = {
      order = 4,
      type = "toggle",
      name = L["Bouton de la minimap"],
      desc = L["Afficher/Cacher le bouton de la minimap"],
      get = function()
        return not ZAllTimePlayed.db.profile.minimap.hide
      end,
      set = function(_, value)
        ZAllTimePlayed.db.profile.minimap.hide = not value
        ZAllTimePlayed:RefreshMinimap()
      end,
    },
    col = {
      name = L["Couleurs"],
      type = "group",
      order = 10,
      args = {
        col_header = {
          order = 1,
          type = "header",
          name = L["Couleur dans le bouton de la minimap"],
        },
        col_current = {
          order = 2,
          type = "input",
          name = L["Personnage actuel"],
          desc = L["Couleur du personnage actuel"],
          validate = function(_, value)
            return VerifHexa(value)
          end,
          get = function(_)
            return ZAllTimePlayed.db.profile.color.current
          end,
          set = function(_, value)
            ZAllTimePlayed.db.profile.color.current = value
          end
        },
        col_others = {
          order = 3,
          type = "input",
          name = L["Autres personnages"],
          desc = L["Couleur des autres personnages"],
          validate = function(_, value)
            return VerifHexa(value)
          end,
          get = function(_)
            return ZAllTimePlayed.db.profile.color.others
          end,
          set = function(_, value)
            ZAllTimePlayed.db.profile.color.others = value
          end
        },
        col_total = {
          order = 4,
          type = "input",
          name = L["Total"],
          desc = L["Couleur du total"],
          validate = function(_, value)
            return VerifHexa(value)
          end,
          get = function(_)
            return ZAllTimePlayed.db.profile.color.total
          end,
          set = function(_, value)
            ZAllTimePlayed.db.profile.color.total = value
          end
        },
        col_chat_header = {
          order = 5,
          type = "header",
          name = L["Couleur dans le chat"]
        },
        col_chat_current = {
          order = 6,
          type = "input",
          name = L["Personnage actuel"],
          desc = L["Couleur du personnage actuel"],
          validate = function(_, value)
            return VerifHexa(value)
          end,
          get = function(_)
            return ZAllTimePlayed.db.profile.color.chatcurrent
          end,
          set = function(_, value)
            ZAllTimePlayed.db.profile.color.chatcurrent = value
          end
        },
        col_chat_others = {
          order = 7,
          type = "input",
          name = L["Autres personnages"],
          desc = L["Couleur des autres personnages"],
          validate = function(_, value)
            return VerifHexa(value)
          end,
          get = function(_)
            return ZAllTimePlayed.db.profile.color.chatothers
          end,
          set = function(_, value)
            ZAllTimePlayed.db.profile.color.chatothers = value
          end
        },
        col_chat_total = {
          order = 8,
          type = "input",
          name = L["Total"],
          desc = L["Couleur du total"],
          validate = function(_, value)
            return VerifHexa(value)
          end,
          get = function(_)
            return ZAllTimePlayed.db.profile.color.chattotal
          end,
          set = function(_, value)
            ZAllTimePlayed.db.profile.color.chattotal = value
          end
        },
      }
    },
    faq = {
      name = L["FAQ"],
      desc = L["Foire aux questions"],
      type = "group",
      order = 1000,
      args = {
        line1 = {
          type = "description",
          name = "|cffffd200" .. L["Qu'est-ce que Z-AllTimePlayed ?"] .. "|r",
          order = 1
        },
        line2 = {
          type = "description",
          name = L["C'est un addon qui enregistre le temps joué par personnage. Il offre plusieurs façon au joueur d'afficher l'information."] .. "\n",
          order = 2
        },
        line3 = {
          type = "description",
          name = "|cffffd200" .. L["Quand est-ce que les données sont mise à jours ?"] .. "|r",
          order = 3
        },
        line4 = {
          type = "description",
          name = L["Les données sont mise à jours quand"] .. " :",
          order = 4
        },
        line5 = {
          type = "description",
          name = " - " .. L["Vous vous connecté."] .. "\n - " .. L["Vous vous déconnecté."] .. "\n - " .. L["Vous changez de zone."] .. "\n - " .. L["Vous pointez votre souris sur le bouton de la minimap."]  .. "\n - " .. L["Vous rechargez votre interface."] .. "\n - " .. L["Vous executez la commande /played."] .. "\n",
          order = 5
        },
        line6 = {
          type = "description",
          name = "|cffffd200" .. L["J'ai trouvé un bogue, comment puis-je te contacter ?"],
          order = 6
        },
        line7 = {
          type = "description",
          name = L["Vous pouvez créer un ticket sur |cffffff78<https://www.wowace.com/projects/z-alltimeplayed/issues>|r ou sur |cffffff78<https://github.com/lamboley/Z-AllTimePlayed/issues>|r."] .. "\n",
          order = 7
        }
      }
    }
  }
}

local defaults = {
  profile = {
    format = "days",
    minimap = {
      hide = false
    },
    color = {
      current = "ffff00",
      others = "808080",
      total = "008000",
      chatcurrent = "ffff00",
      chatothers = "ffff00",
      chattotal = "ffff00"
    }
  }
}

function ZAllTimePlayed:ChatCommand(input)
  if input == 'options' then
    self:MenuOnOpen()
  elseif input == 'minimap' then
    self.db.profile.minimap.hide = not self.db.profile.minimap.hide
    self:RefreshMinimap()
  else
    print("|cffa2e19fZAllTimeplayed:|r " .. L["Arguments pour"] .. " |cfffff194/zatp|r : ")
    print("|cfffff194  options|r - " .. L["Ouvre les options."])
    print("|cfffff194  minimap|r - " .. L["Affiche/Cache le bouton de la minimap."])
  end
end

function ZAllTimePlayed:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("ZAllTimePlayedDB", defaults)

  LibStub("AceConfig-3.0"):RegisterOptionsTable("ZAllTimePlayed", myOptions)
  AceConfigDialog:SetDefaultSize("ZAllTimePlayed", 760, 335)
  self:RegisterChatCommand( "zatp", "ChatCommand")

  LibDBIcon:Register("ZAllTimePlayed", LDBObj, self.db.profile.minimap)
end

function ZAllTimePlayed:OnEnable()
  self:RegisterEvent("TIME_PLAYED_MSG")
  self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
  self:RegisterEvent("PLAYER_LEAVING_WORLD", "OnEvent")
  self:RegisterEvent("ZONE_CHANGED", "OnEvent")
end

function ZAllTimePlayed:OnDisable()
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
  self:UnregisterEvent("PLAYER_LEAVING_WORLD")
  self:UnregisterEvent("ZONE_CHANGED")
end

function ZAllTimePlayed:OnEvent()
  RequestPlayed()
end

function ZAllTimePlayed:RefreshMinimap()
  LibStub("LibDBIcon-1.0"):Refresh("ZAllTimePlayed", self.db.profile.minimap)
end

function ZAllTimePlayed:DrawTooltip(anchor)
  RequestPlayed()

  if not self.tooltip then
    self.tooltip = LibQTip:Acquire("ZAllTimePlayedTooltip")
  end

  local ttime = 0
  local tooltip = self.tooltip
  tooltip:Clear()
  tooltip:SmartAnchorTo(anchor)
  tooltip:SetColumnLayout(2, "LEFT", "LEFT", "LEFT")

  for player,time in pairs(ZAllTimePlayedDB) do
    if (type(time) == 'number') then
      line = tooltip:AddLine()
      if (UnitName("player") == player) then
        tooltip:SetCell(line, 1, "|cff" .. self.db.profile.color.current .. player .. ": ")
        tooltip:SetCell(line, 2, "|cff" .. self.db.profile.color.current .. WriteTime(time))
      else
        tooltip:SetCell(line, 1, "|cff" .. self.db.profile.color.others .. player .. ": ")
        tooltip:SetCell(line, 2, "|cff" .. self.db.profile.color.others .. WriteTime(time))
      end
      ttime = ttime + time
    end
  end

  line = tooltip:AddLine()
  tooltip:SetCell(line, 1, "|cff" .. self.db.profile.color.total .. L["Total:"])
  tooltip:SetCell(line, 2, "|cff" .. self.db.profile.color.total .. WriteTime(ttime))

  tooltip:Show()
end

function ZAllTimePlayed:MenuOnOpen()
  if AceConfigDialog.OpenFrames["ZAllTimePlayed"] then
    AceConfigDialog:Close("ZAllTimePlayed")
  else
    AceConfigDialog:Open("ZAllTimePlayed")
  end
end

function ZAllTimePlayed:HideTooltip()
  if self.tooltip then
    LibQTip:Release(self.tooltip)
    self.tooltip = nil
  end
end

function ZAllTimePlayed:TIME_PLAYED_MSG(_, total, _)
  ZAllTimePlayedDB[UnitName("player")] = total
end

function VerifHexa(value)
  if string.match(value, "^%x%x%x%x%x%x$") then
    return true
  else
    return L["ERREUR - Doit être un code hexadécimale"]
  end
end

function RequestPlayed()
  playedZAllTimePlayed = true
  RequestTimePlayed()
end

function ShowPlaytime()
  local ttime = 0
  for player,time in pairs(ZAllTimePlayedDB) do
    if (type(time) == 'number') then
      if (UnitName("player") == player) then
        print("|cff" .. ZAllTimePlayed.db.profile.color.chatcurrent .. player .. " : " .. WriteTime(time))
      else
        print("|cff" .. ZAllTimePlayed.db.profile.color.chatothers .. player .. " : " .. WriteTime(time))
      end
      ttime = ttime + time
    end
  end
  print("|cff" .. ZAllTimePlayed.db.profile.color.chattotal .. L["Temps de jeu total"] .. " : " .. WriteTime(ttime))
end

function WriteTime(seconds)
  if ZAllTimePlayed.db.profile.format == "days" then
    d = math.floor(seconds/86400)
    h = math.floor((bit.mod(seconds,86400))/3600)
    m = math.floor(bit.mod((bit.mod(seconds,86400)),3600)/60)
    s = math.floor(bit.mod(bit.mod((bit.mod(seconds,86400)),3600),60))
    return d .. L[" jours, "] .. h .. L[" heures, "] .. m .. L[" minutes, "] .. s .. L[" secondes"]
  elseif ZAllTimePlayed.db.profile.format == "hours" then
    h = math.floor((seconds)/3600)
    m = math.floor(bit.mod((bit.mod(seconds,86400)),3600)/60)
    s = math.floor(bit.mod(bit.mod((bit.mod(seconds,86400)),3600),60))
    return h .. L[" heures, "] .. m .. L[" minutes, "] .. s .. L[" secondes"]
  elseif ZAllTimePlayed.db.profile.format == "minutes" then
    m = math.floor(seconds/60)
    s = math.floor(bit.mod(bit.mod((bit.mod(seconds,86400)),3600),60))
    return m .. L[" minutes, "] .. s .. L[" secondes"]
  elseif ZAllTimePlayed.db.profile.format == "seconds" then
    return seconds .. L[" secondes"]
  end
end
