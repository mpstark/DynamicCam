-------------------------------------------------------------------------------
-- DynamicCam Options - Custom AceGUI Widgets
-- Custom widgets for the Options interface
-------------------------------------------------------------------------------

local folderName = ...

local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)

local Options = DynamicCam.Options


-------------------------------------------------------------------------------
-- Region Pool Helpers (for frame reuse without leaking)
-------------------------------------------------------------------------------
local function AcquireLine(frame)
  if not frame.linePool then frame.linePool = {} end
  local count = (frame.lineCount or 0) + 1
  frame.lineCount = count
  local line = frame.linePool[count]
  if not line then
    line = frame:CreateLine()
    frame.linePool[count] = line
  end
  line:Show()
  return line
end

local function ReleaseAllLines(frame)
  if not frame.linePool then return end
  for i = 1, (frame.lineCount or 0) do
    frame.linePool[i]:Hide()
  end
  frame.lineCount = 0
end

local function AcquireFontString(frame)
  if not frame.fontStringPool then frame.fontStringPool = {} end
  local count = (frame.fontStringCount or 0) + 1
  frame.fontStringCount = count
  local fs = frame.fontStringPool[count]
  if not fs then
    fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.fontStringPool[count] = fs
  end
  fs:ClearAllPoints()
  fs:Show()
  return fs
end

local function ReleaseAllFontStrings(frame)
  if not frame.fontStringPool then return end
  for i = 1, (frame.fontStringCount or 0) do
    frame.fontStringPool[i]:Hide()
  end
  frame.fontStringCount = 0
end


-------------------------------------------------------------------------------
-- Registry for Custom Widget Builders
-------------------------------------------------------------------------------
DynamicCam.customWidgetBuilders = {}


-------------------------------------------------------------------------------
-- SituationExport Widget Builder
-------------------------------------------------------------------------------
DynamicCam.customWidgetBuilders["SituationExport"] = function(widget, f)

  -- Description text on top of the page (created once).
  if not f.help then
    f.help = f:CreateFontString(nil, "OVERLAY")
    f.help:SetFontObject("GameFontHighlightSmall")
    f.help:SetJustifyH("LEFT")
    f.help:SetPoint("TOPLEFT", f, "TOPLEFT")
    f.help:SetPoint("TOPRIGHT", f, "TOPRIGHT")
    f.help:SetText("Select the settings you want to export.")
  end

  -- Content frame and row pool (created once).
  if not f.contentFrame then
    f.contentFrame = CreateFrame("Frame", nil, f)
    f.contentFrame:SetPoint("TOPLEFT", f.help, "BOTTOMLEFT", 0, -10)
    f.contentFrame:SetPoint("TOPRIGHT", f.help, "TOPRIGHT", 0, -10)
    f.contentFrame.rowPool = {}
    f.contentFrame.allRows = {}
  end

  local cf = f.contentFrame

  -- ---- Release existing rows back to the pool ----
  for _, row in ipairs(cf.allRows) do
    row:Hide()
    row:ClearAllPoints()
    row.cb:SetScript("OnClick", nil)
    row.cb:SetChecked(false)
    if row.expandBtn then
      row.expandBtn:Hide()
      row.expandBtn:SetScript("OnClick", nil)
    end
    if row.graphFrame then
      row.graphFrame:Hide()
      ReleaseAllLines(row.graphFrame)
    end
    if row.multilineFrame then row.multilineFrame:Hide() end
    ReleaseAllFontStrings(row)
    wipe(row.childRows)
    row.node = nil
    row.parentRow = nil
    row.expanded = nil
    row.level = nil
    row.UpdateVisuals = nil
    table.insert(cf.rowPool, row)
  end
  wipe(cf.allRows)

  -- ---- Tree Building Logic (re-evaluated each rebuild) ----

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

      -- For leaf entries with _dbPath (exportable settings), include even if
      -- disabled (e.g. sliders disabled because the cvar is zoom-based).
      local skipDisabled = isDisabled and not entry._dbPath
      if not skipDisabled and not isHidden then
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

          local cvarName = nil
          if type(entry._dbPath) == "table" and entry._dbPath[1] == "cvars" then
            cvarName = entry._dbPath[2]
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
            cvarName = cvarName,
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

  -- ---- Tree Rendering Logic ----

  local ROW_HEIGHT = 24
  local INDENT = 20
  local allRows = cf.allRows

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

  -- Acquire a row frame from the pool (or create a new one).
  local function AcquireRow()
    local row = table.remove(cf.rowPool)
    if row then
      row:Show()
      return row
    end
    row = CreateFrame("Frame", nil, cf)
    row.childRows = {}
    -- Checkbox (created once per row frame, reused across rebuilds)
    row.cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
    row.cb:SetSize(24, 24)
    return row
  end

  local function CreateRow(parent, node, level, parentRow)
    local row = AcquireRow()
    row:SetHeight(ROW_HEIGHT)
    row.level = level
    row.parentRow = parentRow
    row.node = node
    wipe(row.childRows)

    -- Expand Button (reused from row frame if it exists)
    if node.children and not node.notCollapsible then
      if not row.expandBtn then
        row.expandBtn = CreateFrame("Button", nil, row)
        row.expandBtn:SetSize(22, 22)
        row.expandBtn:SetPoint("LEFT", 0, 0)
        row.expandBtn:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
      end
      row.expandBtn:SetNormalAtlas("common-button-dropdown-open")
      row.expandBtn:SetPushedAtlas("common-button-dropdown-openpressed")
      row.expandBtn:Show()
    elseif row.expandBtn then
      row.expandBtn:Hide()
    end

    row.expanded = node.children and true or nil

    -- ToggleChildren (closure captures this specific row)
    local function ToggleChildren(r, show)
      if not r.childRows then return end
      for _, childRow in ipairs(r.childRows) do
        if show then
          childRow:Show()
          if childRow.expanded then
            ToggleChildren(childRow, true)
          end
        else
          childRow:Hide()
          ToggleChildren(childRow, false)
        end
      end
    end

    if row.expandBtn and node.children then
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

    -- Checkbox (already created on the row frame, just reconfigure)
    local cb = row.cb
    local cbOffsetX = node.notCollapsible and 0 or 24
    cb:ClearAllPoints()
    cb:SetPoint("TOPLEFT", cbOffsetX, 0)
    cb.text:SetText(" " .. node.name)
    cb.text:SetFontObject("GameFontNormal")
    cb:SetChecked(false)
    cb:Show()

    -- Check if this cvar is currently set to zoom-based mode
    local isZoomBased = false
    local zoomPoints = nil
    if node.cvarName then
      isZoomBased = DynamicCam:IsCvarZoomBased(Options.SID, node.cvarName)
      if isZoomBased then
        zoomPoints = DynamicCam:GetSavedZoomBasedPoints(Options.SID, node.cvarName)
      end
    end

    -- Hide any previously visible type-specific content
    if row.graphFrame then row.graphFrame:Hide(); ReleaseAllLines(row.graphFrame) end
    if row.multilineFrame then row.multilineFrame:Hide() end
    ReleaseAllFontStrings(row)

    -- ---- Multiline handling ----
    if node.multiline then
      local val = ""
      if node.get then
        local success, v = pcall(node.get)
        if success and v then val = v end
      end

      if val ~= "" then
        -- Lazily create the multiline sub-frames on this row frame.
        if not row.multilineFrame then
          row.multilineFrame = CreateFrame("Frame", nil, row, "TooltipBackdropTemplate")
          row.multilineScrollFrame = CreateFrame("ScrollFrame", nil, row.multilineFrame, "UIPanelScrollFrameTemplate")

          row.multilineBg = row.multilineScrollFrame:CreateTexture(nil, "BACKGROUND")
          row.multilineBg:SetAllPoints()
          row.multilineBg:SetColorTexture(0.1, 0.1, 0.1, 0.5)

          row.multilineEditBox = CreateFrame("EditBox", nil, row.multilineScrollFrame)
          row.multilineEditBox:SetMultiLine(true)
          row.multilineEditBox:SetFontObject("GameFontHighlightSmall")
          row.multilineEditBox:SetTextColor(0.533, 0.533, 0.533)
          row.multilineEditBox:SetTextInsets(2, 2, 4, 2)
          row.multilineEditBox:SetAutoFocus(false)
          row.multilineEditBox:EnableMouse(false)
          row.multilineScrollFrame:SetScrollChild(row.multilineEditBox)

          row.multilineScrollFrame:SetScript("OnSizeChanged", function(self, w, h)
            row.multilineEditBox:SetWidth(w)
          end)
        end

        row.multilineFrame:ClearAllPoints()
        row.multilineFrame:SetPoint("TOPLEFT", cbOffsetX + 24, -24)
        row.multilineFrame:SetPoint("RIGHT", -30, 0)
        row.multilineFrame:SetHeight(80)
        row.multilineFrame:Show()

        row.multilineScrollFrame:ClearAllPoints()
        row.multilineScrollFrame:SetPoint("TOPLEFT", 8, -4)
        row.multilineScrollFrame:SetPoint("BOTTOMRIGHT", -26, 4)
        row.multilineEditBox:SetText(val)

        row:SetHeight(24 + 80 + 5)
      else
        -- No content: show [blank] inline instead of an empty text box.
        cb.text:SetText(" " .. node.name .. " |cFF888888[" .. L["blank"] .. "]|r")
        row:SetHeight(ROW_HEIGHT)
      end

    -- ---- Zoom-based curve graph ----
    elseif isZoomBased and zoomPoints and #zoomPoints >= 2 then
      local MINI_H = math.floor(77 * 1.5 * 1.5)   -- 172
      local MINI_W = math.floor(MINI_H * 3 / 4)   -- 129

      local range    = DynamicCam.cvarRanges[node.cvarName]
      local minValue = range and range.min or 0
      local maxValue = range and range.max or 1
      local maxZoom  = DynamicCam.cameraDistanceMaxZoomFactor_max

      cb.text:SetText(" " .. node.name .. " |cFF888888[" .. L["Zoom-based"] .. "]|r")

      -- Shared constants and label formatter (used by both axes).
      local charWidth  = 6.5  -- approx px/char for GameFontNormalSmall
      local lineHeight = 9    -- approx px/line for GameFontNormalSmall
      local axisGap    = 4    -- px gap between a label's edge and the graph edge

      local GC = DynamicCam.GRAPH_COLORS

      local function fmtLabel(v)
        local s = string.format("%.2f", v)
        s = s:gsub("0+$", "")   -- strip trailing zeros after decimal point
        s = s:gsub("%.$", "")   -- strip trailing decimal point if nothing left
        return s
      end

      -- Y-axis labels are zoom levels (always integers).
      local function fmtYLabel(v)
        return tostring(math.floor(v + 0.5))
      end

      -- Pre-compute Y-axis (zoom) label candidates so we know the label-column width
      -- before positioning the graph frame.
      -- y pixel = (1 - zoom/maxZoom) * MINI_H: zoom=0 → top, zoom=maxZoom → bottom.
      local yCandidates = {{y = 0, text = fmtYLabel(maxZoom)}}
      for i = 1, 4 do
        local y    = (i / 5) * MINI_H
        local zoom = maxZoom * (1 - i / 5)
        table.insert(yCandidates, {y = y, text = fmtYLabel(zoom)})
      end
      table.insert(yCandidates, {y = MINI_H, text = fmtYLabel(0)})
      table.sort(yCandidates, function(a, b) return a.y < b.y end)

      local maxYLabelW = 0
      for _, c in ipairs(yCandidates) do
        maxYLabelW = math.max(maxYLabelW, #c.text * charWidth)
      end
      -- Reserve space left of the graph: label width + gap + 2px safety margin.
      local Y_OFFSET = math.ceil(maxYLabelW) + axisGap + 2

      -- Lazily create the graph sub-frame on this row frame.
      if not row.graphFrame then
        row.graphFrame = CreateFrame("Frame", nil, row)
        row.graphFrame.bg = row.graphFrame:CreateTexture(nil, "BACKGROUND")
        row.graphFrame.bg:SetAllPoints()
        row.graphFrame.linePool = {}
        row.graphFrame.lineCount = 0
      end

      local graphFrame = row.graphFrame
      graphFrame:ClearAllPoints()
      graphFrame:SetPoint("TOPLEFT", cbOffsetX + 24 + Y_OFFSET, -24)
      graphFrame:SetSize(MINI_W, MINI_H)
      graphFrame:Show()

      graphFrame.bg:SetColorTexture(unpack(GC.gridBackground))

      -- Release any lines from a previous use of this graph frame.
      ReleaseAllLines(graphFrame)

      -- Helper to acquire a pooled line and configure it.
      local function PooledLine(startAnchor, sx, sy, endAnchor, ex, ey, thickness, r, g, b, a, layer)
        local line = AcquireLine(graphFrame)
        line:SetDrawLayer(layer or "ARTWORK")
        line:SetThickness(thickness)
        line:SetColorTexture(r, g, b, a)
        line:SetStartPoint(startAnchor, graphFrame, sx, sy)
        line:SetEndPoint(endAnchor, graphFrame, ex, ey)
      end

      -- Outer border (major grid colour)
      local gmR, gmG, gmB, gmA = unpack(GC.gridMajor)
      PooledLine("BOTTOMLEFT", 0, 0, "BOTTOMRIGHT", 0, 0, 1.5, gmR, gmG, gmB, gmA)
      PooledLine("TOPLEFT",    0, 0, "TOPRIGHT",    0, 0, 1.5, gmR, gmG, gmB, gmA)
      PooledLine("BOTTOMLEFT", 0, 0, "TOPLEFT",     0, 0, 1.5, gmR, gmG, gmB, gmA)
      PooledLine("BOTTOMRIGHT",0, 0, "TOPRIGHT",     0, 0, 1.5, gmR, gmG, gmB, gmA)

      -- Fixed grid: 4 interior horizontal lines (5 y-sections), 3 interior vertical lines (4 x-sections).
      for i = 1, 4 do
        PooledLine("BOTTOMLEFT", 0, (i/5)*MINI_H, "BOTTOMRIGHT", 0, (i/5)*MINI_H, 1, gmR, gmG, gmB, gmA)
      end
      for i = 1, 3 do
        PooledLine("BOTTOMLEFT", (i/4)*MINI_W, 0, "TOPLEFT", (i/4)*MINI_W, 0, 1, gmR, gmG, gmB, gmA)
      end

      -- Curve lines (OVERLAY so they render above the grid)
      local sorted = {}
      for idx, pt in ipairs(zoomPoints) do sorted[idx] = pt end
      table.sort(sorted, function(a, b) return a.zoom < b.zoom end)

      for idx = 1, #sorted - 1 do
        local x1 = ((sorted[idx].value   - minValue) / (maxValue - minValue)) * MINI_W
        local y1 = (1 - sorted[idx].zoom   / maxZoom) * MINI_H
        local x2 = ((sorted[idx+1].value - minValue) / (maxValue - minValue)) * MINI_W
        local y2 = (1 - sorted[idx+1].zoom / maxZoom) * MINI_H

        local line = AcquireLine(graphFrame)
        line:SetDrawLayer("OVERLAY")
        line:SetThickness(2)
        line:SetColorTexture(unpack(GC.curveLine))
        line:SetStartPoint("BOTTOMLEFT", graphFrame, x1, y1)
        line:SetEndPoint("BOTTOMLEFT",   graphFrame, x2, y2)
      end

      -- Y-axis labels (zoom): right-aligned left of the graph.
      do
        for i, c in ipairs(yCandidates) do
          local isLast = (i == #yCandidates)
          local lbl = AcquireFontString(row)
          if i == 1 then
            -- Bottom label (maxZoom): bottom-align with graph bottom
            lbl:SetPoint("BOTTOMRIGHT", graphFrame, "BOTTOMLEFT", -axisGap, 0)
          elseif isLast then
            -- Top label (zoom 0): top-align with graph top
            lbl:SetPoint("TOPRIGHT", graphFrame, "TOPLEFT", -axisGap, 0)
          else
            -- Interior labels: center-aligned
            lbl:SetPoint("RIGHT", graphFrame, "BOTTOMLEFT", -axisGap, c.y)
          end
          lbl:SetText(c.text)
          lbl:SetTextColor(unpack(GC.gridLabel))
        end
      end

      -- X-axis labels: min and max centered below the left/right graph borders; center skipped if it overlaps.
      do
        local minGap   = 4
        local wMin     = #fmtLabel(minValue) * charWidth
        local wMax     = #fmtLabel(maxValue) * charWidth
        local wCenter  = #fmtLabel((minValue + maxValue) / 2) * charWidth
        -- Min and max are centered on the border, so their half-width extends outside.
        -- Use only the inward-facing half for collision purposes.
        local minRight   = wMin / 2
        local maxLeft    = MINI_W - wMax / 2
        local cntLeft    = MINI_W / 2 - wCenter / 2
        local cntRight   = MINI_W / 2 + wCenter / 2

        -- Min label: centered below x=0 (left border)
        local lblMin = AcquireFontString(row)
        lblMin:SetPoint("TOP", graphFrame, "BOTTOMLEFT", 0, -7)
        lblMin:SetText(fmtLabel(minValue))
        lblMin:SetTextColor(unpack(GC.gridLabel))

        -- Center label: only if it clears min and max
        if cntLeft >= minRight + minGap and cntRight <= maxLeft - minGap then
          local lblCenter = AcquireFontString(row)
          lblCenter:SetPoint("TOP", graphFrame, "BOTTOMLEFT", MINI_W / 2, -7)
          lblCenter:SetText(fmtLabel((minValue + maxValue) / 2))
          lblCenter:SetTextColor(unpack(GC.gridLabel))
        end

        -- Max label: centered below x=MINI_W (right border)
        local lblMax = AcquireFontString(row)
        lblMax:SetPoint("TOP", graphFrame, "BOTTOMRIGHT", 0, -7)
        lblMax:SetText(fmtLabel(maxValue))
        lblMax:SetTextColor(unpack(GC.gridLabel))
      end

      row:SetHeight(24 + MINI_H + 14 + 5)

    -- ---- Simple single-line row ----
    else
      if node.get then
        local success, val = pcall(node.get)
        if success and val ~= nil then
          if type(val) == "number" then
            val = math.floor(val * 100 + 0.5) / 100
          end
          cb.text:SetText(" " .. node.name .. " |cFF888888[" .. tostring(val) .. "]|r")
        end
      end
      row:SetHeight(ROW_HEIGHT)
    end

    table.insert(allRows, row)

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

  -- Create all rows from treeData.
  for _, node in ipairs(treeData) do
    CreateRow(cf, node, 0, nil)
  end

  ReLayout()

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

      -- Reuse the existing view frame to avoid leaking frames.
      if not self.views[name] then
        local f = CreateFrame("Frame", nil, self.frame)
        f:SetPoint("TOPLEFT")
        f:SetPoint("TOPRIGHT")
        self.views[name] = f
      end

      local f = self.views[name]
      builder(self, f)

      self.currentView = f
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
    -- In classic, this texture is not included in the game files, so we use a local copy.
    local texturePath = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
      and "Interface\\Common\\CommonDropdownSettings2x"
      or  "Interface\\AddOns\\" .. folderName .. "\\BLP\\commondropdownsettings2x"

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
      local acr = LibStub("AceConfigRegistry-3.0")
      acr:NotifyChange("DynamicCam")
      acr:NotifyChange("DynamicCam_Detached")
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
      if self._registeredConfigId then
        local tbl = DynamicCam._activeZoomWidgets and DynamicCam._activeZoomWidgets[self._registeredConfigId]
        if tbl then tbl[self] = nil end
        self._registeredConfigId = nil
      end
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

      -- Unregister from previous configId (widget may be reused from pool)
      if self._registeredConfigId then
        local prev = DynamicCam._activeZoomWidgets[self._registeredConfigId]
        if prev then prev[self] = nil end
      end

      self.configId = configId
      self._registeredConfigId = configId

      -- Register in the active-widget table so editors can sync all instances
      if not DynamicCam._activeZoomWidgets then
        DynamicCam._activeZoomWidgets = {}
      end
      if not DynamicCam._activeZoomWidgets[configId] then
        DynamicCam._activeZoomWidgets[configId] = {}
      end
      DynamicCam._activeZoomWidgets[configId][self] = true
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
