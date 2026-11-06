-------------------------------------------------------------------------------
-- DynamicCam Options - CVar Monitoring
-- Hooks into Blizzard CVars and settings panel to enforce DynamicCam behavior
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)


-------------------------------------------------------------------------------
-- Disable mouse look slider and motion sickness options
-- and leave a tooltip note in the default UI settings.
-------------------------------------------------------------------------------

-- The rows of the settings list are pooled frames, which Blizzard reuses for other settings
-- while scrolling and switching categories. Anything we write into them taints them, and the
-- next setting using such a frame is initialised in tainted execution: its slider is then
-- blocked from setting its cvar in combat, and settings whose state depends on a protected
-- function (like the Discord voice settings) raise ADDON_ACTION_FORBIDDEN while scrolling.
-- So we only call widget methods on them and hook their scripts instead of replacing them,
-- which leaves no trace in their Lua tables. In particular, we must not use the slider's own
-- SetEnabled, which stores the state in a field. Blizzard reinitialises a reused frame
-- completely, so nothing has to be undone when a frame moves on to another setting.

local hookedFrames = {}

local function AddTooltipNote(row, frame, label, title, text)
  if hookedFrames[frame] then return end
  hookedFrames[frame] = true
  frame:HookScript("OnEnter", function()
    -- The frame may have moved on to another setting since.
    if row.Text:GetText() ~= label then return end
    SettingsTooltip:AddLine(" ")
    SettingsTooltip:AddLine("|cFFFF0000" .. title .. "|r", _, _, _, true)
    SettingsTooltip:AddLine(text, _, _, _, true)
    SettingsTooltip:Show()
  end)
end

-- What the slider's SetEnabled(false) does, minus the field.
local function DisableSlider(sliderWithSteppers)
  sliderWithSteppers.Slider:SetEnabled(false)
  sliderWithSteppers.Slider.Thumb:SetAlpha(0.7)
  local r, g, b = GRAY_FONT_COLOR:GetRGB()
  sliderWithSteppers.LeftText:SetVertexColor(r, g, b)
  sliderWithSteppers.RightText:SetVertexColor(r, g, b)
  sliderWithSteppers.TopText:SetVertexColor(r, g, b)
  sliderWithSteppers.MinText:SetVertexColor(r, g, b)
  sliderWithSteppers.MaxText:SetVertexColor(r, g, b)
  for _, stepper in ipairs({ sliderWithSteppers.Back, sliderWithSteppers.Forward }) do
    stepper:SetEnabled(false)
    -- The classic slider does not fade its steppers out, and would not fade them back in either.
    if sliderWithSteppers.IsSliderEnabled then
      stepper:SetAlpha(0.5)
      stepper:DesaturateHierarchy(1)
    end
  end
end

hooksecurefunc(SettingsPanel.Container.SettingsList.ScrollBox, "Update", function()

  -- Both settings can also turn up among the search results.
  local category = SettingsPanel.Container.SettingsList.Header.Title:GetText()
  if category ~= CONTROLS_LABEL and category ~= ACCESSIBILITY_GENERAL_LABEL and category ~= SETTINGS_SEARCH_RESULTS then return end

  for _, row in ipairs({ SettingsPanel.Container.SettingsList.ScrollBox.ScrollTarget:GetChildren() }) do
    local label = row.Text and row.Text:GetText()

    -- ###################### Mouse ######################
    if label == MOUSE_LOOK_SPEED and row.SliderWithSteppers then

      -- Got to make sure, the slider stays disabled.
      if row.SliderWithSteppers.Slider:IsEnabled() then
        DisableSlider(row.SliderWithSteppers)
      end
      AddTooltipNote(row, row.SliderWithSteppers.Slider, label, L["Disabled"], L["Your DynamicCam addon lets you adjust horizontal and vertical mouse look speed individually! Just go to the \"Mouse Look\" settings of DynamicCam to make the adjustments there."])


    -- ###################### Motion Sickness ######################
    elseif label == MOTION_SICKNESS_CHECKBOX then

      -- Retail got rid of the drop down and only uses a single checkbox now.

      -- Bizarrely, since 11.0.2 checking the checkbox sets
      -- CameraKeepCharacterCentered = false  and  CameraReduceUnexpectedMovement = true
      -- whereas unchecking the checkbox sets
      -- CameraKeepCharacterCentered = true  and  CameraReduceUnexpectedMovement = false
      -- Either variable will stop shoulder offset to take effect, so the SetCVar hook below
      -- undoes the checkbox while the offset (or dynamic pitch) is in use, and the tooltip says so.

      -- Renamed to "Checkbox" in 11.0.0.
      AddTooltipNote(row, row.Checkbox or row.CheckBox, label, L["Attention"], L["The \"%s\" setting is disabled by DynamicCam, while you are using the horizontal camera over shoulder offset."]:format(MOTION_SICKNESS_CHECKBOX))
    end
  end

end)


-------------------------------------------------------------------------------
-- CVar Hooks - Monitor and enforce DynamicCam-related CVars
-------------------------------------------------------------------------------

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

-- Motion Sickness (CameraKeepCharacterCentered and CameraReduceUnexpectedMovement) prevents
-- both shoulder offset and dynamic pitch from taking effect, so we switch it off while either
-- of them is in use. Both of them have to be taken into account when restoring it, or else
-- switching one off restores a setting the other one still needs suppressed.
local function ShoulderOffsetInUse()
  if not DynamicCam.db then return false end
  -- We check the configured value instead of the current cvar, because with
  -- "according to zoom level" the cvar may momentarily be 0.
  return DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "cvars", "test_cameraOverShoulder") ~= 0
end

local function DynamicPitchInUse()
  return tonumber(GetCVar("test_cameraDynamicPitch")) == 1
end

-- We may have no stored value, if the cvar was never switched on while we were watching.
local function RestoreMotionSicknessCvar(cvar, userValue)
  if not userValue or userValue == GetCVar(cvar) then return end
  -- print("|cFF00FF00Restoring", cvar, "|r")
  SetCVar(cvar, userValue, "DynamicCam")
end


hooksecurefunc("SetCVar", function(cvar, value, flag)
  -- print(cvar, value, flag)

  -- Only the corrective calls below carry this flag. Everything else DynamicCam sets goes
  -- through here unflagged on purpose, because applying a situation has to be monitored too.
  if flag == "DynamicCam" then return end

  -- Depending on the caller, value may be a boolean, a number or a string.
  -- We normalise it once, so the checks below do not have to cope with all three.
  local numericValue
  if type(value) == "boolean" then
    numericValue = value and 1 or 0
  else
    numericValue = tonumber(value)
  end


  -- Automatically undo forbidden motion sickness setting.
  if cvar == "CameraKeepCharacterCentered" then
    -- Remember what the user setup. We use GetCVar instead of value, because it returns 0/1 instead of false/true.
    DynamicCam.userCameraKeepCharacterCentered = GetCVar("CameraKeepCharacterCentered")
    -- print("|cFF0000FFStoring userCameraKeepCharacterCentered!|r", GetCVar("CameraKeepCharacterCentered"))

    if numericValue == 1 then
      if ShoulderOffsetInUse() then
        print("|cFFFF0000" .. L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] .. "|r")
        SetCVar("CameraKeepCharacterCentered", false, "DynamicCam")

      elseif DynamicPitchInUse() then
        print("|cFFFF0000" .. L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] .. "|r")
        SetCVar("CameraKeepCharacterCentered", false, "DynamicCam")
      end
    end


  -- As off 11.0.2 this is also needed for shoulder offset to take effect.
  elseif cvar == "CameraReduceUnexpectedMovement" then
    -- Remember what the user setup. We use GetCVar instead of value, because it returns 0/1 instead of false/true.
    DynamicCam.userCameraReduceUnexpectedMovement = GetCVar("CameraReduceUnexpectedMovement")
    -- print("|cFF0000FFStoring userCameraReduceUnexpectedMovement!|r", GetCVar("CameraReduceUnexpectedMovement"))

    if numericValue == 1 then
      if ShoulderOffsetInUse() then
        print("|cFFFF0000" .. L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] .. "|r")
        SetCVar("CameraReduceUnexpectedMovement", false, "DynamicCam")
      end
    end


  elseif cvar == "test_cameraOverShoulder" then

    -- If necessary, prevent Motion Sickness.
    if numericValue ~= 0 then

      if tonumber(GetCVar("CameraKeepCharacterCentered")) == 1 then
        -- print("|cFFFF0000While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!|r")
        -- We used to assert here that we had stored this value before. But the cvar can also
        -- be changed without going through SetCVar (console command, or another addon calling
        -- C_CVar.SetCVar directly), so our stored value may be out of date. Whatever is set
        -- right before we override it is by definition what we have to restore afterwards.
        DynamicCam.userCameraKeepCharacterCentered = GetCVar("CameraKeepCharacterCentered")
        SetCVar("CameraKeepCharacterCentered", false, "DynamicCam")
      end
      if tonumber(GetCVar("CameraReduceUnexpectedMovement")) == 1 then
        -- print("|cFFFF0000While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!|r")
        DynamicCam.userCameraReduceUnexpectedMovement = GetCVar("CameraReduceUnexpectedMovement")
        SetCVar("CameraReduceUnexpectedMovement", false, "DynamicCam")
      end

    -- If no longer necessary, restore Motion Sickness.
    elseif not ShoulderOffsetInUse() then
      -- Dynamic pitch needs CameraKeepCharacterCentered suppressed as well.
      if not DynamicPitchInUse() then
        RestoreMotionSicknessCvar("CameraKeepCharacterCentered", DynamicCam.userCameraKeepCharacterCentered)
      end
      RestoreMotionSicknessCvar("CameraReduceUnexpectedMovement", DynamicCam.userCameraReduceUnexpectedMovement)
    end


  elseif cvar == "test_cameraDynamicPitch" then

    -- If necessary, prevent Motion Sickness.
    if numericValue == 1 then
      if tonumber(GetCVar("CameraKeepCharacterCentered")) == 1 then
        -- print("|cFFFF0000While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!|r")
        DynamicCam.userCameraKeepCharacterCentered = GetCVar("CameraKeepCharacterCentered")
        SetCVar("CameraKeepCharacterCentered", false, "DynamicCam")
      end

    -- If no longer necessary, restore Motion Sickness.
    -- (Shoulder offset needs CameraKeepCharacterCentered suppressed as well.)
    elseif not ShoulderOffsetInUse() then
      RestoreMotionSicknessCvar("CameraKeepCharacterCentered", DynamicCam.userCameraKeepCharacterCentered)
    end




  -- https://github.com/Mpstark/DynamicCam/issues/40
  elseif cvar == "cameraView" and not validValuesCameraView[numericValue] then
    print("|cFFFF0000" .. L["cameraView=%s prevented by DynamicCam!"]:format(tostring(value)) .. "|r")
    SetCVar("cameraView", GetCVarDefault("cameraView"), "DynamicCam")

  -- Switch to a default view, if user switches to cameraSmoothStyle.
  elseif cvar == "cameraSmoothStyle" and numericValue ~= 0 then
    -- The order (first reset then set) is important, because if you are already
    -- in view 1 and do a reset, it also sets the view. If this is followed by
    -- another setView, you get an undesired instant view switch.
    if not viewIsReset[1] then ResetView(1) end
    if not viewIsActive[1] then SetView(1) end
  end

end)
