local folderName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")
local LibEasing = LibStub("LibEasing-1.0")



local GetCameraZoom = _G.GetCameraZoom



-------------------------------------------------------------------------------
-- ZOOM-BASED SETTINGS
--
-- This module allows settings to be controlled by a curve based on zoom level.
-- Instead of a single value, users define points on a 2D graph where:
--   Y-axis = Camera zoom level (0 at top, max zoom at bottom)
--   X-axis = Setting value (min to max of the setting)
--
-- The system interpolates between points to get the value at any zoom level.
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- DATA STRUCTURE FOR ZOOM-BASED SETTINGS
-------------------------------------------------------------------------------

--[[
  The zoom-based settings are stored within standardSettings or situationSettings,
  parallel to the existing 'cvars' table. The new table is called 'cvarsZoomBased'.
  
  Structure:
  
  DynamicCamDB.profiles[profileName].standardSettings.cvarsZoomBased = {
    ["cvarName"] = {
      enabled = true/false,
      points = {
        -- Array of {zoom, value} pairs, sorted by zoom
        -- There's always a point at zoom=0 and zoom=maxZoom
        {zoom = 0, value = 0.5},
        {zoom = 10, value = 1.0},
        {zoom = 39, value = 1.5},
      }
    }
  }
  
  For situation-specific settings:
  DynamicCamDB.profiles[profileName].situations[situationID].situationSettings.cvarsZoomBased = {
    ["cvarName"] = { enabled = ..., points = {...} }
  }
  
  Note: minValue and maxValue are NOT stored in SavedVariables.
  They are passed in when opening the curve editor (from the slider definition).
  When cvarsZoomBased[cvarName] is nil, the curve editor initializes the points
  using the current value from the non-zoom-based slider.
--]]


-- Get the zoom-based cvar data for a specific cvar
-- Returns nil if zoom-based is not enabled for this cvar
function DynamicCam:GetZoomBasedCvar(situationId, cvarName)
  local settings = self:GetSettingsTable(situationId)
  if settings and settings.cvarsZoomBased and
     settings.cvarsZoomBased[cvarName] and
     settings.cvarsZoomBased[cvarName].enabled then
    return settings.cvarsZoomBased[cvarName]
  end
  return nil
end


-- Check if a cvar is zoom-based
function DynamicCam:IsCvarZoomBased(situationId, cvarName)
  local setting = self:GetZoomBasedCvar(situationId, cvarName)
  return setting ~= nil and setting.enabled
end


-- Get the zoom-based cvar data that is effectively active for a given situation,
-- falling back to standard settings when the situation doesn't override the cvar.
-- Returns (zoomBasedData, effectiveSituationId) or (nil, nil).
-- effectiveSituationId is the situationId whose zoom-based data applies (nil = standard).
function DynamicCam:GetEffectiveZoomBasedCvar(situationId, cvarName)
  -- First check the given situation's own settings
  local data = self:GetZoomBasedCvar(situationId, cvarName)
  if data then
    return data, situationId
  end

  -- If this is a situation (not standard) and it doesn't override this cvar,
  -- fall back to standard settings' zoom-based
  if situationId then
    local sitSettings = self:GetSettingsTable(situationId)
    if not sitSettings or not sitSettings.cvars or sitSettings.cvars[cvarName] == nil then
      local standardData = self:GetZoomBasedCvar(nil, cvarName)
      if standardData then
        return standardData, nil
      end
    end
  end

  return nil, nil
end


-- Check if a cvar is effectively zoom-based for a given situation,
-- considering fallback to standard settings.
function DynamicCam:IsEffectivelyCvarZoomBased(situationId, cvarName)
  local data = self:GetEffectiveZoomBasedCvar(situationId, cvarName)
  return data ~= nil
end


-- Set whether a cvar should be zoom-based
-- currentValue is the current slider value, used for initializing default points
function DynamicCam:SetCvarZoomBased(situationId, cvarName, enabled, currentValue)
  local settings = self:GetSettingsTable(situationId)
  if not settings then return end

  -- Initialize cvarsZoomBased if needed
  if not settings.cvarsZoomBased then
    settings.cvarsZoomBased = {}
  end

  if not settings.cvarsZoomBased[cvarName] then
    -- Initialize with default points using current slider value
    -- This creates a flat line at the current value
    settings.cvarsZoomBased[cvarName] = {
      enabled = enabled,
      points = {
        {zoom = 0, value = currentValue},
        {zoom = self.cameraDistanceMaxZoomFactor_max, value = currentValue},
      }
    }
  else
    settings.cvarsZoomBased[cvarName].enabled = enabled
  end

  -- Trigger an immediate update if this is for the active situation
  local isActiveSituation = (situationId == nil and self.currentSituationID == nil)
                         or (situationId == self.currentSituationID)
  if isActiveSituation then
    -- Reset the cache so ZoomBasedUpdateFunction will recalculate all zoom-based cvars on next frame
    self:ResetZoomBasedSettingsCache()
    
    -- If we're disabling zoom-based mode, apply the current slider value immediately
    if not enabled then
      self:ApplySettings()
    end
  end

  -- Notify the UI to refresh so that the slider's disabled state updates
  LibStub("AceConfigRegistry-3.0"):NotifyChange("DynamicCam")
end


-- Get the points for a zoom-based cvar
function DynamicCam:GetZoomBasedPoints(situationId, cvarName)
  local setting = self:GetZoomBasedCvar(situationId, cvarName)
  if setting then
    return setting.points
  end
  return nil
end


-- Set the points for a zoom-based cvar
function DynamicCam:SetZoomBasedPoints(situationId, cvarName, points)
  local settings = self:GetSettingsTable(situationId)
  if not settings then return end

  if settings.cvarsZoomBased and settings.cvarsZoomBased[cvarName] then
    -- Sort points by zoom level
    table.sort(points, function(a, b) return a.zoom < b.zoom end)
    settings.cvarsZoomBased[cvarName].points = points
  end
end



-------------------------------------------------------------------------------
-- INTERPOLATION
-------------------------------------------------------------------------------

-- Cache for last used segment index per cvar (optimization to avoid searching all points every frame)
local lastSegmentIndices = {}

-- Calculate the setting value for a given zoom level using linear interpolation
function DynamicCam:GetInterpolatedValue(situationId, cvarName, zoomLevel)
  local setting = self:GetZoomBasedCvar(situationId, cvarName)
  if not setting or not setting.points or #setting.points < 2 then
    -- Fallback to regular setting
    return self:GetSettingsValue(situationId, "cvars", cvarName)
  end
  
  local points = setting.points
  
  -- Clamp zoom level to valid range
  zoomLevel = math.max(0, math.min(zoomLevel, self.cameraDistanceMaxZoomFactor_max))
  
  -- Find the two points to interpolate between
  local lowerPoint = points[1]
  local upperPoint = points[#points]
  
  -- Get or create cache table for this situation
  local sitKey = situationId or "standard"
  if not lastSegmentIndices[sitKey] then
    lastSegmentIndices[sitKey] = {}
  end
  
  -- Optimization: Try the last successful segment first (works well for incremental zoom changes or when zoom has not changed at all)
  local segmentIndex = nil
  local lastSegmentIndex = lastSegmentIndices[sitKey][cvarName]
  if lastSegmentIndex and lastSegmentIndex <= #points - 1 then
    if points[lastSegmentIndex].zoom <= zoomLevel and points[lastSegmentIndex + 1].zoom >= zoomLevel then
      segmentIndex = lastSegmentIndex
    end
  end
  
  -- If cached segment didn't work, search through all segments
  if not segmentIndex then
    for i = 1, #points - 1 do
      if points[i].zoom <= zoomLevel and points[i + 1].zoom >= zoomLevel then
        segmentIndex = i
        break
      end
    end
  end
  
  -- Use the found segment (or fallback to endpoints)
  if segmentIndex then
    lowerPoint = points[segmentIndex]
    upperPoint = points[segmentIndex + 1]
    lastSegmentIndices[sitKey][cvarName] = segmentIndex  -- Cache for next call
  end
  
  -- Linear interpolation
  if upperPoint.zoom == lowerPoint.zoom then
    return lowerPoint.value
  end
  
  local t = (zoomLevel - lowerPoint.zoom) / (upperPoint.zoom - lowerPoint.zoom)
  return lowerPoint.value + t * (upperPoint.value - lowerPoint.value)
end





-------------------------------------------------------------------------------
-- ZOOM MONITORING AND VALUE APPLICATION
-------------------------------------------------------------------------------

-- Dedicated OnUpdate frame for continuously applying all zoom-based settings.
-- This handles all zoom-based cvars including test_cameraOverShoulder.
-- The frame runs independently, checking zoom level changes and updating cvars accordingly.
local zoomBasedUpdateFrame = CreateFrame("Frame")
local lastAppliedZoom = nil

-- Track which settings are actively being dragged in their curve editors
-- Key: cvarName, Value: true if dragging
local draggingCvars = {}

function DynamicCam:SetEditorDragging(dragging, cvarName)
  if cvarName then
    draggingCvars[cvarName] = dragging or nil
  end
end

function DynamicCam:IsEditorDraggingCvar(cvarName)
  return draggingCvars[cvarName] == true
end


-- Reset the last applied zoom (call when situation changes or settings are modified)
function DynamicCam:ResetZoomBasedSettingsCache()
  lastAppliedZoom = nil
end



-------------------------------------------------------------------------------
-- UNIFIED CVAR TRANSITION EASING
-------------------------------------------------------------------------------
--
-- When transitioning between situations, all cvars are cross-faded between
-- the old and new situation's values over the transition time.
-- At each frame: value = (1-t) * oldValue + t * newValue
-- where oldValue and newValue are computed at the current zoom level.
-- This handles zoom-based curves naturally: as the zoom changes (whether
-- by easing or manual scroll), both old and new values update according
-- to their respective curves at the current zoom.
-------------------------------------------------------------------------------

-- Simple toggle cvars (0/1) with no associated strength variables.
-- These are set immediately at the start of a transition.
local SIMPLE_TOGGLE_CVARS = {
  ["test_cameraDynamicPitch"] = true,
}

-- Toggle cvars with associated strength variables.
-- When these toggles change during a situation transition, the strength
-- variables are eased from/to 0 to create a smooth visual transition.
-- Disabling: the toggle stays enabled while strengths ease to 0, then the toggle is set at the end.
-- Enabling: the toggle is set immediately, strengths ease from 0 to their target values.
local TOGGLE_CVAR_GROUPS = {
  ["test_cameraTargetFocusEnemyEnable"] = {
    "test_cameraTargetFocusEnemyStrengthYaw",
    "test_cameraTargetFocusEnemyStrengthPitch",
  },
  ["test_cameraTargetFocusInteractEnable"] = {
    "test_cameraTargetFocusInteractStrengthYaw",
    "test_cameraTargetFocusInteractStrengthPitch",
  },
  ["test_cameraHeadMovementStrength"] = {
    "test_cameraHeadMovementStandingStrength",
    "test_cameraHeadMovementMovingStrength",
  },
}

-- All sub-cvars that have no visual effect when their parent toggle is disabled (0).
-- This is a superset of TOGGLE_CVAR_GROUPS: it includes ALL sub-cvars per group
-- (not just the strength variables used for transition easing).
local TOGGLE_SUB_CVARS = {
  ["test_cameraDynamicPitch"] = {
    "test_cameraDynamicPitchBaseFovPad",
    "test_cameraDynamicPitchBaseFovPadFlying",
    "test_cameraDynamicPitchBaseFovPadDownScale",
    "test_cameraDynamicPitchSmartPivotCutoffDist",
  },
  ["test_cameraTargetFocusEnemyEnable"] = {
    "test_cameraTargetFocusEnemyStrengthYaw",
    "test_cameraTargetFocusEnemyStrengthPitch",
  },
  ["test_cameraTargetFocusInteractEnable"] = {
    "test_cameraTargetFocusInteractStrengthYaw",
    "test_cameraTargetFocusInteractStrengthPitch",
  },
  ["test_cameraHeadMovementStrength"] = {
    "test_cameraHeadMovementStandingStrength",
    "test_cameraHeadMovementStandingDampRate",
    "test_cameraHeadMovementMovingStrength",
    "test_cameraHeadMovementMovingDampRate",
    "test_cameraHeadMovementFirstPersonDampRate",
    "test_cameraHeadMovementRangeScale",
    "test_cameraHeadMovementDeadZone",
  },
}

-- Reverse lookup: sub-cvar name -> parent toggle cvar name.
local CVAR_TOGGLE_PARENT = {}
for toggleCvar, subCvars in pairs(TOGGLE_SUB_CVARS) do
  for _, subCvar in ipairs(subCvars) do
    CVAR_TOGGLE_PARENT[subCvar] = toggleCvar
  end
end

-- Cvars whose real minimum is greater than the cosmetic slider/curve minimum of 0.
-- The zoom-based system must clamp to this before calling SetCVar,
-- matching the slider set-functions that already do the same conversion.
local CVAR_MIN_CLAMP = {
  ["test_cameraHeadMovementStandingDampRate"] = 0.01,
  ["test_cameraHeadMovementMovingDampRate"] = 0.01,
  ["test_cameraHeadMovementFirstPersonDampRate"] = 0.01,
}
-- Expose for use in ZoomBasedEditor.
DynamicCam.CVAR_MIN_CLAMP = CVAR_MIN_CLAMP

-- Track which cvars are currently controlled by a toggle group transition
-- (so they are excluded from normal easing and ApplySettings).
local toggleControlledCvars = {}

-- Pending toggle values to be applied at the end of a transition.
-- Key: cvarName, Value: { value, endTime }
local pendingToggles = {}

-- Active easing state for each cvar
-- Normal cross-fade:       { oldSituationId, newSituationId, startTime, duration, easingFunc }
-- Interrupted cross-fade:  { startValue, newSituationId, startTime, duration, easingFunc }
-- Toggle strength easing:  { startValue, targetValue, startTime, duration, easingFunc }
local activeCvarEasings = {}

-- Get current time (for easing calculations)
local function GetTime()
  return _G.GetTime()
end


-- Get the effective cvar value for a situation at a given zoom level.
-- If the cvar is zoom-based (in that situation or via standard settings fallback),
-- returns the curve value at zoomLevel.
-- Otherwise returns the fixed cvar value (situation override or standard fallback).
local function GetCvarValueForSituation(situationId, cvarName, zoomLevel)
  local zoomBasedData, effectiveSituationId = DynamicCam:GetEffectiveZoomBasedCvar(situationId, cvarName)
  if zoomBasedData then
    return DynamicCam:GetInterpolatedValue(effectiveSituationId, cvarName, zoomLevel)
  end
  -- Not zoom-based, get direct value (situation override or standard fallback)
  return DynamicCam:GetSettingsValue(situationId, "cvars", cvarName)
end


-- Get the target value for a cvar in the new situation
local function GetTargetCvarValue(newSituationId, cvarName, targetZoom)
  -- Check if zoom-based (in the new situation or via standard settings fallback)
  local zoomBasedData, effectiveSituationId = DynamicCam:GetEffectiveZoomBasedCvar(newSituationId, cvarName)
  if zoomBasedData then
    local points = zoomBasedData.points
    if points and #points >= 2 then
      -- Find interpolation segment
      local lowerPoint = points[1]
      local upperPoint = points[#points]
      for i = 1, #points - 1 do
        if points[i].zoom <= targetZoom and points[i + 1].zoom >= targetZoom then
          lowerPoint = points[i]
          upperPoint = points[i + 1]
          break
        end
      end
      -- Linear interpolation
      if upperPoint.zoom == lowerPoint.zoom then
        return lowerPoint.value, true
      end
      local t = (targetZoom - lowerPoint.zoom) / (upperPoint.zoom - lowerPoint.zoom)
      return lowerPoint.value + t * (upperPoint.value - lowerPoint.value), true
    end
  end
  
  -- Not zoom-based, get direct value (situation override or standard fallback)
  return DynamicCam:GetSettingsValue(newSituationId, "cvars", cvarName), false
end


-- Start easing all cvars for a situation transition
-- Called from ChangeSituation()
function DynamicCam:StartCvarTransitionEasing(oldSituationId, newSituationId, currentZoom, targetZoom, transitionTime, easingFunc)
  -- Apply any pending toggles from a previous unfinished transition.
  for cvarName, info in pairs(pendingToggles) do
    _G.SetCVar(cvarName, info.value)
  end
  pendingToggles = {}
  toggleControlledCvars = {}

  -- Snapshot any in-progress cross-fade values before clearing.
  -- If a cvar was mid-transition, the currently displayed value is a blend
  -- that doesn't match any single situation. We use the snapshot as the
  -- start value for the new easing to prevent visual jumps.
  local interruptedValues = {}
  local now = GetTime()
  for cvarName, easing in pairs(activeCvarEasings) do
    local elapsedTime = now - easing.startTime
    local t = elapsedTime / easing.duration
    if t < 1 then
      local ef = easing.easingFunc or LibEasing.Linear
      local blendFactor = ef(t, 0, 1, 1)
      if easing.startValue then
        if easing.targetValue then
          interruptedValues[cvarName] = easing.startValue + (easing.targetValue - easing.startValue) * blendFactor
        else
          local newValue = GetCvarValueForSituation(easing.newSituationId, cvarName, currentZoom)
          interruptedValues[cvarName] = easing.startValue + (newValue - easing.startValue) * blendFactor
        end
      else
        local oldValue = GetCvarValueForSituation(easing.oldSituationId, cvarName, currentZoom)
        local newValue = GetCvarValueForSituation(easing.newSituationId, cvarName, currentZoom)
        interruptedValues[cvarName] = oldValue + (newValue - oldValue) * blendFactor
      end
    end
  end

  -- Clear any existing easings
  activeCvarEasings = {}
  
  -- If instant transition, don't set up easing
  -- CvarUpdateFunction will apply the direct values immediately
  if transitionTime <= 0 then
    return
  end
  
  -- Ensure we have a valid easing function (fallback to Linear)
  if not easingFunc then
    easingFunc = LibEasing.Linear
  end
  
  -- Collect all cvars that need easing
  local cvarsToEase = {}
  
  -- Add all cvars from standard settings
  for cvarName, _ in pairs(self.db.profile.standardSettings.cvars) do
    cvarsToEase[cvarName] = true
  end
  
  -- Add any situation-specific cvars from old situation
  -- (including zoom-based cvars that need to be eased out)
  if oldSituationId then
    local oldSituation = self.db.profile.situations[oldSituationId]
    if oldSituation then
      if oldSituation.situationSettings.cvars then
        for cvarName, _ in pairs(oldSituation.situationSettings.cvars) do
          cvarsToEase[cvarName] = true
        end
      end
      if oldSituation.situationSettings.cvarsZoomBased then
        for cvarName, _ in pairs(oldSituation.situationSettings.cvarsZoomBased) do
          cvarsToEase[cvarName] = true
        end
      end
    end
  end
  
  -- Add any situation-specific cvars from new situation
  if newSituationId then
    local newSituation = self.db.profile.situations[newSituationId]
    if newSituation then
      if newSituation.situationSettings.cvars then
        for cvarName, _ in pairs(newSituation.situationSettings.cvars) do
          cvarsToEase[cvarName] = true
        end
      end
      if newSituation.situationSettings.cvarsZoomBased then
        for cvarName, _ in pairs(newSituation.situationSettings.cvarsZoomBased) do
          cvarsToEase[cvarName] = true
        end
      end
    end
  end
  
  -- Process toggle cvar groups before the main easing loop.
  -- When a toggle changes, we ease its associated strength variables from/to 0
  -- instead of toggling the enable flag immediately.
  for toggleCvar, strengthCvars in pairs(TOGGLE_CVAR_GROUPS) do
    if cvarsToEase[toggleCvar] then
      local currentToggleValue = tonumber(GetCVar(toggleCvar)) or 0
      local targetToggleValue = GetTargetCvarValue(newSituationId, toggleCvar, targetZoom)

      if targetToggleValue and math.abs(currentToggleValue - targetToggleValue) > 0.0001 then
        local isCurrentlyEnabled = math.abs(currentToggleValue) > 0.0001
        local isTargetEnabled = math.abs(targetToggleValue) > 0.0001

        if isCurrentlyEnabled and not isTargetEnabled then
          -- DISABLING: keep the toggle enabled during transition.
          -- Ease sub-strength cvars from their current values to 0.
          -- Apply the toggle at the end of the transition.
          pendingToggles[toggleCvar] = { value = targetToggleValue, endTime = now + transitionTime }
          toggleControlledCvars[toggleCvar] = true

          for _, strengthCvar in ipairs(strengthCvars) do
            local currentStrength = tonumber(GetCVar(strengthCvar)) or 0
            if math.abs(currentStrength) > 0.0001 then
              activeCvarEasings[strengthCvar] = {
                startValue = currentStrength,
                targetValue = 0,
                startTime = now,
                duration = transitionTime,
                easingFunc = easingFunc,

              }
            end
            toggleControlledCvars[strengthCvar] = true
          end

        elseif not isCurrentlyEnabled and isTargetEnabled then
          -- ENABLING: set the toggle immediately.
          -- Set sub-strength cvars to 0 first (so there's no visual jump),
          -- then ease them from 0 to their target values.
          _G.SetCVar(toggleCvar, targetToggleValue)
          toggleControlledCvars[toggleCvar] = true

          for _, strengthCvar in ipairs(strengthCvars) do
            local targetStrength, isZoomBasedStrength = GetTargetCvarValue(newSituationId, strengthCvar, targetZoom)
            if targetStrength and math.abs(targetStrength) > 0.0001 then
              _G.SetCVar(strengthCvar, 0)
              activeCvarEasings[strengthCvar] = {
                startValue = 0,
                targetValue = targetStrength,
                startTime = now,
                duration = transitionTime,
                easingFunc = easingFunc,

              }
            end
            toggleControlledCvars[strengthCvar] = true
          end
        end
      end
    end
  end

  -- Set up easing for each cvar
  for cvarName, _ in pairs(cvarsToEase) do
    -- Skip cvars already handled by toggle group logic above.
    if toggleControlledCvars[cvarName] then
      -- Already handled.

    -- Simple toggles (no sub-strength vars) are applied immediately.
    elseif SIMPLE_TOGGLE_CVARS[cvarName] then
      local targetValue = GetTargetCvarValue(newSituationId, cvarName, targetZoom)
      if targetValue then
        _G.SetCVar(cvarName, targetValue)
      end

    else
      -- Normal easing.
      local startValue
      if cvarName == "test_cameraOverShoulder" and DynamicCam.currentShoulderOffset then
        startValue = DynamicCam.currentShoulderOffset
      else
        startValue = tonumber(GetCVar(cvarName)) or 0
      end

      local targetValue, targetIsZoomBased = GetTargetCvarValue(newSituationId, cvarName, targetZoom)
      local oldIsZoomBased = DynamicCam:IsEffectivelyCvarZoomBased(oldSituationId, cvarName)

      -- Always create easing if either side is zoom-based, because intermediate
      -- zoom levels during the transition may produce different values even if
      -- start and target values happen to match at their respective zoom levels.
      -- For non-zoom-based cvars, only create easing if values actually differ.
      local needsEasing = (oldIsZoomBased or targetIsZoomBased)
                       or (startValue and targetValue and math.abs(startValue - targetValue) > 0.0001)

      if needsEasing then
        if interruptedValues[cvarName] then
          -- Previous cross-fade was interrupted: use snapshot as fixed start
          -- so the new easing begins from the actual displayed value.
          activeCvarEasings[cvarName] = {
            startValue = interruptedValues[cvarName],
            newSituationId = newSituationId,
            startTime = now,
            duration = transitionTime,
            easingFunc = easingFunc,
          }
        else
          activeCvarEasings[cvarName] = {
            oldSituationId = oldSituationId,
            newSituationId = newSituationId,
            startTime = now,
            duration = transitionTime,
            easingFunc = easingFunc,
          }
        end
      end
    end
  end
end


-- Check if a cvar has an active transition easing
function DynamicCam:IsCvarBeingEased(cvarName)
  return activeCvarEasings[cvarName] ~= nil
end


-- Check if a cvar is currently controlled by a toggle group transition
-- (either the toggle itself is pending, or a sub-strength is being eased).
function DynamicCam:IsCvarToggleControlled(cvarName)
  return pendingToggles[cvarName] ~= nil or toggleControlledCvars[cvarName] ~= nil
end


-- The main update function that applies all cvar values (both eased transitions and zoom-based curves)
local function CvarUpdateFunction(self, elapsed)
  -- Skip if temporarily disabled
  if DynamicCam.shoulderOffsetZoomTmpDisable then return end
  
  -- Process pending toggles (applied at the end of a transition).
  if next(pendingToggles) then
    local currentTime = GetTime()
    for cvarName, info in pairs(pendingToggles) do
      if currentTime >= info.endTime then
        _G.SetCVar(cvarName, info.value)
        pendingToggles[cvarName] = nil
        -- Clean up toggle-controlled flags for this group.
        if TOGGLE_CVAR_GROUPS[cvarName] then
          toggleControlledCvars[cvarName] = nil
          for _, strengthCvar in ipairs(TOGGLE_CVAR_GROUPS[cvarName]) do
            toggleControlledCvars[strengthCvar] = nil
          end
        end
      end
    end
  end
  
  -- Get current zoom (virtual or actual)
  local cameraZoom
  if DynamicCam.virtualCameraZoom ~= nil then
    cameraZoom = DynamicCam.virtualCameraZoom
  else
    cameraZoom = _G.GetCameraZoom()
  end
  
  -- Get the current situation's settings
  local situationId = DynamicCam.currentSituationID
  local settings = DynamicCam:GetSettingsTable(situationId)
  
  -- Track whether we need to update zoom-based values (optimization)
  local zoomChanged = not lastAppliedZoom or math.abs(cameraZoom - lastAppliedZoom) >= 0.01
  local hasActiveEasings = next(activeCvarEasings) ~= nil
  local hasPendingToggles = next(pendingToggles) ~= nil
  
  -- Skip if nothing to do
  if not zoomChanged and not hasActiveEasings and not hasPendingToggles then
    return
  end
  
  lastAppliedZoom = cameraZoom
  
  -- Process each cvar
  -- Collect all cvars we might need to apply
  local cvarsToCheck = {}
  for cvarName, _ in pairs(DynamicCam.db.profile.standardSettings.cvars) do
    cvarsToCheck[cvarName] = true
  end
  if settings and settings.cvars then
    for cvarName, _ in pairs(settings.cvars) do
      cvarsToCheck[cvarName] = true
    end
  end
  if settings and settings.cvarsZoomBased then
    for cvarName, _ in pairs(settings.cvarsZoomBased) do
      cvarsToCheck[cvarName] = true
    end
  end
  -- Include any cvars with active easings (they may reference old situation
  -- cvars not present in the current situation's settings).
  for cvarName, _ in pairs(activeCvarEasings) do
    cvarsToCheck[cvarName] = true
  end

  -- Determine which toggle groups are currently disabled (once per frame).
  -- Sub-cvars of a disabled toggle have no visual effect, so we can skip them
  -- to avoid unnecessary zoom-based interpolation and SetCVar calls.
  local toggleGroupDisabled = {}
  for toggleCvar, _ in pairs(TOGGLE_SUB_CVARS) do
    if not activeCvarEasings[toggleCvar] and not toggleControlledCvars[toggleCvar] and not pendingToggles[toggleCvar] then
      local toggleValue = tonumber(_G.GetCVar(toggleCvar)) or 0
      if math.abs(toggleValue) < 0.0001 then
        toggleGroupDisabled[toggleCvar] = true
      end
    end
  end

  for cvarName, _ in pairs(cvarsToCheck) do
    -- Skip if curve editor is dragging this setting
    if DynamicCam:IsEditorDraggingCvar(cvarName) then
      -- Do nothing, editor handles preview
    elseif pendingToggles[cvarName] then
      -- Skip: this toggle is waiting for its sub-strength transitions to complete.
    elseif CVAR_TOGGLE_PARENT[cvarName] and toggleGroupDisabled[CVAR_TOGGLE_PARENT[cvarName]]
           and not activeCvarEasings[cvarName] and not toggleControlledCvars[cvarName] then
      -- Skip: the parent toggle is disabled, so this sub-cvar has no visual effect.
    else
      local value = nil
      
      -- Priority 1: Active transition easing (cross-fade between old and new situation values)
      local easing = activeCvarEasings[cvarName]
      if easing then
        local elapsedTime = GetTime() - easing.startTime
        local t = elapsedTime / easing.duration
        
        if t >= 1 then
          -- Easing complete
          activeCvarEasings[cvarName] = nil
          -- Fall through to Priority 2/3
        else
          local easingFunc = easing.easingFunc or LibEasing.Linear
          local blendFactor = easingFunc(t, 0, 1, 1)
          
          if easing.startValue then
            -- Fixed start value: either a toggle strength (with targetValue)
            -- or an interrupted cross-fade snapshot (with newSituationId).
            local targetValue
            if easing.targetValue then
              targetValue = easing.targetValue
            else
              targetValue = GetCvarValueForSituation(easing.newSituationId, cvarName, cameraZoom)
            end
            value = easing.startValue + (targetValue - easing.startValue) * blendFactor
          else
            -- Normal cvars: cross-fade between old and new situation values at current zoom.
            local oldValue = GetCvarValueForSituation(easing.oldSituationId, cvarName, cameraZoom)
            local newValue = GetCvarValueForSituation(easing.newSituationId, cvarName, cameraZoom)
            value = oldValue + (newValue - oldValue) * blendFactor
          end
        end
      end
      
      -- Priority 2: Zoom-based curve (if no active easing)
      if value == nil then
        local zoomBasedData, effectiveSituationId = DynamicCam:GetEffectiveZoomBasedCvar(situationId, cvarName)
        if zoomBasedData then
          value = DynamicCam:GetInterpolatedValue(effectiveSituationId, cvarName, cameraZoom)
        end
      end
      
      -- Priority 3: Direct value (non-zoom-based, not easing)
      if value == nil then
        value = DynamicCam:GetSettingsValue(situationId, "cvars", cvarName)
      end
      
      -- Apply the value if we have one
      if value ~= nil then
        -- Clamp cvars whose real minimum is higher than the cosmetic minimum of 0.
        local minClamp = CVAR_MIN_CLAMP[cvarName]
        if minClamp and value < minClamp then
          value = minClamp
        end

        -- Special handling for shoulder offset (CameraOverShoulderFix)
        if cvarName == "test_cameraOverShoulder" then
          -- Update currentShoulderOffset using the function that handles mounted sign-change detection
          DynamicCam.UpdateCurrentShoulderOffset(value)
          value = DynamicCam.ApplyCameraOverShoulderFixCompensation(value)
        end
        
        local currentValue = tonumber(_G.GetCVar(cvarName))
        if currentValue ~= value then
          _G.SetCVar(cvarName, value)
        end
      end
    end
  end
  
  -- Update easeShoulderOffsetInProgress flag for CameraOverShoulderFix
  -- (It checks this flag to know if it should hold off on adjustments)
  DynamicCam.easeShoulderOffsetInProgress = (activeCvarEasings["test_cameraOverShoulder"] ~= nil)
end

-- Start the unified update frame
zoomBasedUpdateFrame:SetScript("OnUpdate", CvarUpdateFunction)




