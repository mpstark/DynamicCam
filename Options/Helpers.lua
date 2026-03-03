-------------------------------------------------------------------------------
-- DynamicCam Options - Helper Functions
-- Utility functions used throughout the Options module
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)

-- Create the Options module if it doesn't exist yet
-- (This file loads before Options.lua in the TOC)
if not DynamicCam.Options then
  DynamicCam.Options = DynamicCam:NewModule("Options", "AceEvent-3.0")
end

local Options = DynamicCam.Options

-------------------------------------------------------------------------------
-- Shared State
-- These variables track the currently selected situation in the UI
-------------------------------------------------------------------------------
Options.S = nil            -- Currently selected situation
Options.SID = nil          -- Currently selected situation ID
Options.lastSelectedSID = nil
Options.copiedSituationID = nil
Options.exportName = nil
Options.exportAuthor = nil


-------------------------------------------------------------------------------
-- Getters and Setters for Shared State
-------------------------------------------------------------------------------
function Options:GetSelectedSituation()
  return self.S, self.SID
end

function Options:SetSelectedSituation(situation, situationId)
  self.S = situation
  self.SID = situationId
  self.lastSelectedSID = situationId
end

function Options:GetLastSelectedSID()
  return self.lastSelectedSID
end


-------------------------------------------------------------------------------
-- Utility Functions
-------------------------------------------------------------------------------
function Options.Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


-------------------------------------------------------------------------------
-- Default Value Checking Functions
-------------------------------------------------------------------------------
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


function Options.EventsIsDefault(situationID)
  if not DynamicCam.defaults.profile.situations[situationID] then return true end
  return DynamicCam:EventsEqual(DynamicCam.db.profile.situations[situationID].events, DynamicCam.defaults.profile.situations[situationID].events)
end

function Options.ScriptIsDefault(situationID, scriptName)
  if not DynamicCam.defaults.profile.situations[situationID] then return true end
  return DynamicCam:ScriptEqual(DynamicCam.db.profile.situations[situationID][scriptName], DynamicCam.defaults.profile.situations[situationID][scriptName])
end

function Options.ValueIsDefault(situationID, valueName)
  if not DynamicCam.defaults.profile.situations[situationID] then return true end
  return DynamicCam.db.profile.situations[situationID][valueName] == DynamicCam.defaults.profile.situations[situationID][valueName]
end


function Options.SituationControlsAreDefault(situationID)
  if Options.ValueIsDefault(situationID, "priority") and
      Options.EventsIsDefault(situationID) and
      Options.ScriptIsDefault(situationID, "executeOnInit") and
      Options.ScriptIsDefault(situationID, "condition") and
      Options.ScriptIsDefault(situationID, "executeOnEnter") and
      Options.ScriptIsDefault(situationID, "executeOnExit") and
      Options.ValueIsDefault(situationID, "delay") then
    return true
  else
    return false
  end
end

function Options.SituationControlsToDefault(situationID)
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


function Options.ColourTextErrorOrModified(text, dataType, dataId)
  local S = Options.S
  local SID = Options.SID

  -- Do we have an error at all, and is it an error for this script.
  -- (dataId is left empty to colour the "Situation Controls" tab text.)
  if S.errorEncountered and (not dataId or dataId == S.errorEncountered) then
    return "|cFFEE0000".. text .. "|r"

  -- Check if the given data is default. Different checking methods based on dataType.
  else
    if (not dataId and not Options.SituationControlsAreDefault(SID))
        or (dataType == "value"  and not Options.ValueIsDefault(SID, dataId))
        or (dataType == "events" and not Options.EventsIsDefault(SID))
        or (dataType == "script" and not Options.ScriptIsDefault(SID, dataId)) then
      return "|cFFFF6600" .. text .. "|r"
    else
      return text
    end
  end
end


-------------------------------------------------------------------------------
-- View Tracking Functions
-------------------------------------------------------------------------------
function Options.GetUsedViews()
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


-------------------------------------------------------------------------------
-- Settings Access Functions
-------------------------------------------------------------------------------
function DynamicCam:GetSettingsTable(situationId)
  if situationId then
    return self.db.profile.situations[situationId].situationSettings
  else
    return self.db.profile.standardSettings
  end
end


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


-------------------------------------------------------------------------------
-- Disabled State Inheritance
-- Thanks to vrul! https://www.wowinterface.com/forums/showthread.php?p=338116#post338116
-------------------------------------------------------------------------------
function Options.GetInheritedDisabledStatus(info)
  if not info or not info.options then return false end
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


-------------------------------------------------------------------------------
-- Group Variables Definitions
-------------------------------------------------------------------------------
Options.zoomGroupVars = {
  {"cvars", "cameraDistanceMaxZoomFactor"},
  {"cvars", "cameraZoomSpeed"},
  {"reactiveZoomAddIncrementsAlways"},
  {"reactiveZoomEnabled"},
  {"reactiveZoomAddIncrements"},
  {"reactiveZoomIncAddDifference"},
  {"reactiveZoomMaxZoomTime"},
}

Options.mouseLookGroupVars = {
  {"cvars", "cameraYawMoveSpeed"},
  {"cvars", "cameraPitchMoveSpeed"},
}

Options.shoulderOffsetGroupVars = {
  {"cvars", "test_cameraOverShoulder"},
}

Options.pitchGroupVars = {
  {"cvars", "test_cameraDynamicPitch"},
  {"cvars", "test_cameraDynamicPitchBaseFovPad"},
  {"cvars", "test_cameraDynamicPitchBaseFovPadFlying"},
  {"cvars", "test_cameraDynamicPitchBaseFovPadDownScale"},
  {"cvars", "test_cameraDynamicPitchSmartPivotCutoffDist"},
}

Options.targetFocusGroupVars = {
  {"cvars", "test_cameraTargetFocusEnemyEnable"},
  {"cvars", "test_cameraTargetFocusEnemyStrengthYaw"},
  {"cvars", "test_cameraTargetFocusEnemyStrengthPitch"},
  {"cvars", "test_cameraTargetFocusInteractEnable"},
  {"cvars", "test_cameraTargetFocusInteractStrengthYaw"},
  {"cvars", "test_cameraTargetFocusInteractStrengthPitch"},
}

Options.headTrackingGroupVars = {
  {"cvars", "test_cameraHeadMovementStrength"},
  {"cvars", "test_cameraHeadMovementStandingStrength"},
  {"cvars", "test_cameraHeadMovementStandingDampRate"},
  {"cvars", "test_cameraHeadMovementMovingStrength"},
  {"cvars", "test_cameraHeadMovementMovingDampRate"},
  {"cvars", "test_cameraHeadMovementFirstPersonDampRate"},
  {"cvars", "test_cameraHeadMovementRangeScale"},
  {"cvars", "test_cameraHeadMovementDeadZone"},
}


-------------------------------------------------------------------------------
-- Group Variable Checking Functions
-------------------------------------------------------------------------------
function Options.CheckGroupVars(groupVarsTable, situationId)
  if not situationId then
    situationId = Options.SID
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


function Options.SetGroupVars(groupVarsTable, override)
  local SID = Options.SID

  for k, v in pairs(groupVarsTable) do
    local index1, index2 = unpack(v)
    local situationSettingsTable = DynamicCam.db.profile.situations[SID].situationSettings
    local standardSettingsTable = DynamicCam.db.profile.standardSettings

    if index1 == "cvars" and index2 then
      if override then
        situationSettingsTable.cvars[index2] = standardSettingsTable.cvars[index2]
      else
        situationSettingsTable.cvars[index2] = nil
        -- Also clear any zoom-based settings for this cvar so that
        -- the standard settings take effect immediately.
        if situationSettingsTable.cvarsZoomBased and situationSettingsTable.cvarsZoomBased[index2] then
          situationSettingsTable.cvarsZoomBased[index2] = nil
        end
      end
    else
      if override then
        situationSettingsTable[index1] = standardSettingsTable[index1]
      else
        situationSettingsTable[index1] = nil
      end
    end
  end

  -- Reset zoom-based cache so that standard zoom-based settings (if any) are applied right away.
  DynamicCam:ResetZoomBasedSettingsCache()
  DynamicCam:ApplySettings()
end


-------------------------------------------------------------------------------
-- Display Helper Functions
-------------------------------------------------------------------------------
function Options.GreyWhenInactive(name, enabled)
  if not enabled then
    return "|cff909090"..name.."|r"
  end
  return name
end

function Options.ColoredNames(name, groupVarsTable, forSituations)
  if not forSituations then
    if DynamicCam.currentSituationID and Options.CheckGroupVars(groupVarsTable, DynamicCam.currentSituationID) then
      return "|cFF00FF00"..name.."|r"
    end
  else
    if not Options.CheckGroupVars(groupVarsTable) then
      return "|cff909090"..name.."|r"
    end
  end
  return name
end


-------------------------------------------------------------------------------
-- Situation List Generator
-------------------------------------------------------------------------------
function Options.GetSituationList()
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

      if not Options.SituationControlsAreDefault(id) then
        modifiedSuffix = "|cFFFF6600  " .. L["(modified)"] .. "|r"
      end

      -- print(id, situation.name)
      situationList[id] = prefix .. customPrefix .. situation.name .. " [" .. L["Priority"] .. ": " .. situation.priority .. "]" .. suffix .. modifiedSuffix
    end
  end

  return situationList
end


-------------------------------------------------------------------------------
-- Rotation and UI Fade Application
-------------------------------------------------------------------------------
local LibCamera = LibStub("LibCamera-1.0")

function Options.ApplyContinuousRotation()
  local S = Options.S
  local SID = Options.SID

  if SID == DynamicCam.currentSituationID then
    LibCamera:StopRotating()

    if S.rotation.enabled and S.rotation.rotationType == "continuous" then
      LibCamera:BeginContinuousYaw(S.rotation.rotationSpeed, 0)
    end
  end
end


function Options.ApplyUIFade()
  local S = Options.S
  local SID = Options.SID

  if SID == DynamicCam.currentSituationID then
    DynamicCam:FadeInUI(0)
    if S.hideUI.enabled then
      DynamicCam:FadeOutUI(0, S.hideUI)
    end
  end
end
