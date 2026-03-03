-------------------------------------------------------------------------------
-- DynamicCam Options - Control Factory Functions
-- Factory functions for creating common UI controls
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)
assert(DynamicCam.Options)

local Options = DynamicCam.Options


-------------------------------------------------------------------------------
-- Reset Button Image Coordinates
-------------------------------------------------------------------------------
Options.resetButtonImageCoords = {0.58203125, 0.64453125, 0.30078125, 0.36328125}
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
  Options.resetButtonImageCoords = {0.533203125, 0.58203125, 0.248046875, 0.294921875}
end


-------------------------------------------------------------------------------
-- Registry for Zoom-Based Control Configurations
-------------------------------------------------------------------------------
DynamicCam.zoomBasedControlConfigs = {}


-------------------------------------------------------------------------------
-- CreateZoomBasedControl
-- Creates a zoom-based control widget (checkbox + edit button with shared label underneath)
-------------------------------------------------------------------------------
function Options.CreateZoomBasedControl(order, forSituations, cvarName, customDisabledFunc)
  -- Create a unique ID for this control instance
  local configId = (forSituations and "situation_" or "standard_") .. cvarName

  -- Get min/max from cvar ranges
  local range = DynamicCam.cvarRanges[cvarName]
  local minValue = range and range.min or 0
  local maxValue = range and range.max or 1

  -- Store configuration in registry for the widget to retrieve
  DynamicCam.zoomBasedControlConfigs[configId] = {
    cvarName = cvarName,
    minValue = minValue,
    maxValue = maxValue,
    displayName = cvarName,
    forSituations = forSituations,
    getSituationId = function()
      return forSituations and Options.SID or nil
    end,
    checkboxTooltip = L["Enable zoom-based curve for this setting.\n\nWhen enabled, the value will change smoothly based on your camera zoom level instead of using a single fixed value. Click the gear icon to edit the curve."],
    editBtnTooltip = L["Open the curve editor.\n\nAllows you to define exactly how this setting changes as you zoom in and out. You can add control points to create a custom curve."],
    getFunc = function()
      return DynamicCam:IsCvarZoomBased(forSituations and Options.SID, cvarName)
    end,
    setFunc = function(newValue)
      local currentValue = DynamicCam:GetSettingsValue(forSituations and Options.SID, "cvars", cvarName)
      DynamicCam:SetCvarZoomBased(forSituations and Options.SID, cvarName, newValue, currentValue)
      
      -- Close the curve editor if disabling zoom-based mode
      if not newValue then
        DynamicCam:CloseCurveEditor(forSituations and Options.SID, cvarName)
      end
    end,
    editFunc = function(isOpen, widget)
      if isOpen then
        DynamicCam:OpenCurveEditor(forSituations and Options.SID, cvarName, minValue, maxValue, cvarName, widget)
      else
        DynamicCam:CloseCurveEditor(forSituations and Options.SID, cvarName)
      end
    end,
  }

  return {
    type = "input",
    name = configId,  -- Used as the config key
    dialogControl = "DynamicCam_ZoomBasedControl",
    order = order,
    width = 0.35,
    disabled = function(info)
      local isDisabled = Options.GetInheritedDisabledStatus(info)
      if customDisabledFunc then
        isDisabled = isDisabled or customDisabledFunc(info)
      end
      return isDisabled
    end,
  }
end


-------------------------------------------------------------------------------
-- CreateSliderResetButton
-- Creates a reset button for sliders
-------------------------------------------------------------------------------
function Options.CreateSliderResetButton(order, forSituations, index1, index2, tooltipDefaultValue, customDisabledFunc)

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
    imageCoords = Options.resetButtonImageCoords,
    imageWidth = 25/1.5,
    imageHeight = 24/1.5,
    desc = L["Reset to global default"] .. ": " .. tooltipDefaultValue .. "\n" .. L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"],
    order = order,
    width = 0.25,
    func =
      function()
        DynamicCam:SetSettingsDefault(forSituations and Options.SID, index1, index2)
      end,
    disabled =
      function(info)
        local isDisabled = Options.GetInheritedDisabledStatus(info) or (DynamicCam:GetSettingsValue(forSituations and Options.SID, index1, index2) == DynamicCam:GetSettingsDefault(index1, index2))
        if index1 == "cvars" then
          isDisabled = isDisabled or DynamicCam:IsCvarZoomBased(forSituations and Options.SID, index2)
        end
        if customDisabledFunc then
          isDisabled = isDisabled or customDisabledFunc(info)
        end
        return isDisabled
      end,
  }
end


-------------------------------------------------------------------------------
-- CreateOverriddenText
-- Creates a text description showing when standard settings are overridden
-------------------------------------------------------------------------------
function Options.CreateOverriddenText(groupVarsTable, forSituations)
  return {
    type = "description",
    name =
      function()
        if DynamicCam.currentSituationID and Options.CheckGroupVars(groupVarsTable, DynamicCam.currentSituationID) then
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


-------------------------------------------------------------------------------
-- CreateOverrideStandardToggle
-- Creates a toggle for overriding standard settings in situations
-------------------------------------------------------------------------------
function Options.CreateOverrideStandardToggle(groupVarsTable, forSituations)
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
        return Options.CheckGroupVars(groupVarsTable)
      end,
    set =
      function(_, newValue)
        Options.SetGroupVars(groupVarsTable, newValue)
      end,
  }
end
