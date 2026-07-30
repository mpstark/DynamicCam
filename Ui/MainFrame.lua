-------------------------------------------------------------------------------
-- DynamicCam new settings UI - main window shell.
--
-- This is the AceGUI-free replacement UI, built alongside the existing options
-- (which stay untouched until the transition is complete). During the transition
-- the window exists only as a free-floating frame, toggled with /dcnew, so it can
-- be compared side by side with the old UI in game. Docking into the Settings
-- panel (Graphit style) is added at the very end.
--
-- The window chrome comes from Ui/Window.lua, shared with the other DynamicCam
-- windows. What this file adds on top is what only the main window has: resizing
-- (grip, bounds, saved geometry), the background opacity slider, and the
-- top-level tabs. The tab row machinery itself (Ui.CreateTabRow) lives here too,
-- shared with the Situations page's inner tabs.
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)

DynamicCam.Ui = DynamicCam.Ui or {}
local Ui = DynamicCam.Ui


-- ===== Window geometry =====

-- First-ever open starts at the default size; thereafter the saved geometry from
-- DynamicCam.db.global.newUi is restored. These minimums are only a taste floor;
-- the hard floors come from the art that would break below them - the chrome's
-- own nine-slice (f.minWidth/minHeight) and whatever the pages claim through
-- Ui.RequireContentSize. See ApplyResizeBounds, which takes the largest.
local DEFAULT_WIDTH  = 760
local DEFAULT_HEIGHT = 820
local MIN_WIDTH      = 580
local MIN_HEIGHT     = 500
local MAX_WIDTH      = 1100
local MAX_HEIGHT_FRACTION = 1    -- cap on height, as a fraction of screen height

-- Gaps between the window edge and the content area, passed to the shared chrome
-- (Ui/Window.lua). Only the top differs from its default, to clear the tab row.
local CONTENT_GAP_TOP    = 64    -- clears the title bar and the tab row
local CONTENT_GAP_BOTTOM = 28
local CONTENT_GAP_LEFT   = 22
local CONTENT_GAP_RIGHT  = 18

-- Tab row: sits directly above the content area.
local TAB_ROW_HEIGHT = 30
local TAB_Y          = 6     -- gap between tab bottoms and the content area top
local TAB_INFO_SIZE  = 18    -- the info "i" inside a tab
local TAB_INFO_GAP   = 2     -- gap between a tab's label and its "i"

-- Shared by every tab row built with Ui.CreateTabRow (the main window's
-- top-level tabs and the Situations page's inner tabs).
local TAB_GAP        = 5     -- horizontal gap between neighbouring tabs
local TAB_H_PAD      = 14    -- padding inside a tab, on each side of its label
-- The selected tab's underlay is a bit taller and less transparent than the
-- unselected ones, applied on each selection change.
local TAB_BG_HEIGHT_SELECTED   = 24
local TAB_BG_HEIGHT_UNSELECTED = 21
local TAB_BG_ALPHA_SELECTED    = 0.55
local TAB_BG_ALPHA_UNSELECTED  = 0.3


local GetConfig = Ui.GetConfig   -- shared db.global.newUi accessor (Ui/Window.lua)


-- ===== Minimum content size =====

-- A page whose layout cannot survive being squeezed states the content-area size
-- it needs, and the window's resize floor grows to guarantee it. The Situations
-- page nests a nine-slice box of its own, whose corners draw at native size and
-- would silently overlap in a short window - so it claims the room for them.
--
-- Pages call this while they load, before the window is ever built, so the very
-- first ApplyResizeBounds already accounts for it.
local minContentWidth, minContentHeight = 0, 0

function Ui.RequireContentSize(width, height)
  minContentWidth  = math.max(minContentWidth, width or 0)
  minContentHeight = math.max(minContentHeight, height or 0)
end


-- ===== Tab rows =====

-- One builder for every row of tabs in the new UI: the main window's top-level
-- tabs and the Situations page's inner tabs (Ui/SituationsPage.lua). Mirrors
-- the Settings panel's Game/AddOns tabs: content-sized MinimalTabTemplate
-- buttons packed left to right, driven by a RadioButtonGroup, which gives the
-- selected texture and the white (selected) vs gold (unselected) text for free.
-- Each tab gets a solid underlay whose height and alpha mark the selected state.
--
-- The tabs are created as children of `row` and packed from its bottom-left.
-- The initial selection is applied silently; onSelect(index) then runs on every
-- user click (with the tab click sound), so the caller brings its initial
-- content on screen itself.
--
-- Returns the tabs array and the layout function, for re-packing after a
-- caller widens a tab (tab.extraWidth, e.g. the "i" icon inside a tab).
function Ui.CreateTabRow(row, names, initialIndex, onSelect)
  -- MinimalTabTemplate is 37px tall, but its art is bottom-anchored at the
  -- atlas's native (shorter) height, leaving clickable dead space above each
  -- tab. Trim each tab's hit rect down to the art height.
  local tabArt = C_Texture.GetAtlasInfo("Options_Tab_Middle")
  local tabArtHeight = tabArt and tabArt.height or 24

  local tabs = {}
  for i, name in ipairs(names) do
    local tab = CreateFrame("Button", nil, row, "MinimalTabTemplate")
    tab:SetHitRectInsets(0, 0, math.max(0, tab:GetHeight() - tabArtHeight), 0)
    local bg = tab:CreateTexture(nil, "BACKGROUND", nil, -8)
    bg:SetColorTexture(0.0, 0.0, 0.0)
    bg:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 2, 0)
    bg:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -2, 0)
    tab.bg = bg
    tab.Text:SetText(name)
    tabs[i] = tab
  end

  -- Content-sized tabs packed left to right, like the Settings panel's own tabs
  -- (widths differ per label; not stretched to fill the row). A tab with an "i"
  -- widens to hold it (tab.extraWidth).
  local function LayoutTabs()
    local x = 0
    for _, tab in ipairs(tabs) do
      tab:SetWidth(math.ceil(tab.Text:GetStringWidth()) + 2 * TAB_H_PAD + (tab.extraWidth or 0))
      tab:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", x, 0)
      x = x + tab:GetWidth() + TAB_GAP
    end
  end
  LayoutTabs()

  local function UpdateTabBackgrounds(selectedIndex)
    for i, tab in ipairs(tabs) do
      local selected = (i == selectedIndex)
      tab.bg:SetHeight(selected and TAB_BG_HEIGHT_SELECTED or TAB_BG_HEIGHT_UNSELECTED)
      tab.bg:SetAlpha(selected and TAB_BG_ALPHA_SELECTED or TAB_BG_ALPHA_UNSELECTED)
    end
  end

  -- Select the initial tab BEFORE registering the callback, so the initial
  -- selection does not fire the click sound.
  local tabsGroup = CreateRadioButtonGroup()
  tabsGroup:AddButtons(tabs)
  tabsGroup:SelectAtIndex(initialIndex)
  UpdateTabBackgrounds(initialIndex)
  tabsGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, function(_, _, tabIndex)
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    UpdateTabBackgrounds(tabIndex)
    onSelect(tabIndex)
  end, row)

  return tabs, LayoutTabs
end


-- ===== Frame =====

local frame  -- the singleton window, built on first toggle

local function BuildFrame()
  -- Shared chrome (Ui/Window.lua): background, metal border, title, close
  -- button, drag-anywhere, and the inner nine-slice content region. The top gap
  -- is bigger than the default because this window's bar also holds the tab row.
  local f = Ui.CreateWindow({
    name   = "DynamicCamUiFrame",
    title  = "DynamicCam",
    width  = DEFAULT_WIDTH,
    height = DEFAULT_HEIGHT,
    esc    = true,
    gaps   = {
      top    = CONTENT_GAP_TOP,
      bottom = CONTENT_GAP_BOTTOM,
      left   = CONTENT_GAP_LEFT,
      right  = CONTENT_GAP_RIGHT,
    },
  })
  f:SetPoint("CENTER")
  local contentArea = f.contentArea

  -- Persist the frame's size and position (account-wide).
  local function SaveGeometry()
    local point, _, relPoint, x, y = f:GetPoint(1)
    GetConfig().geometry = {
      point = point, relPoint = relPoint, x = x, y = y,
      width = f:GetWidth(), height = f:GetHeight(),
    }
  end
  f.onGeometryChanged = SaveGeometry

  -- ===== Resize bounds, geometry restore, screen clamping =====

  local function ApplyResizeBounds()
    if not f.SetResizeBounds then return end
    -- Three floors: the taste minimums above, the one the chrome reports for its
    -- own nine-slice, and whatever the pages require of the content area, which
    -- is stated in content-area terms and so has the gaps added back on.
    local minW = math.max(MIN_WIDTH, f.minWidth,
      minContentWidth + CONTENT_GAP_LEFT + CONTENT_GAP_RIGHT)
    local minH = math.max(MIN_HEIGHT, f.minHeight,
      minContentHeight + CONTENT_GAP_TOP + CONTENT_GAP_BOTTOM)
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

  -- The background opacity slider drives every DynamicCam window at once, so
  -- they keep matching; only this one carries the control (Ui/Window.lua).
  Ui.AddOpacitySlider(f)

  -- ===== Top-level tabs =====

  local tabNames = { L["Standard Settings"], L["Situations"], L["Profiles"], L["About"] }

  local tabRow = CreateFrame("Frame", nil, f)
  tabRow:SetPoint("BOTTOMLEFT", contentArea, "TOPLEFT", 0, TAB_Y)
  tabRow:SetPoint("BOTTOMRIGHT", contentArea, "TOPRIGHT", 0, TAB_Y)
  tabRow:SetHeight(TAB_ROW_HEIGHT)

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

  local currentTabIndex
  local function SelectTabContent(index)
    currentTabIndex = index
    for i, c in ipairs(tabContents) do
      c:SetShown(i == index)
    end
  end

  local activeTab = GetConfig().activeTab or 1
  local tabs, layoutTabs = Ui.CreateTabRow(tabRow, tabNames, activeTab, function(tabIndex)
    SelectTabContent(tabIndex)
    GetConfig().activeTab = tabIndex
  end)
  SelectTabContent(activeTab)

  -- Info "i" inside a tab, explaining what that tab's settings are. Hover-only,
  -- no click (it must not swallow the tab's own selection), matching the
  -- category-header "i" in Ui/Controls.lua. It sits just right of the label and
  -- is anchored to the label FontString (not the tab) so it tracks it - the tab
  -- mixin re-centres the label on every selection change, and the "i" follows.
  -- The tab reserves TAB_INFO_GAP + TAB_INFO_SIZE of its own width for it, hence
  -- the single re-layout once they are all attached.
  local function AddTabInfo(tabIndex, fillTooltip)
    local tab = tabs[tabIndex]
    local info = CreateFrame("Button", nil, tab)
    info:SetSize(TAB_INFO_SIZE, TAB_INFO_SIZE)
    info:SetPoint("LEFT", tab.Text, "RIGHT", TAB_INFO_GAP, 0)
    info:SetNormalTexture("Interface\\common\\help-i")
    info:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      fillTooltip()
      GameTooltip:Show()
    end)
    info:SetScript("OnLeave", GameTooltip_Hide)
    tab.extraWidth = TAB_INFO_GAP + TAB_INFO_SIZE
  end

  -- Standard Settings: what these settings are, plus the meaning of the blue
  -- "overridden" marking.
  AddTabInfo(1, function()
    GameTooltip_SetTitle(GameTooltip, L["Standard Settings"])
    GameTooltip_AddNormalLine(GameTooltip, L["<standardSettings_desc>"], true)
    GameTooltip_AddBlankLineToTooltip(GameTooltip)
    -- Same blue the overridden category rows use, from the one shared source.
    local c = DynamicCam.situationColors
    GameTooltip_AddNormalLine(GameTooltip,
      c.overridden .. L["<standardSettingsOverridden_desc>"] .. c.colorEnd, true)
  end)

  -- Situations: the counterpart, saying how a situation's settings relate to the
  -- standard ones.
  AddTabInfo(2, function()
    GameTooltip_SetTitle(GameTooltip, L["Situations"])
    GameTooltip_AddNormalLine(GameTooltip,
      L["These Situation Settings override the Standard Settings when the respective situation is active."], true)
  end)

  layoutTabs()

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
