local folderName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")
local LibEasing = LibStub("LibEasing-1.0")



local GetCameraZoom = _G.GetCameraZoom


-------------------------------------------------------------------------------
-- ZOOM-BASED SETTINGS
--
-- This module allows settings to be controlled by a curve based on zoom level.
-- Instead of a single value, users define points on a 2D graph where:
--   Y-axis = Camera zoom level (0 at top, max zoom at bottom)
--   X-axis = Setting value (min to max of the setting)
--
-- The system interpolates between points to get the value at any zoom level.
-------------------------------------------------------------------------------


------------
-- LOCALS --
------------

-- Colors
local COLORS = {
  pointNormal = {0.3, 0.7, 1.0, 1.0},
  pointHighlight = {0.5, 0.9, 1.0, 1.0},
  gridLabel = {0.7, 0.7, 0.7},
  gridMajor = {0.4, 0.4, 0.5, 0.6},
  gridMinor = {0.3, 0.3, 0.4, 0.3},
  curveLine = {0.3, 0.7, 1.0, 1.0},
}

-- Zoom constraints
local MIN_ZOOM_SPACING = 0.1
local EDGE_LABEL_THRESHOLD = 0.5
local VALUE_EDGE_THRESHOLD_PCT = 0.08
local NEW_POINT_MATCH_TOLERANCE = 0.15
local ZOOM_INDICATOR_FRAME_LEVEL_OFFSET = 100

local function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


-- Calculate a "nice" step size for grid lines
-- Returns major step and minor step
local function CalculateNiceGridStep(minValue, maxValue, targetDivisions)
  local range = maxValue - minValue
  if range <= 0 then return 1, 0.5 end
  
  local roughStep = range / targetDivisions
  
  -- Find the magnitude (power of 10)
  local magnitude = 10 ^ math.floor(math.log10(roughStep))
  
  -- Normalize to 1-10 range
  local normalized = roughStep / magnitude
  
  -- Round to nearest "nice" number: 1, 2, 2.5, 5, or 10
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
  
  -- Minor step is typically 1/5 or 1/4 of major, depending on major step
  local minorStep
  if niceStep == 1 or niceStep == 5 then
    minorStep = majorStep / 5
  else
    minorStep = majorStep / 4
  end
  
  return majorStep, minorStep
end


-- Generate grid line positions
local function GenerateGridPositions(minValue, maxValue, step)
  local positions = {}
  
  -- Start from the first multiple of step >= minValue
  local start = math.ceil(minValue / step) * step
  
  for pos = start, maxValue, step do
    -- Avoid floating point issues by rounding
    pos = Round(pos, 6)
    if pos >= minValue and pos <= maxValue then
      table.insert(positions, pos)
    end
  end
  
  return positions
end


-- Find the closest valid zoom position that maintains MIN_ZOOM_SPACING distance from all other points
local function FindClosestValidZoom(desiredZoom, otherZooms, maxZoom)
  local minValid = MIN_ZOOM_SPACING
  local maxValid = maxZoom - MIN_ZOOM_SPACING
  
  -- Clamp desired to valid range first
  desiredZoom = math.max(minValid, math.min(maxValid, desiredZoom))
  
  -- Check if a position is valid (at least MIN_ZOOM_SPACING from all other points)
  local function isValid(z)
    if z < minValid - 0.001 or z > maxValid + 0.001 then return false end
    for _, other in ipairs(otherZooms) do
      if math.abs(z - other) < MIN_ZOOM_SPACING - 0.001 then return false end
    end
    return true
  end
  
  -- If desired position is already valid, use it
  if isValid(desiredZoom) then
    return desiredZoom
  end
  
  -- Generate candidate positions: edges of valid range + positions just outside each existing point
  local candidates = {minValid, maxValid}
  for _, z in ipairs(otherZooms) do
    table.insert(candidates, z - MIN_ZOOM_SPACING)
    table.insert(candidates, z + MIN_ZOOM_SPACING)
  end
  
  -- Find the valid candidate closest to desired position
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
  
  return best or desiredZoom  -- Fallback if no valid position found
end


-------------------------------------------------------------------------------
-- MULTI-EDITOR STATE MANAGEMENT
-------------------------------------------------------------------------------

-- Pool of curve editor frames for reuse
local curveEditorFramePool = {}

-- Currently open editors keyed by configId (situationId + cvarName)
local openEditors = {}

-- Counter for strata management - newer editors appear on top
local editorStrataCounter = 0
local BASE_FRAME_LEVEL = 100

-- Generate a unique config ID for a cvar
local function GetConfigId(situationId, cvarName)
  return (situationId or "standard") .. "_" .. cvarName
end

-- Frame dimensions
local EDITOR_WIDTH = 350
local EDITOR_HEIGHT = 450
local GRAPH_PADDING_LEFT = 50
local GRAPH_PADDING_RIGHT = 20
local GRAPH_WIDTH = EDITOR_WIDTH - GRAPH_PADDING_LEFT - GRAPH_PADDING_RIGHT
local GRAPH_HEIGHT = 280

-- Point display
local POINT_RADIUS = 8

-- Label spacing
local Y_AXIS_LABEL_OFFSET = -7  -- Gap between graph and y-axis labels
local X_AXIS_LABEL_OFFSET = -7  -- Gap between graph and x-axis labels

-- Snap threshold (1/20 of the value range)
local SNAP_THRESHOLD_DIVISOR = 100

-- Snap a value to grid lines if close enough
local function SnapToGrid(value, minValue, maxValue, majorStep)
  local range = maxValue - minValue
  local snapThreshold = range / SNAP_THRESHOLD_DIVISOR
  
  -- Generate grid positions
  local gridPositions = GenerateGridPositions(minValue, maxValue, majorStep)
  
  -- Also include min and max as snap targets
  table.insert(gridPositions, minValue)
  table.insert(gridPositions, maxValue)
  
  -- Find closest grid position
  for _, gridValue in ipairs(gridPositions) do
    if math.abs(value - gridValue) <= snapThreshold then
      return gridValue
    end
  end
  
  return value  -- No snap, return original value
end



-------------------------------------------------------------------------------
-- DATA STRUCTURE FOR ZOOM-BASED SETTINGS
-------------------------------------------------------------------------------

--[[
  The zoom-based settings are stored within standardSettings or situationSettings,
  parallel to the existing 'cvars' table. The new table is called 'cvarsZoomBased'.
  
  Structure:
  
  DynamicCamDB.profiles[profileName].standardSettings.cvarsZoomBased = {
    ["cvarName"] = {
      enabled = true/false,
      points = {
        -- Array of {zoom, value} pairs, sorted by zoom
        -- There's always a point at zoom=0 and zoom=maxZoom
        {zoom = 0, value = 0.5},
        {zoom = 10, value = 1.0},
        {zoom = 39, value = 1.5},
      }
    }
  }
  
  For situation-specific settings:
  DynamicCamDB.profiles[profileName].situations[situationID].situationSettings.cvarsZoomBased = {
    ["cvarName"] = { enabled = ..., points = {...} }
  }
  
  Note: minValue and maxValue are NOT stored in SavedVariables.
  They are passed in when opening the curve editor (from the slider definition).
  When cvarsZoomBased[cvarName] is nil, the curve editor initializes the points
  using the current value from the non-zoom-based slider.
--]]


-- Helper to get the settings table for a situation or standard
local function GetSettingsTable(situationId)
  if situationId then
    local situation = DynamicCam.db.profile.situations[situationId]
    if situation then
      return situation.situationSettings
    end
    return nil
  else
    return DynamicCam.db.profile.standardSettings
  end
end


-- Get the zoom-based cvar data for a specific cvar
-- Returns nil if zoom-based is not enabled for this cvar
function DynamicCam:GetZoomBasedCvar(situationId, cvarName)
  local settings = GetSettingsTable(situationId)
  if settings and settings.cvarsZoomBased and
     settings.cvarsZoomBased[cvarName] and
     settings.cvarsZoomBased[cvarName].enabled then
    return settings.cvarsZoomBased[cvarName]
  end
  return nil
end


-- Check if a cvar is zoom-based
function DynamicCam:IsCvarZoomBased(situationId, cvarName)
  local setting = self:GetZoomBasedCvar(situationId, cvarName)
  return setting ~= nil and setting.enabled
end


-- Set whether a cvar should be zoom-based
-- currentValue is the current slider value, used for initializing default points
function DynamicCam:SetCvarZoomBased(situationId, cvarName, enabled, currentValue)
  local settings = GetSettingsTable(situationId)
  if not settings then return end

  -- Initialize cvarsZoomBased if needed
  if not settings.cvarsZoomBased then
    settings.cvarsZoomBased = {}
  end

  if not settings.cvarsZoomBased[cvarName] then
    -- Initialize with default points using current slider value
    -- This creates a flat line at the current value
    settings.cvarsZoomBased[cvarName] = {
      enabled = enabled,
      points = {
        {zoom = 0, value = currentValue},
        {zoom = self.cameraDistanceMaxZoomFactor_max, value = currentValue},
      }
    }
  else
    settings.cvarsZoomBased[cvarName].enabled = enabled
  end

  -- Trigger an immediate update if this is for the active situation
  local isActiveSituation = (situationId == nil and self.currentSituationID == nil)
                         or (situationId == self.currentSituationID)
  if isActiveSituation then
    -- Reset the cache so ZoomBasedUpdateFunction will recalculate all zoom-based cvars on next frame
    self:ResetZoomBasedSettingsCache()
    
    -- If we're disabling zoom-based mode, apply the current slider value immediately
    if not enabled then
      self:ApplySettings()
    end
  end

  -- Notify the UI to refresh so that the slider's disabled state updates
  LibStub("AceConfigRegistry-3.0"):NotifyChange("DynamicCam")
end


-- Get the points for a zoom-based cvar
function DynamicCam:GetZoomBasedPoints(situationId, cvarName)
  local setting = self:GetZoomBasedCvar(situationId, cvarName)
  if setting then
    return setting.points
  end
  return nil
end


-- Set the points for a zoom-based cvar
function DynamicCam:SetZoomBasedPoints(situationId, cvarName, points)
  local settings = GetSettingsTable(situationId)
  if not settings then return end

  if settings.cvarsZoomBased and settings.cvarsZoomBased[cvarName] then
    -- Sort points by zoom level
    table.sort(points, function(a, b) return a.zoom < b.zoom end)
    settings.cvarsZoomBased[cvarName].points = points
  end
end



-------------------------------------------------------------------------------
-- INTERPOLATION
-------------------------------------------------------------------------------

-- Cache for last used segment index per cvar (optimization to avoid searching all points every frame)
local lastSegmentIndices = {}

-- Calculate the setting value for a given zoom level using linear interpolation
function DynamicCam:GetInterpolatedValue(situationId, cvarName, zoomLevel)
  local setting = self:GetZoomBasedCvar(situationId, cvarName)
  if not setting or not setting.points or #setting.points < 2 then
    -- Fallback to regular setting
    return self:GetSettingsValue(situationId, "cvars", cvarName)
  end
  
  local points = setting.points
  
  -- Clamp zoom level to valid range
  zoomLevel = math.max(0, math.min(zoomLevel, self.cameraDistanceMaxZoomFactor_max))
  
  -- Find the two points to interpolate between
  local lowerPoint = points[1]
  local upperPoint = points[#points]
  
  -- Get or create cache table for this situation
  local sitKey = situationId or "standard"
  if not lastSegmentIndices[sitKey] then
    lastSegmentIndices[sitKey] = {}
  end
  
  -- Optimization: Try the last successful segment first (works well for incremental zoom changes or when zoom has not changed at all)
  local segmentIndex = nil
  local lastSegmentIndex = lastSegmentIndices[sitKey][cvarName]
  if lastSegmentIndex and lastSegmentIndex <= #points - 1 then
    if points[lastSegmentIndex].zoom <= zoomLevel and points[lastSegmentIndex + 1].zoom >= zoomLevel then
      segmentIndex = lastSegmentIndex
    end
  end
  
  -- If cached segment didn't work, search through all segments
  if not segmentIndex then
    for i = 1, #points - 1 do
      if points[i].zoom <= zoomLevel and points[i + 1].zoom >= zoomLevel then
        segmentIndex = i
        break
      end
    end
  end
  
  -- Use the found segment (or fallback to endpoints)
  if segmentIndex then
    lowerPoint = points[segmentIndex]
    upperPoint = points[segmentIndex + 1]
    lastSegmentIndices[sitKey][cvarName] = segmentIndex  -- Cache for next call
  end
  
  -- Linear interpolation
  if upperPoint.zoom == lowerPoint.zoom then
    return lowerPoint.value
  end
  
  local t = (zoomLevel - lowerPoint.zoom) / (upperPoint.zoom - lowerPoint.zoom)
  return lowerPoint.value + t * (upperPoint.value - lowerPoint.value)
end



-------------------------------------------------------------------------------
-- CURVE EDITOR UI
-------------------------------------------------------------------------------

local function DrawLine(parent, startX, startY, endX, endY, thickness, r, g, b, a)
  local line = parent:CreateLine()
  line:SetThickness(thickness)
  line:SetColorTexture(r, g, b, a)
  line:SetStartPoint("BOTTOMLEFT", parent, startX, startY)
  line:SetEndPoint("BOTTOMLEFT", parent, endX, endY)
  return line
end


-- Helper functions for point highlighting and tooltips
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


-- Helper to check if any point is being dragged in a specific editor
local function IsAnyPointDragging(editorFrame)
  if not editorFrame or not editorFrame.activePointFrames then return false end
  for _, p in ipairs(editorFrame.activePointFrames) do
    if p.isDragging then return true end
  end
  return false
end

local function CreatePointFrame(parent, editorFrame)
  local point = CreateFrame("Button", nil, parent)
  point:SetSize(POINT_RADIUS * 2, POINT_RADIUS * 2)
  point:EnableMouse(true)
  point:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  point.editorFrame = editorFrame  -- Store reference to owning editor
  
  -- Circle texture
  point.texture = point:CreateTexture(nil, "OVERLAY")
  point.texture:SetAllPoints()
  point.texture:SetTexture("Interface\\COMMON\\Indicator-Gray")
  point.texture:SetVertexColor(unpack(COLORS.pointNormal))
  
  -- Highlight on mouseover (but not while any point is being dragged)
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
  
  return point
end


local function GetPointFromPool(editorFrame, parent)
  for i, point in ipairs(editorFrame.pointFramePool) do
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


local function SortPointsByZoom(points)
  table.sort(points, function(a, b) return a.zoom < b.zoom end)
end


-- Convert graph coordinates to data values (Y is inverted: 0 at top)
local function GraphToData(graphX, graphY, minValue, maxValue, maxZoom)
  local zoom = (1 - graphY / GRAPH_HEIGHT) * maxZoom
  local value = minValue + (graphX / GRAPH_WIDTH) * (maxValue - minValue)
  return zoom, value
end


-- Helper to collect other point zooms for constraint checking
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


-- Grid line pool functions
local function GetGridLineFromPool(editorFrame, parent)
  for _, line in ipairs(editorFrame.gridLinePool) do
    if not line:IsShown() then
      line:Show()
      return line
    end
  end
  local newLine = parent:CreateLine()
  table.insert(editorFrame.gridLinePool, newLine)
  return newLine
end

local function ReleaseAllGridLines(editorFrame)
  for _, line in ipairs(editorFrame.activeGridLines) do
    line:Hide()
  end
  editorFrame.activeGridLines = {}
end


-- Grid label pool functions
local function GetGridLabelFromPool(editorFrame, parent)
  for _, label in ipairs(editorFrame.gridLabelPool) do
    if not label:IsShown() then
      label:Show()
      return label
    end
  end
  local newLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
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


-- Curve line pool functions
local function GetCurveLineFromPool(editorFrame, parent)
  for _, line in ipairs(editorFrame.curveLinePool) do
    if not line:IsShown() then
      line:Show()
      return line
    end
  end
  local newLine = parent:CreateLine()
  table.insert(editorFrame.curveLinePool, newLine)
  return newLine
end

local function ReleaseAllCurveLines(editorFrame)
  for _, line in ipairs(editorFrame.activeCurveLines) do
    line:Hide()
  end
  editorFrame.activeCurveLines = {}
end


-- Convert data values to graph coordinates (Y is inverted: 0 at top)
local function DataToGraph(zoom, value, minValue, maxValue, maxZoom)
  local graphX = ((value - minValue) / (maxValue - minValue)) * GRAPH_WIDTH
  local graphY = (1 - zoom / maxZoom) * GRAPH_HEIGHT
  return graphX, graphY
end


local function UpdateCurveEditor(editorFrame)
  if not editorFrame or not editorFrame:IsShown() or not editorFrame.cvarInfo then
    return
  end
  
  local info = editorFrame.cvarInfo
  local graphFrame = editorFrame.graphFrame
  
  -- Clear existing grid lines and labels (return to pools)
  ReleaseAllGridLines(editorFrame)
  ReleaseAllGridLabels(editorFrame)
  
  -- Draw grid line helper (uses pool)
  local function DrawGridLine(x1, y1, x2, y2, isMajor)
    local line = GetGridLineFromPool(editorFrame, graphFrame)
    line:SetThickness(1)
    if isMajor then
      line:SetColorTexture(unpack(COLORS.gridMajor))
    else
      line:SetColorTexture(unpack(COLORS.gridMinor))
    end
    line:SetStartPoint("BOTTOMLEFT", graphFrame, x1, y1)
    line:SetEndPoint("BOTTOMLEFT", graphFrame, x2, y2)
    table.insert(editorFrame.activeGridLines, line)
    return line
  end
  
  -- Calculate grid steps for zoom axis (Y)
  local zoomMajorStep, zoomMinorStep = CalculateNiceGridStep(0, DynamicCam.cameraDistanceMaxZoomFactor_max, 5)
  
  -- Calculate grid steps for value axis (X)
  local valueMajorStep, valueMinorStep = CalculateNiceGridStep(info.minValue, info.maxValue, 5)
  
  -- Store major step for snapping during dragging
  editorFrame.cvarInfo.valueMajorStep = valueMajorStep
  
  -- Draw horizontal grid lines (zoom levels)
  -- Border lines first (top and bottom edges)
  DrawGridLine(0, GRAPH_HEIGHT, GRAPH_WIDTH, GRAPH_HEIGHT, true)  -- Top border (zoom=0)
  DrawGridLine(0, 0, GRAPH_WIDTH, 0, true)  -- Bottom border (zoom=max)
  
  -- Minor lines
  local zoomMinorPositions = GenerateGridPositions(0, DynamicCam.cameraDistanceMaxZoomFactor_max, zoomMinorStep)
  for _, zoom in ipairs(zoomMinorPositions) do
    local _, y = DataToGraph(zoom, 0, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
    DrawGridLine(0, y, GRAPH_WIDTH, y, false)
  end
  
  -- Major horizontal lines with labels
  local zoomMajorPositions = GenerateGridPositions(0, DynamicCam.cameraDistanceMaxZoomFactor_max, zoomMajorStep)
  for _, zoom in ipairs(zoomMajorPositions) do
    local _, y = DataToGraph(zoom, 0, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
    DrawGridLine(0, y, GRAPH_WIDTH, y, true)
    
    -- Add label for this zoom level (skip if too close to edge labels)
    if zoom > EDGE_LABEL_THRESHOLD and zoom < DynamicCam.cameraDistanceMaxZoomFactor_max - EDGE_LABEL_THRESHOLD then
      local label = GetGridLabelFromPool(editorFrame, editorFrame)
      label:ClearAllPoints()
      label:SetPoint("RIGHT", graphFrame, "BOTTOMLEFT", Y_AXIS_LABEL_OFFSET, y)
      label:SetText(tostring(Round(zoom, 1)))
      label:SetTextColor(unpack(COLORS.gridLabel))
      table.insert(editorFrame.activeGridLabelsZoom, label)
    end
  end
  
  -- Draw vertical grid lines (values)
  -- Border lines first (left and right edges)
  DrawGridLine(0, 0, 0, GRAPH_HEIGHT, true)  -- Left border (minValue)
  DrawGridLine(GRAPH_WIDTH, 0, GRAPH_WIDTH, GRAPH_HEIGHT, true)  -- Right border (maxValue)
  
  -- Minor lines
  local valueMinorPositions = GenerateGridPositions(info.minValue, info.maxValue, valueMinorStep)
  for _, value in ipairs(valueMinorPositions) do
    local x, _ = DataToGraph(0, value, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
    DrawGridLine(x, 0, x, GRAPH_HEIGHT, false)
  end
  
  -- Major vertical lines with labels
  local valueMajorPositions = GenerateGridPositions(info.minValue, info.maxValue, valueMajorStep)
  local valueRange = info.maxValue - info.minValue
  for _, value in ipairs(valueMajorPositions) do
    local x, _ = DataToGraph(0, value, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
    DrawGridLine(x, 0, x, GRAPH_HEIGHT, true)
    
    -- Add label for this value (skip if too close to edge labels)
    local distFromMin = math.abs(value - info.minValue)
    local distFromMax = math.abs(value - info.maxValue)
    local edgeThreshold = valueRange * VALUE_EDGE_THRESHOLD_PCT
    if distFromMin > edgeThreshold and distFromMax > edgeThreshold then
      local label = GetGridLabelFromPool(editorFrame, editorFrame)
      label:ClearAllPoints()
      label:SetPoint("TOP", graphFrame, "BOTTOMLEFT", x, X_AXIS_LABEL_OFFSET)
      -- Format based on magnitude
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
  
  -- Clear existing elements
  ReleaseAllPoints(editorFrame)
  
  -- Clear existing curve lines (return to pool)
  ReleaseAllCurveLines(editorFrame)
  
  -- Get points
  local points = DynamicCam:GetZoomBasedPoints(info.situationId, info.cvarName)
  if not points or #points < 2 then return end
  
  -- Draw the curve (lines connecting points)
  SortPointsByZoom(points)
  
  for i = 1, #points - 1 do
    local x1, y1 = DataToGraph(points[i].zoom, points[i].value, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
    local x2, y2 = DataToGraph(points[i + 1].zoom, points[i + 1].value, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
    
    local line = GetCurveLineFromPool(editorFrame, graphFrame)
    line:SetThickness(2)
    line:SetColorTexture(unpack(COLORS.curveLine))
    line:SetStartPoint("BOTTOMLEFT", graphFrame, x1, y1)
    line:SetEndPoint("BOTTOMLEFT", graphFrame, x2, y2)
    table.insert(editorFrame.activeCurveLines, line)
  end
  
  -- Draw the points
  for i, pointData in ipairs(points) do
    local point = GetPointFromPool(editorFrame, graphFrame)
    local x, y = DataToGraph(pointData.zoom, pointData.value, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
    
    point:ClearAllPoints()
    point:SetPoint("CENTER", graphFrame, "BOTTOMLEFT", x, y)
    point.zoom = pointData.zoom
    point.value = pointData.value
    point.pointIndex = i
    
    -- Mark endpoints (cannot have their zoom changed)
    local isEndpoint = (i == 1 or i == #points)
    point.isEndpoint = isEndpoint
    UnhighlightPoint(point)  -- Reset to normal color
    
    -- Right-click to delete (except endpoints)
    point:SetScript("OnClick", function(self, button)
      if button == "RightButton" and not self.isEndpoint then
        -- Remove this point
        table.remove(points, self.pointIndex)
        DynamicCam:SetZoomBasedPoints(info.situationId, info.cvarName, points)
        UpdateCurveEditor(editorFrame)
      end
    end)
    
    -- Make points draggable with immediate response
    point:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp")
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
        
        -- Calculate final position
        local graphLeft = graphFrame:GetLeft()
        local graphBottom = graphFrame:GetBottom()
        
        if not graphLeft or not graphBottom then
          return
        end
        
        local pointX = self:GetLeft() + POINT_RADIUS
        local pointY = self:GetBottom() + POINT_RADIUS
        
        local relX = pointX - graphLeft
        local relY = pointY - graphBottom
        
        -- Clamp to graph bounds
        relX = math.max(0, math.min(relX, GRAPH_WIDTH))
        relY = math.max(0, math.min(relY, GRAPH_HEIGHT))
        
        local newZoom, newValue = GraphToData(relX, relY, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
        
        -- Snap value to grid if close enough
        if info.valueMajorStep then
          newValue = SnapToGrid(newValue, info.minValue, info.maxValue, info.valueMajorStep)
        end
        
        -- Endpoints can only move horizontally (value changes, zoom stays fixed)
        if self.isEndpoint then
          if self.pointIndex == 1 then
            newZoom = 0
          else
            newZoom = DynamicCam.cameraDistanceMaxZoomFactor_max
          end
        else
          -- For non-endpoints, find the closest valid zoom position
          local otherZooms = CollectOtherZooms(points, self.pointIndex)
          newZoom = FindClosestValidZoom(newZoom, otherZooms, DynamicCam.cameraDistanceMaxZoomFactor_max)
        end
        
        -- Update the point data
        points[self.pointIndex].zoom = Round(newZoom, 1)
        points[self.pointIndex].value = Round(newValue, 2)
        
        DynamicCam:SetZoomBasedPoints(info.situationId, info.cvarName, points)
        UpdateCurveEditor(editorFrame)
      end
    end)
    
    table.insert(editorFrame.activePointFrames, point)
  end
  
  -- Draw current zoom indicator
  if graphFrame.zoomIndicator then
    graphFrame.zoomIndicator:Hide()
  end
  
  local currentZoom = GetCameraZoom()
  local currentValue = DynamicCam:GetInterpolatedValue(info.situationId, info.cvarName, currentZoom)
  local indicatorX, indicatorY = DataToGraph(currentZoom, currentValue, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
  
  if not graphFrame.zoomIndicator then
    graphFrame.zoomIndicator = CreateFrame("Frame", nil, graphFrame)
    graphFrame.zoomIndicator:SetSize(POINT_RADIUS * 2 + 4, POINT_RADIUS * 2 + 4)
    graphFrame.zoomIndicator:SetFrameLevel(graphFrame:GetFrameLevel() + ZOOM_INDICATOR_FRAME_LEVEL_OFFSET)
    graphFrame.zoomIndicator.texture = graphFrame.zoomIndicator:CreateTexture(nil, "OVERLAY")
    graphFrame.zoomIndicator.texture:SetAllPoints()
    graphFrame.zoomIndicator.texture:SetTexture("Interface\\COMMON\\Indicator-Yellow")
  end
  
  graphFrame.zoomIndicator:ClearAllPoints()
  graphFrame.zoomIndicator:SetPoint("CENTER", graphFrame, "BOTTOMLEFT", indicatorX, indicatorY)
  graphFrame.zoomIndicator:Show()
  
  -- Update value labels (only the dynamic values, labels are static)
  editorFrame.currentZoomValue:SetText(string.format("%.1f", currentZoom))
  editorFrame.currentValueValue:SetText(string.format("%.2f", currentValue))
end


local function CreateCurveEditorFrame()
  -- Increment strata counter for new editors
  editorStrataCounter = editorStrataCounter + 1
  
  -- Main frame with similar styling to TableAttributeDisplay
  local frame = CreateFrame("Frame", "DynamicCamCurveEditor" .. editorStrataCounter, UIParent, "BackdropTemplate")
  frame:SetSize(EDITOR_WIDTH, EDITOR_HEIGHT)
  -- Offset each new editor slightly so they don't stack exactly
  local offsetX = 20 + ((editorStrataCounter - 1) % 5) * 30
  local offsetY = -20 - ((editorStrataCounter - 1) % 5) * 30
  frame:SetPoint("TOPLEFT", SettingsPanel, "TOPRIGHT", offsetX, offsetY)
  frame:SetFrameStrata("DIALOG")
  frame:SetFrameLevel(BASE_FRAME_LEVEL + editorStrataCounter)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:SetClampedToScreen(true)
  
  -- Immediate dragging without threshold - raise frame level and start moving
  frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
      editorStrataCounter = editorStrataCounter + 1
      self:SetFrameLevel(BASE_FRAME_LEVEL + editorStrataCounter)
      self:StartMoving()
    end
  end)
  
  frame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
      self:StopMovingOrSizing()
    end
  end)
  
  -- Initialize per-frame pools
  frame.pointFramePool = {}
  frame.activePointFrames = {}
  frame.gridLinePool = {}
  frame.activeGridLines = {}
  frame.gridLabelPool = {}
  frame.activeGridLabelsZoom = {}
  frame.activeGridLabelsValue = {}
  frame.curveLinePool = {}
  frame.activeCurveLines = {}
  
  -- Per-frame setting info and widget reference
  frame.cvarInfo = nil
  frame.ownerWidget = nil
  
  -- Backdrop
  frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
  frame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
  
  -- Title bar
  frame.titleBar = CreateFrame("Frame", nil, frame)
  frame.titleBar:SetPoint("TOPLEFT", 4, -4)
  frame.titleBar:SetPoint("TOPRIGHT", -4, -4)
  frame.titleBar:SetHeight(20)
  
  frame.titleBar.bg = frame.titleBar:CreateTexture(nil, "BACKGROUND")
  frame.titleBar.bg:SetAllPoints()
  frame.titleBar.bg:SetColorTexture(0.2, 0.2, 0.3, 1)
  
  frame.title = frame.titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
  frame.title:SetPoint("CENTER", frame.titleBar)
  frame.title:SetText(L["DynamicCam: Zoom-Based Setting"])
  
  -- Setting name label
  frame.settingLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.settingLabel:SetPoint("TOPLEFT", 15, -35)
  frame.settingLabel:SetText(L["CVAR: "])
  
  -- Graph frame (the actual drawing area)
  frame.graphFrame = CreateFrame("Frame", nil, frame)
  frame.graphFrame:SetSize(GRAPH_WIDTH, GRAPH_HEIGHT)
  local horizontalOffset = (GRAPH_PADDING_LEFT - GRAPH_PADDING_RIGHT) / 2
  frame.graphFrame:SetPoint("TOP", frame, "TOP", horizontalOffset, -65)
  
  -- Simple background without border
  frame.graphFrame.bg = frame.graphFrame:CreateTexture(nil, "BACKGROUND")
  frame.graphFrame.bg:SetAllPoints()
  frame.graphFrame.bg:SetColorTexture(0.05, 0.05, 0.1, 1)
  
  -- Y-axis label (Zoom)
  frame.yAxisLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.yAxisLabel:SetPoint("LEFT", frame.graphFrame, "LEFT", -40, 0)
  frame.yAxisLabel:SetText(L["Z\no\no\nm"])
  
  frame.yAxisMin = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.yAxisMin:SetPoint("RIGHT", frame.graphFrame, "TOPLEFT", Y_AXIS_LABEL_OFFSET, 0)
  frame.yAxisMin:SetText("0")
  frame.yAxisMin:SetTextColor(unpack(COLORS.gridLabel))
  
  frame.yAxisMax = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.yAxisMax:SetPoint("RIGHT", frame.graphFrame, "BOTTOMLEFT", Y_AXIS_LABEL_OFFSET, 0)
  frame.yAxisMax:SetText(tostring(DynamicCam.cameraDistanceMaxZoomFactor_max))
  frame.yAxisMax:SetTextColor(unpack(COLORS.gridLabel))
  
  -- X-axis label (Value)
  frame.xAxisLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.xAxisLabel:SetPoint("BOTTOM", frame.graphFrame, "BOTTOM", 0, -30)
  frame.xAxisLabel:SetText(L["Value"])
  
  frame.xAxisMin = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.xAxisMin:SetPoint("TOP", frame.graphFrame, "BOTTOMLEFT", 0, X_AXIS_LABEL_OFFSET)
  frame.xAxisMin:SetTextColor(unpack(COLORS.gridLabel))
  
  frame.xAxisMax = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.xAxisMax:SetPoint("TOP", frame.graphFrame, "BOTTOMRIGHT", 0, X_AXIS_LABEL_OFFSET)
  frame.xAxisMax:SetTextColor(unpack(COLORS.gridLabel))
  
  -- Current zoom/value display
  -- Static labels
  frame.currentZoomLabelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.currentZoomLabelText:SetPoint("BOTTOMLEFT", 35, 50)
  frame.currentZoomLabelText:SetText(L["Current Zoom:"])
  
  frame.currentValueLabelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.currentValueLabelText:SetPoint("BOTTOMLEFT", 35, 35)
  frame.currentValueLabelText:SetText(L["Current Value:"])
  
  -- Dynamic values (anchored to the right of labels)
  frame.currentZoomValue = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.currentZoomValue:SetPoint("LEFT", frame.currentZoomLabelText, "RIGHT", 5, 0)
  
  frame.currentValueValue = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.currentValueValue:SetPoint("LEFT", frame.currentValueLabelText, "RIGHT", 5, 0)
  
  -- Yellow indicator dot for current value
  frame.currentValueIndicator = CreateFrame("Frame", nil, frame)
  frame.currentValueIndicator:SetSize(20, 20)
  frame.currentValueIndicator:SetPoint("BOTTOMLEFT", 12, 38)
  frame.currentValueIndicator.texture = frame.currentValueIndicator:CreateTexture(nil, "OVERLAY")
  frame.currentValueIndicator.texture:SetAllPoints()
  frame.currentValueIndicator.texture:SetTexture("Interface\\COMMON\\Indicator-Yellow")


  -- Instructions
  frame.instructions = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.instructions:SetPoint("BOTTOMLEFT", 15, 15)
  frame.instructions:SetTextColor(unpack(COLORS.gridLabel))
  frame.instructions:SetText(L["Left-click: add/drag point | Right-click: remove point"])
  
  -- Cancel button
  frame.cancelButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  frame.cancelButton:SetSize(80, 22)
  frame.cancelButton:SetPoint("BOTTOMRIGHT", -15, 35)
  frame.cancelButton:SetText(L["Cancel"])
  frame.cancelButton:SetScript("OnClick", function()
    -- Revert all changes made since opening
    if frame.originalPoints and frame.cvarInfo then
      DynamicCam:SetZoomBasedPoints(frame.cvarInfo.situationId, frame.cvarInfo.cvarName, frame.originalPoints)
      frame.originalPoints = nil
    end
    DynamicCam:CloseCurveEditorFrame(frame)
  end)
  frame.cancelButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(L["Cancel"], 1, 1, 1)
    GameTooltip:AddLine(L["Close and revert all changes made since opening this editor."], nil, nil, nil, true)
    GameTooltip:Show()
  end)
  frame.cancelButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)
  
  -- OK button
  frame.okButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  frame.okButton:SetSize(80, 22)
  frame.okButton:SetPoint("RIGHT", frame.cancelButton, "LEFT", -5, 0)
  frame.okButton:SetText(L["OK"])
  frame.okButton:SetScript("OnClick", function()
    -- Changes are already applied, just clear the backup
    frame.originalPoints = nil
    DynamicCam:CloseCurveEditorFrame(frame)
  end)
  frame.okButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(L["OK"], 1, 1, 1)
    GameTooltip:AddLine(L["Close and keep all changes."], nil, nil, nil, true)
    GameTooltip:Show()
  end)
  frame.okButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)
  
  -- Click handler to add new points
  frame.graphFrame:EnableMouse(true)
  frame.graphFrame.addingNewPoint = false
  
  frame.graphFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" and frame.cvarInfo then
      local info = frame.cvarInfo
      
      -- Get click position relative to graph
      local x, y = GetCursorPosition()
      local scale = self:GetEffectiveScale()
      x, y = x / scale, y / scale
      
      local graphLeft = self:GetLeft()
      local graphBottom = self:GetBottom()
      
      if not graphLeft or not graphBottom then return end
      
      local relX = x - graphLeft
      local relY = y - graphBottom
      
      -- Check if click is within graph bounds
      if relX >= 0 and relX <= GRAPH_WIDTH and relY >= 0 and relY <= GRAPH_HEIGHT then
        -- Check if we clicked on an existing point
        local clickedOnPoint = false
        for _, point in ipairs(frame.activePointFrames) do
          if point:IsMouseOver() then
            clickedOnPoint = true
            break
          end
        end
        
        -- Only add new point if we didn't click on an existing one
        if not clickedOnPoint then
          local newZoom, newValue = GraphToData(relX, relY, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
          
          -- Store rounded values for finding the point after refresh
          local roundedZoom = Round(newZoom, 1)
          local roundedValue = Round(newValue, 2)
          
          -- Add new point (no tolerance check - constraint is handled during dragging)
          local points = DynamicCam:GetZoomBasedPoints(info.situationId, info.cvarName)
          table.insert(points, {zoom = roundedZoom, value = roundedValue})
          DynamicCam:SetZoomBasedPoints(info.situationId, info.cvarName, points)
          
          -- Mark that we're adding a new point
          self.addingNewPoint = true
          
          -- Refresh to create the visual point
          UpdateCurveEditor(frame)
          
          -- Find the newly created point frame by matching its zoom/value
          -- (points are sorted after UpdateCurveEditor, so we can't assume position)
          for _, pointFrame in ipairs(frame.activePointFrames) do
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
  
  frame.graphFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" and self.addingNewPoint then
      self.addingNewPoint = false
      
      -- Use stored reference to finalize the new point
      if self.draggingNewPoint and self.draggingNewPoint.isDragging then
        self.draggingNewPoint:GetScript("OnMouseUp")(self.draggingNewPoint, button)
      end
      self.draggingNewPoint = nil
    end
  end)
  
  -- Update on show
  frame:SetScript("OnShow", function(self)
    UpdateCurveEditor(self)
  end)
  
  -- Update frame for continuous zoom indicator updates and real-time dragging
  frame.updateFrame = CreateFrame("Frame", nil, frame)
  frame.updateFrame:SetScript("OnUpdate", function(self, elapsed)
    if not frame:IsShown() or not frame.cvarInfo then return end
    
    local info = frame.cvarInfo
    local graphFrame = frame.graphFrame
    
    -- Check if any point is being dragged for real-time positioning and curve updates
    local draggingPoint = nil
    for _, point in ipairs(frame.activePointFrames) do
      if point.isDragging then
        draggingPoint = point
        break
      end
    end
    
    -- Update the global dragging flag so ZoomBasedUpdateFunction doesn't conflict
    DynamicCam:SetEditorDragging(draggingPoint ~= nil, info.cvarName)
    
    local tempPoints = nil  -- Will hold temporary points if dragging
    
    if draggingPoint then
      local graphLeft = graphFrame:GetLeft()
      local graphBottom = graphFrame:GetBottom()
      
      if graphLeft and graphBottom then
        -- Get cursor position
        local cursorX, cursorY = GetCursorPosition()
        local scale = graphFrame:GetEffectiveScale()
        cursorX, cursorY = cursorX / scale, cursorY / scale
        
        local relX = cursorX - graphLeft
        local relY = cursorY - graphBottom
        
        -- Clamp X to graph bounds
        relX = math.max(0, math.min(relX, GRAPH_WIDTH))
        -- Clamp Y to graph bounds
        relY = math.max(0, math.min(relY, GRAPH_HEIGHT))
        
        local newZoom, newValue = GraphToData(relX, relY, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
        
        -- Snap value to grid if close enough
        if info.valueMajorStep then
          newValue = SnapToGrid(newValue, info.minValue, info.maxValue, info.valueMajorStep)
        end
        
        -- Endpoints can only move horizontally - keep their fixed zoom level
        if draggingPoint.isEndpoint then
          if draggingPoint.pointIndex == 1 then
            newZoom = 0
          else
            newZoom = DynamicCam.cameraDistanceMaxZoomFactor_max
          end
        else
          -- For non-endpoints, find the closest valid zoom position
          local otherZooms = CollectOtherZoomsFromFrames(frame.activePointFrames, draggingPoint)
          newZoom = FindClosestValidZoom(newZoom, otherZooms, DynamicCam.cameraDistanceMaxZoomFactor_max)
        end
        
        -- Calculate constrained position and move point there
        local constrainedX, constrainedY = DataToGraph(newZoom, newValue, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
        draggingPoint:ClearAllPoints()
        draggingPoint:SetPoint("CENTER", graphFrame, "BOTTOMLEFT", constrainedX, constrainedY)
        
        -- Update temporary display values for curve drawing
        draggingPoint.tempZoom = newZoom
        draggingPoint.tempValue = newValue
        
        -- Always update tooltip while dragging (force it to stay visible)
        if GameTooltip:GetOwner() ~= draggingPoint then
          GameTooltip:SetOwner(draggingPoint, "ANCHOR_RIGHT")
        end
        GameTooltip:ClearLines()
        GameTooltip:SetText(string.format("Zoom: %.1f\nValue: %.2f", newZoom, newValue))
        GameTooltip:Show()
        
        -- Redraw lines in real-time (release and reuse from pool)
        ReleaseAllCurveLines(frame)
        
        -- Build temporary points array with updated dragging position
        tempPoints = {}
        for _, point in ipairs(frame.activePointFrames) do
          if point == draggingPoint then
            table.insert(tempPoints, {zoom = draggingPoint.tempZoom, value = draggingPoint.tempValue, pointIndex = point.pointIndex})
          else
            table.insert(tempPoints, {zoom = point.zoom, value = point.value, pointIndex = point.pointIndex})
          end
        end
        table.sort(tempPoints, function(a, b) return a.zoom < b.zoom end)
        
        -- Draw lines between temporary points
        for i = 1, #tempPoints - 1 do
          local x1, y1 = DataToGraph(tempPoints[i].zoom, tempPoints[i].value, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
          local x2, y2 = DataToGraph(tempPoints[i + 1].zoom, tempPoints[i + 1].value, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
          
          local line = GetCurveLineFromPool(frame, graphFrame)
          line:SetThickness(2)
          line:SetColorTexture(unpack(COLORS.curveLine))
          line:SetStartPoint("BOTTOMLEFT", graphFrame, x1, y1)
          line:SetEndPoint("BOTTOMLEFT", graphFrame, x2, y2)
          table.insert(frame.activeCurveLines, line)
        end
      end
    end
    
    -- Update the zoom indicator (using temporary curve if dragging)
    local currentZoom = GetCameraZoom()
    local currentValue
    
    if tempPoints then
      -- Calculate interpolated value from temporary points
      local lowerPoint = tempPoints[1]
      local upperPoint = tempPoints[#tempPoints]
      
      for i = 1, #tempPoints - 1 do
        if tempPoints[i].zoom <= currentZoom and tempPoints[i + 1].zoom >= currentZoom then
          lowerPoint = tempPoints[i]
          upperPoint = tempPoints[i + 1]
          break
        end
      end
      
      -- Linear interpolation
      if upperPoint.zoom == lowerPoint.zoom then
        currentValue = lowerPoint.value
      else
        local t = (currentZoom - lowerPoint.zoom) / (upperPoint.zoom - lowerPoint.zoom)
        currentValue = lowerPoint.value + t * (upperPoint.value - lowerPoint.value)
      end
      
      -- Apply the value in real-time while dragging (direct CVar for immediate preview)
      -- Note: We set the raw curve value here. Any external post-processing (like
      -- CameraOverShoulderFix) is outside of DynamicCam's scope and not our concern.
      SetCVar(info.cvarName, currentValue)
    else
      -- Use normal interpolation from saved data
      currentValue = DynamicCam:GetInterpolatedValue(info.situationId, info.cvarName, currentZoom)
      -- Fallback to current CVar value if interpolation returns nil
      if not currentValue then
        currentValue = tonumber(GetCVar(info.cvarName)) or 0
      end
    end
    
    local indicatorX, indicatorY = DataToGraph(currentZoom, currentValue, info.minValue, info.maxValue, DynamicCam.cameraDistanceMaxZoomFactor_max)
    
    if graphFrame.zoomIndicator then
      graphFrame.zoomIndicator:ClearAllPoints()
      graphFrame.zoomIndicator:SetPoint("CENTER", graphFrame, "BOTTOMLEFT", indicatorX, indicatorY)
    end
    
    frame.currentZoomValue:SetText(string.format("%.1f", currentZoom))
    frame.currentValueValue:SetText(string.format("%.2f", currentValue))
  end)
  
  -- Store in pool
  table.insert(curveEditorFramePool, frame)
  return frame
end


-- Get or create an editor frame for a specific setting
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
  return CreateCurveEditorFrame()
end


-- Open the curve editor for a specific setting
function DynamicCam:OpenCurveEditor(situationId, cvarName, minValue, maxValue, displayName, widget)
  local configId = GetConfigId(situationId, cvarName)
  
  -- If already open for this setting, just raise it
  if openEditors[configId] then
    local frame = openEditors[configId]
    -- Update the widget reference in case the widget instance has changed
    if widget then
      frame.ownerWidget = widget
    end
    editorStrataCounter = editorStrataCounter + 1
    frame:SetFrameLevel(BASE_FRAME_LEVEL + editorStrataCounter)
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
    displayName = displayName or cvarName,
  }
  
  -- Store widget reference
  frame.ownerWidget = widget
  
  -- Store which profile this editor was opened in
  frame.openedInProfile = self.db:GetCurrentProfile()
  
  -- Save original points for cancel functionality (deep copy)
  local currentPoints = self:GetZoomBasedPoints(situationId, cvarName)
  frame.originalPoints = {}
  for i, point in ipairs(currentPoints) do
    frame.originalPoints[i] = {zoom = point.zoom, value = point.value}
  end
  
  -- Track open editor
  openEditors[configId] = frame
  
  -- Update labels
  frame.settingLabel:SetText(L["CVAR: "] .. (displayName or cvarName))
  frame.xAxisMin:SetText(tostring(minValue))
  frame.xAxisMax:SetText(tostring(maxValue))
  
  -- Raise to top
  editorStrataCounter = editorStrataCounter + 1
  frame:SetFrameLevel(BASE_FRAME_LEVEL + editorStrataCounter)
  
  -- Update and show
  UpdateCurveEditor(frame)
  frame:Show()
end


-- Close a specific curve editor frame
function DynamicCam:CloseCurveEditorFrame(frame)
  if not frame then return end
  
  frame:Hide()
  
  -- Clear the dragging flag for this editor's setting
  if frame.cvarInfo then
    self:SetEditorDragging(false, frame.cvarInfo.cvarName)
    
    -- Remove from open editors
    local configId = GetConfigId(frame.cvarInfo.situationId, frame.cvarInfo.cvarName)
    openEditors[configId] = nil
  end
  
  -- Notify the owning widget that the editor is closed
  if frame.ownerWidget then
    frame.ownerWidget.isEditorOpen = false
    if frame.ownerWidget.UpdateButtonTextures then
      frame.ownerWidget:UpdateButtonTextures()
    end
    frame.ownerWidget = nil
  end
  
  frame.cvarInfo = nil
end


-- Close the curve editor for a specific setting (by setting ID)
function DynamicCam:CloseCurveEditor(situationId, cvarName)
  local configId = GetConfigId(situationId, cvarName)
  local frame = openEditors[configId]
  if frame then
    self:CloseCurveEditorFrame(frame)
  end
end


-- Close all open curve editors
function DynamicCam:CloseAllCurveEditors()
  for configId, frame in pairs(openEditors) do
    self:CloseCurveEditorFrame(frame)
  end
end


-- Refresh all open curve editors (e.g., after profile change)
function DynamicCam:RefreshAllCurveEditors()
  local currentProfile = self.db:GetCurrentProfile()
  
  for configId, frame in pairs(openEditors) do
    if frame:IsShown() and frame.cvarInfo then
      local info = frame.cvarInfo
      
      -- If this editor was opened in a different profile, cancel any unsaved changes
      -- by restoring originalPoints to that old profile before switching
      if frame.openedInProfile and frame.openedInProfile ~= currentProfile and frame.originalPoints then
        -- Temporarily switch to the old profile
        self.db:SetProfile(frame.openedInProfile)
        
        -- Restore the original points (cancel unsaved changes)
        self:SetZoomBasedPoints(info.situationId, info.cvarName, frame.originalPoints)
        
        -- Switch back to the new profile
        self.db:SetProfile(currentProfile)
      end
      
      -- Update the profile tracking
      frame.openedInProfile = currentProfile
      
      -- Update original points from the new profile (for cancel functionality)
      local currentPoints = self:GetZoomBasedPoints(info.situationId, info.cvarName)
      if currentPoints then
        frame.originalPoints = {}
        for i, point in ipairs(currentPoints) do
          frame.originalPoints[i] = {zoom = point.zoom, value = point.value}
        end
      end
      
      -- Redraw the curve with new profile data
      UpdateCurveEditor(frame)
    end
  end
end


-- Check if the editor is currently open for a specific setting
function DynamicCam:IsEditorOpenForSetting(situationId, cvarName)
  local configId = GetConfigId(situationId, cvarName)
  return openEditors[configId] ~= nil
end


-- Update the widget reference for the currently open editor
-- Called when a widget is reacquired and detects its editor is still open
function DynamicCam:UpdateEditorWidgetReference(widget)
  -- Get the config from the widget's configId
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


-- Toggle the curve editor
function DynamicCam:ToggleCurveEditor(situationId, cvarName, minValue, maxValue, displayName)
  if self:IsEditorOpenForSetting(situationId, cvarName) then
    self:CloseCurveEditor(situationId, cvarName)
  else
    self:OpenCurveEditor(situationId, cvarName, minValue, maxValue, displayName)
  end
end



-------------------------------------------------------------------------------
-- ZOOM MONITORING AND VALUE APPLICATION
-------------------------------------------------------------------------------

-- Dedicated OnUpdate frame for continuously applying all zoom-based settings.
-- This handles all zoom-based cvars including test_cameraOverShoulder.
-- The frame runs independently, checking zoom level changes and updating cvars accordingly.
local zoomBasedUpdateFrame = CreateFrame("Frame")
local lastAppliedZoom = nil

-- Track which settings are actively being dragged in their curve editors
-- Key: cvarName, Value: true if dragging
local draggingCvars = {}

function DynamicCam:SetEditorDragging(dragging, cvarName)
  if cvarName then
    draggingCvars[cvarName] = dragging or nil
  end
end

function DynamicCam:IsEditorDraggingCvar(cvarName)
  return draggingCvars[cvarName] == true
end


-- Reset the last applied zoom (call when situation changes or settings are modified)
function DynamicCam:ResetZoomBasedSettingsCache()
  lastAppliedZoom = nil
end



-------------------------------------------------------------------------------
-- UNIFIED CVAR TRANSITION EASING
-------------------------------------------------------------------------------
--
-- When transitioning between situations, all cvars are eased from their current
-- values to their target values over the transition time. This works for both
-- zoom-based and non-zoom-based cvars.
--
-- For zoom-based cvars: start value is current curve at current zoom,
--                       target value is new curve at target zoom
-- For non-zoom-based cvars: start value is current cvar value,
--                           target value is new situation's value
--
-- If user manually zooms during transition, zoom-based easing is cancelled
-- and values snap to the new curve.
-------------------------------------------------------------------------------

-- Active easing state for each cvar
-- Key: cvarName, Value: { startValue, targetValue, startTime, duration, easingFunc, isZoomBased }
local activeCvarEasings = {}

-- Track the expected zoom during transition (to detect manual zoom)
local expectedZoomEasing = nil  -- { startZoom, targetZoom, startTime, duration, easingFunc }

-- Get current time (for easing calculations)
local function GetTime()
  return _G.GetTime()
end


-- Calculate expected zoom at current time during transition
local function GetExpectedZoom()
  if not expectedZoomEasing then return nil end
  
  local elapsed = GetTime() - expectedZoomEasing.startTime
  local t = elapsed / expectedZoomEasing.duration
  
  if t >= 1 then
    return expectedZoomEasing.targetZoom
  end
  
  -- Apply easing function to get interpolation factor (with fallback to linear if somehow nil)
  local easingFunc = expectedZoomEasing.easingFunc or LibEasing.Linear
  local easedT = easingFunc(t, 0, 1, 1)
  return expectedZoomEasing.startZoom + (expectedZoomEasing.targetZoom - expectedZoomEasing.startZoom) * easedT
end


-- Check if user has manually zoomed (actual zoom differs significantly from expected)
local function HasUserManuallyZoomed()
  if not expectedZoomEasing then return false end
  
  local expectedZoom = GetExpectedZoom()
  if not expectedZoom then return false end
  
  local actualZoom = _G.GetCameraZoom()
  -- Allow small tolerance for floating point and minor reactive zoom adjustments
  return math.abs(actualZoom - expectedZoom) > 0.5
end


-- Cancel all zoom-based easings (called when user manually zooms)
local function CancelZoomBasedEasings()
  for cvarName, easing in pairs(activeCvarEasings) do
    if easing.isZoomBased then
      activeCvarEasings[cvarName] = nil
    end
  end
  -- Also clear zoom expectation
  expectedZoomEasing = nil
end


-- Get the target value for a cvar in the new situation
local function GetTargetCvarValue(newSituationId, cvarName, targetZoom)
  -- Check if zoom-based for the new situation
  local newSettings
  if newSituationId then
    local situation = DynamicCam.db.profile.situations[newSituationId]
    if situation then
      newSettings = situation.situationSettings
    end
  else
    newSettings = DynamicCam.db.profile.standardSettings
  end
  
  -- Check if this cvar is zoom-based in the new situation
  if newSettings and newSettings.cvarsZoomBased and 
     newSettings.cvarsZoomBased[cvarName] and 
     newSettings.cvarsZoomBased[cvarName].enabled then
    -- Compute value from the new curve at target zoom
    local points = newSettings.cvarsZoomBased[cvarName].points
    if points and #points >= 2 then
      -- Find interpolation segment
      local lowerPoint = points[1]
      local upperPoint = points[#points]
      for i = 1, #points - 1 do
        if points[i].zoom <= targetZoom and points[i + 1].zoom >= targetZoom then
          lowerPoint = points[i]
          upperPoint = points[i + 1]
          break
        end
      end
      -- Linear interpolation
      if upperPoint.zoom == lowerPoint.zoom then
        return lowerPoint.value, true
      end
      local t = (targetZoom - lowerPoint.zoom) / (upperPoint.zoom - lowerPoint.zoom)
      return lowerPoint.value + t * (upperPoint.value - lowerPoint.value), true
    end
  end
  
  -- Not zoom-based, get direct value
  if newSettings and newSettings.cvars and newSettings.cvars[cvarName] ~= nil then
    return newSettings.cvars[cvarName], false
  end
  
  -- Fall back to standard settings
  local standardValue = DynamicCam.db.profile.standardSettings.cvars[cvarName]
  return standardValue, false
end


-- Start easing all cvars for a situation transition
-- Called from ChangeSituation()
function DynamicCam:StartCvarTransitionEasing(oldSituationId, newSituationId, currentZoom, targetZoom, transitionTime, easingFunc)
  -- Store which cvars were being eased before we clear (so we can read their current values)
  local wasBeingEased = {}
  for cvarName, _ in pairs(activeCvarEasings) do
    wasBeingEased[cvarName] = true
  end
  
  -- Clear any existing easings
  activeCvarEasings = {}
  expectedZoomEasing = nil
  
  -- If instant transition, don't set up easing
  -- CvarUpdateFunction will apply the direct values immediately
  if transitionTime <= 0 then
    return
  end
  
  -- Ensure we have a valid easing function (fallback to Linear)
  if not easingFunc then
    easingFunc = LibEasing.Linear
  end
  
  -- Store expected zoom easing (to detect manual zoom)
  if math.abs(currentZoom - targetZoom) > 0.01 then
    expectedZoomEasing = {
      startZoom = currentZoom,
      targetZoom = targetZoom,
      startTime = GetTime(),
      duration = transitionTime,
      easingFunc = easingFunc,
    }
  end
  
  -- Collect all cvars that need easing
  local cvarsToEase = {}
  
  -- Add all cvars from standard settings
  for cvarName, _ in pairs(self.db.profile.standardSettings.cvars) do
    cvarsToEase[cvarName] = true
  end
  
  -- Add any situation-specific cvars from new situation
  if newSituationId then
    local newSituation = self.db.profile.situations[newSituationId]
    if newSituation and newSituation.situationSettings.cvars then
      for cvarName, _ in pairs(newSituation.situationSettings.cvars) do
        cvarsToEase[cvarName] = true
      end
    end
  end
  
  -- Set up easing for each cvar
  local now = GetTime()
  for cvarName, _ in pairs(cvarsToEase) do
    local startValue
    if cvarName == "test_cameraOverShoulder" and DynamicCam.currentShoulderOffset then
      startValue = DynamicCam.currentShoulderOffset
    else
      startValue = tonumber(GetCVar(cvarName)) or 0
    end

    local targetValue, isZoomBased = GetTargetCvarValue(newSituationId, cvarName, targetZoom)
    
    -- Only set up easing if values differ
    if startValue and targetValue and math.abs(startValue - targetValue) > 0.0001 then
      activeCvarEasings[cvarName] = {
        startValue = startValue,
        targetValue = targetValue,
        startTime = now,
        duration = transitionTime,
        easingFunc = easingFunc,
        isZoomBased = isZoomBased,
      }
    end
  end
end


-- Check if a cvar has an active transition easing
function DynamicCam:IsCvarBeingEased(cvarName)
  return activeCvarEasings[cvarName] ~= nil
end


-- Get the eased value for a cvar (if being eased), or nil if not
local function GetEasedCvarValue(cvarName)
  local easing = activeCvarEasings[cvarName]
  if not easing then return nil end
  
  local elapsed = GetTime() - easing.startTime
  local t = elapsed / easing.duration
  
  if t >= 1 then
    -- Easing complete
    activeCvarEasings[cvarName] = nil
    return nil  -- Let normal value application take over
  end
  
  -- Apply easing function (with fallback to linear if somehow nil)
  local easingFunc = easing.easingFunc or LibEasing.Linear
  local easedT = easingFunc(t, 0, 1, 1)
  return easing.startValue + (easing.targetValue - easing.startValue) * easedT
end


-- The main update function that applies all cvar values (both eased transitions and zoom-based curves)
local function CvarUpdateFunction(self, elapsed)
  -- Skip if temporarily disabled
  if DynamicCam.shoulderOffsetZoomTmpDisable then return end
  
  -- Check for manual zoom (cancels zoom-based easings)
  if HasUserManuallyZoomed() then
    CancelZoomBasedEasings()
    DynamicCam:ResetZoomBasedSettingsCache()
  end
  
  -- Get current zoom (virtual or actual)
  local cameraZoom
  if DynamicCam.virtualCameraZoom ~= nil then
    cameraZoom = DynamicCam.virtualCameraZoom
  else
    cameraZoom = _G.GetCameraZoom()
  end
  
  -- Get the current situation's settings
  local situationId = DynamicCam.currentSituationID
  local settings = DynamicCam:GetSettingsTable(situationId)
  
  -- Track whether we need to update zoom-based values (optimization)
  local zoomChanged = not lastAppliedZoom or math.abs(cameraZoom - lastAppliedZoom) >= 0.01
  local hasActiveEasings = next(activeCvarEasings) ~= nil
  
  -- Skip if nothing to do
  if not zoomChanged and not hasActiveEasings then
    return
  end
  
  lastAppliedZoom = cameraZoom
  
  -- Process each cvar
  -- Collect all cvars we might need to apply
  local cvarsToCheck = {}
  for cvarName, _ in pairs(DynamicCam.db.profile.standardSettings.cvars) do
    cvarsToCheck[cvarName] = true
  end
  if settings and settings.cvars then
    for cvarName, _ in pairs(settings.cvars) do
      cvarsToCheck[cvarName] = true
    end
  end
  if settings and settings.cvarsZoomBased then
    for cvarName, _ in pairs(settings.cvarsZoomBased) do
      cvarsToCheck[cvarName] = true
    end
  end
  
  for cvarName, _ in pairs(cvarsToCheck) do
    -- Skip if curve editor is dragging this setting
    if DynamicCam:IsEditorDraggingCvar(cvarName) then
      -- Do nothing, editor handles preview
    else
      local value = nil
      
      -- Priority 1: Active transition easing
      value = GetEasedCvarValue(cvarName)
      
      -- Priority 2: Zoom-based curve (if no active easing)
      if value == nil and settings and settings.cvarsZoomBased and 
         settings.cvarsZoomBased[cvarName] and 
         settings.cvarsZoomBased[cvarName].enabled then
        value = DynamicCam:GetInterpolatedValue(situationId, cvarName, cameraZoom)
      end
      
      -- Priority 3: Direct value (non-zoom-based, not easing)
      if value == nil then
        value = DynamicCam:GetSettingsValue(situationId, "cvars", cvarName)
      end
      
      -- Apply the value if we have one
      if value ~= nil then
        -- Special handling for shoulder offset (CameraOverShoulderFix)
        if cvarName == "test_cameraOverShoulder" then
          -- Update currentShoulderOffset using the function that handles mounted sign-change detection
          DynamicCam.UpdateCurrentShoulderOffset(value)
          value = DynamicCam.ApplyCameraOverShoulderFixCompensation(value)
        end
        
        local currentValue = tonumber(_G.GetCVar(cvarName))
        if currentValue ~= value then
          _G.SetCVar(cvarName, value)
        end
      end
    end
  end
  
  -- Update easeShoulderOffsetInProgress flag for CameraOverShoulderFix
  -- (It checks this flag to know if it should hold off on adjustments)
  DynamicCam.easeShoulderOffsetInProgress = (activeCvarEasings["test_cameraOverShoulder"] ~= nil)
  
  -- Clean up completed zoom easing
  if expectedZoomEasing then
    local elapsed = GetTime() - expectedZoomEasing.startTime
    if elapsed >= expectedZoomEasing.duration then
      expectedZoomEasing = nil
    end
  end
end

-- Start the unified update frame
zoomBasedUpdateFrame:SetScript("OnUpdate", CvarUpdateFunction)




