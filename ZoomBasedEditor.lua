local folderName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

local GetCameraZoom = _G.GetCameraZoom


-------------------------------------------------------------------------------
-- ZOOM-BASED CURVE EDITOR (ButtonFrameTemplate)
--
-- Complete curve editor for zoom-based settings, built on ButtonFrameTemplate.
-- Users define control points on a graph where:
--   Y-axis = Camera zoom level (0 at top, max zoom at bottom)
--   X-axis = Setting value (min to max of the setting)
-- The system interpolates between points to get the value at any zoom level.
-------------------------------------------------------------------------------


------------
-- LOCALS --
------------

-- Colors (addon-wide, also used by the mini preview in Widgets.lua)
DynamicCam.GRAPH_COLORS = {
  curveLine = {0.8, 0.0, 0.0, 1.0},
  pointNormal = {0.8, 0.0, 0.0, 1.0},
  pointHighlight = {1.0, 1.0, 1.0, 1.0},
  gridLabel = {0.7, 0.7, 0.7},
  gridMajor = {0.4, 0.4, 0.5, 0.6},
  gridMinor = {0.3, 0.3, 0.4, 0.3},
  gridBackground = {0.0, 0.0, 0.25, 1},
}
local COLORS = DynamicCam.GRAPH_COLORS

-- Point display
local POINT_RADIUS = 8

-- Zoom constraints
local MIN_ZOOM_SPACING = 0.1
local EDGE_LABEL_THRESHOLD = 0.5
local VALUE_EDGE_THRESHOLD_PCT = 0.08
local ZOOM_INDICATOR_FRAME_LEVEL_OFFSET = 100

-- Frame dimensions
local EDITOR_WIDTH = 300
local EDITOR_HEIGHT = 450

-- Graph layout (padding inside the Inset)
local GRAPH_PADDING_TOP = 15
local GRAPH_PADDING_BOTTOM = 40
local GRAPH_PADDING_LEFT = 45
local GRAPH_PADDING_RIGHT = 15

-- Label spacing
local Y_AXIS_LABEL_OFFSET = -7
local X_AXIS_LABEL_OFFSET = -7

-- Snap threshold
local SNAP_THRESHOLD_DIVISOR = 100


---------------------
-- UTILITY FUNCTIONS
---------------------

local function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


local function CalculateNiceGridStep(minValue, maxValue, targetDivisions)
  local range = maxValue - minValue
  if range <= 0 then return 1, 0.5 end

  local roughStep = range / targetDivisions
  local magnitude = 10 ^ math.floor(math.log10(roughStep))
  local normalized = roughStep / magnitude

  local niceStep
  if normalized <= 1.5 then
    niceStep = 1
  elseif normalized <= 3 then
    niceStep = 2
  elseif normalized <= 7 then
    niceStep = 5
  else
    niceStep = 10
  end

  local majorStep = niceStep * magnitude
  local minorStep
  if niceStep == 1 or niceStep == 5 then
    minorStep = majorStep / 5
  else
    minorStep = majorStep / 4
  end

  return majorStep, minorStep
end


local function GenerateGridPositions(minValue, maxValue, step)
  local positions = {}
  local start = math.ceil(minValue / step) * step
  for pos = start, maxValue, step do
    pos = Round(pos, 6)
    if pos >= minValue and pos <= maxValue then
      table.insert(positions, pos)
    end
  end
  return positions
end


local function FindClosestValidZoom(desiredZoom, otherZooms, maxZoom)
  local minValid = MIN_ZOOM_SPACING
  local maxValid = maxZoom - MIN_ZOOM_SPACING

  desiredZoom = math.max(minValid, math.min(maxValid, desiredZoom))

  local function isValid(z)
    if z < minValid - 0.001 or z > maxValid + 0.001 then return false end
    for _, other in ipairs(otherZooms) do
      if math.abs(z - other) < MIN_ZOOM_SPACING - 0.001 then return false end
    end
    return true
  end

  if isValid(desiredZoom) then
    return desiredZoom
  end

  local candidates = {minValid, maxValid}
  for _, z in ipairs(otherZooms) do
    table.insert(candidates, z - MIN_ZOOM_SPACING)
    table.insert(candidates, z + MIN_ZOOM_SPACING)
  end

  local best = nil
  local bestDist = 999
  for _, candidate in ipairs(candidates) do
    if isValid(candidate) then
      local dist = math.abs(candidate - desiredZoom)
      if dist < bestDist then
        bestDist = dist
        best = candidate
      end
    end
  end

  return best or desiredZoom
end


local function SnapToGrid(value, minValue, maxValue, majorStep)
  local range = maxValue - minValue
  local snapThreshold = range / SNAP_THRESHOLD_DIVISOR

  local gridPositions = GenerateGridPositions(minValue, maxValue, majorStep)
  table.insert(gridPositions, minValue)
  table.insert(gridPositions, maxValue)

  for _, gridValue in ipairs(gridPositions) do
    if math.abs(value - gridValue) <= snapThreshold then
      return gridValue
    end
  end

  return value
end


-------------------------------------------------------------------------------
-- MULTI-EDITOR STATE MANAGEMENT
-------------------------------------------------------------------------------

local curveEditorFramePool = {}
local openEditors = {}
local editorStrataCounter = 0

-- Shared clipboard: stores normalized points (values in 0-1 range) so curves
-- can be pasted across settings with different value ranges.
local clipboard = nil

local function GetConfigId(situationId, cvarName)
  return (situationId or "standard") .. "_" .. cvarName
end


-------------------------------------------------------------------------------
-- POOL FUNCTIONS
-------------------------------------------------------------------------------

-- Point pool

local function CreatePointFrame(parent, editorFrame)
  local point = CreateFrame("Button", nil, parent)
  point:SetSize(POINT_RADIUS * 2, POINT_RADIUS * 2)
  point:EnableMouse(true)
  point:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  point.editorFrame = editorFrame

  point.texture = point:CreateTexture(nil, "OVERLAY")
  point.texture:SetAllPoints()
  point.texture:SetTexture("Interface\\COMMON\\Indicator-Red")
  point.texture:SetVertexColor(unpack(COLORS.pointNormal))

  return point
end


local function GetPointFromPool(editorFrame, parent)
  for _, point in ipairs(editorFrame.pointFramePool) do
    if not point:IsShown() then
      point:SetParent(parent)
      point.isDragging = false
      point.editorFrame = editorFrame
      point:Show()
      return point
    end
  end

  local newPoint = CreatePointFrame(parent, editorFrame)
  newPoint.isDragging = false
  table.insert(editorFrame.pointFramePool, newPoint)
  return newPoint
end


local function ReleaseAllPoints(editorFrame)
  for _, point in ipairs(editorFrame.activePointFrames) do
    point:Hide()
  end
  editorFrame.activePointFrames = {}
end


-- Grid line pool

local function GetGridLineFromPool(editorFrame, parent)
  for _, line in ipairs(editorFrame.gridLinePool) do
    if not line:IsShown() then
      line:Show()
      return line
    end
  end
  -- ARTWORK layer so curve lines on OVERLAY always render on top
  local newLine = parent:CreateLine(nil, "ARTWORK")
  table.insert(editorFrame.gridLinePool, newLine)
  return newLine
end

local function ReleaseAllGridLines(editorFrame)
  for _, line in ipairs(editorFrame.activeGridLines) do
    line:Hide()
  end
  editorFrame.activeGridLines = {}
end


-- Grid label pool

local function GetGridLabelFromPool(editorFrame)
  for _, label in ipairs(editorFrame.gridLabelPool) do
    if not label:IsShown() then
      label:Show()
      return label
    end
  end
  local newLabel = editorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  table.insert(editorFrame.gridLabelPool, newLabel)
  return newLabel
end

local function ReleaseAllGridLabels(editorFrame)
  for _, label in ipairs(editorFrame.activeGridLabelsZoom) do
    label:Hide()
  end
  for _, label in ipairs(editorFrame.activeGridLabelsValue) do
    label:Hide()
  end
  editorFrame.activeGridLabelsZoom = {}
  editorFrame.activeGridLabelsValue = {}
end


-- Curve line pool

local function GetCurveLineFromPool(editorFrame, parent)
  for _, line in ipairs(editorFrame.curveLinePool) do
    if not line:IsShown() then
      line:Show()
      return line
    end
  end
  local newLine = parent:CreateLine(nil, "OVERLAY")
  table.insert(editorFrame.curveLinePool, newLine)
  return newLine
end

local function ReleaseAllCurveLines(editorFrame)
  for _, line in ipairs(editorFrame.activeCurveLines) do
    line:Hide()
  end
  editorFrame.activeCurveLines = {}
end


-------------------------------------------------------------------------------
-- UI HELPERS
-------------------------------------------------------------------------------

local function HighlightPoint(point)
  point.texture:SetVertexColor(unpack(COLORS.pointHighlight))
end

local function UnhighlightPoint(point)
  point.texture:SetVertexColor(unpack(COLORS.pointNormal))
end

local function ShowPointTooltip(point, zoom, value)
  GameTooltip:SetOwner(point, "ANCHOR_RIGHT")
  GameTooltip:SetText(string.format("Zoom: %.1f\nValue: %.2f", zoom or 0, value or 0))
  GameTooltip:Show()
end

local function IsAnyPointDragging(editorFrame)
  if not editorFrame or not editorFrame.activePointFrames then return false end
  for _, p in ipairs(editorFrame.activePointFrames) do
    if p.isDragging then return true end
  end
  return false
end

local function SortPointsByZoom(points)
  table.sort(points, function(a, b) return a.zoom < b.zoom end)
end


-------------------------------------------------------------------------------
-- GRAPH COORDINATE CONVERSION
-------------------------------------------------------------------------------

-- Convert data values to graph coordinates (Y inverted: zoom 0 at top)
local function DataToGraph(zoom, value, minValue, maxValue, maxZoom, gw, gh)
  local graphX = ((value - minValue) / (maxValue - minValue)) * gw
  local graphY = (1 - zoom / maxZoom) * gh
  return graphX, graphY
end

-- Convert graph coordinates to data values
local function GraphToData(graphX, graphY, minValue, maxValue, maxZoom, gw, gh)
  local zoom = (1 - graphY / gh) * maxZoom
  local value = minValue + (graphX / gw) * (maxValue - minValue)
  return zoom, value
end

local function CollectOtherZooms(points, excludeIndex)
  local otherZooms = {}
  for i, pointData in ipairs(points) do
    if i ~= excludeIndex then
      table.insert(otherZooms, pointData.zoom)
    end
  end
  return otherZooms
end

local function CollectOtherZoomsFromFrames(pointFrames, excludePoint)
  local otherZooms = {}
  for _, otherPoint in ipairs(pointFrames) do
    if otherPoint ~= excludePoint then
      table.insert(otherZooms, otherPoint.zoom)
    end
  end
  return otherZooms
end


local function GetSituationStatus(info)
  local cvarName = info.cvarName
  local situationId = info.situationId
  local currentSitId = DynamicCam.currentSituationID
  local sc = DynamicCam.situationColors

  if situationId then
    local sitData = DynamicCam.db.profile.situations[situationId]
    local sitName = sitData and sitData.name or situationId
    local labelText = L["Situation Settings"] .. ": " .. sitName
    if not (sitData and sitData.enabled) then
      return sc.disabled .. labelText .. sc.colorEnd, false,
             sc.disabled .. L["Situation disabled."] .. sc.colorEnd
    end
    if sitData.errorEncountered then
      return sc.error .. labelText .. sc.colorEnd, false,
             sc.error .. L["Situation has a script error."] .. sc.colorEnd
    end
    if not DynamicCam.conditionExecutionCache[situationId] then
      return sc.inactive .. labelText .. sc.colorEnd, false,
             sc.inactive .. L["Situation enabled but condition not fulfilled."] .. sc.colorEnd
    end
    if currentSitId and currentSitId ~= situationId then
      local activeSit = DynamicCam.db.profile.situations[currentSitId]
      local activeSitName = activeSit and activeSit.name or currentSitId
      local coloredName = sc.active .. "\"" .. activeSitName .. "\"" .. sc.colorEnd
      return sc.overridden .. labelText .. sc.colorEnd, false,
             sc.overridden .. L["Currently overridden by the active situation %s."]:format(coloredName) .. sc.colorEnd
    end
    return sc.active .. labelText .. sc.colorEnd, true, nil
  else
    local labelText = L["Standard Settings"]
    if currentSitId then
      local activeSit = DynamicCam.db.profile.situations[currentSitId]
      if activeSit and activeSit.situationSettings then
        local ss = activeSit.situationSettings
        if (ss.cvars and ss.cvars[cvarName] ~= nil) or
           (ss.cvarsZoomBased and ss.cvarsZoomBased[cvarName] ~= nil) then
          local sitName = activeSit.name or currentSitId
          local coloredName = sc.active .. "\"" .. sitName .. "\"" .. sc.colorEnd
          return sc.overridden .. labelText .. sc.colorEnd, false,
                 sc.overridden .. L["Currently overridden by the active situation %s."]:format(coloredName) .. sc.colorEnd
        end
      end
    end
    return labelText, true, nil
  end
end


-- Forward declaration (defined further below).
local UpdateCurveEditor

-- Re-anchors the instructions text below whichever line-3 widget is visible, then
-- measures the rendered heights and repositions the Inset accordingly.
local function UpdateTopRegionLayout(f)
  f.instructions:ClearAllPoints()
  if f.currentZoomLabelText:IsShown() then
    f.instructions:SetPoint("TOPLEFT", f.currentZoomLabelText, "BOTTOMLEFT", 0, -4)
  else
    f.instructions:SetPoint("TOPLEFT", f.statusExplanation, "BOTTOMLEFT", 0, -4)
  end
  f.instructions:SetPoint("RIGHT", f, "RIGHT", -10, 0)

  -- Defer measurement by one frame so WoW layout has fully settled.
  C_Timer.After(0, function()
    if not f or not f:IsShown() then return end
    local frameTop = f:GetTop()
    local instrBottom = f.instructions:GetBottom()
    if not frameTop or not instrBottom then return end
    local topRegionHeight = math.ceil(frameTop - instrBottom) + 4
    if topRegionHeight ~= f.lastTopRegionHeight then
      f.lastTopRegionHeight = topRegionHeight
      f.Inset:ClearAllPoints()
      f.Inset:SetPoint("TOPLEFT",     f, "TOPLEFT",     10, -topRegionHeight)
      f.Inset:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -6,  26)
      UpdateCurveEditor(f)
    end
  end)
end


local function UpdateStatusDisplay(editorFrame, statusLabel, isActive, explanationText)
  editorFrame.isActive = isActive
  editorFrame.situationLabel:SetText(statusLabel)
  if isActive then
    editorFrame.currentZoomLabelText:Show()
    editorFrame.currentValueIndicator:Show()
    editorFrame.currentValueValue:Show()
    editorFrame.statusExplanation:Hide()
  else
    editorFrame.currentZoomLabelText:Hide()
    editorFrame.currentValueIndicator:Hide()
    editorFrame.currentValueValue:Hide()
    if explanationText then
      editorFrame.statusExplanation:SetText(explanationText)
      editorFrame.statusExplanation:Show()
    end
    if editorFrame.graphFrame and editorFrame.graphFrame.zoomIndicator then
      editorFrame.graphFrame.zoomIndicator:Hide()
    end
  end
  UpdateTopRegionLayout(editorFrame)
end


-------------------------------------------------------------------------------
-- BUTTON STATE HELPERS
-------------------------------------------------------------------------------

local function DeepCopyPoints(points)
  local copy = {}
  for i, point in ipairs(points) do
    copy[i] = {zoom = point.zoom, value = point.value}
  end
  return copy
end

local function HasUnsavedChanges(editorFrame)
  if not editorFrame.savedPoints or not editorFrame.cvarInfo then return false end
  local currentPoints = DynamicCam:GetZoomBasedPoints(editorFrame.cvarInfo.situationId, editorFrame.cvarInfo.cvarName)
  if not currentPoints then return false end
  if #currentPoints ~= #editorFrame.savedPoints then return true end
  local sortedCurrent = DeepCopyPoints(currentPoints)
  local sortedSaved = DeepCopyPoints(editorFrame.savedPoints)
  SortPointsByZoom(sortedCurrent)
  SortPointsByZoom(sortedSaved)
  for i = 1, #sortedCurrent do
    if sortedCurrent[i].zoom ~= sortedSaved[i].zoom or sortedCurrent[i].value ~= sortedSaved[i].value then
      return true
    end
  end
  return false
end

-- Visually grey out / restore a UIPanelButtonTemplate button to emulate disabled.
-- (WoW does not fire OnEnter on truly-disabled buttons, so we fake it.)
local function SetButtonActive(button, active)
  button.dcActive = active
  if active then
    if button.Left then button.Left:SetDesaturated(false) end
    if button.Right then button.Right:SetDesaturated(false) end
    if button.Middle then button.Middle:SetDesaturated(false) end
    if button:GetHighlightTexture() then
      button:GetHighlightTexture():SetAlpha(1)
    end
    button:GetFontString():SetTextColor(NORMAL_FONT_COLOR:GetRGB())
  else
    if button.Left then button.Left:SetDesaturated(true) end
    if button.Right then button.Right:SetDesaturated(true) end
    if button.Middle then button.Middle:SetDesaturated(true) end
    if button:GetHighlightTexture() then
      button:GetHighlightTexture():SetAlpha(0)
    end
    button:GetFontString():SetTextColor(DISABLED_FONT_COLOR:GetRGB())
  end
end

local function UpdateButtonStates(editorFrame)
  if not editorFrame.saveButton then return end
  local hasChanges = HasUnsavedChanges(editorFrame)
  SetButtonActive(editorFrame.saveButton, hasChanges)
  SetButtonActive(editorFrame.revertButton, hasChanges)
  SetButtonActive(editorFrame.pasteButton, clipboard ~= nil)
end

-- Refresh paste-button state on every open editor (called after copy).
local function UpdateAllPasteButtons()
  for _, frame in pairs(openEditors) do
    if frame:IsShown() and frame.pasteButton then
      SetButtonActive(frame.pasteButton, clipboard ~= nil)
    end
  end
end


-------------------------------------------------------------------------------
-- UPDATE CURVE EDITOR
-------------------------------------------------------------------------------

UpdateCurveEditor = function(editorFrame)
  if not editorFrame or not editorFrame:IsShown() or not editorFrame.cvarInfo then
    return
  end

  local info = editorFrame.cvarInfo
  local graphFrame = editorFrame.graphFrame
  local gw = graphFrame:GetWidth()
  local gh = graphFrame:GetHeight()
  if gw <= 0 or gh <= 0 then return end

  local maxZoom = DynamicCam.cameraDistanceMaxZoomFactor_max

  -- Update status display
  local statusLabel, isActive, explanationText = GetSituationStatus(info)
  UpdateStatusDisplay(editorFrame, statusLabel, isActive, explanationText)
  editorFrame.lastStatusKey = statusLabel .. (explanationText or "")

  -- Clear existing grid lines and labels (return to pools)
  ReleaseAllGridLines(editorFrame)
  ReleaseAllGridLabels(editorFrame)

  -- Draw grid line helper (uses pool)
  local function DrawGridLine(x1, y1, x2, y2, isMajor)
    local line = GetGridLineFromPool(editorFrame, graphFrame)
    line:SetThickness(1.5)
    if isMajor then
      line:SetColorTexture(unpack(COLORS.gridMajor))
    else
      line:SetColorTexture(unpack(COLORS.gridMinor))
    end
    line:SetStartPoint("BOTTOMLEFT", graphFrame, x1, y1)
    line:SetEndPoint("BOTTOMLEFT", graphFrame, x2, y2)
    table.insert(editorFrame.activeGridLines, line)
  end

  -- Calculate grid steps
  local zoomMajorStep, zoomMinorStep = CalculateNiceGridStep(0, maxZoom, 5)
  local valueMajorStep, valueMinorStep = CalculateNiceGridStep(info.minValue, info.maxValue, 5)
  editorFrame.cvarInfo.valueMajorStep = valueMajorStep

  -- Horizontal grid lines (zoom levels)
  DrawGridLine(0, gh, gw, gh, true)  -- Top border (zoom=0)
  DrawGridLine(0, 0, gw, 0, true)   -- Bottom border (zoom=max)

  local zoomMinorPositions = GenerateGridPositions(0, maxZoom, zoomMinorStep)
  for _, zoom in ipairs(zoomMinorPositions) do
    local _, y = DataToGraph(zoom, 0, info.minValue, info.maxValue, maxZoom, gw, gh)
    DrawGridLine(0, y, gw, y, false)
  end

  local zoomMajorPositions = GenerateGridPositions(0, maxZoom, zoomMajorStep)
  for _, zoom in ipairs(zoomMajorPositions) do
    local _, y = DataToGraph(zoom, 0, info.minValue, info.maxValue, maxZoom, gw, gh)
    DrawGridLine(0, y, gw, y, true)

    if zoom > EDGE_LABEL_THRESHOLD and zoom < maxZoom - EDGE_LABEL_THRESHOLD then
      local label = GetGridLabelFromPool(editorFrame)
      label:ClearAllPoints()
      label:SetPoint("RIGHT", graphFrame, "BOTTOMLEFT", Y_AXIS_LABEL_OFFSET, y)
      label:SetText(tostring(Round(zoom, 1)))
      label:SetTextColor(unpack(COLORS.gridLabel))
      table.insert(editorFrame.activeGridLabelsZoom, label)
    end
  end

  -- Edge zoom labels (zoom=0 at top, zoom=max at bottom)
  local zoomMinLabel = GetGridLabelFromPool(editorFrame)
  zoomMinLabel:ClearAllPoints()
  zoomMinLabel:SetPoint("RIGHT", graphFrame, "TOPLEFT", Y_AXIS_LABEL_OFFSET, 0)
  zoomMinLabel:SetText("0")
  zoomMinLabel:SetTextColor(unpack(COLORS.gridLabel))
  table.insert(editorFrame.activeGridLabelsZoom, zoomMinLabel)

  local zoomMaxLabel = GetGridLabelFromPool(editorFrame)
  zoomMaxLabel:ClearAllPoints()
  zoomMaxLabel:SetPoint("RIGHT", graphFrame, "BOTTOMLEFT", Y_AXIS_LABEL_OFFSET, 0)
  zoomMaxLabel:SetText(tostring(maxZoom))
  zoomMaxLabel:SetTextColor(unpack(COLORS.gridLabel))
  table.insert(editorFrame.activeGridLabelsZoom, zoomMaxLabel)

  -- Vertical grid lines (values)
  DrawGridLine(0, 0, 0, gh, true)   -- Left border (minValue)
  DrawGridLine(gw, 0, gw, gh, true) -- Right border (maxValue)

  local valueMinorPositions = GenerateGridPositions(info.minValue, info.maxValue, valueMinorStep)
  for _, value in ipairs(valueMinorPositions) do
    local x, _ = DataToGraph(0, value, info.minValue, info.maxValue, maxZoom, gw, gh)
    DrawGridLine(x, 0, x, gh, false)
  end

  local valueMajorPositions = GenerateGridPositions(info.minValue, info.maxValue, valueMajorStep)
  local valueRange = info.maxValue - info.minValue
  for _, value in ipairs(valueMajorPositions) do
    local x, _ = DataToGraph(0, value, info.minValue, info.maxValue, maxZoom, gw, gh)
    DrawGridLine(x, 0, x, gh, true)

    local distFromMin = math.abs(value - info.minValue)
    local distFromMax = math.abs(value - info.maxValue)
    local edgeThreshold = valueRange * VALUE_EDGE_THRESHOLD_PCT
    if distFromMin > edgeThreshold and distFromMax > edgeThreshold then
      local label = GetGridLabelFromPool(editorFrame)
      label:ClearAllPoints()
      label:SetPoint("TOP", graphFrame, "BOTTOMLEFT", x, X_AXIS_LABEL_OFFSET)
      local displayValue
      if math.abs(value) >= 100 then
        displayValue = tostring(Round(value, 0))
      elseif math.abs(value) >= 10 then
        displayValue = tostring(Round(value, 1))
      else
        displayValue = tostring(Round(value, 2))
      end
      label:SetText(displayValue)
      label:SetTextColor(unpack(COLORS.gridLabel))
      table.insert(editorFrame.activeGridLabelsValue, label)
    end
  end

  -- Edge value labels (minValue at left, maxValue at right)
  local valueMinLabel = GetGridLabelFromPool(editorFrame)
  valueMinLabel:ClearAllPoints()
  valueMinLabel:SetPoint("TOP", graphFrame, "BOTTOMLEFT", 0, X_AXIS_LABEL_OFFSET)
  valueMinLabel:SetText(tostring(info.minValue))
  valueMinLabel:SetTextColor(unpack(COLORS.gridLabel))
  table.insert(editorFrame.activeGridLabelsValue, valueMinLabel)

  local valueMaxLabel = GetGridLabelFromPool(editorFrame)
  valueMaxLabel:ClearAllPoints()
  valueMaxLabel:SetPoint("TOP", graphFrame, "BOTTOMRIGHT", 0, X_AXIS_LABEL_OFFSET)
  valueMaxLabel:SetText(tostring(info.maxValue))
  valueMaxLabel:SetTextColor(unpack(COLORS.gridLabel))
  table.insert(editorFrame.activeGridLabelsValue, valueMaxLabel)

  -- Clear existing points and curve lines
  ReleaseAllPoints(editorFrame)
  ReleaseAllCurveLines(editorFrame)

  -- Get points
  local points = DynamicCam:GetZoomBasedPoints(info.situationId, info.cvarName)
  if not points or #points < 2 then return end

  -- Draw curve (lines connecting points)
  SortPointsByZoom(points)

  for i = 1, #points - 1 do
    local x1, y1 = DataToGraph(points[i].zoom, points[i].value, info.minValue, info.maxValue, maxZoom, gw, gh)
    local x2, y2 = DataToGraph(points[i + 1].zoom, points[i + 1].value, info.minValue, info.maxValue, maxZoom, gw, gh)

    local line = GetCurveLineFromPool(editorFrame, graphFrame)
    line:SetThickness(2)
    line:SetColorTexture(unpack(COLORS.curveLine))
    line:SetStartPoint("BOTTOMLEFT", graphFrame, x1, y1)
    line:SetEndPoint("BOTTOMLEFT", graphFrame, x2, y2)
    table.insert(editorFrame.activeCurveLines, line)
  end

  -- Draw points
  for i, pointData in ipairs(points) do
    local point = GetPointFromPool(editorFrame, graphFrame)
    local x, y = DataToGraph(pointData.zoom, pointData.value, info.minValue, info.maxValue, maxZoom, gw, gh)

    point:ClearAllPoints()
    point:SetPoint("CENTER", graphFrame, "BOTTOMLEFT", x, y)
    point.zoom = pointData.zoom
    point.value = pointData.value
    point.pointIndex = i

    local isEndpoint = (i == 1 or i == #points)
    point.isEndpoint = isEndpoint
    UnhighlightPoint(point)

    -- Hover handlers
    point:SetScript("OnEnter", function(self)
      if IsAnyPointDragging(self.editorFrame) then return end
      HighlightPoint(self)
      ShowPointTooltip(self, self.zoom, self.value)
    end)

    point:SetScript("OnLeave", function(self)
      if IsAnyPointDragging(self.editorFrame) then return end
      UnhighlightPoint(self)
      GameTooltip:Hide()
    end)

    -- Right-click to delete (except endpoints)
    point:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp")
    point:SetScript("OnClick", function(self, button)
      if button == "RightButton" and not self.isEndpoint then
        table.remove(points, self.pointIndex)
        DynamicCam:SetZoomBasedPoints(info.situationId, info.cvarName, points)
        UpdateCurveEditor(editorFrame)
      end
    end)

    -- Drag handlers
    point:SetScript("OnMouseDown", function(self, button)
      if button == "LeftButton" then
        self.isDragging = true
        HighlightPoint(self)
        ShowPointTooltip(self, self.zoom, self.value)
      end
    end)

    point:SetScript("OnMouseUp", function(self, button)
      if button == "LeftButton" and self.isDragging then
        self.isDragging = false
        UnhighlightPoint(self)
        GameTooltip:Hide()

        local graphLeft = graphFrame:GetLeft()
        local graphBottom = graphFrame:GetBottom()
        if not graphLeft or not graphBottom then return end

        local pointX = self:GetLeft() + POINT_RADIUS
        local pointY = self:GetBottom() + POINT_RADIUS

        local relX = pointX - graphLeft
        local relY = pointY - graphBottom

        relX = math.max(0, math.min(relX, gw))
        relY = math.max(0, math.min(relY, gh))

        local newZoom, newValue = GraphToData(relX, relY, info.minValue, info.maxValue, maxZoom, gw, gh)

        if info.valueMajorStep then
          newValue = SnapToGrid(newValue, info.minValue, info.maxValue, info.valueMajorStep)
        end

        if self.isEndpoint then
          if self.pointIndex == 1 then
            newZoom = 0
          else
            newZoom = maxZoom
          end
        else
          local otherZooms = CollectOtherZooms(points, self.pointIndex)
          newZoom = FindClosestValidZoom(newZoom, otherZooms, maxZoom)
        end

        points[self.pointIndex].zoom = Round(newZoom, 1)
        points[self.pointIndex].value = Round(newValue, 2)

        DynamicCam:SetZoomBasedPoints(info.situationId, info.cvarName, points)
        UpdateCurveEditor(editorFrame)
      end
    end)

    table.insert(editorFrame.activePointFrames, point)
  end

  -- Zoom indicator (only shown when active)
  if graphFrame.zoomIndicator then
    graphFrame.zoomIndicator:Hide()
  end

  if editorFrame.isActive then
    local currentZoom = GetCameraZoom()
    local currentValue = DynamicCam:GetInterpolatedValue(info.situationId, info.cvarName, currentZoom)
    if not currentValue then
      currentValue = tonumber(GetCVar(info.cvarName)) or 0
    end
    local indicatorX, indicatorY = DataToGraph(currentZoom, currentValue, info.minValue, info.maxValue, maxZoom, gw, gh)

    if not graphFrame.zoomIndicator then
      graphFrame.zoomIndicator = CreateFrame("Frame", nil, graphFrame)
      graphFrame.zoomIndicator:SetSize(POINT_RADIUS * 2 + 2, POINT_RADIUS * 2 + 2)
      graphFrame.zoomIndicator:SetFrameLevel(graphFrame:GetFrameLevel() + ZOOM_INDICATOR_FRAME_LEVEL_OFFSET)
      graphFrame.zoomIndicator.texture = graphFrame.zoomIndicator:CreateTexture(nil, "OVERLAY")
      graphFrame.zoomIndicator.texture:SetAllPoints()
      graphFrame.zoomIndicator.texture:SetTexture("Interface\\COMMON\\Indicator-Green")
    end

    graphFrame.zoomIndicator:ClearAllPoints()
    graphFrame.zoomIndicator:SetPoint("CENTER", graphFrame, "BOTTOMLEFT", indicatorX, indicatorY)
    graphFrame.zoomIndicator:Show()

    editorFrame.currentValueValue:SetText(string.format("%.1f / %.2f", currentZoom, currentValue))
  end

  UpdateButtonStates(editorFrame)
end


-------------------------------------------------------------------------------
-- FRAME CREATION
-------------------------------------------------------------------------------

local function CreateZoomBasedEditorFrame()
  editorStrataCounter = editorStrataCounter + 1

  local frameName = "DynamicCamZoomEditor" .. editorStrataCounter
  local f = CreateFrame("Frame", frameName, UIParent, "ButtonFrameTemplate")

  ButtonFrameTemplate_HidePortrait(f)
  f:SetSize(EDITOR_WIDTH, EDITOR_HEIGHT)

  -- Offset each editor so they don't overlap exactly
  local offsetX = 100 + ((editorStrataCounter - 1) % 5) * 40
  local offsetY = -80 - ((editorStrataCounter - 1) % 5) * 40
  f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", offsetX, offsetY)

  f:SetFrameStrata("HIGH")
  f:SetToplevel(true)
  f:SetMovable(true)
  f:EnableMouse(true)
  f:SetClampedToScreen(true)

  -- Drag to move + raise (OnMouseDown fires immediately, no threshold)
  f:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
      self:Raise()
      self:StartMoving()
    end
  end)
  f:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
      self:StopMovingOrSizing()
    end
  end)

  -- ESC closing is handled by our CloseSpecialWindows wrapper in
  -- DetachFrame.lua (calling EscAllCurveEditors).  We intentionally
  -- do NOT register in UISpecialFrames because ShowUIPanel calls
  -- CloseSpecialWindows which would close editors when the game
  -- settings panel opens.

  -- Initialize per-frame pools
  f.pointFramePool = {}
  f.activePointFrames = {}
  f.gridLinePool = {}
  f.activeGridLines = {}
  f.gridLabelPool = {}
  f.activeGridLabelsZoom = {}
  f.activeGridLabelsValue = {}
  f.curveLinePool = {}
  f.activeCurveLines = {}

  -- Per-frame state
  f.cvarInfo = nil
  f.ownerWidget = nil

  -- Title
  f.TitleContainer.TitleText:SetText(L["DynamicCam: Zoom-Based Setting"])

  -- Override the default OnClick which calls HideUIPanel() (a secure function
  -- that is blocked during combat). We only need a plain Hide() here.
  f.CloseButton:SetScript("OnClick", function(self)
    self:GetParent():Hide()
  end)

  -- Close button tooltip
  f.CloseButton:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(L["Close"], 1, 0.82, 0, 1, true)
    GameTooltip:AddLine(L["<close_tooltip>"], 1, 1, 1, 1, true)
    GameTooltip:Show()
  end)
  f.CloseButton:HookScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Info labels (in top region above Inset)
  -- Line 1: CVAR name (bounded before the close button; clips if too long)
  f.settingLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  f.settingLabel:SetPoint("TOPLEFT", f.TopTileStreaks, "TOPLEFT", 6, -6)
  f.settingLabel:SetPoint("RIGHT", f, "RIGHT", -32, 0)
  f.settingLabel:SetJustifyH("LEFT")

  -- Invisible mouse-capture frame so the (potentially clipped) label shows a tooltip
  f.settingLabelHover = CreateFrame("Frame", nil, f)
  f.settingLabelHover:SetPoint("TOPLEFT",     f.settingLabel, "TOPLEFT",     0,  4)
  f.settingLabelHover:SetPoint("BOTTOMRIGHT", f.settingLabel, "BOTTOMRIGHT", 0, -4)
  f.settingLabelHover:EnableMouse(true)
  f.settingLabelHover:Hide()  -- shown only when text is truncated
  f.settingLabelHover:SetScript("OnEnter", function(self)
    if not f.cvarInfo then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(L["CVAR: "] .. f.cvarInfo.cvarName, 1, 0.82, 0)
    GameTooltip:Show()
  end)
  f.settingLabelHover:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Line 2: Situation/Standard label (colored by status)
  f.situationLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  f.situationLabel:SetPoint("TOPLEFT", f.settingLabel, "BOTTOMLEFT", 0, -4)
  f.situationLabel:SetPoint("TOPRIGHT", f.TopTileStreaks, "TOPRIGHT", -10, 0)
  f.situationLabel:SetJustifyH("LEFT")

  -- Line 3a: Current Zoom/Value (shown when active)
  f.currentZoomLabelText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  f.currentZoomLabelText:SetPoint("TOPLEFT", f.situationLabel, "BOTTOMLEFT", 0, -4)
  f.currentZoomLabelText:SetText(L["Current Zoom/Value:"])

  f.currentValueIndicator = CreateFrame("Frame", nil, f)
  f.currentValueIndicator:SetSize(POINT_RADIUS * 2, POINT_RADIUS * 2)
  f.currentValueIndicator:SetPoint("LEFT", f.currentZoomLabelText, "RIGHT", 5, 0)
  f.currentValueIndicator.texture = f.currentValueIndicator:CreateTexture(nil, "OVERLAY")
  f.currentValueIndicator.texture:SetAllPoints()
  f.currentValueIndicator.texture:SetTexture("Interface\\COMMON\\Indicator-Green")

  f.currentValueValue = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  f.currentValueValue:SetPoint("LEFT", f.currentValueIndicator, "RIGHT", 1, 1)
  f.currentValueValue:SetText("--- / ---")

  -- Line 3b: Status explanation (shown when inactive, replaces zoom/value line)
  f.statusExplanation = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  f.statusExplanation:SetPoint("TOPLEFT", f.situationLabel, "BOTTOMLEFT", 0, -4)
  f.statusExplanation:SetPoint("TOPRIGHT", f.TopTileStreaks, "TOPRIGHT", -10, 0)
  f.statusExplanation:SetJustifyH("LEFT")
  f.statusExplanation:SetWordWrap(true)
  f.statusExplanation:Hide()

  
  f.instructions = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  -- Instructions text (anchor is managed dynamically by UpdateTopRegionLayout)
  f.instructions:SetJustifyH("LEFT")
  f.instructions:SetWordWrap(true)
  f.instructions:SetTextColor(unpack(COLORS.gridLabel))
  f.instructions:SetText(L["Left-click: add/drag point\nRight-click: remove point"])

  -- Inset height is managed dynamically by UpdateTopRegionLayout.

  -- Graph frame inside the Inset
  f.graphFrame = CreateFrame("Frame", nil, f.Inset)
  f.graphFrame:SetPoint("TOPLEFT", f.Inset, "TOPLEFT", GRAPH_PADDING_LEFT, -GRAPH_PADDING_TOP)
  f.graphFrame:SetPoint("BOTTOMRIGHT", f.Inset, "BOTTOMRIGHT", -GRAPH_PADDING_RIGHT, GRAPH_PADDING_BOTTOM)

  -- Solid background for the grid.
  f.graphFrame.bg = f.graphFrame:CreateTexture(nil, "BACKGROUND")
  f.graphFrame.bg:SetAllPoints()
  f.graphFrame.bg:SetColorTexture(unpack(COLORS.gridBackground))


  -- Y-axis title (vertical)
  f.yAxisTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  f.yAxisTitle:SetPoint("RIGHT", f.graphFrame, "LEFT", Y_AXIS_LABEL_OFFSET - 14, 0)
  f.yAxisTitle:SetText(L["Z\no\no\nm"])
  f.yAxisTitle:SetJustifyH("CENTER")

  -- X-axis title
  f.xAxisTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  f.xAxisTitle:SetPoint("TOP", f.graphFrame, "BOTTOM", 0, X_AXIS_LABEL_OFFSET - 14)
  f.xAxisTitle:SetText(L["Value"])


  -- Bottom button bar: [Copy] [Paste] [Revert] [Save]
  -- Each button gets 1/4 of the frame width minus side padding and inter-button gaps.
  local BTN_SIDE_PAD = 4
  local BTN_GAP      = 1
  local BTN_H        = 22
  local BTN_Y        = 4
  local BTN_W        = (EDITOR_WIDTH - BTN_SIDE_PAD * 2 - BTN_GAP * 3) / 4

  -- Copy button (leftmost)
  f.copyButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  f.copyButton:SetSize(BTN_W, BTN_H)
  f.copyButton:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", BTN_SIDE_PAD + 2, BTN_Y)
  f.copyButton:SetText(L["Copy"])
  f.copyButton:SetScript("OnClick", function(self)
    if not f.cvarInfo then return end
    local info = f.cvarInfo
    local maxZoom = DynamicCam.cameraDistanceMaxZoomFactor_max
    local points = DynamicCam:GetZoomBasedPoints(info.situationId, info.cvarName)
    if not points or #points < 2 then return end
    local valueRange = info.maxValue - info.minValue
    -- Store normalized (0-1) values so the curve can be scaled to any range
    clipboard = {}
    for i, pt in ipairs(points) do
      clipboard[i] = {
        normZoom = pt.zoom / maxZoom,
        normValue = (valueRange > 0) and ((pt.value - info.minValue) / valueRange) or 0,
      }
    end
    UpdateAllPasteButtons()
  end)
  f.copyButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText(L["Copy"], 1, 0.82, 0, 1, true)
    GameTooltip:AddLine(L["<copy_tooltip>"], 1, 1, 1, 1, true)
    GameTooltip:Show()
  end)
  f.copyButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Paste button
  f.pasteButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  f.pasteButton:SetSize(BTN_W, BTN_H)
  f.pasteButton:SetPoint("LEFT", f.copyButton, "RIGHT", BTN_GAP, 0)
  f.pasteButton:SetText(L["Paste"])
  f.pasteButton:SetScript("OnClick", function(self)
    if not self.dcActive then return end
    if not clipboard or not f.cvarInfo then return end
    local info = f.cvarInfo
    local maxZoom = DynamicCam.cameraDistanceMaxZoomFactor_max
    -- Scale normalized clipboard points into the target value range
    local newPoints = {}
    for i, pt in ipairs(clipboard) do
      local scaledValue = info.minValue + pt.normValue * (info.maxValue - info.minValue)
      -- Scale zoom proportionally to current max zoom
      local scaledZoom = pt.normZoom * maxZoom
      newPoints[i] = {zoom = Round(scaledZoom, 1), value = Round(scaledValue, 2)}
    end
    -- Ensure endpoints are exactly at zoom 0 and maxZoom
    SortPointsByZoom(newPoints)
    newPoints[1].zoom = 0
    newPoints[#newPoints].zoom = maxZoom
    DynamicCam:SetZoomBasedPoints(info.situationId, info.cvarName, newPoints)
    DynamicCam:ResetZoomBasedSettingsCache()
    UpdateCurveEditor(f)
  end)
  f.pasteButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    if self.dcActive then
      GameTooltip:SetText(L["Paste"], 1, 0.82, 0, 1, true)
      GameTooltip:AddLine(L["<paste_tooltip>"], 1, 1, 1, 1, true)
    else
      GameTooltip:SetText(L["Paste"], 0.5, 0.5, 0.5, 1, true)
      GameTooltip:AddLine(L["<paste_disabled_tooltip>"], 1, 1, 1, 1, true)
    end
    GameTooltip:Show()
  end)
  f.pasteButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Revert button
  f.revertButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  f.revertButton:SetSize(BTN_W, BTN_H)
  f.revertButton:SetPoint("LEFT", f.pasteButton, "RIGHT", BTN_GAP, 0)
  f.revertButton:SetText(L["Revert"])
  f.revertButton:SetScript("OnClick", function(self)
    if not self.dcActive then return end
    -- Revert to last saved state
    if f.savedPoints and f.cvarInfo then
      DynamicCam:SetZoomBasedPoints(f.cvarInfo.situationId, f.cvarInfo.cvarName, DeepCopyPoints(f.savedPoints))
      local revertedValue = DynamicCam:GetInterpolatedValue(f.cvarInfo.situationId, f.cvarInfo.cvarName, GetCameraZoom())
      if revertedValue then
        SetCVar(f.cvarInfo.cvarName, revertedValue)
      end
      DynamicCam:ResetZoomBasedSettingsCache()
      UpdateCurveEditor(f)
    end
  end)
  f.revertButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    if self.dcActive then
      GameTooltip:SetText(L["Revert"], 1, 0.82, 0, 1, true)
      GameTooltip:AddLine(L["<revert_tooltip>"], 1, 1, 1, 1, true)
    else
      GameTooltip:SetText(L["Revert"], 0.5, 0.5, 0.5, 1, true)
      GameTooltip:AddLine(L["<revert_disabled_tooltip>"], 1, 1, 1, 1, true)
    end
    GameTooltip:Show()
  end)
  f.revertButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- Save button (rightmost)
  f.saveButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  f.saveButton:SetSize(BTN_W, BTN_H)
  f.saveButton:SetPoint("LEFT", f.revertButton, "RIGHT", BTN_GAP, 0)
  f.saveButton:SetText(L["Save"])
  f.saveButton:SetScript("OnClick", function(self)
    if not self.dcActive then return end
    -- Update savedPoints to current state
    local currentPoints = DynamicCam:GetZoomBasedPoints(f.cvarInfo.situationId, f.cvarInfo.cvarName)
    if currentPoints then
      f.savedPoints = DeepCopyPoints(currentPoints)
    end
    UpdateButtonStates(f)
    -- Refresh the export preview so it reflects the newly saved curve.
    local acr = LibStub("AceConfigRegistry-3.0")
    acr:NotifyChange("DynamicCam")
    acr:NotifyChange("DynamicCam_Detached")
  end)
  f.saveButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    if self.dcActive then
      GameTooltip:SetText(L["Save"], 1, 0.82, 0, 1, true)
      GameTooltip:AddLine(L["<save_tooltip>"], 1, 1, 1, 1, true)
    else
      GameTooltip:SetText(L["Save"], 0.5, 0.5, 0.5, 1, true)
      GameTooltip:AddLine(L["<save_disabled_tooltip>"], 1, 1, 1, 1, true)
    end
    GameTooltip:Show()
  end)
  f.saveButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)

  -- OnHide: handle Escape / CloseButton (X) - revert unsaved changes
  f:SetScript("OnHide", function(self)
    if self.isClosing then return end
    if self.suppressOnHide then return end
    -- Hidden by Escape or CloseButton - revert to last saved state
    if self.savedPoints and self.cvarInfo then
      DynamicCam:SetZoomBasedPoints(self.cvarInfo.situationId, self.cvarInfo.cvarName, self.savedPoints)
      local revertedValue = DynamicCam:GetInterpolatedValue(self.cvarInfo.situationId, self.cvarInfo.cvarName, GetCameraZoom())
      if revertedValue then
        SetCVar(self.cvarInfo.cvarName, revertedValue)
      end
      DynamicCam:ResetZoomBasedSettingsCache()
      self.savedPoints = nil
    end
    DynamicCam:CloseCurveEditorFrame(self)
  end)

  -- Click handler to add new points on the graph
  f.graphFrame:EnableMouse(true)
  f.graphFrame.addingNewPoint = false

  f.graphFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and f.cvarInfo then
      local info = f.cvarInfo
      local gw = self:GetWidth()
      local gh = self:GetHeight()
      local maxZoom = DynamicCam.cameraDistanceMaxZoomFactor_max

      local x, y = GetCursorPosition()
      local scale = self:GetEffectiveScale()
      x, y = x / scale, y / scale

      local graphLeft = self:GetLeft()
      local graphBottom = self:GetBottom()
      if not graphLeft or not graphBottom then return end

      local relX = x - graphLeft
      local relY = y - graphBottom

      if relX >= 0 and relX <= gw and relY >= 0 and relY <= gh then
        -- Check if clicked on an existing point
        local clickedOnPoint = false
        for _, point in ipairs(f.activePointFrames) do
          if point:IsMouseOver() then
            clickedOnPoint = true
            break
          end
        end

        if not clickedOnPoint then
          local newZoom, newValue = GraphToData(relX, relY, info.minValue, info.maxValue, maxZoom, gw, gh)
          local roundedZoom = Round(newZoom, 1)
          local roundedValue = Round(newValue, 2)

          local points = DynamicCam:GetZoomBasedPoints(info.situationId, info.cvarName)
          table.insert(points, {zoom = roundedZoom, value = roundedValue})
          DynamicCam:SetZoomBasedPoints(info.situationId, info.cvarName, points)

          self.addingNewPoint = true
          UpdateCurveEditor(f)

          -- Find the newly created point frame and start dragging it
          for _, pointFrame in ipairs(f.activePointFrames) do
            if math.abs(pointFrame.zoom - roundedZoom) < 0.05 and math.abs(pointFrame.value - roundedValue) < 0.05 then
              pointFrame.isDragging = true
              self.draggingNewPoint = pointFrame
              HighlightPoint(pointFrame)
              ShowPointTooltip(pointFrame, pointFrame.zoom, pointFrame.value)
              break
            end
          end
        end
      end
    end
  end)

  f.graphFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and self.addingNewPoint then
      self.addingNewPoint = false
      if self.draggingNewPoint and self.draggingNewPoint.isDragging then
        self.draggingNewPoint:GetScript("OnMouseUp")(self.draggingNewPoint, button)
      end
      self.draggingNewPoint = nil
    end
  end)

  -- OnShow: refresh the graph
  f:HookScript("OnShow", function(self)
    UpdateCurveEditor(self)
  end)

  -- OnUpdate for continuous zoom indicator updates and real-time dragging
  f.updateFrame = CreateFrame("Frame", nil, f)
  f.updateFrame:SetScript("OnUpdate", function(self, elapsed)
    if not f:IsShown() or not f.cvarInfo then return end

    local info = f.cvarInfo
    local graphFrame = f.graphFrame
    local gw = graphFrame:GetWidth()
    local gh = graphFrame:GetHeight()
    if gw <= 0 or gh <= 0 then return end
    local maxZoom = DynamicCam.cameraDistanceMaxZoomFactor_max

    -- Update situation status (can change at runtime)
    local statusLabel, isActive, explanationText = GetSituationStatus(info)
    local statusKey = statusLabel .. (explanationText or "")
    if statusKey ~= f.lastStatusKey then
      f.lastStatusKey = statusKey
      UpdateStatusDisplay(f, statusLabel, isActive, explanationText)
    end

    -- Check if any point is being dragged
    local draggingPoint = nil
    for _, point in ipairs(f.activePointFrames) do
      if point.isDragging then
        draggingPoint = point
        break
      end
    end

    DynamicCam:SetEditorDragging(draggingPoint ~= nil, info.cvarName)

    local tempPoints = nil

    if draggingPoint then
      local graphLeft = graphFrame:GetLeft()
      local graphBottom = graphFrame:GetBottom()

      if graphLeft and graphBottom then
        local cursorX, cursorY = GetCursorPosition()
        local scale = graphFrame:GetEffectiveScale()
        cursorX, cursorY = cursorX / scale, cursorY / scale

        local relX = cursorX - graphLeft
        local relY = cursorY - graphBottom

        relX = math.max(0, math.min(relX, gw))
        relY = math.max(0, math.min(relY, gh))

        local newZoom, newValue = GraphToData(relX, relY, info.minValue, info.maxValue, maxZoom, gw, gh)

        if info.valueMajorStep then
          newValue = SnapToGrid(newValue, info.minValue, info.maxValue, info.valueMajorStep)
        end

        if draggingPoint.isEndpoint then
          if draggingPoint.pointIndex == 1 then
            newZoom = 0
          else
            newZoom = maxZoom
          end
        else
          local otherZooms = CollectOtherZoomsFromFrames(f.activePointFrames, draggingPoint)
          newZoom = FindClosestValidZoom(newZoom, otherZooms, maxZoom)
        end

        local constrainedX, constrainedY = DataToGraph(newZoom, newValue, info.minValue, info.maxValue, maxZoom, gw, gh)
        draggingPoint:ClearAllPoints()
        draggingPoint:SetPoint("CENTER", graphFrame, "BOTTOMLEFT", constrainedX, constrainedY)

        draggingPoint.tempZoom = newZoom
        draggingPoint.tempValue = newValue

        if GameTooltip:GetOwner() ~= draggingPoint then
          GameTooltip:SetOwner(draggingPoint, "ANCHOR_RIGHT")
        end
        GameTooltip:ClearLines()
        GameTooltip:SetText(string.format("Zoom: %.1f\nValue: %.2f", newZoom, newValue))
        GameTooltip:Show()

        -- Redraw curve lines in real-time
        ReleaseAllCurveLines(f)

        tempPoints = {}
        for _, point in ipairs(f.activePointFrames) do
          if point == draggingPoint then
            table.insert(tempPoints, {zoom = draggingPoint.tempZoom, value = draggingPoint.tempValue, pointIndex = point.pointIndex})
          else
            table.insert(tempPoints, {zoom = point.zoom, value = point.value, pointIndex = point.pointIndex})
          end
        end
        table.sort(tempPoints, function(a, b) return a.zoom < b.zoom end)

        for i = 1, #tempPoints - 1 do
          local x1, y1 = DataToGraph(tempPoints[i].zoom, tempPoints[i].value, info.minValue, info.maxValue, maxZoom, gw, gh)
          local x2, y2 = DataToGraph(tempPoints[i + 1].zoom, tempPoints[i + 1].value, info.minValue, info.maxValue, maxZoom, gw, gh)

          local line = GetCurveLineFromPool(f, graphFrame)
          line:SetThickness(2)
          line:SetColorTexture(unpack(COLORS.curveLine))
          line:SetStartPoint("BOTTOMLEFT", graphFrame, x1, y1)
          line:SetEndPoint("BOTTOMLEFT", graphFrame, x2, y2)
          table.insert(f.activeCurveLines, line)
        end
      end
    end

    -- Update zoom indicator and apply cvar (only when active)
    if f.isActive then
      local currentZoom = GetCameraZoom()
      local currentValue

      if tempPoints then
        local lowerPoint = tempPoints[1]
        local upperPoint = tempPoints[#tempPoints]

        for i = 1, #tempPoints - 1 do
          if tempPoints[i].zoom <= currentZoom and tempPoints[i + 1].zoom >= currentZoom then
            lowerPoint = tempPoints[i]
            upperPoint = tempPoints[i + 1]
            break
          end
        end

        if upperPoint.zoom == lowerPoint.zoom then
          currentValue = lowerPoint.value
        else
          local t = (currentZoom - lowerPoint.zoom) / (upperPoint.zoom - lowerPoint.zoom)
          currentValue = lowerPoint.value + t * (upperPoint.value - lowerPoint.value)
        end

        if info.cvarName == "test_cameraOverShoulder" then
          DynamicCam.UpdateCurrentShoulderOffset(currentValue)
          SetCVar(info.cvarName, DynamicCam.ApplyCameraOverShoulderFixCompensation(currentValue))
        else
          SetCVar(info.cvarName, currentValue)
        end
      else
        currentValue = DynamicCam:GetInterpolatedValue(info.situationId, info.cvarName, currentZoom)
        if not currentValue then
          currentValue = tonumber(GetCVar(info.cvarName)) or 0
        end
      end

      local indicatorX, indicatorY = DataToGraph(currentZoom, currentValue, info.minValue, info.maxValue, maxZoom, gw, gh)

      if not graphFrame.zoomIndicator then
        graphFrame.zoomIndicator = CreateFrame("Frame", nil, graphFrame)
        graphFrame.zoomIndicator:SetSize(POINT_RADIUS * 2 + 2, POINT_RADIUS * 2 + 2)
        graphFrame.zoomIndicator:SetFrameLevel(graphFrame:GetFrameLevel() + ZOOM_INDICATOR_FRAME_LEVEL_OFFSET)
        graphFrame.zoomIndicator.texture = graphFrame.zoomIndicator:CreateTexture(nil, "OVERLAY")
        graphFrame.zoomIndicator.texture:SetAllPoints()
        graphFrame.zoomIndicator.texture:SetTexture("Interface\\COMMON\\Indicator-Green")
      end

      graphFrame.zoomIndicator:ClearAllPoints()
      graphFrame.zoomIndicator:SetPoint("CENTER", graphFrame, "BOTTOMLEFT", indicatorX, indicatorY)
      graphFrame.zoomIndicator:Show()

      f.currentValueValue:SetText(string.format("%.1f / %.2f", currentZoom, currentValue))
    end
  end)

  -- Store in pool
  table.insert(curveEditorFramePool, f)
  return f
end


-------------------------------------------------------------------------------
-- GET OR CREATE EDITOR FRAME
-------------------------------------------------------------------------------

local function GetEditorFrame(situationId, cvarName)
  local configId = GetConfigId(situationId, cvarName)

  -- If already open, return existing
  if openEditors[configId] then
    return openEditors[configId]
  end

  -- Look for a hidden frame in the pool to reuse
  for _, frame in ipairs(curveEditorFramePool) do
    if not frame:IsShown() then
      return frame
    end
  end

  -- Create new frame
  return CreateZoomBasedEditorFrame()
end


-------------------------------------------------------------------------------
-- DYNAMICCAM METHODS
-------------------------------------------------------------------------------

function DynamicCam:OpenCurveEditor(situationId, cvarName, minValue, maxValue, widget)
  local configId = GetConfigId(situationId, cvarName)

  -- If already open for this setting, just raise it
  if openEditors[configId] then
    local frame = openEditors[configId]
    if widget then
      frame.ownerWidget = widget
    end
    frame:Raise()
    frame:Show()
    return
  end

  local frame = GetEditorFrame(situationId, cvarName)

  -- Get current slider value to initialize the curve (if not already initialized)
  local currentValue = self:GetSettingsValue(situationId, "cvars", cvarName)

  -- Ensure the cvar is initialized for zoom-based
  self:SetCvarZoomBased(situationId, cvarName, true, currentValue)

  -- Store cvar info on the frame
  frame.cvarInfo = {
    situationId = situationId,
    cvarName = cvarName,
    minValue = minValue,
    maxValue = maxValue,
  }

  -- Store widget reference
  frame.ownerWidget = widget

  -- Store which profile this editor was opened in
  frame.openedInProfile = self.db:GetCurrentProfile()

  -- Save initial points as the "saved" checkpoint (deep copy)
  local currentPoints = self:GetZoomBasedPoints(situationId, cvarName)
  frame.savedPoints = DeepCopyPoints(currentPoints)

  -- Track open editor
  openEditors[configId] = frame

  -- Update cog-wheel state on any other widget instances for this configId
  -- (e.g. the same setting visible in both the SettingsPanel and detached frame).
  local peers = self._activeZoomWidgets and self._activeZoomWidgets[configId]
  if peers then
    for w in pairs(peers) do
      if w ~= widget then
        w.isEditorOpen = true
        w:UpdateButtonTextures()
      end
    end
  end

  -- Update labels
  frame.lastStatusKey = nil
  local prefix = L["CVAR: "]
  local fullText = prefix .. cvarName
  frame.settingLabel:SetText(fullText)
  -- availableWidth: EDITOR_WIDTH minus ~14px left inset (TopTileStreaks+6) and 32px for close button
  local availableWidth = EDITOR_WIDTH - 46
  if frame.settingLabel:GetStringWidth() > availableWidth then
    local truncated = cvarName
    repeat
      truncated = truncated:sub(1, #truncated - 1)
      frame.settingLabel:SetText(prefix .. truncated .. "...")
    until frame.settingLabel:GetStringWidth() <= availableWidth or #truncated == 0
    frame.settingLabelHover:Show()
  else
    frame.settingLabelHover:Hide()
  end
  local statusLabel, isActive, explanationText = GetSituationStatus(frame.cvarInfo)
  UpdateStatusDisplay(frame, statusLabel, isActive, explanationText)
  -- Show and raise
  frame:Raise()
  UpdateCurveEditor(frame)
  frame:Show()
  self.Options:ShowEscProxy()
end


function DynamicCam:CloseCurveEditorFrame(frame)
  if not frame then return end

  frame.isClosing = true
  frame:Hide()

  -- Clear the dragging flag for this editor's setting
  if frame.cvarInfo then
    self:SetEditorDragging(false, frame.cvarInfo.cvarName)

    -- Remove from open editors
    local configId = GetConfigId(frame.cvarInfo.situationId, frame.cvarInfo.cvarName)
    openEditors[configId] = nil
  end

  -- Update cog-wheel state on ALL widget instances for this configId
  -- (covers the ownerWidget plus any duplicate in the other panel).
  local configId2 = frame.cvarInfo and GetConfigId(frame.cvarInfo.situationId, frame.cvarInfo.cvarName)
  local peers = configId2 and self._activeZoomWidgets and self._activeZoomWidgets[configId2]
  if peers then
    for w in pairs(peers) do
      w.isEditorOpen = false
      w:UpdateButtonTextures()
    end
  elseif frame.ownerWidget then
    -- Fallback: only ownerWidget available (e.g. widget was released)
    frame.ownerWidget.isEditorOpen = false
    if frame.ownerWidget.UpdateButtonTextures then
      frame.ownerWidget:UpdateButtonTextures()
    end
  end
  frame.ownerWidget = nil

  frame.cvarInfo = nil
  frame.isClosing = nil
  self.Options:HideEscProxyIfNeeded()
end


function DynamicCam:CloseCurveEditor(situationId, cvarName)
  local configId = GetConfigId(situationId, cvarName)
  local frame = openEditors[configId]
  if frame then
    self:CloseCurveEditorFrame(frame)
  end
end


function DynamicCam:CloseAllCurveEditors()
  for configId, frame in pairs(openEditors) do
    self:CloseCurveEditorFrame(frame)
  end
end

function DynamicCam:HasVisibleCurveEditors()
  for _, frame in pairs(openEditors) do
    if frame:IsShown() then
      return true
    end
  end
  return false
end

-- Hide all open editors without isClosing so that OnHide reverts unsaved
-- changes (matching the original ESC-via-UISpecialFrames behaviour).
function DynamicCam:EscAllCurveEditors()
  local found = false
  local frames = {}
  for _, frame in pairs(openEditors) do
    if frame:IsShown() then
      found = true
      table.insert(frames, frame)
    end
  end
  for _, frame in ipairs(frames) do
    frame:Hide()
  end
  return found
end

function DynamicCam:RefreshAllCurveEditors()
  if self.refreshingCurveEditors then return end
  self.refreshingCurveEditors = true

  local currentProfile = self.db:GetCurrentProfile()

  for configId, frame in pairs(openEditors) do
    if frame:IsShown() and frame.cvarInfo then
      local info = frame.cvarInfo

      if frame.openedInProfile and frame.openedInProfile ~= currentProfile and frame.savedPoints then
        self.db:SetProfile(frame.openedInProfile)
        self:SetZoomBasedPoints(info.situationId, info.cvarName, frame.savedPoints)
        self.db:SetProfile(currentProfile)
      end

      frame.openedInProfile = currentProfile

      -- Close editors for cvars that are no longer zoom-based in the new profile
      if not self:IsCvarZoomBased(info.situationId, info.cvarName) then
        self:CloseCurveEditorFrame(frame)
      else
        local currentPoints = self:GetZoomBasedPoints(info.situationId, info.cvarName)
        if currentPoints then
          frame.savedPoints = DeepCopyPoints(currentPoints)
        end

        UpdateCurveEditor(frame)
      end
    end
  end

  self.refreshingCurveEditors = false
end


function DynamicCam:IsEditorOpenForSetting(situationId, cvarName)
  local configId = GetConfigId(situationId, cvarName)
  return openEditors[configId] ~= nil
end


-- Returns the last *saved* checkpoint for a zoom-based cvar.
-- If a curve editor is currently open for that cvar, it may have unsaved
-- in-progress changes in the db; this method returns savedPoints instead,
-- which is what the export should show.
function DynamicCam:GetSavedZoomBasedPoints(situationId, cvarName)
  local configId = GetConfigId(situationId, cvarName)
  local frame = openEditors[configId]
  if frame and frame.savedPoints then
    return frame.savedPoints
  end
  return self:GetZoomBasedPoints(situationId, cvarName)
end


function DynamicCam:UpdateEditorWidgetReference(widget)
  local config = self.zoomBasedControlConfigs and self.zoomBasedControlConfigs[widget.configId]
  if not config then return end

  local situationId = config.getSituationId()
  local cvarName = config.cvarName

  local configId = GetConfigId(situationId, cvarName)
  local frame = openEditors[configId]
  if frame then
    frame.ownerWidget = widget
  end
end



