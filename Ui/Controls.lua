-------------------------------------------------------------------------------
-- DynamicCam new settings UI - row factories.
--
-- Renders the descriptor items (Ui/Descriptor.lua) as Settings-panel-style rows:
-- label on the left, a modern control on the right (MinimalSliderWithSteppers,
-- UICheckButton), plus DynamicCam's per-setting reset button and the zoom-based
-- curve control (checkbox + gear opening the curve editor).
--
-- Every factory takes (parent, item, ctx) and returns a row frame. ctx carries:
--   sid        situationId the page edits (nil = standard settings)
--   onChanged  called after any write, so the page can refresh gated rows
-- Rows expose row.Refresh() (re-read the binding, apply enable state) and may
-- set row.ShouldShow() (conditional note rows).
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
local LABEL_LEFT_PAD   = 8     -- row edge -> label
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
local RIGHT_PAD        = 6     -- last column -> row edge

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
local HEADER_TOGGLE_X    = 0
local HEADER_TOGGLE_Y    = -8

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
-- so a local copy ships in the addon's BLP folder.
local GEAR_TEX = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
  and "Interface\\Common\\CommonDropdownSettings2x"
  or  "Interface\\AddOns\\" .. folderName .. "\\BLP\\commondropdownsettings2x"
local GEAR_NORMAL    = {0.21875, 0.43750, 0.00000, 0.43750}
local GEAR_PRESSED   = {0.21875, 0.43750, 0.43750, 0.87500}
local GEAR_HL_NORMAL = {0.00000, 0.21875, 0.43750, 0.87500}
local GEAR_HL_PRESSED= {0.43750, 0.65625, 0.00000, 0.43750}


-- ===== Binding =====

-- Wraps a descriptor item into display-space get/set plus reset handling.
-- All slider math happens in display space; toDisplay/fromDisplay convert
-- from/to the stored value, and minClampZero maps the cvar's real minimum
-- (e.g. 0.01 damp rate) to a clean 0 on the slider.
local function MakeBinding(item, sid)
  local p1, p2 = item.dbPath and item.dbPath[1], item.dbPath and item.dbPath[2]

  local function rawGet()
    if item.get then return item.get() end
    return DynamicCam:GetSettingsValue(sid, p1, p2)
  end

  local function rawSet(v)
    if item.set then item.set(v) return end
    DynamicCam:SetSettingsValue(v, sid, p1, p2)
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

  if item.dbPath and not item.get then
    function binding.isDefault()
      return DynamicCam:GetSettingsValue(sid, p1, p2) == DynamicCam:GetSettingsDefault(p1, p2)
    end
    function binding.reset()
      DynamicCam:SetSettingsDefault(sid, p1, p2)
    end
    function binding.defaultDisplay()
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

-- Tooltip on the row's NAME only (title, optional body, optional grey cvar
-- note), as in the Settings panel and Graphit: hovering the controls to the
-- right shows nothing, so the tooltip does not follow the cursor across the
-- whole row. A FontString takes no mouse, so the trigger is a button spanning
-- the label's width across the full row height, lining up with the row's hover
-- highlight (the label is vertically centred, hence the half-height reach).
local function AddRowTooltip(row, item)
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
    if item.tooltip then
      GameTooltip_AddNormalLine(GameTooltip, item.tooltip, true)
    end
    if item.cvar then
      GameTooltip_AddDisabledLine(GameTooltip, "cvar: " .. item.cvar, true)
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


-- ===== Reset button =====

-- The per-setting reset-to-default button, right of the value readout.
-- Disabled (desaturated) while the setting is at its default.
local function CreateResetButton(row, item, binding, ctx)
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
  local configId = (ctx.sid or "standard") .. "_" .. cvar
  ctrl.configId = configId
  DynamicCam._activeZoomWidgets = DynamicCam._activeZoomWidgets or {}
  DynamicCam._activeZoomWidgets[configId] = DynamicCam._activeZoomWidgets[configId] or {}
  DynamicCam._activeZoomWidgets[configId][ctrl] = true

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
    local zoomBased = DynamicCam:IsCvarZoomBased(ctx.sid, cvar)
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
  AddRowTooltip(row, item)

  local binding = MakeBinding(item, ctx.sid)

  local resetBtn = binding.reset and CreateResetButton(row, item, binding, ctx)
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

  local refreshing = false
  widget:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, value)
    if refreshing then return end
    binding.set(Snap(value))
    ctx.onChanged()
  end, row)

  function row.Refresh()
    local enabled = not item.enabledWhen or item.enabledWhen(ctx.sid)
    local zoomBased = item.zoomBased and DynamicCam:IsCvarZoomBased(ctx.sid, item.cvar)

    refreshing = true
    widget:SetValue(binding.get() or minVal)
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
  AddRowTooltip(row, item)

  local binding = MakeBinding(item, ctx.sid)

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
    local enabled = not item.enabledWhen or item.enabledWhen(ctx.sid)
    check:SetEnabled(enabled)
    SetLabelEnabled(row, enabled)
  end
  row.Refresh()

  return row
end


-- ===== Header and note rows =====

-- A category heading: white text hung below the row's top, the optional info
-- "i" (item.info), the optional state toggle (item.toggle), and a divider line
-- across the top which the page shows or hides via row.lineAbove (none above
-- the very first category).
function Controls.CreateHeaderRow(parent, item)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(Controls.HEADER_HEIGHT)

  -- White, like the Settings panel's (and Graphit's) section headers.
  -- Left-aligned with the setting rows' labels, and hung from the row's top so
  -- it keeps its distance below the divider no matter how tall the row is.
  row.label = row:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  row.label:SetPoint("TOPLEFT", row, "TOPLEFT", LABEL_LEFT_PAD, -HEADER_TEXT_TOP)
  row.label:SetTextColor(WHITE_FONT_COLOR:GetRGB())
  row.label:SetText(item.label)

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

  row.line = row:CreateTexture(nil, "ARTWORK")
  row.line:SetColorTexture(1, 1, 1, 0.15)
  row.line:SetHeight(1)
  row.line:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -4)
  row.line:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -4)

  return row
end

function Controls.CreateNoteRow(parent, item)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(22)
  row.text = row:CreateFontString(nil, "ARTWORK", "GameFontRedSmall")
  row.text:SetPoint("LEFT", row, "LEFT", 8, 0)
  row.text:SetText(item.text)
  row.ShouldShow = item.shownWhen
  return row
end


-- ===== Dispatch =====

function Controls.CreateRow(parent, item, ctx)
  if item.kind == "slider" then return Controls.CreateSliderRow(parent, item, ctx) end
  if item.kind == "checkbox" then return Controls.CreateCheckboxRow(parent, item, ctx) end
  if item.kind == "header" then return Controls.CreateHeaderRow(parent, item) end
  if item.kind == "note" then return Controls.CreateNoteRow(parent, item) end
end
