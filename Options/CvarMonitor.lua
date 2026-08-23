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
