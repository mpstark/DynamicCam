-------------------------------------------------------------------------------
-- DynamicCam new settings UI - Situations tab.
--
-- Top strip (always visible): Import and Export buttons at the left, the
-- situation selector filling the middle, and the selected situation's Enable
-- checkbox at the right. The selector is a modern dropdown modeled on Graphit's
-- preset dropdown, with a per-row enable/disable checkbox, rename and delete for
-- custom situations, and a "New Situation" entry at the bottom.
--
-- Below the strip, an inner tab row (Situation Settings / Actions / Controls)
-- and a second nine-slice box holding their pages - the same construction the
-- window itself uses, one level in. Situation Settings is Ui/SettingsPage.lua's
-- page in situation mode, i.e. literally the Standard Settings tab's content
-- plus the override layer; the other two are still to come, as is the window
-- the Import and Export buttons will open.
-------------------------------------------------------------------------------

local folderName = ...
local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)
local Ui = DynamicCam.Ui
local GetConfig = Ui.GetConfig   -- shared db.global.newUi accessor (Ui/Window.lua)

local sc = DynamicCam.situationColors


-- ===== Layout: the top strip =====

-- The page's left and right margin, shared by everything in it: the top strip
-- (hence the Import button's distance from the page's left edge) and the box
-- below it. One constant, so the button and the box border cannot drift out of
-- line with each other.
local SIDE_INSET = 6

-- The strip is one row: the Import/Export buttons at the left, the Enabled
-- checkbox at the right, and the situation dropdown filling whatever is left
-- between them - so it grows and shrinks with the window while the two fixed
-- blocks keep their size. Every block hangs from the strip's top edge, so
-- STRIP_Y moves the row as a whole.
local STRIP_Y = 8

-- The Import/Export art buttons, the strip's left block. Each file holds the
-- four button states in a 2x2 grid of 128x128 quadrants, laid out like
-- Blizzard's 128-redbutton art kits: normal top-left, pressed top-right,
-- disabled bottom-left, and the additive hover glow bottom-right. The art is
-- square, hence one size.
local BUTTON_FILE_IMPORT = "Interface\\AddOns\\" .. folderName .. "\\Ui\\Textures\\import-button.png"
local BUTTON_FILE_EXPORT = "Interface\\AddOns\\" .. folderName .. "\\Ui\\Textures\\export-button.png"
local BUTTON_QUADRANT = {
  normal    = {0,   0.5, 0,   0.5},
  pushed    = {0.5, 1,   0,   0.5},
  disabled  = {0,   0.5, 0.5, 1  },
  highlight = {0.5, 1,   0.5, 1  },
}
local BUTTON_SIZE = 29
local BUTTON_GAP  = 5   -- between Import and Export

-- The width of that block, which the dropdown's left edge is measured with
-- rather than anchored to the buttons - see the dropdown's anchors.
local BUTTON_BLOCK_WIDTH = 2 * BUTTON_SIZE + BUTTON_GAP

-- The buttons are the tallest block, so they set how much room the row takes.
local STRIP_HEIGHT = BUTTON_SIZE

-- The situation dropdown, filling the middle. DROPDOWN_Y is its offset below the
-- strip's top, the one adjustment between it and the buttons (which sit flush at
-- the top); the Enabled checkbox is centred on the dropdown and follows along.
local DROPDOWN_GAP_LEFT  = 8    -- dropdown to the Export button
local DROPDOWN_GAP_RIGHT = 8    -- dropdown to the Enabled checkbox
local DROPDOWN_Y         = 1.5

-- The Enabled checkbox for the selected situation, the strip's right block. It
-- is a fixed width, so the dropdown's right edge does not jump around as
-- situation names of differing length are selected.
local ENABLE_CHECK_SIZE  = 28
local ENABLE_LABEL_GAP   = 3    -- box to its label
local ENABLE_BLOCK_WIDTH = 100  -- the whole box-plus-label block


-- ===== Layout: the dropdown's menu =====

-- The menu grows with its content and only scrolls when it would run off the
-- screen: it opens below the dropdown with all the room down to the screen
-- bottom as its height cap - unless that room is cramped (below MENU_MIN_HEIGHT),
-- in which case it opens above with the room up to the screen top instead.
-- Deciding the side ourselves (per open, in the menu generator) keeps Blizzard's
-- flip-when-offscreen fallback from kicking in, which would flip a menu above
-- WITHOUT enlarging its too-small below-cap. The margin is what stays clear
-- between menu and screen edge; it also absorbs the menu frame's own insets
-- around the scroll box, which come on top of the cap - were they to push the
-- menu off screen, the flip fallback would trigger after all.
local MENU_SCREEN_MARGIN = 30
local MENU_MIN_HEIGHT    = 200

-- The icons at a menu row's right end, laid out right to left from the row's
-- edge: the enable/disable checkbox (on every row, always visible), then - on
-- custom situations, revealed on row hover - rename and delete.
--
-- The checkbox is the empty box with the check overlaid while enabled. The two
-- atlases are a matched pair drawn at the same size and position, so one size
-- covers both and neither needs a nudge of its own.
local CHECK_ATLAS_BOX   = "checkbox-minimal"
local CHECK_ATLAS_CHECK = "checkmark-minimal"
local CHECK_SIZE        = 18

-- Rename and delete, in Blizzard's own menu-row icons (the same the Edit Mode
-- layout dropdown uses). Each has its own size, since the two textures carry
-- different amounts of padding around their artwork and so do not look equally
-- big at the same size. Whatever the sizes, the icons stay vertically centred in
-- the row and ROW_ICON_GAP stays the air between their edges - it also applies
-- to the checkbox-to-rename step.
local ROW_ICON_RENAME      = MenuVariants.GearButtonTexture
local ROW_ICON_RENAME_SIZE = 18
local ROW_ICON_DELETE      = MenuVariants.CancelButtonTexture
local ROW_ICON_DELETE_SIZE = 15
local ROW_ICON_GAP         = 3


-- ===== Layout: the inner tab row and its box =====

-- The tab row clears the strip by TAB_ROW_GAP, so it follows a resized button
-- rather than having to be re-tuned after one.
local TAB_ROW_GAP    = 8
local TAB_ROW_TOP    = STRIP_Y + STRIP_HEIGHT + TAB_ROW_GAP
local TAB_ROW_HEIGHT = 30    -- as in the main window's tab row
local TAB_Y          = 6     -- gap between tab bottoms and the box's content

-- The nested nine-slice box framing the situation pages, built to the same
-- relations the window's own box and tab row have (see Ui/MainFrame.lua and
-- Ui/Window.lua), so the two read as the same construction:
--
--   * BOX_PAD_* is the air inside the box, between its border and the content -
--     the counterpart of Window.lua's INNER_GAP_*, hence the same defaults.
--   * The tab row sits TAB_Y above the content, and its left and right edges are
--     the content's. With TAB_Y equal to BOX_PAD_TOP, that puts the tab bottoms
--     exactly on the box's top border and insets them from its left border by
--     BOX_PAD_LEFT - which is precisely how the outer tabs meet the outer box.
--
-- What has no outer counterpart is the inner box's breathing space from the outer
-- box's content area (this page). On the sides that is SIDE_INSET, shared with
-- the top strip, so the Import button's left edge and the box's left border are
-- the same line by construction; the bottom is the box's alone.
local BOX_INSET_BOTTOM = 12
local BOX_PAD_LEFT     = 10
local BOX_PAD_RIGHT    = 10
local BOX_PAD_TOP      = 6
local BOX_PAD_BOTTOM   = 6

-- How far the box's top border sits below the page's top, mirroring how the
-- anchors below stack it: down to the content, then back up by the box's own top
-- pad to its border.
local BOX_TOP = TAB_ROW_TOP + TAB_ROW_HEIGHT + TAB_Y - BOX_PAD_TOP

-- Claim the room the box needs, so its nine-slice corners cannot overlap however
-- far the window is shrunk - they draw at native size and would do so silently.
-- Stated as a content-area size, which the window turns into its resize floor;
-- registered at load, before the window is built.
Ui.RequireContentSize(
  2 * SIDE_INSET + Ui.INNER_BOX_MIN_WIDTH,
  BOX_TOP + Ui.INNER_BOX_MIN_HEIGHT + BOX_INSET_BOTTOM)


-- ===== Situations =====

local function Situations() return DynamicCam.db.profile.situations end

-- A displayable situation: exists and is not one of the corrupt entries
-- (missing name or priority) the old UI's list generator purges.
local function ValidSituation(id)
  local situation = id and Situations()[id]
  if situation and situation.name and situation.priority then return situation end
end

-- Session-local, like the old UI's selection: the first open lands on the
-- currently active situation (or the first stock one), and a deleted selection
-- falls back the same way (EnsureSelection runs in the page's poll).
local selectedSID

local function EnsureSelection()
  if ValidSituation(selectedSID) then return end
  selectedSID = DynamicCam.currentSituationID
  if not ValidSituation(selectedSID) then
    local first
    for id in pairs(Situations()) do
      -- Stock ids ("001") sort before custom ones ("custom1").
      if ValidSituation(id) and (not first or id < first) then first = id end
    end
    selectedSID = first
  end
end

-- Stock and custom situation ids as two sorted lists: stock by id (the old
-- UI's order - ids group by rising priority), customs by creation number
-- (plain string sort would put "custom10" before "custom2").
local function SortedSituationIDs()
  local stock, custom = {}, {}
  for id in pairs(Situations()) do
    if ValidSituation(id) then
      if id:find("custom") then
        custom[#custom + 1] = id
      else
        stock[#stock + 1] = id
      end
    end
  end
  table.sort(stock)
  table.sort(custom, function(a, b)
    return (tonumber(a:match("%d+")) or 0) < (tonumber(b:match("%d+")) or 0)
  end)
  return stock, custom
end

-- A situation's list entry: name and priority, coloured by its current state
-- with the same precedence the old UI's list used (Options.GetSituationList),
-- including the "(modified)" suffix for touched stock Situation Controls. Only
-- the old list's "Custom:" prefix is dropped; the divider between the stock
-- and custom blocks conveys that now.
local function SituationText(id)
  local situation = Situations()[id]

  local prefix
  if situation.errorEncountered then
    prefix = sc.error
  elseif DynamicCam.currentSituationID == id then
    prefix = sc.active
  elseif not situation.enabled then
    prefix = sc.disabled
  elseif DynamicCam.conditionExecutionCache[id] then
    prefix = sc.overridden
  else
    prefix = sc.inactive
  end

  local text = prefix .. situation.name ..
    " [" .. L["Priority"] .. ": " .. situation.priority .. "]" .. sc.colorEnd

  -- Old Options module helper; still the one place knowing what "modified" is.
  if not DynamicCam.Options.SituationControlsAreDefault(id) then
    text = text .. sc.modified .. "  " .. L["(modified)"] .. sc.colorEnd
  end
  return text
end

-- Set a situation's enable flag and apply it as the old UI's Enable box did:
-- enabling enters the situation right away if it qualifies, disabling leaves it
-- to the evaluation to hand over to whichever situation takes its place. Shared
-- by the strip's checkbox and the menu rows' own.
local function SetSituationEnabled(id, enabled)
  local situation = ValidSituation(id)
  if not situation then return end
  situation.enabled = enabled
  if enabled then
    DynamicCam:UpdateSituation(id)
  else
    DynamicCam:EvaluateSituations()
  end
end


-- ===== Dialogs =====

-- StaticPopup editbox handlers must work in retail 11.2+ (where the editbox
-- callbacks' self IS the editbox) and in Classic (where self is the dialog);
-- resolving through .editBox/global name with self as fallback covers both, as
-- established by Core.lua's DYNAMICCAM_NEW_CUSTOM_SITUATION.
local function ResolveEditBox(self)
  return self.editBox or _G[self:GetName() .. "EditBox"] or self
end

-- Set in the builder below: repaints the strip and points the settings page at
-- the selected situation. The dialogs call it after they change the selection
-- or a name, which they can only do once the page has been built.
local RefreshTopStrip

local function CreateSituation(name)
  name = strtrim(name or "")
  if name == "" then return end
  local _, newSID = DynamicCam:CreateCustomSituation(name)
  selectedSID = newSID
  RefreshTopStrip()
end

StaticPopupDialogs["DYNAMICCAM_UI_NEW_SITUATION"] = {
  text = L["Enter name for custom situation:"],
  button1 = L["Create"],
  button2 = L["Cancel"],
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint (see Core.lua's popups)
  OnShow = function(self)
    ResolveEditBox(self):SetFocus()
  end,
  OnAccept = function(self)
    CreateSituation(ResolveEditBox(self):GetText())
  end,
  EditBoxOnEnterPressed = function(self)
    local editBox = ResolveEditBox(self)
    CreateSituation(editBox:GetText())
    editBox:GetParent():Hide()
  end,
}

local function RenameSituation(id, name)
  name = strtrim(name or "")
  local situation = ValidSituation(id)
  if not situation or name == "" then return end
  situation.name = name
  RefreshTopStrip()
end

StaticPopupDialogs["DYNAMICCAM_UI_RENAME_SITUATION"] = {
  text = L["Rename situation:"],
  button1 = SAVE,
  button2 = CANCEL,
  hasEditBox = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
  OnShow = function(self, data)
    local editBox = ResolveEditBox(self)
    local situation = data and ValidSituation(data.id)
    editBox:SetText(situation and situation.name or "")
    editBox:HighlightText()
    editBox:SetFocus()
  end,
  OnAccept = function(self, data)
    RenameSituation(data and data.id, ResolveEditBox(self):GetText())
  end,
  EditBoxOnEnterPressed = function(self)
    local editBox = ResolveEditBox(self)
    local dialog = editBox:GetParent()
    RenameSituation(dialog.data and dialog.data.id, editBox:GetText())
    dialog:Hide()
  end,
}

-- Unlike the old UI's unprompted "-" button, deleting here asks first (as
-- Graphit's preset delete does). DeleteCustomSituation exits the situation if
-- active and notifies the old Options module; our poll picks up the fallback
-- selection.
StaticPopupDialogs["DYNAMICCAM_UI_DELETE_SITUATION"] = {
  text = L["Delete situation \"%s\"?"],
  button1 = DELETE,
  button2 = CANCEL,
  showAlert = true,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
  OnAccept = function(self, data)
    if data then DynamicCam:DeleteCustomSituation(data.id) end
  end,
}


-- ===== Page builder =====

Ui.tabBuilders = Ui.tabBuilders or {}
Ui.tabBuilders[2] = function(parent)

  -- ===== Top strip =====

  -- One row holding all three blocks. Its TOP is the shared reference they all
  -- hang from, and its right edge is where the Enabled block ends up.
  local strip = CreateFrame("Frame", nil, parent)
  strip:SetPoint("TOPLEFT", parent, "TOPLEFT", SIDE_INSET, -STRIP_Y)
  strip:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -SIDE_INSET, -STRIP_Y)
  strip:SetHeight(STRIP_HEIGHT)

  -- Custom art buttons laid out in the four states of Blizzard's own
  -- 128-redbutton art kits (see BUTTON_QUADRANT). They will open the sharing
  -- window; for now a click only prints, so the art can be reviewed in place.
  local function CreateArtButton(file, tooltipText, anchorTo, onClick)
    local btn = CreateFrame("Button", nil, strip)
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    -- Top-anchored (not centred), so the buttons line up with the dropdown's
    -- top edge however their heights differ.
    if anchorTo then
      btn:SetPoint("TOPLEFT", anchorTo, "TOPRIGHT", BUTTON_GAP, 0)
    else
      btn:SetPoint("TOPLEFT", strip, "TOPLEFT", 0, 0)
    end

    -- One file per button, each state cropped from its own quadrant. The
    -- highlight is the art kit's glow, so it draws additively on top of the
    -- normal texture rather than replacing it.
    local function SetStateTexture(setter, getter, quadrant, blendMode)
      btn[setter](btn, file, blendMode)
      btn[getter](btn):SetTexCoord(unpack(BUTTON_QUADRANT[quadrant]))
    end
    SetStateTexture("SetNormalTexture",    "GetNormalTexture",    "normal")
    SetStateTexture("SetPushedTexture",    "GetPushedTexture",    "pushed")
    SetStateTexture("SetDisabledTexture",  "GetDisabledTexture",  "disabled")
    SetStateTexture("SetHighlightTexture", "GetHighlightTexture", "highlight", "ADD")

    btn:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip_SetTitle(GameTooltip, tooltipText)
      GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    btn:SetScript("OnClick", onClick)
    return btn
  end

  local importButton = CreateArtButton(BUTTON_FILE_IMPORT, L["Import"], nil, function()
    print("DynamicCam: import clicked")
  end)
  CreateArtButton(BUTTON_FILE_EXPORT, L["Export"], importButton, function()
    print("DynamicCam: export clicked")
  end)

  -- The dropdown, anchored by both top corners to the strip itself, so it fills
  -- the room the two fixed blocks leave and follows every window resize. Its
  -- height comes from the template.
  --
  -- Both corners are measured from the strip, not from its neighbours, for two
  -- reasons: a point fixes BOTH axes, so anchoring to the buttons would tie the
  -- dropdown to their vertical position as well (leaving no way to shift one
  -- against the other), and anchoring to the Enabled block - which hangs off the
  -- dropdown in turn - would be an anchor cycle. Both neighbours have a fixed
  -- width, so the arithmetic lands them flush against the strip's edges anyway.
  local dropdown = CreateFrame("DropdownButton", nil, strip, "WowStyle1DropdownTemplate")
  dropdown:SetPoint("TOPLEFT", strip, "TOPLEFT",
    BUTTON_BLOCK_WIDTH + DROPDOWN_GAP_LEFT, -DROPDOWN_Y)
  dropdown:SetPoint("TOPRIGHT", strip, "TOPRIGHT",
    -(ENABLE_BLOCK_WIDTH + DROPDOWN_GAP_RIGHT), -DROPDOWN_Y)

  -- Hovering the closed dropdown explains the list's colour coding, formatted
  -- from the same shared colour table the entries are painted with - exactly
  -- the old UI's select tooltip.
  dropdown:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip_SetTitle(GameTooltip, L["Select a situation to setup"])
    local e = sc.colorEnd
    GameTooltip_AddNormalLine(GameTooltip, L["<selectedSituation_desc>"]:format(
      sc.header, e,
      sc.disabled, e,
      sc.inactive, e,
      sc.active, e,
      sc.overridden, e,
      sc.modified, e,
      sc.error, e
    ), true)
    GameTooltip:Show()
  end)
  dropdown:HookScript("OnLeave", GameTooltip_Hide)

  -- The selected situation's enable toggle, the same setting the menu rows'
  -- checkboxes carry. Hung off the dropdown's right and vertically centred on
  -- it, since it is shorter than the buttons and would look adrift top-aligned.
  -- The label is clipped rather than allowed to widen the block, so the
  -- dropdown's right edge stays put whatever is selected. Kept in sync by
  -- RefreshTopStrip.
  local enableBlock = CreateFrame("Frame", nil, strip)
  enableBlock:SetPoint("LEFT", dropdown, "RIGHT", DROPDOWN_GAP_RIGHT, 0)
  enableBlock:SetSize(ENABLE_BLOCK_WIDTH, ENABLE_CHECK_SIZE)

  local enableCheck = CreateFrame("CheckButton", nil, enableBlock, "UICheckButtonTemplate")
  enableCheck:SetSize(ENABLE_CHECK_SIZE, ENABLE_CHECK_SIZE)
  enableCheck:SetPoint("LEFT", enableBlock, "LEFT", 0, 0)

  local enableLabel = enableBlock:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  enableLabel:SetPoint("LEFT", enableCheck, "RIGHT", ENABLE_LABEL_GAP, 0)
  enableLabel:SetPoint("RIGHT", enableBlock, "RIGHT", 0, 0)
  enableLabel:SetJustifyH("LEFT")
  enableLabel:SetText(L["Enable"])

  enableCheck:SetScript("OnClick", function(self)
    local checked = self:GetChecked()
    PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
      or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    SetSituationEnabled(selectedSID, checked)
  end)

  enableCheck:SetScript("OnEnter", function(self)
    local situation = ValidSituation(selectedSID)
    if not situation then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip_SetTitle(GameTooltip, L["Enable"])
    GameTooltip_AddNormalLine(GameTooltip, L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."]:format(situation.name), true)
    GameTooltip:Show()
  end)
  enableCheck:SetScript("OnLeave", GameTooltip_Hide)

  -- ===== The dropdown's menu =====

  -- The menu's auto-hide utility buttons draw from one frame pool shared by
  -- every menu in the game, and its reset restores size but NOT a texture's
  -- texcoord / tint / desaturation - a reused frame carries whatever the
  -- previous owner (possibly another addon) left on it. Wipe a freshly
  -- attached button's Texture back to a clean baseline (as Graphit does).
  local function ResetUtilityButtonTexture(button)
    local tex = button.Texture
    tex:SetTexCoord(0, 1, 0, 1)
    tex:SetVertexColor(1, 1, 1)
    tex:SetDesaturated(false)
  end

  -- The selected situation's row frame of the currently open menu, recorded by
  -- InitRow for the scroll-to-selection below; reset on every menu generation.
  local selectedRowButton

  -- Row (re)initializer, run on every open AND on every in-place refresh
  -- (menu:ReinitializeAll): repaint the row text (an enable toggle can change
  -- any row's colour - disabling the active situation activates another),
  -- record the selected row for the scroll-to-selection, and attach the row
  -- furniture. Everything is attached through the menu element's compositor,
  -- which strips and re-pools it on teardown and before every reinitialization,
  -- so nothing needs manual cleanup.
  --
  -- Rightmost the enable/disable checkbox, on every row and visible all the
  -- time; a custom situation's rename and delete sit left of it as
  -- Edit-Mode-style auto-hide icons revealed on row hover (as in Graphit's
  -- preset dropdown).
  local function InitRow(button, menu, id, isCustom)
    button.fontString:SetTextToFit(SituationText(id))
    if selectedSID == id then selectedRowButton = button end

    -- The pooled utility button is auto-hide by design (its attach wraps the
    -- row's enter/leave with its Show/Hide), so the always-visible checkbox is
    -- built from parts that are not: an attached texture for the box, one for
    -- the check overlaid on it while enabled, and an invisible basic button on
    -- top carrying the click and the state-dependent tooltip. The attached
    -- textures come unsized and unlayered, so set both explicitly - the check
    -- must draw above the box.
    local enabled = Situations()[id].enabled
    local checkBox = MenuTemplates.AttachTexture(button, CHECK_ATLAS_BOX, "RIGHT")
    checkBox:SetSize(CHECK_SIZE, CHECK_SIZE)
    checkBox:SetDrawLayer("ARTWORK", 0)
    if enabled then
      local checkMark = MenuTemplates.AttachTexture(button, CHECK_ATLAS_CHECK, "RIGHT")
      checkMark:SetSize(CHECK_SIZE, CHECK_SIZE)
      checkMark:SetDrawLayer("ARTWORK", 1)
    end

    local check = MenuTemplates.AttachBasicButton(button, CHECK_SIZE, CHECK_SIZE)
    check:SetPoint("RIGHT")
    MenuTemplates.SetUtilityButtonTooltipText(check, enabled and L["Disable"] or L["Enable"])
    MenuTemplates.SetUtilityButtonClickHandler(check, function()
      SetSituationEnabled(id, not Situations()[id].enabled)
      menu:ReinitializeAll()   -- repaint all rows in place; the menu stays open
    end)

    if not isCustom then return end

    -- An auto-hide button starts hidden and is revealed by the row's OnEnter,
    -- which does not fire again when a row is reinitialized under a resting
    -- cursor - the toggle above does exactly that. So reveal it right away
    -- when the cursor is already on the row, mirroring how Blizzard's own row
    -- initializer restores the row highlight in that same situation.
    local function AttachRowIcon(texture, size, tooltipText, anchorTo, onClick)
      local btn = MenuTemplates.AttachUtilityButton(button, texture, size, size)
      ResetUtilityButtonTexture(btn)
      MenuTemplates.SetUtilityButtonTooltipText(btn, tooltipText)
      btn:SetPoint("RIGHT", anchorTo, "LEFT", -ROW_ICON_GAP, 0)
      MenuTemplates.SetUtilityButtonClickHandler(btn, onClick)
      if button:IsMouseMotionFocus() then
        btn:Show()
        btn.Texture:Show()
      end
      return btn
    end

    local rename = AttachRowIcon(ROW_ICON_RENAME, ROW_ICON_RENAME_SIZE,
      L["Rename situation"], checkBox, function()
        menu:Close()
        StaticPopup_Show("DYNAMICCAM_UI_RENAME_SITUATION", nil, nil, { id = id })
      end)

    AttachRowIcon(ROW_ICON_DELETE, ROW_ICON_DELETE_SIZE,
      L["Delete situation"], rename, function()
        menu:Close()
        StaticPopup_Show("DYNAMICCAM_UI_DELETE_SITUATION", Situations()[id].name, nil, { id = id })
      end)
  end

  -- The menu regenerates on every open, so entry colours and the stock/custom
  -- split are always current. Stock situations first, then (behind a divider)
  -- the custom ones - only they can be renamed or deleted - then, again set
  -- off by a divider, the "New Situation" entry.
  dropdown:SetupMenu(function(_, rootDescription)
    -- Grow with the content; scroll only against the screen edge (see the
    -- constants above): open below the dropdown with all the room down to the
    -- screen bottom, or above with the room up to the top when below is
    -- cramped. The anchor set here is read when this open proceeds.
    local roomBelow = (dropdown:GetBottom() or 0) - MENU_SCREEN_MARGIN
    local roomAbove = UIParent:GetHeight() - (dropdown:GetTop() or 0) - MENU_SCREEN_MARGIN
    if roomBelow >= MENU_MIN_HEIGHT or roomBelow >= roomAbove then
      dropdown:SetMenuAnchor(AnchorUtil.CreateAnchor("TOPLEFT", dropdown, "BOTTOMLEFT"))
      rootDescription:SetScrollMode(math.max(roomBelow, MENU_MIN_HEIGHT))
    else
      dropdown:SetMenuAnchor(AnchorUtil.CreateAnchor("BOTTOMLEFT", dropdown, "TOPLEFT"))
      rootDescription:SetScrollMode(math.max(roomAbove, MENU_MIN_HEIGHT))
    end

    selectedRowButton = nil

    local stock, custom = SortedSituationIDs()
    local function AddRows(ids, isCustom)
      for _, id in ipairs(ids) do
        local radio = rootDescription:CreateRadio(SituationText(id),
          function() return selectedSID == id end,
          function()
            selectedSID = id
            RefreshTopStrip()
            return MenuResponse.CloseAll   -- a picked situation closes the menu
          end)
        radio:AddInitializer(function(button, description, menu)
          InitRow(button, menu, id, isCustom)
        end)
      end
    end

    AddRows(stock, false)
    if #custom > 0 then rootDescription:CreateDivider() end
    AddRows(custom, true)

    rootDescription:CreateDivider()
    rootDescription:CreateButton(
      CreateAtlasMarkup("editmode-new-layout-plus") .. " " .. L["New Situation"],
      function() StaticPopup_Show("DYNAMICCAM_UI_NEW_SITUATION") end)
  end)

  -- Once the menu is open (laid out, its scroll box filled - hence this hook
  -- rather than the pre-layout MenuAcquired callback), jump so the selected
  -- situation is centered in view. Only applies when the menu actually scrolls;
  -- the scroll box stays hidden otherwise. The scroll elements ARE the row
  -- frames, so the one InitRow recorded addresses the target directly.
  local baseOnMenuOpened = dropdown.OnMenuOpened
  dropdown.OnMenuOpened = function(self, menu)
    baseOnMenuOpened(self, menu)
    local scrollBox = menu.ScrollBox
    if selectedRowButton and scrollBox and scrollBox:IsShown() then
      scrollBox:ScrollToElementData(selectedRowButton, ScrollBoxConstants.AlignCenter,
        0, ScrollBoxConstants.NoScrollInterpolation)
    end
  end

  -- ===== Keeping the strip current =====

  -- Repaint the closed dropdown's text (the selected entry, in its current
  -- colour) and re-read the Enabled box. The text is cached, since building and
  -- setting it is the only part worth skipping on an unchanged frame.
  local shownText
  local function RefreshStrip()
    EnsureSelection()
    local situation = ValidSituation(selectedSID)

    local text = situation and SituationText(selectedSID) or ""
    if text ~= shownText then
      shownText = text
      dropdown:OverrideText(text)
    end

    -- With nothing selected (no situations at all) the box sits unchecked and
    -- unclickable rather than pretending to edit something.
    enableCheck:SetChecked(situation ~= nil and situation.enabled)
    enableCheck:SetEnabled(situation ~= nil)
  end

  -- ===== Inner tabs and their box =====

  -- Same three-part construction as the window itself: a content rect, the box
  -- border around it (content expanded by the pads), and the tab row directly
  -- above the content. The tab row's edges are the content's, so the tabs are
  -- inset from the box's left border and their bottoms land on its top border.
  local tabRow = CreateFrame("Frame", nil, parent)
  tabRow:SetPoint("TOPLEFT", parent, "TOPLEFT",
    SIDE_INSET + BOX_PAD_LEFT, -TAB_ROW_TOP)
  tabRow:SetPoint("TOPRIGHT", parent, "TOPRIGHT",
    -(SIDE_INSET + BOX_PAD_RIGHT), -TAB_ROW_TOP)
  tabRow:SetHeight(TAB_ROW_HEIGHT)

  -- The pages' rect, the counterpart of the window's contentArea: it starts
  -- TAB_Y below the tab row and runs to the page's bottom right, inset by the
  -- box's own spacing.
  local content = CreateFrame("Frame", nil, parent)
  content:SetPoint("TOPLEFT", tabRow, "BOTTOMLEFT", 0, -TAB_Y)
  content:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT",
    -(SIDE_INSET + BOX_PAD_RIGHT), BOX_INSET_BOTTOM + BOX_PAD_BOTTOM)

  -- The border rect, and the nine-slice drawn on it (the very function the
  -- window chrome uses). The art goes on its own layer, held at the page frame's
  -- own level so the pages - children of it, and thus a level above - draw on
  -- top of the border and its solid centre.
  local box = CreateFrame("Frame", nil, parent)
  box:SetPoint("TOPLEFT", content, "TOPLEFT", -BOX_PAD_LEFT, BOX_PAD_TOP)
  box:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", BOX_PAD_RIGHT, -BOX_PAD_BOTTOM)

  local boxArt = CreateFrame("Frame", nil, parent)
  boxArt:SetAllPoints(parent)
  boxArt:SetFrameLevel(parent:GetFrameLevel())
  Ui.DrawInnerBox(boxArt, box)

  -- The Situation Settings page is the very page the Standard Settings tab is
  -- built from - same descriptor, same rows - run in situation mode, which adds
  -- the per-category override checkboxes and gating (Ui/SettingsPage.lua). The
  -- other two are still to come; they will want the same scroll box, nav pane
  -- and scrollspy, so they too should come out of Ui.CreatePage rather than a
  -- second implementation.
  local tabNames = { L["Situation Settings"], L["Situation Actions"], L["Situation Controls"] }
  local pages = {}
  local pageObjects = {}   -- the Ui.CreatePage handles, keyed by inner tab
  for i, name in ipairs(tabNames) do
    local c = CreateFrame("Frame", nil, parent)
    c:SetAllPoints(content)
    c:Hide()
    if i == 1 then
      pageObjects[i] = Ui.CreatePage(c, Ui.settingsCategories,
        {situation = true, overrideLayer = true, configKey = "situationCategory"})
    elseif i == 2 then
      -- Actions edit the situation directly, so no override layer.
      pageObjects[i] = Ui.CreatePage(c, Ui.actionCategories,
        {situation = true, configKey = "actionCategory"})
    else
      local placeholder = c:CreateFontString(nil, "OVERLAY", "GameFontDisableLarge")
      placeholder:SetPoint("CENTER")
      placeholder:SetText(name .. "\n\n(under construction)")
    end
    pages[i] = c
  end

  -- The strip and the page below it move together: the strip resolves which
  -- situation is selected (falling back when one is deleted elsewhere), then the
  -- page is pointed at it. This is the file-scope RefreshTopStrip the situation
  -- dialogs call, and it can only be assembled here, once both halves exist.
  RefreshTopStrip = function()
    RefreshStrip()
    -- Every built page follows the selection; SetSid ignores a repeat.
    for _, page in pairs(pageObjects) do page.SetSid(selectedSID) end
  end
  RefreshTopStrip()

  -- A situation's state colour, name, priority and "(modified)" suffix can all
  -- change while the page is open (situations switch on player state; the old
  -- frame may edit in parallel), and a deleted selection must fall back - so
  -- poll, as the settings page polls its override display. Only runs while the
  -- page is visible.
  parent:HookScript("OnUpdate", RefreshTopStrip)

  local function SelectPage(index)
    for i, c in ipairs(pages) do
      c:SetShown(i == index)
    end
  end

  -- Each inner tab carries the help text that stood at the top of the old UI's
  -- corresponding tab. The Controls one is written for a panel and ends in blank
  -- lines, which a tooltip would render as trailing space - hence the trim.
  local activeTab = GetConfig().situationTab or 1
  Ui.CreateTabRow(tabRow, tabNames, activeTab, function(tabIndex)
    SelectPage(tabIndex)
    GetConfig().situationTab = tabIndex
  end, {
    [1] = function()
      GameTooltip_SetTitle(GameTooltip, L["Situation Settings"])
      GameTooltip_AddNormalLine(GameTooltip,
        L["These Situation Settings override the Standard Settings when the respective situation is active."], true)
    end,
    [2] = function()
      GameTooltip_SetTitle(GameTooltip, L["Situation Actions"])
      GameTooltip_AddNormalLine(GameTooltip,
        L["Setup stuff to happen while in a situation or when entering/exiting it."], true)
    end,
    [3] = function()
      GameTooltip_SetTitle(GameTooltip, L["Situation Controls"])
      GameTooltip_AddNormalLine(GameTooltip, strtrim(L["<situationControls_help>"]), true)
    end,
  })
  SelectPage(activeTab)
end
