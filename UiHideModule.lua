local _, Addon = ...


-- For debugging:
-- local debugFrame = MinimapCluster


-- Have to store uiHiddenTime and currentConfig globally,
-- because several addons may use this module simultaneously.
if not ludius_UiHideModule then
  ludius_UiHideModule = {}

  -- Flag indicating if the UI is currently faded out.
  ludius_UiHideModule.uiHiddenTime = 0

  -- The current configuration passed by the addon calling HideUI.
  ludius_UiHideModule.currentConfig = nil

  -- Collect alert frames that are created.
  ludius_UiHideModule.collectedAlertFrames = {}
end

Addon.uiHiddenTime = ludius_UiHideModule.uiHiddenTime
local currentConfig = ludius_UiHideModule.currentConfig
local collectedAlertFrames = ludius_UiHideModule.collectedAlertFrames


-- Call Addon.HideUI(fadeOutTime, config) to hide UI keeping configured frames.
-- Call Addon.ShowUI(fadeInTime, true) when entering combat while UI is hidden.
--   This will show the actually hidden frames, that cannot be shown during combat,
--   but the fade out state will remain. You only see tooltips of faded-out frames.
-- Call Addon.ShowUI(fadeInTime, false) to show UI.

-- Accepted options for config argument of HideUI():
--   config.hideFrameRate
--   config.keepAlertFrames
--   config.keepTooltip
--   config.keepMinimap
--   config.keepChatFrame
--   config.keepPartyRaidFrame
--   config.keepTrackingBar
--   config.keepEncounterBar
--   config.keepCustomFrames
--   config.customFramesToKeep
--   config.UIParentAlpha     (while faded out)


-- Lua API
local _G = _G

local tonumber = tonumber
local tinsert = tinsert
local string_find = string.find
local string_match = string.match

local GetTime            = _G.GetTime
local InCombatLockdown   = _G.InCombatLockdown
local UnitInParty        = _G.UnitInParty

-- TODO: Adopt new UI!
-- local CompactRaidFrameContainer = _G.CompactRaidFrameContainer





-- The user can define custom frames to keep visible.
-- To prevent these user settings from clashing with the other frames,
-- we store the names of frames handled by the addon.

-- Frames whose visibility is defined via explicit UI checkboxes/flags.
local flagFrames = {

  -- config.hideFrameRate
  ["FramerateLabel"] = true,
  ["FramerateText"] = true,

  -- config.keepAlertFrames
  ["CovenantRenownToast"] = true,


  -- config.keepMinimap
  ["MinimapCluster"] = true,
  -- Minimap is needed, because Immersion sets it to IgnoreParentAlpha.
  ["Minimap"] = true,

  -- config.keepTooltip
  ["GameTooltip"] = true,
  ["AceGUITooltip"] = true,
  ["AceConfigDialogTooltip"] = true,


  -- config.keepTrackingBar
  ["BT4BarStatus"] = true,
  ["StatusTrackingBarManager"] = true,
  ["GwExperienceFrame"] = true,

  -- config.keepEncounterBar
  ["EncounterBar"] = true,
}



-- config.keepChatFrame
for i = 1, 12, 1 do
  flagFrames["ChatFrame" .. i] = true
  flagFrames["ChatFrame" .. i .. "Tab"] = true
  flagFrames["ChatFrame" .. i .. "EditBox"] = true
  flagFrames["GwChatContainer" .. i] = true
end


-- config.keepPartyRaidFrame
for i = 1, 4, 1 do
  flagFrames["PartyMemberFrame" .. i] = true
  flagFrames["PartyMemberFrame" .. i .. "NotPresentIcon"] = true
end


-- TODO: Adopt new UI!
-- flagFrames["CompactRaidFrameContainer"] = true
-- for i = 1, 40, 1 do
  -- flagFrames["CompactRaidFrame" .. i .. "Background"] = true
  -- flagFrames["CompactRaidFrame" .. i .. "HorizTopBorder"] = true
  -- flagFrames["CompactRaidFrame" .. i .. "HorizBottomBorder"] = true
  -- flagFrames["CompactRaidFrame" .. i .. "VertLeftBorder"] = true
  -- flagFrames["CompactRaidFrame" .. i .. "VertRightBorder"] = true
  -- flagFrames["CompactRaidFrame" .. i .. "SelectionHighlight"] = true
-- end



-- Frames which are hidden by default.
local defaultHiddenFrames = {
  ["QuickJoinToastButton"] = true,
  ["PlayerFrame"] = true,
  ["PetFrame"] = true,
  ["TargetFrame"] = true,
  ["BuffFrame"] = true,
  ["DebuffFrame"] = true,
  ["ObjectiveTrackerFrame"] = true,
  -- TODO: Would have to fade every single 3D model separately.
  ["WardrobeFrame"] = true,
  ["CollectionsJournal"] = true,
}




if Bartender4 then
  defaultHiddenFrames["BT4Bar1"] = true
  defaultHiddenFrames["BT4Bar2"] = true
  defaultHiddenFrames["BT4Bar3"] = true
  defaultHiddenFrames["BT4Bar4"] = true
  defaultHiddenFrames["BT4Bar5"] = true
  defaultHiddenFrames["BT4Bar6"] = true
  defaultHiddenFrames["BT4Bar7"] = true
  defaultHiddenFrames["BT4Bar8"] = true
  defaultHiddenFrames["BT4Bar9"] = true
  defaultHiddenFrames["BT4Bar10"] = true
  defaultHiddenFrames["BT4Bar11"] = true
  defaultHiddenFrames["BT4Bar12"] = true
  defaultHiddenFrames["BT4Bar13"] = true
  defaultHiddenFrames["BT4Bar14"] = true
  defaultHiddenFrames["BT4Bar15"] = true
  defaultHiddenFrames["BT4BarBagBar"] = true
  defaultHiddenFrames["BT4BarMicroMenu"] = true
  defaultHiddenFrames["BT4BarStanceBar"] = true
  defaultHiddenFrames["BT4BarPetBar"] = true
else
  defaultHiddenFrames["MainMenuBar"] = true
  defaultHiddenFrames["MultiBarLeft"] = true
  defaultHiddenFrames["MultiBarRight"] = true
  defaultHiddenFrames["MultiBarBottomLeft"] = true
  defaultHiddenFrames["MultiBarBottomRight"] = true
  defaultHiddenFrames["MultiBar5"] = true
  defaultHiddenFrames["MultiBar6"] = true
  defaultHiddenFrames["MultiBar7"] = true
  defaultHiddenFrames["MultiBar8"] = true
  defaultHiddenFrames["ExtraActionBarFrame"] = true
  defaultHiddenFrames["MainMenuBarVehicleLeaveButton"] = true
  defaultHiddenFrames["MicroButtonAndBagsBar"] = true
  defaultHiddenFrames["MultiCastActionBarFrame"] = true
  defaultHiddenFrames["StanceBar"] = true
  defaultHiddenFrames["PetActionBar"] = true
  defaultHiddenFrames["PossessBar"] = true
end




-- We need a function to change a frame's alpha without automatically showing the frame
-- (as done by the original UIFrameFade() defined in UIParent.lua).

if not ludius_FADEFRAMES then ludius_FADEFRAMES = {} end

local frameFadeManager = CreateFrame("FRAME")

local function UIFrameFadeRemoveFrame(frame)
  tDeleteItem(ludius_FADEFRAMES, frame)
end



-- Changed this to work with GetTime() instead of "elapsed" argument.
-- Because the first elapsed after login is always very long and we want
-- to be able to start a smooth fade out beginning at the first update.
local lastUpdate
local function UIFrameFade_OnUpdate(self)

  local elapsed = 0
  if lastUpdate then
    elapsed = GetTime() - lastUpdate
  end
  lastUpdate = GetTime()

  local index = 1
  local frame, fadeInfo
  while ludius_FADEFRAMES[index] do
    frame = ludius_FADEFRAMES[index]
    fadeInfo = frame.fadeInfo
    -- Reset the timer if there isn't one, this is just an internal counter
    if not fadeInfo.fadeTimer then
      fadeInfo.fadeTimer = 0
    end
    fadeInfo.fadeTimer = fadeInfo.fadeTimer + elapsed

    -- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade
    if tonumber(fadeInfo.fadeTimer) < tonumber(fadeInfo.timeToFade) then
      if fadeInfo.mode == "IN" then
        frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha)
      elseif fadeInfo.mode == "OUT" then
        frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha) + fadeInfo.endAlpha)
      end

      -- if frame == debugFrame then print("UIFrameFade_OnUpdate", elapsed, frame:GetName(), fadeInfo.fadeTimer, fadeInfo.timeToFade, "Setting alpha", frame:GetAlpha()) end

    else

      -- if frame == debugFrame then print("Last call of UIFrameFade_OnUpdate.", frame:GetName(), "Setting endAlpha", fadeInfo.endAlpha) end

      frame:SetAlpha(fadeInfo.endAlpha)
      -- Complete the fade and call the finished function if there is one
      UIFrameFadeRemoveFrame(frame)
      if fadeInfo.finishedFunc then
        fadeInfo.finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4)
        fadeInfo.finishedFunc = nil
      end
    end

    index = index + 1
  end

  if #ludius_FADEFRAMES == 0 then
    self:SetScript("OnUpdate", nil)
    lastUpdate = nil
  end
end

local function UIFrameFade(frame, fadeInfo)
  if not frame then return end

  -- We make sure that we always call this with mode, startAlpha and endAlpha.
  assert(fadeInfo.mode)
  assert(fadeInfo.startAlpha)
  assert(fadeInfo.endAlpha)

  -- if frame == debugFrame then print("UIFrameFade", frame:GetName(), fadeInfo.mode, fadeInfo.startAlpha, fadeInfo.endAlpha) end

  frame.fadeInfo = fadeInfo
  frame:SetAlpha(fadeInfo.startAlpha)

  local index = 1
  while ludius_FADEFRAMES[index] do
    -- If frame is already set to fade then return
    if ludius_FADEFRAMES[index] == frame then
      return
    end
    index = index + 1
  end
  tinsert(ludius_FADEFRAMES, frame)

  if #ludius_FADEFRAMES == 1 then
    frameFadeManager:SetScript("OnUpdate", UIFrameFade_OnUpdate)
  end

end



-- A function to set a frame's alpha depending on mouse over and
-- whether we are fading/faded out or not.
local function SetMouseOverAlpha(frame)
  -- Only do something to frames for which the hovering was activated.
  if frame.ludius_mouseOver == nil then return end

  -- Fading or faded out.
  if frame.ludius_fadeout then

    -- If the mouse is hovering over the status bar, show it with alpha 1.
    if frame.ludius_mouseOver then
      -- In case we are currently fading out,
      -- interrupt the fade out in progress.
      UIFrameFadeRemoveFrame(frame)
      frame.ludius_alreadyOnIt = nil
      frame:SetAlpha(1)

    -- Otherwise use the faded out alpha.
    else
      frame:SetAlpha(frame.ludius_alphaAfterFadeOut)
    end

  end
end

local function SetMouseOverFading(barManager)

  -- Have to do this for the single bars.
  -- Otherwise the text does not pop up any more when hovering over the bars.
  for _, frame in pairs(barManager.bars) do
    if not frame.ludius_hooked then
      frame:HookScript("OnEnter", function()
        barManager.ludius_mouseOver = true
        SetMouseOverAlpha(barManager)
      end)
      frame:HookScript("OnLeave", function()
        barManager.ludius_mouseOver = false
        SetMouseOverAlpha(barManager)
      end)
      frame.ludius_hooked = true
    end
  end
  
end

hooksecurefunc(StatusTrackingBarManager, "AddBarFromTemplate", SetMouseOverFading)



if IsAddOnLoaded("GW2_UI") then
  -- GW2_UI seems to offer no way of hooking any of its functions.
  -- So we have to do it like this.
  local enterWorldFrame = CreateFrame("Frame")
  enterWorldFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  enterWorldFrame:SetScript("OnEvent", function()
    if GwExperienceFrame then
      GwExperienceFrame:HookScript("OnEnter", function()
        GwExperienceFrame.ludius_mouseOver = true
        SetMouseOverAlpha(GwExperienceFrame)
      end)
      GwExperienceFrame:HookScript("OnLeave", function()
        GwExperienceFrame.ludius_mouseOver = false
        SetMouseOverAlpha(GwExperienceFrame)
      end)
    end
  end)
end



-- To hide the tooltip of bag items.
-- (While we are actually hiding other frames to suppress their tooltips,
-- this is not practical for the bag, as opening may cause an annoying FPS drop.)
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

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, GameTooltipHider)
GameTooltip:HookScript("OnTooltipSetDefaultAnchor", GameTooltipHider)
GameTooltip:HookScript("OnShow", GameTooltipHider)



local function ConditionalHide(frame)
  if not frame then return end

  -- if frame == debugFrame then print("ConditionalHide", frame:GetName(), frame:GetParent():GetName(), frame:IsIgnoringParentAlpha()) end

  -- Checking for combat lockdown is not this function's concern.
  -- Functions calling it must make sure, it is not  called in combat lockdown.

  -- TODO: What if the combat started while the fade out was already happening???
  if frame:IsProtected() and InCombatLockdown() then
    print("ERROR: Should not try to hide", frame:GetName(), "in combat lockdown!")
  end

  if frame.ludius_shownBeforeFadeOut == nil then
    -- if frame == debugFrame then print("Remember it was shown", frame:IsShown()) end
    frame.ludius_shownBeforeFadeOut = frame:IsShown()
  end

  if frame:IsShown() then
    frame:Hide()
  end
end


local function ConditionalShow(frame)
  if not frame or frame.ludius_shownBeforeFadeOut == nil then return end

  -- if frame == debugFrame then print("ConditionalShow", frame:GetName(), frame.ludius_shownBeforeFadeOut) end

  if frame:IsProtected() and InCombatLockdown() then
    print("ERROR: Should not try to show", frame:GetName(), "in combat lockdown!")
  end


  -- If the frame is already shown, we leave it be.
  if not frame:IsShown() then

    -- For party and raid member frames, we cannot rely on ludius_shownBeforeFadeOut,
    -- so some more complex checks are necessary.

    -- Party member frames.
    if string_find(frame:GetName(), "^PartyMemberFrame") then

      -- The NotPresentIcon is taken care of by PartyMemberFrame_UpdateNotPresentIcon below.
      -- So we only handle the actual PartyMemberFrame and do nothing otherwise.
      if string_find(frame:GetName(), "^PartyMemberFrame(%d+)$") then

        -- Only show the party member frames, if we are in a party that is not a raid.
        -- (Use CompactRaidFrameContainer:IsShown() instead of UnitInRaid("player") because people might use
        -- an addon like SoloRaidFrame to show the raid frame even while not in raid.)
        if UnitInParty("player") and not CompactRaidFrameContainer:IsShown() then
          -- Only for as many frames as there are party members.
          local numGroupMembers = GetNumGroupMembers()
          local frameNumber = tonumber(string_match(frame:GetName(), "^PartyMemberFrame(%d+)"))
          if frameNumber < numGroupMembers then
            frame:Show()
            PartyMemberFrame_UpdateNotPresentIcon(frame)
            -- The above functions set the alpha, but we want to do the fade in ourselves.
            frame:SetAlpha(0)
            frame.notPresentIcon:SetAlpha(0)
          end
        end

      end


    -- TODO: Adopt new UI.
    -- Only show the CompactRaidFrameManager, if the player is still in a party.
    -- elseif frame == CompactRaidFrameManager then

      -- -- (Again also use CompactRaidFrameContainer:IsShown() because people might use
      -- -- an addon like SoloRaidFrame to show the raid frame even while not in raid.)
      -- if UnitInParty("player") or CompactRaidFrameContainer:IsShown() then
        -- frame:Show()
      -- end


    elseif frame.ludius_shownBeforeFadeOut then
      -- if frame == debugFrame then print("Have to show it again!") end
      frame:Show()
    end

  end

  frame.ludius_shownBeforeFadeOut = nil
end




-- To prevent other addons (Immersion, I'm looking in your direction) from
-- setting Minimap's and MinimapCluster's ignoreParentAlpha to false, when DynamicCam does not.
local function ParentAlphaGuard(self, ignoreParentAlpha)
  -- print(self:GetName(), "SetIgnoreParentAlpha", ignoreParentAlpha, self.ludius_intendedIgnoreParentAlpha)
  if self.ludius_intendedIgnoreParentAlpha ~= nil and ignoreParentAlpha ~= self.ludius_intendedIgnoreParentAlpha then
      -- print("no")
      self:SetIgnoreParentAlpha(self.ludius_intendedIgnoreParentAlpha)
  -- else
      -- print("ok")
  end
end

hooksecurefunc(MinimapCluster, "SetIgnoreParentAlpha", ParentAlphaGuard)
hooksecurefunc(Minimap, "SetIgnoreParentAlpha", ParentAlphaGuard)




-- To restore frames to their pre-hide ignore-parent-alpha state,
-- we remember it in the ludius_ignoreParentAlphaBeforeFadeOut variable.
local function ConditionalSetIgnoreParentAlpha(frame, ignoreParentAlpha)
  -- if frame == debugFrame then print("ConditionalSetIgnoreParentAlpha", ignoreParentAlpha) end

  if not frame or ignoreParentAlpha == nil then return end

  if frame.ludius_ignoreParentAlphaBeforeFadeOut == nil then
    frame.ludius_ignoreParentAlphaBeforeFadeOut = frame:IsIgnoringParentAlpha()
  end

  if frame:IsIgnoringParentAlpha() ~= ignoreParentAlpha then
    frame.ludius_intendedIgnoreParentAlpha = ignoreParentAlpha
    frame:SetIgnoreParentAlpha(ignoreParentAlpha)
  end
end

local function ConditionalResetIgnoreParentAlpha(frame)
  -- if frame == debugFrame then print("ConditionalSetIgnoreParentAlpha", ignoreParentAlpha) end

  if not frame or frame.ludius_ignoreParentAlphaBeforeFadeOut == nil then return end

  if frame:IsIgnoringParentAlpha() ~= frame.ludius_ignoreParentAlphaBeforeFadeOut then
    frame.ludius_intendedIgnoreParentAlpha = frame.ludius_ignoreParentAlphaBeforeFadeOut
    frame:SetIgnoreParentAlpha(frame.ludius_ignoreParentAlphaBeforeFadeOut)
  end
  frame.ludius_ignoreParentAlphaBeforeFadeOut = nil
end




-- The alert frames have to be dealt with as they are created.
-- https://www.wowinterface.com/forums/showthread.php?p=337803
-- For testing:
-- /run UIParent:SetAlpha(0.5)
-- /run NewMountAlertSystem:ShowAlert("123") NewMountAlertSystem:ShowAlert("123")
-- /run CovenantRenownToast:ShowRenownLevelUpToast(C_Covenants.GetActiveCovenantID(), 40)


-- A flag for alert frames that are created/collected while the UI is hidden.
local currentAlertFramesIgnoreParentAlpha = false

local function AlertFramesSetIgnoreParentAlpha(ignoreParentAlpha)
  currentAlertFramesIgnoreParentAlpha = ignoreParentAlpha
  for _, v in pairs(collectedAlertFrames) do
    ConditionalSetIgnoreParentAlpha(v, ignoreParentAlpha)
  end
end

local function AlertFramesResetIgnoreParentAlpha()
  currentAlertFramesIgnoreParentAlpha = false
  for _, v in pairs(collectedAlertFrames) do
    ConditionalResetIgnoreParentAlpha(v)
  end
end


local function CollectAlertFrame(_, frame)
  -- print("CollectAlertFrame", frame, currentAlertFramesIgnoreParentAlpha, frame.ludius_collected)

  if frame and not frame.ludius_collected then
    tinsert(collectedAlertFrames, frame)
    frame.ludius_collected = true
  end

  if currentAlertFramesIgnoreParentAlpha and not frame:IsIgnoringParentAlpha() then
    ConditionalSetIgnoreParentAlpha(frame, currentAlertFramesIgnoreParentAlpha)
  end
end

for _, subSystem in pairs(AlertFrame.alertFrameSubSystems) do
  local pool = type(subSystem) == 'table' and subSystem.alertFramePool
  if type(pool) == 'table' and type(pool.resetterFunc) == 'function' then
    hooksecurefunc(pool, "resetterFunc", CollectAlertFrame)
  end
end




-- targetIgnoreParentAlpha == true:  frame ignores parent alpha, and itself fades to targetAlpha (maybe different from UIParent's alpha).
-- targetIgnoreParentAlpha == false: frame adheres to parent alpha, but gets hidden, if targetAlpha (UIParent's alpha) is 0.
--
-- targetIgnoreParentAlpha == nil: Ignoring this frame!
-- This is needed for example, if the keeping or fading of a frame should be governed by another addon.
-- Like MinimapCluster is governed by Immersion and should therefore not be modified by IEF.
-- FadeInFrame() will automatically ignore non-faded frames as it will not find our ludius_ flags.
local function FadeOutFrame(frame, duration, targetIgnoreParentAlpha, targetAlpha)

  if not frame or targetIgnoreParentAlpha == nil then return end

  -- If another addon is already handling this, we don't touch it.
  if frame.ludius_alreadyOnIt then
    return
  else
    frame.ludius_alreadyOnIt = true
  end

  assert(targetAlpha)

  -- Prevent callback functions of currently active timers.
  UIFrameFadeRemoveFrame(frame)

  -- if frame == debugFrame then print("FadeOutFrame", frame:GetName(), duration, targetIgnoreParentAlpha, frame:IsIgnoringParentAlpha(), targetAlpha, frame:GetAlpha()) end

  -- ludius_alphaBeforeFadeOut is only set, if this is a fresh FadeOutFrame().
  -- It is set to nil after a FadeOutFrame() is completed.
  -- Otherwise, we might falsely asume a wrong ludius_alphaBeforeFadeOut
  -- value while a fade-in is still in progress.
  if frame.ludius_alphaBeforeFadeOut == nil then
    frame.ludius_alphaBeforeFadeOut = frame:GetAlpha()
  end


  -- To use UIFrameFade() which is the same as UIFrameFadeOut, but with a callback function.
  local fadeInfo = {}
  fadeInfo.mode = "OUT"
  fadeInfo.timeToFade = duration
  fadeInfo.finishedArg1 = frame
  fadeInfo.finishedArg2 = targetAlpha
  fadeInfo.finishedFunc = function(finishedArg1, finishedArg2)
    -- if finishedArg1 == debugFrame then print("Fade out finished", finishedArg1:GetName(), finishedArg2) end
    if finishedArg2 == 0 and (not finishedArg1:IsProtected() or not InCombatLockdown()) then
      -- if finishedArg1 == debugFrame then print("...and hiding!", finishedArg2) end
      ConditionalHide(finishedArg1)
    end
    
    finishedArg1.ludius_alreadyOnIt = nil
  end




  -- Frame should henceforth ignore parent alpha.
  if targetIgnoreParentAlpha then

    -- This is to let SetMouseOverAlpha() know whether we are
    -- currently fading/faded in or fading/faded out.
    -- Notice that we cannot use ludius_alphaBeforeFadeOut or ludius_alphaAfterFadeOut as this flag,
    -- because ludius_fadeout is unset at the beginning of a fade out
    -- and ludius_alphaBeforeFadeOut is unset at the end of a fade out.
    -- For an OnEnable/OnLeave during fade out, we do not want the alpha to change.
    frame.ludius_fadeout = true
    -- This is to let SetMouseOverAlpha() know which
    -- alpha to go back to OnLeave while the frame is faded or fading out.
    frame.ludius_alphaAfterFadeOut = targetAlpha
    SetMouseOverAlpha(frame)


    -- Frame was adhering to parent alpha before.
    -- Start the fade with parent's current alpha.
    if not frame:IsIgnoringParentAlpha() then
      fadeInfo.startAlpha = frame:GetParent():GetAlpha()

    -- Frame was already ignoring parent alpha before.
    else
      fadeInfo.startAlpha = frame:GetAlpha()

    end
    fadeInfo.endAlpha = targetAlpha

    ConditionalSetIgnoreParentAlpha(frame, true)


  -- Frame should henceforth adhere to parent alpha.
  else

    -- Frame was ignoring parent alpha before.
    -- Start the fade with the frame's alpha, fade to UIParent's target alpha
    -- and only then unset ignore parent alpha.
    -- Notice that the frame's alpha is not overriden by parent alpha but combined.
    -- So we have to set the child's alpha to 1 at the same time as we stop ignoring
    -- parent alpha.
    if frame:IsIgnoringParentAlpha() then

      fadeInfo.startAlpha = frame:GetAlpha()
      fadeInfo.endAlpha = targetAlpha

      fadeInfo.finishedFunc = function(finishedArg1, finishedArg2)
        -- if finishedArg1 == debugFrame then print("Fade out finished", finishedArg1:GetName(), finishedArg2) end
        finishedArg1:SetAlpha(1)
        ConditionalSetIgnoreParentAlpha(finishedArg1, false)
        if finishedArg2 == 0 and (not finishedArg1:IsProtected() or not InCombatLockdown()) then
          ConditionalHide(finishedArg1)
        end
        
        finishedArg1.ludius_alreadyOnIt = nil
      end

    -- Frame was already adhering to parent alpha.
    -- We are not changing it.
    else

      -- if frame == debugFrame then print("was already adhering to parent alpha") end

      fadeInfo.startAlpha = frame:GetAlpha()
      fadeInfo.endAlpha = frame:GetAlpha()
    end

  end


  -- Cannot rely on UIFrameFade to finish within the same frame.
  if duration == 0 then
    frame:SetAlpha(fadeInfo.endAlpha)
    fadeInfo.finishedFunc(frame, targetAlpha)

  -- This is for some frames to not being shown in between situations that are both hiding them.
  elseif (frame == MinimapCluster or frame == ObjectiveTrackerFrame) and targetAlpha == 0 and targetIgnoreParentAlpha == false and frame:GetParent():GetAlpha() == 0 and frame:IsShown() then
    fadeInfo.finishedFunc(frame, targetAlpha)

  else
    -- if frame == debugFrame then print("Starting fade with", fadeInfo.startAlpha, fadeInfo.endAlpha, fadeInfo.mode, fadeInfo.timeToFade) end
    UIFrameFade(frame, fadeInfo)
  end

end


local function FadeInFrame(frame, duration, enteringCombat)

  if not frame then return end

  -- If another addon is already handling this, we don't touch it.
  if frame.ludius_alreadyOnIt then
    return
  else
    frame.ludius_alreadyOnIt = true
  end


  -- Prevent callback functions of currently active timers.
  UIFrameFadeRemoveFrame(frame)

  -- Only do something if we have touched this frame before.
  if frame.ludius_shownBeforeFadeOut == nil and frame.ludius_alphaBeforeFadeOut == nil and frame.ludius_ignoreParentAlphaBeforeFadeOut == nil then return end

  -- if frame == debugFrame then print("FadeInFrame", frame:GetName(), frame:IsIgnoringParentAlpha()) end


  if enteringCombat then
    -- When entering combat we have to show protected frames, which cannot be shown any more during combat.
    if frame:IsProtected() then
      ConditionalShow(frame)
    end
    frame.ludius_alreadyOnIt = nil
    -- But we do not yet do the fade in.
    return
  else
    ConditionalShow(frame)
  end


  -- To use UIFrameFade() which is the same as UIFrameFadeOut, but with a callback function.
  local fadeInfo = {}
  fadeInfo.mode = "IN"
  fadeInfo.timeToFade = duration
  fadeInfo.finishedArg1 = frame
  fadeInfo.finishedFunc = function(finishedArg1)
      finishedArg1.ludius_alphaBeforeFadeOut = nil
      finishedArg1.ludius_alphaAfterFadeOut = nil
      finishedArg1.ludius_alreadyOnIt = nil
    end


  -- Frame should henceforth ignore parent alpha.
  if frame.ludius_ignoreParentAlphaBeforeFadeOut == true then

    -- Frame was adhering to parent alpha before.
    -- Start the fade with parent's current alpha.
    if not frame:IsIgnoringParentAlpha() then
      fadeInfo.startAlpha = frame:GetParent():GetAlpha()
    -- Frame was already ignoring parent alpha before.
    else
      fadeInfo.startAlpha = frame:GetAlpha()
    end
    fadeInfo.endAlpha = frame.ludius_alphaBeforeFadeOut

    ConditionalResetIgnoreParentAlpha(frame)

  -- Frame should henceforth adhere to parent alpha.
  elseif frame.ludius_ignoreParentAlphaBeforeFadeOut == false then

    -- Frame was ignoring parent alpha before.
    -- Start the fade with the frame's alpha, fade to UIParent's target alpha
    -- (which is always 1 when we fade the UI back in) and only then unset
    -- ignore parent alpha.
    if frame:IsIgnoringParentAlpha() then
      fadeInfo.startAlpha = frame:GetAlpha()
      fadeInfo.endAlpha = 1

      fadeInfo.finishedFunc = function(finishedArg1)
        ConditionalResetIgnoreParentAlpha(finishedArg1)
        finishedArg1.ludius_alphaBeforeFadeOut = nil
        finishedArg1.ludius_alphaAfterFadeOut = nil
        finishedArg1.ludius_alreadyOnIt = nil
      end

    -- Frame was already adhering to parent alpha.
    -- We are not changing it.
    else
      fadeInfo.startAlpha = frame:GetAlpha()
      fadeInfo.endAlpha = frame:GetAlpha()
    end

  -- No stored value in ludius_ignoreParentAlphaBeforeFadeOut.
  else
    fadeInfo.startAlpha = frame:GetAlpha()
    fadeInfo.endAlpha = frame.ludius_alphaBeforeFadeOut or frame:GetAlpha()
  end

  -- if frame == debugFrame then print("Starting fade with", fadeInfo.startAlpha, fadeInfo.endAlpha, fadeInfo.mode) end


  -- Cannot rely on UIFrameFade to finish within the same frame.
  if duration == 0 then
    frame:SetAlpha(fadeInfo.endAlpha)
    fadeInfo.finishedFunc(frame)
  else
    UIFrameFade(frame, fadeInfo)
  end

  -- We can do this always when fading in.
  frame.ludius_fadeout = nil
  SetMouseOverAlpha(frame)

end


-- So the GameTooltip stays hidden while UI is faded.
local hideGameTooltip = nil
GameTooltip:HookScript("OnShow", function(self)
  if hideGameTooltip and self:GetOwner() == UIParent then
    self:Hide()
  end
end)


Addon.HideUI = function(fadeOutTime, config)

  -- print("HideUI", fadeOutTime, config.UIParentAlpha)

  -- Remember that the UI is faded.
  Addon.uiHiddenTime = GetTime()
  currentConfig = config

  if config.hideFrameRate then
    -- The framerate label is a child of WorldFrame, while we just fade UIParent.
    -- That's why we have to set targetIgnoreParentAlpha to true.
    FadeOutFrame(FramerateLabel, fadeOutTime, true, config.UIParentAlpha)
    FadeOutFrame(FramerateText, fadeOutTime, true, config.UIParentAlpha)
  end

  AlertFramesSetIgnoreParentAlpha(config.keepAlertFrames)
  FadeOutFrame(CovenantRenownToast, fadeOutTime, config.keepAlertFrames, config.keepAlertFrames and 1 or config.UIParentAlpha)

  FadeOutFrame(MinimapCluster, fadeOutTime, config.keepMinimap, config.keepMinimap and 1 or config.UIParentAlpha)
  -- Minimap is needed, because Immersion sets it to IgnoreParentAlpha.
  FadeOutFrame(Minimap, fadeOutTime, config.keepMinimap, config.keepMinimap and 1 or config.UIParentAlpha)

  FadeOutFrame(GameTooltip, fadeOutTime, config.keepTooltip, config.keepTooltip and 1 or config.UIParentAlpha)
  C_Timer.After(fadeOutTime, function() hideGameTooltip = (config.keepTooltip == false) end)

  FadeOutFrame(AceGUITooltip, fadeOutTime, config.keepTooltip, config.keepTooltip and 1 or config.UIParentAlpha)
  FadeOutFrame(AceConfigDialogTooltip, fadeOutTime, config.keepTooltip, config.keepTooltip and 1 or config.UIParentAlpha)


  for i = 1, 12, 1 do
    if _G["ChatFrame" .. i] then
      FadeOutFrame(_G["ChatFrame" .. i], fadeOutTime, config.keepChatFrame, config.keepChatFrame and 1 or config.UIParentAlpha)
      FadeOutFrame(_G["ChatFrame" .. i .. "Tab"], fadeOutTime, config.keepChatFrame, config.keepChatFrame and 1 or config.UIParentAlpha)
      FadeOutFrame(_G["ChatFrame" .. i .. "EditBox"], fadeOutTime, config.keepChatFrame, config.keepChatFrame and 1 or config.UIParentAlpha)
    end

    if _G["GwChatContainer" .. i] then
      FadeOutFrame(_G["GwChatContainer" .. i], fadeOutTime, config.keepChatFrame, config.keepChatFrame and 1 or config.UIParentAlpha)
    end
  end


  FadeOutFrame(BT4BarStatus, fadeOutTime, config.keepTrackingBar, config.keepTrackingBar and config.trackingBarAlpha or config.UIParentAlpha)
  FadeOutFrame(StatusTrackingBarManager, fadeOutTime, config.keepTrackingBar, config.keepTrackingBar and config.trackingBarAlpha or config.UIParentAlpha)
  FadeOutFrame(GwExperienceFrame, fadeOutTime, config.keepTrackingBar, config.keepTrackingBar and config.trackingBarAlpha or config.UIParentAlpha)


  FadeOutFrame(EncounterBar, fadeOutTime, config.keepEncounterBar, config.keepEncounterBar and 1 or config.UIParentAlpha)


  -- TODO: Adopt new UI.
  -- CompactRaidFrameManager:Hide() is disabled, if the addon SoloRaidFrame is used.
  -- But we are not taking care of this!
  -- FadeOutFrame(CompactRaidFrameManager, fadeOutTime, config.keepPartyRaidFrame, config.keepPartyRaidFrame and 1 or config.UIParentAlpha)

  for i = 1, 4, 1 do
    if _G["PartyMemberFrame" .. i] then

      -- This frame is by default ignoring its parent's alpha. So we have to fade it manually.
      -- So we always set targetIgnoreParentAlpha to true. But depending on config.keepPartyRaidFrame
      -- we set the targetAlpha to 1 or to the UIParentAlpha.
      FadeOutFrame(_G["PartyMemberFrame" .. i .. "NotPresentIcon"], fadeOutTime, true, config.keepPartyRaidFrame and 1 or config.UIParentAlpha)

      -- PartyMemberFrames are direct children of UIParent (unlike CompactRaidFrames, which are children of
      -- CompactRaidFrameContainer, which is a child of CompactRaidFrameManager).
      -- Hence, we have to hide PartyMemberFrames manually.
      FadeOutFrame(_G["PartyMemberFrame" .. i], fadeOutTime, config.keepPartyRaidFrame, config.keepPartyRaidFrame and 1 or config.UIParentAlpha)
    end
  end


  -- TODO: Adopt new UI.
  -- Do not use GetNumGroupMembers() here, because as people join and leave the raid the frame numbers get mixed up.
  -- for i = 1, 40, 1 do
    -- if _G["CompactRaidFrame" .. i .. "Background"] then

      -- -- These frames are by default ignoring their parent's (i.e. "CompactRaidFrame"..i's) alpha.
      -- -- So we have to fade them out manually, when we want to hide the raid frame.
      -- -- So we always set targetIgnoreParentAlpha to true.
      -- if config.keepPartyRaidFrame == false then
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "Background"], fadeOutTime, true, config.UIParentAlpha)
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "HorizTopBorder"], fadeOutTime, true, config.UIParentAlpha)
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "HorizBottomBorder"], fadeOutTime, true, config.UIParentAlpha)
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "VertLeftBorder"], fadeOutTime, true, config.UIParentAlpha)
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "VertRightBorder"], fadeOutTime, true, config.UIParentAlpha)
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "SelectionHighlight"], fadeOutTime, true, config.UIParentAlpha)

        -- -- I first thought, there is no need to fade out "CompactRaidFrame"..i, as it is taken care of through its parent
        -- -- CompactRaidFrameManager. However, it turns out that the CompactRaidFrames produce tooltips again after the
        -- -- raid roster changes. So we have to do this here!
      -- end

    -- end
  -- end


  -- Non-configurable frames that we just want to hide in case UIParentAlpha is 0.
  for k in pairs(defaultHiddenFrames) do
    -- Using "not not" to convert nil to false.
    local keepFrame = not not config.keepCustomFrames and not not config.customFramesToKeep[k]
    FadeOutFrame(_G[k], fadeOutTime, keepFrame, keepFrame and 1 or config.UIParentAlpha)
  end


  -- Keep frames that are in config.customFramesToKeep but not in defaultHiddenFrames or flagFrames.
  if config.keepCustomFrames then
    for k in pairs(config.customFramesToKeep) do
      if not defaultHiddenFrames[k] and not flagFrames[k] then
        -- At the moment we are not supporting custom alphas for kept frames, so we set it to 1.
        FadeOutFrame(_G[k], fadeOutTime, true, 1)
      end
    end
  end

  if Addon.frameShowTimer then LibStub("AceTimer-3.0"):CancelTimer(Addon.frameShowTimer) end

end




-- If enteringCombat we only show the hidden frames (which cannot be shown
-- during combat lockdown). But we skip the SetIgnoreParentAlpha(false).
-- This can be done when the intended ShowUI() is called.
Addon.ShowUI = function(fadeInTime, enteringCombat)

  -- Only do something once per closing.
  if Addon.uiHiddenTime == 0 then return end

  -- print("ShowUI", fadeInTime, enteringCombat)

  if not enteringCombat then
    Addon.uiHiddenTime = 0
    currentConfig = nil
  end

  FadeInFrame(FramerateLabel, fadeInTime, enteringCombat)
  FadeInFrame(FramerateText, fadeInTime, enteringCombat)


  FadeInFrame(CompactRaidFrameManager, fadeInTime, enteringCombat)

  for i = 1, 4, 1 do
    if _G["PartyMemberFrame" .. i] then
      FadeInFrame(_G["PartyMemberFrame" .. i], fadeInTime, enteringCombat)
      FadeInFrame(_G["PartyMemberFrame" .. i .. "NotPresentIcon"], fadeInTime, enteringCombat)
    end
  end

  for i = 1, 40, 1 do
    if _G["CompactRaidFrame" .. i] then
      FadeInFrame(_G["CompactRaidFrame" .. i .. "Background"], fadeInTime, enteringCombat)
      FadeInFrame(_G["CompactRaidFrame" .. i .. "HorizTopBorder"], fadeInTime, enteringCombat)
      FadeInFrame(_G["CompactRaidFrame" .. i .. "HorizBottomBorder"], fadeInTime, enteringCombat)
      FadeInFrame(_G["CompactRaidFrame" .. i .. "VertLeftBorder"], fadeInTime, enteringCombat)
      FadeInFrame(_G["CompactRaidFrame" .. i .. "VertRightBorder"], fadeInTime, enteringCombat)
      FadeInFrame(_G["CompactRaidFrame" .. i .. "SelectionHighlight"], fadeInTime, enteringCombat)
    end
  end


  for k in pairs(defaultHiddenFrames) do
    FadeInFrame(_G[k], fadeInTime, enteringCombat)
  end


  -- Fade in the (possibly only partially) faded status bar.
  FadeInFrame(BT4BarStatus, fadeInTime, enteringCombat)
  FadeInFrame(StatusTrackingBarManager, fadeInTime, enteringCombat)
  FadeInFrame(GwExperienceFrame, fadeInTime, enteringCombat)

  FadeInFrame(CovenantRenownToast, fadeInTime, enteringCombat)

  FadeInFrame(MinimapCluster, fadeInTime, enteringCombat)
  FadeInFrame(Minimap, fadeInTime, enteringCombat)

  hideGameTooltip = false
  FadeInFrame(GameTooltip, fadeInTime, enteringCombat)

  FadeInFrame(AceGUITooltip, fadeInTime, enteringCombat)
  FadeInFrame(AceConfigDialogTooltip, fadeInTime, enteringCombat)


  for i = 1, 12, 1 do
    if _G["ChatFrame" .. i] then
      FadeInFrame(_G["ChatFrame" .. i], fadeInTime, enteringCombat)
      FadeInFrame(_G["ChatFrame" .. i .. "Tab"], fadeInTime, enteringCombat)
      FadeInFrame(_G["ChatFrame" .. i .. "EditBox"], fadeInTime, enteringCombat)
    end

    if _G["GwChatContainer" .. i] then
      FadeInFrame(_G["GwChatContainer" .. i], fadeInTime, enteringCombat)
    end
  end


  FadeInFrame(EncounterBar, fadeInTime, enteringCombat)


  -- Cancel timers that may still be in progress.
  if Addon.frameShowTimer then LibStub("AceTimer-3.0"):CancelTimer(Addon.frameShowTimer) end

  if not enteringCombat then
    -- Reset the IgnoreParentAlpha after the UI fade-in is finished.
    Addon.frameShowTimer = LibStub("AceTimer-3.0"):ScheduleTimer(function()
      AlertFramesResetIgnoreParentAlpha()
    end, fadeInTime)
  end

end



-- If party/raid members join/leave while the UI is faded, we prevent the frames from being shown again.
-- This code is similar to the respective part of HideUI(), see comments there.

-- We have to do the OnShow hook, because the GROUP_ROSTER_UPDATE event comes too late.
for i = 1, 4, 1 do
  if _G["PartyMemberFrame" .. i] then
    _G["PartyMemberFrame" .. i]:HookScript("OnShow", function()
      if Addon.uiHiddenTime == 0 then return end
      FadeOutFrame(_G["PartyMemberFrame" .. i .. "NotPresentIcon"], 0, true, currentConfig.keepPartyRaidFrame and 1 or currentConfig.UIParentAlpha)
      FadeOutFrame(_G["PartyMemberFrame" .. i], 0, currentConfig.keepPartyRaidFrame, currentConfig.keepPartyRaidFrame and 1 or currentConfig.UIParentAlpha)
    end)
  end
end



-- TODO: Adopt new UI!

-- Unlike party member frames, the raid member frames are not there from the start.
-- So we have to do the onShow hook, when new ones arrive.
-- hooksecurefunc("CompactRaidFrameContainer_AddUnitFrame", function(_, unit, frameType)

  -- for i = 1, 40, 1 do

    -- -- Only look at those, which we have not hooked yet.
    -- if _G["CompactRaidFrame" .. i .. "Background"] and not _G["CompactRaidFrame" .. i .. "Background"].ludius_hooked then

      -- -- If it is a new frame and the UI is currently hidden, we may have to also hide the new frame.
      -- if Addon.uiHiddenTime ~= 0 and currentConfig.keepPartyRaidFrame == false then
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "Background"], 0, true, currentConfig.UIParentAlpha)
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "HorizTopBorder"], 0, true, currentConfig.UIParentAlpha)
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "HorizBottomBorder"], 0, true, currentConfig.UIParentAlpha)
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "VertLeftBorder"], 0, true, currentConfig.UIParentAlpha)
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "VertRightBorder"], 0, true, currentConfig.UIParentAlpha)
        -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "SelectionHighlight"], 0, true, currentConfig.UIParentAlpha)
      -- end

      -- -- Do the hook.
      -- _G["CompactRaidFrame" .. i]:HookScript("OnShow", function()

        -- if Addon.uiHiddenTime ~= 0 and currentConfig.keepPartyRaidFrame == false then
          -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "Background"], 0, true, currentConfig.UIParentAlpha)
          -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "HorizTopBorder"], 0, true, currentConfig.UIParentAlpha)
          -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "HorizBottomBorder"], 0, true, currentConfig.UIParentAlpha)
          -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "VertLeftBorder"], 0, true, currentConfig.UIParentAlpha)
          -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "VertRightBorder"], 0, true, currentConfig.UIParentAlpha)
          -- FadeOutFrame(_G["CompactRaidFrame" .. i .. "SelectionHighlight"], 0, true, currentConfig.UIParentAlpha)
        -- end
      -- end)

      -- -- Remember that you hooked it.
      -- _G["CompactRaidFrame" .. i .. "Background"].ludius_hooked = true

    -- end
  -- end
-- end)



-- The CompactRaidFrameManager frame gets shown every time the raid roster changes.
-- While the UI is hidden, we have to hide it again.
-- CompactRaidFrameManager:Hide() is disabled, if the addon SoloRaidFrame is used.
-- But we are not taking care of this!
-- CompactRaidFrameManager:HookScript("OnShow", function()
  -- if Addon.uiHiddenTime ~= 0 and currentConfig.keepPartyRaidFrame == false then
    -- FadeOutFrame(CompactRaidFrameManager, 0, false, currentConfig.UIParentAlpha)
  -- end
-- end)

