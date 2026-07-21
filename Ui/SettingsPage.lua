-------------------------------------------------------------------------------
-- DynamicCam new settings UI - settings page (category column + setting rows).
--
-- Renders a category list on the left (styled like the Settings panel's
-- category column, including the vertical divider baked into the options
-- texture) and all categories' rows on the right in one continuous ScrollBox.
--
-- The left column is a navigation pane, not a tab switcher: clicking a category
-- scrolls its header to the top; scrolling the content highlights the topmost
-- visible category (a scrollspy). Category boundaries are marked by a separator
-- line. The page is built from a descriptor (Ui/Descriptor.lua) and runs
-- against standardSettings (sid = nil) here; the situations tab later reuses
-- CreatePage with a situationId and its override layer on top.
-------------------------------------------------------------------------------

assert(DynamicCam)
local Ui = DynamicCam.Ui
local Controls = Ui.Controls
local GetConfig = Ui.GetConfig   -- shared db.global.newUi accessor (MainFrame.lua)


-- ===== Layout =====

local CATEGORY_COL_WIDTH  = 150   -- nav pane width
local CATEGORY_ROW_HEIGHT = 24
local CATEGORY_TOP_PAD    = 8
local DIVIDER_WIDTH       = 16    -- on-screen width of the divider strip
local CONTENT_LEFT_PAD    = 12    -- gap between the divider and the rows
local SCROLLBAR_CHANNEL   = 20
local CONTENT_TOP_PAD     = 4     -- air above the first row, as in Graphit
local SECTION_GAP         = 15    -- extra air above header rows, as in Graphit
local ROW_GAP             = 6     -- vertical air between rows, so a zoom-based
                                  -- caption reads as part of ITS row, not the next

-- Animation timings (seconds).
local HIGHLIGHT_ANIM_TIME  = 0.1  -- selection bar slide
local NAV_ANIM_TIME        = 0.1  -- nav pane slide in/out
local SCROLL_SUPPRESS_TIME = 0.2  -- scrollspy off during a click-scroll (engine
                                  -- scroll is 0.11s; extra clears before release)

-- Collapse knob: one atlas set on a single managed texture, left-pointing by
-- default and rotated 180 for the right-pointing (expand) state.
local ARROW_ATLAS    = "shop-header-arrow"
local ARROW_HOVER    = "shop-header-arrow-hover"
local ARROW_PRESSED  = "shop-header-arrow-pressed"
local KNOB_SCALE     = 0.75   -- knob size vs the atlas's native size
-- Knob center X relative to the divider/edge, per state (negative = left of it,
-- positive = right); it slides between the two as the pane animates.
local KNOB_X_EXPANDED  = -4   -- while the nav is shown
local KNOB_X_COLLAPSED = -5   -- while the nav is hidden

-- The vertical category divider, cut from the options texture (the strip the
-- shell's nine-slice deliberately excludes). Vertically stretchable mid part.
local DIVIDER_FILE   = "Interface\\OptionsFrame\\Options"
local DIVIDER_COORDS = {194 / 1024, 210 / 1024, 330 / 1024, 589 / 1024}


-- ===== Category column button =====

local function CreateCategoryButton(parent, name, index, onSelect)
  local btn = CreateFrame("Button", nil, parent)
  PixelUtil.SetHeight(btn, CATEGORY_ROW_HEIGHT)

  btn.label = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  btn.label:SetPoint("LEFT", btn, "LEFT", 8, 0)
  btn.label:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
  btn.label:SetJustifyH("LEFT")
  btn.label:SetText(name)

  btn:SetScript("OnClick", function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    onSelect(index)
  end)

  -- The hover and selection fills are shared bars on the column (see CreatePage)
  -- so they can stack; the button itself draws no fill. Selecting only turns the
  -- label white.
  function btn.SetSelected(selected)
    btn.label:SetFontObject(selected and "GameFontHighlight" or "GameFontNormal")
  end

  return btn
end


-- ===== Page =====

-- Builds a settings page into `parent` (a tab content frame) from `categories`
-- (Ui/Descriptor.lua format). sid = nil edits the standard settings.
-- configKey names the db.global.newUi field remembering the selected category.
function Ui.CreatePage(parent, categories, sid, configKey)
  local page = {}

  -- ===== Category column =====

  -- The nav pane collapses by sliding left off the frame. navClip is the fixed
  -- clipping viewport pinned to the parent's left edge; its WIDTH is the single
  -- animated value (CATEGORY_COL_WIDTH expanded -> 0 collapsed). The divider,
  -- scroll box and knob all anchor to its right edge, so animating that one
  -- width slides the whole layout; the pane's buttons clip against it.
  local navClip = CreateFrame("Frame", nil, parent)
  navClip:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
  navClip:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
  navClip:SetWidth(CATEGORY_COL_WIDTH)
  navClip:SetClipsChildren(true)

  -- column: fixed-width nav content, right edge pinned to navClip's right edge,
  -- so it slides left (and clips) as navClip narrows.
  local column = CreateFrame("Frame", nil, navClip)
  column:SetPoint("TOPRIGHT", navClip, "TOPRIGHT", 0, 0)
  column:SetPoint("BOTTOMRIGHT", navClip, "BOTTOMRIGHT", 0, 0)
  column:SetWidth(CATEGORY_COL_WIDTH)

  -- The divider strip at the pane's right edge, from the options texture. It
  -- stays on the (unclipped) parent so it remains fully visible when collapsed.
  local divider = parent:CreateTexture(nil, "BACKGROUND")
  divider:SetTexture(DIVIDER_FILE)
  divider:SetTexCoord(unpack(DIVIDER_COORDS))
  divider:SetWidth(DIVIDER_WIDTH)
  divider:SetPoint("TOPLEFT", navClip, "TOPRIGHT", -DIVIDER_WIDTH / 2, 0)
  divider:SetPoint("BOTTOMLEFT", navClip, "BOTTOMRIGHT", -DIVIDER_WIDTH / 2, 0)

  -- Shared hover and selection fills, both on the column so they can stack: the
  -- selection bar (Options_List_Active) sits at a higher sublevel than the hover
  -- fill (Options_List_Hover), and the button labels sit above both (they live
  -- on the buttons, children of the column). This lets the sliding selection bar
  -- eclipse a hovered row instead of a gap opening under the cursor on click.
  -- Snapped to whole physical pixels (PixelUtil). The row pitch is a logical
  -- unit count, so at a UI scale other than 1:1 each successive bar would land
  -- on a different sub-pixel phase, and the bright 1px line along the atlas's
  -- top edge would blend away on some rows but not others (it looked like the
  -- top was cut off, and which rows were affected changed with the frame size).
  -- Snapping gives every bar the same physical size and phase.
  local function PositionBarAt(bar, y)
    PixelUtil.SetPoint(bar, "TOPLEFT", column, "TOPLEFT", 0, -(y + 2))
    PixelUtil.SetPoint(bar, "TOPRIGHT", column, "TOPRIGHT", -DIVIDER_WIDTH / 2, -(y + 2))
  end

  local hoverBar = column:CreateTexture(nil, "ARTWORK", nil, 0)
  hoverBar:SetAtlas("Options_List_Hover")
  PixelUtil.SetHeight(hoverBar, CATEGORY_ROW_HEIGHT - 4)
  hoverBar:Hide()

  local selectionBar = column:CreateTexture(nil, "ARTWORK", nil, 1)
  selectionBar:SetAtlas("Options_List_Active")
  PixelUtil.SetHeight(selectionBar, CATEGORY_ROW_HEIGHT - 4)
  selectionBar:Hide()

  local categoryButtons = {}
  for i, cat in ipairs(categories) do
    local btn = CreateCategoryButton(column, cat.name, i, function(index)
      page.ScrollToCategory(index)
    end)
    btn.topY = CATEGORY_TOP_PAD + (i - 1) * CATEGORY_ROW_HEIGHT
    -- Snapped like the bars, so each label stays centred in its highlight.
    PixelUtil.SetPoint(btn, "TOPLEFT", column, "TOPLEFT", 0, -btn.topY)
    PixelUtil.SetPoint(btn, "TOPRIGHT", column, "TOPRIGHT", -DIVIDER_WIDTH / 2, -btn.topY)
    -- Hover fill follows the mouse. It stays put through a click (the cursor is
    -- still over the row), so the sliding selection bar eclipses it from above
    -- rather than a gap flashing; it hides only when the mouse leaves the row.
    btn:SetScript("OnEnter", function() PositionBarAt(hoverBar, btn.topY); hoverBar:Show() end)
    btn:SetScript("OnLeave", function() hoverBar:Hide() end)
    categoryButtons[i] = btn
  end

  -- The selection bar slides between buttons with a retargetable ease-out:
  -- passing the current animated Y as the tween's start means an interrupted
  -- slide continues smoothly from where it is rather than snapping.
  local highlightInterp = CreateInterpolator(InterpolatorUtil.InterpolateEaseOut)
  local highlightY   -- current animated top offset of the bar

  local function MoveHighlightTo(targetY)
    selectionBar:Show()
    if highlightY == nil then
      -- First placement (page opens): no slide.
      highlightInterp:Cancel()
      highlightY = targetY
      PositionBarAt(selectionBar, targetY)
      return
    end
    highlightInterp:Interpolate(highlightY, targetY, HIGHLIGHT_ANIM_TIME, function(v)
      highlightY = v
      PositionBarAt(selectionBar, v)
    end)
  end

  -- ===== Content scroll box =====

  local scrollBox = CreateFrame("Frame", nil, parent, "WowScrollBox")
  scrollBox:SetPoint("TOPLEFT", navClip, "TOPRIGHT", CONTENT_LEFT_PAD, 0)
  scrollBox:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -SCROLLBAR_CHANNEL, 0)
  -- Exposed so the main window can forward wheel from anywhere over the frame.
  parent.wheelScrollBox = scrollBox

  local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
  scrollBar:SetPoint("TOP", scrollBox, "TOPRIGHT", SCROLLBAR_CHANNEL / 2, -4)
  scrollBar:SetPoint("BOTTOM", scrollBox, "BOTTOMRIGHT", SCROLLBAR_CHANNEL / 2, 4)

  local content = CreateFrame("Frame", nil, scrollBox)
  content.scrollable = true

  -- ===== Collapse knob =====

  -- The knob rides the divider, vertically centered, on the unclipped parent so
  -- it stays fully visible when the pane is collapsed to the far left. A single
  -- managed texture with plain SetAtlas (packing/rotation handled by the engine)
  -- draws the arrow; the hover/pressed atlas swap in on those states, and the
  -- 180 rotation flips left->right for the collapsed (expand) state. This avoids
  -- SetTexCoord surgery, which blanks atlas art that is packed rotated.
  local knob = CreateFrame("Button", nil, parent)
  local knobInfo = C_Texture.GetAtlasInfo(ARROW_ATLAS)
  knob:SetSize((knobInfo and knobInfo.width or 24) * KNOB_SCALE,
               (knobInfo and knobInfo.height or 34) * KNOB_SCALE)
  knob:SetFrameLevel(scrollBox:GetFrameLevel() + 10)
  -- Horizontal position (relative to the divider) is set per-frame in
  -- ApplyNavWidth, since it slides across the edge as the pane collapses.

  local knobTex = knob:CreateTexture(nil, "ARTWORK")
  knobTex:SetAllPoints(knob)

  local navInterp = CreateInterpolator(InterpolatorUtil.InterpolateEaseOut)
  local navWidth = CATEGORY_COL_WIDTH   -- current animated nav width
  local collapsed = false

  local function RefreshKnob()
    local atlas = ARROW_ATLAS
    if knob.pressed then atlas = ARROW_PRESSED
    elseif knob.hovered then atlas = ARROW_HOVER end
    knobTex:SetAtlas(atlas)
    knobTex:SetRotation(collapsed and math.pi or 0)
  end

  knob:SetScript("OnEnter", function() knob.hovered = true; RefreshKnob() end)
  knob:SetScript("OnLeave", function() knob.hovered = false; RefreshKnob() end)
  knob:SetScript("OnMouseDown", function() knob.pressed = true; RefreshKnob() end)
  knob:SetScript("OnMouseUp", function() knob.pressed = false; RefreshKnob() end)

  local function ApplyNavWidth(w)
    navWidth = w
    navClip:SetWidth(math.max(w, 0.001))
    column:SetShown(w > 0.5)   -- fully hidden (and click-proof) once collapsed

    local frac = 1 - w / CATEGORY_COL_WIDTH   -- 0 expanded, 1 collapsed
    -- Divider fades out with the collapse, gone entirely when hidden.
    divider:SetAlpha(Saturate(1 - frac))
    -- Knob slides between its expanded and collapsed X as the pane animates.
    knob:SetPoint("CENTER", navClip, "RIGHT",
      KNOB_X_EXPANDED + frac * (KNOB_X_COLLAPSED - KNOB_X_EXPANDED), 0)
  end

  local function SetCollapsed(wantCollapsed, instant)
    collapsed = wantCollapsed
    GetConfig().navCollapsed = wantCollapsed
    RefreshKnob()
    local target = wantCollapsed and 0 or CATEGORY_COL_WIDTH
    if instant then
      navInterp:Cancel()
      ApplyNavWidth(target)
    else
      navInterp:Interpolate(navWidth, target, NAV_ANIM_TIME, ApplyNavWidth)
    end
  end

  knob:SetScript("OnClick", function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    SetCollapsed(not collapsed)
  end)

  -- Apply the remembered state instantly on open (no slide).
  SetCollapsed(GetConfig().navCollapsed or false, true)

  -- ===== Rows =====

  local rows = {}
  local categoryOffsets = {}   -- catIndex -> pixel Y of its header, for the nav
  local ctx = {
    sid = sid,
    onChanged = function() page.RefreshAll() end,
  }

  -- All categories are laid out one after another in a single scroll. Each
  -- opens with a header; a separator line and extra air mark every category
  -- boundary but the first, so firstOverall carries across categories.
  local firstOverall = true
  for catIndex, cat in ipairs(categories) do
    -- Categories without any zoom-based setting give that column's width back
    -- to their sliders.
    local hasZoomBased = false
    for _, item in ipairs(cat.items) do
      if item.zoomBased then hasZoomBased = true break end
    end
    ctx.zoomZone = hasZoomBased and Controls.ZOOM_ZONE or 0

    -- Every category opens with a section header carrying the category's name
    -- and its help text behind the header's "i" icon.
    local items = cat.items
    if items[1] and items[1].kind ~= "header" then
      items = {{kind = "header", label = cat.name, info = cat.info, toggle = cat.toggle}}
      for _, item in ipairs(cat.items) do items[#items + 1] = item end
    end

    for _, item in ipairs(items) do
      local row = Controls.CreateRow(content, item, ctx)
      if row then
        row.category = catIndex
        if item.kind == "header" then
          row.isHeader = true
          -- Separator line and extra air at every category boundary except the
          -- first, which sits at the top and only needs CONTENT_TOP_PAD.
          row.lineAbove = not firstOverall
          row.line:SetShown(row.lineAbove)
        end
        firstOverall = false
        rows[#rows + 1] = row
      end
    end
  end

  -- Stack every row top to bottom in one continuous column, recording where
  -- each category begins (its header's top). Row heights are width-independent,
  -- so these offsets stay valid across resizes.
  local didInitialScroll = false
  local function Relayout()
    local y = CONTENT_TOP_PAD
    wipe(categoryOffsets)
    for _, row in ipairs(rows) do
      local show = not row.ShouldShow or row.ShouldShow()
      row:SetShown(show)
      if show then
        if row.isHeader and row.lineAbove then y = y + SECTION_GAP end
        if not categoryOffsets[row.category] then
          categoryOffsets[row.category] = y
        end
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -y)
        y = y + row:GetHeight() + ROW_GAP
      end
    end
    content:SetHeight(math.max(y, 1))
    scrollBox:FullUpdate()

    -- Once the box has a real size, jump to the remembered category. Instant:
    -- opening should show the remembered position, not scroll into it.
    if not didInitialScroll and page.ScrollToCategory and scrollBox:GetHeight() > 1 then
      didInitialScroll = true
      page.ScrollToCategory((configKey and GetConfig()[configKey]) or 1, true)
    end
  end

  scrollBox:HookScript("OnSizeChanged", function()
    content:SetWidth(scrollBox:GetWidth())
    Relayout()
  end)

  ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, CreateScrollBoxLinearView())
  scrollBar:SetHideIfUnscrollable(true)
  scrollBox:SetPanExtent(Controls.ROW_HEIGHT)
  scrollBox:SetInterpolateScroll(true)   -- ease-out on click-scroll, wheel, drag

  -- Row hover highlight, polled rather than event-driven (as in Graphit): a
  -- row's own OnEnter/OnLeave would drop the highlight the moment the cursor
  -- moved onto one of its controls, since the control takes the mouse.
  -- IsMouseOver is purely geometric, so the highlight covers the whole row.
  -- It ignores clipping too, hence the scrollBox gate: rows scrolled out of
  -- view still report the cursor as over them.
  parent:HookScript("OnUpdate", function()
    local inBox = scrollBox:IsMouseOver()
    for _, row in ipairs(rows) do
      if row.highlight then
        row.highlight:SetShown(inBox and row:IsMouseOver())
      end
    end
  end)

  -- ===== Navigation (nav pane <-> scroll position) =====

  local activeCategory = nil

  -- Highlight a nav entry without moving the scroll (driven by the scrollspy).
  local function SetActiveHighlight(index)
    if index == activeCategory then return end
    activeCategory = index
    for i, btn in ipairs(categoryButtons) do
      btn.SetSelected(i == index)
    end
    MoveHighlightTo(categoryButtons[index].topY)
    if configKey then GetConfig()[configKey] = index end
  end

  -- The active category for the current scroll position: the last one whose
  -- header is above a focus line.
  --
  -- For every category that CAN reach the top edge, the focus line is the top
  -- edge itself, so scrolling agrees with clicking (a click puts the header at
  -- the top). The last categories are piled into less than a viewport and can
  -- never reach the top; once the scroll passes the last reachable header it is
  -- "stuck" against the bottom, so there the focus line glides from that header
  -- down to the content's end, lighting up the tail in order and committing to
  -- the very last category at max scroll.
  local function ScrollspyCategory()
    local range = scrollBox:GetDerivedScrollRange()
    if range <= 0 then return 1 end
    local offset = scrollBox:GetDerivedScrollOffset()

    -- Last category whose header can reach the top edge (offset <= range).
    local lastReachable = 1
    for i = 1, #categories do
      if categoryOffsets[i] and categoryOffsets[i] <= range + 1 then
        lastReachable = i
      else
        break
      end
    end

    -- Clamped to the scroll range, and compared strictly below: the tolerance
    -- above can put the last reachable header a hair BEYOND max scroll, and an
    -- unclamped `offset <= reachTop` would then hold at every reachable offset.
    -- The tail regime would never run and the scrollspy would cap at this
    -- category, leaving the ones below it unselectable. Which categories that
    -- hits shifts with any change in content height (a conditional note row
    -- appearing is enough), so it has to be ruled out rather than tuned around.
    local reachTop = math.min(categoryOffsets[lastReachable] or 0, range)
    local focus
    if offset < reachTop then
      focus = offset                                  -- top-edge regime
    else
      local span = range - reachTop                   -- remaining stuck scroll
      local t = span > 0 and (offset - reachTop) / span or 1
      focus = reachTop + t * (content:GetHeight() - reachTop)  -- tail regime
    end

    local top = 1
    for i = 1, #categories do
      if categoryOffsets[i] and categoryOffsets[i] <= focus + 1 then
        top = i
      else
        break
      end
    end
    return top
  end

  -- Suppress the scrollspy while we drive the scroll ourselves, so a click
  -- lands on exactly the clicked category instead of flickering through the
  -- ones its animated scroll passes over.
  local suppressSpy = false
  scrollBox:RegisterCallback(BaseScrollBoxEvents.OnScroll, function()
    if suppressSpy then return end
    SetActiveHighlight(ScrollspyCategory())
  end, page)

  -- The scroll animation is the engine's fixed 0.11s ease-out; hold the
  -- scrollspy off a touch longer, and token-guard the release so a rapid second
  -- click extends the window rather than an earlier click's timer ending it.
  local suppressToken = 0
  function page.ScrollToCategory(index, instant)
    local target = categoryOffsets[index]
    if not target then return end
    SetActiveHighlight(index)

    local range = scrollBox:GetDerivedScrollRange()
    local targetPct = (range > 0) and Saturate(target / range) or 0
    if math.abs(scrollBox:GetScrollPercentage() - targetPct) < 0.0025 then
      return   -- already there: no scroll, so nothing to suppress
    end

    if instant then
      -- OnScroll fires synchronously here; suppress it so the one settled event
      -- doesn't re-run the scrollspy (the highlight is already set above).
      suppressSpy = true
      scrollBox:ScrollToOffset(target, true)
      suppressSpy = false
      return
    end

    suppressSpy = true
    suppressToken = suppressToken + 1
    local myToken = suppressToken
    scrollBox:ScrollToOffset(target)
    C_Timer.After(SCROLL_SUPPRESS_TIME, function()
      if myToken == suppressToken then suppressSpy = false end
    end)
  end

  -- ===== Page interface =====

  function page.RefreshAll()
    for _, row in ipairs(rows) do
      if row.Refresh then row.Refresh() end
    end
    -- Conditional notes may have appeared/disappeared.
    Relayout()
  end

  parent:HookScript("OnShow", function() page.RefreshAll() end)

  return page
end


-- ===== Standard Settings tab =====

-- Registered with the shell; built when the main frame is first created.
Ui.tabBuilders = Ui.tabBuilders or {}
Ui.tabBuilders[1] = function(tabContentFrame)
  Ui.standardPage = Ui.CreatePage(tabContentFrame, Ui.standardCategories, nil, "standardCategory")
end
