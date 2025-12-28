
---------------
-- LIBRARIES --
---------------
local LibCamera = LibStub("LibCamera-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")
-------------
-- GLOBALS --
-------------
assert(DynamicCam)
DynamicCam.Options = DynamicCam:NewModule("Options", "AceEvent-3.0")


DynamicCam.cameraDistanceMaxZoomFactor_max = 39
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
  DynamicCam.cameraDistanceMaxZoomFactor_max = 50
end



------------
-- LOCALS --
------------
local function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


local Options = DynamicCam.Options
local _

-- To store the currently selected situation and situation ID.
local S, SID, lastSelectedSID
local copiedSituationID
local exportName, exportAuthor




-- Checking if "situation controls" settings deviate from the stock settings.

function DynamicCam:ScriptEqual(customScript, defaultScript)
  if (customScript == "" and defaultScript == nil) or customScript == defaultScript then return true end
end

function DynamicCam:EventsEqual(customEvents, defaultEvents)
  local customEventsCheck = {}
  local defaultEventsCheck = {}

  for k, v in pairs(customEvents) do
    customEventsCheck[v] = true
  end

  for k, v in pairs(defaultEvents) do
    if not customEventsCheck[v] then
      return false
    end
    defaultEventsCheck[v] = true
  end

  for k, v in pairs(customEvents) do
    if not defaultEventsCheck[v] then
      return false
    end
  end

  return true
end


local function EventsIsDefault(situationID)
  if not DynamicCam.defaults.profile.situations[situationID] then return true end
  return DynamicCam:EventsEqual(DynamicCam.db.profile.situations[situationID].events, DynamicCam.defaults.profile.situations[situationID].events)
end

local function ScriptIsDefault(situationID, scriptName)
  if not DynamicCam.defaults.profile.situations[situationID] then return true end
  return DynamicCam:ScriptEqual(DynamicCam.db.profile.situations[situationID][scriptName], DynamicCam.defaults.profile.situations[situationID][scriptName])
end

local function ValueIsDefault(situationID, valueName)
  if not DynamicCam.defaults.profile.situations[situationID] then return true end
  return DynamicCam.db.profile.situations[situationID][valueName] == DynamicCam.defaults.profile.situations[situationID][valueName]
end


local function SituationControlsAreDefault(situationID)
  if ValueIsDefault(situationID, "priority") and
      EventsIsDefault(situationID) and
      ScriptIsDefault(situationID, "executeOnInit") and
      ScriptIsDefault(situationID, "condition") and
      ScriptIsDefault(situationID, "executeOnEnter") and
      ScriptIsDefault(situationID, "executeOnExit") and
      ValueIsDefault(situationID, "delay") then
    return true
  else
    return false
  end
end

local function SituationControlsToDefault(situationID)
  local targetSituation = DynamicCam.db.profile.situations[situationID]
  local defaultSituation = DynamicCam.defaults.profile.situations[situationID]

  targetSituation.priority       = defaultSituation.priority
  targetSituation.events         = defaultSituation.events
  targetSituation.executeOnInit  = defaultSituation.executeOnInit
  targetSituation.condition      = defaultSituation.condition
  targetSituation.executeOnEnter = defaultSituation.executeOnEnter
  targetSituation.executeOnExit  = defaultSituation.executeOnExit
  targetSituation.delay          = defaultSituation.delay

  DynamicCam:UpdateSituation(situationID)

end


local function ColourTextErrorOrModified(text, dataType, dataId)

  -- Do we have an error at all, and is it an error for this script.
  -- (dataId is left empty to colour the "Situation Controls" tab text.)
  if S.errorEncountered and (not dataId or dataId == S.errorEncountered) then
    return "|cFFEE0000".. text .. "|r"

  -- Check if the given data is default. Different checking methods based on dataType.
  else
    if (not dataId and not SituationControlsAreDefault(SID))
        or (dataType == "value"  and not ValueIsDefault(SID, dataId))
        or (dataType == "events" and not EventsIsDefault(SID))
        or (dataType == "script" and not ScriptIsDefault(SID, dataId)) then
      return "|cFFFF6600" .. text .. "|r"
    else
      return text
    end
  end
end




-- A function to get all views used by all situations.
local function GetUsedViews()
  local usedViews = {}
  local usedDefaultViews = {}
  -- Go through all situations.
  for id, situation in pairs(DynamicCam.db.profile.situations) do

    if situation.enabled and not situation.errorEncountered then

      -- Shortcut variable.
      local sc = situation.viewZoom

      if sc.enabled and sc.viewZoomType == "view" then

        if not usedViews[sc.viewNumber] then
          usedViews[sc.viewNumber] = {}
        end
        -- Store the id of the situation using this view.
        usedViews[sc.viewNumber][id] = true

        if not usedDefaultViews[sc.def] then
          usedDefaultViews[sc.restoreDefaultViewNumber] = {}
        end
        -- Store the id of the situation using this view.
        usedDefaultViews[sc.restoreDefaultViewNumber][id] = true

      end
    end
  end

  return usedViews, usedDefaultViews
end




-- We want to use the same CreateSettingsTab() function for the
-- standard settings and situation settings. Hence we need this function
-- to return the appropriate table.
function DynamicCam:GetSettingsTable(situationId)
  if situationId then
    return self.db.profile.situations[situationId].situationSettings
  else
    return self.db.profile.standardSettings
  end
end


-- For the get functions of the options: if a situation has no setting,
-- we want to show the standard value.
function DynamicCam:GetSettingsValue(situationId, index1, index2)

  -- Is this a request for a standard or situation setting?
  local settingsTable = self:GetSettingsTable(situationId)

  -- Is this a request for the cvars sub table?
  if index1 == "cvars" and index2 then
    -- Is there a user setting?
    if settingsTable.cvars[index2] ~= nil then
      return settingsTable.cvars[index2]
    -- If there is none, this must have been an unset situation setting,
    -- so we are returning the standard setting.
    else
      return self.db.profile.standardSettings.cvars[index2]
    end
  else
    if settingsTable[index1] ~= nil then
      return settingsTable[index1]
    else
      return self.db.profile.standardSettings[index1]
    end
  end
end


function DynamicCam:GetSettingsDefault(index1, index2)
  -- Is this a request for the cvars sub table?
  if index1 == "cvars" and index2 then
    return self.defaults.profile.standardSettings.cvars[index2]
  else
    return self.defaults.profile.standardSettings[index1]
  end
end


function DynamicCam:SetSettingsValue(newValue, situationId, index1, index2)
  -- Is this a request for a standard or situation setting?
  local settingsTable = self:GetSettingsTable(situationId)

  -- Is this a request for the cvars sub table?
  if index1 == "cvars" and index2 then
    settingsTable.cvars[index2] = newValue
  else
    settingsTable[index1] = newValue
  end

  self:ApplySettings()
end

function DynamicCam:SetSettingsDefault(situationId, index1, index2)
  -- Is this a request for a standard or situation setting?
  local settingsTable = self:GetSettingsTable(situationId)

  -- Is this a request for the cvars sub table?
  if index1 == "cvars" and index2 then
    settingsTable.cvars[index2] = self.defaults.profile.standardSettings.cvars[index2]
  else
    settingsTable[index1] = self.defaults.profile.standardSettings[index1]
  end

  self:ApplySettings()
end


function DynamicCam:SettingsPanelSetIgnoreParentAlpha(ignoreParentAlpha)
  GameMenuFrame:SetIgnoreParentAlpha(ignoreParentAlpha)
  SettingsPanel:SetIgnoreParentAlpha(ignoreParentAlpha)
  for i = 1, LibStub("AceGUI-3.0"):GetNextWidgetNum("Dropdown-Pullout") do
    if _G["AceGUI30Pullout" .. i] then _G["AceGUI30Pullout" .. i]:SetIgnoreParentAlpha(ignoreParentAlpha) end
  end
end


-- We need this to disable a reset button when its parent group is disabled.
-- Thanks to vrul!
-- https://www.wowinterface.com/forums/showthread.php?p=338116#post338116
local function GetInheritedDisabledStatus(info)
  local option, options = info.options, { }
  local disabled = option.disabled
  for index = 1, #info - 1 do
    option = option.args[info[index]]
    options[index] = option
  end
  for index = #options, 1, -1 do
    if options[index].disabled ~= nil then
      disabled = options[index].disabled
      break
    end
  end
  if type(disabled) == "function" then
    disabled = disabled()
  end
  return disabled
end


local resetButtonImageCoords = {0.58203125, 0.64453125, 0.30078125, 0.36328125}
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
  resetButtonImageCoords = {0.533203125, 0.58203125, 0.248046875, 0.294921875}
end



local function CreateSliderResetButton(order, forSituations, index1, index2, tooltipDefaultValue)

  -- We allow to pass the tooltipDefaultValue as an extra argument, because for some
  -- settings the slider value is a transformation of the cvar.
  if tooltipDefaultValue == nil then
    tooltipDefaultValue = DynamicCam:GetSettingsDefault(index1, index2)
  end

  return {
    type = "execute",

    -- -- You could also take the icon in the name, but this is not clickable.
    -- name = CreateAtlasMarkup("transmog-icon-revert-small", 20, 20),

    name = L["Reset"],
    image = "Interface\\Transmogrify\\Transmogrify",
    imageCoords = resetButtonImageCoords,
    imageWidth = 25/1.5,
    imageHeight = 24/1.5,
    desc = L["Reset to global default"] .. ": " .. tooltipDefaultValue .. "\n" .. L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"],
    order = order,
    width = 0.25,
    func =
      function()
        DynamicCam:SetSettingsDefault(forSituations and SID, index1, index2)
      end,
    disabled =
      function(info)
        return GetInheritedDisabledStatus(info) or (DynamicCam:GetSettingsValue(forSituations and SID, index1, index2) == DynamicCam:GetSettingsDefault(index1, index2))
      end,
  }
end




local zoomGroupVars = {
  {"cvars", "cameraDistanceMaxZoomFactor"},
  {"cvars", "cameraZoomSpeed"},
  {"reactiveZoomAddIncrementsAlways"},
  {"reactiveZoomEnabled"},
  {"reactiveZoomAddIncrements"},
  {"reactiveZoomIncAddDifference"},
  {"reactiveZoomMaxZoomTime"},
}

local mouseLookGroupVars = {
  {"cvars", "cameraYawMoveSpeed"},
  {"cvars", "cameraPitchMoveSpeed"},
}

local shoulderOffsetGroupVars = {
  {"cvars", "test_cameraOverShoulder"},
  {"shoulderOffsetZoomEnabled"},
  {"shoulderOffsetZoomLowerBound"},
  {"shoulderOffsetZoomUpperBound"},
}

local pitchGroupVars = {
  {"cvars", "test_cameraDynamicPitch"},
  {"cvars", "test_cameraDynamicPitchBaseFovPad"},
  {"cvars", "test_cameraDynamicPitchBaseFovPadFlying"},
  {"cvars", "test_cameraDynamicPitchBaseFovPadDownScale"},
  {"cvars", "test_cameraDynamicPitchSmartPivotCutoffDist"},
}

local targetFocusGroupVars = {
  {"cvars", "test_cameraTargetFocusEnemyEnable"},
  {"cvars", "test_cameraTargetFocusEnemyStrengthYaw"},
  {"cvars", "test_cameraTargetFocusEnemyStrengthPitch"},
  {"cvars", "test_cameraTargetFocusInteractEnable"},
  {"cvars", "test_cameraTargetFocusInteractStrengthYaw"},
  {"cvars", "test_cameraTargetFocusInteractStrengthPitch"},
}

local headTrackingGroupVars = {
  {"cvars", "test_cameraHeadMovementStrength"},
  {"cvars", "test_cameraHeadMovementStandingStrength"},
  {"cvars", "test_cameraHeadMovementStandingDampRate"},
  {"cvars", "test_cameraHeadMovementMovingStrength"},
  {"cvars", "test_cameraHeadMovementMovingDampRate"},
  {"cvars", "test_cameraHeadMovementFirstPersonDampRate"},
  {"cvars", "test_cameraHeadMovementRangeScale"},
  {"cvars", "test_cameraHeadMovementDeadZone"},
}



-- Check if any of the group variables are set.
local function CheckGroupVars(groupVarsTable, situationId)
  if not situationId then
    situationId = SID
  end

  for k, v in pairs(groupVarsTable) do
    local index1, index2 = unpack(v)
    local situationSettingsTable = DynamicCam.db.profile.situations[situationId].situationSettings
    if index1 == "cvars" and index2 then
      -- Is there a user setting?
      if situationSettingsTable.cvars[index2] ~= nil then
        return true
      end
    else
      if situationSettingsTable[index1] ~= nil then
        return true
      end
    end
  end
  return false
end


-- Clear all group variables.
local function SetGroupVars(groupVarsTable, override)
  for k, v in pairs(groupVarsTable) do
    local index1, index2 = unpack(v)
    local situationSettingsTable = DynamicCam.db.profile.situations[SID].situationSettings
    local standardSettingsTable = DynamicCam.db.profile.standardSettings

    if index1 == "cvars" and index2 then
      if override then
        situationSettingsTable.cvars[index2] = standardSettingsTable.cvars[index2]
      else
        situationSettingsTable.cvars[index2] = nil
      end
    else
      if override then
        situationSettingsTable[index1] = standardSettingsTable[index1]
      else
        situationSettingsTable[index1] = nil
      end
    end
  end

  DynamicCam:ApplySettings()
end


local function GreyWhenInactive(name, enabled)
  if not enabled then
    return "|cff909090"..name.."|r"
  end
  return name
end

local function ColoredNames(name, groupVarsTable, forSituations)
  if not forSituations then
    if DynamicCam.currentSituationID and CheckGroupVars(groupVarsTable, DynamicCam.currentSituationID) then
      return "|cFF00FF00"..name.."|r"
    end
  else
    if not CheckGroupVars(groupVarsTable) then
      return "|cff909090"..name.."|r"
    end
  end
  return name
end


local function CreateOverriddenText(groupVarsTable, forSituations)
  return {
    type = "description",
    name =
      function()
        if DynamicCam.currentSituationID and CheckGroupVars(groupVarsTable, DynamicCam.currentSituationID) then
          return "|cFF00FF00" .. L["Currently overridden by the active situation \"%s\"."]:format(DynamicCam.db.profile.situations[DynamicCam.currentSituationID].name) .. "|r\n"
        end
      end,
    order = 0,
    hidden =
      function()
        return forSituations
      end,
  }
end


local function CreateOverrideStandardToggle(groupVarsTable, forSituations)
  return {
    type = "toggle",
    name = L["Override Standard Settings"],
    desc = L["<overrideStandardToggle_desc>"],
    order = 0,
    width = "full",
    hidden =
      function()
        return not forSituations
      end,
    get =
      function()
        return CheckGroupVars(groupVarsTable)
      end,
    set =
      function(_, newValue)
        SetGroupVars(groupVarsTable, newValue)
      end,
  }
end


local function ApplyContinuousRotation()
  if SID == DynamicCam.currentSituationID then
    LibCamera:StopRotating()

    if S.rotation.enabled and S.rotation.rotationType == "continuous" then
      LibCamera:BeginContinuousYaw(S.rotation.rotationSpeed, 0)
    end
  end
end


local function ApplyUIFade()
  if SID == DynamicCam.currentSituationID then
    DynamicCam:FadeInUI(0)
    if S.hideUI.enabled then
      DynamicCam:FadeOutUI(0, S.hideUI)
    end
  end
end


local function GetSituationList()
  local situationList = {}

  for id, situation in pairs(DynamicCam.db.profile.situations) do

    if not situation.name or not situation.priority then
      DynamicCam.db.profile.situations[id] = nil
      -- print("Purging situation", id)
    else

      local prefix = ""
      local suffix = ""
      local customPrefix = ""
      local modifiedSuffix = ""

      if situation.errorEncountered then
        prefix = "|cFFEE0000"
        suffix = "|r"
      elseif DynamicCam.currentSituationID == id then
        prefix = "|cFF00FF00"
        suffix = "|r"
      elseif not situation.enabled then
        prefix = "|cFF808A87"
        suffix = "|r"
      elseif DynamicCam.conditionExecutionCache[id] then
        prefix = "|cFF63B8FF"
        suffix = "|r"
      end

      if string.find(id, "custom") then
        customPrefix = L["Custom:"] .. " "
      end

      if not SituationControlsAreDefault(id) then
        modifiedSuffix = "|cFFFF6600  " .. L["(modified)"] .. "|r"
      end

      -- print(id, situation.name)
      situationList[id] = prefix .. customPrefix .. situation.name .. " [" .. L["Priority"] .. ": " .. situation.priority .. "]" .. suffix .. modifiedSuffix
    end
  end

  return situationList
end




local function CreateSettingsTab(tabOrder, forSituations)

  -- For the situation settings the area is a little smaller.
  local sliderWidth = 1.9
  if forSituations then
    sliderWidth = 1.75
  end

  return {

    type = "group",
    name =
      function()
        if not forSituations then return L["Standard Settings"]
        else return L["Situation Settings"] end
      end,
    order = tabOrder,
    args = {

      help = {
        type = "description",
        name =
          function()
            local text = ""

            if not forSituations then

              text = L["<standardSettings_desc>"]

              if DynamicCam.currentSituationID then
                text = text .. " |cFF00FF00" .. L["<standardSettingsOverridden_desc>"] .. "|r"
              end

            else
              text = L["These Situation Settings override the Standard Settings when the respective situation is active."]
            end

            return text .. "\n\n"
          end,
        order = 0,
      },


      zoomGroup = {
        type = "group",
        name =
          function()
            return ColoredNames(L["Mouse Zoom"], zoomGroupVars, forSituations)
          end,
        order = 1,
        args = {

          overriddenText = CreateOverriddenText(zoomGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(zoomGroupVars, forSituations),
          blank0 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },


          zoomSubGroup = {
            type = "group",
            name = "",
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(zoomGroupVars)
              end,
            args = {

              cameraDistanceMaxFactor = {
                type = "range",
                name = L["Maximum Camera Distance"],
                desc = L["How many yards the camera can zoom away from your character."] .. "\n|cff909090cvar: cameraDistanceMaxZoomFactor|r",
                order = 1,
                width = sliderWidth,
                min = 15,
                max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                step = 0.5,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "cameraDistanceMaxZoomFactor") * 15
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue/15, forSituations and SID, "cvars", "cameraDistanceMaxZoomFactor")
                  end,
              },
              cameraDistanceMaxFactorReset =
                CreateSliderResetButton(1.1, forSituations, "cvars", "cameraDistanceMaxZoomFactor",
                                        DynamicCam:GetSettingsDefault("cvars", "cameraDistanceMaxZoomFactor") * 15),
              blank1 = {type = "description", name = " ", order = 1.2, },

              cameraZoomSpeed = {
                type = "range",
                name = L["Camera Zoom Speed"],
                desc = L["How fast the camera can zoom."] .. "\n|cff909090cvar: cameraZoomSpeed|r",
                order = 2,
                width = sliderWidth,
                min = 1,
                max = 50,
                step = 0.5,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "cameraZoomSpeed")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "cameraZoomSpeed")
                  end,
              },
              cameraZoomSpeedReset =
                CreateSliderResetButton(2.1, forSituations, "cvars", "cameraZoomSpeed"),
              blank2 = {type = "description", name = " ", order = 2.2, },

              addIncrementsAlways = {
                type = "range",
                name = L["Zoom Increments"],
                desc = L["How many yards the camera should travel for each \"tick\" of the mouse wheel."],
                order = 3,
                width = sliderWidth,
                min = 0.05,
                max = 10,
                step = 0.05,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomAddIncrementsAlways") + 1
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue - 1, forSituations and SID, "reactiveZoomAddIncrementsAlways")
                  end,
              },
              addIncrementsAlwaysReset =
                CreateSliderResetButton(3.1, forSituations, "reactiveZoomAddIncrementsAlways", nil,
                                        DynamicCam:GetSettingsDefault("reactiveZoomAddIncrementsAlways") + 1),
              blank3 = {type = "description", name = "\n\n", order = 3.2, },


              reactiveZoomToggle = {
                type = "toggle",
                name = L["Use Reactive Zoom"],
                order = 4,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomEnabled")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "reactiveZoomEnabled")
                  end,
              },

              reactiveZoomGroup = {
                type = "group",
                name = "",
                disabled =
                  function()
                    return not DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomEnabled")
                           or (forSituations and not CheckGroupVars(zoomGroupVars))
                  end,
                order = 5,
                args = {

                  addIncrements = {
                    type = "range",
                    name = L["Quick-Zoom Additional Increments"],
                    desc = L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."],
                    order = 1,
                    width = sliderWidth,
                    min = 0,
                    max = 10,
                    step = 0.1,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomAddIncrements")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "reactiveZoomAddIncrements")
                      end,
                  },
                  addIncrementsReset =
                    CreateSliderResetButton(1.1, forSituations, "reactiveZoomAddIncrements"),
                  blank1 = {type = "description", name = " ", order = 1.2, },

                  incAddDifference = {
                    type = "range",
                    name = L["Quick-Zoom Enter Threshold"],
                    desc = L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."],
                    order = 2,
                    width = sliderWidth,
                    min = 0.1,
                    max = 5,
                    step = 0.1,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomIncAddDifference")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "reactiveZoomIncAddDifference")
                      end,
                  },
                  incAddDifferenceReset =
                    CreateSliderResetButton(2.1, forSituations, "reactiveZoomIncAddDifference"),
                  blank2 = {type = "description", name = " ", order = 2.2, },

                  maxZoomTime = {
                    type = "range",
                    name = L["Maximum Zoom Time"],
                    desc = L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."],
                    order = 3,
                    width = sliderWidth,
                    min = 0.1,
                    max = 5,
                    step = 0.05,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomMaxZoomTime")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "reactiveZoomMaxZoomTime")
                      end,
                  },
                  maxZoomTimeReset = CreateSliderResetButton(3.1, forSituations, "reactiveZoomMaxZoomTime"),
                  blank3 = {type = "description", name = "\n\n", order = 3.2, },

                },
              },

            },
          },

          reactiveZoomDescriptionGroup = {
            type = "group",
            name = L["Help"],
            order = 6,
            inline = true,
            args = {

              toggleVisualAid = {
                type = "execute",
                name = L["Toggle Visual Aid"],
                func = function() DynamicCam:ToggleRZVA() end,
                order = 1,
                width = "full",
              },
              blank1 = {type = "description", name = " ", order = 1.1, },

              reactiveZoomDescription = {
                type = "description",
                name = L["<reactiveZoom_desc>"],
                order = 2,
              },

              blank2 = {type = "description", name = "\n\n", order = 2.1, },

              enhancedMinZoom = {
                type = "toggle",
                name = L["Enhanced minimal zoom-in"],
                desc = L["<enhancedMinZoom_desc>"],
                order = 3,
                width = "full",
                get =
                  function()
                    return DynamicCam.db.profile.reactiveZoomEnhancedMinZoom
                  end,
                set =
                  function(_, newValue)
                    DynamicCam.db.profile.reactiveZoomEnhancedMinZoom = newValue
                  end,
              },

              reloadMessage = {
                type = "description",
                name = "|cFFFF0000" .. L["/reload of the UI required!"] .. "|r",
                hidden =
                  function()
                    return DynamicCam.modelFrame and DynamicCam.db.profile.reactiveZoomEnhancedMinZoom or not DynamicCam.modelFrame and not DynamicCam.db.profile.reactiveZoomEnhancedMinZoom
                  end,
                order = 4,
              },
              blank4 = {
                type = "description",
                name = " ",
                hidden =
                  function()
                    return not DynamicCam.modelFrame and DynamicCam.db.profile.reactiveZoomEnhancedMinZoom or DynamicCam.modelFrame and not DynamicCam.db.profile.reactiveZoomEnhancedMinZoom
                  end,
                order = 4, },

            },
          },
        },
      },  -- /zoomGroup


      mouseLookGroup = {
        type = "group",
        name =
          function()
            return ColoredNames(L["Mouse Look"], mouseLookGroupVars, forSituations)
          end,
        order = 2,
        args = {

          overriddenText = CreateOverriddenText(mouseLookGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(mouseLookGroupVars, forSituations),
          blank0 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },

          mouseLookSubGroup = {
            type = "group",
            name = "",
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(mouseLookGroupVars)
              end,
            args = {

              cameraYawMoveSpeed = {
                type = "range",
                name = L["Horizontal Speed"],
                desc = L["How much the camera yaws horizontally when in mouse look mode."] .. "\n|cff909090cvar: cameraYawMoveSpeed|r",
                order = 1,
                width = sliderWidth + 0.1,
                min = 1,
                max = 360,
                step = 1,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "cameraYawMoveSpeed")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "cameraYawMoveSpeed")
                  end,
              },
              cameraYawMoveSpeedReset =
                CreateSliderResetButton(1.1, forSituations, "cvars", "cameraYawMoveSpeed"),
              blank1 = {type = "description", name = " ", order = 1.2, },

              cameraPitchMoveSpeed = {
                type = "range",
                name = L["Vertical Speed"],
                desc = L["How much the camera pitches vertically when in mouse look mode."] .. "\n|cff909090cvar: cameraPitchMoveSpeed|r",
                order = 2,
                width = sliderWidth + 0.1,
                min = 1,
                max = 360,
                step = 1,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "cameraPitchMoveSpeed")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "cameraPitchMoveSpeed")
                  end,
              },
              cameraPitchMoveSpeedReset =
                CreateSliderResetButton(2.1, forSituations, "cvars", "cameraPitchMoveSpeed"),
              blank2 = {type = "description", name = "\n\n", order = 2.2, },

              mouseLookDescriptionGroup = {
                type = "group",
                name = L["Help"],
                order = 3,
                args = {
                  mouseLookDescription = {
                    type = "description",
                    name = L["<mouseLook_desc>"],
                  },
                },
              },
            },
          },
        },
      },  -- /mouseLookGroup


      shoulderOffsetGroup = {

        type = "group",
        name =
          function()
            return ColoredNames(L["Horizontal Offset"], shoulderOffsetGroupVars, forSituations)
          end,
        order = 3,
        args = {

          overriddenText = CreateOverriddenText(shoulderOffsetGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(shoulderOffsetGroupVars, forSituations),
          blank0 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },

          shoulderOffsetSubGroup = {
            type = "group",
            name = "",
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(shoulderOffsetGroupVars)
              end,
            args = {

              cameraOverShoulderGroup = {
                type = "group",
                name = L["Camera Over Shoulder Offset"],
                order = 1,
                args = {

                  cameraOverShoulderDescription = {
                    type = "description",
                    name = L["Positions the camera left or right from your character."] .. "\n|cff909090cvar: test_cameraOverShoulder|r\n\n" .. L["<cameraOverShoulder_desc>"],
                    order = 0,
                  },

                  cameraOverShoulder = {
                    type = "range",
                    name = "",
                    order = 1,
                    width = sliderWidth - 0.15,
                    min = -15,
                    max = 15,
                    step = 0.1,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraOverShoulder")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraOverShoulder")
                      end,
                  },
                  cameraOverShoulderReset = CreateSliderResetButton(1.1, forSituations, "cvars", "test_cameraOverShoulder"),
                },
              },
              blank1 = {type = "description", name = " ", order = 1.1, },

              shoulderOffsetZoomGroup = {
                type = "group",
                name = L["Adjust shoulder offset according to zoom level"],
                order = 2,
                args = {

                  shoulderOffsetZoomEnabled = {
                    type = "toggle",
                    name = L["Enable"],
                    order = 1,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "shoulderOffsetZoomEnabled")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "shoulderOffsetZoomEnabled")
                      end,
                  },
                  blank1 = {type = "description", name = " ", width = sliderWidth - 1.15, order = 1.1, },
                  -- Make a custom reset button, because we need to reset both values at once.
                  shoulderOffsetZoomReset = {
                    type = "execute",
                    name = L["Reset"],
                    image = "Interface\\Transmogrify\\Transmogrify",
                    imageCoords = resetButtonImageCoords,
                    imageWidth = 25/1.5,
                    imageHeight = 24/1.5,
                    desc = L["Reset to global default"] .. ": " .. DynamicCam:GetSettingsDefault("shoulderOffsetZoomLowerBound") .. " " .. L["and"] .. " " .. DynamicCam:GetSettingsDefault("shoulderOffsetZoomUpperBound") .. "\n" .. L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"],
                    order = 1.2,
                    width = 0.25,
                    func =
                      function()
                        DynamicCam:SetSettingsDefault(forSituations and SID, "shoulderOffsetZoomLowerBound")
                        DynamicCam:SetSettingsDefault(forSituations and SID, "shoulderOffsetZoomUpperBound")
                      end,
                    disabled =
                      function()
                        return
                        (DynamicCam:GetSettingsValue(forSituations and SID, "shoulderOffsetZoomLowerBound") == DynamicCam:GetSettingsDefault( "shoulderOffsetZoomLowerBound")
                        and
                        DynamicCam:GetSettingsValue(forSituations and SID, "shoulderOffsetZoomUpperBound") == DynamicCam:GetSettingsDefault("shoulderOffsetZoomUpperBound"))
                        or not DynamicCam:GetSettingsValue(forSituations and SID, "shoulderOffsetZoomEnabled")
                      end,
                  },

                  shoulderOffsetZoomLowerBound = {
                    type = "range",
                    name = L["No offset when below this zoom level:"],
                    order = 2,
                    width = "full",
                    desc = L["When the camera is closer than this zoom level, the offset has reached zero."],
                    min = 0.8,
                    max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                    step = 0.1,
                    disabled =
                      function(info)
                        return GetInheritedDisabledStatus(info) or not DynamicCam:GetSettingsValue(forSituations and SID, "shoulderOffsetZoomEnabled")
                      end,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "shoulderOffsetZoomLowerBound")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "shoulderOffsetZoomLowerBound")
                        if DynamicCam:GetSettingsValue(forSituations and SID, "shoulderOffsetZoomUpperBound") < newValue then
                          DynamicCam:SetSettingsValue(newValue, forSituations and SID, "shoulderOffsetZoomUpperBound")
                        end
                      end,
                  },
                  blank2 = {type = "description", name = " ", order = 2.2, },

                  shoulderOffsetZoomUpperBound = {
                    type = "range",
                    name = L["Real offset when above this zoom level:"],
                    order = 3,
                    width = "full",
                    desc = L["When the camera is further away than this zoom level, the offset has reached its set value."],
                    min = 0.8,
                    max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                    step = 0.1,
                    disabled =
                      function(info)
                        return GetInheritedDisabledStatus(info) or not DynamicCam:GetSettingsValue(forSituations and SID, "shoulderOffsetZoomEnabled")
                      end,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "shoulderOffsetZoomUpperBound")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "shoulderOffsetZoomUpperBound")
                        if DynamicCam:GetSettingsValue(forSituations and SID, "shoulderOffsetZoomLowerBound") > newValue then
                          DynamicCam:SetSettingsValue(newValue, forSituations and SID, "shoulderOffsetZoomLowerBound")
                        end
                      end,
                  },
                  blank3 = {type = "description", name = " ", order = 3.1, },

                  shoulderOffsetZoomDescription = {
                    type = "description",
                    name = L["<shoulderOffsetZoom_desc>"],
                    order = 4,
                  },

                },
              },
            },
          },
        },
      },  -- shoulderOffsetGroup


      pitchGroup = {

        type = "group",
        name =
          function()
            return ColoredNames(L["Vertical Pitch"], pitchGroupVars, forSituations)
          end,
        order = 4,
        args = {

          overriddenText = CreateOverriddenText(pitchGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(pitchGroupVars, forSituations),
          blank0 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },

          pitchSubGroup = {
            type = "group",
            name = "",
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(pitchGroupVars)
              end,
            args = {

              cameraDynamicPitch = {
                type = "toggle",
                name = L["Enable"],
                order = 1,
                width = "full",
                desc = "|cff909090cvar: test_cameraDynamicPitch|r",
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 1
                  end,
                set =
                  function(_, newValue)
                    if newValue then
                      DynamicCam:SetSettingsValue(1, forSituations and SID, "cvars", "test_cameraDynamicPitch")
                    else
                      DynamicCam:SetSettingsValue(0, forSituations and SID, "cvars", "test_cameraDynamicPitch")
                    end
                  end,
              },
              blank1 = {type = "description", name = " ", order = 1.1, },

              baseFovPad = {
                type = "range",
                name = L["Pitch (on ground)"],
                order = 2,
                width = sliderWidth,
                desc = "|cff909090cvar: test_cameraDynamicPitch\nBaseFovPad|r",
                min = 0,
                max = 0.99,
                step = 0.01,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPad")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPad")
                  end,
              },
              baseFovPadReset =
                CreateSliderResetButton(2.1, forSituations, "cvars", "test_cameraDynamicPitchBaseFovPad"),
              blank2 = {type = "description", name = " ", order = 2.2, },

              baseFovPadFlying = {
                type = "range",
                name = L["Pitch (flying)"],
                order = 3,
                width = sliderWidth,
                desc = "|cff909090cvar: test_cameraDynamicPitch\nBaseFovPadFlying|r",
                min = 0,
                max = 1,
                step = 0.01,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPadFlying")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPadFlying")
                  end,
              },
              baseFovPadFlyingReset =
                CreateSliderResetButton(3.1, forSituations, "cvars", "test_cameraDynamicPitchBaseFovPadFlying"),
              blank3 = {type = "description", name = "\n\n", order = 3.2, },

              baseFovPadDownScale = {
                type = "range",
                name = L["Down Scale"],
                order = 4,
                width = sliderWidth,
                desc = "|cff909090cvar: test_cameraDynamicPitch\nBaseFovPadDownScale|r",
                min = 0,
                max = 1,
                step = 0.01,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPadDownScale")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPadDownScale")
                  end,
              },
              baseFovPadDownScaleReset =
                CreateSliderResetButton(4.1, forSituations, "cvars", "test_cameraDynamicPitchBaseFovPadDownScale"),
              blank4 = {type = "description", name = "\n\n", order = 4.2, },

              smartPivotCutoffDist = {
                type = "range",
                name = L["Smart Pivot Cutoff Distance"],
                order = 5,
                width = sliderWidth,
                desc = "|cff909090cvar: test_cameraDynamicPitch\nSmartPivotCutoffDist|r",
                min = 0,
                max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                step = 0.5,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitchSmartPivotCutoffDist")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraDynamicPitchSmartPivotCutoffDist")
                  end,
              },
              smartPivotCutoffDistReset =
                CreateSliderResetButton(5.1, forSituations, "cvars", "test_cameraDynamicPitchSmartPivotCutoffDist"),
              blank5 = {type = "description", name = " ", order = 5.2, },

              pitchDescriptionGroup = {
                type = "group",
                name = L["Help"],
                order = 6,
                args = {
                  pitchDescription = {
                    type = "description",
                    name = L["<pitch_desc>"],
                  },
                },
              },
            },
          },
        },
      },  -- /pitchGroup


      targetFocusGroup = {

        type = "group",
        name =
          function()
            return ColoredNames(L["Target Focus"], targetFocusGroupVars, forSituations)
          end,
        order = 5,
        args = {

          overriddenText = CreateOverriddenText(targetFocusGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(targetFocusGroupVars, forSituations),
          blank0 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },

          targetFocusSubGroup = {
            type = "group",
            name = "",
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(targetFocusGroupVars)
              end,
            args = {

              targetFocusEnemiesGroup = {
                type = "group",
                name = L["Enemy Target"],
                order = 1,
                args = {

                  targetFocusEnemyEnable = {
                    type = "toggle",
                    name = L["Enable"],
                    order = 1,
                    width = "full",
                    desc = "|cff909090cvar: test_cameraTargetFocus\nEnemyEnable|r",
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable") == 1
                      end,
                    set =
                      function(_, newValue)
                        if newValue then
                          DynamicCam:SetSettingsValue(1, forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable")
                        else
                          DynamicCam:SetSettingsValue(0, forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable")
                        end
                      end,
                  },

                  targetFocusEnemyStrengthYaw = {
                    type = "range",
                    name = L["Horizontal Strength"],
                    order = 2,
                    width = sliderWidth - 0.15,
                    desc = "|cff909090cvar: test_cameraTargetFocus\nEnemyStrengthYaw|r",
                    min = 0,
                    max = 1,
                    step = 0.05,
                    disabled =
                      function(info)
                        return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable") == 0
                      end,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyStrengthYaw")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraTargetFocusEnemyStrengthYaw")
                      end,
                  },
                  targetFocusEnemyStrengthYawReset =
                    CreateSliderResetButton(2.1, forSituations, "cvars", "test_cameraTargetFocusEnemyStrengthYaw"),
                  blank2 = {type = "description", name = " ", order = 2.2, },

                  targetFocusEnemyStrengthPitch = {
                    type = "range",
                    name = L["Vertical Strength"],
                    order = 3,
                    width = sliderWidth - 0.15,
                    desc = "|cff909090cvar: test_cameraTargetFocus\nEnemyStrengthPitch|r",
                    min = 0,
                    max = 1,
                    step = 0.05,
                    disabled =
                      function(info)
                        return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable") == 0
                      end,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyStrengthPitch")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraTargetFocusEnemyStrengthPitch")
                      end,
                  },
                  targetFocusEnemyStrengthPitchReset =
                    CreateSliderResetButton(3.1, forSituations, "cvars", "test_cameraTargetFocusEnemyStrengthPitch"),
                },
              },
              blank1 = {type = "description", name = " ", order = 1.1,},

              targetFocusNPCsGroup = {
                type = "group",
                name = L["Interaction Target (NPCs)"],
                order = 2,
                args = {

                  targetFocusInteractEnable = {
                    type = "toggle",
                    name = L["Enable"],
                    order = 1,
                    width = sliderWidth - 0.15,
                    desc = "|cff909090cvar: test_cameraTargetFocus\nInteractEnable|r",
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable") == 1
                      end,
                    set =
                      function(_, newValue)
                        if newValue then
                          DynamicCam:SetSettingsValue(1, forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable")
                        else
                          DynamicCam:SetSettingsValue(0, forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable")
                        end
                      end,
                  },

                  targetFocusInteractStrengthYaw = {
                    type = "range",
                    name = L["Horizontal Strength"],
                    order = 2,
                    width = sliderWidth - 0.15,
                    desc = "|cff909090cvar: test_cameraTargetFocus\nInteractStrengthYaw|r",
                    min = 0,
                    max = 1,
                    step = 0.05,
                    disabled =
                      function(info)
                        return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable") == 0
                      end,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractStrengthYaw")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraTargetFocusInteractStrengthYaw")
                      end,
                  },
                  targetFocusInteractStrengthYawReset =
                    CreateSliderResetButton(2.1, forSituations, "cvars", "test_cameraTargetFocusInteractStrengthYaw"),
                  blank2 = {type = "description", name = " ", order = 2.2, },

                  targetFocusInteractStrengthPitch = {
                    type = "range",
                    name = L["Vertical Strength"],
                    order = 3,
                    width = sliderWidth - 0.15,
                    desc = "|cff909090cvar: test_cameraTargetFocus\nInteractStrengthPitch|r",
                    min = 0,
                    max = 1,
                    step = 0.05,
                    disabled =
                      function(info)
                        return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable") == 0
                      end,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractStrengthPitch")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraTargetFocusInteractStrengthPitch")
                      end,
                  },
                  targetFocusInteractStrengthPitchReset =
                    CreateSliderResetButton(3.1, forSituations, "cvars", "test_cameraTargetFocusInteractStrengthPitch"),
                },
              },

              blank2 = {type = "description", name = " ", order = 2.1, },

              targetFocusDescriptionGroup = {
                type = "group",
                name = L["Help"],
                order = 3,
                args = {
                  targetFocusDescription = {
                    type = "description",
                    name = L["<targetFocus_desc>"],
                  },
                },
              },
            },
          },
        },
      },  -- /targetFocusGroup


      headTrackingGroup = {

        type = "group",
        name =
          function()
            return ColoredNames(L["Head Tracking"], headTrackingGroupVars, forSituations)
          end,
        order = 6,
        args = {

          overriddenText = CreateOverriddenText(headTrackingGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(headTrackingGroupVars, forSituations),
          blank0 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },

          headTrackingSubGroup = {
            type = "group",
            name = "",
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(headTrackingGroupVars)
              end,
            args = {

              headTrackingEnable = {
                type = "toggle",
                name = L["Enable"],
                order = 1,
                width = sliderWidth - 0.15,
                desc = "|cff909090cvar: test_cameraHeadMovementStrength\n\n" .. L["<headTrackingEnable_desc>"] .. "|r",
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 1
                  end,
                set =
                  function(_, newValue)
                    if newValue then
                      DynamicCam:SetSettingsValue(1, forSituations and SID, "cvars", "test_cameraHeadMovementStrength")
                    else
                      DynamicCam:SetSettingsValue(0, forSituations and SID, "cvars", "test_cameraHeadMovementStrength")
                    end
                  end,
              },
              blank1 = {type = "description", name = " ", order = 1.1, },

              standingStrength = {
                type = "range",
                order = 2,
                width = sliderWidth,
                name = L["Strength (standing)"],
                desc = "|cff909090cvar: test_cameraHeadMovement\nStandingStrength|r",
                min = 0,
                max = 1,   -- No effect above 1.
                step = 0.01,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStandingStrength")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementStandingStrength")
                  end,
              },
              standingStrengthReset =
                CreateSliderResetButton(2.1, forSituations, "cvars", "test_cameraHeadMovementStandingStrength"),
              blank2 = {type = "description", name = " ", order = 2.2, },

              standingDampRate = {
                type = "range",
                order = 3,
                width = sliderWidth,
                name = L["Inertia (standing)"],
                desc = "|cff909090cvar: test_cameraHeadMovement\nStandingDampRate|r",
                min = 0,
                max = 20,
                step = 0.05,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end,
                get =
                  function()
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStandingDampRate") == 0.01 then
                      return 0
                    else
                      return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStandingDampRate")
                    end
                  end,
                set =
                  function(_, newValue)
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if newValue == 0 then newValue = 0.01 end
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementStandingDampRate")
                  end,
              },
              standingDampRateReset =
                CreateSliderResetButton(3.1, forSituations, "cvars", "test_cameraHeadMovementStandingDampRate"),
              blank3 = {type = "description", name = "\n\n", order = 3.2, },

              movingStrength = {
                type = "range",
                order = 4,
                width = sliderWidth,
                name = L["Strength (moving)"],
                desc = "|cff909090cvar: test_cameraHeadMovement\nMovingStrength|r",
                min = 0,
                max = 1,   -- No effect above 1.
                step = 0.01,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementMovingStrength")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementMovingStrength")
                  end,
              },
              movingStrengthReset =
                CreateSliderResetButton(4.1, forSituations, "cvars", "test_cameraHeadMovementMovingStrength"),
              blank4 = {type = "description", name = " ", order = 4.2, },

              movingDampRate = {
                type = "range",
                order = 5,
                width = sliderWidth,
                name = L["Inertia (moving)"],
                desc = "|cff909090cvar: test_cameraHeadMovement\nMovingDampRate|r",
                min = 0,
                max = 20,
                step = 0.05,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end,
                get =
                  function()
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementMovingDampRate") == 0.01 then
                      return 0
                    else
                      return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementMovingDampRate")
                    end
                  end,
                set =
                  function(_, newValue)
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if newValue == 0 then newValue = 0.01 end
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementMovingDampRate")
                  end,
              },
              movingDampRateReset =
                  CreateSliderResetButton(5.1, forSituations, "cvars", "test_cameraHeadMovementMovingDampRate"),
              blank5 = {type = "description", name = "\n\n", order = 5.2, },

              firstPersonDampRate = {
                type = "range",
                order = 6,
                width = sliderWidth,
                name = L["Inertia (first person)"],
                desc = "|cff909090cvar: test_cameraHeadMovement\nFirstPersonDampRate|r",
                min = 0,
                max = 20,
                step = 0.05,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end,
                get =
                  function()
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementFirstPersonDampRate") == 0.01 then
                      return 0
                    else
                      return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementFirstPersonDampRate")
                    end
                  end,
                set =
                  function(_, newValue)
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if newValue == 0 then newValue = 0.01 end
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementFirstPersonDampRate")
                  end,
              },
              firstPersonDampRateReset =
                CreateSliderResetButton(6.1, forSituations, "cvars", "test_cameraHeadMovementFirstPersonDampRate"),
              blank6 = {type = "description", name = "\n\n", order = 6.2, },

              rangeScale = {
                type = "range",
                order = 7,
                width = sliderWidth,
                name = L["Range Scale"],
                desc = L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] .. "\n|cff909090cvar: test_ cameraHeadMovementRangeScale\n" .. L["(slider value transformed)"] .. "|r",
                min = 0,
                max = 117,
                step = 0.5,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end,
                get =
                  function()
                    return (DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementRangeScale")  * 3.25) + 0.1625
                  end,
                set =
                  function(_, newValue)
                    newValue = (newValue - 0.1625) / 3.25
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementRangeScale")
                  end,
              },
              rangeScaleReset =
                CreateSliderResetButton(7.1, forSituations, "cvars", "test_cameraHeadMovementRangeScale",
                                        Round((DynamicCam:GetSettingsDefault("cvars", "test_cameraHeadMovementRangeScale") * 3.25) + 0.1625, 2)),
              blank7 = {type = "description", name = "\n\n", order = 7.2, },

              deadZone = {
                type = "range",
                order = 8,
                width = sliderWidth,
                name = L["Dead Zone"],
                desc = L["Radius of head movement not affecting the camera. (See explanation below.)"] .. "\n|cff909090cvar: test_ cameraHeadMovementDeadZone\n" .. L["(slider value devided by 10)"] .. "|r\n|cffe00000" .. L["Requires /reload to come into effect!"] .. "|r",
                min = 0,
                max = 10,
                step = 0.05,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementDeadZone") * 10
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue / 10, forSituations and SID, "cvars", "test_cameraHeadMovementDeadZone")
                  end,
              },
              deadZoneReset =
                CreateSliderResetButton(8.1, forSituations, "cvars", "test_cameraHeadMovementDeadZone",
                                            Round(DynamicCam:GetSettingsDefault("cvars", "test_cameraHeadMovementDeadZone") * 10, 2)),


              headTrackingDescriptionGroup = {
                type = "group",
                name = L["Help"],
                order = 9,
                args = {
                  headTrackingDescription = {
                    type = "description",
                    name = L["<headTracking_desc>"],
                  },
                },
              },
            },
          },
        },
      },  -- /headTrackingGroup

    },  -- /args
  }
end


local function CreateSituationSettingsTab(tabOrder)

  local returnOptions = {

    type = "group",
    name = L["Situations"],
    order = tabOrder,

    childGroups = "tab",

    args = {

      selectedSituation = {
        type = "select",
        name = L["Select a situation to setup"],
        desc = L["<selectedSituation_desc>"],
        get =
          function()
            lastSelectedSID = SID
            return SID
          end,
        set =
          function(_, newValue)
            S = DynamicCam.db.profile.situations[newValue]
            SID = newValue
            lastSelectedSID = newValue
          end,
        values =
          function()
            return GetSituationList()
          end,
        width = 2.2,
        order = 1,
      },
      blank1 = {type = "description", name = " ", width = 0.1, order = 1.5, },

      enabled = {
        type = "toggle",
        name = L["Enable"],
        desc =
          function()
            return L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."]:format(S.name)
          end,
        disabled =
          function()
            return not S
          end,
        get =
          function()
            return S.enabled
          end,
        set =
          function(_, newValue)
            S.enabled = newValue
            if newValue then
              DynamicCam:UpdateSituation(SID)
            else
              DynamicCam:EvaluateSituations()
            end
          end,
        width = 0.7,
        order = 2,
      },
      blank2 = {type = "description", name = " ", width = 0.1, order = 2.5, },

      deleteCustom = {
        type = "execute",
        name = "-",
        desc =
          function()
            return L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"]:format(S.name)
          end,
        hidden =
          function()
            return not S or not string.find(SID, "custom")
          end,
        func =
          function()
            DynamicCam:DeleteCustomSituation(SID)
          end,
        order = 3,
        width = 0.23,
      },
      deleteCustomPlaceholder = {
        type = "description",
        name = " ",
        hidden =
          function()
            return S and string.find(SID, "custom")
          end,
        width = 0.23,
        order = 3,
      },
      blank3 = {type = "description", name = " ", width = 0.03, order = 3.5, },

      newSituation = {
        type = "execute",
        name = "+",
        desc = L["Create a new custom situation."],
        func = function() DynamicCam:PopupCreateCustomProfile() end,
        order = 4,
        width = 0.23,
      },


      situationSettings = CreateSettingsTab(5, true),


      situationActions = {

        type = "group",
        name = L["Situation Actions"],
        order = 6,

        args = {

          help = {
            type = "description",
            name = L["Setup stuff to happen while in a situation or when entering/exiting it."] .. "\n\n",
            order = 0,
          },

          viewZoomSettings = {
            type = "group",
            name =
              function()
                return GreyWhenInactive(L["Zoom/View"], S.viewZoom.enabled)
              end,
            order = 1,
            args = {

              viewZoomToggle = {
                type = "toggle",
                name = L["Enable"],
                desc = L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."],
                get =
                  function()
                    return S.viewZoom.enabled
                  end,
                set =
                  function(_, newValue)
                    S.viewZoom.enabled = newValue
                  end,
                order = 1,
              },
              viewZoomReset = {
                type = "execute",
                -- name = CreateAtlasMarkup("transmog-icon-revert-small", 20, 20),
                name = L["Reset"],
                image = "Interface\\Transmogrify\\Transmogrify",
                imageCoords = resetButtonImageCoords,
                imageWidth = 25/1.5,
                imageHeight = 24/1.5,
                desc = L["Reset to global default"] .. "!\n" .. L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"],
                order = 1.5,
                width = 0.25,
                func =
                  function()
                    for k in pairs(S.viewZoom) do
                      if k ~= "enabled" and k ~= "viewZoomType" then
                        S.viewZoom[k] = DynamicCam.situationDefaults.viewZoom[k]
                      end
                    end
                  end,
                disabled =
                  function()
                    for k in pairs(S.viewZoom) do
                      if k ~= "enabled" and k ~= "viewZoomType" and S.viewZoom[k] ~= DynamicCam.situationDefaults.viewZoom[k] then
                        return false
                      end
                    end
                    return true
                  end,
              },

              viewZoomGroup = {
                type = "group",
                name = "",
                order = 2,
                disabled =
                  function()
                    return not S.viewZoom.enabled
                  end,
                inline = true,
                args = {

                  viewZoomType = {
                    type = "select",
                    name = L["Set Zoom or Set View"],
                    desc = "\n" .. L["<viewZoomType_desc>"],
                    width = "full",
                    disabled =
                      function()
                        return not S.viewZoom.enabled
                      end,
                    get =
                      function()
                        return S.viewZoom.viewZoomType
                      end,
                    set =
                      function(_, newValue)
                        S.viewZoom.viewZoomType = newValue
                      end,
                    values = {
                      ["zoom"] = L["Set Zoom"],
                      ["view"] = L["Set View"],
                    },
                    sorting = {
                      "zoom",
                      "view",
                    },
                    order = 2,
                  },
                  blank2 = {type = "description", name = " ", order = 2.1, },


                  viewBox = {

                    type = "group",
                    name = L["Set View"],
                    order = 3,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "view"
                      end,
                    args = {

                      view = {
                        type = "select",
                        name = L["Set view to saved view:"],
                        desc = L["Select the saved view to switch to when entering this situation."],
                        get =
                          function()
                            return S.viewZoom.viewNumber
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.viewNumber = newValue
                          end,
                        values = {
                          [2] = "View 2",
                          [3] = "View 3",
                          [4] = "View 4",
                          [5] = "View 5"
                        },
                        order = 1,
                        width = 0.8,
                      },
                      blank1 = {type = "description", name = " ", order = 1.1, width = 0.1, },
                      instant = {
                        type = "toggle",
                        name = L["Instant"],
                        desc = L["Make view transitions instant."],
                        get =
                          function()
                            return S.viewZoom.viewInstant
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.viewInstant = newValue
                          end,
                        order = 2,
                        width = "half",
                      },

                      viewRestore = {
                        type = "toggle",
                        name = L["Restore view when exiting"],
                        desc = L["When exiting the situation restore the camera position to what it was at the time of entering the situation."],
                        hidden =
                          function()
                            return GetCVar("cameraSmoothStyle") ~= "0"
                          end,
                        get =
                          function()
                            return S.viewZoom.viewRestore
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.viewRestore = newValue
                          end,
                        order = 3,
                        width = "full",
                      },

                      cameraSmoothNote = {
                        type = "description",
                        hidden =
                          function()
                            return GetCVar("cameraSmoothStyle") == "0"
                          end,
                        order = 4,
                        name = L["cameraSmoothNote"],
                      },

                      viewRestoreToDefault = {
                        type = "select",
                        name = L["Restore to default view:"],
                        desc = L["<viewRestoreToDefault_desc>"],
                        hidden =
                          function()
                            return GetCVar("cameraSmoothStyle") == "0"
                          end,
                        get =
                          function()
                            return S.viewZoom.restoreDefaultViewNumber
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.restoreDefaultViewNumber = newValue
                          end,
                        values = {
                          [1] = "View 1",
                          [2] = "View 2",
                          [3] = "View 3",
                          [4] = "View 4",
                          [5] = "View 5"
                        },
                        order = 5,
                        width = "full",
                      },

                      cameraSmoothWarning = {
                        type = "description",
                        hidden =
                          function ()
                            if GetCVar("cameraSmoothStyle") == "0" then return true end

                            local usedViews, usedDefaultViews = GetUsedViews()

                            for usedView in pairs(usedViews) do
                              -- We know that at least one other situation used this view.
                              if usedDefaultViews[usedView] then
                                -- print("View", usedView, "used as saved and default view.")
                                return false
                              end
                            end
                            return true
                          end,

                        order = 6,
                        name =
                          function()
                            if GetCVar("cameraSmoothStyle") == "0" then return "" end

                            local usedViews, usedDefaultViews = GetUsedViews()

                            local returnString = "|cFFEE0000" .. L["WARNING"] .. ":|r" .. L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] .. "\n"

                            for usedView, usedViewSituationList in pairs(usedViews) do

                              -- We know that at least one other situation used this view.
                              if usedDefaultViews[usedView] then

                                local savedViewSituations = ""
                                for usedViewSituationId in pairs(usedViewSituationList) do
                                  savedViewSituations = savedViewSituations .. "    - " .. DynamicCam.db.profile.situations[usedViewSituationId].name .. "\n"
                                end
                                
                                local restoreToDefaultSituations = ""
                                for usedDefaultViewSituationId in pairs(usedDefaultViews[usedView]) do
                                  restoreToDefaultSituations = restoreToDefaultSituations .. "    - " ..  DynamicCam.db.profile.situations[usedDefaultViewSituationId].name .. "\n"
                                end
                                
                                
                                returnString = returnString .. "\n\n" .. L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"]:format(usedView, savedViewSituations, restoreToDefaultSituations) .. "\n"


                                

                              end
                            end

                            return returnString
                          end,
                      },
                    },
                  },
                  viewBlank = {type = "description", name = " ", order = 3.1, },

                  viewDescriptionGroup = {
                    type = "group",
                    name = L["Help"],
                    order = 4,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "view"
                      end,
                    args = {
                      viewDescription = {
                        type = "description",
                        name = L["<view_desc>"],
                      },
                    },
                  },


                  zoomBox = {
                    type = "group",
                    name = L["Set Zoom"],
                    order = 3,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                    args = {

                      transitionTime = {
                        type = "range",
                        name = L["Zoom Transition Time"],
                        desc = L["<transitionTime_desc>"],
                        min = 0,
                        max = 5,
                        step = .05,
                        get =
                          function()
                            return S.viewZoom.zoomTransitionTime
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.zoomTransitionTime = newValue
                          end,
                        width = "full",
                        order = 1,
                      },
                      blank1 = {type = "description", name = "\n\n", order = 1.2, },

                      zoomType = {
                        type = "select",
                        name = L["Zoom Type"],
                        desc = L["<zoomType_desc>"],
                        width = 0.8,
                        get =
                          function()
                            return S.viewZoom.zoomType
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.zoomType = newValue
                          end,
                        values = {
                          ["set"] = L["Set"],
                          ["out"] = L["Out"],
                          ["in"] = L["In"],
                          ["range"] = L["Range"],
                        },
                        sorting = {
                          "set",
                          "out",
                          "in",
                          "range",
                        },
                        order = 2,
                      },
                      blank2 = {type = "description", name = " ", order = 2.1, width = 0.2, },

                      zoomTimeIsMaxToggle = {
                        type = "toggle",
                        name = L["Don't slow"],
                        desc = L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."],
                        get =
                          function()
                            return S.viewZoom.zoomTimeIsMax
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.zoomTimeIsMax = newValue
                          end,
                        width = 0.8,
                        order = 2.2,
                      },
                      blank22 = {type = "description", name = " ", order = 2.5, },

                      zoomValue = {
                        type = "range",
                        name = L["Zoom Value"],
                        desc =
                          function()
                            if S.viewZoom.zoomType == "set" then
                              return L["Zoom to this zoom level."]
                            elseif S.viewZoom.zoomType == "out" then
                              return L["Zoom out to this zoom level, if the current zoom level is less than this."]
                            elseif S.viewZoom.zoomType == "in" then
                              return L["Zoom in to this zoom level, if the current zoom level is greater than this."]
                            end
                          end,
                        width = "full",
                        hidden =
                          function()
                            return S.viewZoom.zoomType == "range"
                          end,
                        min = 0,
                        max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                        step = .5,
                        get =
                          function()
                            return S.viewZoom.zoomValue
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.zoomValue = newValue
                          end,
                        order = 3,
                      },

                      zoomMin = {
                        type = "range",
                        name = L["Zoom Min"],
                        desc = L["Zoom out to this zoom level, if the current zoom level is less than this."],
                        width = "full",
                        hidden =
                          function()
                            return S.viewZoom.zoomType ~= "range"
                          end,
                        min = 0,
                        max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                        step = .5,
                        get =
                          function()
                            return S.viewZoom.zoomMin
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.zoomMin = newValue
                            if S.viewZoom.zoomMin > S.viewZoom.zoomMax then
                              S.viewZoom.zoomMax = S.viewZoom.zoomMin
                            end
                          end,
                        order = 3,
                      },
                      blank3 = {
                        type = "description",
                        name = " ",
                        order = 3.1,
                        hidden =
                          function()
                            return S.viewZoom.zoomType ~= "range"
                          end,
                      },
                      zoomMax = {
                        type = "range",
                        name = L["Zoom Max"],
                        desc = L["Zoom in to this zoom level, if the current zoom level is greater than this."],
                        width = "full",
                        hidden =
                          function()
                            return S.viewZoom.zoomType ~= "range"
                          end,
                        min = 0,
                        max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                        step = .5,
                        get =
                          function()
                            return S.viewZoom.zoomMax
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.zoomMax = newValue
                            if S.viewZoom.zoomMax < S.viewZoom.zoomMin then
                              S.viewZoom.zoomMin = S.viewZoom.zoomMax
                            end
                          end,
                        order = 4,
                      },

                    },

                  },
                  zoomBlank1 = {
                    type = "description",
                    name = " ",
                    order = 3.1,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                  },

                  zoomRestoreSettingGroup = {
                    type = "group",
                    name = L["Restore Zoom"],
                    order = 4,
                    disabled = false,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                    args = {

                      zoomRestoreSettingDescription = {
                        type = "description",
                        name = L["<zoomRestoreSetting_desc>"],
                        order = 0,
                      },

                      zoomRestoreSettingSelect = {
                        type = "select",
                        name = L["Restore Zoom Mode"],
                        desc = L["<zoomRestoreSettingSelect_desc>"],
                        order = 1,
                        width = "full",
                        get =
                          function()
                            return DynamicCam.db.profile.zoomRestoreSetting
                          end,
                        set =
                          function(_, newValue)
                            DynamicCam.db.profile.zoomRestoreSetting = newValue
                          end,
                        values = {
                          ["never"] = L["Never"],
                          ["always"] = L["Always"],
                          ["adaptive"] = L["Adaptive"],
                        },
                        sorting = {
                          "never",
                          "always",
                          "adaptive",
                        },
                      },

                    },
                  },
                  zoomBlank2 = {
                    type = "description",
                    name = " ",
                    order = 4.1,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                  },

                  zoomDescriptionGroup = {
                    type = "group",
                    name = L["Help"],
                    order = 5,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                    args = {
                      zoomDescription = {
                        type = "description",
                        name = L["<zoom_desc>"],
                      },
                    },
                  },

                },
              },

            },

          },


          rotationSettings = {
            type = "group",
            name =
              function()
                return GreyWhenInactive(L["Rotation"], S.rotation.enabled)
              end,
            order = 2,
            args = {

              rotationToggle = {
                type = "toggle",
                name = L["Enable"],
                desc = L["Start a camera rotation when this situation is active."],
                get =
                  function()
                    return S.rotation.enabled
                  end,
                set =
                  function(_, newValue)
                    S.rotation.enabled = newValue
                    ApplyContinuousRotation()
                  end,
                order = 1,
              },
              rotationReset = {
                type = "execute",
                -- name = CreateAtlasMarkup("transmog-icon-revert-small", 20, 20),
                name = L["Reset"],
                image = "Interface\\Transmogrify\\Transmogrify",
                imageCoords = resetButtonImageCoords,
                imageWidth = 25/1.5,
                imageHeight = 24/1.5,
                desc = L["Reset to global default"] .. "!\n" .. L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"],
                order = 1.5,
                width = 0.25,
                func =
                  function()
                    for k in pairs(S.rotation) do
                      if k ~= "enabled" then
                        S.rotation[k] = DynamicCam.situationDefaults.rotation[k]
                      end
                    end
                    ApplyContinuousRotation()
                  end,
                disabled =
                  function()
                    for k in pairs(S.rotation) do
                      if k ~= "enabled" and S.rotation[k] ~= DynamicCam.situationDefaults.rotation[k] then
                        return false
                      end
                    end
                    return true
                  end,
              },

              rotationGroup = {
                type = "group",
                name = "",
                order = 2,
                disabled =
                  function()
                    return not S.rotation.enabled
                  end,
                inline = true,
                args = {

                  rotationType = {
                    type = "select",
                    name = L["Rotation Type"],
                    desc = L["<rotationType_desc>"],
                    get =
                      function()
                        return S.rotation.rotationType
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.rotationType = newValue
                        ApplyContinuousRotation()
                      end,
                    values = {
                      ["continuous"] = L["Continuously"],
                      ["degrees"] = L["By Degrees"],
                    },
                    width = "full",
                    order = 1,
                  },
                  blank1 = {type = "description", name = "\n\n", order = 1.1, },

                  rotationOrAccelerationTime = {
                    type = "range",
                    name =
                      function()
                        if S.rotation.rotationType == "continuous" then
                          return L["Acceleration Time"]
                        else
                          return L["Rotation Time"]
                        end
                      end,
                    desc =
                      function()
                        if S.rotation.rotationType == "continuous" then
                          return L["<accelerationTime_desc>"]
                        else
                          return L["<rotationTime_desc>"]
                        end
                      end,
                    min = 0,
                    max = 5,
                    step = .05,
                    get =
                      function()
                        return S.rotation.rotationTime
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.rotationTime = newValue
                      end,
                    width = "full",
                    order = 2,
                  },
                  blank2 = {type = "description", name = " ", order = 2.1, },

                  rotationSpeed = {
                    type = "range",
                    name = L["Rotation Speed"],
                    desc = L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."],
                    min = -900,
                    max = 900,
                    softMin = -90,
                    softMax = 90,
                    hidden =
                      function()
                        return S.rotation.rotationType ~= "continuous"
                      end,
                    step = 1,
                    get =
                      function()
                        return S.rotation.rotationSpeed
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.rotationSpeed = newValue
                        ApplyContinuousRotation()
                      end,
                    width = "full",
                    order = 3,
                  },

                  yawDegrees = {
                    type = "range",
                    name = L["Yaw (-Left/Right+)"],
                    desc = L["Degrees to yaw (left or right)."],
                    min = -1400,
                    max = 1440,
                    softMin = -360,
                    softMax = 360,
                    hidden =
                      function()
                        return S.rotation.rotationType == "continuous"
                      end,
                    step = 5,
                    get =
                      function()
                        return S.rotation.yawDegrees
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.yawDegrees = newValue
                      end,
                    width = "full",
                    order = 3,
                  },
                  blank3 = {
                    type = "description",
                    name = " ",
                    hidden =
                      function()
                        return S.rotation.rotationType == "continuous"
                      end,
                    order = 3.1,
                  },
                  pitchDegrees = {
                    type = "range",
                    name = L["Pitch (-Down/Up+)"],
                    desc = L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."],
                    min = -180,
                    max = 180,
                    hidden =
                      function()
                        return S.rotation.rotationType == "continuous"
                      end,
                    step = 5,
                    get =
                      function()
                        return S.rotation.pitchDegrees
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.pitchDegrees = newValue
                      end,
                    width = "full",
                    order = 4,
                  },


                  blank4 = {type = "description", name = "\n\n", order = 4.1, },

                  rotateBack = {
                    type = "toggle",
                    name = L["Rotate Back"],
                    desc = L["<rotateBack_desc>"],
                    get =
                      function()
                        return S.rotation.rotateBack
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.rotateBack = newValue
                      end,
                    width = "normal",
                    order = 5,
                  },
                  rotateBackTime = {
                    type = "range",
                    name = L["Rotate Back Time"],
                    desc = L["<rotateBackTime_desc>"],
                    min = 0,
                    max = 5,
                    step = .05,
                    disabled =
                      function()
                        return not S.rotation.enabled or not S.rotation.rotateBack
                      end,
                    get =
                      function()
                        return S.rotation.rotateBackTime
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.rotateBackTime = newValue
                      end,
                    width = "full",
                    order = 6,
                  },
                  blank6 = {type = "description", name = " ", order = 6.1, },
                },
              },
            },
          },


          hideUISettings = {
            type = "group",
            name =
              function()
                return GreyWhenInactive(L["Fade Out UI"], S.hideUI.enabled)
              end,
            order = 3,
            args = {
              hideUIToggle = {
                type = "toggle",
                name = L["Enable"],
                desc = L["Fade out or hide (parts of) the UI when this situation is active."],
                get =
                  function()
                    return S.hideUI.enabled
                  end,
                set =
                  function(_, newValue)
                    S.hideUI.enabled = newValue
                    ApplyUIFade()
                  end,
                order = 1,
              },
              hideUIReset = {
                type = "execute",
                -- name = CreateAtlasMarkup("transmog-icon-revert-small", 20, 20),
                name = L["Reset"],
                image = "Interface\\Transmogrify\\Transmogrify",
                imageCoords = resetButtonImageCoords,
                imageWidth = 25/1.5,
                imageHeight = 24/1.5,
                desc = L["Reset to global default"] .. "!\n" .. L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"],
                order = 1.5,
                width = 0.25,
                func =
                  function()
                    for k in pairs(S.hideUI) do
                      if k ~= "enabled" then
                        S.hideUI[k] = DynamicCam.situationDefaults.hideUI[k]
                      end
                    end
                    ApplyUIFade()
                  end,
                disabled =
                  function()
                    for k in pairs(S.hideUI) do
                      if k ~= "enabled" and S.hideUI[k] ~= DynamicCam.situationDefaults.hideUI[k] then
                        return false
                      end
                    end
                    return true
                  end,
              },
              blank0 = {type = "description", name = "", width = 0.3, order = 1.6, },

              adjustToImmersion = {
                type = "execute",
                name = L["Adjust to Immersion"],
                desc = L["<adjustToImmersion_desc>"],
                func =
                  function()
                    S.hideUI.fadeOutTime = 0.2
                    S.hideUI.fadeInTime = 0.5
                  end,
                order = 1.7,
                width = 1,
                hidden =
                  function()
                    return SID ~= "300"
                  end,
              },
              blank1 = {type = "description", name = " ", order = 1.9, },

              hideUIGroup = {
                type = "group",
                name = "",
                order = 2,
                disabled =
                  function()
                    return not S.hideUI.enabled
                  end,
                inline = true,
                args = {

                  fadeOutTime = {
                    type = "range",
                    name = L["Fade Out Time"],
                    desc = L["Seconds it takes to fade out the UI when entering the situation."],
                    min = 0,
                    max = 5,
                    step = .05,
                    get =
                      function()
                        return S.hideUI.fadeOutTime
                      end,
                    set =
                      function(_, newValue)
                        S.hideUI.fadeOutTime = newValue
                      end,
                    width = "full",
                    order = 1,
                  },
                  blank1 = {type = "description", name = " ", order = 1.1, },
                  fadeInTime = {
                    type = "range",
                    name = L["Fade In Time"],
                    desc = L["<fadeInTime_desc>"],
                    min = 0,
                    max = 5,
                    step = .05,
                    get =
                      function()
                        return S.hideUI.fadeInTime
                      end,
                    set =
                      function(_, newValue)
                        S.hideUI.fadeInTime = newValue
                      end,
                    width = "full",
                    order = 2,
                  },
                  blank2 = {type = "description", name = "\n\n", order = 2.1, },

                  hideEntireUI = {
                    type = "toggle",
                    name =
                      function()
                        local text = L["Hide entire UI"]
                        if S.hideUI.hideEntireUI then
                          return "|cFFFF4040" .. text .. "|r"
                        else
                          return text
                        end
                      end,
                    desc = L["<hideEntireUI_desc>"],
                    disabled =
                      function()
                        return not S.hideUI.enabled
                      end,
                    get =
                      function()
                        return S.hideUI.hideEntireUI
                      end,
                    set =
                      function(_, newValue)
                        if newValue then
                          S.hideUI.fadeOpacity = 0
                        end
                        S.hideUI.hideEntireUI = newValue
                      end,
                    order = 3,
                  },

                  keepFrameRate = {
                    type = "toggle",
                    name = L["Keep FPS indicator"],
                    desc = L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."],
                    disabled =
                      function()
                        return not S.hideUI.enabled
                      end,
                    get =
                      function()
                        return S.hideUI.keepFrameRate
                      end,
                    set =
                      function(_, newValue)
                        S.hideUI.keepFrameRate = newValue
                      end,
                    order = 4,
                  },
                  blank4 = {type = "description", name = "\n\n", order = 4.2, },

                  hideUIFadeOpacity = {
                    type = "range",
                    name = L["Fade Opacity"],
                    desc = L["Fade the UI to this opacity when entering the situation."],
                    min = 0,
                    max = 1,
                    step = .01,
                    disabled =
                      function()
                        return not S.hideUI.enabled or S.hideUI.hideEntireUI
                      end,
                    get =
                      function()
                        return S.hideUI.fadeOpacity
                      end,
                    set =
                      function(_, newValue)
                        S.hideUI.fadeOpacity = newValue
                        ApplyUIFade()
                      end,
                    width = "full",
                    order = 5,
                  },
                  blank5 = {type = "description", name = "\n\n", order = 5.2, },

                  excludedFramesGroup = {
                    type = "group",
                    name = L["Excluded UI elements"],
                    order = 6,
                    disabled =
                      function()
                        return not S.hideUI.enabled or S.hideUI.hideEntireUI
                      end,
                    args = {

                      keepAlertFrames = {
                        type = "toggle",
                        name = L["Keep Alerts"],
                        desc = L["Still show alert popups from completed achievements, Covenant Renown, etc."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepAlertFrames
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepAlertFrames = newValue
                            ApplyUIFade()
                          end,
                        order = 1,
                        width = 0.9,
                      },

                      keepTooltip = {
                        type = "toggle",
                        name = L["Keep Tooltip"],
                        desc = L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepTooltip
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepTooltip = newValue
                            ApplyUIFade()
                          end,
                        order = 2,
                        width = 0.9,
                      },

                      keepMinimap = {
                        type = "toggle",
                        name = L["Keep Minimap"],
                        desc = L["<keepMinimap_desc>"],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepMinimap
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepMinimap = newValue
                            ApplyUIFade()
                          end,
                        order = 3,
                        width = 0.9,
                      },

                      keepChatFrame = {
                        type = "toggle",
                        name = L["Keep Chat Box"],
                        desc = L["Do not fade out the chat box."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepChatFrame
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepChatFrame = newValue
                            ApplyUIFade()
                          end,
                        order = 4,
                        width = 0.9,
                      },

                      keepTrackingBar = {
                        type = "toggle",
                        name = L["Keep Tracking Bar"],
                        desc = L["Do not fade out the tracking bar (XP, AP, reputation)."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepTrackingBar
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepTrackingBar = newValue
                            ApplyUIFade()
                          end,
                        order = 5,
                        width = 0.9,
                      },

                      keepPartyRaidFrame = {
                        type = "toggle",
                        name = L["Keep Party/Raid"],
                        desc = L["Do not fade out the Party/Raid frame."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepPartyRaidFrame
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepPartyRaidFrame = newValue
                            ApplyUIFade()
                          end,
                        order = 5,
                        width = 0.9,
                      },

                      keepEncounterBar = {
                        type = "toggle",
                        name = L["Keep Encounter Frame (Skyriding Vigor)"],
                        desc = L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepEncounterBar
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepEncounterBar = newValue
                            ApplyUIFade()
                          end,
                        order = 6,
                        width = "full",
                      },

                      n7 = {order = 7, type = "description", name = " ",},

                      keepCustomFrames = {
                        type = "toggle",
                        name = L["Keep additional frames"],
                        desc = L["<keepCustomFrames_desc>"],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepCustomFrames
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepCustomFrames = newValue
                            ApplyUIFade()
                          end,
                        order = 8,
                        width = 2,
                      },

                      customFramesToKeep = {
                        type = "input",
                        name = L["Custom frames to keep"],
                        desc = L["Separated by commas."],
                        get =
                          function()
                            returnString = ""
                            for k, v in pairs(S.hideUI.customFramesToKeep) do
                              if v == true then
                                if returnString ~= "" then
                                  returnString = returnString .. ", "
                                end
                                returnString = returnString .. k
                              end
                            end
                            return returnString
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.customFramesToKeep = {}

                            newValue = string.gsub(newValue, "%s+", "")
                            for k, v in pairs({strsplit(",", newValue)}) do
                              -- Not checking if frame exists, because some frames are only created when needed (e.g. DebuffFrame).
                              S.hideUI.customFramesToKeep[v] = true
                            end

                            -- We have to set unused default frames explicitly to false, otherwise they will be put back on reload.
                            for k, _ in pairs(DynamicCam.situationDefaults.hideUI.customFramesToKeep) do
                              if S.hideUI.customFramesToKeep[k] == nil then
                                S.hideUI.customFramesToKeep[k] = false
                              end
                            end

                            ApplyUIFade()
                          end,
                        disabled = function() return not S.hideUI.keepCustomFrames end,
                        multiline = 3,
                        order = 9,
                        width = "full",
                      },

                    },
                  },
                  blank6 = {type = "description", name = " ", order = 6.2, },

                  emergencyShowGroup = {
                    type = "group",
                    name = L["Emergency Fade In"],
                    order = 7,
                    disabled =
                      function()
                        return not S.hideUI.enabled
                      end,
                    args = {
                      emergencyShowEscEnabled = {
                        type = "toggle",
                        name = L["Pressing Esc fades the UI back in."],
                        get =
                          function()
                            return S.hideUI.emergencyShowEscEnabled
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.emergencyShowEscEnabled = newValue
                          end,
                        order = 1,
                        width = "full",
                      },
                      emergencyShowDescription = {
                        type = "description",
                        name = L["<emergencyShow_desc>"],
                        order = 2,
                      },
                    },
                  },
                },
              },
              blank2 = {type = "description", name = " ", order = 2.2, },

              hideUIHelpGroup = {
                type = "group",
                name = L["Help"],
                order = 3,
                inline = true,
                args = {
                  hideUIHelpDescription = {
                    type = "description",
                    name = L["<hideUIHelp_desc>"],
                    order = 1,
                  },
                  settingsPanelIgnoreParentAlpha = {
                    type = "toggle",
                    name = L["Do not fade out this \"Interface\" settings frame."],
                    get =
                      function()
                        return SettingsPanel:IsIgnoringParentAlpha()
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam.db.profile.settingsPanelIgnoreParentAlpha = newValue
                        DynamicCam:SettingsPanelSetIgnoreParentAlpha(newValue)
                      end,
                    width = "full",
                    order = 2,
                  },
                },
              },
            },
          },
        },
      },


      situationControls = {

        type = "group",
        name = function() return ColourTextErrorOrModified(L["Situation Controls"]) end,
        order = 7,
        args = {

          help = {
            type = "description",
            name = L["<situationControls_help>"],
            order = 0,
          },

          priority = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified(L["Priority"], "value", "priority")
              end,
            order = 1,
            args = {

              priority = {
                type = "input",
                name = L["Priority"],
                desc = L["The priority of this situation.\nMust be a number."],
                get = function() return ""..S.priority end,
                set =
                  function(_, newValue)
                    if tonumber(newValue) then
                      S.priority = tonumber(newValue)
                    end
                    DynamicCam:UpdateSituation(SID)
                  end,
                order = 1,
              },
              priorityDefault = {
                type = "execute",
                name = L["Restore stock setting"],
                desc =
                  function()
                    return L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."]:format(DynamicCam.defaults.profile.situations[SID].priority)
                  end,
                func =
                  function()
                    S.priority = DynamicCam.defaults.profile.situations[SID].priority
                      DynamicCam:UpdateSituation(SID)
                  end,
                hidden =
                  function()
                    return ValueIsDefault(SID, "priority")
                  end,
                order = 2,
              },
              blank2 = {type = "description", name = " ", order = 2.2, },

              priorityDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 3,
                args = {
                  priorityDescription = {
                    type = "description",
                    name = L["<priority_desc>"],
                  },
                },
              },
            },
          },

          events = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified(L["Events"], "events", "events")
              end,
            order = 2,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "events" then
                      return "|cFFEE0000" .. L["Error message:"] .. "\n\n" .. S.errorMessage .. "|r\n\n"
                    end
                  end,
                hidden =
                  function()
                    return not S.errorEncountered or S.errorEncountered ~= "events"
                  end,
                order = 0
              },

              events = {
                type = "input",
                name = L["Events"],
                desc = L["Separated by commas."],
                get = function() return table.concat(S.events, ", ") end,
                set =
                  function(_, newValue)
                    if newValue == "" then
                      S.events = {}
                    else
                      newValue = string.gsub(newValue, "%s+", "")
                      S.events = {strsplit(",", newValue)}
                    end
                    DynamicCam:UpdateSituation(SID)
                  end,
                multiline = 10,
                width = "full",
                order = 1,
              },

              eventsDefault = {
                type = "execute",
                name = L["Restore stock setting"],
                desc = L["Your \"Events\" deviate from the default for this situation. Click here to restore them."],
                func =
                  function()
                    S.events = DynamicCam.defaults.profile.situations[SID].events
                    DynamicCam:UpdateSituation(SID)
                  end,
                hidden =
                  function()
                    return EventsIsDefault(SID)
                  end,
                order = 2,
              },
              blank2 = {type = "description", name = " ", order = 2.2, },

              eventsDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 3,
                args = {
                  eventsDescription = {
                    type = "description",
                    name = L["<events_desc>"],

-- TODO: Still need this for classic:
-- Notice, that you have to manually scroll down after the window first opens. Then you can use these commands to stop and start the logging:

  -- /eventtrace stop
  -- /eventtrace start

-- If you want to get serious with the event trace, put these two commands into macros and keybind them, so you can stop and start quickly.

                  },
                },
              },
            },
          },

          executeOnInit = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified(L["Initialisation"], "script", "executeOnInit")
              end,
            order = 3,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "executeOnInit" then
                      return "|cFFEE0000" .. L["Error message:"] .. "\n\n" .. S.errorMessage .. "|r\n\n"
                    end
                  end,
                hidden =
                  function()
                    return not S.errorEncountered or S.errorEncountered ~= "executeOnInit"
                  end,
                order = 0
              },

              executeOnInit = {
                type = "input",
                name = L["Initialisation Script"],
                desc = L["Lua code using the WoW UI API."],
                get = function() return S.executeOnInit end,
                set =
                  function(_, newValue)
                    S.executeOnInit = newValue
                    DynamicCam:UpdateSituation(SID)
                  end,
                multiline = 10,
                width = "full",
                order = 1,
              },

              executeOnInitDefault = {
                type = "execute",
                name = L["Restore stock setting"],
                desc = L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."],
                func =
                  function()
                    S.executeOnInit = DynamicCam.defaults.profile.situations[SID].executeOnInit
                    DynamicCam:UpdateSituation(SID)
                  end,
                hidden =
                  function()
                    return ScriptIsDefault(SID, "executeOnInit")
                  end,
                order = 2,
              },
              blank2 = {type = "description", name = " ", order = 2.2, },

              initialisationDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 3,
                args = {
                  initialisationDescription = {
                    type = "description",
                    name = L["<initialisation_desc>"],
                  },
                },
              },
            },
          },

          condition = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified(L["Condition"], "script", "condition")
              end,
            order = 4,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "condition" then
                      return "|cFFEE0000Error message:\n\n" .. S.errorMessage .. "|r\n\n"
                    end
                  end,
                hidden =
                  function()
                    return not S.errorEncountered or S.errorEncountered ~= "condition"
                  end,
                order = 0
              },

              condition = {
                type = "input",
                name = L["Condition Script"],
                desc = L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."],
                get = function() return S.condition end,
                set =
                  function(_, newValue)
                    S.condition = newValue
                    DynamicCam:UpdateSituation(SID)
                  end,
                multiline = 10,
                width = "full",
                order = 1,
              },

              conditionDefault = {
                type = "execute",
                name = L["Restore stock setting"],
                desc = L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."],
                func =
                  function()
                    S.condition = DynamicCam.defaults.profile.situations[SID].condition
                    DynamicCam:UpdateSituation(SID)
                  end,
                hidden =
                  function()
                    return ScriptIsDefault(SID, "condition")
                  end,
                order = 2,
              },
              blank2 = {type = "description", name = " ", order = 2.2, },

              conditionDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 3,
                args = {
                  conditionDescription = {
                    type = "description",
                    name = L["<condition_desc>"],
                  },
                },
              },
            },
          },

          executeOnEnter = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified(L["Entering"], "script", "executeOnEnter")
              end,
            order = 5,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "executeOnEnter" then
                      return L["|cFFEE0000Error message:\n\n"] .. S.errorMessage .. "|r\n\n"
                    end
                  end,
                hidden =
                  function()
                    return not S.errorEncountered or S.errorEncountered ~= "executeOnEnter"
                  end,
                order = 0
              },

              executeOnEnter = {
                type = "input",
                name = L["On-Enter Script"],
                desc = L["Lua code using the WoW UI API."],
                get = function() return S.executeOnEnter end,
                set =
                  function(_, newValue)
                    S.executeOnEnter = newValue
                    DynamicCam:UpdateSituation(SID)
                  end,
                multiline = 10,
                width = "full",
                order = 1,
              },

              executeOnEnterDefault = {
                type = "execute",
                name = L["Restore stock setting"],
                desc = L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."],
                func =
                  function()
                    S.executeOnEnter = DynamicCam.defaults.profile.situations[SID].executeOnEnter
                    DynamicCam:UpdateSituation(SID)
                  end,
                hidden =
                  function()
                    return ScriptIsDefault(SID, "executeOnEnter")
                  end,
                order = 2,
              },
              blank2 = {type = "description", name = " ", order = 2.2, },

              executeOnEnterDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 3,
                args = {
                  executeOnEnterDescription = {
                    type = "description",
                    name = L["<executeOnEnter_desc>"],
                  },
                },
              },

            },
          },

          executeOnExit = {
            type = "group",
            name =
                function()
                    if (S.errorEncountered and S.errorEncountered == executeOnExit) or not ScriptIsDefault(SID, "executeOnExit") then
                        return ColourTextErrorOrModified(L["Exiting"], "script", "executeOnExit")
                    else
                        return ColourTextErrorOrModified(L["Exiting"], "value", "delay")
                    end
                end,
            order = 6,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "executeOnExit" then
                      return L["|cFFEE0000Error message:\n\n"] .. S.errorMessage .. "|r\n\n"
                    end
                  end,
                hidden =
                  function()
                    return not S.errorEncountered or S.errorEncountered ~= "executeOnExit"
                  end,
                order = 0
              },

              executeOnExit = {
                type = "input",
                name = L["On-Exit Script"],
                desc = L["Lua code using the WoW UI API."],
                get = function() return S.executeOnExit end,
                set =
                  function(_, newValue)
                    S.executeOnExit = newValue
                    DynamicCam:UpdateSituation(SID)
                  end,
                multiline = 10,
                width = "full",
                order = 1,
              },
              executeOnExitDefaultWrapper = {
                type = "group",
                name = "",
                inline = true,
                width = "full",
                order = 2,
                args = {
                  executeOnExitDefault = {
                    type = "execute",
                    name = L["Restore stock setting"],
                    desc = L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."],
                    func =
                      function()
                        S.executeOnExit = DynamicCam.defaults.profile.situations[SID].executeOnExit
                        DynamicCam:UpdateSituation(SID)
                      end,
                  },
                },
                hidden =
                  function()
                    return ScriptIsDefault(SID, "executeOnExit")
                  end,
              },
              blank2 = {type = "description", name = " ", order = 2.1, },

              exitDelay = {
                type = "input",
                name = L["Exit Delay"],
                desc = L["Wait for this many seconds before exiting this situation."],
                get = function() return ""..S.delay end,
                set =
                  function(_, newValue)
                    if tonumber(newValue) then
                      S.delay = tonumber(newValue)
                    end
                    DynamicCam:UpdateSituation(SID)
                  end,
                width = "half",
                order = 3,
              },
              exitDelayDefaultWrapper = {
                type = "group",
                name = "",
                inline = true,
                width = "full",
                order = 4,
                args = {
                  exitDelayDefault = {
                    type = "execute",
                    name = L["Restore stock setting"],
                    desc = L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."],
                    func =
                      function()
                        S.delay = DynamicCam.defaults.profile.situations[SID].delay
                        DynamicCam:UpdateSituation(SID)
                      end,
                  },
                },
                hidden =
                  function()
                    return ValueIsDefault(SID, "delay")
                  end,
              },
              blank4 = {type = "description", name = " ", order = 4.1, },

              executeOnExitDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 5,
                args = {
                  executeOnExitDescription = {
                    type = "description",
                    name = L["<executeOnExit_desc>"],
                  },
                },
              },

            },
          },

        },
      },


      export = {

        type = "group",
        name = L["Export"],
        order = 8,

        args = {

          description = {
            type = "description",
            name = L["Coming soon(TM)."],
            order = 1,
          },

          -- TODO
          exportFrame = {
            type = "input",
            name = "SituationExport",
            dialogControl = "DynamicCam_CustomWidget",
            width = "full",
          },
        },
      },

      import = {

        type = "group",
        name = L["Import"],
        order = 9,

        args = {

          description = {
              type = "description",
              name = L["Coming soon(TM)."],
              order = 1,
          },


          -- TODO
          -- copy = {
              -- type = "execute",
              -- name = "Copy",
              -- desc = "Copy this situations settings so that you can paste it into another situation.\n\nDoesn't copy the condition or the advanced mode Lua scripts.",
              -- hidden = function() return not S end,
              -- func = function() copiedSituationID = SID end,
              -- order = 5,
              -- width = "half",
          -- },

          -- paste = {
              -- type = "execute",
              -- name = "Paste",
              -- desc = "Paste the settings from that last copied situation.",
              -- hidden = function() return not S end,
              -- disabled = function() return not copiedSituationID end,
              -- func = function()
                      -- DynamicCam:CopySituationInto(copiedSituationID, SID)
                      -- copiedSituationID = nil
                  -- end,
              -- order = 6,
              -- width = "half",
          -- },

          -- export = {
              -- type = "execute",
              -- name = "Export",
              -- desc = "If you want to share the settings of this situation with others you can export it into a text string. Use the \"Import\" section of the DynamicCam settings to import strings you have received from others.",
              -- hidden = function() return not S end,
              -- func = function() DynamicCam:PopupExport(DynamicCam:ExportSituation(SID)) end,
              -- order = 7,
              -- width = "half",
          -- },

          -- helpText = {
              -- type = "description",
              -- name = "If you have the DynamicCam import string for a profile or situation, paste it in the text box below to import it. You can generate such import strings yourself using the export functions in the \"Profiles\" or \"Situations\" sections of the DynamicCam settings.\n\n|cFFFF4040YOUR CURRENT PROFILE WILL BE OVERRIDDEN WITHOUT WARNING, SO MAKE A COPY IF YOU WANT TO KEEP IT!|r\n",
              -- order = 8,
          -- },
          -- import = {
              -- type = "input",
              -- name = "Paste and hit Accept to import!",
              -- desc = "Paste the DynamicCam import string of a profile or a situation.",
              -- get = function() return "" end,
              -- set = function(_, newValue) DynamicCam:Import(newValue) end,
              -- multiline = 10,
              -- width = "full",
              -- order = 9,
          -- },

        },

      },

    },
  }

  return returnOptions

end




local welcomeMessage = L["<welcomeMessage>"]




local about = {
  type = "group",
  name = L["About"],
  order = 10,
  args = {
    situationControlsWarning = {
      type = "group",
      name = " ",
      order = 1,
      inline = true,
      hidden =
        function()
          for situationId in pairs(DynamicCam.defaults.profile.situations) do
            if not SituationControlsAreDefault(situationId) then return false end
          end
          return true
        end,
      args = {
        header = {
          type = "header",
          name = "|cFFEE0000" .. L["WARNING"] .. "!|r",
          order = 1,
        },
        message = {
          type = "description",
          name =
            function()
              local returnString = L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"]

              for situationId, situation in pairs(DynamicCam.defaults.profile.situations) do
                if not SituationControlsAreDefault(situationId) then
                  returnString = returnString .. "  - " .. situation.name .. "\n"
                end
              end

              returnString = returnString .. L["<situationControlsWarning>"]

              return returnString

            end,
          order = 2,
        },
        restoreDefaultsButton = {
          type = "execute",
          name = L["Restore all stock Situation Controls"],
          order = 3,
          width = "full",
          func =
            function()
              for situationId in pairs(DynamicCam.defaults.profile.situations) do
                SituationControlsToDefault(situationId)
              end
            end,
        },
      }
    },
    blank1 = {
      type = "description",
      name = " ",
      order = 1.1,
      hidden =
        function()
          for situationId in pairs(DynamicCam.defaults.profile.situations) do
            if not SituationControlsAreDefault(situationId) then return false end
          end
          return true
        end,
    },
    messageGroup = {
      type = "group",
      name = "",
      order = 2,
      inline = true,
      args = {
        heading = {
          type = "header",
          name = L["Hello and welcome to DynamicCam!"],
        },
        message = {
          type = "description",
          name = welcomeMessage,
        },
      }
    },
  },
}





local profileSettings = {
  type = "group",
  name = L["Profiles"],
  order = 4,
  childGroups = "tab",
  args = {

    manageProfiles = {
      type = "group",
      name = L["Manage Profiles"],
      order = 1,
      args = {

        blank99 = {type = "description", name = " ", order = 99, },

        manageProfilesWarningGroup = {
          type = "group",
          name = L["Help"],
          inline = true,
          order = 100,
          args = {
            manageProfilesWarning = {
              type = "description",
              name = L["<manageProfilesWarning>"],
            },
          },
        },
      },
    },

    presets = {
      type = "group",
      name = L["Profile presets"],
      order = 2,
      args = {
        description = {
          type = "description",
          name = L["Coming soon(TM)."],
          order = 1,
        },

        -- TODO
        -- description = {
          -- type = "description",
          -- name = "Here are some preset profiles created by other DynamicCam users. Do you have a profile that's unlike any of these? Please export it and post it together with a name and description on the DynamicCam user forum! We will then consider putting it into the next release.",
          -- order = 1,
        -- },
        -- loadPreset = {
          -- type = "select",
          -- name = "Load Preset",
          -- desc = "Select a preset profile to load it.\n|cFFFF4040YOUR CURRENT PROFILE WILL BE OVERRIDDEN WITHOUT WARNING, SO MAKE A COPY IF YOU WANT TO KEEP IT!|r",
          -- get = function() return "" end,
          -- set = function(_, newValue) DynamicCam:LoadPreset(newValue) end,
          -- values = function() return DynamicCam:GetPresets() end,
          -- sorting = function() return DynamicCam:GetPresetsSorting() end,
          -- width = "full",
          -- order = 2,
        -- },
        -- presetDescriptions = {
          -- type = "group",
          -- name = "Descriptions",
          -- order = 3,
          -- inline = true,
          -- args = {
            -- description = {
              -- type = "description",
              -- name = function() return DynamicCam:GetPresetDescriptions() end,
              -- order = 1,
            -- },
          -- },
        -- },
      },
    },

    importExport = {
      type = "group",
      name = L["Import / Export"],
      order = 3,
      args = {
        description = {
          type = "description",
          name = L["Coming soon(TM)."],
          order = 1,
        },

        -- TODO
        -- helpText = {
          -- type = "description",
          -- name = "If you want to share your profile with others you can export it into a text string. Use \"Import\" to import strings you have received from others.",
          -- order = 0,
        -- },
        -- name = {
          -- type = "input",
          -- name = "Profile Name (Required!)",
          -- desc = "The name that other people will see when importing this profile.",
          -- get = function() return exportName end,
          -- set = function(_, newValue) exportName = newValue end,
          -- --width = "double",
          -- order = 1,
        -- },
        -- author = {
          -- type = "input",
          -- name = "Author (Optional)",
          -- desc = "A name that will be attached to the export so that other people know whom it's from.",
          -- get = function() return exportAuthor end,
          -- set = function(_, newValue) exportAuthor = newValue end,
          -- order = 2,
        -- },
        -- export = {
          -- type = "execute",
          -- name = "Generate export string",
          -- disabled = function() return not (exportName and exportName ~= "") end,
          -- func = function() DynamicCam:PopupExport(DynamicCam:ExportProfile(exportName, exportAuthor)) end,
          -- order = 3,
        -- },

        -- helpText = {
          -- type = "description",
          -- name = "If you have the DynamicCam import string for a profile or situation, paste it in the text box below to import it. You can generate such import strings yourself using the export functions in the \"Profiles\" or \"Situations\" sections of the DynamicCam settings.\n\n|cFFFF4040YOUR CURRENT PROFILE WILL BE OVERRIDDEN WITHOUT WARNING, SO MAKE A COPY IF YOU WANT TO KEEP IT!|r\n",
          -- order = 4,
        -- },
        -- import = {
          -- type = "input",
          -- name = "Paste and hit Accept to import!",
          -- desc = "Paste the DynamicCam import string of a profile or a situation.",
          -- get = function() return "" end,
          -- set = function(_, newValue) DynamicCam:Import(newValue) end,
          -- multiline = 10,
          -- width = "full",
          -- order = 5,
        -- },

      },
    },
  },
}








----------
-- CORE --
----------
function Options:OnInitialize()
  -- make sure to select something for the UI
  self:SelectSituation()

  -- register the gui with AceConfig and Blizz Options
  self:RegisterMenus()
end

function Options:OnEnable()
  -- register for dynamiccam messages
  self:RegisterMessage("DC_SITUATION_ACTIVE", "ReselectSituation")
  self:RegisterMessage("DC_SITUATION_INACTIVE", "ReselectSituation")
  self:RegisterMessage("DC_SITUATION_ENTERED", "ReselectSituation")
  self:RegisterMessage("DC_SITUATION_EXITED", "ReselectSituation")
end

function Options:OnDisable()
  self:UnregisterAllMessages()
end


---------
-- GUI --
---------
function Options:ClearSelection()
  SID = nil
  S = nil
end

-- This function is needed to call SelectSituation() and
-- ignore the "message" argument passed to ReselectSituation().
function Options:ReselectSituation()
  self:SelectSituation()
end


-- If there has been user interaction with situation settings before (lastSelectedSID ~= nil),
-- do not change the currently selected situation.
function Options:SelectSituation(selectMe)
  if selectMe and DynamicCam.db.profile.situations[selectMe] then
    S = DynamicCam.db.profile.situations[selectMe]
    SID = selectMe
  elseif not lastSelectedSID and DynamicCam.currentSituationID then
    S = DynamicCam.db.profile.situations[DynamicCam.currentSituationID]
    SID = DynamicCam.currentSituationID
  elseif not SID or not S then
    SID, S = next(DynamicCam.db.profile.situations)
  end

  LibStub("AceConfigRegistry-3.0"):NotifyChange("DynamicCam")
end



function Options:RegisterMenus()
  -- setup menu

  -- Add profile managing here, such that we can have export below it.
  profileSettings.args.manageProfiles.args.acedbPanel = LibStub("AceDBOptions-3.0"):GetOptionsTable(DynamicCam.db)

  profileSettings.args.manageProfiles.args.acedbPanel.name = ""
  profileSettings.args.manageProfiles.args.acedbPanel.inline = true
  profileSettings.args.manageProfiles.args.acedbPanel.order = 1


  local allOptions = {
    name = L["DynamicCam"],
    type = "group",
    childGroups = "tab",
    args = {
      aboutTab = about,
      standardSettingsTab = CreateSettingsTab(2),
      situationSettingsTab = CreateSituationSettingsTab(3),
      profileSettingsTab = profileSettings,
    }
  }

  LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam", allOptions)
  self.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam", "DynamicCam")

end





local function DrawLine(f, startRelativeAnchor, startOffsetX, startOffsetY,
                           endRelativeAnchor, endOffsetX, endOffsetY,
                           thickness, r, g, b, a)

  local line = f:CreateLine()
  line:SetThickness(thickness)
  line:SetColorTexture(r, g, b, a)
  line:SetStartPoint(startRelativeAnchor, f, startOffsetX, startOffsetY)
  line:SetEndPoint(endRelativeAnchor, f, endOffsetX, endOffsetY)

end


local function SetFrameBorder(f, thickness, r, g, b, a)
  -- Bottom line.
  DrawLine(f, "BOTTOMLEFT", 0, 0, "BOTTOMRIGHT", 0, 0, thickness, r, g, b, a)
  -- Top line.
  DrawLine(f, "TOPLEFT", 0, 0, "TOPRIGHT", 0, 0, thickness, r, g, b, a)
  -- Left line.
  DrawLine(f, "BOTTOMLEFT", 0, 0, "TOPLEFT", 0, 0, thickness, r, g, b, a)
  -- Right line.
  DrawLine(f, "BOTTOMRIGHT", 0, 0, "TOPRIGHT", 0, 0, thickness, r, g, b, a)
end




-- Registry for custom widget builders.
DynamicCam.CustomWidgetBuilders = {}

DynamicCam.CustomWidgetBuilders["SituationExport"] = function(widget, f)

  -- Description text on top of the page. Using the same font as AceConfig description text.
  if not f.help then

    f.help = f:CreateFontString(nil, "OVERLAY")
    f.help:SetFontObject("GameFontHighlightSmall")
    f.help:SetJustifyH("LEFT")
    f.help:SetPoint("TOPLEFT", f, "TOPLEFT")
    f.help:SetPoint("TOPRIGHT", f, "TOPRIGHT")

    f.help:SetText("TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO")
  end


  if not f.contentFrame then
    f.contentFrame = CreateFrame("Frame", nil, f)
    local cf = f.contentFrame

    local yOffset = -10
    cf:SetPoint("TOPLEFT", f.help, "BOTTOMLEFT", 0, yOffset)
    cf:SetPoint("TOPRIGHT", f.help, "TOPRIGHT", 0, yOffset)


    cf.situationSettingsFrame = CreateFrame("Frame", nil, cf)
    local ssf = cf.situationSettingsFrame
    ssf:SetPoint("TOPLEFT", cf, "TOPLEFT")
    ssf:SetPoint("TOPRIGHT", cf, "TOPRIGHT")

    ssf:SetHeight(30)


    cf.situationActionsFrame = CreateFrame("Frame", nil, cf)
    local saf = cf.situationActionsFrame
    saf:SetPoint("TOPLEFT", ssf, "BOTTOMLEFT")
    saf:SetPoint("TOPRIGHT", ssf, "BOTTOMRIGHT")

    saf:SetHeight(30)


    cf.situationControlsFrame = CreateFrame("Frame", nil, cf)
    local scf = cf.situationControlsFrame
    scf:SetPoint("TOPLEFT", saf, "BOTTOMLEFT")
    scf:SetPoint("TOPRIGHT", saf, "BOTTOMRIGHT")

    -- If this is too small, the text of the label gets cut off...
    scf:SetHeight(30)

  end





  -- TODO: For testing.
  -- SetFrameBorder(f, 2, 1, 0, 0, 0.5)
  -- SetFrameBorder(f.contentFrame, 2, 1, 1, 1)

  -- testFrame = f.contentFrame.situationControlsFrame
  -- if not testFrame.myLabel then
    -- testFrame.myLabel = testFrame:CreateFontString(nil, "OVERLAY")
    -- testFrame.myLabel:SetFontObject("Game12Font")
    -- testFrame.myLabel:SetTextColor(0.8, 0.8, 0.8)
    -- testFrame.myLabel:SetJustifyH("LEFT")
    -- testFrame.myLabel:SetPoint("TOPLEFT", testFrame, "TOPLEFT")
    -- testFrame.myLabel:SetPoint("TOPRIGHT", testFrame, "TOPRIGHT")
    -- testFrame.myLabel:SetText("TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST")
  -- end




  -- Whenever OnWidthSet() is called, we set the height of frames to the height of their children frames.
  widget.AdjustHeightFunction = function(self)

    -- -- For multi-line text labels with automatic line breaks you may have to
    -- -- reset the label height back to the string height here. Because for some reason
    -- -- the label may get reduced to one line (problby because the width is temporarily
    -- -- undefined) in the process of switching GUI tabs.
    -- -- This is also the place where have to set the height of frames, whose height should
    -- -- depend on a text's height.
    -- local newHeight = testFrame.myLabel:GetStringHeight()
    -- testFrame.myLabel:SetHeight(newHeight)
    -- testFrame:SetHeight(newHeight)

    local cf = f.contentFrame

    -- Set the contentFrame to the height of all its children.
    cf:SetHeight(cf.situationSettingsFrame:GetHeight() + cf.situationActionsFrame:GetHeight() + cf.situationControlsFrame:GetHeight())

    -- Set the container frame (f) height.
    local point, _, _, _, yOffset = cf:GetPoint()
    f:SetHeight(f.help:GetStringHeight() - yOffset + cf:GetHeight())

    -- Set the widget frame height to match the container.
    self.frame:SetHeight(f:GetHeight())
  end

end



-- My custom widget for Situation Export.
-- Inspired by https://github.com/SFX-WoW/AceGUI-3.0_SFX-Widgets/.
do

  local Type, Version = "DynamicCam_CustomWidget", 1
  local AceGUI = LibStub("AceGUI-3.0", true)

  -- Standard Ace3 version check: If a newer version of this widget is already registered, don't overwrite it.
  if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

  local function Constructor()
    
    local Widget = {}
    Widget.frame = CreateFrame("Frame", nil, UIParent)
    Widget.frame.obj = Widget
    Widget.type  = Type
    Widget.num   = AceGUI:GetNextWidgetNum(Type)

    -- Reccommended place to store ephemeral widget information.
    Widget.userdata = {}

    -- Storage for our different views (builders)
    Widget.views = {}

    -- OnAcquire, SetLabel, SetText, SetDisabled(nil)
    -- all get called when showing the widget.
    Widget.OnAcquire = function(self)
      self.resizing = true

      self:SetDisabled(true)
      self.frame:SetHeight(10) -- Default small height until built

      -- Hide all views
      for _, view in pairs(self.views) do
        view:Hide()
      end
      self.currentView = nil
      self.AdjustHeightFunction = nil

      self.resizing = nil
    end

    Widget.SetLabel = function(self, name)
      -- Use 'name' as the ID to look up the builder.
      local builder = DynamicCam.CustomWidgetBuilders[name]
      if not builder then return end

      if not self.views[name] then
        local f = CreateFrame("Frame", nil, self.frame)
        f:SetPoint("TOPLEFT")
        f:SetPoint("TOPRIGHT")
        -- We don't set height here, the builder/AdjustHeightFunction will do it.

        builder(self, f)
        self.views[name] = f
      end

      self.currentView = self.views[name]
      self.currentView:Show()

      -- Trigger a resize now that we have content
      if self.AdjustHeightFunction then
         self:AdjustHeightFunction()
      end
    end

    -- Not useful to us, but Ace3 needs to call it.
    Widget.SetText = function(self) end

    Widget.OnWidthSet = function(self)
      if self.resizing then return end

      -- Whenever OnWidthSet() is called, adjust the height of the frames to contain all child frames.
      if self.AdjustHeightFunction then self:AdjustHeightFunction() end
    end

    Widget.SetDisabled = function(self, Disabled)
      self.disabled = Disabled
    end

    -- OnRelease gets called when hiding the widget.
    Widget.OnRelease = function(self)
      self:SetDisabled(true)
      self.frame:ClearAllPoints()
      if self.currentView then
        self.currentView:Hide()
      end
      self.currentView = nil
      self.AdjustHeightFunction = nil
    end

    return AceGUI:RegisterAsWidget(Widget)
  end

  AceGUI:RegisterWidgetType(Type, Constructor, Version)
end






-- Disable mouse look slider and motion sickness options
-- and leave a tooltip note in the default UI settings.

local mouseLookSpeedSlider = nil
local MouseLookSpeedSliderOrignialTooltipEnter = nil
local MouseLookSpeedSliderOrignialTooltipLeave = nil

local motionSicknessElement = nil
local indexCentered = nil
local indexReduced = nil
local indexBoth = nil
local indexNone = nil
local motionSicknessElementOriginalTooltipEnter = nil
local motionSicknessElementOriginalTooltipLeave = nil

hooksecurefunc(SettingsPanel.Container.SettingsList.ScrollBox, "Update", function(self)

  local foundMouseLookSpeedSlider = false
  local foundMotionSicknessElement = false

  -- ###################### Mouse ######################
  if SettingsPanel.Container.SettingsList.Header.Title:GetText() == CONTROLS_LABEL then

    local children = { SettingsPanel.Container.SettingsList.ScrollBox.ScrollTarget:GetChildren() }
    for i, child in ipairs(children) do
      if child.Text then
        if child.Text:GetText() == MOUSE_LOOK_SPEED then
          -- print("Found", child.Text:GetText(), MOUSE_LOOK_SPEED)
          foundMouseLookSpeedSlider = true

          if not mouseLookSpeedSlider then
            -- print("Disabling slider")
            mouseLookSpeedSlider = child.SliderWithSteppers

            if not MouseLookSpeedSliderOrignialTooltipEnter then
              MouseLookSpeedSliderOrignialTooltipEnter = mouseLookSpeedSlider.Slider:GetScript("OnEnter")
              MouseLookSpeedSliderOrignialTooltipLeave = mouseLookSpeedSlider.Slider:GetScript("OnLeave")
            end

            -- Change tooltip.
            mouseLookSpeedSlider.Slider:SetScript("OnEnter", function(self)
              GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
              GameTooltip:AddLine("|cFFFF0000" .. L["Disabled"] .. "|r", _, _, _, true)
              GameTooltip:AddLine(L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."], _, _, _, true)
              GameTooltip:Show()
            end)
            mouseLookSpeedSlider.Slider:SetScript("OnLeave", function(self)
              GameTooltip:Hide()
            end)
          end

          -- Got to make sure, the slider stays disabled.
          if mouseLookSpeedSlider.Slider:IsEnabled() then
            -- Function name "SetEnabled" introduced in 11.0.0.
            if mouseLookSpeedSlider.SetEnabled then
              mouseLookSpeedSlider:SetEnabled(false)
            else
              mouseLookSpeedSlider:SetEnabled_(false)
            end
          end

          break
        end
      end
    end



  -- ###################### Motion Sickness ######################
  elseif SettingsPanel.Container.SettingsList.Header.Title:GetText() == ACCESSIBILITY_GENERAL_LABEL then

    -- Retail got rid of the drop down and only uses a single checkbox now.

    -- Bizarrely, since 11.0.2 checking the checkbox sets
    -- CameraKeepCharacterCentered = false  and  CameraReduceUnexpectedMovement = true
    -- whereas unchecking the checkbox sets
    -- CameraKeepCharacterCentered = true  and  CameraReduceUnexpectedMovement = false
    -- Either variable will stop shoulder offset to take effect, so we disable the checkbox completely.


    local children = { SettingsPanel.Container.SettingsList.ScrollBox.ScrollTarget:GetChildren() }
    for i, child in ipairs(children) do
      if child.Text then
        if child.Text:GetText() == MOTION_SICKNESS_CHECKBOX then
          -- print("Found", child.Text:GetText(), MOTION_SICKNESS_CHECKBOX)
          foundMotionSicknessElement = true

          if not motionSicknessElement then
            -- print("Disabling motion sickness checkox.")
            -- Renamed to "Checkbox" in 11.0.0.
            if child.Checkbox then
              motionSicknessElement = child.Checkbox
            else
              motionSicknessElement = child.CheckBox
            end

            if not motionSicknessElementOriginalTooltipEnter then
              motionSicknessElementOriginalTooltipEnter = motionSicknessElement:GetScript("OnEnter")
              motionSicknessElementOriginalTooltipLeave = motionSicknessElement:GetScript("OnLeave")
            end

            -- Change tooltip.
            motionSicknessElement:SetScript("OnEnter", function(self)
              GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
              GameTooltip:AddLine("|cFFFF0000" .. L["Attention"] .. "|r", _, _, _, true)
              GameTooltip:AddLine(L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."]:format(MOTION_SICKNESS_CHECKBOX), _, _, _, true)
              GameTooltip:Show()
            end)
            motionSicknessElement:SetScript("OnLeave", function(self)
              GameTooltip:Hide()
            end)

          end

          break
        end
      end
    end

  end



  -- If the slider is used for something else and we have changed it before, undo the change.
  if mouseLookSpeedSlider and not foundMouseLookSpeedSlider then
    -- print("Re-enabling slider")
    mouseLookSpeedSlider.Slider:SetScript("OnEnter", MouseLookSpeedSliderOrignialTooltipEnter)
    mouseLookSpeedSlider.Slider:SetScript("OnLeave", MouseLookSpeedSliderOrignialTooltipLeave)
    if not mouseLookSpeedSlider.Slider:IsEnabled() then
      -- Function name "SetEnabled" introduced in 11.0.0.
      if mouseLookSpeedSlider.SetEnabled then
        mouseLookSpeedSlider:SetEnabled(false)
      else
        mouseLookSpeedSlider:SetEnabled_(false)
      end
    end
    mouseLookSpeedSlider = nil
  end


  -- If the checkbox is used for something else and we have changed it before, undo the change.
  if motionSicknessElement and not foundMotionSicknessElement then
    -- print("Re-enabling checkbox")
    motionSicknessElement:SetScript("OnEnter", motionSicknessElementOriginalTooltipEnter)
    motionSicknessElement:SetScript("OnLeave", motionSicknessElementOriginalTooltipLeave)

    motionSicknessElement = nil
  end




end)





-- Remember which view is active and which as been reset,
-- so when the user activates cameraSmoothStyle, we only reset to view 1 once.
local viewIsActive = {[1] = nil, [2] = nil, [3] = nil, [4] = nil, [5] = nil,}
local viewIsReset = {[1] = nil, [2] = nil, [3] = nil, [4] = nil, [5] = nil,}
hooksecurefunc("SetView", function(view)
  for i = 1, 5 do
    if i == tonumber(view) then
      viewIsActive[i] = true
    else
      viewIsActive[i] = false
    end
  end
end)
hooksecurefunc("SaveView", function(view) viewIsReset[tonumber(view)] = false end)
hooksecurefunc("ResetView", function(view) viewIsReset[tonumber(view)] = true end)

local validValuesCameraView = {[1] = true, [2] = true, [3] = true, [4] = true, [5] = true,}

hooksecurefunc("SetCVar", function(cvar, value, flag)
  -- print(cvar, value, flag)

  -- We are only handling cvar calls not done by DynamicCam.
  if flag == "DynamicCam" then return end


  -- Automatically undo forbidden motion sickness setting.
  if cvar == "CameraKeepCharacterCentered" then
    -- Remember what the user setup. We use GetCVar instead of value, because it returns 0/1 instead of false/true.
    DynamicCam.userCameraKeepCharacterCentered = GetCVar("CameraKeepCharacterCentered")
    -- print("|cFF0000FFStoring userCameraKeepCharacterCentered!|r", GetCVar("CameraKeepCharacterCentered"))

    if value == true or tonumber(value) == 1 then
      if tonumber(GetCVar("test_cameraOverShoulder")) ~= 0 then
        print("|cFFFF0000" .. L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] .. "|r")
        SetCVar("CameraKeepCharacterCentered", false, "DynamicCam")

      elseif tonumber(GetCVar("test_cameraDynamicPitch")) == 1 then
        print("|cFFFF0000" .. L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] .. "|r")
        SetCVar("CameraKeepCharacterCentered", false, "DynamicCam")
      end
    end


  -- As off 11.0.2 this is also needed for shoulder offset to take effect.
  elseif cvar == "CameraReduceUnexpectedMovement" then
    -- Remember what the user setup. We use GetCVar instead of value, because it returns 0/1 instead of false/true.
    DynamicCam.userCameraReduceUnexpectedMovement = GetCVar("CameraReduceUnexpectedMovement")
    -- print("|cFF0000FFStoring userCameraReduceUnexpectedMovement!|r", GetCVar("CameraReduceUnexpectedMovement"))

    if value == true or tonumber(value) == 1 then
      if tonumber(GetCVar("test_cameraOverShoulder")) ~= 0 then
        print("|cFFFF0000" .. L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] .. "|r")
        SetCVar("CameraReduceUnexpectedMovement", false, "DynamicCam")
      end
    end


  elseif cvar == "test_cameraOverShoulder" then

    -- If necessary, prevent Motion Sickness.
    if tonumber(value) ~= 0 then

      if tonumber(GetCVar("CameraKeepCharacterCentered")) == 1 then
        -- print("|cFFFF0000While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!|r")
        assert(DynamicCam.userCameraKeepCharacterCentered == GetCVar("CameraKeepCharacterCentered"))
        SetCVar("CameraKeepCharacterCentered", false, "DynamicCam")
      end
      if tonumber(GetCVar("CameraReduceUnexpectedMovement")) == 1 then
        -- print("|cFFFF0000While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!|r")
        assert(DynamicCam.userCameraReduceUnexpectedMovement == GetCVar("CameraReduceUnexpectedMovement"))
        SetCVar("CameraReduceUnexpectedMovement", false, "DynamicCam")
      end

    -- If no longer necessary, restore Motion Sickness.
    -- (cvar may become 0 "according to zoom level", so we check
    elseif DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "cvars", "test_cameraOverShoulder") == 0 then
      if DynamicCam.userCameraKeepCharacterCentered ~= GetCVar("CameraKeepCharacterCentered") then
        -- print("|cFF00FF00Restoring CameraKeepCharacterCentered!|r")
        SetCVar("CameraKeepCharacterCentered", DynamicCam.userCameraKeepCharacterCentered, "DynamicCam")
      end
      if DynamicCam.userCameraReduceUnexpectedMovement ~= GetCVar("CameraReduceUnexpectedMovement") then
        -- print("|cFF00FF00Restoring CameraReduceUnexpectedMovement!|r")
        SetCVar("CameraReduceUnexpectedMovement", DynamicCam.userCameraReduceUnexpectedMovement, "DynamicCam")
      end
    end


  elseif cvar == "test_cameraDynamicPitch" then

    -- If necessary, prevent Motion Sickness.
    if tonumber(value) == 1 then
      if tonumber(GetCVar("CameraKeepCharacterCentered")) == 1 then
        -- print("|cFFFF0000While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!|r")
        assert(DynamicCam.userCameraKeepCharacterCentered == GetCVar("CameraKeepCharacterCentered"))
        SetCVar("CameraKeepCharacterCentered", false, "DynamicCam")
      end

    -- If no longer necessary, restore Motion Sickness.
    else
      if DynamicCam.userCameraKeepCharacterCentered ~= GetCVar("CameraKeepCharacterCentered") then
        -- print("|cFF00FF00Restoring CameraKeepCharacterCentered!|r")
        SetCVar("CameraKeepCharacterCentered", DynamicCam.userCameraKeepCharacterCentered, "DynamicCam")
      end
    end




  -- https://github.com/Mpstark/DynamicCam/issues/40
  elseif cvar == "cameraView" and not validValuesCameraView[tonumber(value)] then
    print("|cFFFF0000" .. L["cameraView=%s prevented by DynamicCam!"]:format(value) .. "|r")
    SetCVar("cameraView", GetCVarDefault("cameraView"), "DynamicCam")

  -- Switch to a default view, if user switches to cameraSmoothStyle.
  elseif cvar == "cameraSmoothStyle" and value ~= "0" then
    -- The order (first reset then set) is important, because if you are already
    -- in view 1 and do a reset, it also sets the view. If this is followed by
    -- another setView, you get an undesired instant view switch.
    if not viewIsReset[1] then ResetView(1) end
    if not viewIsActive[1] then SetView(1) end
  end

end)










-- This is not working reliably. Especially the zoom when not set to default.
-- So we hide this for now.

-- local easingValues = {
  -- Linear = "Linear",
  -- InQuad = "In Quadratic",
  -- OutQuad = "Out Quadratic",
  -- InOutQuad = "In/Out Quadratic",
  -- OutInQuad = "Out/In Quadratic",
  -- InCubic = "In Cubic",
  -- OutCubic = "Out Cubic",
  -- InOutCubic = "In/Out Cubic",
  -- OutInCubic = "Out/In Cubic",
  -- InQuart = "In Quartic",
  -- OutQuart = "Out Quartic",
  -- InOutQuart = "In/Out Quartic",
  -- OutInQuart = "Out/In Quartic",
  -- InQuint = "In Quintic",
  -- OutQuint = "Out Quintic",
  -- InOutQuint = "In/Out Quintic",
  -- OutInQuint = "Out/In Quintic",
  -- InSine = "In Sine",
  -- OutSine = "Out Sine",
  -- InOutSine = "In/Out Sine",
  -- OutInSine = "Out/In Sine",
  -- InExpo = "In Exponent",
  -- OutExpo = "Out Exponent",
  -- InOutExpo = "In/Out Exponent",
  -- OutInExpo = "Out/In Exponent",
  -- InCirc = "In Circular",
  -- OutCirc = "Out Circular",
  -- InOutCirc = "In/Out Circular",
  -- OutInCirc = "Out/In Circular",
-- }


-- defaultEasing = {
  -- type = "group",
  -- name = "Default Easing Functions",
  -- order = 2,
  -- inline = true,
  -- args = {
    -- easingZoom = {
      -- type = "select",
      -- name = "Zoom Easing",
      -- desc = "Which easing function to use for zoom.",
      -- get = function() return DynamicCam.db.profile.easingZoom end,
      -- set = function(_, newValue) DynamicCam.db.profile.easingZoom = newValue; end,
      -- values = easingValues,
      -- order = 1,
    -- },
    -- easingYaw = {
      -- type = "select",
      -- name = "Yaw Easing",
      -- desc = "Which easing function to use for yaw.",
      -- get = function() return DynamicCam.db.profile.easingYaw end,
      -- set = function(_, newValue) DynamicCam.db.profile.easingYaw = newValue end,
      -- values = easingValues,
      -- order = 2,
    -- },
    -- easingPitch = {
      -- type = "select",
      -- name = "Pitch Easing",
      -- desc = "Which easing function to use for pitch.",
      -- get = function() return DynamicCam.db.profile.easingPitch end,
      -- set = function(_, newValue) DynamicCam.db.profile.easingPitch = newValue end,
      -- values = easingValues,
      -- order = 3,
    -- },
  -- },
-- },



