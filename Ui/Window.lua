-------------------------------------------------------------------------------
-- DynamicCam new UI - shared window chrome.
--
-- One factory for every DynamicCam window, so the main settings window, the
-- reactive zoom visual aid and the curve editors all look the same: a flat panel
-- background, the Settings panel's portrait-less metal nine-slice, a centred
-- title and a close button. The window is dragged from any empty area.
--
-- Optionally (opts.innerFrame) the content area is framed by a second, inner
-- nine-slice hand-cut from the Settings panel's own options texture. The main
-- window uses it; the two graph windows read better without it. That box is also
-- available on its own as Ui.DrawInnerBox, for a page nesting one inside it.
--
-- The factory builds the chrome only. Anything a particular window needs on top
-- (resizing, saved geometry, tabs, the opacity slider) stays with that window;
-- see Ui/MainFrame.lua, which is the only resizable one.
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)

DynamicCam.Ui = DynamicCam.Ui or {}
local Ui = DynamicCam.Ui


-- ===== Saved state =====

-- All new-UI state (geometry, active tab, background opacity, nav collapse,
-- selected category) lives in the account-wide AceDB global table under
-- db.global.newUi. Windows are built lazily, after the addon is initialised, so
-- the db is always ready by the time this is called.
function Ui.GetConfig()
  local g = DynamicCam.db.global
  g.newUi = g.newUi or {}
  return g.newUi
end
local GetConfig = Ui.GetConfig


-- ===== Chrome metrics =====

-- Gap between the inner-frame border and the content area, per side (positive
-- pushes the border outward past the content).
local INNER_GAP_TOP    = 6
local INNER_GAP_BOTTOM = 6
local INNER_GAP_LEFT   = 10
local INNER_GAP_RIGHT  = 10

-- Options texture inner-frame corner size on screen. The corners draw at native
-- size, so a window smaller than two of them plus its chrome would have them
-- overlap - hence the minimum size the factory reports back on each window.
local INNER_CORNER_W = 60
local INNER_CORNER_H = 180

-- The smallest region Ui.DrawInnerBox fills without its corners overlapping.
-- Published for callers that draw a box of their own and have to secure the room
-- for it themselves (see Ui.RequireContentSize in Ui/MainFrame.lua).
Ui.INNER_BOX_MIN_WIDTH  = 2 * INNER_CORNER_W
Ui.INNER_BOX_MIN_HEIGHT = 2 * INNER_CORNER_H

-- The smallest window the inner nine-slice can be drawn in, for the given gaps.
local function MinSize(gaps)
  local chromeW = gaps.left + gaps.right - INNER_GAP_LEFT - INNER_GAP_RIGHT
  local chromeH = gaps.top + gaps.bottom - INNER_GAP_TOP - INNER_GAP_BOTTOM
  return 2 * INNER_CORNER_W + chromeW, 2 * INNER_CORNER_H + chromeH
end


-- ===== Inner nine-slice =====

-- The Settings inner-content frame, a nine-slice hand-cut from the options
-- texture so the corners stay crisp and Blizzard's baked-in category divider is
-- excluded. (The settings page adds a divider back as its own strip, at the
-- category column's edge.)
--
-- SetTexCoord addresses the grid lines between pixels, not the pixels, so each
-- coordinate is one more than the image editor's pixel index.
local INNER_FILE = "Interface\\OptionsFrame\\Options"
local INNER_TEX  = 1024
local INNER_PIECE = {
  TL = {1,   150, 61,  330}, TR = {828, 150, 888, 330},  -- corners (60x180)
  BL = {1,   589, 61,  769}, BR = {828, 589, 888, 769},
  T  = {101, 150, 120, 330}, B  = {101, 589, 120, 769},  -- clean border slices
  L  = {1,   330, 61,  589}, R  = {828, 330, 888, 589},  -- (divider-free)
  C  = {401, 401, 420, 420},                             -- solid center
}

-- Draws that box around `region`, with its border sitting on the region's edges.
-- The nine pieces are textures created on `artParent`, which decides what they
-- draw over: the window chrome passes a layer above the flat panel background,
-- and a page nesting a second box inside the first passes a layer of its own,
-- below its content. Corners draw at native size, edges and center stretch - so
-- a region smaller than two corners (INNER_CORNER_W/H) has them overlap.
function Ui.DrawInnerBox(artParent, region)
  local function piece(name)
    local t = artParent:CreateTexture(nil, "BACKGROUND")
    t:SetTexture(INNER_FILE)
    local r = INNER_PIECE[name]
    t:SetTexCoord(r[1] / INNER_TEX, r[3] / INNER_TEX, r[2] / INNER_TEX, r[4] / INNER_TEX)
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
end


-- ===== Background opacity =====

-- Blizzard's flat panel background is slightly translucent by design, which can
-- make content hard to read against a turbulent game world. Every window carries
-- a solid backing under the panel art that the main window's opacity slider
-- blends in (0 = standard Blizzard look, 1 = fully opaque). One setting drives
-- them all, so the windows keep matching whatever it is set to.
local solidBackings = {}

function Ui.SetWindowOpacity(value)
  GetConfig().opacity = value
  for backing in pairs(solidBackings) do
    backing:SetAlpha(value)
  end
end


-- ===== Factory =====

-- opts:
--   name    global frame name; also what ESC closing needs (optional)
--   title   title bar text
--   width   initial size
--   height
--   strata  frame strata (default "HIGH")
--   esc     register in UISpecialFrames, so ESC closes it (needs name)
--   gaps    content area gaps from the window edge, {top, bottom, left, right}
--   innerFrame  draw the inner nine-slice around the content area (default true).
--               Windows whose content is one graph look cleaner without the
--               second box, and are then free of its minimum size.
--
-- The returned frame carries:
--   f.contentArea  the content region; re-anchor it freely, the inner nine-slice
--                  (when there is one) follows
--   f.TitleText    the centred title
--   f.CloseButton  the top-right close button
--   f.minWidth     smallest size the inner nine-slice draws cleanly at (0 without)
--   f.minHeight
--   f.onGeometryChanged  optional callback, called after a drag (set by caller)
function Ui.CreateWindow(opts)
  local gaps = opts.gaps
  local innerFrame = opts.innerFrame ~= false

  local f = CreateFrame("Frame", opts.name, UIParent)
  f:SetSize(opts.width, opts.height)
  f:SetFrameStrata(opts.strata or "HIGH")
  f:SetToplevel(true)
  f:EnableMouse(true)
  f:SetClampedToScreen(true)
  if innerFrame then
    f.minWidth, f.minHeight = MinSize(gaps)
  else
    f.minWidth, f.minHeight = 0, 0
  end

  -- ESC closes the window: WoW's ESC cascade calls CloseSpecialWindows, which
  -- hides every named frame listed here. A plain frame needs nothing more.
  if opts.esc and opts.name then
    tinsert(UISpecialFrames, opts.name)
  end

  -- ===== Background art =====

  -- Grouping layer for all background art, below every control.
  local bgLayer = CreateFrame("Frame", nil, f)
  bgLayer:SetAllPoints(f)
  bgLayer:SetFrameLevel(0)

  -- Flat dark background, inset like the Settings panel's own Bg.
  f.Bg = CreateFrame("Frame", nil, bgLayer, "FlatPanelBackgroundTemplate")
  f.Bg:SetPoint("TOPLEFT", f, "TOPLEFT", 7, -18)
  f.Bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -3, 3)

  -- Solid backing UNDER the panel art (see Ui.SetWindowOpacity). As a texture on
  -- bgLayer it renders below the f.Bg child frame, regardless of creation order.
  local solidBg = bgLayer:CreateTexture(nil, "BACKGROUND", nil, -8)
  solidBg:SetColorTexture(0.2, 0.2, 0.2, 1)
  solidBg:SetAllPoints(f.Bg)
  solidBg:SetAlpha(GetConfig().opacity or 0)
  solidBackings[solidBg] = true

  -- Metal nine-slice border: the Settings panel's portrait-less layout.
  f.NineSlice = CreateFrame("Frame", nil, f, "NineSlicePanelTemplate")
  f.NineSlice.layoutType = "ButtonFrameTemplateNoPortrait"
  NineSliceUtil.ApplyLayoutByName(f.NineSlice, "ButtonFrameTemplateNoPortrait")

  -- Centred title in the top bar.
  f.TitleText = f.NineSlice:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  f.TitleText:SetPoint("TOP", 0, -5)
  f.TitleText:SetText(opts.title or "")

  -- Close button in the top-right corner. Plain Hide() - a templated close
  -- button's default OnClick calls the secure HideUIPanel(), blocked in combat.
  f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  f.CloseButton:SetPoint("TOPRIGHT", 1, 1)
  f.CloseButton:SetScript("OnClick", function(self) self:GetParent():Hide() end)

  -- Drag the window from any empty area, including the title bar: f is the
  -- bottom-most frame, so clicks on interactive children (buttons, sliders,
  -- scroll boxes, the close button) are consumed by them, and only
  -- non-interactive regions fall through to start a drag. Move on mouse-down
  -- (not OnDragStart, which only fires after the cursor travels a threshold
  -- distance) so the drag is immediate.
  f:SetMovable(true)
  f:SetScript("OnMouseDown", function() f:StartMoving() end)
  f:SetScript("OnMouseUp", function()
    f:StopMovingOrSizing()
    if f.onGeometryChanged then f.onGeometryChanged() end
  end)

  -- ===== Content area and inner nine-slice =====

  local contentArea = CreateFrame("Frame", nil, f)
  contentArea:SetPoint("TOPLEFT", gaps.left, -gaps.top)
  contentArea:SetPoint("BOTTOMRIGHT", -gaps.right, gaps.bottom)
  f.contentArea = contentArea

  if not innerFrame then return f end

  -- Invisible region the nine-slice fills. Anchored to the content area, so a
  -- window that moves its content area (the curve editor's varying top region)
  -- drags the border along with it.
  local region = CreateFrame("Frame", nil, f)
  region:SetPoint("TOPLEFT", contentArea, "TOPLEFT", -INNER_GAP_LEFT, INNER_GAP_TOP)
  region:SetPoint("BOTTOMRIGHT", contentArea, "BOTTOMRIGHT", INNER_GAP_RIGHT, -INNER_GAP_BOTTOM)

  -- Its pieces go on a layer of their own, ABOVE the flat background. (Putting
  -- them directly on bgLayer would leave them veiled by f.Bg's translucent art,
  -- since a child frame draws over its parent's textures - washing the box out.)
  local innerBgLayer = CreateFrame("Frame", nil, bgLayer)
  innerBgLayer:SetAllPoints(f)
  innerBgLayer:SetFrameLevel(f.Bg:GetFrameLevel() + 1)

  Ui.DrawInnerBox(innerBgLayer, region)

  return f
end


-- ===== Opacity slider =====

-- The slider that drives Ui.SetWindowOpacity, placed in a window's title bar
-- left of its close button. Only the main window carries one; the others follow
-- the setting it writes.
function Ui.AddOpacitySlider(f)
  local slider = CreateFrame("Slider", nil, f, "MinimalSliderTemplate")
  slider:SetWidth(100)
  slider:SetPoint("RIGHT", f.CloseButton, "LEFT", -8, 0)
  slider:SetFrameLevel(f.NineSlice:GetFrameLevel() + 1)
  slider:SetMinMaxValues(0, 1)
  slider:SetValueStep(0.05)
  slider:SetObeyStepOnDrag(true)
  slider:SetScript("OnValueChanged", function(_, value) Ui.SetWindowOpacity(value) end)
  slider:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:SetText(L["Increase opacity"], 1, 1, 1)
    GameTooltip:AddLine(L["<opacity_tooltip>"], nil, nil, nil, true)
    GameTooltip:Show()
  end)
  slider:SetScript("OnLeave", function() GameTooltip:Hide() end)
  slider:SetValue(GetConfig().opacity or 0)
  return slider
end
