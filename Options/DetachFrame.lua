---------------
-- LIBRARIES --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)
local Options = DynamicCam.Options

local acd = LibStub("AceConfigDialog-3.0")
local acr = LibStub("AceConfigRegistry-3.0")

-- AceConfigDialog appName used exclusively for the detached frame.
-- Registered (with the same options table) in Options:RegisterMenus() so
-- that the detached frame has its own status tables and OpenFrames slot,
-- letting it coexist with the Blizzard-panel-embedded "DynamicCam" frame.
local DETACHED_APP = "DynamicCam_Detached"
local DETACHED_FRAME_WIDTH = 680  -- fixed width; east-edge resizer is disabled

-- Module-level state.
local detachedOpen   = false           -- true while the detached frame is shown
local detachedWidget = nil             -- the AceGUI Frame widget, if open
local settingsPanelJustClosed = false  -- one-frame flag, see §2


---------------------------------------------------------------------------
-- §1  ESC-proxy frame
---------------------------------------------------------------------------
-- Problem:  We want ESC to close our detached frame and curve editors, but
--           we do NOT want WoW's panel management (ShowUIPanel, game-menu
--           open/close, SettingsPanel close) to close them.
--
-- WoW's ESC cascade:
--   ToggleGameMenu -> CloseAllWindows -> CloseWindows -> CloseSpecialWindows
-- ShowUIPanel also calls:
--                                        CloseWindows -> CloseSpecialWindows
--
-- AceConfigDialog hooks CloseSpecialWindows itself (tainting it), so we
-- cannot register our frames there directly without combat issues.
--
-- Solution:
--   1. An invisible proxy frame in UISpecialFrames.  When our frames
--      are visible the proxy is :Show()n, so the ORIGINAL untainted
--      CloseSpecialWindows hides it and returns truthy - signalling to
--      ToggleGameMenu that the ESC keystroke was consumed, so it skips
--      opening the game menu for that keypress.
--
--   2. hooksecurefunc on AceConfigDialog:CloseAll always sets
--      closeAllOverride[DETACHED_APP], so ACD's own CloseSpecialWindows
--      hook never closes our detached frame. (See §2.)
--
--   3. The proxy's OnHide defers the close decision by one frame:
--        - If GameMenuFrame or SettingsPanel appeared -> panel transition,
--          our frames survive, proxy re-shows.
--        - If SettingsPanel was just hidden (its Close() calls
--          ToggleGameMenu internally) -> same, survive.
--        - Otherwise -> genuine ESC, close our frames.
--
-- Two-ESC side-effect (by design, not worth fixing):
--   - Game menu open + our frames open: the first ESC is consumed by
--     ToggleGameMenu to close the game menu (it never calls
--     CloseSpecialWindows when the menu is already shown), so our proxy
--     isn't touched. A second ESC is needed to close our frames.
--   - SettingsPanel open + our frames open: the first ESC closes the
--     settings panel, which internally calls ToggleGameMenu() and trips
--     our proxy. The wasSettingsClose flag prevents that from closing
--     our frames (we can't distinguish this from SettingsPanel closing
--     itself via its own Close button). A second ESC is needed.
--   Fixing either case would require detecting the raw ESCAPE keypress,
--   which is fragile inside a deferred timer.
---------------------------------------------------------------------------

local proxy = CreateFrame("Frame", "DynamicCamEscProxy")
tinsert(UISpecialFrames, "DynamicCamEscProxy")
proxy:Hide()

-- Returns true when any of our closeable frames are visible.
local function HasVisibleFrames()
  return detachedOpen or DynamicCam:HasVisibleCurveEditors()
end

proxy:SetScript("OnHide", function(self)
  -- Capture the flag synchronously into a local before scheduling the
  -- deferred check. The SettingsPanel:OnHide hook (§2) sets the flag to
  -- true and also schedules a C_Timer.After(0) to reset it back to false.
  -- C_Timer callbacks fire in the order they were scheduled within a frame,
  -- so by the time our deferred closure below runs, the reset timer has
  -- already fired and settingsPanelJustClosed is false again. The local
  -- captures the true value before either timer has had a chance to run.
  local wasSettingsClose = settingsPanelJustClosed

  C_Timer.After(0, function()
    if not HasVisibleFrames() then return end

    -- A UI panel appeared, or the settings panel just dismissed itself
    -- (its Close() chains into ToggleGameMenu) - not a genuine ESC.
    if GameMenuFrame:IsShown() or SettingsPanel:IsShown() or wasSettingsClose then
      self:Show()
      return
    end

    -- Genuine ESC: close our frames.
    if acd.OpenFrames and acd.OpenFrames[DETACHED_APP] then
      acd.OpenFrames[DETACHED_APP]:Hide()
    end
    DynamicCam:EscAllCurveEditors()
  end)
end)

-- Public helpers - called by ZoomBasedEditor.lua when curve editors
-- open/close, and by OpenDetached / detached-frame OnHide below.
function Options:ShowEscProxy()
  proxy:Show()
end

function Options:HideEscProxyIfNeeded()
  if not HasVisibleFrames() then
    proxy:Hide()
  end
end


---------------------------------------------------------------------------
-- §2  Hooks on external systems (run once at file load)
---------------------------------------------------------------------------

-- Always exempt the detached frame from ACD's CloseAll sweep.
hooksecurefunc(acd, "CloseAll", function()
  acd.frame.closeAllOverride[DETACHED_APP] = true
end)

-- SettingsPanel:Close() -> ExitWithCommit() -> TransitionBackOpeningPanel()
-- hides the panel, then calls ToggleGameMenu(). That cascades through
-- CloseAllWindows and hides our proxy. The one-frame flag lets the
-- proxy's OnHide handler (§1) recognise this as a panel transition.
SettingsPanel:HookScript("OnHide", function()
  settingsPanelJustClosed = true
  C_Timer.After(0, function()
    settingsPanelJustClosed = false
  end)
end)


---------------------------------------------------------------------------
-- §3  Navigation-state sync between the two appNames
---------------------------------------------------------------------------
-- Both "DynamicCam" and DETACHED_APP share the same options table but have
-- independent ACD status trees (tracking which tab / tree node is selected).
-- We copy the navigation state so that switching between attached <-> detached
-- preserves the user's current view.
--
-- Copying replaces the status.groups *table object*, which breaks any live
-- TreeGroup widget that still holds the old reference. Therefore:
--   - Copy INTO a frame only when it is about to open (before ACD builds it).
--   - Never copy into a frame whose widgets are still live.

local function CopyNavigationState(sourceApp, targetApp)
  local statusTable = acd.Status
  if not statusTable[sourceApp] then return end

  local function copyGroups(src, dst)
    if src.status and src.status.groups then
      if not dst.status then dst.status = {} end
      dst.status.groups = CopyTable(src.status.groups)
    end
    if src.children then
      if not dst.children then dst.children = {} end
      for key, child in pairs(src.children) do
        if not dst.children[key] then
          dst.children[key] = { status = {}, children = {} }
        end
        copyGroups(child, dst.children[key])
      end
    end
  end

  if not statusTable[targetApp] then
    statusTable[targetApp] = { status = {}, children = {} }
  end
  copyGroups(statusTable[sourceApp], statusTable[targetApp])
end


---------------------------------------------------------------------------
-- §4  Detach button (on the Blizzard-panel-embedded frame)
---------------------------------------------------------------------------
-- Called once at the end of Options:RegisterMenus().

function Options:CreateDetachButton()

  ---- 4a. Detach button ------------------------------------------------

  local detachBtn = CreateFrame("Button", nil, self.menu)
  detachBtn:SetSize(24, 24)
  detachBtn:SetPoint("TOPRIGHT", self.menu, "TOPRIGHT", -10, -10)
  detachBtn:SetFrameLevel(self.menu:GetFrameLevel() + 10)
  detachBtn:SetNormalAtlas("RedButton-Expand")
  detachBtn:SetPushedAtlas("RedButton-Expand-Pressed")
  detachBtn:SetDisabledAtlas("RedButton-Expand-Disabled")
  detachBtn:SetHighlightAtlas("RedButton-Highlight", "ADD")

  detachBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    if InCombatLockdown() then
      GameTooltip:SetText(L["Detach"], LIGHTERGRAY_FONT_COLOR.r, LIGHTERGRAY_FONT_COLOR.g, LIGHTERGRAY_FONT_COLOR.b, 1, true)
      GameTooltip:AddLine(L["<detach_combat>"], RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1, true)
    else
      GameTooltip:SetText(L["Detach"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, true)
      GameTooltip:AddLine(L["<detach_tooltip>"], TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, 1, true)
    end
    GameTooltip:Show()
  end)
  detachBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

  -- Close the settings panel only when the detach button is used
  -- (not via /dc, which intentionally leaves the settings panel open).
  detachBtn:SetScript("OnClick", function()
    if InCombatLockdown() then return end  -- belt-and-suspenders: button is greyed out in combat
    if SettingsPanel and SettingsPanel:IsShown() then
      HideUIPanel(SettingsPanel)
    end
    Options:OpenDetached()
  end)

  ---- 4b. Combat-lock visual for detach button -------------------------

  local function setDetachCombatLocked(locked)
    if locked then
      detachBtn:GetNormalTexture():SetDesaturated(true)
      detachBtn:GetHighlightTexture():SetAlpha(0)
      detachBtn:SetPushedAtlas("RedButton-Expand")
      detachBtn:GetPushedTexture():SetDesaturated(true)
    else
      detachBtn:GetNormalTexture():SetDesaturated(false)
      detachBtn:GetHighlightTexture():SetAlpha(1)
      detachBtn:SetPushedAtlas("RedButton-Expand-Pressed")
      detachBtn:GetPushedTexture():SetDesaturated(false)
    end
  end

  local combatFrame = CreateFrame("Frame")
  combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
  combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
  combatFrame:SetScript("OnEvent", function(_, event)
    setDetachCombatLocked(event == "PLAYER_REGEN_DISABLED")
  end)
  setDetachCombatLocked(InCombatLockdown())

  ---- 4c. Attached-frame OnShow: sync from detached --------------------
  -- When the attached frame opens while the detached frame is still
  -- visible, adopt the detached frame's current view. ACD has already
  -- built the content by the time HookScript fires (post-hook), so a
  -- deferred NotifyChange rebuilds the tree with the copied state.

  self.menu:HookScript("OnShow", function()
    if detachedOpen then
      CopyNavigationState(DETACHED_APP, "DynamicCam")
      C_Timer.After(0, function()
        acr:NotifyChange("DynamicCam")
      end)
    end
  end)
end


---------------------------------------------------------------------------
-- §5  Open / customise the detached frame
---------------------------------------------------------------------------

function Options:OpenDetached()
  -- Already showing - just raise.
  if detachedWidget and detachedWidget.frame:IsShown() then
    detachedWidget.frame:Raise()
    return
  end

  -- Sync navigation state from the attached frame's last-known status.
  if acd.Status["DynamicCam"] then
    CopyNavigationState("DynamicCam", DETACHED_APP)
  end

  -- Geometry: fixed width, restored height + position from saved vars.
  local status = acd:GetStatusTable(DETACHED_APP)

  -- Height and width must be set in the status table before opening the frame, so ACD sizes it correctly on first open.
  -- This is why we are not doing it in CustomiseDetachedFrame, which runs after the frame is already shown.
  status.width = DETACHED_FRAME_WIDTH

  -- Read last position and height from saved variables.
  local popOut = DynamicCam.db.global.popOutFrame
  if popOut then
    -- If the user has changed the screen resolution since the last time they
    -- opened the detached frame, the saved height may be larger than the current screen.
    -- So clamp it to 90% of the current screen.
    local maxHeight = GetScreenHeight() * 0.9
    if popOut.height then status.height = math.min(popOut.height, maxHeight) end
    if popOut.top    then status.top    = popOut.top    end
    if popOut.left   then status.left   = popOut.left   end
  end

  acd:Open(DETACHED_APP)
  local widget = acd.OpenFrames[DETACHED_APP]
  if not widget then return end

  detachedWidget = widget
  detachedOpen   = true
  Options:ShowEscProxy()

  widget.frame:Raise()  -- bring to front on every open

  ---- One-time customisation (AceGUI pools frames) ---------------------
  if not widget.frame._dcCustomised then
    widget.frame._dcCustomised = true
    self:CustomiseDetachedFrame(widget)
  end

  ---- Per-open state (runs every time) ---------------------------------
  local savedOpacity = (popOut and popOut.opacity) or 0.0
  widget.frame._dcSolidBg:SetAlpha(savedOpacity)
  widget.frame._dcOpacitySlider:SetValue(savedOpacity)

  self:DisableTreeDraggers(widget)
end


---------------------------------------------------------------------------
-- §6  One-time frame customisation
---------------------------------------------------------------------------
-- Called once per pooled AceGUI Frame instance the first time it is used
-- for our detached app. Sets up child widgets (reattach button, opacity
-- slider, solid background) and hooks (OnHide, drag, resize).

function Options:CustomiseDetachedFrame(widget)
  local f = widget.frame

  f:SetFrameStrata("HIGH")        -- elevated above normal UI panels
  f:SetClampedToScreen(true)      -- prevent dragging off-screen

  ---- 6a. OnHide: state cleanup ----------------------------------------
  f:HookScript("OnHide", function()
    -- Only sync navigation state back into "DynamicCam" when the attached
    -- frame (SettingsPanel) is not currently shown.
    -- Reason: CopyNavigationState replaces the status.groups table object.
    -- A live AceGUI TreeGroup widget caches a direct reference to that
    -- table internally, so if we swap the table out while the attached
    -- frame is open, the widget continues reading/writing the old table
    -- and our new copy is silently ignored - the selection appears to
    -- reset on the next interaction.
    if not SettingsPanel:IsShown() then
      CopyNavigationState(DETACHED_APP, "DynamicCam")
    end
    detachedOpen   = false
    detachedWidget = nil
    Options:HideEscProxyIfNeeded()
  end)

  ---- 6b. Solid background behind the semi-transparent AceGUI backdrop --
  local solidBg = f:CreateTexture(nil, "BACKGROUND", nil, -8)
  solidBg:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -12)
  solidBg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 12)
  solidBg:SetColorTexture(0.2, 0.2, 0.2, 1)
  f._dcSolidBg = solidBg

  ---- 6c. Reattach button ----------------------------------------------
  local reattachBtn = CreateFrame("Button", nil, f)
  reattachBtn:SetSize(24, 24)
  reattachBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -20)
  reattachBtn:SetFrameLevel(f:GetFrameLevel() + 20)
  reattachBtn:SetNormalAtlas("RedButton-Condense")
  reattachBtn:SetPushedAtlas("RedButton-Condense-Pressed")
  reattachBtn:SetDisabledAtlas("RedButton-Condense-disabled")
  reattachBtn:SetHighlightAtlas("RedButton-Highlight", "ADD")

  reattachBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    if InCombatLockdown() then
      GameTooltip:SetText(L["Reattach"], LIGHTERGRAY_FONT_COLOR.r, LIGHTERGRAY_FONT_COLOR.g, LIGHTERGRAY_FONT_COLOR.b, 1, true)
      GameTooltip:AddLine(L["<reattach_combat>"], RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1, true)
    else
      GameTooltip:SetText(L["Reattach"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, true)
      GameTooltip:AddLine(L["<reattach_tooltip>"], TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, 1, true)
    end
    GameTooltip:Show()
  end)
  reattachBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

  reattachBtn:SetScript("OnClick", function()
    if InCombatLockdown() then return end  -- belt-and-suspenders: button is greyed out in combat
    if detachedOpen and acd.Status[DETACHED_APP] then
      CopyNavigationState(DETACHED_APP, "DynamicCam")
    end
    acd:Close(DETACHED_APP)
    Settings.OpenToCategory(Options.menu.name)
  end)

  ---- 6d. Reattach combat-lock visual ----------------------------------
  local function setReattachCombatLocked(locked)
    if locked then
      reattachBtn:GetNormalTexture():SetDesaturated(true)
      reattachBtn:GetHighlightTexture():SetAlpha(0)
      reattachBtn:SetPushedAtlas("RedButton-Condense")
      reattachBtn:GetPushedTexture():SetDesaturated(true)
    else
      reattachBtn:GetNormalTexture():SetDesaturated(false)
      reattachBtn:GetHighlightTexture():SetAlpha(1)
      reattachBtn:SetPushedAtlas("RedButton-Condense-Pressed")
      reattachBtn:GetPushedTexture():SetDesaturated(false)
    end
  end
  local combatFrame = CreateFrame("Frame")
  combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
  combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
  combatFrame:SetScript("OnEvent", function(_, event)
    setReattachCombatLocked(event == "PLAYER_REGEN_DISABLED")
  end)
  setReattachCombatLocked(InCombatLockdown())

  ---- 6e. Opacity slider -----------------------------------------------
  local opacitySlider = CreateFrame("Slider", nil, f, "MinimalSliderTemplate")
  opacitySlider:SetWidth(100)
  opacitySlider:SetPoint("RIGHT", reattachBtn, "LEFT", -10, 0)
  opacitySlider:SetFrameLevel(f:GetFrameLevel() + 20)
  opacitySlider:SetMinMaxValues(0, 1.0)
  opacitySlider:SetValueStep(0.05)
  opacitySlider:SetObeyStepOnDrag(true)
  opacitySlider:SetScript("OnValueChanged", function(_, value)
    solidBg:SetAlpha(value)
    local db = DynamicCam.db.global
    if not db.popOutFrame then db.popOutFrame = {} end
    db.popOutFrame.opacity = value
  end)
  opacitySlider:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(L["Increase opacity"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, true)
    GameTooltip:AddLine(L["<opacity_tooltip>"], TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, 1, true)
    GameTooltip:Show()
  end)
  opacitySlider:SetScript("OnLeave", function() GameTooltip:Hide() end)
  f._dcOpacitySlider = opacitySlider

  ---- 6f. Resize / drag overrides --------------------------------------
  -- Disable east-edge resizer (width is fixed).
  widget.sizer_e:EnableMouse(false)
  -- Make SE corner resize vertically only.
  widget.sizer_se:SetScript("OnMouseDown", function(this)
    this:GetParent():StartSizing("BOTTOM")
  end)

  -- Allow dragging from any unused background area.
  f:EnableMouse(true)
  f:SetMovable(true)

  -- Persist position and height to a saved variable.
  local function SavePopOutState()
    local db = DynamicCam.db.global
    if not db.popOutFrame then db.popOutFrame = {} end
    db.popOutFrame.height = f:GetHeight()
    db.popOutFrame.top    = f:GetTop()
    db.popOutFrame.left   = f:GetLeft()
  end

  f:SetScript("OnMouseDown", function(this, button)
    if button == "LeftButton" then
      this:StartMoving()
    end
  end)
  f:SetScript("OnMouseUp", function(this)
    this:StopMovingOrSizing()
    local s = widget.status or widget.localstatus
    s.top  = this:GetTop()
    s.left = this:GetLeft()
    SavePopOutState()
  end)

  widget.sizer_s:HookScript("OnMouseUp", SavePopOutState)
  widget.sizer_se:HookScript("OnMouseUp", SavePopOutState)

  -- Clamp height so the bottom never leaves the screen.
  local clampingHeight = false
  f:HookScript("OnSizeChanged", function(this)
    if clampingHeight then return end
    local top = this:GetTop()
    if top and this:GetHeight() > top then
      clampingHeight = true
      this:SetHeight(top)
      clampingHeight = false
    end
  end)

  -- Persist position after AceGUI title-bar drag.
  local knownChildren = {
    [widget.sizer_se] = true,
    [widget.sizer_s]  = true,
    [widget.sizer_e]  = true,
    [widget.content]  = true,
  }
  for _, child in ipairs({f:GetChildren()}) do
    if not knownChildren[child] and child:GetScript("OnMouseUp") then
      child:HookScript("OnMouseUp", SavePopOutState)
    end
  end
end


---------------------------------------------------------------------------
-- §7  Tree-dragger suppression
---------------------------------------------------------------------------
-- The detached frame has a fixed width, so the AceGUI TreeGroup drag
-- handle (between the tree and content panes) must be disabled.  When
-- ACD switches tabs it releases and re-acquires TreeGroup widgets from
-- the AceGUI pool, re-enabling the dragger each time.  We handle both
-- the initial disable and the re-acquire case.

function Options:DisableTreeDraggers(widget)
  -- Disable draggers on any TreeGroup already in the widget hierarchy.
  local function disableRecursive(container)
    if container.dragger then
      container.dragger:EnableMouse(false)
    end
    if container.children then
      for _, child in ipairs(container.children) do
        disableRecursive(child)
      end
    end
  end
  disableRecursive(widget)

  -- One-time hook: override AceGUI.Create so every TreeGroup acquired
  -- while the detached frame is open has its SetTreeWidth patched to
  -- force resizable=false.
  if self._treeHookInstalled then return end
  self._treeHookInstalled = true

  local AceGUI = LibStub("AceGUI-3.0")
  local origCreate = AceGUI.Create
  AceGUI.Create = function(self, widgetType, ...)
    local w = origCreate(self, widgetType, ...)
    if w and w.type == "TreeGroup" and acd.OpenFrames and acd.OpenFrames[DETACHED_APP] then
      local origSTW = w.SetTreeWidth
      w.SetTreeWidth = function(tw, treewidth, _resizable)
        origSTW(tw, treewidth, false)
      end
    end
    return w
  end
end
