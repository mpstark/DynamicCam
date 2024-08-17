
---------------
-- LIBRARIES --
---------------
local LibCamera = LibStub("LibCamera-1.0")

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
local function round(num, numDecimalPlaces)
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

    name = "Reset",
    image = "Interface\\Transmogrify\\Transmogrify",
    imageCoords = resetButtonImageCoords,
    imageWidth = 25/1.5,
    imageHeight = 24/1.5,
    desc = "Reset to global default: " .. tooltipDefaultValue .."\n(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)",
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
          return "|cFF00FF00Currently overridden by the active situation \"" .. DynamicCam.db.profile.situations[DynamicCam.currentSituationID].name .. "\".\n|r"
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
    name = "Override Standard Settings",
    desc = "Checking this box allows you to define settings in this category that override the Standard Settings whenever this situation is active. Unchecking erases the Situation Settings for this category.",
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
        customPrefix = "Custom: "
      end

      if not SituationControlsAreDefault(id) then
        modifiedSuffix = "|cFFFF6600" .. "  (modified)" .. "|r"
      end

      -- print(id, situation.name)
      situationList[id] = prefix .. customPrefix .. situation.name .. " [Priority: " .. situation.priority .. "]" .. suffix .. modifiedSuffix
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
        if not forSituations then return "Standard Settings"
        else return "Situation Settings" end
      end,
    order = tabOrder,
    args = {

      help = {
        type = "description",
        name =
          function()
            local text = ""

            if not forSituations then

              text = "These Standard Settings are applied when either no situation is active or when the active situation has no Situation Settings set up overriding the Standard Settings."

              if DynamicCam.currentSituationID then
                text = text .. " |cFF00FF00The categories marked in green are currently overridden by the active situation. You will thus not see any effect of changing the Standard Settings of green categories while the overriding situation is active.|r"
              end

            else
              text = "These Situation Settings can override the Standard Settings when the respective situation is active."
            end

            return text .. "\n\n"
          end,
        order = 0,
      },


      zoomGroup = {
        type = "group",
        name =
          function()
            return ColoredNames("Mouse Zoom", zoomGroupVars, forSituations)
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
                name = "Maximum Camera Distance",
                desc = "How many yards the camera can zoom away from your character.\n|cff909090cvar: cameraDistanceMaxZoomFactor|r",
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
                name = "Camera Zoom Speed",
                desc = "How fast the camera can zoom.\n|cff909090cvar: cameraZoomSpeed|r",
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
                name = "Zoom Increments",
                desc = "How many yards the camera should travel for each \"tick\" of the mouse wheel.",
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
                name = "Use Reactive Zoom",
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
                    name = "Quick-Zoom Additional Increments",
                    desc = "How many yards per mouse wheel tick should be added when quick-zooming.",
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
                    name = "Quick-Zoom Enter Threshold",
                    desc = "How many yards the \"Reactive Zoom Target\" and the \"Actual Zoom Value\" have to be apart to enter quick-zooming.",
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
                    name = "Maximum Zoom Time",
                    desc = "The maximum time the camera should take to make \"Actual Zoom Value\" equal to \"Reactive Zoom Target\".",
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
            name = "Help",
            order = 6,
            inline = true,
            args = {

              toggleVisualAid = {
                type = "execute",
                name = "Toggle Visual Aid",
                func = function() DynamicCam:ToggleRZVA() end,
                order = 1,
                width = "full",
              },
              blank1 = {type = "description", name = " ", order = 1.1, },

              reactiveZoomDescription = {
                type = "description",
                name = "With DynamicCam's Reactive Zoom the mouse wheel controls the so called \"Reactive Zoom Target\". Whenever the \"Reactive Zoom Target\" and the \"Actual Zoom Value\" are different, DynamicCam changes the \"Actual Zoom Value\" until it matches the \"Reactive Zoom Target\" again.\n\nHow fast this zoom change is happening depends on \"Camera Zoom Speed\" and \"Maximum Zoom Time\". If \"Maximum Zoom Time\" is set low, the zoom change will always be executed fast, regardless of the \"Camera Zoom Speed\" setting. To achieve a slower zoom change, you must set \"Maximum Zoom Time\" to a higher value and \"Camera Zoom Speed\" to a lower value.\n\nTo enable faster zooming with faster mouse wheel movement, there is \"Quick-Zoom\": if the \"Reactive Zoom Target\" is further away from the \"Actual Zoom Value\" than the \"Quick-Zoom Enter Threshold\", the amount of \"Quick-Zoom Additional Increments\" is added to every mouse wheel tick.\n\nTo get a feeling of how this works, you can toggle the visual aid while finding your ideal settings. You can also freely move this graph by left-clicking and dragging it. A right-click closes it.",
                order = 2,
              },

              blank2 = {type = "description", name = "\n\n", order = 2.1, },

              enhancedMinZoom = {
                type = "toggle",
                name = "Enhanced minimal zoom-in",
                desc = "Reactive zoom makes it possible to zoom-in closer than level 1. You can achieve this by zooming out one mouse wheel tick from first person.\n\nWith \"Enhanced minimal zoom-in\" we force the camera to also stop at this minimal zoom level when zooming in, before it would snap into first person.\n\n|cFFFF0000Enabling \"Enhanced minimal zoom-in\" may cost up to 15% FPS when in CPU limited situations.|r",
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
                name = "|cFFFF0000/reload of the UI required!|r",
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
            return ColoredNames("Mouse Look", mouseLookGroupVars, forSituations)
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
                name = "Horizontal Speed",
                desc = "How much the camera yaws horizontally when in mouse look mode.\n|cff909090cvar: cameraYawMoveSpeed|r",
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
                name = "Vertical Speed",
                desc = "How much the camera pitches vertically when in mouse look mode.\n|cff909090cvar: cameraPitchMoveSpeed|r",
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
                name = "Help",
                order = 3,
                args = {
                  mouseLookDescription = {
                    type = "description",
                    name = "How much the camera moves when you move the mouse in \"mouse look\" mode; i.e. while the left or right mouse button is pressed.\n\nThe \"Mouse Look Speed\" slider of WoW's default interface settings controls horizontal and vertical speed at the same time: automatically setting horizontal speed to 2 x vertical speed. DynamicCam overrides this and allows you a more customized setup.",
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
            return ColoredNames("Horizontal Offset", shoulderOffsetGroupVars, forSituations)
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
                name = "Camera Over Shoulder Offset",
                order = 1,
                args = {

                  cameraOverShoulderDescription = {
                    type = "description",
                    name = "Positions the camera left or right from your character.\n|cff909090cvar: test_cameraOverShoulder|r\n\nFor this to come into effect, DynamicCam automatically temporarily disables WoW's motion sickness setting. So if you need the Motion Sickness setting, do not use the horizontal offset in these situations.\n\nWhen you are selecting your own character, WoW automatically switches to an offset of zero. There is nothing we can do about this. We also cannot do anything about offset jerks that may occur upon camera-to-wall collisions. A workaround is to use little to no offset while indoors.\n\nFurthermore, WoW strangely applies the offest differntly depending on player model or mount. If you prefer a constant offset, Ludius is working on another addon (CameraOverShoulder Fix) to resolve this.",
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
                name = "Adjust shoulder offset according to zoom level",
                order = 2,
                args = {

                  shoulderOffsetZoomEnabled = {
                    type = "toggle",
                    name = "Enable",
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
                    name = "Reset",
                    image = "Interface\\Transmogrify\\Transmogrify",
                    imageCoords = resetButtonImageCoords,
                    imageWidth = 25/1.5,
                    imageHeight = 24/1.5,
                    desc = "Reset to global defaults: " .. DynamicCam:GetSettingsDefault("shoulderOffsetZoomLowerBound") .." and " .. DynamicCam:GetSettingsDefault("shoulderOffsetZoomUpperBound") .. "\n(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)",
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
                    name = "No offset when below this zoom level:",
                    order = 2,
                    width = "full",
                    desc = "When the camera is closer than this zoom level, the offset has reached zero.",
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
                    name = "Real offset when above this zoom level:",
                    order = 3,
                    width = "full",
                    desc = "When the camera is further away than this zoom level, the offset has reached its set value.",
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
                    name = "Make the shoulder offset gradually transition to zero while zooming in. The two sliders define between what zoom levels this transition takes place. This setting is global and not situation-specific.",
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
            return ColoredNames("Vertical Pitch", pitchGroupVars, forSituations)
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
                name = "Enable",
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
                name = "Pitch (on ground)",
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
                name = "Pitch (flying)",
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
                name = "Down Scale",
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
                name = "Smart Pivot Cutoff Distance",
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
                name = "Help",
                order = 6,
                args = {
                  pitchDescription = {
                    type = "description",
                    name = "If the camera is pitched upwards (lower \"Pitch\" value), the \"Down Scale\" setting determines how much this comes into effect while looking at your character from above. Setting \"Down Scale\" to 0 nullifies the effect of an upwards pitch while looking from above. On the contrary, while you are not looking from above or if the camera is pitched downwards (greater \"Pitch\" value), the \"Down Scale\" setting has little to no effect.\n\nThus, you should first find your preferred \"Pitch\" setting while looking at your character from behind. Afterwards, if you have chosen an upwards pitch, find your preferred \"Down Scale\" setting while looking from above.\n\n\nWhen the camera collides with the ground, it normally performs an upwards pitch on the spot of the camera-to-ground collision. An alternative is that the camera moves closer to your character's feet while performing this pitch. The \"Smart Pivot Cutoff Distance\" setting determines the distance that the camera has to be inside of to do the latter. Setting it to 0 never moves the camera closer (WoW's default), whereas setting it to the maximum zoom distance of 39 always moves the camera closer.\n\n",
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
            return ColoredNames("Target Focus", targetFocusGroupVars, forSituations)
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
                name = "Enemy Target",
                order = 1,
                args = {

                  targetFocusEnemyEnable = {
                    type = "toggle",
                    name = "Enable",
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
                    name = "Horizontal Strength",
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
                    name = "Vertical Strength",
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
                name = "Interaction Target (NPCs)",
                order = 2,
                args = {

                  targetFocusInteractEnable = {
                    type = "toggle",
                    name = "Enable",
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
                    name = "Horizontal Strength",
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
                    name = "Vertical Strength",
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
                name = "Help",
                order = 3,
                args = {
                  targetFocusDescription = {
                    type = "description",
                    name = "If enabled, the camera automatically tries to bring the target closer to the center of the screen. The strength determines the intensity of this effect.\n\nIf \"Enemy Target Focus\" and \"Interaction Target Focus\" are both enabled, there seems to be a strange bug with the latter: When interacting with an NPC for the first time, the camera smoothly moves to its new angle as expected. But when you exit the interaction, it snaps immediately into its previous angle. When you then start the interaction again, it snaps again to the new angle. This is repeatable whenever talking to a new NPCs: only the first transition is smooth, all following are immediate.\nA workaround, if you want to use both \"Enemy Target Focus\" and \"Interaction Target Focus\", is to only activate \"Enemy Target Focus\" for DynamicCam situations in which you need it and in which NPC interactions are unlikely (like Combat).",
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
            return ColoredNames("Head Tracking", headTrackingGroupVars, forSituations)
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
                name = "Enable",
                order = 1,
                width = sliderWidth - 0.15,
                desc = "|cff909090cvar: test_cameraHeadMovement\nStrength\n\nThis could also be used as a continuous value between 0 and 1, but it is just multiplied with StandingStrength and MovingStrength respectively. So there is really no need for another slider.|r",
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
                name = "Strength (standing)",
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
                name = "Inertia (standing)",
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
                name = "Strength (moving)",
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
                name = "Inertia (moving)",
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
                name = "Inertia (first person)",
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
                name = "Range Scale",
                desc = "Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)\n|cff909090cvar: test_cameraHeadMovement\nRangeScale (slider value transformed)|r",
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
                                        round((DynamicCam:GetSettingsDefault("cvars", "test_cameraHeadMovementRangeScale") * 3.25) + 0.1625, 2)),
              blank7 = {type = "description", name = "\n\n", order = 7.2, },

              deadZone = {
                type = "range",
                order = 8,
                width = sliderWidth,
                name = "Dead Zone",
                desc = "Radius of head movement not affecting the camera. (See explanation below.)\n|cff909090cvar: test_cameraHeadMovement\nDeadZone (slider value / 10)|r\n|cffe00000Requires /reload to come into effect!|r",
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
                                            round(DynamicCam:GetSettingsDefault("cvars", "test_cameraHeadMovementDeadZone") * 10, 2)),


              headTrackingDescriptionGroup = {
                type = "group",
                name = "Help",
                order = 9,
                args = {
                  headTrackingDescription = {
                    type = "description",
                    name = "With head tracking enabled the camera follows the movement of your character's head. (While this can be a benefit for immersion, it may also cause nausea if you are prone to motion sickness.)\n\nThe \"Strength\" setting determines the intensity of this effect. Setting it to 0 disables head tracking. The \"Inertia\" setting determines how fast the camera reacts to head movements. Setting it to 0 also disables head tracking. The three cases \"standing\", \"moving\" and \"first person\" can be set up individually. There is no \"Strength\" setting for \"first person\" as it assumes the \"Strength\" settings of \"standing\" and \"moving\" respectively. If you want to enable or disable \"first person\" exclusively, use the \"Inertia\" sliders to disable the unwanted cases.\n\nWith the \"Range Scale\" setting you can set the camera distance beyond which head tracking is reduced or disabled. For example, with the slider set to 30 you will have no head tracking when the camera is more than 30 yards away from your character. However, there is a gradual transition from full head tracking to no head tracking, which starts at one third of the slider value. For example, with the slider value set to 30 you have full head tracking when the camera is closer than 10 yards. Beyond 10 yards, head tracking gradually decreases until it is completely gone beyond 30 yards. Hence, the slider's maximum value is 117 allowing for full head tracking at the maximum camera distance of 39 yards. (Hint: Use our \"Mouse Zoom\" visual aid to check the current camera distance while setting this up.)\n\nThe \"Dead Zone\" setting can be used to ignore smaller head movements. Setting it to 0 has the camera follow every slightest head movement, whereas setting it to a greater value results in it following only greater movements. Notice, that changing this setting only comes into effect after reloading the UI (type /reload into the console).",
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
    name = "Situations",
    order = tabOrder,

    childGroups = "tab",

    args = {

      selectedSituation = {
        type = "select",
        name = "Select a situation to setup",
        desc = "\n|cffffcc00Colour codes:|r\n|cFF808A87- Disabled situation.|r\n- Enabled situation.\n|cFF00FF00- Enabled and currently active situation.|r\n|cFF63B8FF- Enabled situation with fulfilled condition but lower priority than the currently active situation.|r\n|cFFFF6600- Modified stock \"Situation Controls\" (reset recommended).|r\n|cFFEE0000- Erroneous \"Situation Controls\" (changes required).|r",
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
        name = "Enable",
        desc =
          function()
            return "If this box is checked, DynamicCam will enter the situation \"" .. S.name .. "\" whenever its condition is fulfilled and no other situation with higher priority is active."
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
        width = 0.5,
        order = 2,
      },
      blank2 = {type = "description", name = " ", width = 0.1, order = 2.5, },

      deleteCustom = {
        type = "execute",
        name = "-",
        desc =
          function()
            return "Delete custom situation \"" .. S.name .. "\".\n(There will be no 'Are you sure?' prompt!)"
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
        desc = "Create a new custom situation.",
        func = function() DynamicCam:PopupCreateCustomProfile() end,
        order = 4,
        width = 0.23,
      },


      situationSettings = CreateSettingsTab(5, true),


      situationActions = {

        type = "group",
        name = "Situation Actions",
        order = 6,

        args = {

          help = {
            type = "description",
            name = "Setup stuff to happen while in a situation or when entering/exiting it.\n\n",
            order = 0,
          },

          viewZoomSettings = {
            type = "group",
            name =
              function()
                return GreyWhenInactive("Zoom/View", S.viewZoom.enabled)
              end,
            order = 1,
            args = {

              viewZoomToggle = {
                type = "toggle",
                name = "Enable",
                desc = "Zoom to a certain zoom level or switch to a saved camera view when entering this situation.",
                get =
                  function()
                    return S.viewZoom.enabled
                  end,
                set =
                  function(_, newValue)
                    S.viewZoom.enabled = newValue
                  end,
                width = "half",
                order = 1,
              },
              viewZoomReset = {
                type = "execute",
                -- name = CreateAtlasMarkup("transmog-icon-revert-small", 20, 20),
                name = "Reset",
                image = "Interface\\Transmogrify\\Transmogrify",
                imageCoords = resetButtonImageCoords,
                imageWidth = 25/1.5,
                imageHeight = 24/1.5,
                desc = "Reset to global defaults!\n(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)",
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
                    name = "Set Zoom or Set View",
                    desc = "\nSet Zoom: Zoom to a given zoom level with advanced options of transition time and zoom conditions.\n\nSet View: Switch to a saved camera view consisting of a fix zoom level and camera angle.",
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
                      ["zoom"] = "Set Zoom",
                      ["view"] = "Set View",
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
                    name = "Set View",
                    order = 3,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "view"
                      end,
                    args = {

                      view = {
                        type = "select",
                        name = "Set view to saved view:",
                        desc = "Select the saved view to switch to when entering this situation.",
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
                        name = "Instant",
                        desc = "Make view transitions instant.",
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
                        name = "Restore view when exiting",
                        desc = "When exiting the situation restore the camera position to what it was at the time of entering the situation.",
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
                        name =
[[|cFFEE0000Attention:|r You are using WoW's "Camera Following Styles" that automatically put the camera behind the player. This does not work while you are in a customized saved view. It is possible to use customized saved views for situations in which camera following is not needed (e.g. NPC interaction). But after exiting the situation you have to return to a non-customized default view in order to make the camera following work again.]],
                      },

                      viewRestoreToDefault = {
                        type = "select",
                        name = "Restore to default view:",
                        desc =
[[Select the default view to return to when exiting this situation.

View 1:   Zoom 0, Pitch 0
View 2:   Zoom 5.5, Pitch 10
View 3:   Zoom 5.5, Pitch 20
View 4:   Zoom 13.8, Pitch 30
View 5:   Zoom 13.8, Pitch 10]],
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

                            local returnString = "|cFFEE0000WARNING:|r You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view.\n"

                            for usedView, usedViewSituationList in pairs(usedViews) do

                              -- We know that at least one other situation used this view.
                              if usedDefaultViews[usedView] then

                                returnString = returnString .. "\n\n- View " .. usedView .. " is used as saved view in the situations:\n"

                                for usedViewSituationId in pairs(usedViewSituationList) do
                                  returnString = returnString .. "    - " .. DynamicCam.db.profile.situations[usedViewSituationId].name .. "\n"
                                end
                                returnString = returnString .. "   and as restore-to-default view in the situations:\n"

                                for usedDefaultViewSituationId in pairs(usedDefaultViews[usedView]) do
                                  returnString = returnString .. "    - " ..  DynamicCam.db.profile.situations[usedDefaultViewSituationId].name .. "\n"
                                end

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
                    name = "Help",
                    order = 4,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "view"
                      end,
                    args = {
                      zoomDescription = {
                        type = "description",
                        name =
[[WoW allows to save up to 5 custom camera views. View 1 is used by DynamicCam to save the camera position when entering a situation, such that it can be restored upon exiting the situation again, if you check the "Restore" box above. This is particularly nice for short situations like NPC interaction, allowing to switch to one view while talking to the NPC and afterwards back to what the camera was before. This is why View 1 cannot be selected in the above drop down menu of saved views.

Views 2, 3, 4 and 5 can be used to save a custom camera positions. To save a view, simply bring the camera into the desired zoom and angle. Then type the following command into the console (with # being the view number 2, 3, 4 or 5):

  /saveView #

Or for short:

  /sv #

Notice that the saved views are stored by WoW. DynamicCam only stores which view numbers to use. Thus, when you import a new DynamicCam situation profile with views, you probably have to set and save the appropriate views afterwards.


DynamicCam also provides a console command to switch to a view irrespective of entering or exiting situations:

  /setView #

To make the view transition instant, add an "i" after the view number. E.g. to immediately switch to the saved View 3 enter:

  /setView 3 i

]],
                      },
                    },
                  },


                  zoomBox = {
                    type = "group",
                    name = "Set Zoom",
                    order = 3,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                    args = {

                      transitionTime = {
                        type = "range",
                        name = "Zoom Transition Time",
                        desc = "The time in seconds it takes to transition to the new zoom value.\n\nIf set lower than possible, the transition will be as fast as the current camera zoom speed allows (adjustable in the DynamicCam \"Mouse Zoom\" settings).\n\nIf a situation assigns the variable \"this.transitionTime\" in its on-enter script (see \"Situation Controls\"), the setting here is overriden. This is done e.g. in the \"Hearth/Teleport\" situation to allow a transition time for the duration of the spell cast.",
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
                        name = "Zoom Type",
                        desc = "\nSet: Always set the zoom to this value.\n\nOut: Only set the zoom, if the camera is currently closer than this.\n\nIn: Only set the zoom, if the camera is currently further away than this.\n\nRange: Zoom in, if further away than the given maximum. Zoom out, if closer than the given minimum. Do nothing, if the current zoom is within the [min, max] range.",
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
                          ["set"] = "Set",
                          ["out"] = "Out",
                          ["in"] = "In",
                          ["range"] = "Range",
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
                        name = "Don't slow",
                        desc = "Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows.",
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
                        name = "Zoom Value",
                        desc =
                          function()
                            if S.viewZoom.zoomType == "set" then
                              return "Zoom to this zoom level."
                            elseif S.viewZoom.zoomType == "out" then
                              return "Zoom out to this zoom level, if the current zoom level is less than this."
                            elseif S.viewZoom.zoomType == "in" then
                              return "Zoom in to this zoom level, if the current zoom level is greater than this."
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
                        name = "Zoom Min",
                        desc = "Zoom out to this zoom level, if the current zoom level is less than this.",
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
                        name = "Zoom Max",
                        desc = "Zoom in to this zoom level, if the current zoom level is greater than this.",
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
                    name = "Restore Zoom",
                    order = 4,
                    disabled = false,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                    args = {

                      zoomRestoreSettingDescription = {
                        type = "description",
                        name = "When you exit a situation (or exit the default of no situation being active), the current zoom level is temporarily saved, such that it could be restored once you enter this situation the next time. Here you can select how this is handled.\n\nThis setting is global for all situations.",
                        order = 0,
                      },

                      zoomRestoreSetting = {
                        type = "select",
                        name = "Restore Zoom Mode",
                        desc = "\nNever: When entering a situation, the actual zoom setting (if any) of the entering situation is applied. No saved zoom is taken into account.\n\nAlways: When entering a situation, the last saved zoom of this situation is used. Its actual setting is only taken into account when entering the situation for the first time after login.\n\nAdaptive: The saved zoom is only used under certain circumstances. E.g. only when returning to the same situation you came from or when the saved zoom fulfills the criteria of the situation's \"in\", \"out\" or \"range\" zoom settings.",
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
                          ["never"] = "Never",
                          ["always"] = "Always",
                          ["adaptive"] = "Adaptive",
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
                    name = "Help",
                    order = 5,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                    args = {
                      zoomDescription = {
                        type = "description",
                        name =
[[To determine the current zoom level, you can either use the "Visual Aid" (toggled in DynamicCam's "Mouse Zoom" settings) or use the console command:

  /zoomInfo

Or for short:

  /zi]],
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
                return GreyWhenInactive("Rotation", S.rotation.enabled)
              end,
            order = 2,
            args = {

              rotationToggle = {
                type = "toggle",
                name = "Enable",
                desc = "Start a camera rotation when this situation is active.",
                get =
                  function()
                    return S.rotation.enabled
                  end,
                set =
                  function(_, newValue)
                    S.rotation.enabled = newValue
                    ApplyContinuousRotation()
                  end,
                width = "half",
                order = 1,
              },
              rotationReset = {
                type = "execute",
                -- name = CreateAtlasMarkup("transmog-icon-revert-small", 20, 20),
                name = "Reset",
                image = "Interface\\Transmogrify\\Transmogrify",
                imageCoords = resetButtonImageCoords,
                imageWidth = 25/1.5,
                imageHeight = 24/1.5,
                desc = "Reset to global defaults!\n(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)",
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
                    name = "Rotation Type",
                    desc = "\nContinuously: The camera is rotating horizontally all the time while this situation is active. Only advisable for situations in which you are not mouse-moving the camera; e.g. teleport spell casting, taxi or AFK. Continuous vertical rotation is not possible as it would stop at the perpendicular upwards or downwards view.\n\nBy Degrees: After entering the situation, change the current camera yaw (horizontal) and/or pitch (vertical) by the given amount of degrees.",
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
                      ["continuous"] = "Continuously",
                      ["degrees"] = "By Degrees",
                    },
                    width = "full",
                    order = 1,
                  },
                  blank1 = {type = "description", name = "\n\n", order = 1.1, },

                  rotationTime = {
                    type = "range",
                    name =
                      function()
                        if S.rotation.rotationType == "continuous" then
                          return "Acceleration Time"
                        else
                          return "Rotation Time"
                        end
                      end,
                    desc =
                      function()
                        if S.rotation.rotationType == "continuous" then
                          return "If you set a time greater than 0 here, the continuous rotation will not immediately start at its full rotation speed but will take that amount of time to accelerate. (Only noticeable for relatively high rotation speeds.)"
                        else
                          return "How long it should take to assume the new camera angle. If a too small value is given here, the camera might rotate too far, because we only check once per rendered frame if the desired angle is reached.\n\nIf a situation assigns the variable \"this.rotationTime\" in its on-enter script (see \"Situation Controls\"), the setting here is overriden. This is done e.g. in the \"Hearth/Teleport\" situation to allow a rotation time for the duration of the spell cast."
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
                    name = "Rotation Speed",
                    desc = "Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy...",
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
                    name = "Yaw (-Left/Right+)",
                    desc = "Degrees to yaw (left or right).",
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
                    name = "Pitch (-Down/Up+)",
                    desc = "Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view.",
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
                    name = "Rotate Back",
                    desc = "When exiting the situation, rotate back by the amount of degrees (modulo 360) rotated since entering the situation. This effectively brings you to the pre-entering camera position, unless you have in between changed the view angle with your mouse.\n\nIf you are entering a new situation with a rotation setting of its own, the \"rotate back\" of the exiting situation is ignored.",
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
                    name = "Rotate Back Time",
                    desc = "The time it takes to rotate back. If a too small value is given here, the camera might rotate too far, because we only check once per rendered frame if the desired angle is reached.",
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
                return GreyWhenInactive("Fade Out UI", S.hideUI.enabled)
              end,
            order = 3,
            args = {
              hideUIToggle = {
                type = "toggle",
                name = "Enable",
                desc = "Fade out or hide (parts of) the UI when this situation is active.",
                get =
                  function()
                    return S.hideUI.enabled
                  end,
                set =
                  function(_, newValue)
                    S.hideUI.enabled = newValue
                    ApplyUIFade()
                  end,
                width = "half",
                order = 1,
              },
              hideUIReset = {
                type = "execute",
                -- name = CreateAtlasMarkup("transmog-icon-revert-small", 20, 20),
                name = "Reset",
                image = "Interface\\Transmogrify\\Transmogrify",
                imageCoords = resetButtonImageCoords,
                imageWidth = 25/1.5,
                imageHeight = 24/1.5,
                desc = "Reset to global defaults!\n(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)",
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
                name = "Adjust to Immersion",
                desc = "Many people use the Addon Immersion in combination with DynamicCam. Immersion has some hide UI features of its own which come into effect during NPC interaction. Under certain circumstances, DynamicCam's hide UI overrides that of Immersion. To prevent this, make your desired setting here in DynamicCam. Click this button to use the same fade-in and fade-out times as Immersion. For even more options, check out Ludius's other addon called \"Immersion ExtraFade\".",
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
                    name = "Fade Out Time",
                    desc = "Seconds it takes to fade out the UI when entering the situation.",
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
                    name = "Fade In Time",
                    desc = "Seconds it takes to fade the UI back in when exiting the situation.\n\nWhen you exit a situation while entering another situation, the fade out time of the entering situation is used for the transition.",
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
                        local text = "Hide entire UI"
                        if S.hideUI.hideEntireUI then
                          return "|cFFFF4040" .. text .. "|r"
                        else
                          return text
                        end
                      end,
                    desc = "There is a difference between a \"hidden\" UI and a \"just faded out\" UI: the faded-out UI elements have an opacity of 0 but can still be interacted with. Since DynamicCam 2.0 we are automatically hiding most UI elements if their opacity is 0. Thus, this option of hiding the entire UI after fade out is more of a relic. A reason to still use it may be to avoid unwanted interactions (e.g. mouse-over tooltips) of UI elements DynamicCam is still not hiding properly.\n\nThe opacity of the hidden UI is of course 0, so you cannot choose a different opacity nor can you keep any UI elements visible (except the FPS indicator).\n\nDuring combat we cannot change the hidden status of protected UI elements. Hence, such elements are always set to \"just faded out\" during combat. Notice that the opacity of the Minimap \"blips\" cannot be reduced. Thus, if you try to hide the Minimap, the \"blips\" are always visible during combat.\n\nWhen you check this box for the currently active situation, it will not be applied at once, because this would also hide this settings frame. You have to enter the situation for it to take effect, which is also possible with the situation \"Enable\" checkbox above.\n\nAlso notice that hiding the entire UI cancels Mailbox or NPC interactions. So do not use it for such situations!",
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
                    name = "Keep FPS indicator",
                    desc = "Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R).",
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
                    name = "Fade Opacity",
                    desc = "Fade the UI to this opacity when entering the situation.",
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
                    name = "Excluded UI elements",
                    order = 6,
                    disabled =
                      function()
                        return not S.hideUI.enabled or S.hideUI.hideEntireUI
                      end,
                    args = {

                      keepAlertFrames = {
                        type = "toggle",
                        name = "Keep Alerts",
                        desc = "Still show alert popups from completed achievements, Covenant Renown, etc.",
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
                        name = "Keep Tooltip",
                        desc = "Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements.",
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
                        name = "Keep Minimap",
                        desc = "Do not fade out the Minimap.\n\nNotice that we cannot reduce the opacity of the \"blips\" on the Minimap. These can only be hidden together with the whole Minimap, when the UI is faded to 0 opacity.",
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
                        name = "Keep Chat Box",
                        desc = "Do not fade out the chat box.",
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
                        name = "Keep Tracking Bar",
                        desc = "Do not fade out the tracking bar (XP, AP, reputation).",
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
                        name = "Keep Party/Raid",
                        desc = "Do not fade out the Party/Raid frame.",
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
                        name = "Keep Encounter Frame (Dragonriding Vigor)",
                        desc = "Do not fade out the Encounter Frame, which while dragonriding is the Vigor display.",
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
                        type = 'toggle',
                        name = "Keep additional frames",
                        desc = "The text box below allows you to define any frame you want to keep during NPC interaction.\n\nUse the console command /fstack to learn the names of frames.\n\nFor example, you may want to keep the buff icons next to the Minimap to be able to dismount during NPC interaction by clicking the appropriate icon.",
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
                        name = "Custom frames to keep",
                        desc = "Separated by commas.",
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
                    name = "Emergency Fade In",
                    order = 7,
                    disabled =
                      function()
                        return not S.hideUI.enabled
                      end,
                    args = {
                      emergencyShowEscEnabled = {
                        type = "toggle",
                        name = "Pressing Esc fades the UI back in.",
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
                      headTrackingDescription = {
                        type = "description",
                        name =
[[Sometimes you need to show the UI even in situations where you normaly want it hidden. Older versions of DynamicCam established that the UI is shown whenever the Esc key is pressed. The downside of this is that the UI is also shown when the Esc key is used for other purposes like closing windows, cancelling spell casting etc. Unchecking the above checkbox disables this.

Notice however that you can lock yourself out of the UI this way! A better alternative to the Esc key are the following console commands, which show or hide the UI according to the current situation's "Fade Out UI" settings:

    /showUI
    /hideUI

For a convenient fade-in hotkey, put /showUI into a macro and assign a key to it in your "bindings-cache.wtf" file. E.g.:

    bind ALT+F11 MACRO Your Macro Name

If editing the "bindings-cache.wtf" file puts you off, you could use a keybind addon like "BindPad".

Using /showUI or /hideUI without any arguments takes the current situation's fade in or fade out time. But you can also provide a different transition time. E.g.:

    /showUI 0

to show the UI without any delay.]],
                        order = 2,
                      },
                    },
                  },
                },
              },
              blank2 = {type = "description", name = " ", order = 2.2, },

              hideUIHelpGroup = {
                type = "group",
                name = "Help",
                order = 3,
                inline = true,
                args = {
                  hideUIHelpDescription = {
                    type = "description",
                    name = "While setting up your desired UI fade effects, it can be annoying when this \"Interface\" settings frame fades out as well. If this box is checked, it will not be faded out.\n\nThis setting is global for all situations.",
                    order = 1,
                  },
                  settingsPanelIgnoreParentAlpha = {
                    type = "toggle",
                    name = "Do not fade out this \"Interface\" settings frame.",
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
        name = function() return ColourTextErrorOrModified("Situation Controls") end,
        order = 7,
        args = {

          help = {
            type = "description",
            name = "Here you control when a situation is active. Knowledge of the WoW UI API may be required. If you are happy with the stock situations of DynamicCam, just ignore this section. But if you want to create custom situations, you can check the stock situations here. You can also modify them, but beware: your changed settings will persist even if future versions of DynamicCam introduce important updates.\n\n",
            order = 0,
          },

          priority = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified("Priority", "value", "priority")
              end,
            order = 1,
            args = {

              priority = {
                type = "input",
                name = "Priority",
                desc = "The priority of this situation.\nMust be a number.",
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
                name = "Restore stock setting",
                desc =
                  function()
                    return "Your \"Priority\" deviates from the stock setting for this situation (".. DynamicCam.defaults.profile.situations[SID].priority .. "). Click here to restore it."
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
                name = "Help",
                inline = true,
                order = 3,
                args = {
                  priorityDescription = {
                    type = "description",
                    name = "If the conditions of several different DynamicCam situations are fulfilled at the same time, the situation with the highest priority is entered. For example, whenever the condition of \"World Indoors\" is fulfilled, the condition of \"World\" is fulfilled as well. But as \"World Indoor\" has a higher priority than \"World\", it is prioritised. You can also see the priorities of all situations in the drop down menu above.\n\n",
                  },
                },
              },
            },
          },

          events = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified("Events", "events", "events")
              end,
            order = 2,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "events" then
                      return "|cFFEE0000Error message:\n\n" .. S.errorMessage .. "|r\n\n"
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
                name = "Events",
                desc = "Separated by commas.",
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
                name = "Restore stock setting",
                desc = "Your \"Events\" deviate from the default for this situation. Click here to restore them.",
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
                name = "Help",
                inline = true,
                order = 3,
                args = {
                  eventsDescription = {
                    type = "description",
                    name =
[[Here you define all the in-game events upon which DynamicCam should check the condition of this situation, to enter or exit it if applicable.

You can learn about in-game events using WoW's Event Log.
To open it, type this into the console:

  /eventtrace

A list of all possible events can also be found here:
https://warcraft.wiki.gg/wiki/Events

]],

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
                return ColourTextErrorOrModified("Initialisation", "script", "executeOnInit")
              end,
            order = 3,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "executeOnInit" then
                      return "|cFFEE0000Error message:\n\n" .. S.errorMessage .. "|r\n\n"
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
                name = "Initialisation Script",
                desc = "Lua code using the WoW UI API.",
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
                name = "Restore stock setting",
                desc = "Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it.",
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
                name = "Help",
                inline = true,
                order = 3,
                args = {
                  initialisationDescription = {
                    type = "description",
                    name =
[[The initialisation script of a situation is run once when DynamicCam is loaded (and also when the situation is modified). You would typically put stuff into it which you want to reuse in any of the other scripts (condition, on-enter, on-exit). This can make these other scripts a bit shorter.

For example, the initialisation script of the "Hearth/Teleport" situation defines the table "this.spells", which includes the spell IDs of teleport spells. The condition script can then simply access "this.spells" every time it is executed.

Like in this example, you can share any data object between the scripts of a situation by putting it into the "this" table.

]],
                  },
                },
              },
            },
          },

          condition = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified("Condition", "script", "condition")
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
                name = "Condition Script",
                desc = "Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active.",
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
                name = "Restore stock setting",
                desc = "Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it.",
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
                name = "Help",
                inline = true,
                order = 3,
                args = {
                  conditionDescription = {
                    type = "description",
                    name =
[[The condition script of a situation is run every time an in-game event of this situation is triggered. The script should return "true" if and only if this situation should be active.

For example, the condition script of the "City" situation uses the WoW API function "IsResting()" to check if you are currently in a resting zone:

  return IsResting()

Likewise, the condition script of the "City - Indoors" situation also uses the WoW API function "IsIndoors()" to also check if you are indoors:

  return IsResting() and IsIndoors()

A list of WoW API functions can be found here:
https://warcraft.wiki.gg/wiki/World_of_Warcraft_API

]],
                  },
                },
              },
            },
          },

          executeOnEnter = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified("Entering", "script", "executeOnEnter")
              end,
            order = 5,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "executeOnEnter" then
                      return "|cFFEE0000Error message:\n\n" .. S.errorMessage .. "|r\n\n"
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
                name = "On-Enter Script",
                desc = "Lua code using the WoW UI API.",
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
                name = "Restore stock setting",
                desc = "Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it.",
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
                name = "Help",
                inline = true,
                order = 3,
                args = {
                  executeOnEnterDescription = {
                    type = "description",
                    name =
[[The on-enter script of a situation is run every time the situation is entered.

So far, the only example for this is the "Hearth/Teleport" situation in which we use the WoW API function "UnitCastingInfo()" to determine the cast duration of the current spell. We then assign this to the variables "this.transitionTime" and "this.rotationTime", such that a zoom or rotation (see "Situation Actions") can take exactly as long as the spell cast. (Not all teleport spells have the same cast times.)

]],
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
                        return ColourTextErrorOrModified("Exiting", "script", "executeOnExit")
                    else
                        return ColourTextErrorOrModified("Exiting", "value", "delay")
                    end
                end,
            order = 6,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "executeOnExit" then
                      return "|cFFEE0000Error message:\n\n" .. S.errorMessage .. "|r\n\n"
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
                name = "On-Exit Script",
                desc = "Lua code using the WoW UI API.",
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
                    name = "Restore stock setting",
                    desc = "Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it.",
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
                name = "Exit Delay",
                desc = "Wait for this many seconds before exiting this situation.",
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
                    name = "Restore stock setting",
                    desc = "Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it.",
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

              executeOnEnterDescriptionGroup = {
                type = "group",
                name = "Help",
                inline = true,
                order = 5,
                args = {
                  executeOnEnterDescription = {
                    type = "description",
                    name =
[[The on-exit script of a situation is run every time the situation is exited. So far, no situation is using this.

The delay determines how many seconds to wait before exiting the situation. So far, the only example for this is the "Fishing" situation, where the delay gives you time to re-cast your fishing rod without exiting the situation.

]],
                  },
                },
              },

            },
          },

        },
      },


      export = {

        type = "group",
        name = "Export",
        order = 8,

        args = {

          description = {
            type = "description",
            name = "Coming soon(TM).",
            order = 1,
          },

          -- TODO
          -- exportFrame = {
            -- type = "input",
            -- name = "Situation Export",
            -- dialogControl = "aceInvader",
          -- },
        },
      },

      import = {

        type = "group",
        name = "Import",
        order = 9,

        args = {

          description = {
              type = "description",
              name = "Coming soon(TM).",
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




local welcomeMessage = [[We're glad that you're here and we hope that you have fun with the addon.

DynamicCam (DC) was started in May 2016 by mpstark when the WoW devs at Blizzard introduced the experimental ActionCam features into the game. The main purpose of DC has been to provide a user interface for the ActionCam settings. Within the game, the ActionCam is still designated as "experimental" and there has been no sign from Blizzard to develop it further. There are some shortcomings, but we should be thankful that ActionCam was left in the game for enthusiast like us to use. :-) DC does not just allow you to change the ActionCam settings but to have different settings for different game situations. Not related to ActionCam, DC also provides features regarding camera zoom and UI fade-out.

The work of mpstark on DC continued until August 2018. While most features worked well for a substantial user base, mpstark had always considered DC to be in beta state and due to his waning investment in WoW he ended up not resuming his work. At that time, Ludius had already begun making adjustments to DC for himself, which was noticed by Weston (aka dernPerkins) who in early 2020 managed to get in touch with mpstark leading to Ludius taking over the development. The first non-beta version 1.0 was released in May 2020 including Ludius's adjustments up to that point. Afterwards, Ludius began to work on an overhaul of DC resulting in version 2.0 being released in Autum 2022.

When mpstark started DC, his focus was on making most customisations in-game instead of having to change the source code. This made it easier to experiment particularly with the different game situations. From version 2.0 on, these advanced settings have been moved to a special section called "Situation Controls". Most users will probably never need it, but for "power users" it is still available. A hazard of making changes there is that saved user settings always override DC's stock settings, even if new versions of DC bring updated stock settings. Hence, a warning is displayed at the top of this page whenever you have stock situations with modified "Situation Controls".

If you think one of DC's stock situations should be changed, you can always create a copy of it with your changes. Feel free to export this new situation and post it on DC's curseforge page. We may then add it as a new stock situtation of its own. You are also welcome to export and post your entire DC profile, as we are always looking for new profile presets which allow newcomers an easier entry to DC. If you find a problem or want to make a suggestion, just leave a note in the curseforge comments or even better use the Issues on GitHub. If you'd like to contribute, also feel free to open a pull request there.

Here are some handy slash commands:

    `/dynamiccam` or `/dc` opens this menu.
    `/zoominfo` or `/zi` prints out the current zoom level.

    `/zoom #1 #2` zooms to zoom level #1 in #2 seconds.
    `/yaw #1 #2` yaws the camera by #1 degrees in #2 seconds (negative #1 to yaw right).
    `/pitch #1 #2` pitches the camera by #1 degrees (negative #1 to pitch up).


]]




local about = {
  type = "group",
  name = "About",
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
          name = "|cFFEE0000WARNING!|r",
          order = 1,
        },
        message = {
          type = "description",
          name =
            function()
              local returnString = "The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"

              for situationId, situation in pairs(DynamicCam.defaults.profile.situations) do
                if not SituationControlsAreDefault(situationId) then
                  returnString = returnString .. "  - " .. situation.name .. "\n"
                end
              end

              returnString = returnString .. "\nIf you are doing this on purpose, it is fine. Just be aware that any updates to these settings by the DynamicCam developers will always be overridden by your modified (possibly outdated) version. You can check the \"Situation Controls\" tab of each situation for details. If you are not aware of any \"Situation Controls\" modifications from your side and simply want to restore the stock control settings for *all* situations, hit this button:"

              return returnString

            end,
          order = 2,
        },
        restoreDefaultsButton = {
          type = "execute",
          name = "Restore all stock Situation Controls",
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
          name = "Hello and welcome to DynamicCam!",
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
  name = "Profiles",
  order = 4,
  childGroups = "tab",
  args = {

    manageProfiles = {
      type = "group",
      name = "Manage Profiles",
      order = 1,
      args = {

        blank99 = {type = "description", name = " ", order = 99, },

        warning = {
          type = "group",
          name = "Help",
          inline = true,
          order = 100,
          args = {
            priorityDescription = {
              type = "description",
              name = "Like many addons, DynamicCam uses the \"AceDB-3.0\" library to manage profiles. What you have to understand is that there is nothing like \"Save Profile\" here. You can only create new profiles and you can copy settings from another profile into the currently active one. Whatever change you make for the currently active profile is immediately saved! There is nothing like \"cancel\" or \"discard changes\". The \"Reset Profile\" button only resets to the global default profile.\n\nSo if you like your DynamicCam settings, you should create another profile into which you copy these settings as a backup. When you don't use this backup profile as your active profile, you can experiment with the settings and return to your original profile at any time by selecting your backup profile in the \"Copy from\" box.\n\nIf you want to switch profiles via macro, you can use the following:\n/run DynamicCam.db:SetProfile(\"Profile name here\")\n\n",
            },
          },
        },
      },
    },

    presets = {
      type = "group",
      name = "Profile presets",
      order = 2,
      args = {
        description = {
          type = "description",
          name = "Coming soon(TM).",
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
      name = "Import / Export",
      order = 3,
      args = {
        description = {
          type = "description",
          name = "Coming soon(TM).",
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
    name = "DynamicCam",
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




-- Create stuff, but all width dependent things have to be (re-)done in the OnWidthSet function.
local function BuildSituationExportFrame(widget)

  local f = widget.frame

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
    -- testFrame.myLabel:SetFont("Fonts\\FRIZQT__.TTF", 12)
    -- testFrame.myLabel:SetTextColor(0.8, 0.8, 0.8)
    -- testFrame.myLabel:SetJustifyH("LEFT")
    -- testFrame.myLabel:SetPoint("TOPLEFT", testFrame, "TOPLEFT")
    -- testFrame.myLabel:SetPoint("TOPRIGHT", testFrame, "TOPRIGHT")
    -- testFrame.myLabel:SetText("TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST TEST")
  -- end




  -- Whenever OnWidthSet() is called, we set the height of frames to the height of their children frames.
  widget.AdjustHeightFunction = widget.AdjustHeightFunction or function(self)

    -- -- For multi-line text labels with automatic line breaks you may have to
    -- -- reset the label height back to the string height here. Because for some reason
    -- -- the label may get reduced to one line (problby because the width is temporarily
    -- -- undefined) in the process of switching GUI tabs.
    -- -- This is also the place where have to set the height of frames, whose height should
    -- -- depend on a text's height.
    -- local newHeight = testFrame.myLabel:GetStringHeight()
    -- testFrame.myLabel:SetHeight(newHeight)
    -- testFrame:SetHeight(newHeight)

    local f = self.frame
    local cf = f.contentFrame

    -- Set the contentFrame to the height of all its children.
    cf:SetHeight(cf.situationSettingsFrame:GetHeight() + cf.situationActionsFrame:GetHeight() + cf.situationControlsFrame:GetHeight())

    -- Set the widget frame to the height of all its children (frame.help and frame.contentFrame).
    -- Get the offset between frame.help and frame.contentFrame.
    local point, _, _, _, yOffset = cf:GetPoint()
    assert(point == "TOPLEFT" or point == "TOPRIGHT")
    f:SetHeight(f.help:GetStringHeight() - yOffset + cf:GetHeight())
  end

end



-- My aceInvader.
-- Inspired by https://github.com/SFX-WoW/AceGUI-3.0_SFX-Widgets/.
do

  local Type, Version = "aceInvader", 1
  local AceGUI = LibStub("AceGUI-3.0", true)

	local function Constructor()
		local Widget = {}

		-- Container Frame
		local frame = CreateFrame("Frame", nil, UIParent)
    frame.obj = Widget

    -- Widget
    Widget.frame = frame
    Widget.type  = Type
		Widget.num   = AceGUI:GetNextWidgetNum(Type)


    -- Reccommended place to store ephemeral widget information.
    Widget.userdata = {}

    -- OnAcquire, SetLabel, SetText, SetDisabled(nil)
    -- all get called when showing the widget.
    -- It does not really matter which of these functions you use to do your stuff.
		Widget.OnAcquire = function(self)
      -- print("----------- OnAcquire")
      self.resizing = true

      self:SetDisabled(true)
      self:SetFullWidth(true)

      self.resizing = nil
    end


    -- Could be used to read the "name" attribute,
    -- if you want to use the same aceInvader for different purposes.
		Widget.SetLabel = function(self, name)
      -- print("----------- SetLabel", name)

      if name == "Situation Export" then
        BuildSituationExportFrame(self)
      end

    end

    -- Not useful to us, but Ace3 needs to call it.
		Widget.SetText = function(self)
      -- print("----------- SetText")
    end



    Widget.OnWidthSet = function(self)
      if self.resizing then return end
      -- print("----------- OnWidthSet", self.frame:GetWidth(), self.frame.contentFrame:GetWidth())

      -- Whenever OnWidthSet() is called, adjust the height of the frames to contain all child frames.
      if self.AdjustHeightFunction then self:AdjustHeightFunction() end
    end



    -- Not sure if this is really necessary...
		Widget.SetDisabled = function(self, Disabled)
      -- print("----------- SetDisabled", Disabled)
      self.disabled = Disabled
    end


    -- OnRelease gets called when hiding the widget.
    Widget.OnRelease = function(self)
      -- print("----------- OnRelease")
      self:SetDisabled(true)
      self.frame:ClearAllPoints()
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
              GameTooltip:AddLine("|cFFFF0000Disabled|r", _, _, _, true)
              GameTooltip:AddLine("Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there.", _, _, _, true)
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
              GameTooltip:AddLine("|cFFFF0000Attention|r", _, _, _, true)
              GameTooltip:AddLine("The \"" .. MOTION_SICKNESS_CHECKBOX .. "\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset.", _, _, _, true)
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
        print("|cFFFF0000While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!|r")
        SetCVar("CameraKeepCharacterCentered", false, "DynamicCam")

      elseif tonumber(GetCVar("test_cameraDynamicPitch")) == 1 then
        print("|cFFFF0000While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!|r")
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
        print("|cFFFF0000While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!|r")
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
    print("|cFFFF0000cameraView =", value, "prevented by DynamicCam!|r")
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



