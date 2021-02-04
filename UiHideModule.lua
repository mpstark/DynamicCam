local _, Addon = ...


-- Flag. Also needed by emergency handling.
Addon.uiHiddenTime = 0


-- Call Addon.HideUI() to hide UI keeping configured frames.
-- Call Addon.ShowUI(true) when entering combat while UI is hidden.
--   This will show the actually hidden frames, that cannot be shown during combat,
--   but the fade out state will remain. You only see tooltips of faded-out frames.
-- Call Addon.ShowUI(false) to show UI.

-- Expecting configuration in config argument:

-- config.hideFrameRate
-- config.hideAlertFrame
-- config.hideChatFrame
-- config.hideTrackingBar
-- config.trackingBarAlpha


-- Lua API
local _G = _G
local string_find = string.find

local UIFrameFadeOut   = _G.UIFrameFadeOut
local UIFrameFadeIn    = _G.UIFrameFadeIn
local InCombatLockdown = _G.InCombatLockdown




-- The alert frames are hard to come by...
-- https://www.wowinterface.com/forums/showthread.php?p=337803
-- For testing:
-- /run UIParent:SetAlpha(0.5)
-- /run NewMountAlertSystem:ShowAlert("123"); NewMountAlertSystem:ShowAlert("123")

local collectedAlertFrames = {}
local alertFramesIgnoreParentAlpha = false

local function SetAlertFramesIgnoreParentAlpha(enable)
  alertFramesIgnoreParentAlpha = enable
  for _, v in pairs(collectedAlertFrames) do
    v:SetIgnoreParentAlpha(enable)
  end
end

local function CollectAlertFrame(_, frame)
  if not frame.ludius_collected then
    tinsert(collectedAlertFrames, frame)
    frame.ludius_collected = true
    frame:SetIgnoreParentAlpha(alertFramesIgnoreParentAlpha)
  end
end

for _, subSystem in pairs(AlertFrame.alertFrameSubSystems) do
  local pool = type(subSystem) == 'table' and subSystem.alertFramePool
  if type(pool) == 'table' and type(pool.resetterFunc) == 'function' then
    hooksecurefunc(pool, "resetterFunc", CollectAlertFrame)
  end
end




-- A function to set the status bar alpha depending on whether we are
-- fading/faded out or fading/faded in.
local function SetStatusBarAlpha(frame)
  -- Only do something to frames for which the hovering was activated.
  if frame.ludius_mouseOver == nil then return end

  -- Fading or faded out.
  if frame.ludius_fadeout then

    -- If the mouse is hovering over the status bar, show it with full opacity.
    if frame.ludius_mouseOver then
      -- In case we are currently fading out,
      -- interrupt the fade out in progress.
      UIFrameFadeRemoveFrame(frame)
      frame:SetAlpha(1)

    -- Otherwise show the faded out opacity.
    else
      frame:SetAlpha(frame.ludius_alphaAfterFadeOut)
    end

  end
end

local function SetStatusBarFading(barManager)
  for _, frame in pairs(barManager.bars) do
    frame:HookScript("OnEnter", function()
      barManager.ludius_mouseOver = true
      SetStatusBarAlpha(barManager)
    end)
    frame:HookScript("OnLeave", function()
      barManager.ludius_mouseOver = false
      SetStatusBarAlpha(barManager)
    end)
  end
end


if Bartender4 then
  hooksecurefunc(Bartender4:GetModule("StatusTrackingBar"), "OnEnable", function()
    SetStatusBarFading(BT4StatusBarTrackingManager)
  end)
else
  hooksecurefunc(StatusTrackingBarManager, "AddBarFromTemplate", SetStatusBarFading)
end


if IsAddOnLoaded("GW2_UI") then
  -- GW2_UI seems to offer no way of hooking any of its functions.
  -- So we have to do it like this.
  local enterWorldFrame = CreateFrame("Frame")
  enterWorldFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  enterWorldFrame:SetScript("OnEvent", function()
    if GwExperienceFrame then
      GwExperienceFrame:HookScript("OnEnter", function()
        GwExperienceFrame.ludius_mouseOver = true
        SetStatusBarAlpha(GwExperienceFrame)
      end)
      GwExperienceFrame:HookScript("OnLeave", function()
        GwExperienceFrame.ludius_mouseOver = false
        SetStatusBarAlpha(GwExperienceFrame)
      end)
    end
  end)
end



-- To hide the tooltip of bag items.
-- (While we are actually hiding other frames to suppress their tooltips,
-- this is not practical for the bag, as openning my cause a slight lag.)
local function GameTooltipHider(self)

  if Addon.uiHiddenTime == 0 or not self then return end

  local ownerName = nil
  if self:GetOwner() then
    ownerName = self:GetOwner():GetName()
  end
  if ownerName == nil then return end

  if string_find(ownerName, "^ContainerFrame") or ownerName == "ChatFrameChannelButton" then
    self:Hide()
  -- else
    -- print(ownerName)
  end
end

GameTooltip:HookScript("OnTooltipSetDefaultAnchor", GameTooltipHider)
GameTooltip:HookScript("OnTooltipSetItem", GameTooltipHider)
GameTooltip:HookScript("OnShow", GameTooltipHider)





local function ConditionalHide(frame)
  if not frame or (frame:IsProtected() and InCombatLockdown()) then return end

  if frame:IsShown() then
    frame.ludius_wasShown = true
    frame:Hide()
  else
    frame.ludius_wasShown = false
  end
end

local function ConditionalShow(frame)
  if not frame then return end

  if frame.ludius_wasShown and not frame:IsShown() then
    if frame:IsProtected() and InCombatLockdown() then
      -- Try again!
      LibStub("AceTimer-3.0"):ScheduleTimer(function() ConditionalShow(frame) end , 0.1)
    else
      frame.ludius_wasShown = false
      frame:Show()
    end
  end
end



local function ConditionalFadeOutTo(frame, targetAlpha, fadeOutTime)
  if not frame or not frame:IsShown() then return end

  -- ludius_alphaBeforeFadeOut is only set, if this is a fresh
  -- fadeout. It is set to nil after a fadein is completed.
  -- Otherwise, we might falsely asume a wrong ludius_alphaBeforeFadeOut
  -- value while a fadein is still in progress.
  if frame.ludius_alphaBeforeFadeOut == nil then
    frame.ludius_alphaBeforeFadeOut = frame:GetAlpha()
  end
  frame.ludius_alphaAfterFadeOut = targetAlpha

  UIFrameFadeRemoveFrame(frame)
  UIFrameFadeOut(frame, fadeOutTime, frame:GetAlpha(), targetAlpha)

  -- This is to let SetStatusBarAlpha() know whether we are
  -- currently fading/faded in or fading/faded out.
  frame.ludius_fadeout = true
  SetStatusBarAlpha(frame)
end

local function ConditionalFadeIn(frame, fadeInTime)
  if not frame or frame.ludius_alphaBeforeFadeOut == nil then return end

  -- The same as UIFrameFadeIn(), but with a callback function.
  local fadeInfo = {};
  fadeInfo.mode = "IN";
  fadeInfo.timeToFade = fadeInTime
  fadeInfo.startAlpha = frame:GetAlpha()
  fadeInfo.endAlpha = frame.ludius_alphaBeforeFadeOut
  fadeInfo.finishedArg1 = frame
  fadeInfo.finishedFunc = function(finishedArg1)
      -- print(finishedArg1:GetName(), "finished")
      finishedArg1.ludius_alphaBeforeFadeOut = nil
      finishedArg1.ludius_alphaAfterFadeOut = nil
    end
    
  UIFrameFadeRemoveFrame(frame)
  UIFrameFade(frame, fadeInfo)

  frame.ludius_fadeout = false
  SetStatusBarAlpha(frame)
end



Addon.HideUI = function(config, fadeOutTime)

  -- print("HideUI")

  -- Make sure that this is not run when the UI is already hidden.
  if Addon.uiHiddenTime ~= 0 then return end

  Addon.uiHiddenTime = GetTime()


  if config.hideFrameRate then
    ConditionalFadeOutTo(FramerateLabel, 0, fadeOutTime)
    ConditionalFadeOutTo(FramerateText, 0, fadeOutTime)
  end

  if not config.hideAlertFrame then
    CovenantRenownToast:SetIgnoreParentAlpha(true)
    SetAlertFramesIgnoreParentAlpha(true)
  end

  if not config.hideChatFrame then
    ChatFrame1:SetIgnoreParentAlpha(true)
    ChatFrame1Tab:SetIgnoreParentAlpha(true)
    ChatFrame1EditBox:SetIgnoreParentAlpha(true)

    if GwChatContainer1 then
      GwChatContainer1:SetIgnoreParentAlpha(true)
    end
  end


  if not config.hideTrackingBar then

    if BT4StatusBarTrackingManager then
      BT4StatusBarTrackingManager:SetIgnoreParentAlpha(true)
      ConditionalFadeOutTo(BT4StatusBarTrackingManager, config.trackingBarAlpha, fadeOutTime)
    else
      StatusTrackingBarManager:SetIgnoreParentAlpha(true)
      ConditionalFadeOutTo(StatusTrackingBarManager, config.trackingBarAlpha, fadeOutTime)
    end

    if GwExperienceFrame then
      GwExperienceFrame:SetIgnoreParentAlpha(true)
      ConditionalFadeOutTo(GwExperienceFrame, config.trackingBarAlpha, fadeOutTime)
    end

  end


  -- Got to manually fade out the PartyMemberFrame..NotPresentIcon
  -- and afterwards hide PartyMemberFrame..
  for i = 1, 4, 1 do
    ConditionalFadeOutTo(_G["PartyMemberFrame" .. i .. "NotPresentIcon"], 0, fadeOutTime)
  end


  -- Got to manually fade out these CompactRaidFrame.. child frames
  -- and afterwards hide CompactRaidFrame..
  for i = 1, 40, 1 do
    if _G["CompactRaidFrame" .. i] then
      ConditionalFadeOutTo(_G["CompactRaidFrame" .. i .. "Background"], 0, fadeOutTime)
      ConditionalFadeOutTo(_G["CompactRaidFrame" .. i .. "HorizTopBorder"], 0, fadeOutTime)
      ConditionalFadeOutTo(_G["CompactRaidFrame" .. i .. "HorizBottomBorder"], 0, fadeOutTime)
      ConditionalFadeOutTo(_G["CompactRaidFrame" .. i .. "VertLeftBorder"], 0, fadeOutTime)
      ConditionalFadeOutTo(_G["CompactRaidFrame" .. i .. "VertRightBorder"], 0, fadeOutTime)
    end
  end



  -- Cancel timers that may still be in progress.
  if Addon.frameHideTimer then LibStub("AceTimer-3.0"):CancelTimer(Addon.frameHideTimer) end
  if Addon.frameShowTimer then LibStub("AceTimer-3.0"):CancelTimer(Addon.frameShowTimer) end


  -- Hide frames of which we want no mouseover tooltips while faded.
  Addon.frameHideTimer = LibStub("AceTimer-3.0"):ScheduleTimer(function()

    -- Minimap, MinimapCluster and ObjectiveTrackerFrame may be excluded from fading out by Immersion.
    -- But we do not need to take care of them here, as they are not causing any unwanted tooltips.

    -- These frames are always faded out by Immersion and cause unwanted tooltips.
    -- So we hide them!
    ConditionalHide(QuickJoinToastButton)
    ConditionalHide(PlayerFrame)
    ConditionalHide(PetFrame)
    ConditionalHide(TargetFrame)
    ConditionalHide(BuffFrame)
    ConditionalHide(DebuffFrame)


    for i = 1, 4, 1 do
      ConditionalHide(_G["PartyMemberFrame" .. i])
    end

    for i = 1, 40, 1 do
      if _G["CompactRaidFrame" .. i] then
        ConditionalHide(_G["CompactRaidFrame" .. i])
      end
    end


    -- Hide the action bars.
    if Bartender4 then

      ConditionalHide(BT4Bar1)
      ConditionalHide(BT4Bar2)
      ConditionalHide(BT4Bar3)
      ConditionalHide(BT4Bar4)
      ConditionalHide(BT4Bar5)
      ConditionalHide(BT4Bar6)
      ConditionalHide(BT4Bar7)
      ConditionalHide(BT4Bar8)
      ConditionalHide(BT4Bar9)
      ConditionalHide(BT4Bar10)
      ConditionalHide(BT4BarBagBar)
      ConditionalHide(BT4BarMicroMenu)

      ConditionalHide(BT4BarStanceBar)
      ConditionalHide(BT4BarPetBar)

      if config.hideTrackingBar then
        ConditionalHide(BT4StatusBarTrackingManager)
      end

    else

      ConditionalHide(ExtraActionBarFrame)
      ConditionalHide(MainMenuBarArtFrame)
      ConditionalHide(MainMenuBarVehicleLeaveButton)
      ConditionalHide(MicroButtonAndBagsBar)
      ConditionalHide(MultiCastActionBarFrame)
      ConditionalHide(PetActionBarFrame)
      ConditionalHide(PossessBarFrame)
      ConditionalHide(StanceBarFrame)

      ConditionalHide(MultiBarRight)
      ConditionalHide(MultiBarLeft)

      if config.hideTrackingBar then
        ConditionalHide(StatusTrackingBarManager)
      end

    end


    if IsAddOnLoaded("GW2_UI") then

      -- TODO: Could hide other GW2_UI frames too,
      -- which should not give tooltips while faded...

      if config.hideTrackingBar then
        ConditionalHide(GwExperienceFrame)
      end

    end

  end, fadeOutTime)

end




-- If enteringCombat we only show the hidden frames (which cannot be shown
-- during combat lockdown). But we skip the SetIgnoreParentAlpha(false).
-- This can be done when Immersion exits the NPC interaction.
Addon.ShowUI = function(fadeInTime, enteringCombat)

  -- print("ShowUI", enteringCombat)

  -- Only do something once per closing.
  if Addon.uiHiddenTime == 0 then return end

  if not enteringCombat then
    Addon.uiHiddenTime = 0

    -- Show FramerateLabel again.
    ConditionalFadeIn(FramerateLabel, fadeInTime)
    ConditionalFadeIn(FramerateText, fadeInTime)
  end



  for i = 1, 4, 1 do
    -- If we are not checking this, it may happen that the empty PartyMemberFrame
    -- is shown again after NPC interaction, even if the party has been disbanded.
    if UnitInParty("player") then
      ConditionalShow(_G["PartyMemberFrame" .. i])
    end
    ConditionalFadeIn(_G["PartyMemberFrame" .. i .. "NotPresentIcon"], fadeInTime)
  end


  for i = 1, 40, 1 do
    if _G["CompactRaidFrame" .. i] then
      if UnitInRaid("player") then
        ConditionalShow(_G["CompactRaidFrame" .. i])
      end
      ConditionalFadeIn(_G["CompactRaidFrame" .. i .. "Background"], fadeInTime)
      ConditionalFadeIn(_G["CompactRaidFrame" .. i .. "HorizTopBorder"], fadeInTime)
      ConditionalFadeIn(_G["CompactRaidFrame" .. i .. "HorizBottomBorder"], fadeInTime)
      ConditionalFadeIn(_G["CompactRaidFrame" .. i .. "VertLeftBorder"], fadeInTime)
      ConditionalFadeIn(_G["CompactRaidFrame" .. i .. "VertRightBorder"], fadeInTime)
    end
  end


  ConditionalShow(QuickJoinToastButton)
  ConditionalShow(PlayerFrame)
  ConditionalShow(PetFrame)
  ConditionalShow(TargetFrame)
  ConditionalShow(BuffFrame)
  ConditionalShow(DebuffFrame)


  if Bartender4 then

    ConditionalShow(BT4Bar1)
    ConditionalShow(BT4Bar2)
    ConditionalShow(BT4Bar3)
    ConditionalShow(BT4Bar4)
    ConditionalShow(BT4Bar5)
    ConditionalShow(BT4Bar6)
    ConditionalShow(BT4Bar7)
    ConditionalShow(BT4Bar8)
    ConditionalShow(BT4Bar9)
    ConditionalShow(BT4Bar10)
    ConditionalShow(BT4BarBagBar)
    ConditionalShow(BT4BarMicroMenu)

    ConditionalShow(BT4BarStanceBar)
    ConditionalShow(BT4BarPetBar)

    -- Fade in the (possibly only partially) faded status bar.
    ConditionalShow(BT4StatusBarTrackingManager)
    if not enteringCombat then
      ConditionalFadeIn(BT4StatusBarTrackingManager, fadeInTime)
    end

  else

    ConditionalShow(ExtraActionBarFrame)
    ConditionalShow(MainMenuBarArtFrame)
    ConditionalShow(MainMenuBarVehicleLeaveButton)
    ConditionalShow(MicroButtonAndBagsBar)
    ConditionalShow(MultiCastActionBarFrame)
    ConditionalShow(PetActionBarFrame)
    ConditionalShow(PossessBarFrame)
    ConditionalShow(StanceBarFrame)

    ConditionalShow(MultiBarRight)
    ConditionalShow(MultiBarLeft)

    -- Fade in the (possibly only partially) faded status bar.
    ConditionalShow(StatusTrackingBarManager)
    if not enteringCombat then
      ConditionalFadeIn(StatusTrackingBarManager, fadeInTime)
    end

  end


  if IsAddOnLoaded("GW2_UI") then

    -- TODO: Whould have to show other GW2_UI frames again,
    -- which were hidden in HideUI()...

    -- Fade in the (possibly only partially) faded status bar.
    ConditionalShow(GwExperienceFrame)
    if not enteringCombat then
      ConditionalFadeIn(GwExperienceFrame, fadeInTime)
    end

  end

  -- Cancel timers that may still be in progress.
  if Addon.frameHideTimer then LibStub("AceTimer-3.0"):CancelTimer(Addon.frameHideTimer) end
  if Addon.frameShowTimer then LibStub("AceTimer-3.0"):CancelTimer(Addon.frameShowTimer) end

  if not enteringCombat then
    -- Reset the IgnoreParentAlpha after the UI fade-in is finished.
    Addon.frameShowTimer = LibStub("AceTimer-3.0"):ScheduleTimer(function()

      SetAlertFramesIgnoreParentAlpha(false)
      CovenantRenownToast:SetIgnoreParentAlpha(false)

      ChatFrame1:SetIgnoreParentAlpha(false)
      ChatFrame1Tab:SetIgnoreParentAlpha(false)
      ChatFrame1EditBox:SetIgnoreParentAlpha(false)

      if GwChatContainer1 then
        GwChatContainer1:SetIgnoreParentAlpha(false)
      end


      if BT4StatusBarTrackingManager then
        BT4StatusBarTrackingManager:SetIgnoreParentAlpha(false)
      else
        StatusTrackingBarManager:SetIgnoreParentAlpha(false)
      end

      if GwExperienceFrame then
        GwExperienceFrame:SetIgnoreParentAlpha(false)
      end

    end, fadeInTime)
  end

end





