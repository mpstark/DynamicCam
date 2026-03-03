-------------------------------------------------------------------------------
-- DynamicCam Options - Custom AceGUI Widgets
-- Custom widgets for the Options interface
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)

local Options = DynamicCam.Options


-------------------------------------------------------------------------------
-- Drawing Helper Functions
-------------------------------------------------------------------------------
local function DrawLine(f, startRelativeAnchor, startOffsetX, startOffsetY,
                           endRelativeAnchor, endOffsetX, endOffsetY,
                           thickness, r, g, b, a)

  local line = f:CreateLine()
  line:SetThickness(thickness)
  line:SetColorTexture(r, g, b, a)
  line:SetStartPoint(startRelativeAnchor, f, startOffsetX, startOffsetY)
  line:SetEndPoint(endRelativeAnchor, f, endOffsetX, endOffsetY)

end


local function SetFrameBorder(f, thickness, r, g, b, a)
  -- Bottom line.
  DrawLine(f, "BOTTOMLEFT", 0, 0, "BOTTOMRIGHT", 0, 0, thickness, r, g, b, a)
  -- Top line.
  DrawLine(f, "TOPLEFT", 0, 0, "TOPRIGHT", 0, 0, thickness, r, g, b, a)
  -- Left line.
  DrawLine(f, "BOTTOMLEFT", 0, 0, "TOPLEFT", 0, 0, thickness, r, g, b, a)
  -- Right line.
  DrawLine(f, "BOTTOMRIGHT", 0, 0, "TOPRIGHT", 0, 0, thickness, r, g, b, a)
end


-------------------------------------------------------------------------------
-- Registry for Custom Widget Builders
-------------------------------------------------------------------------------
DynamicCam.customWidgetBuilders = {}


-------------------------------------------------------------------------------
-- SituationExport Widget Builder
-------------------------------------------------------------------------------
DynamicCam.customWidgetBuilders["SituationExport"] = function(widget, f)

  -- Description text on top of the page.
  if not f.help then
    f.help = f:CreateFontString(nil, "OVERLAY")
    f.help:SetFontObject("GameFontHighlightSmall")
    f.help:SetJustifyH("LEFT")
    f.help:SetPoint("TOPLEFT", f, "TOPLEFT")
    f.help:SetPoint("TOPRIGHT", f, "TOPRIGHT")
    f.help:SetText("Select the settings you want to export.")
  end

  if not f.contentFrame then
    f.contentFrame = CreateFrame("Frame", nil, f)
    local cf = f.contentFrame
    local yOffset = -10
    cf:SetPoint("TOPLEFT", f.help, "BOTTOMLEFT", 0, yOffset)
    cf:SetPoint("TOPRIGHT", f.help, "TOPRIGHT", 0, yOffset)

    -- We use cf directly as the container for rows.
    -- Scrolling is handled by the parent AceGUI container.

    -- --- Tree Building Logic ---

    local function BuildTreeData(args)
      local tree = {}
      for key, entry in pairs(args) do
        -- Check disabled status
        local isDisabled = false
        if entry.disabled then
            if type(entry.disabled) == "function" then
                isDisabled = entry.disabled({})
            else
                isDisabled = entry.disabled
            end
        end

        -- Check hidden status
        local isHidden = false
        if entry.hidden then
            if type(entry.hidden) == "function" then
                isHidden = entry.hidden({})
            else
                isHidden = entry.hidden
            end
        end

        if not isDisabled and not isHidden then
            if entry.type == "group" then
              local children = BuildTreeData(entry.args)
              if next(children) then
                local rawName = (type(entry.name) == "function" and entry.name() or entry.name)
                local name = rawName and rawName:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") or ""

                -- Optimization: If group has name, but contains only 1 child,
                -- hoist the child and merge the names.
                if name and name ~= "" and #children == 1 then
                    local child = children[1]
                    local cleanChildName = child.name and child.name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") or ""

                    if cleanChildName ~= "" then
                        child.name = name .. " |cFFFFFFFF- " .. cleanChildName .. "|r"
                    else
                        if child.children then
                            child.name = name
                        else
                            child.name = "|cFFFFFFFF" .. name .. "|r"
                        end
                    end
                    child.order = entry.order or child.order
                    table.insert(tree, child)
                elseif not name or name == "" then
                    -- If the group has no name (like inline groups), flatten it by merging children up
                    for _, child in ipairs(children) do
                        table.insert(tree, child)
                    end
                else
                    table.insert(tree, {
                      key = key,
                      name = name,
                      children = children,
                      order = entry.order or 100,
                      checked = false,
                      notCollapsible = entry.notCollapsible
                    })
                end
              end
            elseif entry._dbPath or entry.get then
              local rawName = (type(entry.name) == "function" and entry.name() or entry.name)
              local cleanName = rawName and rawName:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") or ""

              local finalName = cleanName
              if cleanName ~= "" then
                  finalName = "|cFFFFFFFF" .. cleanName .. "|r"
              end

              table.insert(tree, {
                key = key,
                name = finalName,
                dbPath = entry._dbPath,
                order = entry.order or 100,
                get = entry.get,
                arg = entry.arg,
                type = entry.type,
                multiline = entry.multiline,
                checked = false
              })
            end
        end
      end
      table.sort(tree, function(a,b) return a.order < b.order end)
      return tree
    end

    -- Get options structure - these functions are defined in the main Options.lua
    local fullOptions = Options.CreateSituationSettingsTab(0, true)
    local exportArgs = {
        everything = {
            type = "group",
            name = "Everything",
            order = 1,
            notCollapsible = true,
            args = {
                situationSettings = {
                    type = "group",
                    name = L["Situation Settings"],
                    order = 1,
                    args = Options.CreateSettingsTab(0, true, true).args
                },
                situationActions = {
                    type = "group",
                    name = L["Situation Actions"],
                    order = 2,
                    args = fullOptions.args.situationActions.args
                },
                situationControls = {
                    type = "group",
                    name = L["Situation Controls"],
                    order = 3,
                    args = fullOptions.args.situationControls.args
                }
            }
        }
    }

    local treeData = BuildTreeData(exportArgs)

    -- --- Tree Rendering Logic ---

    local ROW_HEIGHT = 24
    local INDENT = 20
    local allRows = {} -- Flat list of all rows in visual order

    local function ReLayout()
        local currentY = 0
        for _, row in ipairs(allRows) do
            if row:IsShown() then
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", cf, "TOPLEFT", row.level * INDENT, currentY)
                row:SetPoint("RIGHT", cf, "RIGHT")
                currentY = currentY - row:GetHeight()
            end
        end
        cf:SetHeight(math.abs(currentY))

        if widget.AdjustHeightFunction then
            widget:AdjustHeightFunction()
        end

        -- Force parent to update layout to accommodate new height
        if widget.parent and widget.parent.DoLayout then
            widget.parent:DoLayout()
        end
    end

    local function CreateRow(parent, node, level, parentRow)
      local row = CreateFrame("Frame", nil, parent)
      row:SetHeight(ROW_HEIGHT)
      row.level = level -- Store level for ReLayout
      row.parentRow = parentRow

      -- Expand Button (if children)
      if node.children then
        if not node.notCollapsible then
            local expandBtn = CreateFrame("Button", nil, row)
            expandBtn:SetSize(22, 22)
            expandBtn:SetPoint("LEFT", 0, 0)

            -- Use textures instead of text
            expandBtn:SetNormalAtlas("common-button-dropdown-open")
            expandBtn:SetPushedAtlas("common-button-dropdown-openpressed")
            expandBtn:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")

            row.expandBtn = expandBtn
        end

        row.expanded = true -- Default to expanded

        local function ToggleChildren(row, show)
            if not row.childRows then return end
            for _, childRow in ipairs(row.childRows) do
                if show then
                    childRow:Show()
                    -- If the child itself is expanded, show its children too
                    if childRow.expanded then
                        ToggleChildren(childRow, true)
                    end
                else
                    childRow:Hide()
                    -- Recursively hide all descendants
                    ToggleChildren(childRow, false)
                end
            end
        end

        if row.expandBtn then
            row.expandBtn:SetScript("OnClick", function(self)
               row.expanded = not row.expanded
               local show = row.expanded

               if show then
                   self:SetNormalAtlas("common-button-dropdown-open")
                   self:SetPushedAtlas("common-button-dropdown-openpressed")
               else
                   self:SetNormalAtlas("common-button-dropdown-closed")
                   self:SetPushedAtlas("common-button-dropdown-closedpressed")
               end

               ToggleChildren(row, show)
               ReLayout()
            end)
        end
      end

      -- Checkbox
      local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
      cb:SetSize(24, 24)

      local cbOffsetX = 24
      if node.notCollapsible then
          cbOffsetX = 0
      end
      cb:SetPoint("TOPLEFT", cbOffsetX, 0)

      cb.text:SetText(" " .. node.name)

      cb.text:SetFontObject("GameFontNormal")

      row.cb = cb
      row.node = node
      row.childRows = {}

      -- Multiline handling
      if node.multiline then
          local val = ""
          if node.get then
             local success, v = pcall(node.get)
             if success and v then val = v end
          end

          local hasContent = (val and val ~= "")
          local boxHeight = hasContent and 80 or 24

          local scrollFrameBorder = CreateFrame("Frame", nil, row, "TooltipBackdropTemplate")
          scrollFrameBorder:SetPoint("TOPLEFT", 28, -24)
          scrollFrameBorder:SetPoint("RIGHT", -30, 0)
          scrollFrameBorder:SetHeight(boxHeight)

          local template = hasContent and "UIPanelScrollFrameTemplate" or nil
          local scrollFrame = CreateFrame("ScrollFrame", nil, scrollFrameBorder, template)
          scrollFrame:SetPoint("TOPLEFT", 8, -4)
          if hasContent then
              scrollFrame:SetPoint("BOTTOMRIGHT", -26, 4)
          else
              scrollFrame:SetPoint("BOTTOMRIGHT", -8, 4)
          end

          local bg = scrollFrame:CreateTexture(nil, "BACKGROUND")
          bg:SetAllPoints()
          bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)

          local editBox = CreateFrame("EditBox", nil, scrollFrame)
          editBox:SetMultiLine(true)
          editBox:SetFontObject("GameFontHighlightSmall")
          editBox:SetTextColor(0.533, 0.533, 0.533)
          editBox:SetTextInsets(2, 2, 4, 2)
          editBox:SetText(val)
          editBox:SetAutoFocus(false)
          editBox:EnableMouse(false)

          scrollFrame:SetScript("OnSizeChanged", function(self, w, h)
              editBox:SetWidth(w)
          end)

          scrollFrame:SetScrollChild(editBox)

          row:SetHeight(24 + boxHeight + 5)
      else
          -- Append value if available (single line)
          if node.get then
              local success, val = pcall(node.get)
              if success and val ~= nil then
                  if type(val) == "number" then
                      val = math.floor(val * 100 + 0.5) / 100 -- Round to 2 decimals
                  end
                  cb.text:SetText(" " .. node.name .. " |cFF888888[" .. tostring(val) .. "]|r")
              end
          end
          row:SetHeight(ROW_HEIGHT)
      end

      table.insert(allRows, row) -- Add to flat list

      -- Helper to calculate state based on children
      local function GetState(r)
          if not r.childRows or #r.childRows == 0 then
              return r.node.checked
          end

          local allChecked = true
          local allUnchecked = true

          for _, child in ipairs(r.childRows) do
              local childState = GetState(child)
              if childState == false then
                  allChecked = false
              elseif childState == true then
                  allUnchecked = false
              else -- mixed
                  allChecked = false
                  allUnchecked = false
              end
          end

          if allChecked then return true end
          if allUnchecked then return false end
          return "mixed"
      end

      -- Helper to update visuals
      local function UpdateVisuals(r)
          local state = GetState(r)
          local tex = r.cb:GetCheckedTexture()

          if state == true then
              r.cb:SetChecked(true)
              tex:SetAlpha(1)
          elseif state == false then
              r.cb:SetChecked(false)
          else -- mixed
              r.cb:SetChecked(true)
              tex:SetAlpha(0.4)
          end
      end
      row.UpdateVisuals = UpdateVisuals

      -- Checkbox Logic
      cb:SetScript("OnClick", function(self)
          local currentState = GetState(row)
          local newState = true
          if currentState == true then
              newState = false
          end

          -- Apply to self (leaf) or children (recursive)
          local function SetStateRecursive(r, state)
              r.node.checked = state
              if r.childRows then
                  for _, child in ipairs(r.childRows) do
                      SetStateRecursive(child, state)
                  end
              end
              r.UpdateVisuals(r)
          end

          SetStateRecursive(row, newState)

          -- Update parents upwards
          local p = row.parentRow
          while p do
              p.UpdateVisuals(p)
              p = p.parentRow
          end
      end)

      if node.children then
        for _, child in ipairs(node.children) do
          local childRow = CreateRow(parent, child, level + 1, row)
          table.insert(row.childRows, childRow)
        end
      end

      -- Initialize state
      if node.checked == nil then node.checked = false end
      UpdateVisuals(row)

      return row
    end

    -- Use real treeData
    for _, node in ipairs(treeData) do
      CreateRow(cf, node, 0, nil)
    end

    -- Initial Layout
    ReLayout()
  end

  -- Whenever OnWidthSet() is called, we set the height of frames to the height of their children frames.
  widget.AdjustHeightFunction = function(self)
    local cf = f.contentFrame

    -- Set the container frame (f) height.
    local point, _, _, _, yOffset = cf:GetPoint()
    -- yOffset is negative (e.g. -10), so we subtract it to add the spacing
    local totalHeight = f.help:GetStringHeight() + math.abs(yOffset) + cf:GetHeight()
    f:SetHeight(totalHeight)

    -- Set the widget frame height to match the container.
    self:SetHeight(totalHeight)
  end

end


-------------------------------------------------------------------------------
-- DynamicCam_CustomWidget
-- My custom widget for Situation Export.
-- Inspired by https://github.com/SFX-WoW/AceGUI-3.0_SFX-Widgets/.
-------------------------------------------------------------------------------
do
  local Type, Version = "DynamicCam_CustomWidget", 1
  local AceGUI = LibStub("AceGUI-3.0", true)

  -- Standard Ace3 version check: If a newer version of this widget is already registered, don't overwrite it.
  if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

  local function Constructor()

    local Widget     = {}
    Widget.frame     = CreateFrame("Frame", nil, UIParent)
    Widget.frame.obj = Widget
    Widget.type      = Type
    Widget.num       = AceGUI:GetNextWidgetNum(Type)

    -- Reccommended place to store ephemeral widget information.
    Widget.userdata = {}

    -- Storage for our different views (builders)
    Widget.views = {}

    -- OnAcquire, SetLabel, SetText, SetDisabled(nil)
    -- all get called when showing the widget.
    Widget.OnAcquire = function(self)
      self.resizing = true

      self:SetDisabled(true)

      -- Hide all views
      for _, view in pairs(self.views) do
        view:Hide()
      end
      self.currentView = nil
      self.AdjustHeightFunction = nil

      self.resizing = nil
    end

    Widget.SetLabel = function(self, name)
      -- Use 'name' as the ID to look up the builder.
      local builder = DynamicCam.customWidgetBuilders[name]
      if not builder then return end

      -- Always rebuild to ensure fresh data (e.g. when situation changes)
      if self.views[name] then
        self.views[name]:Hide()
        self.views[name]:SetParent(nil)
      end

      local f = CreateFrame("Frame", nil, self.frame)
      f:SetPoint("TOPLEFT")
      f:SetPoint("TOPRIGHT")

      builder(self, f)
      self.views[name] = f

      self.currentView = self.views[name]
      self.currentView:Show()

      -- Trigger a resize now that we have content
      if self.AdjustHeightFunction then
         self:AdjustHeightFunction()
      end
    end

    -- Not useful to us, but Ace3 needs to call it.
    Widget.SetText = function(self) end

    Widget.OnWidthSet = function(self)
      if self.resizing then return end

      -- Whenever OnWidthSet() is called, adjust the height of the frames to contain all child frames.
      if self.AdjustHeightFunction then self:AdjustHeightFunction() end
    end

    Widget.SetDisabled = function(self, Disabled)
      self.disabled = Disabled
    end

    -- OnRelease gets called when hiding the widget.
    Widget.OnRelease = function(self)
      self:SetDisabled(true)
      self.frame:ClearAllPoints()
      if self.currentView then
        self.currentView:Hide()
      end
      self.currentView = nil
      self.AdjustHeightFunction = nil
    end

    return AceGUI:RegisterAsWidget(Widget)
  end

  AceGUI:RegisterWidgetType(Type, Constructor, Version)
end


-------------------------------------------------------------------------------
-- DynamicCam_ZoomBasedControl
-- Custom AceGUI widget for zoom-based controls.
-- Displays a checkbox and edit button side-by-side with a single label underneath.
-------------------------------------------------------------------------------
do
  local Type, Version = "DynamicCam_ZoomBasedControl", 1
  local AceGUI = LibStub("AceGUI-3.0", true)

  -- Standard Ace3 version check
  if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

  local function Constructor()
    local Widget = {}
    Widget.type = Type
    Widget.num = AceGUI:GetNextWidgetNum(Type)
    Widget.userdata = {}

    -- Main container frame
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetHeight(36)
    Widget.frame = frame
    frame.obj = Widget

    -- Checkbox (no text, we'll use our own label)
    local checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    checkbox:SetSize(24, 24)
    checkbox:SetPoint("TOPRIGHT", frame, "TOP", 0, 0)
    checkbox:SetHitRectInsets(0, 0, 0, 0)
    Widget.checkbox = checkbox


    -- Edit button (gear icon)
    local editBtn = CreateFrame("Button", nil, frame)
    editBtn:SetSize(23, 23)
    editBtn:SetPoint("TOPLEFT", frame, "TOP", 0, -3)
    Widget.editBtn = editBtn

    -- Base texture path
    -- https://wago.tools/files?search=interface%2Fcommon%2Fcommondropdownsettings2x
    local texturePath = "Interface\\Common\\CommonDropdownSettings2x"

    -- Store the texture coordinates for different highlight states
    Widget.noHighlightNormalCoords  = {0.21875, 0.43750, 0.00000, 0.43750}  -- Texture: center, top
    Widget.noHighlightPressedCoords = {0.21875, 0.43750, 0.43750, 0.87500}  -- Texture: center, bottom
    Widget.highlightNormalCoords    = {0.00000, 0.21875, 0.43750, 0.87500}  -- Texture: left, bottom
    Widget.highlightPressedCoords   = {0.43750, 0.65625, 0.00000, 0.43750}  -- Texture: right, top
    Widget.disabledCoords           = {0.00000, 0.21875, 0.00000, 0.43750}  -- Texture: left, top


    -- Normal texture - use SetNormalTexture for proper button behavior

    editBtn:SetNormalTexture(texturePath)
    local normalTex = editBtn:GetNormalTexture()
    normalTex:SetTexCoord(unpack(Widget.noHighlightNormalCoords))
    Widget.editIcon = normalTex

    -- Pushed/pressed texture - use SetPushedTexture
    -- Shows when button is pressed but mouse is NOT hovering (pressed-not-highlighted)
    editBtn:SetPushedTexture(texturePath)
    local pushedTex = editBtn:GetPushedTexture()
    pushedTex:SetTexCoord(unpack(Widget.noHighlightPressedCoords))
    Widget.editPushed = pushedTex

    -- Highlight texture - use SetHighlightTexture
    editBtn:SetHighlightTexture(texturePath)
    local highlightTex = editBtn:GetHighlightTexture()
    highlightTex:SetTexCoord(unpack(Widget.highlightNormalCoords))
    highlightTex:SetBlendMode("BLEND")
    Widget.editHighlight = highlightTex

    -- Track button press state (mouse down) and toggle state (editor open)
    Widget.isMousePressed = false
    Widget.isEditorOpen = false

    -- Disabled texture - use SetDisabledTexture
    editBtn:SetDisabledTexture(texturePath)
    local disabledTex = editBtn:GetDisabledTexture()
    disabledTex:SetTexCoord(0, 0.21093750, 0, 0.421875)
    Widget.editDisabled = disabledTex

    -- Helper function to update button textures based on editor open state
    local function UpdateButtonTextures()
      if Widget.isEditorOpen then
        -- When editor is open, show pressed appearance
        Widget.editIcon:SetTexCoord(unpack(Widget.noHighlightPressedCoords))
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      else
        -- Normal appearance
        Widget.editIcon:SetTexCoord(unpack(Widget.noHighlightNormalCoords))
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightNormalCoords))
      end
    end
    Widget.UpdateButtonTextures = UpdateButtonTextures

    -- Open the editor for this widget
    local function OpenEditor()
      if Widget.isEditorOpen then return end

      Widget.isEditorOpen = true

      -- Call the EditFunc to actually open the editor
      if Widget.EditFunc then
        Widget.EditFunc(true, Widget)  -- Pass widget so EditFunc can set up close callbacks
      end

      UpdateButtonTextures()
    end
    Widget.OpenEditor = OpenEditor

    -- Close the editor for this widget
    local function CloseEditor()
      if not Widget.isEditorOpen then return end

      Widget.isEditorOpen = false

      -- Call the EditFunc to actually close the editor
      if Widget.EditFunc then
        Widget.EditFunc(false, Widget)
      end

      UpdateButtonTextures()
    end
    Widget.CloseEditor = CloseEditor

    -- Toggle editor open/closed
    local function ToggleEditor()
      if Widget.isEditorOpen then
        Widget:CloseEditor()
      else
        Widget:OpenEditor()
      end
    end
    Widget.ToggleEditor = ToggleEditor

    -- Label underneath both controls
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("BOTTOM", frame, "BOTTOM", 0, 3)
    label:SetText(L["Zoom-based"])
    Widget.label = label

    -- Checkbox click handler
    checkbox:SetScript("OnClick", function(self)
      local checked = self:GetChecked()
      if Widget.SetValueFunc then
        Widget.SetValueFunc(checked)
      end
      -- Update button disabled state after toggle
      if Widget.UpdateDisabled then
        Widget:UpdateDisabled()
      end
      -- Notify AceConfig to refresh the UI (disables/enables associated slider)
      LibStub("AceConfigRegistry-3.0"):NotifyChange("DynamicCam")
      PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    end)

    -- Checkbox tooltip
    checkbox:SetScript("OnEnter", function(self)
      if Widget.checkboxTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Zoom-based"], 1, 1, 1)
        GameTooltip:AddLine(Widget.checkboxTooltip, nil, nil, nil, true)
        GameTooltip:Show()
      end
    end)
    checkbox:SetScript("OnLeave", function(self)
      GameTooltip:Hide()
    end)

    -- Edit button state handlers for highlight texture switching
    editBtn:SetScript("OnMouseDown", function(self)
      if not Widget.editBtnDisabled then
        Widget.isMousePressed = true
        -- Show pressed highlight while mouse is down
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      end
    end)

    editBtn:SetScript("OnMouseUp", function(self)
      Widget.isMousePressed = false
      -- Restore highlight based on editor open state
      if Widget.isEditorOpen then
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      else
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightNormalCoords))
      end
    end)

    -- Edit button click handler - now toggles the editor
    editBtn:SetScript("OnClick", function(self)
      if not Widget.editBtnDisabled then
        Widget:ToggleEditor()
      end
    end)

    -- Edit button tooltip
    editBtn:SetScript("OnEnter", function(self)
      -- Update highlight based on pressed state or editor open state
      if Widget.isMousePressed and not Widget.editBtnDisabled then
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      elseif Widget.isEditorOpen then
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      end

      if Widget.editBtnTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Edit Curve"], 1, 1, 1)
        GameTooltip:AddLine(Widget.editBtnTooltip, nil, nil, nil, true)
        GameTooltip:Show()
      end
    end)

    editBtn:SetScript("OnLeave", function(self)
      GameTooltip:Hide()
      -- Restore textures based on state
      if Widget.isMousePressed and not Widget.editBtnDisabled then
        -- Mouse still pressed but left button area
        Widget.editHighlight:SetTexCoord(unpack(Widget.noHighlightPressedCoords))
      elseif Widget.isEditorOpen then
        -- Editor is open, keep pressed highlight look
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      else
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightNormalCoords))
      end
    end)

    -- Widget methods
    Widget.OnAcquire = function(self)
      self:SetDisabled(false)
      self.checkbox:SetChecked(false)
      self.editBtnDisabled = true
      self.isEditorOpen = false
      self.isMousePressed = false
      self:UpdateButtonTextures()
      self:UpdateDisabled()
    end

    Widget.OnRelease = function(self)
      -- Don't close the editor when widget is released - it should stay open
      -- The editor state will be restored when the widget is reacquired
      self.GetValueFunc = nil
      self.SetValueFunc = nil
      self.EditFunc = nil
      self.DisabledFunc = nil
      self.checkboxTooltip = nil
      self.editBtnTooltip = nil
      self.configId = nil
      self.frame:ClearAllPoints()
    end

    Widget.SetDisabled = function(self, disabled)
      self.disabled = disabled
      if disabled then
        self.checkbox:Disable()
        self.checkbox:SetAlpha(0.5)
        self.label:SetAlpha(0.5)
      else
        self.checkbox:Enable()
        self.checkbox:SetAlpha(1)
        self.label:SetAlpha(1)
      end
      self:UpdateDisabled()
    end

    Widget.UpdateDisabled = function(self)
      -- Edit button is disabled if widget is disabled OR if checkbox is unchecked
      local editDisabled = self.disabled or not self.checkbox:GetChecked()
      if self.DisabledFunc then
        editDisabled = editDisabled or self.DisabledFunc()
      end
      self.editBtnDisabled = editDisabled

      -- Use the proper button Enable/Disable methods
      if editDisabled then
        self.editBtn:Disable()
        -- Close editor if it was open
        if self.isEditorOpen then
          self:CloseEditor()
        end
      else
        self.editBtn:Enable()
      end
    end

    Widget.SetValue = function(self, value)
      self.checkbox:SetChecked(value)
      self:UpdateDisabled()
    end

    -- Called by AceConfigDialog - the name is our config ID
    Widget.SetLabel = function(self, configId)
      -- Look up the configuration from the registry
      local config = DynamicCam.zoomBasedControlConfigs and DynamicCam.zoomBasedControlConfigs[configId]
      if not config then return end

      self.configId = configId
      self.checkboxTooltip = config.checkboxTooltip
      self.editBtnTooltip = config.editBtnTooltip
      self.EditFunc = config.editFunc
      self.SetValueFunc = config.setFunc
      self.GetValueFunc = config.getFunc

      -- Set initial state
      if config.getFunc then
        self.checkbox:SetChecked(config.getFunc())
      end

      -- Check if editor is currently open for this setting and restore button state
      if config.getSituationId and config.cvarName and DynamicCam.IsEditorOpenForSetting then
        local situationId = config.getSituationId()
        if DynamicCam:IsEditorOpenForSetting(situationId, config.cvarName) then
          self.isEditorOpen = true
          self:UpdateButtonTextures()
          -- Update the editor's widget reference to this widget instance
          if DynamicCam.UpdateEditorWidgetReference then
            DynamicCam:UpdateEditorWidgetReference(self)
          end
        end
      end

      self:UpdateDisabled()
    end

    Widget.SetCallback = function(self, event, func)
      -- Not needed - we handle callbacks through the registry
    end

    -- SetText is called by AceConfigDialog for input widgets, ignore it
    Widget.SetText = function(self, text)
    end

    return AceGUI:RegisterAsWidget(Widget)
  end

  AceGUI:RegisterWidgetType(Type, Constructor, Version)
end
