-------------------------------------------------------------------------------
-- DynamicCam new settings UI - row factories.
--
-- Renders the descriptor items (Ui/Descriptor.lua) as Settings-panel-style rows:
-- label on the left, a modern control on the right (MinimalSliderWithSteppers,
-- UICheckButton), plus DynamicCam's per-setting reset button and the zoom-based
-- curve control (checkbox + gear opening the curve editor).
--
-- Every factory takes (parent, item, ctx) and returns a row frame. ctx carries:
--   sid        situationId the page edits (nil = standard settings); read
--              lazily everywhere, so the page can retarget it at runtime
--   onChanged  called after any write, so the page can refresh gated rows
--   rowGate?   rowGate(row, item) gate over a whole row, consulted on
--              Refresh: the page's own conditions (a situation being
--              selected, the category's override, the category's
--              enabledWhen)
-- Rows expose row.Refresh() (re-read the binding, apply enable state), may set
-- row.ShouldShow() (any kind, from item.shownWhen) and may set
-- row.MeasureHeight() when their height depends on wrapped text.
-------------------------------------------------------------------------------

local folderName = ...
local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)
local Ui = DynamicCam.Ui

local Controls = {}
Ui.Controls = Controls


-- ===== Row layout =====

Controls.ROW_HEIGHT    = 35
Controls.HEADER_HEIGHT = 35
-- A row is a chain of columns, listed here left to right: each WIDTH names a
-- thing, each GAP names the air on that thing's left. Together they tile the
-- whole row, so every one of them is independent - changing a gap moves what is
-- left of it and nothing else. Only the widths and gaps below are tunable; the
-- positions are derived from them by the *Offset helpers further down.
local LABEL_LEFT_PAD   = 0     -- row edge -> label
local LABEL_WIDTH      = 140   -- label ("name column")
local CONTROL_GAP      = 4     -- label -> slider or checkbox
local READOUT_GAP      = 2     -- slider -> value readout
local READOUT_WIDTH    = 40    -- value readout
local RESET_GAP        = 0     -- value readout -> reset button
local RESET_SIZE       = 20    -- reset button (its frame is square)
local ZOOM_GAP         = 8     -- reset button -> zoom-based column
local ZOOM_PAIR_WIDTH  = 49    -- ... whose width is the wider of its checkbox
local ZOOM_CAPTION_PAD = 6     --     (24) + gap (2) + gear (23) and its caption
                               --     plus this padding: see ZOOM_ZONE below
local RIGHT_PAD        = 8     -- last column -> row edge

-- The slider widget's frame is wider than the slider looks: the template insets
-- the bar by 19px on each side for the steppers, which are 15px (back) and 13px
-- (forward) wide. So 4px of the frame's left and 6px of its right are empty.
-- READOUT_GAP is measured from the visible stepper, hence this correction.
-- CONTROL_GAP is not corrected: it applies to the control's frame, so that a
-- row's slider and another row's checkbox still start on the same column.
local SLIDER_RIGHT_SLACK = 6

-- Vertical placement within the zoom-based column.
local ZOOM_CTRL_HEIGHT = 40    -- tall enough for the caption to clear the row-
                               -- centered pair; see CreateZoomBasedControl
local ZOOM_CTRL_Y      = -5    -- ditto: how far the whole column rides below the
                               -- row's center
local HEADER_TEXT_TOP  = 13    -- heading text, below the row's top

-- Header-right toggle (a 128px atlas, scaled down). It floats over the rows
-- beneath it, so none of these three affect the layout. X is measured from the
-- row's RIGHT edge and Y from its TOP, so both go negative to move inwards.
-- Y is tuned by eye rather than set to HEADER_TEXT_TOP: the atlas carries
-- transparent margin, so the art's top sits well below the button's frame.
-- Retune it after changing HEADER_TOGGLE_SIZE, which scales that margin too.
local HEADER_TOGGLE_SIZE = 36
local HEADER_TOGGLE_X    = -5
local HEADER_TOGGLE_Y    = -8

-- The override checkbox left of a heading (situation pages only): the heading
-- text moves right to make room for it. Y is its top's distance below the
-- row's top, tuned so the box centers on the heading text.
local HEADER_CHECK_SIZE = 28
local HEADER_CHECK_GAP  = 4    -- checkbox -> heading text
local HEADER_CHECK_Y    = 7

-- Select row: [<] [ dropdown fills ] [>], the Settings panel's dropdown with
-- steppers, built exactly as Graphit's setting dropdowns are. It has no value
-- readout of its own, so it spans the slider's and the readout's columns
-- together, up to the reset button.
local SELECT_STEPPER_GAP = 2   -- stepper -> dropdown
local SELECT_RESET_GAP   = 4   -- forward stepper -> reset button

-- Input row: a scrolling multi-line edit box spanning the same columns as a
-- select. item.lines sets how many lines of it are visible; the text scrolls
-- within that, since the lists these hold - comma-separated frame names - run
-- far past what any reasonable row height could show.
local INPUT_LINE_HEIGHT = 14   -- one line of ChatFontNormal
local INPUT_ROW_PAD     = 10   -- air above and below the box within its row
-- InputScrollFrameTemplate hangs its border art 5px outside the scroll frame on
-- every side, so the frame is inset by that much for the BORDER to land where
-- the other controls' edges are.
local INPUT_BORDER_INSET = 5
-- Its scroll bar sits inside the right edge (scrollBarX = -10 in
-- InputScrollFrame_OnLoad), and OnLoad sizes the edit box to width - 18 to clear
-- it; that 18 has to be reapplied whenever the row is resized.
local INPUT_BAR_CHANNEL = 18
-- Fewer lines than this and the scroll bar's knob has no travel worth dragging.
local INPUT_MIN_LINES = 6

-- Button row: an action rather than a value, so it takes its natural width in
-- the control column instead of stretching to the reset column like the others.
local ACTION_BUTTON_WIDTH  = 160
local ACTION_BUTTON_HEIGHT = 22

-- Note row: a wrapped paragraph spanning the whole row, so it only has air
-- above and below its text.
local NOTE_TOP_PAD    = 2
local NOTE_BOTTOM_PAD = 6
-- A disabled note FADES rather than turning grey: its string carries its own
-- colour codes (the red "Attention:" lead), which SetTextColor cannot override.
local NOTE_DISABLED_ALPHA = 0.4

-- The zoom-based column must fit its "Zoom-based" caption, whose width depends
-- on the locale - so measure it instead of hardcoding. The measuring string and
-- the real caption must use the same font, hence the shared constant: with two
-- separate font names one could be changed without the other and the column
-- would silently truncate (or waste width).
local ZOOM_CAPTION_FONT = "GameFontNormalTiny"
local ZOOM_ZONE
do
  local measure = UIParent:CreateFontString(nil, "ARTWORK", ZOOM_CAPTION_FONT)
  measure:SetText(L["Zoom-based"])
  ZOOM_ZONE = math.max(ZOOM_PAIR_WIDTH, math.ceil(measure:GetStringWidth()))
             + ZOOM_CAPTION_PAD
  measure:Hide()
end

-- The page sets ctx.zoomZone to 0 for categories without any zoom-based
-- setting, letting their sliders use the freed width.
Controls.ZOOM_ZONE = ZOOM_ZONE

-- Left inset of every row's label; the override banner aligns its text to it.
Controls.LABEL_LEFT_PAD = LABEL_LEFT_PAD

-- Where each column's RIGHT edge sits, as a distance inwards from the row's
-- right edge. Walking the chain from the right is what lets a category without
-- any zoom-based setting pass zoomZone = 0 and have every column left of it -
-- reset button, readout, slider - reclaim that width automatically.
local function ResetOffset(zoomZone)
  return RIGHT_PAD + (zoomZone > 0 and zoomZone + ZOOM_GAP or 0)
end

local function ReadoutOffset(zoomZone)
  return ResetOffset(zoomZone) + RESET_SIZE + RESET_GAP
end

local function SliderOffset(zoomZone)
  return ReadoutOffset(zoomZone) + READOUT_WIDTH + READOUT_GAP - SLIDER_RIGHT_SLACK
end

-- Reset button icon (the transmogrify revert arrow), per client flavor.
local RESET_TEX = "Interface\\Transmogrify\\Transmogrify"
local RESET_COORDS = {0.58203125, 0.64453125, 0.30078125, 0.36328125}
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
  RESET_COORDS = {0.533203125, 0.58203125, 0.248046875, 0.294921875}
end

-- Zoom-based gear textures (see the curve editor). Not in classic game files,
-- so a local copy ships in the addon's Ui/Textures folder.
local GEAR_TEX = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
  and "Interface\\Common\\CommonDropdownSettings2x"
  or  "Interface\\AddOns\\" .. folderName .. "\\Ui\\Textures\\commondropdownsettings2x"
local GEAR_NORMAL    = {0.21875, 0.43750, 0.00000, 0.43750}
local GEAR_PRESSED   = {0.21875, 0.43750, 0.43750, 0.87500}
local GEAR_HL_NORMAL = {0.00000, 0.21875, 0.43750, 0.87500}
local GEAR_HL_PRESSED= {0.43750, 0.65625, 0.00000, 0.43750}


-- ===== Binding =====

-- Wraps a descriptor item into display-space get/set plus reset handling.
-- All slider math happens in display space; toDisplay/fromDisplay convert
-- from/to the stored value, and minClampZero maps the cvar's real minimum
-- (e.g. 0.01 damp rate) to a clean 0 on the slider.
--
-- An item addresses its value either with dbPath (the settings layer) or with
-- situationPath (the situation object itself); see Ui/Descriptor.lua for what
-- that distinction means.
--
-- ctx.sid is read on every access, never captured: a situation page retargets
-- its rows to another situation by just changing ctx.sid and refreshing.

-- Walk to the container holding a path's last key, so a caller can read or
-- assign the leaf. Returns nil when the path does not exist.
local function ResolvePath(root, path)
  local t = root
  for i = 1, #path - 1 do
    t = t and t[path[i]]
  end
  return t, path[#path]
end

local function MakeBinding(item, ctx)
  local p1, p2 = item.dbPath and item.dbPath[1], item.dbPath and item.dbPath[2]

  -- The second address kind: a path into the situation object itself
  -- (transitionTime, viewZoom, rotation, hideUI), whose values are per-situation
  -- by nature and so have no standard setting to fall back to. Their defaults
  -- come from DynamicCam.situationDefaults, NOT from the standard settings.
  local sitPath = item.situationPath

  local function Situation()
    return ctx.sid and DynamicCam.db.profile.situations[ctx.sid]
  end

  local function SituationDefault()
    local t, key = ResolvePath(DynamicCam.situationDefaults, sitPath)
    return t and t[key]
  end

  local function rawGet()
    if item.get then return item.get(ctx.sid) end
    if sitPath then
      local t, key = ResolvePath(Situation(), sitPath)
      return t and t[key]
    end
    return DynamicCam:GetSettingsValue(ctx.sid, p1, p2)
  end

  local function rawSet(v)
    if item.set then item.set(v, ctx.sid) return end
    if sitPath then
      local t, key = ResolvePath(Situation(), sitPath)
      if not t then return end
      local previous = t[key]
      t[key] = v
      -- Some of these need work beyond the write (restarting a rotation,
      -- re-running the UI fade); the item says so with its own apply. Only when
      -- the value actually MOVED, though: re-applying on a write that changed
      -- nothing would restart a live rotation for no reason.
      --
      -- Worth guarding here, rather than only at the slider, precisely BECAUSE
      -- apply does more than store a value. A setter that merely re-writes its
      -- value idempotently would not need this - deduping the drag would be
      -- enough - but a stateful side effect has to be protected from every
      -- caller, not just the one that fires most often.
      if item.apply and previous ~= v then item.apply(ctx.sid) end
      return
    end
    DynamicCam:SetSettingsValue(v, ctx.sid, p1, p2)
  end

  local clamp = item.minClampZero and DynamicCam.CVAR_MIN_CLAMP[item.minClampZero]
  local toDisplay = item.toDisplay or function(v) return v end
  local fromDisplay = item.fromDisplay or function(v) return v end

  local binding = {}

  function binding.get()
    local raw = rawGet()
    if clamp and raw == clamp then raw = 0 end
    return toDisplay(raw)
  end

  function binding.set(display)
    if clamp and display < clamp then display = clamp end
    rawSet(fromDisplay(display))
  end

  -- A reset button appears only where this binding knows the default, which is
  -- either address kind but not a hand-written get/set.
  if (item.dbPath or sitPath) and not item.get then
    function binding.isDefault()
      if sitPath then return rawGet() == SituationDefault() end
      return DynamicCam:GetSettingsValue(ctx.sid, p1, p2) == DynamicCam:GetSettingsDefault(p1, p2)
    end
    function binding.reset()
      if sitPath then rawSet(SituationDefault()) return end
      DynamicCam:SetSettingsDefault(ctx.sid, p1, p2)
    end
    function binding.defaultDisplay()
      if sitPath then return toDisplay(SituationDefault()) end
      return toDisplay(DynamicCam:GetSettingsDefault(p1, p2))
    end
  end

  return binding
end


-- ===== Row base =====

local function NewRow(parent)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(Controls.ROW_HEIGHT)

  -- Settings-style hover highlight across the whole row. Deliberately NOT driven
  -- by the row's own OnEnter/OnLeave: moving onto a child control (slider, reset
  -- button, ...) fires the row's OnLeave and the highlight would drop out. The
  -- page polls row:IsMouseOver() in an OnUpdate instead (a geometric test that
  -- ignores which frame owns the mouse), so the highlight stays up across the
  -- whole row. See Ui/SettingsPage.lua.
  row.highlight = row:CreateTexture(nil, "ARTWORK")
  row.highlight:SetColorTexture(1, 1, 1, 0.1)
  row.highlight:SetAllPoints(row)
  row.highlight:Hide()

  row.label = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  row.label:SetPoint("LEFT", row, "LEFT", LABEL_LEFT_PAD, 0)
  row.label:SetWidth(LABEL_WIDTH)
  row.label:SetJustifyH("LEFT")
  row.label:SetWordWrap(true)
  row.label:SetMaxLines(2)

  return row
end

-- Break a long cvar name over several lines for the tooltip. The tooltip wraps
-- only at spaces, and a cvar name has none, so past the tooltip's max width the
-- one long word is not wrapped but clipped with an ellipsis. We insert the
-- breaks ourselves at camelCase boundaries (the old UI did this by hand for
-- "Pitch (flying)") so each line fits. Only the display copy is broken;
-- item.cvar stays intact as the live key.
local CVAR_WRAP = 23   -- start a new line at the next word once past this length;
                       -- lower it if any wrapped line still clips
local function WrapCvar(cvar)
  local lines, line = {}, ""
  for i = 1, #cvar do
    local ch = cvar:sub(i, i)
    if ch:match("%u") and #line >= CVAR_WRAP then
      lines[#lines + 1] = line
      line = ""
    end
    line = line .. ch
  end
  lines[#lines + 1] = line
  return table.concat(lines, "\n")
end

-- Tooltip on the row's NAME only (title, optional body, optional grey cvar
-- note), as in the Settings panel and Graphit: hovering the controls to the
-- right shows nothing, so the tooltip does not follow the cursor across the
-- whole row. A FontString takes no mouse, so the trigger is a button spanning
-- the label's width across the full row height, lining up with the row's hover
-- highlight (the label is vertically centred, hence the half-height reach).
local function AddRowTooltip(row, item, ctx)
  local hasBody = item.tooltip or item.cvar or item.transformNote

  local hit = CreateFrame("Button", nil, row)
  local half = row:GetHeight() / 2
  hit:SetPoint("TOPLEFT", row.label, "LEFT", 0, half)
  hit:SetPoint("BOTTOMRIGHT", row.label, "RIGHT", 0, -half)

  hit:SetScript("OnEnter", function(self)
    -- Nothing to say and the name is fully readable: no tooltip at all.
    if not hasBody and not row.label:IsTruncated() then return end
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip_SetTitle(GameTooltip, item.label)
    -- A tooltip may be a function, for a row whose explanation depends on the
    -- current state (Zoom Value reads differently per zoom type).
    if item.tooltip then
      local body = item.tooltip
      if type(body) == "function" then body = body(ctx.sid) end
      GameTooltip_AddNormalLine(GameTooltip, body, true)
    end
    if item.cvar then
      GameTooltip_AddDisabledLine(GameTooltip, "cvar: " .. WrapCvar(item.cvar), true)
    end
    if item.transformNote then
      GameTooltip_AddDisabledLine(GameTooltip, item.transformNote, true)
    end
    GameTooltip:Show()
  end)
  hit:SetScript("OnLeave", GameTooltip_Hide)
end

-- Grey or restore a row's label with its enabled state.
local function SetLabelEnabled(row, enabled)
  if enabled then
    row.label:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
  else
    row.label:SetTextColor(GRAY_FONT_COLOR:GetRGB())
  end
end

-- Whether a row's controls are live, from both gates: the page's own (a
-- situation being selected, the category's override, the category's shared
-- condition) and the item's own enabledWhen.
local function RowEnabled(row, item, ctx)
  if ctx.rowGate and not ctx.rowGate(row, item) then return false end
  return not item.enabledWhen or item.enabledWhen(ctx.sid)
end


-- ===== Reset button =====

-- The per-setting reset-to-default button, right of the value readout.
-- Disabled (desaturated) while the setting is at its default.
local function CreateResetButton(row, binding, ctx)
  local btn = CreateFrame("Button", nil, row)
  btn:SetSize(RESET_SIZE, RESET_SIZE)
  btn:SetPoint("RIGHT", row, "RIGHT", -ResetOffset(ctx.zoomZone or ZOOM_ZONE), 0)
  btn:SetNormalTexture(RESET_TEX)
  btn:GetNormalTexture():SetTexCoord(unpack(RESET_COORDS))
  btn:SetHighlightTexture(RESET_TEX)
  btn:GetHighlightTexture():SetTexCoord(unpack(RESET_COORDS))
  btn:GetHighlightTexture():SetBlendMode("ADD")

  btn:SetScript("OnClick", function()
    binding.reset()
    ctx.onChanged()
  end)
  btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip_SetTitle(GameTooltip, L["Reset"])
    GameTooltip_AddNormalLine(GameTooltip,
      L["Reset to global default"] .. ": " .. tostring(binding.defaultDisplay()), true)
    GameTooltip_AddNormalLine(GameTooltip,
      L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"], true)
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", GameTooltip_Hide)

  -- rowEnabled: the gate state of the whole row (a reset makes no sense while
  -- the group is off or the value is already at the default).
  function btn.Refresh(rowEnabled)
    local enabled = rowEnabled and not binding.isDefault()
    btn:SetEnabled(enabled)
    btn:GetNormalTexture():SetDesaturated(not enabled)
    btn:SetAlpha(enabled and 1 or 0.5)
  end

  return btn
end


-- ===== Zoom-based curve control =====

-- Checkbox (curve on/off) + gear (curve editor), replacing the old AceGUI
-- widget. Registers itself with the curve editor's widget registry, which
-- expects .isEditorOpen and :UpdateButtonTextures() on each instance.
local function CreateZoomBasedControl(row, item, ctx)
  local cvar = item.cvar
  local range = DynamicCam.cvarRanges[cvar]

  -- ZOOM_CTRL_HEIGHT is tall enough to give the caption room above the pair:
  -- ctrl is anchored by RIGHT (a frame's vertical-middle point), so growing it
  -- adds clearance symmetrically above and below the pair rather than shifting
  -- the pair. ZOOM_CTRL_Y then slides the whole column down as one, far enough
  -- that the caption clears the row above instead of bleeding into it.
  local ctrl = CreateFrame("Frame", nil, row)
  ctrl:SetSize(ZOOM_ZONE, ZOOM_CTRL_HEIGHT)
  ctrl:SetPoint("RIGHT", row, "RIGHT", -RIGHT_PAD, ZOOM_CTRL_Y)

  -- Checkbox + gear pair on ctrl's vertical center, so the two constants above
  -- are the only things deciding where it sits relative to the slider.
  local check = CreateFrame("CheckButton", nil, ctrl, "UICheckButtonTemplate")
  check:SetSize(24, 24)
  check:SetPoint("LEFT", ctrl, "LEFT", (ZOOM_ZONE - ZOOM_PAIR_WIDTH) / 2, 0)

  -- The gear sits 2.5px lower than the checkbox center: the checkbox art has a
  -- baked-in bottom shadow, so a plain center alignment LOOKS off (same offset
  -- the old widget used).
  local gear = CreateFrame("Button", nil, ctrl)
  gear:SetSize(23, 23)
  gear:SetPoint("LEFT", check, "RIGHT", 2, -2.5)
  gear:SetNormalTexture(GEAR_TEX)
  gear:GetNormalTexture():SetTexCoord(unpack(GEAR_NORMAL))
  gear:SetPushedTexture(GEAR_TEX)
  gear:GetPushedTexture():SetTexCoord(unpack(GEAR_PRESSED))
  gear:SetHighlightTexture(GEAR_TEX)
  gear:GetHighlightTexture():SetTexCoord(unpack(GEAR_HL_NORMAL))
  gear:GetHighlightTexture():SetBlendMode("BLEND")
  gear:SetDisabledTexture(GEAR_TEX)
  gear:GetDisabledTexture():SetTexCoord(0, 0.21093750, 0, 0.421875)

  -- Caption above the pair, like the old widget: without it the two unlabeled
  -- icons are hard to read. The column is sized to the caption, so it never
  -- truncates.
  ctrl.caption = ctrl:CreateFontString(nil, "ARTWORK", ZOOM_CAPTION_FONT)
  ctrl.caption:SetPoint("TOP", ctrl, "TOP", 0, 0)
  ctrl.caption:SetWordWrap(false)
  ctrl.caption:SetText(L["Zoom-based"])

  -- The tooltip lives on the label, not the controls (checkbox/gear keep only
  -- their click handlers): a FontString can't take OnEnter/OnLeave itself, so a
  -- mouse-enabled hitbox frame is sized to it.
  local captionHit = CreateFrame("Frame", nil, ctrl)
  captionHit:SetAllPoints(ctrl.caption)
  captionHit:EnableMouse(true)
  captionHit:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip_SetTitle(GameTooltip, L["Zoom-based"])
    GameTooltip_AddNormalLine(GameTooltip, L["<zoomBased_desc>"], true)
    GameTooltip:Show()
  end)
  captionHit:SetScript("OnLeave", GameTooltip_Hide)

  ctrl.isEditorOpen = false

  function ctrl:UpdateButtonTextures()
    if self.isEditorOpen then
      gear:GetNormalTexture():SetTexCoord(unpack(GEAR_PRESSED))
      gear:GetHighlightTexture():SetTexCoord(unpack(GEAR_HL_PRESSED))
    else
      gear:GetNormalTexture():SetTexCoord(unpack(GEAR_NORMAL))
      gear:GetHighlightTexture():SetTexCoord(unpack(GEAR_HL_NORMAL))
    end
  end

  -- Register with the curve editor, so it can sync the gear's pressed state
  -- when the editor opens/closes (also from another instance of this setting).
  -- The registry is keyed by situation+cvar, and a situation page can retarget
  -- to another situation (ctx.sid changes) - so registration is re-derived on
  -- every Refresh rather than fixed at build.
  DynamicCam._activeZoomWidgets = DynamicCam._activeZoomWidgets or {}
  local registry = DynamicCam._activeZoomWidgets

  local function UpdateRegistration()
    local configId = (ctx.sid or "standard") .. "_" .. cvar
    if ctrl.configId == configId then return end
    if ctrl.configId and registry[ctrl.configId] then
      registry[ctrl.configId][ctrl] = nil
    end
    ctrl.configId = configId
    registry[configId] = registry[configId] or {}
    registry[configId][ctrl] = true
  end

  check:SetScript("OnClick", function(self)
    local checked = self:GetChecked()
    local currentValue = DynamicCam:GetSettingsValue(ctx.sid, "cvars", cvar)
    DynamicCam:SetCvarZoomBased(ctx.sid, cvar, checked, currentValue)
    if not checked then
      DynamicCam:CloseCurveEditor(ctx.sid, cvar)
    end
    PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    ctx.onChanged()
  end)

  gear:SetScript("OnClick", function()
    if ctrl.isEditorOpen then
      DynamicCam:CloseCurveEditor(ctx.sid, cvar)
    else
      ctrl.isEditorOpen = true
      ctrl:UpdateButtonTextures()
      DynamicCam:OpenCurveEditor(ctx.sid, cvar, range.min, range.max, ctrl)
    end
  end)

  -- rowEnabled: the gate state of the row (e.g. pitch disabled entirely).
  function ctrl.Refresh(rowEnabled)
    UpdateRegistration()
    -- Pull the gear's pressed state: the editor pushes changes to registered
    -- widgets, but a situation switch retargets this widget to a different
    -- setting entirely, whose editor may or may not be open right now.
    ctrl.isEditorOpen = DynamicCam:IsEditorOpenForSetting(ctx.sid, cvar)
    ctrl:UpdateButtonTextures()

    -- The EFFECTIVE state, so a situation row that does not override this cvar
    -- shows the standard setting's curve being ticked, just as its slider shows
    -- the standard setting's value. Where the situation does own the cvar this
    -- is its own state, and on the standard page the two are the same thing.
    local zoomBased = DynamicCam:IsEffectivelyCvarZoomBased(ctx.sid, cvar)
    check:SetChecked(zoomBased)
    check:SetEnabled(rowEnabled)
    check:SetAlpha(rowEnabled and 1 or 0.5)
    gear:SetEnabled(rowEnabled and zoomBased)
    if rowEnabled then
      ctrl.caption:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
    else
      ctrl.caption:SetTextColor(GRAY_FONT_COLOR:GetRGB())
    end
  end

  return ctrl
end


-- ===== Slider row =====

function Controls.CreateSliderRow(parent, item, ctx)
  local row = NewRow(parent)
  row.label:SetText(item.label)
  AddRowTooltip(row, item, ctx)

  local binding = MakeBinding(item, ctx)

  local resetBtn = binding.reset and CreateResetButton(row, binding, ctx)
  local zoomCtrl = item.zoomBased and CreateZoomBasedControl(row, item, ctx)

  local zoomZone = ctx.zoomZone or ZOOM_ZONE
  local widget = CreateFrame("Frame", nil, row, "MinimalSliderWithSteppersTemplate")
  widget:SetHeight(20)
  widget:SetPoint("LEFT", row.label, "RIGHT", CONTROL_GAP, 0)
  widget:SetPoint("RIGHT", row, "RIGHT", -SliderOffset(zoomZone), 0)

  local minVal, maxVal, step = item.min, item.max, item.step
  local steps = (maxVal - minVal) / step
  local decimals = 0
  do local frac = tostring(step):match("%.(%d+)"); if frac then decimals = #frac end end

  -- Snap a value to the step grid, formatted with as many decimals as the step.
  local function Snap(v)
    v = minVal + math.floor((v - minVal) / step + 0.5) * step
    if decimals == 0 then return math.floor(v + 0.5) end
    return tonumber(("%." .. decimals .. "f"):format(v))
  end

  local formatters = {
    [MinimalSliderWithSteppersMixin.Label.Right] = function(value)
      if decimals > 0 then return ("%." .. decimals .. "f"):format(Snap(value)) end
      return tostring(Snap(value))
    end,
  }

  -- Init wires its OnValueChanged after the initial SetValue, so this does not
  -- echo back into the binding.
  widget:Init(binding.get() or minVal, minVal, maxVal, steps, formatters)

  -- Give the readout its own column, overriding the template's anchor (which
  -- hangs it off the slider bar at a fixed distance, ignoring our layout). The
  -- number is centred in that column, as in Graphit, so it stays put as its
  -- width changes with the digit count instead of twitching on every step.
  local rt = widget.RightText
  rt:ClearAllPoints()
  rt:SetPoint("RIGHT", row, "RIGHT", -ReadoutOffset(zoomZone), 0)
  rt:SetWidth(READOUT_WIDTH)
  rt:SetJustifyH("CENTER")

  -- The template sets a value step but never SetObeyStepOnDrag, so a drag
  -- reports CONTINUOUS values - many events per step, most of which snap to the
  -- value we already stored. Acting on those would write and re-apply dozens of
  -- times a second (which tore a live camera rotation apart) and refresh the
  -- whole page each time. So act only when the snapped value really moves.
  local refreshing = false
  local shownValue = binding.get() or minVal   -- correct from frame one
  widget:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
    if refreshing then return end
    local snapped = Snap(value)
    if snapped == shownValue then return end
    shownValue = snapped
    binding.set(snapped)
    ctx.onChanged()
  end, row)

  function row.Refresh()
    local enabled = RowEnabled(row, item, ctx)
    -- Effective, matching the zoom control's own display (see its Refresh).
    local zoomBased = item.zoomBased and DynamicCam:IsEffectivelyCvarZoomBased(ctx.sid, item.cvar)

    refreshing = true
    shownValue = binding.get() or minVal
    widget:SetValue(shownValue)
    widget:FormatValue(widget.Slider:GetValue())
    refreshing = false

    -- A zoom-based setting is driven by its curve, so neither the slider nor
    -- its reset button applies; the zoom control itself stays live, or there
    -- would be no way to switch the curve back off.
    widget:SetEnabled(enabled and not zoomBased)
    SetLabelEnabled(row, enabled)
    if resetBtn then resetBtn.Refresh(enabled and not zoomBased) end
    if zoomCtrl then zoomCtrl.Refresh(enabled) end
  end
  row.Refresh()

  return row
end


-- ===== Checkbox row =====

function Controls.CreateCheckboxRow(parent, item, ctx)
  local row = NewRow(parent)
  row.label:SetText(item.label)
  AddRowTooltip(row, item, ctx)

  local binding = MakeBinding(item, ctx)

  local check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
  check:SetSize(28, 28)
  check:SetPoint("LEFT", row.label, "RIGHT", CONTROL_GAP, 0)

  local function GetChecked()
    local v = binding.get()
    if item.cvarBool then return v == 1 end
    return v and true or false
  end

  check:SetScript("OnClick", function(self)
    local checked = self:GetChecked()
    if item.cvarBool then
      binding.set(checked and 1 or 0)
    else
      binding.set(checked)
    end
    PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    ctx.onChanged()
  end)

  function row.Refresh()
    check:SetChecked(GetChecked())
    local enabled = RowEnabled(row, item, ctx)
    check:SetEnabled(enabled)
    SetLabelEnabled(row, enabled)
  end
  row.Refresh()

  return row
end


-- ===== Select row =====

-- A WowStyle2 dropdown flanked by < > stepper buttons, as the Settings panel
-- (and Graphit) present a choice: the steppers walk to the previous/next option
-- and grey out at the ends, and the menu marks the current one in gold rather
-- than with a radio dot. item.options is a list of { value, text }.
function Controls.CreateSelectRow(parent, item, ctx)
  local row = NewRow(parent)
  row.label:SetText(item.label)
  AddRowTooltip(row, item, ctx)

  local binding = MakeBinding(item, ctx)
  local resetBtn = binding.reset and CreateResetButton(row, binding, ctx)

  local dd  = CreateFrame("DropdownButton", nil, row, "WowStyle2DropdownTemplate")
  local dec = CreateFrame("Button", nil, row, "WowStyle2IconButtonTemplate")
  local inc = CreateFrame("Button", nil, row, "WowStyle2IconButtonTemplate")

  local zoomZone = ctx.zoomZone or ZOOM_ZONE
  dec:SetPoint("LEFT", row.label, "RIGHT", CONTROL_GAP, 0)
  inc:SetPoint("RIGHT", row, "RIGHT", -(ReadoutOffset(zoomZone) + SELECT_RESET_GAP), 0)
  dd:SetPoint("LEFT", dec, "RIGHT", SELECT_STEPPER_GAP, 0)
  dd:SetPoint("RIGHT", inc, "LEFT", -SELECT_STEPPER_GAP, 0)

  dec.normalAtlas, dec.disabledAtlas = "common-dropdown-icon-back", "common-dropdown-icon-back-disabled"
  inc.normalAtlas, inc.disabledAtlas = "common-dropdown-icon-next", "common-dropdown-icon-next-disabled"
  dec:OnButtonStateChanged()
  inc:OnButtonStateChanged()

  -- The button's text. Greyed with a flat disabled colour while the row is off,
  -- matching the label and the steppers rather than fading the whole control.
  local rowEnabled = true
  dd:SetSelectionText(function(selections)
    local sel = selections and selections[1]
    local text
    if sel then
      text = MenuUtil.GetElementText(sel)
    else
      -- Nothing in the list matches the stored value: show it raw rather than
      -- leaving the button blank.
      local current = binding.get()
      text = (current ~= nil and current ~= "") and tostring(current) or nil
    end
    if text and not rowEnabled then
      text = DISABLED_FONT_COLOR:WrapTextInColorCode(text)
    end
    return text
  end)

  dd:SetupMenu(function(_, rootDescription)
    for _, opt in ipairs(item.options) do
      -- CreateHighlightRadio (not CreateRadio) is what the Settings panel uses:
      -- the selected entry in gold text, with no radio dot.
      rootDescription:CreateHighlightRadio(opt.text,
        function() return tostring(binding.get()) == tostring(opt.value) end,
        function()
          binding.set(opt.value)
          ctx.onChanged()
        end)
    end
  end)

  -- A stepper greys out at its end of the list, and both die with the row.
  -- dd:Increment/Decrement do NOT fire OnUpdate, so refresh after those too.
  local function UpdateSteppers()
    local previousRadio, nextRadio = dd:CollectSelectionData()
    dec:SetEnabled(rowEnabled and previousRadio ~= nil)
    inc:SetEnabled(rowEnabled and nextRadio ~= nil)
  end

  -- No ctx.onChanged here: Increment/Decrement go through Pick, which fires the
  -- picked option's own responder - and that already writes and refreshes.
  local function Step(fn)
    fn(dd)
    UpdateSteppers()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
  end
  dec:SetScript("OnClick", function() Step(dd.Decrement) end)
  inc:SetScript("OnClick", function() Step(dd.Increment) end)

  dd:RegisterCallback(DropdownButtonMixin.Event.OnUpdate, UpdateSteppers, dd)

  -- Keep the motion scripts alive while disabled, as Blizzard's own disabled
  -- controls do, so the row's tooltip still works over a greyed dropdown.
  dd:SetMotionScriptsWhileDisabled(true)

  function row.Refresh()
    rowEnabled = RowEnabled(row, item, ctx)
    dd:SetEnabled(rowEnabled)
    SetLabelEnabled(row, rowEnabled)
    -- SetupMenu defers generating until the dropdown is first shown, and these
    -- rows are built hidden - so make sure there is a description to collect
    -- the selection from before asking for one.
    if not dd:HasElements() then dd:GenerateMenu() end
    dd:SignalUpdate()      -- re-reads the binding and repaints the button text
    UpdateSteppers()
    if resetBtn then resetBtn.Refresh(rowEnabled) end
  end
  row.Refresh()

  return row
end


-- ===== Input row =====

-- A free-text box on InputScrollFrameTemplate - the Settings panel's own
-- multi-line input, which the macro editor uses too. It brings its border art,
-- its scroll bar and an edit box already wired for scrolling; item.lines sets
-- how many lines are visible.
--
-- The value is committed when the box loses focus (Enter inserts a newline, the
-- box being multi-line). Escape reverts to the stored value, so a half-typed
-- edit can always be abandoned.
function Controls.CreateInputRow(parent, item, ctx)
  local row = NewRow(parent)
  -- Always a scrolling multi-line box: the template's edit box is multiLine, and
  -- the lists these hold are far too long for one line anyway.
  local lines = math.max(item.lines or INPUT_MIN_LINES, INPUT_MIN_LINES)
  -- Before AddRowTooltip, which sizes its hit rect from the row's height.
  row:SetHeight(math.max(Controls.ROW_HEIGHT,
    lines * INPUT_LINE_HEIGHT + 2 * INPUT_BORDER_INSET + INPUT_ROW_PAD))
  row.label:SetText(item.label)
  AddRowTooltip(row, item, ctx)

  local binding = MakeBinding(item, ctx)
  local resetBtn = binding.reset and CreateResetButton(row, binding, ctx)

  -- The Settings panel's own multi-line input (as the macro editor uses): it
  -- brings its border, its scroll bar, and an edit box already wired to the
  -- ScrollingEdit_* handlers that keep the text scrolling inside a fixed height.
  local zoomZone = ctx.zoomZone or ZOOM_ZONE
  local scroll = CreateFrame("ScrollFrame", nil, row, "InputScrollFrameTemplate")
  scroll:SetPoint("LEFT", row.label, "RIGHT", CONTROL_GAP + INPUT_BORDER_INSET, 0)
  scroll:SetPoint("RIGHT", row, "RIGHT",
    -(ReadoutOffset(zoomZone) + SELECT_RESET_GAP + INPUT_BORDER_INSET), 0)
  scroll:SetHeight(lines * INPUT_LINE_HEIGHT)
  scroll.CharCount:Hide()   -- a letter count means nothing for a frame list

  local edit = scroll.EditBox
  edit:SetFontObject(ChatFontNormal)
  -- OnLoad did this once against a width we had not set yet.
  scroll:HookScript("OnSizeChanged", function(self, width)
    edit:SetWidth(width - INPUT_BAR_CHANNEL)
  end)

  local function Revert()
    edit:SetText(binding.get() or "")
    edit:SetCursorPosition(0)
  end

  local function Commit()
    local value = edit:GetText()
    if value ~= (binding.get() or "") then
      binding.set(value)
      ctx.onChanged()
    end
    -- Re-read: the setter may normalise what it stored (dropping whitespace,
    -- reordering a list), and the box should show what was actually kept.
    Revert()
  end

  -- Only these two are ours; the template's own OnTextChanged / OnUpdate /
  -- OnCursorChanged are what do the scrolling and must stay untouched.
  edit:SetScript("OnEditFocusLost", Commit)
  edit:SetScript("OnEscapePressed", function(self)
    Revert()
    self:ClearFocus()
  end)

  function row.Refresh()
    local enabled = RowEnabled(row, item, ctx)
    edit:SetEnabled(enabled)
    edit:SetTextColor((enabled and HIGHLIGHT_FONT_COLOR or GRAY_FONT_COLOR):GetRGB())
    SetLabelEnabled(row, enabled)
    -- Never yank the text out from under someone mid-edit; the commit that ends
    -- the edit refreshes it anyway.
    if not edit:HasFocus() then Revert() end
    if resetBtn then resetBtn.Refresh(enabled) end
  end
  row.Refresh()

  return row
end


-- ===== Button row =====

-- A row whose control performs an action instead of holding a value, so it has
-- no binding and no reset button. item.onClick(sid) does the work.
function Controls.CreateButtonRow(parent, item, ctx)
  local row = NewRow(parent)
  row.label:SetText(item.label)
  AddRowTooltip(row, item, ctx)

  local btn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
  btn:SetSize(ACTION_BUTTON_WIDTH, ACTION_BUTTON_HEIGHT)
  btn:SetPoint("LEFT", row.label, "RIGHT", CONTROL_GAP, 0)
  btn:SetText(item.buttonText or item.label)
  btn:SetScript("OnClick", function()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    item.onClick(ctx.sid)
    ctx.onChanged()
  end)

  function row.Refresh()
    local enabled = RowEnabled(row, item, ctx)
    btn:SetEnabled(enabled)
    SetLabelEnabled(row, enabled)
  end
  row.Refresh()

  return row
end


-- ===== Header and note rows =====

-- A category heading: white text hung below the row's top, the optional
-- override checkbox (item.overrideToggle, situation pages), the optional info
-- "i" (item.info), and the optional state toggle (item.toggle). The category
-- separator line above the heading is added and positioned by the page (it also
-- has to sit above the override banner when one is showing), not here.
function Controls.CreateHeaderRow(parent, item, ctx)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(Controls.HEADER_HEIGHT)

  -- White, like the Settings panel's (and Graphit's) section headers.
  -- Left-aligned with the setting rows' labels, and hung from the row's top so
  -- it keeps its distance below the divider no matter how tall the row is. On a
  -- situation page it starts further right, leaving the row's left end to the
  -- override checkbox.
  local labelLeft = LABEL_LEFT_PAD
  if item.overrideToggle then
    labelLeft = labelLeft + HEADER_CHECK_SIZE + HEADER_CHECK_GAP
  end

  row.label = row:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  row.label:SetPoint("TOPLEFT", row, "TOPLEFT", labelLeft, -HEADER_TEXT_TOP)
  row.label:SetTextColor(WHITE_FONT_COLOR:GetRGB())
  row.label:SetText(item.label)

  -- The situation page's per-category override checkbox, left of the heading.
  -- It is the gate the rows below are gated BY, so it is never gated itself;
  -- row.Refresh keeps it current, since the override state can also change from
  -- outside (the old frame, an import).
  if item.overrideToggle then
    local check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    check:SetSize(HEADER_CHECK_SIZE, HEADER_CHECK_SIZE)
    check:SetPoint("TOPLEFT", row, "TOPLEFT", LABEL_LEFT_PAD, -HEADER_CHECK_Y)

    check:SetScript("OnClick", function(self)
      local checked = self:GetChecked()
      PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
      item.overrideToggle.set(checked)
      ctx.onChanged()
    end)
    check:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip_SetTitle(GameTooltip, L["Override Standard Settings"])
      GameTooltip_AddNormalLine(GameTooltip, L["<overrideStandardToggle_desc>"], true)
      GameTooltip:Show()
    end)
    check:SetScript("OnLeave", GameTooltip_Hide)

    function row.Refresh()
      check:SetChecked(item.overrideToggle.get())
    end
    row.Refresh()
  end

  -- Info "i" right of the title, showing the category's help text as a tooltip
  -- (as in Graphit): hover-only, no click, no sound.
  if item.info then
    local btn = CreateFrame("Button", nil, row)
    btn:SetSize(30, 30)
    -- Directly right of the title so it tracks the title's length; the -8 drops
    -- the icon level with the title text. No hover glow: it would suggest a
    -- click that does nothing.
    btn:SetPoint("BOTTOMLEFT", row.label, "BOTTOMRIGHT", 0, -8)
    btn:SetNormalTexture("Interface\\common\\help-i")
    btn:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip_SetTitle(GameTooltip, item.label)
      GameTooltip_AddNormalLine(GameTooltip, item.info, true)
      GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)
  end

  -- Optional state toggle at the header's right edge (Reactive Zoom's visual
  -- aid). Its art shows whether the target frame is currently open, so it has
  -- to follow that frame rather than its own clicks - the frame can also be
  -- closed on its own, and the old UI can toggle it too. There is no event for
  -- that, so it polls, like the row hover does.
  --
  -- It is bigger than the header row and deliberately FLOATS: the row keeps its
  -- normal height and the button just overhangs the rows beneath it, so its
  -- size never shifts the layout. That needs a raised frame level, because the
  -- rows below are created later and would otherwise draw over it.
  if item.toggle then
    local toggle = item.toggle
    local btn = CreateFrame("Button", nil, row)
    btn:SetSize(HEADER_TOGGLE_SIZE, HEADER_TOGGLE_SIZE)
    btn:SetPoint("TOPRIGHT", row, "TOPRIGHT", HEADER_TOGGLE_X, HEADER_TOGGLE_Y)
    btn:SetFrameLevel(row:GetFrameLevel() + 20)
    btn:SetScript("OnClick", function()
      PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
      toggle.onClick()
    end)
    if toggle.tooltip then
      btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip, toggle.title or item.label)
        GameTooltip_AddNormalLine(GameTooltip, toggle.tooltip, true)
        GameTooltip:Show()
      end)
      btn:SetScript("OnLeave", GameTooltip_Hide)
    end

    -- nil until the first sync, so that pass always applies the atlases.
    local shownState
    local function SyncToggle()
      local on = toggle.isOn()
      if on == shownState then return end
      shownState = on
      -- The art shows the ACTION, not the current state: while the target is
      -- open the button offers to hide it (VisibilityOff), and while it is
      -- closed the button offers to show it (VisibilityOn). Hence the inverse.
      local base = "128-RedButton-Visibility" .. (on and "Off" or "On")
      btn:SetNormalAtlas(base)
      btn:SetPushedAtlas(base .. "-Pressed")
      btn:SetHighlightAtlas(base .. "-Highlight", "ADD")   -- glow over the art
    end
    SyncToggle()
    btn:SetScript("OnUpdate", SyncToggle)
  end

  return row
end

-- A note: a whole paragraph rather than a one-liner, so it is left-aligned with
-- the setting labels and wraps to the row's width, and its row grows to fit.
--
-- The font is the NORMAL small one, not a red one: these strings carry their own
-- colouring (usually just a red "Attention:"/"WARNING:" lead), and a red font
-- object would swallow it - |r resets to the FontString's own colour, so with a
-- red base every character after the lead would stay red too.
--
-- item.text may be a function, for a note whose wording depends on the current
-- state; it is then re-evaluated on every Refresh. A note has no control to
-- disable, so its enabledWhen fades the text instead - it stays readable and
-- in place, which is the point of a warning.
function Controls.CreateNoteRow(parent, item, ctx)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(Controls.ROW_HEIGHT)   -- until the first MeasureHeight

  row.text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  row.text:SetPoint("TOPLEFT", row, "TOPLEFT", LABEL_LEFT_PAD, -NOTE_TOP_PAD)
  row.text:SetPoint("RIGHT", row, "RIGHT", -RIGHT_PAD, 0)
  row.text:SetJustifyH("LEFT")
  row.text:SetWordWrap(true)

  local dynamic = type(item.text) == "function"
  row.text:SetText(dynamic and item.text(ctx.sid) or item.text)

  function row.Refresh()
    if dynamic then row.text:SetText(item.text(ctx.sid)) end
    row.text:SetAlpha(RowEnabled(row, item, ctx) and 1 or NOTE_DISABLED_ALPHA)
  end
  row.Refresh()

  -- Only the page knows the row's width (it anchors it), so the wrapped height
  -- can be measured only once that has happened - hence a hook, not a size set
  -- here. See Relayout in Ui/SettingsPage.lua.
  function row.MeasureHeight()
    return math.ceil(row.text:GetStringHeight()) + NOTE_TOP_PAD + NOTE_BOTTOM_PAD
  end

  return row
end


-- ===== Dispatch =====

function Controls.CreateRow(parent, item, ctx)
  local row
  if item.kind == "slider" then row = Controls.CreateSliderRow(parent, item, ctx) end
  if item.kind == "checkbox" then row = Controls.CreateCheckboxRow(parent, item, ctx) end
  if item.kind == "select" then row = Controls.CreateSelectRow(parent, item, ctx) end
  if item.kind == "input" then row = Controls.CreateInputRow(parent, item, ctx) end
  if item.kind == "button" then row = Controls.CreateButtonRow(parent, item, ctx) end
  if item.kind == "header" then row = Controls.CreateHeaderRow(parent, item, ctx) end
  if item.kind == "note" then row = Controls.CreateNoteRow(parent, item, ctx) end

  -- Conditional visibility applies to every kind, not just notes: a slider
  -- that only makes sense for one zoom type is hidden rather than greyed. The
  -- page calls this with no arguments, so bind the situation here.
  if row and item.shownWhen then
    row.ShouldShow = function() return item.shownWhen(ctx.sid) end
  end
  return row
end
