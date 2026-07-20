-------------------------------------------------------------------------------
-- DynamicCam new settings UI - main window shell.
--
-- This is the AceGUI-free replacement UI, built alongside the existing options
-- (which stay untouched until the transition is complete). During the transition
-- the window exists only as a free-floating frame, toggled with /dcnew, so it can
-- be compared side by side with the old UI in game. Docking into the Settings
-- panel (Graphit style) is added at the very end.
--
-- The window chrome follows Graphit's MainFrame.lua: a flat panel background,
-- the Settings panel's portrait-less metal nine-slice, a centred title, a close
-- button, a bottom-right resize grip, and the inner content background hand-cut
-- as a nine-slice from the Settings panel's own options texture. The frame is
-- dragged from any empty area. Top-level tabs are MinimalTabTemplate buttons
-- driven by a RadioButtonGroup, with a solid underlay whose height/alpha mark
-- the selected tab.
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)

DynamicCam.Ui = DynamicCam.Ui or {}
local Ui = DynamicCam.Ui


-- ===== Window geometry =====

-- First-ever open starts at the default size; thereafter the saved geometry from
-- DynamicCam.db.global.newUi is restored. Minimums are floored by the inner-frame
-- corner tiles, which must not overlap (see ApplyResizeBounds).
local DEFAULT_WIDTH  = 760
local DEFAULT_HEIGHT = 820
local MIN_WIDTH      = 640
local MIN_HEIGHT     = 500
local MAX_WIDTH      = 1100
local MAX_HEIGHT_FRACTION = 1    -- cap on height, as a fraction of screen height

-- Content area: the region framed by the inner nine-slice, below the title bar
-- and the tab row. Gaps are between the frame edge and the content area.
local CONTENT_GAP_TOP    = 64    -- clears the title bar and the tab row
local CONTENT_GAP_BOTTOM = 28
local CONTENT_GAP_LEFT   = 22
local CONTENT_GAP_RIGHT  = 18

-- Gap between the inner-frame border and the content area, per side (positive
-- pushes the border outward past the content).
local INNER_GAP_TOP    = 6
local INNER_GAP_BOTTOM = 6
local INNER_GAP_LEFT   = 10
local INNER_GAP_RIGHT  = 10

-- Options texture inner-frame corner size on screen. Also floors the resizable
-- frame's min size so the nine-slice corners never overlap.
local INNER_CORNER_W = 60
local INNER_CORNER_H = 180

-- Fixed (non-stretching) padding between the outer frame edge and the inner-
-- frame region, per axis; the resize floor is 2 corners + this chrome.
local CHROME_W = CONTENT_GAP_LEFT + CONTENT_GAP_RIGHT - INNER_GAP_LEFT - INNER_GAP_RIGHT
local CHROME_H = CONTENT_GAP_TOP + CONTENT_GAP_BOTTOM - INNER_GAP_TOP - INNER_GAP_BOTTOM

-- Tab row: sits directly above the content area.
local TAB_ROW_HEIGHT = 30
local TAB_Y          = 6     -- gap between tab bottoms and the content area top
local TAB_GAP        = 5     -- horizontal gap between neighbouring tabs

-- The selected tab's underlay is a bit taller and less transparent than the
-- unselected ones; UpdateTabBackgrounds applies these on each selection change.
local TAB_BG_HEIGHT_SELECTED   = 24
local TAB_BG_HEIGHT_UNSELECTED = 21
local TAB_BG_ALPHA_SELECTED    = 0.55
local TAB_BG_ALPHA_UNSELECTED  = 0.3


-- ===== Saved state =====

-- All new-UI state (geometry, active tab, background opacity, nav collapse,
-- selected category) lives in the account-wide AceDB global table under
-- db.global.newUi. Exposed on Ui so the page files share one accessor. The
-- frame is built lazily on first toggle, after the addon is initialised, so the
-- db is always ready.
function Ui.GetConfig()
  local g = DynamicCam.db.global
  g.newUi = g.newUi or {}
  return g.newUi
end
local GetConfig = Ui.GetConfig


-- ===== Frame =====

local frame  -- the singleton window, built on first toggle

local function BuildFrame()
  local f = CreateFrame("Frame", "DynamicCamUiFrame", UIParent)
  f:SetSize(DEFAULT_WIDTH, DEFAULT_HEIGHT)
  f:SetPoint("CENTER")
  f:SetFrameStrata("HIGH")
  f:SetToplevel(true)
  f:EnableMouse(true)
  f:SetClampedToScreen(true)

  -- ESC closes the window: WoW's ESC cascade calls CloseSpecialWindows, which
  -- hides every named frame listed here. A plain frame needs nothing more.
  tinsert(UISpecialFrames, "DynamicCamUiFrame")

  -- Persist the frame's size and position (account-wide).
  local function SaveGeometry()
    local point, _, relPoint, x, y = f:GetPoint(1)
    GetConfig().geometry = {
      point = point, relPoint = relPoint, x = x, y = y,
      width = f:GetWidth(), height = f:GetHeight(),
    }
  end

  -- ===== Chrome: flat background, metal nine-slice, title, close button =====

  -- Grouping layer for all background art, below every control.
  local bgLayer = CreateFrame("Frame", nil, f)
  bgLayer:SetAllPoints(f)
  bgLayer:SetFrameLevel(0)
  f.bgLayer = bgLayer

  -- Flat dark background, inset like the Settings panel's own Bg.
  f.Bg = CreateFrame("Frame", nil, bgLayer, "FlatPanelBackgroundTemplate")
  f.Bg:SetPoint("TOPLEFT", f, "TOPLEFT", 7, -18)
  f.Bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -3, 3)

  -- Solid backing UNDER the panel art. Blizzard's flat panel background is
  -- slightly translucent by design, which can make the content hard to read
  -- against a turbulent game world. The opacity slider blends this solid fill
  -- in (0 = standard Blizzard look, 1 = fully opaque window) - same purpose as
  -- the old detached frame's slider. As a texture on bgLayer it renders below
  -- the f.Bg child frame, regardless of creation order.
  local solidBg = bgLayer:CreateTexture(nil, "BACKGROUND", nil, -8)
  solidBg:SetColorTexture(0.2, 0.2, 0.2, 1)
  solidBg:SetAllPoints(f.Bg)
  solidBg:SetAlpha(0)

  -- The inner nine-slice pieces render on this layer, ABOVE the flat
  -- background. (Putting them directly on bgLayer would leave them veiled by
  -- f.Bg's translucent art, since a child frame draws over its parent's
  -- textures - washing the inner box out.)
  local innerBgLayer = CreateFrame("Frame", nil, bgLayer)
  innerBgLayer:SetAllPoints(f)
  innerBgLayer:SetFrameLevel(f.Bg:GetFrameLevel() + 1)

  -- Metal nine-slice border: the Settings panel's portrait-less layout.
  f.NineSlice = CreateFrame("Frame", nil, f, "NineSlicePanelTemplate")
  f.NineSlice.layoutType = "ButtonFrameTemplateNoPortrait"
  NineSliceUtil.ApplyLayoutByName(f.NineSlice, "ButtonFrameTemplateNoPortrait")

  -- Centred title in the top bar.
  f.TitleText = f.NineSlice:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  f.TitleText:SetPoint("TOP", 0, -5)
  f.TitleText:SetText("DynamicCam")

  -- Close button in the top-right corner. Plain Hide() - a templated close
  -- button's default OnClick calls the secure HideUIPanel(), blocked in combat.
  f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  f.CloseButton:SetPoint("TOPRIGHT", 1, 1)
  f.CloseButton:SetScript("OnClick", function(self) self:GetParent():Hide() end)

  -- Drag the frame from any empty area, including the title bar: f is the
  -- bottom-most frame, so clicks on interactive children (buttons, sliders, the
  -- scroll box, category buttons, rows, the close button, the resize grip) are
  -- consumed by them, and only non-interactive regions fall through to start a
  -- drag. Move on mouse-down (not OnDragStart, which only fires after the cursor
  -- travels a threshold distance) so the drag is immediate.
  f:SetMovable(true)
  f:SetScript("OnMouseDown", function() f:StartMoving() end)
  f:SetScript("OnMouseUp", function() f:StopMovingOrSizing(); SaveGeometry() end)

  -- ===== Resize bounds, geometry restore, screen clamping =====

  local function ApplyResizeBounds()
    if not f.SetResizeBounds then return end
    local minW = math.max(MIN_WIDTH, 2 * INNER_CORNER_W + CHROME_W)
    local minH = math.max(MIN_HEIGHT, 2 * INNER_CORNER_H + CHROME_H)
    local maxHeight = math.max(UIParent:GetHeight() * MAX_HEIGHT_FRACTION, minH)
    f:SetResizeBounds(minW, minH, MAX_WIDTH, maxHeight)
    -- SetResizeBounds only limits future drags; clamp the live size too, so a
    -- saved geometry from another display setup cannot stick out of range.
    f:SetWidth(math.max(minW, math.min(f:GetWidth(), MAX_WIDTH)))
    f:SetHeight(math.max(minH, math.min(f:GetHeight(), maxHeight)))
    return maxHeight
  end

  -- A display/UI-scale change does not retroactively move an open frame, so
  -- after refreshing the bounds pull any off-screen edge back into view.
  local function RefreshBoundsAndClamp()
    if not ApplyResizeBounds() then return end
    local left, bottom = f:GetRect()
    if left then
      local screenW, screenH = UIParent:GetWidth(), UIParent:GetHeight()
      left   = math.max(0, math.min(left,   screenW - f:GetWidth()))
      bottom = math.max(0, math.min(bottom, screenH - f:GetHeight()))
      f:ClearAllPoints()
      f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
    end
  end

  local function RestoreGeometry()
    local g = GetConfig().geometry
    if g and g.point then
      f:ClearAllPoints()
      f:SetPoint(g.point, UIParent, g.relPoint or g.point, g.x or 0, g.y or 0)
      f:SetSize(g.width or f:GetWidth(), g.height or f:GetHeight())
    end
    RefreshBoundsAndClamp()
  end

  f:SetResizable(true)
  RestoreGeometry()
  f:HookScript("OnShow", ApplyResizeBounds)
  f:RegisterEvent("DISPLAY_SIZE_CHANGED")
  f:RegisterEvent("UI_SCALE_CHANGED")
  f:HookScript("OnEvent", RefreshBoundsAndClamp)

  local grip = CreateFrame("Button", nil, f)
  grip:SetSize(16, 16)
  grip:SetPoint("BOTTOMRIGHT", -4, 4)
  grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  grip:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
  grip:SetScript("OnMouseUp", function() f:StopMovingOrSizing(); SaveGeometry() end)

  -- ===== Content area and inner nine-slice background =====

  -- The region every tab's content fills.
  local contentArea = CreateFrame("Frame", nil, f)
  contentArea:SetPoint("TOPLEFT", CONTENT_GAP_LEFT, -CONTENT_GAP_TOP)
  contentArea:SetPoint("BOTTOMRIGHT", -CONTENT_GAP_RIGHT, CONTENT_GAP_BOTTOM)
  f.contentArea = contentArea

  -- The Settings inner-content frame, a nine-slice hand-cut from the options
  -- texture so the corners stay crisp and Blizzard's baked-in category divider
  -- is excluded. (Category pages add the divider back as their own strip, at
  -- the category column's edge - that comes with the settings pages.) The nine
  -- pieces are textures on the innerBgLayer, above the flat background; corners
  -- draw at native size, edges/center stretch.
  --
  -- SetTexCoord addresses the grid lines between pixels, not the pixels, so
  -- each coordinate is one more than the image editor's pixel index.
  local INNER_FILE = "Interface\\OptionsFrame\\Options"
  local TEX        = 1024
  local PIECE = {
    TL = {1,   150, 61,  330}, TR = {828, 150, 888, 330},  -- corners (60x180)
    BL = {1,   589, 61,  769}, BR = {828, 589, 888, 769},
    T  = {101, 150, 120, 330}, B  = {101, 589, 120, 769},  -- clean border slices
    L  = {1,   330, 61,  589}, R  = {828, 330, 888, 589},  -- (divider-free)
    C  = {401, 401, 420, 420},                             -- solid center
  }

  -- Invisible region the nine-slice fills (frames the content area).
  local region = CreateFrame("Frame", nil, f)
  region:SetPoint("TOPLEFT", contentArea, "TOPLEFT", -INNER_GAP_LEFT, INNER_GAP_TOP)
  region:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", INNER_GAP_RIGHT, -INNER_GAP_BOTTOM)

  local function piece(name)
    local t = innerBgLayer:CreateTexture(nil, "BACKGROUND")
    t:SetTexture(INNER_FILE)
    local r = PIECE[name]
    t:SetTexCoord(r[1] / TEX, r[3] / TEX, r[2] / TEX, r[4] / TEX)
    return t
  end
  local tl, tr, bl, br = piece("TL"), piece("TR"), piece("BL"), piece("BR")
  tl:SetSize(INNER_CORNER_W, INNER_CORNER_H); tl:SetPoint("TOPLEFT",     region, "TOPLEFT")
  tr:SetSize(INNER_CORNER_W, INNER_CORNER_H); tr:SetPoint("TOPRIGHT",    region, "TOPRIGHT")
  bl:SetSize(INNER_CORNER_W, INNER_CORNER_H); bl:SetPoint("BOTTOMLEFT",  region, "BOTTOMLEFT")
  br:SetSize(INNER_CORNER_W, INNER_CORNER_H); br:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT")

  local top = piece("T"); top:SetPoint("TOPLEFT", tl, "TOPRIGHT");    top:SetPoint("BOTTOMRIGHT", tr, "BOTTOMLEFT")
  local bot = piece("B"); bot:SetPoint("TOPLEFT", bl, "TOPRIGHT");    bot:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT")
  local lft = piece("L"); lft:SetPoint("TOPLEFT", tl, "BOTTOMLEFT");  lft:SetPoint("BOTTOMRIGHT", bl, "TOPRIGHT")
  local rgt = piece("R"); rgt:SetPoint("TOPLEFT", tr, "BOTTOMLEFT");  rgt:SetPoint("BOTTOMRIGHT", br, "TOPRIGHT")
  local cen = piece("C"); cen:SetPoint("TOPLEFT", tl, "BOTTOMRIGHT"); cen:SetPoint("BOTTOMRIGHT", br, "TOPLEFT")

  -- ===== Background opacity slider =====

  -- Blends the solid backing in behind the translucent panel art, so the
  -- window can be made fully opaque for better readability (see solidBg
  -- above). Sits in the title bar, left of the close button.
  local opacitySlider = CreateFrame("Slider", nil, f, "MinimalSliderTemplate")
  opacitySlider:SetWidth(100)
  opacitySlider:SetPoint("RIGHT", f.CloseButton, "LEFT", -8, 0)
  opacitySlider:SetFrameLevel(f.NineSlice:GetFrameLevel() + 1)
  opacitySlider:SetMinMaxValues(0, 1)
  opacitySlider:SetValueStep(0.05)
  opacitySlider:SetObeyStepOnDrag(true)
  local function ApplyOpacity(value)
    solidBg:SetAlpha(value)
  end
  opacitySlider:SetScript("OnValueChanged", function(_, value)
    ApplyOpacity(value)
    GetConfig().opacity = value
  end)
  opacitySlider:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:SetText(L["Increase opacity"], 1, 1, 1)
    GameTooltip:AddLine(L["<opacity_tooltip>"], nil, nil, nil, true)
    GameTooltip:Show()
  end)
  opacitySlider:SetScript("OnLeave", function() GameTooltip:Hide() end)
  local savedOpacity = GetConfig().opacity or 0
  opacitySlider:SetValue(savedOpacity)
  ApplyOpacity(savedOpacity)

  -- ===== Top-level tabs =====

  -- Mirror the Settings panel's Game/AddOns tabs: MinimalTabTemplate buttons
  -- driven by a RadioButtonGroup, which gives the selected texture and the
  -- white (selected) vs gold (unselected) text for free. Each tab gets a solid
  -- underlay whose height and alpha mark the selected state.
  local tabNames = { L["Standard Settings"], L["Situations"], L["Profiles"], L["About"] }

  local tabRow = CreateFrame("Frame", nil, f)
  tabRow:SetPoint("BOTTOMLEFT", contentArea, "TOPLEFT", 0, TAB_Y)
  tabRow:SetPoint("BOTTOMRIGHT", contentArea, "TOPRIGHT", 0, TAB_Y)
  tabRow:SetHeight(TAB_ROW_HEIGHT)

  -- MinimalTabTemplate is 37px tall, but its art is bottom-anchored at the
  -- atlas's native (shorter) height, leaving clickable dead space above each
  -- tab. Trim each tab's hit rect down to the art height.
  local tabArt = C_Texture.GetAtlasInfo("Options_Tab_Middle")
  local tabArtHeight = tabArt and tabArt.height or 24

  local tabs = {}
  for i, name in ipairs(tabNames) do
    local tab = CreateFrame("Button", nil, f, "MinimalTabTemplate")
    tab:SetHitRectInsets(0, 0, math.max(0, tab:GetHeight() - tabArtHeight), 0)
    local bg = tab:CreateTexture(nil, "BACKGROUND", nil, -8)
    bg:SetColorTexture(0.0, 0.0, 0.0)
    bg:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 2, 0)
    bg:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -2, 0)
    tab.bg = bg
    tab.Text:SetText(name)
    tab:SetPoint("BOTTOMLEFT", tabRow, "BOTTOMLEFT", 0, 0)  -- x set in LayoutTabs
    tabs[i] = tab
  end
  f.tabs = tabs

  -- Equal tab widths across the row; recomputed when the window is resized.
  local function LayoutTabs()
    local w = (tabRow:GetWidth() - (#tabs - 1) * TAB_GAP) / #tabs
    if w <= 0 then return end
    for i, tab in ipairs(tabs) do
      tab:SetWidth(w)
      tab:SetPoint("BOTTOMLEFT", tabRow, "BOTTOMLEFT", (i - 1) * (w + TAB_GAP), 0)
    end
  end
  tabRow:SetScript("OnSizeChanged", LayoutTabs)
  LayoutTabs()

  local function UpdateTabBackgrounds(selectedIndex)
    for i, tab in ipairs(tabs) do
      local selected = (i == selectedIndex)
      tab.bg:SetHeight(selected and TAB_BG_HEIGHT_SELECTED or TAB_BG_HEIGHT_UNSELECTED)
      tab.bg:SetAlpha(selected and TAB_BG_ALPHA_SELECTED or TAB_BG_ALPHA_UNSELECTED)
    end
  end

  -- Per-tab content frames filling the content area; the selected tab's frame
  -- is shown, the others hidden. A tab with a registered builder (Ui.tabBuilders,
  -- filled by the page files) gets its page built now; the rest show a
  -- placeholder until their phase.
  Ui.tabBuilders = Ui.tabBuilders or {}
  local tabContents = {}
  for i, name in ipairs(tabNames) do
    local c = CreateFrame("Frame", nil, f)
    c:SetAllPoints(contentArea)
    c:Hide()
    if Ui.tabBuilders[i] then
      Ui.tabBuilders[i](c)
    else
      local placeholder = c:CreateFontString(nil, "OVERLAY", "GameFontDisableLarge")
      placeholder:SetPoint("CENTER")
      placeholder:SetText(name .. "\n\n(under construction)")
    end
    tabContents[i] = c
  end
  Ui.tabContents = tabContents

  local currentTabIndex
  local function SelectTabContent(index)
    currentTabIndex = index
    for i, c in ipairs(tabContents) do
      c:SetShown(i == index)
    end
  end

  -- Select the restored tab BEFORE registering the callback, so the initial
  -- selection does not fire the click sound.
  local activeTab = GetConfig().activeTab or 1
  local tabsGroup = CreateRadioButtonGroup()
  tabsGroup:AddButtons(tabs)
  tabsGroup:SelectAtIndex(activeTab)
  UpdateTabBackgrounds(activeTab)
  SelectTabContent(activeTab)
  tabsGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, function(_, _, tabIndex)
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    UpdateTabBackgrounds(tabIndex)
    SelectTabContent(tabIndex)
    GetConfig().activeTab = tabIndex
  end, f)

  -- ===== Mouse wheel forwarding =====

  -- The whole window consumes the mouse wheel and applies it to the active tab's
  -- scroll box (pages expose it as content.wheelScrollBox), so the wheel scrolls
  -- the content from anywhere over the frame, not only directly over the scroll
  -- box. Regions with their own wheel-enabled child (the scroll box itself,
  -- multiline edit boxes) still handle the wheel themselves, as they sit above f.
  f:EnableMouseWheel(true)
  f:SetScript("OnMouseWheel", function(_, delta)
    local c = tabContents[currentTabIndex]
    if c and c.wheelScrollBox then
      c.wheelScrollBox:OnMouseWheel(delta)
    end
  end)

  -- ===== Open / close sounds =====

  -- Hooked after the initial Hide, so building the frame plays no close sound.
  f:Hide()
  f:HookScript("OnShow", function() PlaySound(SOUNDKIT.IG_MAINMENU_OPEN) end)
  f:HookScript("OnHide", function() PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE) end)

  return f
end


-- ===== Toggle and slash command =====

local function EnsureFrame()
  if not frame then
    frame = BuildFrame()
    Ui.frame = frame
  end
  return frame
end
Ui.EnsureFrame = EnsureFrame

function Ui.Toggle()
  EnsureFrame()
  if frame:IsVisible() then
    frame:Hide()
  else
    frame:Show()
  end
end

-- Temporary development command while the new UI is built alongside the old
-- one. Replaces the old UI's slash commands at the end of the transition.
SLASH_DCNEW1 = "/dcnew"
SlashCmdList["DCNEW"] = function()
  Ui.Toggle()
end
