local folderName, Addon = ...

---------------
-- LIBRARIES --
---------------
local LibCamera = LibStub("LibCamera-1.0")
local LibEasing = LibStub("LibEasing-1.0")
local LibHideUI = LibStub("LibHideUI-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")


-------------
-- GLOBALS --
-------------
DynamicCam = LibStub("AceAddon-3.0"):NewAddon(folderName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

-- Needed by CameraOverShoulderFix to know if a zoom easing is in progress.
DynamicCam.LibCamera = LibCamera


DynamicCam.currentSituationID = nil


-- For other Addons (like Narcissus) to temporarily disable
-- "Adjust Shoulder offset according to zoom level" without
-- having to change the user's permanent DynamicCam profile.
-- This flag is checked by CvarUpdateFunction to prevent it from
-- applying zoom-based shoulder offset adjustments.
DynamicCam.shoulderOffsetZoomTmpDisable = false
function DynamicCam:BlockShoulderOffsetZoom()
  self.shoulderOffsetZoomTmpDisable = true
end
function DynamicCam:AllowShoulderOffsetZoom()
  self.shoulderOffsetZoomTmpDisable = false
end


-- This flag indicates when shoulder offset is being eased (during situation transitions).
-- This info is needed by CameraOverShoulderFix, such that it does not interfere.
DynamicCam.easeShoulderOffsetInProgress = false


-- Stores the "desired" shoulder offset value (as configured by the user/situation).
-- The actual test_cameraOverShoulder CVar may differ from this value because
-- CameraOverShoulderFix multiplies it by currentModelFactor to compensate for player model.
-- So: GetCVar("test_cameraOverShoulder") = currentShoulderOffset * cosFix.currentModelFactor
--
-- This must be stored because:
-- 1) During easing animations, it's continuously updated by LibEasing
-- 2) Zoom functions need to know the current value during easing
-- 3) CameraOverShoulderFix needs to know the sign (positive/negative) when mounted
DynamicCam.currentShoulderOffset = 0


DynamicCam.conditionExecutionCache = {}


-- When the users sets ActionCam features that are prevented by Motion Sickness settings,
-- we temporarily disable these Motion Sicknes settings. But we restore them when no
-- affected ActionCam features are used any more.
DynamicCam.userCameraKeepCharacterCentered = DynamicCam.userCameraKeepCharacterCentered or GetCVar("CameraKeepCharacterCentered")
DynamicCam.userCameraReduceUnexpectedMovement = DynamicCam.userCameraReduceUnexpectedMovement or GetCVar("CameraReduceUnexpectedMovement")


-- When SetView() happens, the zoom level of the new view is
-- returned instantaneously by GetCameraZoom().
-- If "Adjust Shoulder offset according to zoom level" is activated,
-- this may lead to a shoulder offset skip. Thus we have to make
-- a virtual zoom ease for the duration of the view change on this variable (see SituationManager.lua):
DynamicCam.virtualCameraZoom = nil


-- To evaluate situations one frame after an event is triggered (see EventHandler()).
DynamicCam.evaluateSituationsNextFrame = false


-- We use this to suppress situation entering easing at login!
DynamicCam.enteredSituationAtLogin = false




------------
-- LOCALS --
------------

local function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end



-- Forward declaration.
local UpdateCurrentShoulderOffset



-- Use this variable to get the duration of the last frame.
-- This is more accurate than the game framerate, which is the average over several recent frames.
-- (Needed in SituationManager.lua and MouseZoom.lua.)
DynamicCam.secondsPerFrame = 1.0 / GetFramerate()


-- Always evaluate to be on the safe side.
-- Because some situations (like taking off on a mount) cannot be associated with an event.
local alwaysEvaluateDelay = 1
local alwaysEvaluateTimer = alwaysEvaluateDelay

local function ConstantlyRunningFrameFunction(_, elapsed)
  -- Also using this frame's OnUpdate to log secondsPerFrame.
  DynamicCam.secondsPerFrame = elapsed

  alwaysEvaluateTimer = alwaysEvaluateTimer - elapsed

  -- Using this frame to evaluate situations one frame after an event
  -- is triggered (see EventHandler()). This way we are never too early.
  if DynamicCam.evaluateSituationsNextFrame or alwaysEvaluateTimer < 0 then
    DynamicCam.evaluateSituationsNextFrame = false
    alwaysEvaluateTimer = alwaysEvaluateDelay
    DynamicCam:EvaluateSituations()
  end

end
local constantlyRunningFrame = CreateFrame("Frame")



function DynamicCam:DC_SetCVar(cvar, setting)

  -- Special handling for shoulder offset
  if cvar == "test_cameraOverShoulder" then
    UpdateCurrentShoulderOffset(setting)
    
    -- If zoom-based curves are enabled, CvarUpdateFunction will handle application
    if self:IsCvarZoomBased(self.currentSituationID, "test_cameraOverShoulder") then
      return
    end
    
    -- If zooming or easing, don't apply now
    if LibCamera:IsZooming() or DynamicCam.easeShoulderOffsetInProgress then
      return
    end
    
    -- Apply with CameraOverShoulderFix compensation
    setting = DynamicCam.ApplyCameraOverShoulderFixCompensation(DynamicCam.currentShoulderOffset)
  end
  
  -- Apply the cvar if it's not already set to the new value
  if GetCVar(cvar) ~= tostring(setting) then
    SetCVar(cvar, setting)
  end
end












----------------------
-- SHOULDER OFFSET  --
----------------------

-- Applies CameraOverShoulderFix compensation to a shoulder offset value.
-- Takes the "desired" value and returns what should actually be set in the CVar.
-- Returns: shoulderOffset * cosFix.currentModelFactor (or unchanged if cosFix not present)
-- Made global so ZoomBasedSettings.lua can use it too.
function DynamicCam.ApplyCameraOverShoulderFixCompensation(shoulderOffset)
  local cosFix = _G.cosFix
  if cosFix then
    if not cosFix.currentModelFactor then
      cosFix.currentModelFactor = cosFix:CorrectShoulderOffset()
    end
    return Round(shoulderOffset * cosFix.currentModelFactor, 10)
  end
  return shoulderOffset
end

-- Updates the stored "desired" shoulder offset value.
-- Handles CameraOverShoulderFix sign-change detection when mounted.
-- Note: This updates currentShoulderOffset (desired value), NOT the CVar directly.
-- The CVar is set separately using ApplyCameraOverShoulderFixCompensation().
function DynamicCam.UpdateCurrentShoulderOffset(offset)

  -- If offset changes sign while mounted, CameraOverShoulderFix needs to update currentModelFactor!
  local cosFix = _G.cosFix
  if cosFix and IsMounted() then
    if (DynamicCam.currentShoulderOffset < 0 and offset >= 0)
    or (DynamicCam.currentShoulderOffset >= 0 and offset < 0) then
        cosFix.currentModelFactor = cosFix:CorrectShoulderOffset()
    end
  end

  DynamicCam.currentShoulderOffset = offset
end

-- Local alias for backward compatibility within this file
UpdateCurrentShoulderOffset = DynamicCam.UpdateCurrentShoulderOffset




-------------
-- FADE UI --
-------------

-- We Show() this frame, whenever we are hiding the UI.
-- Inserting it into UISpecialFrames leads to the frame being hidden when
-- the user presses ESCAPE. So we can use the frame's OnHide script to
-- bring the UI back.
local fadeUIEscapeHandlerFrame = CreateFrame("Frame", "DynamicCamfadeUIEscapeHandlerFrame")
tinsert(UISpecialFrames, fadeUIEscapeHandlerFrame:GetName())

fadeUIEscapeHandlerFrame:SetScript("OnHide", function(self)
  -- print("Hiding FadeUIEscapeHandler")

  if not DynamicCam.db.profile.situations[DynamicCam.currentSituationID].hideUI.emergencyShowEscEnabled then return end

  -- We do not even have to Show() UIParent here, because whenever
  -- UIParent is hidden the first press of ESCAPE will bring
  -- UIParent back. Only a second ESCAPE press would then hide
  -- all shown UISpecialFrames. That's why we are always hiding
  -- fadeUIEscapeHandlerFrame after UIParent's OnHide handler.
  -- (see below).

  -- Use this as default.
  local fadeInTime = 0.5

  -- Check if we are currently in a situation with fadeInTime.
  local curSituation = DynamicCam.db.profile.situations[DynamicCam.currentSituationID]
  if curSituation and curSituation.hideUI.enabled then
    fadeInTime = curSituation.transitionTime.timeToExit
  end

  DynamicCam:FadeInUI(fadeInTime)
end)
-- For debugging.
-- fadeUIEscapeHandlerFrame:SetScript("OnShow", function() print("Showing FadeUIEscapeHandler") end)


-- Whenever UIParent is hidden, the first ESCAPE press brings UIParent back.
-- A second ESCAPE press would be needed to hide UISpecialFrames.
-- So we already hide fadeUIEscapeHandlerFrame with the first ESCAPE press.
UIParent:HookScript("OnShow", function()
  if fadeUIEscapeHandlerFrame:IsShown() then
    fadeUIEscapeHandlerFrame:Hide()
  end
end)



-- To hide fadeUIEscapeHandlerFrame without triggering its OnHide script.
local function UIEscapeHandlerDisable()
  if fadeUIEscapeHandlerFrame:IsShown() then
    local onHide = fadeUIEscapeHandlerFrame:GetScript("OnHide")
    fadeUIEscapeHandlerFrame:SetScript("OnHide", nil)
    fadeUIEscapeHandlerFrame:Hide()
    fadeUIEscapeHandlerFrame:SetScript("OnHide", onHide)
  end
end
-- When the UI is loaded fadeUIEscapeHandlerFrame is shown, so we hide it.
UIEscapeHandlerDisable()



-- To prevent unintended showing of UIParent, we set this flag whenever we have hidden it.
local uiParentHidden = false



local enterCombatFrame = CreateFrame("Frame")
enterCombatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
enterCombatFrame:SetScript("OnEvent", function()
  -- print("enterCombatFrame")

  -- If entering combat while UIParent is hidden,
  -- we have to show it here again, because it is not allowed during combat.
  -- To avoid that the UI is also faded in again, we have to
  -- temporarily disable our UIEscapeHandler while showing UIParent.
  if not UIParent:IsShown() then
    local fadeUIEscapeHandlerShown = fadeUIEscapeHandlerFrame:IsShown()
    if fadeUIEscapeHandlerShown then UIEscapeHandlerDisable() end
    uiParentHidden = false
    UIParent:Show()
    if fadeUIEscapeHandlerShown then fadeUIEscapeHandlerFrame:Show() end
  end

  -- If entering combat while frames are faded to 0 *and hidden*,
  -- we have to show the hidden frames again, because Show() is
  -- not allowed for protected frames during combat.
  if ludius_UiHideModule.uiHiddenTime ~= 0 then
    Addon.ShowUI(0, true)
  end
end)

-- If the user leaves combat while still in a situation with hidden UI,
-- we hide it again everything again.
local leaveCombatFrame = CreateFrame("Frame")
leaveCombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
leaveCombatFrame:SetScript("OnEvent", function()
  -- print("leaveCombatFrame")

  -- But not, if the user has pressed ESC in between.
  if fadeUIEscapeHandlerFrame:IsShown() then
    -- Check if we are currently in a situation with hideUI settings.
    local curSituation = DynamicCam.db.profile.situations[DynamicCam.currentSituationID]
    if curSituation and curSituation.hideUI.enabled then
      DynamicCam:FadeOutUI(0, curSituation.hideUI)
    end
  end
end)




-- To prevent UIParent from being shown when a situation change coincides with a cinematic start.
-- CINEMATIC_START and CINEMATIC_STOP are just for in-game cinematics.
-- For pre-rendered cinematics, there is unfortunately no stop event.
-- CinematicFrame:IsShown() also does not work for pre-rendered cinematics.
-- So we go with just taking the elapsed time since the last PLAY_MOVIE.
local ingameCinematicRunning = false
local lastPlayMovie = GetTime()
local cinematicTrackingFrame = CreateFrame("Frame")
cinematicTrackingFrame:RegisterEvent("CINEMATIC_START")
cinematicTrackingFrame:RegisterEvent("CINEMATIC_STOP")
cinematicTrackingFrame:RegisterEvent("PLAY_MOVIE")
cinematicTrackingFrame:SetScript("OnEvent", function(_, event)
  if event == "CINEMATIC_START" then
    ingameCinematicRunning = true
  elseif event == "CINEMATIC_STOP" then
    ingameCinematicRunning = false
  else
    lastPlayMovie = GetTime()
  end
end)



-- To prevent other addons (Immersion, I'm looking in your direction) from
-- fading-in UIParent while DynamicCam has hidden it.
hooksecurefunc(UIParent, "SetAlpha", function(self, alpha)
  -- print("UIParent SetAlpha", alpha, UIParent.ludius_intendedUIParentAlpha)
  if UIParent.ludius_intendedUIParentAlpha ~= nil and UIParent.ludius_intendedUIParentAlpha ~= alpha then
    -- print("no")
    UIParent:SetAlpha(UIParent.ludius_intendedUIParentAlpha)
  -- else
    -- print("ok")
  end
end)


-- WoW's UIFrameFade(), UIFrameFadeOut() and UIFrameFadeIn() cause errors in combat lockdown when used with UIParent.
-- Hence, we need our own function.
local easeUIParentAlphaHandle
local function EaseUIParentAlpha(endValue, duration, callback)
  if easeUIParentAlphaHandle then
    LibEasing:StopEasing(easeUIParentAlphaHandle)
    easeUIParentAlphaHandle = nil
  end

  if UIParent:GetAlpha() ~= endValue then
    easeUIParentAlphaHandle = LibEasing:Ease(
      function(alpha)
        if alpha == 1 then
          UIParent.ludius_intendedUIParentAlpha = nil
        else
          UIParent.ludius_intendedUIParentAlpha = alpha
        end

        UIParent:SetAlpha(alpha)
      end,
      UIParent:GetAlpha(),
      endValue,
      duration,
      LibEasing.Linear,
      callback
    )
  else
    if callback then callback() end
  end
end


function DynamicCam:FadeOutUI(fadeOutTime, settings)

  -- print("FadeOutUI", fadeOutTime, GetTime())

  -- If we are starting to fade-out while a fade-in was still in progress,
  -- we are not updating ludius_alphaBeforeFadeOut.
  -- Because ludius_alphaBeforeFadeOut is only set to nil after a fade-in is complete.
  if UIParent.ludius_alphaBeforeFadeOut == nil then

    -- If fading of another source (e.g. Immersion) is in progress.
    if fadeOutTime > 0 and UIParent.fadeInfo and UIParent.fadeInfo.fadeTimer ~= nil and UIParent.fadeInfo.timeToFade ~= nil and tonumber(UIParent.fadeInfo.fadeTimer) < tonumber(UIParent.fadeInfo.timeToFade) then

      -- When fading out we take the maximum alpha of the other fade as our alpha before fade out.
      UIParent.ludius_alphaBeforeFadeOut = math.max(UIParent.fadeInfo.startAlpha, UIParent.fadeInfo.endAlpha)

      -- Stop the other fade progress.
      -- (We do not want to use the UIFrameFade(), UIFrameFadeOut() and UIFrameFadeIn()
      -- which we have seen to cause errors in combat lockdown when used with UIParent.)
      UIParent.fadeInfo.startAlpha = UIParent:GetAlpha()
      UIParent.fadeInfo.endAlpha = UIParent:GetAlpha()
      UIParent.fadeInfo.timeToFade = -1

    else
      UIParent.ludius_alphaBeforeFadeOut = UIParent:GetAlpha()
    end
    -- print("Remembering", UIParent.ludius_alphaBeforeFadeOut)
  end

  EaseUIParentAlpha(settings.hideEntireUI and 0 or settings.fadeOpacity, fadeOutTime)

  if settings.hideEntireUI then

    -- The frame rate indicator is the only frame that is independent of UIParent.
    -- So we can keep or hide it even when UIParent is hidden.
    Addon.HideUI(fadeOutTime, {hideFrameRate = not settings.keepFrameRate, UIParentAlpha = 0})

    if self.hideEntireUITimer then LibStub("AceTimer-3.0"):CancelTimer(self.hideEntireUITimer) end
    self.hideEntireUITimer = LibStub("AceTimer-3.0"):ScheduleTimer(
      function()
          if not InCombatLockdown() then
              UIParent:Hide()
              uiParentHidden = true
          end
      end,
      fadeOutTime
    )
  else
    local config = {
      UIParentAlpha = settings.fadeOpacity,

      hideFrameRate = not settings.keepFrameRate,

      keepAlertFrames = settings.keepAlertFrames,
      keepTooltip = settings.keepTooltip,
      keepMinimap = settings.keepMinimap,
      keepChatFrame = settings.keepChatFrame,
      keepPartyRaidFrame = settings.keepPartyRaidFrame,
      keepTrackingBar = settings.keepTrackingBar,
      -- This only has an effect when keepTrackingBar is true.
      -- (For now we are not allowing DynamicCam users to partially fade out single frames.
      -- That's just for "Immersion ExtraFade".)
      trackingBarAlpha = 1,
      keepEncounterBar = settings.keepEncounterBar,

      keepCustomFrames   = settings.keepCustomFrames,
      customFramesToKeep = settings.customFramesToKeep,
    }

    -- Use the UiHideModule to keep configured frames and properly hide the others.
    Addon.HideUI(fadeOutTime, config)
  end

  if settings.emergencyShowEscEnabled then
    fadeUIEscapeHandlerFrame:Show()
  end
end

function DynamicCam:FadeInUI(fadeInTime)

  -- print("FadeInUI", fadeInTime, GetTime())

  if self.hideEntireUITimer then LibStub("AceTimer-3.0"):CancelTimer(self.hideEntireUITimer) end

  -- Actually allow the last PLAY_MOVIE to be at most 2 seconds ago. You never know...
  if not UIParent:IsShown() and uiParentHidden and not ingameCinematicRunning and lastPlayMovie + 2 < GetTime() then
    uiParentHidden = false
    UIParent:Show()
  end

  -- If fading of another source (e.g. Immersion) is in progress, stop it.
  if fadeInTime > 0 and UIParent.fadeInfo and UIParent.fadeInfo.fadeTimer ~= nil and UIParent.fadeInfo.timeToFade ~= nil and tonumber(UIParent.fadeInfo.fadeTimer) < tonumber(UIParent.fadeInfo.timeToFade) then
    UIParent.fadeInfo.startAlpha = UIParent:GetAlpha()
    UIParent.fadeInfo.endAlpha = UIParent:GetAlpha()
    UIParent.fadeInfo.timeToFade = -1
  end


  if UIParent.ludius_alphaBeforeFadeOut then

    UIEscapeHandlerDisable()

    local function FadeInCallback()
      -- print("Fade in finished")
      UIParent.ludius_alphaBeforeFadeOut = nil
      UIParent.ludius_intendedUIParentAlpha = nil
    end

    -- print("UIParent.ludius_alphaBeforeFadeOut", UIParent.ludius_alphaBeforeFadeOut)
    EaseUIParentAlpha(UIParent.ludius_alphaBeforeFadeOut, fadeInTime, FadeInCallback)

    Addon.ShowUI(fadeInTime, false)
  end
end



----------
-- CORE --
----------
local started = false

function DynamicCam:OnInitialize()

  -- setup db
  self:InitDatabase()
  self:RefreshConfig()

  -- setup chat commands
  self:RegisterChatCommand("dynamiccam", "OpenMenu")
  self:RegisterChatCommand("dc", "OpenMenu")

  self:RegisterChatCommand("saveview", "SaveViewSlash")
  self:RegisterChatCommand("sv", "SaveViewSlash")
  self:RegisterChatCommand("setView", "SetViewSlash")

  self:RegisterChatCommand("zoominfo", "ZoomInfoSlash")
  self:RegisterChatCommand("zi", "ZoomInfoSlash")

  self:RegisterChatCommand("zoom", "ZoomSlash")
  self:RegisterChatCommand("pitch", "PitchSlash")
  self:RegisterChatCommand("yaw", "YawSlash")

  self:RegisterChatCommand("hideUI", "HideUISlash")
  self:RegisterChatCommand("showUI", "ShowUISlash")

  -- Disable the ActionCam warning message.
  UIParent:UnregisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED")


end

function DynamicCam:OnEnable()
  self:Startup()
end

function DynamicCam:OnDisable()
  self:Shutdown()
end

function DynamicCam:Startup()

  -- If there is a bug in the options, don't start.
  if not DynamicCam.GetSettingsValue then
    return self:Shutdown()
  end


  if started then return end

  self.enteredSituationAtLogin = false


  -- initial evaluate needs to be delayed because the camera doesn't like changing cvars on startup
  self:ScheduleTimer("ApplySettings", 0.1)
  self:ScheduleTimer("EvaluateSituations", 0.2)
  self:ScheduleTimer("RegisterEvents", 0.3)

  -- turn on reactive zoom if it's enabled
  if self:GetSettingsValue(self.currentSituationID, "reactiveZoomEnabled") then
    self:ReactiveZoomOn()
  else
    -- Must call this to prehook NonReactiveZoomIn/Out.
    self:ReactiveZoomOff()
  end



  if tonumber(GetCVar("CameraKeepCharacterCentered")) == 1 then

    if tonumber(GetCVar("test_cameraOverShoulder")) ~= 0 then
      print("|cFFFF0000" .. L["While you are using horizontal camera offset, DynamicCam prevents CameraKeepCharacterCentered!"] .. "|r")
      SetCVar("CameraKeepCharacterCentered", false, "DynamicCam")

    elseif tonumber(GetCVar("test_cameraDynamicPitch")) == 1 then
      print("|cFFFF0000" .. L["While you are using vertical camera pitch, DynamicCam prevents CameraKeepCharacterCentered!"] .. "|r")
      SetCVar("CameraKeepCharacterCentered", false, "DynamicCam")
    end

  end

  -- As off 11.0.2 this is also needed for shoulder offset to take effect.
  if tonumber(GetCVar("CameraReduceUnexpectedMovement")) == 1 then
    if tonumber(GetCVar("test_cameraOverShoulder")) ~= 0 then
      print("|cFFFF0000" .. L["While you are using horizontal camera offset, DynamicCam prevents CameraReduceUnexpectedMovement!"] .. "|r")
      SetCVar("CameraReduceUnexpectedMovement", false, "DynamicCam")
    end
  end

  -- https://github.com/Mpstark/DynamicCam/issues/40
  local validValuesCameraView = {[1] = true, [2] = true, [3] = true, [4] = true, [5] = true,}
  if not validValuesCameraView[tonumber(GetCVar("cameraView"))] then
    -- print("cameraView =", GetCVar("cameraView"), "prevented by DynamicCam!")
    SetCVar("cameraView", GetCVarDefault("cameraView"))
  end


  self:SettingsPanelSetIgnoreParentAlpha(DynamicCam.db.profile.settingsPanelIgnoreParentAlpha)
  hooksecurefunc(
    LibStub("AceGUI-3.0"),
    "Create",
    function(_, widgetType)
      if widgetType == "Dropdown-Pullout" then
        DynamicCam:SettingsPanelSetIgnoreParentAlpha(DynamicCam.db.profile.settingsPanelIgnoreParentAlpha)
      end
    end
  )


  -- A frame to determine the current player model.
  if DynamicCam.db.profile.reactiveZoomEnhancedMinZoom then
    DynamicCam.modelFrame = CreateFrame("PlayerModel")
  end


  constantlyRunningFrame:SetScript("OnUpdate", ConstantlyRunningFrameFunction)

  started = true


  -- -- For coding
  -- C_Timer.After(0, function()
    -- self:OpenMenu()
    -- LibStub("AceConfigDialog-3.0"):SelectGroup("DynamicCam", "standardSettingsTab")
    -- -- LibStub("AceConfigDialog-3.0"):SelectGroup("DynamicCam", "situationSettingsTab", "situationSettings")
    -- -- LibStub("AceConfigDialog-3.0"):SelectGroup("DynamicCam", "situationSettingsTab", "export")
  -- end)

  -- C_Timer.After(3, function()
    -- if BugSack then
      -- BugSack:OpenSack()
      -- BugSackFrame:SetIgnoreParentAlpha(true)
      -- BugSackFrame:Hide()
    -- end
  -- end)

end

function DynamicCam:Shutdown()

  if not started then return end

  -- exit the current situation if in one
  if self.currentSituationID then
    self:ChangeSituation(self.currentSituationID, nil)
  end

  self.events = {}
  self:UnregisterAllEvents()
  self:UnregisterAllMessages()

  self:ApplySettings()

  self:ReactiveZoomOff()

  constantlyRunningFrame:SetScript("OnUpdate", nil)

  started = false
end

-- function DynamicCam:DebugPrint(...)
  -- if self.db.profile.debugMode then
    -- self:Print(...)
  -- end
-- end





-------------
-- UTILITY --
-------------
function DynamicCam:ApplySettings()

  local curSituation = self.db.profile.situations[self.currentSituationID]

  -- Set the cvars (standard or situation).
  for cvar, value in pairs(self.db.profile.standardSettings.cvars) do

    if curSituation and curSituation.situationSettings.cvars[cvar] then
      value = curSituation.situationSettings.cvars[cvar]
    end

    -- Skip cvars that are zoom-based or currently being eased - CvarUpdateFunction handles them
    if not (self:IsCvarZoomBased(self.currentSituationID, cvar) or self:IsCvarBeingEased(cvar)) then
      self:DC_SetCVar(cvar, value)
    end
  end

  -- Set reactive zoom.
  if self:GetSettingsValue(self.currentSituationID, "reactiveZoomEnabled") then
    self:ReactiveZoomOn()
  else
    self:ReactiveZoomOff()
  end


  if not LibCamera:IsZooming() then
    -- This is necessary to see effects of changing the maximum camera distance, without having to manually zoom.
    self:ZoomSlash(GetCameraZoom() .. " " .. 0)
  end

  -- print("Finished ApplySettings", newSituationID, GetTime())
end






--------------
-- DATABASE --
--------------

function DynamicCam:InitDatabase()
  self.db = LibStub("AceDB-3.0"):New("DynamicCamDB", self.defaults, true)
  self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
  self.db.RegisterCallback(self, "OnDatabaseShutdown", "Shutdown")


  if DynamicCamDB.profiles then

    -- reset db if we've got a really old version
    for profileName, profile in pairs(DynamicCamDB.profiles) do
      if profile.defaultCvars and profile.defaultCvars["cameraovershoulder"] then
        self:Print("Detected very old profile versions, resetting DB, sorry about that!")
        self.db:ResetDB()
      end
    end


    local profilesModernized = false

    -- modernize each profile
    for profileName, profile in pairs(DynamicCamDB.profiles) do
      local modernized = self:ModernizeProfile(profile)
      profilesModernized = profilesModernized or modernized
    end

    -- Setting the profile cleans up the storage.
    -- I.e. defaults are not explicitly stored.
    if profilesModernized then
      local currentProfile = self.db:GetCurrentProfile()
      for profileName, profile in pairs(DynamicCamDB.profiles) do
        self.db:SetProfile(profileName)
      end
      self.db:SetProfile(currentProfile)
    end

  end

end


-- This function checks if a value exists in the values table.
-- We have to make the check like this, because values[key] may be false or 0, which are valid values and should not be overridden by the default.
local function ValueOrDefault(values, defaults, key)
  if values and values[key] ~= nil then
    return values[key]
  else
    return defaults[key]
  end
end




-- 1 : some early DC version
-- 2 : DC pre-2.0
-- 3 : DC post-2.0
-- 4 : New mounted situation IDs.
-- 5 : Migrated shoulderOffsetZoom to cvarsZoomBased (stored in standardSettings/situationSettings).
--     Generalized transition times (migrate from zoom/rotation/UI fade times to transitionTime.timeToEnter/Exit).
function DynamicCam:ModernizeProfile(p)

  -- If there is no version number, it is most probably a newly created one!
  if not p.version then
    p.version = 5
    return false
  end


  if p.version == 1 then

    if p.defaultCvars and p.defaultCvars["test_cameraLockedTargetFocusing"] ~= nil then
      p.defaultCvars["test_cameraLockedTargetFocusing"] = nil
    end

    -- modernize each situation
    if p.situations then
      for k, v in pairs(p.situations) do
        self:ModernizeSituation(v, k, p.version)
      end
    end

    p.version = 2
  end


  -- Upgrade to DynamicCam 2.0
  if p.version == 2 then

    -- Not changing:
    -- p.zoomRestoreSetting

    -- These existed before. But as the user is currently not supposed to change the values, we do not set them (i.e. they assume the default).
    -- p.standardSettings.easingZoom
    -- p.standardSettings.easingYaw
    -- p.standardSettings.easingPitch
    -- p.standardSettings.reactiveZoomEasingFunc

    -- Newly introduced setting also assumes default.
    -- p.settingsPanelIgnoreParentAlpha

    p.standardSettings = {cvars = {},}

    p.standardSettings.reactiveZoomEnabled             = ValueOrDefault(p.reactiveZoom, DynamicCam.v2Defaults.reactiveZoom, "enabled")
    p.standardSettings.reactiveZoomAddIncrementsAlways = ValueOrDefault(p.reactiveZoom, DynamicCam.v2Defaults.reactiveZoom, "addIncrementsAlways")
    p.standardSettings.reactiveZoomAddIncrements       = ValueOrDefault(p.reactiveZoom, DynamicCam.v2Defaults.reactiveZoom, "addIncrements")
    p.standardSettings.reactiveZoomIncAddDifference    = ValueOrDefault(p.reactiveZoom, DynamicCam.v2Defaults.reactiveZoom, "incAddDifference")
    p.standardSettings.reactiveZoomMaxZoomTime         = ValueOrDefault(p.reactiveZoom, DynamicCam.v2Defaults.reactiveZoom, "maxZoomTime")

    p.standardSettings.shoulderOffsetZoomEnabled       = ValueOrDefault(p.shoulderOffsetZoom, DynamicCam.v2Defaults.shoulderOffsetZoom, "enabled")
    p.standardSettings.shoulderOffsetZoomLowerBound    = ValueOrDefault(p.shoulderOffsetZoom, DynamicCam.v2Defaults.shoulderOffsetZoom, "lowerBound")
    p.standardSettings.shoulderOffsetZoomUpperBound    = ValueOrDefault(p.shoulderOffsetZoom, DynamicCam.v2Defaults.shoulderOffsetZoom, "upperBound")

    for cvarName, _ in pairs(p.defaultCvars) do
      p.standardSettings.cvars[cvarName] = ValueOrDefault(p.defaultCvars, DynamicCam.v2Defaults.defaultCvars, cvarName)
    end


    -- If we did not import anything...
    if next(p.standardSettings.cvars) == nil then p.standardSettings.cvars = nil end
    if next(p.standardSettings) == nil then p.standardSettings = nil end


    -- Deep compare of two tables in Lua is not trivial.
    -- So we just delete all old settings manually here.
    p.enabled = nil
    p.advanced = nil
    p.debugMode = nil
    p.actionCam = nil

    p.easingZoom = nil
    p.easingYaw = nil
    p.easingPitch = nil

    p.reactiveZoom = nil
    p.shoulderOffsetZoom = nil
    p.defaultCvars = nil


    -- modernize each situation
    if p.situations then
      for k, v in pairs(p.situations) do
        self:ModernizeSituation(v, k, p.version)
        -- It may happen that a situation becomes empty
        -- because old values are the same as new defaults.
        -- (Particularly "enabled")
        if next(v) == nil then p.situations[k] = nil end
      end
    end

    p.version = 3

  end


  -- Rearrange situation IDs.
  if p.version == 3 then

    if p.situations then

      local function SwapSituationIDs(src, dst, situations)
        if situations[src] then
          assert(not situations[dst])
          situations[dst] = situations[src]
          situations[src] = nil
        end
      end

      SwapSituationIDs("102", "170", p.situations)    -- Vehicle
      SwapSituationIDs("101", "160", p.situations)    -- Taxi
      SwapSituationIDs("103", "115", p.situations)    -- Druid Travel Form
      SwapSituationIDs("100.5", "105", p.situations)  -- mounted (only airborne)
      SwapSituationIDs("126", "106", p.situations)    -- mounted (only airborne + Skyriding)
      SwapSituationIDs("125", "107", p.situations)    -- mounted (only Skyriding)

    end

    p.version = 4

  end


  -- Migrate legacy shoulderOffsetZoom to new zoom-based settings system.
  if p.version == 4 then

    local maxZoom = self.cameraDistanceMaxZoomFactor_max or 39

    -- Get effective profile-wide values (stored values or defaults)
    -- These were global settings that applied to ALL shoulder offsets (standard + all situations)
    local enabled = ValueOrDefault(p.standardSettings, DynamicCam.v4ShoulderOffsetZoomDefaults, "shoulderOffsetZoomEnabled")
    local lowerBound = ValueOrDefault(p.standardSettings, DynamicCam.v4ShoulderOffsetZoomDefaults, "shoulderOffsetZoomLowerBound")
    local upperBound = ValueOrDefault(p.standardSettings, DynamicCam.v4ShoulderOffsetZoomDefaults, "shoulderOffsetZoomUpperBound")

    -- Helper function to create zoom-based curve for a settings table
    local function CreateZoomBasedCurve(settings, shoulderOffset)
      if shoulderOffset ~= 0 then
        -- Initialize cvarsZoomBased if needed
        if not settings.cvarsZoomBased then
          settings.cvarsZoomBased = {}
        end

        -- Create the zoom-based setting with migrated points:
        -- (0, 0) -> (lowerBound, 0) -> (upperBound, fullValue) -> (maxZoom, fullValue)
        settings.cvarsZoomBased["test_cameraOverShoulder"] = {
          enabled = true,
          points = {
            {zoom = 0, value = 0},
            {zoom = lowerBound, value = 0},
            {zoom = upperBound, value = shoulderOffset},
            {zoom = maxZoom, value = shoulderOffset},
          }
        }
      end
    end

    -- Migrate standard settings if shoulder offset exists there
    if enabled and p.standardSettings then
      local shoulderOffset = p.standardSettings.cvars and p.standardSettings.cvars.test_cameraOverShoulder or 0
      if shoulderOffset ~= 0 then
        CreateZoomBasedCurve(p.standardSettings, shoulderOffset)
      end
    end

    -- Migrate each situation's settings if shoulder offset exists there
    if enabled and p.situations then
      for situationID, situation in pairs(p.situations) do
        if situation.situationSettings and situation.situationSettings.cvars then
          local shoulderOffset = situation.situationSettings.cvars.test_cameraOverShoulder
          if shoulderOffset and shoulderOffset ~= 0 then
            CreateZoomBasedCurve(situation.situationSettings, shoulderOffset)
          end
        end
      end
    end

    -- Always remove the old profile-wide settings (they will be ignored anyway, but clean up)
    if p.standardSettings then
      p.standardSettings.shoulderOffsetZoomEnabled = nil
      p.standardSettings.shoulderOffsetZoomLowerBound = nil
      p.standardSettings.shoulderOffsetZoomUpperBound = nil
    end


    -- Modernize each situation (transition time migration)
    if p.situations then
      for k, v in pairs(p.situations) do
        self:ModernizeSituation(v, k, p.version)
      end
    end

    p.version = 5
    return true

  end

  return false
end



function DynamicCam:ModernizeSituation(s, situationID, version)

  if version == 1 then

    -- clear unused nameplates db stuff
    if s.extras then
      s.extras["nameplates"] = nil
      s.extras["friendlyNameplates"] = nil
      s.extras["enemyNameplates"] = nil
    end

    -- update targetlock features
    if s.targetLock then
      if s.targetLock.enabled then
        if not s.cameraCVars then
          s.cameraCVars = {}
        end

        if s.targetLock.onlyAttackable ~= nil and s.targetLock.onlyAttackable == false then
          s.cameraCVars["test_cameraTargetFocusEnemyEnable"] = 1
          s.cameraCVars["test_cameraTargetFocusInteractEnable"] = 1
        else
          s.cameraCVars["test_cameraTargetFocusEnemyEnable"] = 1
        end
      end

      s.targetLock = nil
    end

    -- update camera rotation
    if s.cameraActions then
      -- convert to yaw degrees instead of rotate degrees
      if s.cameraActions.rotateDegrees then
        s.cameraActions.yawDegrees = s.cameraActions.rotateDegrees
        s.cameraActions.pitchDegrees = 0
        s.cameraActions.rotateDegrees = nil
      end

      -- convert old scalar rotate speed to something that's in degrees/second
      if s.cameraActions.rotateSpeed and s.cameraActions.rotateSpeed < 5 then
        s.cameraActions.rotateSpeed = s.cameraActions.rotateSpeed * tonumber(GetCVar("cameraYawMoveSpeed"))
      end
    end

  end

  if version == 2 then

    -- The new default is "disabled".
    if s.enabled == nil then
      s.enabled = true
    else
      s.enabled = nil
    end


    -- Not changing:
    -- s.name
    -- s.executeOnInit
    -- s.priority
    -- s.events
    -- s.condition
    -- s.executeOnEnter
    -- s.executeOnExit
    -- s.delay


    s.viewZoom = {}
    s.rotation = {}
    s.hideUI = {}
    s.situationSettings = {cvars = {},}


    -- Only restoring old values or defaults if an option was enabled.


    local oldValues = s.cameraActions
    local oldDefaults = DynamicCam.v2Defaults.situations.cameraActions

    -- For AFK situation we need to restore special defaults...
    if situationID == "303" then
      oldDefaults = {}
      for k, v in pairs(DynamicCam.v2Defaults.situations.cameraActions) do
        if DynamicCam.v2Defaults.afkSituation.cameraActions[k] then
          -- print("Taking", k, DynamicCam.v2Defaults.afkSituation.cameraActions[k], "from AFK defaults.")
          oldDefaults[k] = DynamicCam.v2Defaults.afkSituation.cameraActions[k]
        else
          -- print("Taking", k, v, "from global defaults.")
          oldDefaults[k] = v
        end
      end
    end

    if oldValues and oldValues.zoomSetting and oldValues.zoomSetting ~= "off" then
      s.viewZoom.enabled      = true
      s.viewZoom.viewZoomType = "zoom"
      s.viewZoom.zoomTransitionTime = ValueOrDefault(oldValues, oldDefaults, "transitionTime")
      s.viewZoom.zoomType           = ValueOrDefault(oldValues, oldDefaults, "zoomSetting")
      s.viewZoom.zoomValue          = ValueOrDefault(oldValues, oldDefaults, "zoomValue")
      s.viewZoom.zoomMin            = ValueOrDefault(oldValues, oldDefaults, "zoomMin")
      s.viewZoom.zoomMax            = ValueOrDefault(oldValues, oldDefaults, "zoomMax")
      s.viewZoom.zoomTimeIsMax      = ValueOrDefault(oldValues, oldDefaults, "timeIsMax")
    end

    -- Different default for AFK situation...
    if (oldValues and oldValues.rotate) or (situationID == "303" and (oldValues == nil or oldValues.rotate == nil)) then
      s.rotation.enabled            = true
      s.rotation.rotationType       = ValueOrDefault(oldValues, oldDefaults, "rotateSetting")
      s.rotation.rotationTime       = ValueOrDefault(oldValues, oldDefaults, "transitionTime")
      s.rotation.rotationSpeed      = ValueOrDefault(oldValues, oldDefaults, "rotateSpeed")
      s.rotation.yawDegrees         = ValueOrDefault(oldValues, oldDefaults, "yawDegrees")
      s.rotation.pitchDegrees       = ValueOrDefault(oldValues, oldDefaults, "pitchDegrees")
      s.rotation.rotateBack         = ValueOrDefault(oldValues, oldDefaults, "rotateBack")
      s.rotation.rotateBackTime     = ValueOrDefault(oldValues, oldDefaults, "transitionTime")
    end

    -- From DC 2.0 on, you cannot do a view change and a zoom change at the same time.
    -- A view change has higher priority than zoom change. By checking view here,
    -- a possible zoom change gets overridden.
    oldValues = s.view
    oldDefaults = DynamicCam.v2Defaults.situations.view
    if oldValues and oldValues.enabled then
      s.viewZoom.enabled      = true
      s.viewZoom.viewZoomType = "view"
      s.viewZoom.viewNumber   = ValueOrDefault(oldValues, oldDefaults, "viewNumber")
      s.viewZoom.viewRestore  = ValueOrDefault(oldValues, oldDefaults, "restoreView")
      s.viewZoom.viewInstant  = ValueOrDefault(oldValues, oldDefaults, "instant")
    end

    oldValues = s.extras
    oldDefaults = DynamicCam.v2Defaults.situations.extras
    -- Different default for AFK situation...
    if (oldValues and oldValues.hideUI) or (situationID == "303" and (oldValues == nil or oldValues.hideUI == nil)) then
      s.hideUI.enabled      = true
      s.hideUI.fadeOpacity  = ValueOrDefault(oldValues, oldDefaults, "hideUIFadeOpacity")
      s.hideUI.hideEntireUI = ValueOrDefault(oldValues, oldDefaults, "actuallyHideUI")
      s.hideUI.keepMinimap  = ValueOrDefault(oldValues, oldDefaults, "keepMinimap")
    end

    -- There are and were no defaults for situation specific cvars.
    if s.cameraCVars then
      for cvarName, cvarValue in pairs(s.cameraCVars) do
        s.situationSettings.cvars[cvarName] = cvarValue
      end
    end


    -- Delete entries if empty.
    if next(s.viewZoom) == nil then s.viewZoom = nil end
    if next(s.rotation) == nil then s.rotation = nil end
    if next(s.hideUI) == nil then s.hideUI = nil end
    if next(s.situationSettings.cvars) == nil then s.situationSettings.cvars = nil end
    if next(s.situationSettings) == nil then s.situationSettings = nil end

    -- Delete old entries.
    s.cameraActions = nil
    s.view = nil
    s.extras = nil
    s.cameraCVars = nil

  end

  if version == 4 then

    -- Migrate to generalized transition times.
    local maxEnterTime = 0
    local maxExitTime = 0

    -- Check zoom transition time (for entering)
    -- Only effective if viewZoom.enabled AND viewZoomType == "zoom"
    if s.viewZoom then
      local enabled = ValueOrDefault(s.viewZoom, DynamicCam.situationDefaults.viewZoom, "enabled")
      local viewZoomType = ValueOrDefault(s.viewZoom, DynamicCam.situationDefaults.viewZoom, "viewZoomType")
      if enabled and viewZoomType == "zoom" then
        maxEnterTime = math.max(maxEnterTime, ValueOrDefault(s.viewZoom, DynamicCam.v4TransitionTimeDefaults.viewZoom, "zoomTransitionTime"))
      end
      s.viewZoom.zoomTransitionTime = nil
    end

    -- Check rotation times (for entering and exiting)
    -- Only effective if rotation.enabled
    if s.rotation then
      local enabled = ValueOrDefault(s.rotation, DynamicCam.situationDefaults.rotation, "enabled")
      if enabled then
        maxEnterTime = math.max(maxEnterTime, ValueOrDefault(s.rotation, DynamicCam.v4TransitionTimeDefaults.rotation, "rotationTime"))
        -- rotateBackTime only effective if rotation.rotateBack is also true
        local rotateBack = ValueOrDefault(s.rotation, DynamicCam.situationDefaults.rotation, "rotateBack")
        if rotateBack then
          maxExitTime = math.max(maxExitTime, ValueOrDefault(s.rotation, DynamicCam.v4TransitionTimeDefaults.rotation, "rotateBackTime"))
        end
      end
      s.rotation.rotationTime = nil
      s.rotation.rotateBackTime = nil
    end

    -- Check UI fade times (for entering and exiting)
    -- Only effective if hideUI.enabled
    if s.hideUI then
      local enabled = ValueOrDefault(s.hideUI, DynamicCam.situationDefaults.hideUI, "enabled")
      if enabled then
        maxEnterTime = math.max(maxEnterTime, ValueOrDefault(s.hideUI, DynamicCam.v4TransitionTimeDefaults.hideUI, "fadeOutTime"))
        maxExitTime = math.max(maxExitTime, ValueOrDefault(s.hideUI, DynamicCam.v4TransitionTimeDefaults.hideUI, "fadeInTime"))
      end
      s.hideUI.fadeOutTime = nil
      s.hideUI.fadeInTime = nil
    end

    -- Always create transitionTime (even if both times are 0)
    s.transitionTime = {
      timeToEnter = maxEnterTime,
      timeToExit = maxExitTime,
    }

  end

end

function DynamicCam:RefreshConfig()

  -- shutdown the addon
  if started then
    self:Shutdown()
  end

  -- situation is active, but db killed it
  if self.currentSituationID then
    self.currentSituationID = nil
  end

  -- clear the options panel so that it reselects
  -- make sure that options panel selects a situation
  if self.Options then
    self.Options:ClearSelection()
    self.Options:SelectSituation()
  end

  -- Refresh all open curve editors to display the new profile's data
  self:RefreshAllCurveEditors()

  -- start the addon back up
  if not started then
    self:Startup()
  end

  -- run all situations's advanced init script
  for id, situation in pairs(self.db.profile.situations) do

    -- So we don't have old error messages active.
    situation.errorEncountered = nil
    situation.errorMessage = nil

    if situation.enabled then
      self:RunScript(id, "executeOnInit")
    end
  end
end



-------------------
-- CHAT COMMANDS --
-------------------
local function tokenize(str, delimitor)
  local tokens = {}
  for token in str:gmatch(delimitor or "%S+") do
    table.insert(tokens, token)
  end
  return tokens
end

StaticPopupDialogs["DYNAMICCAM_NEW_CUSTOM_SITUATION"] = {
  text = L["Enter name for custom situation:"],
  button1 = L["Create"],
  button2 = L["Cancel"],
  timeout = 0,
  hasEditBox = true,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see https://authors.curseforge.com/forums/world-of-warcraft/general-chat/lua-code-discussion/226040-how-to-reduce-chance-of-ui-taint-from
  OnShow = function (self)
    -- self.editBox is no longer accessible since 11.2.
    local editBox = self.editBox or _G[self:GetName() .. "EditBox"]
    editBox:SetFocus()
  end,
  OnAccept = function (self, data)
    -- self.editBox is no longer accessible since 11.2.
    local editBox = self.editBox or _G[self:GetName() .. "EditBox"]
    DynamicCam:CreateCustomSituation(editBox:GetText())
  end,
  EditBoxOnEnterPressed = function(self)
    -- self.editBox is no longer accessible since 11.2.
    local editBox = self:GetParent().editBox or _G[self:GetName() .. "EditBox"]
    DynamicCam:CreateCustomSituation(editBox:GetText())
    self:GetParent():Hide()
  end,
}



local exportString
StaticPopupDialogs["DYNAMICCAM_EXPORT"] = {
  text = "DynamicCam Export:",
  button1 = "Done!",
  timeout = 0,
  hasEditBox = true,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see https://authors.curseforge.com/forums/world-of-warcraft/general-chat/lua-code-discussion/226040-how-to-reduce-chance-of-ui-taint-from
  OnShow = function (self)
    -- self.editBox is no longer accessible since 11.2.
    local editBox = self.editBox or _G[self:GetName() .. "EditBox"]
    editBox:SetText(exportString)
    editBox:HighlightText()
  end,
  EditBoxOnEnterPressed = function(self)
    self:GetParent():Hide()
  end,
}

function DynamicCam:OpenMenu()

  if not SettingsPanel or not SettingsPanel:IsShown() then
  
    -- Cannot open menu during combat.
    if InCombatLockdown() then
      self:Print("Addon code cannot open menu during combat.")
      return
    else
      Settings.OpenToCategory(self.Options.menu.name)
    end
  
  end

  self.Options:SelectSituation()

end

function DynamicCam:SaveViewSlash(input)
  local tokens = tokenize(input)

  local viewNumber = tonumber(tokens[1])

  if viewNumber and viewNumber <= 5 and viewNumber > 0 then
    SaveView(viewNumber)
  else
    self:Print("Improper view number provided. Only 1-5 allowed.")
  end
end


function DynamicCam:SetViewSlash(input)
  local tokens = tokenize(input)

  local viewNumber = tonumber(tokens[1])
  local instant = tokens[2] == "i"

  if viewNumber and viewNumber <= 5 and viewNumber > 0 then
    SetView(viewNumber)
    if instant then
      SetView(viewNumber)
    end
  else
    self:Print("Improper view number provided.")
  end
end



function DynamicCam:ZoomInfoSlash(input)
  self:Print(string.format("Zoom level: %0.2f", GetCameraZoom()))
end

function DynamicCam:ZoomSlash(input)
  local tokens = tokenize(input)

  local zoom = tonumber(tokens[1])
  local time = tonumber(tokens[2])
  local easingFuncName
  local easingFunc

  if not time then
    -- time not provided, maybe 2nd param is easingfunc?
    easingFuncName = tokens[2]
  else
    easingFuncName = tokens[3]
  end

  -- look up easing func
  if easingFuncName then
    easingFunc = LibEasing[easingFuncName] or LibEasing.InOutQuad
  end

  if zoom and (zoom <= DynamicCam.cameraDistanceMaxZoomFactor_max or zoom >= 0) then
    local defaultTime = math.abs(zoom - GetCameraZoom()) / tonumber(GetCVar("cameraZoomSpeed"))

    -- Whenever the zoom changes we need to reset the reactiveZoomTarget.
    DynamicCam:ResetReactiveZoomTarget()
    LibCamera:SetZoom(zoom, time or math.min(defaultTime, 0.75), easingFunc)
  end
end

function DynamicCam:PitchSlash(input)
  local tokens = tokenize(input)

  local pitch = tonumber(tokens[1])
  local time = tonumber(tokens[2])
  local easingFuncName
  local easingFunc

  if not time then
    -- time not provided, maybe 2nd param is easingfunc?
    easingFuncName = tokens[2]
  else
    easingFuncName = tokens[3]
  end

  -- look up easing func
  if easingFuncName then
    easingFunc = LibEasing[easingFuncName] or LibEasing.InOutQuad
  end

  if pitch and (pitch <= 90 or pitch >= -90) then
    LibCamera:Pitch(pitch, time or 0.75, easingFunc)
  end
end

function DynamicCam:YawSlash(input)
  local tokens = tokenize(input)

  local yaw = tonumber(tokens[1])
  local time = tonumber(tokens[2])
  local easingFuncName
  local easingFunc

  if not time then
    -- time not provided, maybe 2nd param is easingfunc?
    easingFuncName = tokens[2]
  else
    easingFuncName = tokens[3]
  end

  -- look up easing func
  if easingFuncName then
    easingFunc = LibEasing[easingFuncName] or LibEasing.InOutQuad
  end

  if yaw then
    LibCamera:Yaw(yaw, time or 0.75, easingFunc)
  end
end



function DynamicCam:ShowUISlash(input)
  local tokens = tokenize(input)
  local duration = tonumber(tokens[1])
  local currentSituation = self.db.profile.situations[self.currentSituationID]
  self:FadeInUI(duration or currentSituation.transitionTime.timeToExit)
end


function DynamicCam:HideUISlash(input)
  local tokens = tokenize(input)
  local duration = tonumber(tokens[1])
  local currentSituation = self.db.profile.situations[self.currentSituationID]
  self:FadeOutUI(duration or currentSituation.transitionTime.timeToEnter, currentSituation.hideUI)
end



function DynamicCam:PopupCreateCustomProfile()
  StaticPopup_Show("DYNAMICCAM_NEW_CUSTOM_SITUATION")
end

function DynamicCam:PopupExport(str)
  exportString = str
  StaticPopup_Show("DYNAMICCAM_EXPORT")
end

function DynamicCam:PopupExportProfile()
  self:PopupExport(self:ExportProfile())
end


-----------
-- CVARS --
-----------
function DynamicCam:ResetCVars()
  for cvar, value in pairs(self.db.profile.standardSettings.cvars) do
    self:DC_SetCVar(cvar, GetCVarDefault(cvar))
  end

  ResetView(1)
  ResetView(2)
  ResetView(3)
  ResetView(4)
  ResetView(5)
end







-- For debugging.
function DynamicCam:PrintTable(t, indent)
  assert(type(t) == "table", "PrintTable() called for non-table!")

  if not indent then indent = 0 end

  local indentString = ""
  for i = 1, indent do
    indentString = indentString .. "  "
  end

  for k, v in pairs(t) do
    if type(v) ~= "table" then
      print(indentString, k, "=", v)
    else
      print(indentString, k, "=")
      print(indentString, "  {")
      self:PrintTable(v, indent + 2)
      print(indentString, "  }")
    end
  end
end
