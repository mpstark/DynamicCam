local LibCamera = LibStub("LibCamera-1.0")
local LibEasing = LibStub("LibEasing-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")


------------
-- LOCALS --
------------

local function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end




-------------------------
-- Minimal Zoom-Level  --
-------------------------


-- When zooming in, the mimimal third person zoom value depends on the current model.
-- We store this in a SaveVariable.

-- Initialize the SaveVariable if it does not yet exist.
if not minZoomValues then
  minZoomValues = {}
end


local function SetMinZoom(zoom)
  if not DynamicCam.modelFrame then return end

  DynamicCam.modelFrame:SetUnit("player")
  -- print("Storing", zoom, "for", DynamicCam.modelFrame:GetModelFileID())
  minZoomValues[DynamicCam.modelFrame:GetModelFileID()] = zoom
end

local function GetMinZoom()
  if IsMounted() then
    -- For mounted we just take a default instead of storing the value for each mount and player-model.
    return 1.5
  else

    if not DynamicCam.modelFrame then return 0.5 end

    -- If we have already stored the minimum value, return it. Else use a default.
    DynamicCam.modelFrame:SetUnit("player")
    return minZoomValues[DynamicCam.modelFrame:GetModelFileID()] or 1.5
  end
end

-- Set to true when zooming out from first person, such that the next zoom is stored as min value.
local storeMinZoom = false





-----------------------
-- NON-REACTIVE ZOOM --
-----------------------


-- To indicate if a non-reactive zoom is in progress.
-- This is needed to correct reactiveZoomTarget in case the target is missed.
local nonReactiveZoomStarted = false
local nonReactiveZoomInProgress = false
local nonReactiveZoomStartValue = GetCameraZoom()


local OldCameraZoomIn = CameraZoomIn
local OldCameraZoomOut = CameraZoomOut



-- Notice: The feature of zooming to the smallest third person zoom level does only work good for ReactiveZoom.
-- In NonReactiveZoom it only works if you set the zoom speed to max.
-- That's why we are not doing it for NonReactiveZoom.
local function NonReactiveZoom(zoomIn, increments)
  -- print("NonReactiveZoom", zoomIn, increments, GetCameraZoom())

  -- Stop zooming that might currently be in progress from a situation change.
  LibCamera:StopZooming(true)

  -- If we are not using this from within ReactiveZoom, we can also use the increment multiplier here.
  if not DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "reactiveZoomEnabled") then
    increments = increments + DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "reactiveZoomAddIncrementsAlways")

  else
    -- print("NonReactiveZoom starting", GetCameraZoom(), GetTime())
    nonReactiveZoomStarted = true
    nonReactiveZoomInProgress = false
    nonReactiveZoomStartValue = GetCameraZoom()
  end

  if zoomIn then
    OldCameraZoomIn(increments)
  else
    OldCameraZoomOut(increments)
  end
end


local function NonReactiveZoomIn(increments)
  -- No idea, why WoW does in-out-in-out with increments 0 after each mouse wheel turn.
  if increments == 0 then return end
  NonReactiveZoom(true, increments)
end

local function NonReactiveZoomOut(increments)
  -- No idea, why WoW does in-out-in-out with increments 0 after each mouse wheel turn.
  if increments == 0 then return end

  if storeMinZoom then
    -- print("User zoomed out again before reaching min value. Interrupting store process.")
    storeMinZoom = false
  end

  NonReactiveZoom(false, increments)
end




-------------------
-- REACTIVE ZOOM --
-------------------

local reactiveZoomTarget = nil

-- We have to be able to set this to nil whenever
-- SetZoom() or SetView() happens. Otherwise, the
-- next scroll wheel turn will scroll back
-- to the last zoom position.
function DynamicCam:ResetReactiveZoomTarget()
  reactiveZoomTarget = nil
end




-- This is needed to correct reactiveZoomTarget in case the target is missed.
local lastZoomForCorrection = GetCameraZoom()

local function ReactiveZoomTargetCorrectionFunction(_, elapsed)

  if not DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "reactiveZoomEnabled") then return end

  local currentZoom = GetCameraZoom()

  if nonReactiveZoomStarted and nonReactiveZoomStartValue ~= currentZoom then
    -- print("NonReactiveZoom just Started", nonReactiveZoomStartValue, GetTime())
    nonReactiveZoomInProgress = true
    nonReactiveZoomStarted = false
  elseif nonReactiveZoomInProgress and lastZoomForCorrection == currentZoom then
    -- print("NonReactiveZoom finished", GetTime())
    nonReactiveZoomInProgress = false
  end

  if not LibCamera:IsZooming() and not nonReactiveZoomStarted and not nonReactiveZoomInProgress and reactiveZoomTarget ~= currentZoom then
    -- print("Correcting reactiveZoomTarget", reactiveZoomTarget, "to", currentZoom, GetTime())
    reactiveZoomTarget = currentZoom

    if storeMinZoom then
      SetMinZoom(currentZoom)
      storeMinZoom = false
    end
  end

  lastZoomForCorrection = currentZoom
end

local reactiveZoomTargetCorrectionFrame = CreateFrame("Frame")




local function ReactiveZoom(zoomIn, increments)
  -- print("ReactiveZoom", zoomIn, increments, reactiveZoomTarget)

  increments = increments or 1

  -- If this is a "mouse wheel" CameraZoomIn/CameraZoomOut, increments is 1.
  -- Unlike a CameraZoomIn/CameraZoomOut from within LibCamera.SetZoomUsingCVar().
  if increments == 1 then
    local currentZoom = GetCameraZoom()

    local addIncrementsAlways = DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "reactiveZoomAddIncrementsAlways")
    local addIncrements = DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "reactiveZoomAddIncrements")
    local maxZoomTime = DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "reactiveZoomMaxZoomTime")
    local incAddDifference = DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "reactiveZoomIncAddDifference")
    local easingFunc = DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "reactiveZoomEasingFunc")


    -- scale increments up
    increments = increments + addIncrementsAlways

    if reactiveZoomTarget and math.abs(reactiveZoomTarget - currentZoom) > incAddDifference then
      increments = increments + addIncrements
    end



    -- if we've changed directions, make sure to reset
    if zoomIn then
      if reactiveZoomTarget and reactiveZoomTarget > currentZoom then
        reactiveZoomTarget = nil
      end
    else
      if reactiveZoomTarget and reactiveZoomTarget < currentZoom then
        reactiveZoomTarget = nil
      end
    end

    -- if there is already a target zoom, base off that one, or just use the current zoom
    reactiveZoomTarget = reactiveZoomTarget or currentZoom


    -- Always stop at closest third person zoom level.
    local minZoom = GetMinZoom()

    if zoomIn then

      if reactiveZoomTarget - increments < minZoom then

        if reactiveZoomTarget > minZoom then
          -- print("go to minZoom", minZoom)
          reactiveZoomTarget = minZoom

          -- Also update the increments if we need to make a NonReactiveZoom below,
          -- in case of "zoomTime < secondsPerFrame".
          increments = currentZoom - minZoom
        else
          -- print("go to 0")
          reactiveZoomTarget = 0

          -- No need to update increments because any zoom target below minZoom
          -- will result in 0 automatically.
        end

      else
        reactiveZoomTarget = math.max(0, reactiveZoomTarget - increments)
      end


    -- zoom out
    else

      -- From first person go directly into closest third person.
      if currentZoom == 0 then
        -- print("Giving this to non-reactive zoom")
        NonReactiveZoomOut(0.05)

        -- When this zoom is finished, store the minimal zoom distance,
        -- such that we can also use it while zooming in.
        if not IsMounted() then
          storeMinZoom = true
        end

        return
      else
        reactiveZoomTarget = math.min(GetCVar("cameraDistanceMaxZoomFactor")*15, reactiveZoomTarget + increments)
      end
    end


    -- if we don't need to zoom because we're at the max limits, then don't
    if (reactiveZoomTarget == DynamicCam.cameraDistanceMaxZoomFactor_max and currentZoom == DynamicCam.cameraDistanceMaxZoomFactor_max) or (reactiveZoomTarget == 0 and currentZoom == 0) then
      return
    end


    -- get the current time to zoom if we were going linearly or use maxZoomTime, if that's too high
    local zoomTime = math.min(maxZoomTime, math.abs(reactiveZoomTarget - currentZoom) / tonumber(GetCVar("cameraZoomSpeed")) )


    -- print ("Want to get from", currentZoom, "to", reactiveZoomTarget, "in", zoomTime, "with one frame being", DynamicCam.secondsPerFrame)
    if zoomTime < DynamicCam.secondsPerFrame then
      -- print("No easing for you", zoomTime, DynamicCam.secondsPerFrame, increments)

      if zoomIn then
        NonReactiveZoomIn(increments)
      else
        NonReactiveZoomOut(increments)
      end
    else
      -- print("REACTIVE ZOOM start", GetTime())
      -- LibCamera:SetZoom(reactiveZoomTarget, zoomTime, LibEasing[easingFunc], function() print("REACTIVE ZOOM end", GetTime()) end)
      LibCamera:SetZoom(reactiveZoomTarget, zoomTime, LibEasing[easingFunc])
    end

  else
    -- Called from within LibCamera.SetZoomUsingCVar(), through SetZoom() when the target zoom was missed.
    -- print("...this is no mouse wheel call!", increments)

    if zoomIn then
      NonReactiveZoomIn(increments)
    else
      NonReactiveZoomOut(increments)
    end
  end
end


local function ReactiveZoomIn(increments)
  -- No idea, why WoW does in-out-in-out with increments 0 after each mouse wheel turn.
  if increments == 0 then return end
  ReactiveZoom(true, increments)
end

local function ReactiveZoomOut(increments)
  -- No idea, why WoW does in-out-in-out with increments 0 after each mouse wheel turn.
  if increments == 0 then return end

  if storeMinZoom then
    -- print("User zoomed out again before reaching min value. Interrupting store process.")
    storeMinZoom = false
  end

  ReactiveZoom(false, increments)
end


function DynamicCam:ReactiveZoomOn()
  -- print("ReactiveZoomOn()")
  if CameraZoomIn == ReactiveZoomIn then
    -- print("already on")
    return
  end

  CameraZoomIn = ReactiveZoomIn
  CameraZoomOut = ReactiveZoomOut

  reactiveZoomTarget = GetCameraZoom()
  reactiveZoomTargetCorrectionFrame:SetScript("OnUpdate", ReactiveZoomTargetCorrectionFunction)
end

function DynamicCam:ReactiveZoomOff()
  -- print("ReactiveZoomOff()")
  if CameraZoomIn == NonReactiveZoomIn then
    -- print("already off")
    return
  end

  CameraZoomIn = NonReactiveZoomIn
  CameraZoomOut = NonReactiveZoomOut

  reactiveZoomTarget = nil
  reactiveZoomTargetCorrectionFrame:SetScript("OnUpdate", nil)
end


function DynamicCam:ReactiveZoomIsOn()
  return CameraZoomIn == ReactiveZoomIn
end



------------------------------------
-- ReactiveZoom Visual Aid (RZVA) --
------------------------------------

-- RZVA Colors
local RZVA_COLORS = {
  currentZoom = {1, 0.3, 0.3, 1},      -- Red for current zoom
  targetZoom = {0.3, 0.3, 1, 1},       -- Blue for target
  increment = {1, 1, 0, 1},            -- Yellow for increment
  gridLabel = {0.7, 0.7, 0.7},
  gridMajor = {0.4, 0.4, 0.5, 0.6},
  disabled = {0.3, 0.3, 0.3, 1},
}

-- RZVA Dimensions
local RZVA_WIDTH = 170
local RZVA_HEIGHT = 400
local RZVA_GRAPH_WIDTH = 120
local RZVA_GRAPH_HEIGHT = 250
local RZVA_GRAPH_HALF_WIDTH = RZVA_GRAPH_WIDTH / 2

local rzvaFrame = nil
local lastReactiveZoomTarget = reactiveZoomTarget
local reactiveZoomGraphUpdateFrame = CreateFrame("Frame")


local function RZVADrawLine(parent, startX, startY, endX, endY, thickness, r, g, b, a)
  local line = parent:CreateLine()
  line:SetThickness(thickness)
  line:SetColorTexture(r, g, b, a)
  line:SetStartPoint("BOTTOMLEFT", parent, startX, startY)
  line:SetEndPoint("BOTTOMLEFT", parent, endX, endY)
  return line
end


local function ReactiveZoomGraphUpdateFunction()
  local graphFrame = rzvaFrame.graphFrame
  local graphHeight = RZVA_GRAPH_HEIGHT
  local maxZoom = DynamicCam.cameraDistanceMaxZoomFactor_max
  local currentZoom = GetCameraZoom()
  
  -- Update current zoom marker.
  local currentY = graphHeight - (graphHeight * currentZoom / maxZoom)
  graphFrame.zm:ClearAllPoints()
  graphFrame.zm:SetPoint("BOTTOMRIGHT", graphFrame, "BOTTOMRIGHT", 0, currentY)
  rzvaFrame.cameraZoomValue:SetText(string.format("%.1f", currentZoom))

  if DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "reactiveZoomEnabled") then

    if not graphFrame.rzt:IsShown() then
      graphFrame.rzt:Show()
      graphFrame.rzi:Show()
      rzvaFrame.reactiveZoomTargetLabelText:SetTextColor(unpack(RZVA_COLORS.targetZoom))
      rzvaFrame.reactiveZoomTargetValue:SetTextColor(unpack(RZVA_COLORS.targetZoom))
    end

    graphFrame.rzt:ClearAllPoints()
    if reactiveZoomTarget then
      local targetY = graphHeight - (graphHeight * reactiveZoomTarget / maxZoom)
      graphFrame.rzt:SetPoint("BOTTOMLEFT", graphFrame, "BOTTOMLEFT", 0, targetY)

      rzvaFrame.reactiveZoomTargetValue:SetText(string.format("%.1f", reactiveZoomTarget))

      if lastReactiveZoomTarget then
        local step = lastReactiveZoomTarget - reactiveZoomTarget

        if step ~= 0 then
          graphFrame.rzi:SetHeight(graphHeight * math.abs(step) / maxZoom)
          graphFrame.rzi:Show()
        else
          graphFrame.rzi:Hide()
        end
      end

      lastReactiveZoomTarget = reactiveZoomTarget

    else
      graphFrame.rzi:Hide()
      graphFrame.rzt:Hide()
      rzvaFrame.reactiveZoomTargetValue:SetText("---")
    end

  else
    if graphFrame.rzt:IsShown() then
      graphFrame.rzt:Hide()
      graphFrame.rzi:Hide()
      rzvaFrame.reactiveZoomTargetLabelText:SetTextColor(unpack(RZVA_COLORS.disabled))
      rzvaFrame.reactiveZoomTargetValue:SetTextColor(unpack(RZVA_COLORS.disabled))
      rzvaFrame.reactiveZoomTargetValue:SetText("---")
    end
  end
end



function DynamicCam:ToggleRZVA()

  if not rzvaFrame then

    -- Main frame with same styling as curve editor
    rzvaFrame = CreateFrame("Frame", "DynamicCamRZVA", UIParent, "BackdropTemplate")
    rzvaFrame:SetSize(RZVA_WIDTH, RZVA_HEIGHT)
    rzvaFrame:SetPoint("BOTTOMRIGHT", SettingsPanel, "BOTTOMLEFT", -20, -20)
    rzvaFrame:SetFrameStrata("DIALOG")
    rzvaFrame:SetMovable(true)
    rzvaFrame:EnableMouse(true)
    rzvaFrame:SetClampedToScreen(true)

    -- Immediate dragging without threshold
    rzvaFrame:SetScript("OnMouseDown", function(self, button)
      if button == "LeftButton" then
        self:StartMoving()
      end
    end)
    rzvaFrame:SetScript("OnMouseUp", function(self, button)
      if button == "LeftButton" then
        self:StopMovingOrSizing()
      end
    end)

    -- Backdrop
    rzvaFrame:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true, tileSize = 16, edgeSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    rzvaFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    rzvaFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    -- Title bar
    rzvaFrame.titleBar = CreateFrame("Frame", nil, rzvaFrame)
    rzvaFrame.titleBar:SetPoint("TOPLEFT", 4, -4)
    rzvaFrame.titleBar:SetPoint("TOPRIGHT", -4, -4)
    rzvaFrame.titleBar:SetHeight(20)

    rzvaFrame.titleBar.bg = rzvaFrame.titleBar:CreateTexture(nil, "BACKGROUND")
    rzvaFrame.titleBar.bg:SetAllPoints()
    rzvaFrame.titleBar.bg:SetColorTexture(0.2, 0.2, 0.3, 1)

    rzvaFrame.title = rzvaFrame.titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    rzvaFrame.title:SetPoint("LEFT", rzvaFrame.titleBar, "LEFT", 5, 0)
    rzvaFrame.title:SetText(L["Reactive Zoom"])

    -- Close button
    rzvaFrame.closeButton = CreateFrame("Button", nil, rzvaFrame, "UIPanelCloseButton")
    rzvaFrame.closeButton:SetPoint("TOPRIGHT", -1, -1)
    rzvaFrame.closeButton:SetScript("OnClick", function()
      rzvaFrame:Hide()
    end)

    -- Graph frame (the visual area)
    rzvaFrame.graphFrame = CreateFrame("Frame", nil, rzvaFrame)
    rzvaFrame.graphFrame:SetSize(RZVA_GRAPH_WIDTH, RZVA_GRAPH_HEIGHT)
    rzvaFrame.graphFrame:SetPoint("TOP", rzvaFrame, "TOP", 7, -40)

    -- Graph background
    rzvaFrame.graphFrame.bg = rzvaFrame.graphFrame:CreateTexture(nil, "BACKGROUND")
    rzvaFrame.graphFrame.bg:SetAllPoints()
    rzvaFrame.graphFrame.bg:SetColorTexture(0.05, 0.05, 0.1, 1)

    -- Graph border lines
    local graphFrame = rzvaFrame.graphFrame
    RZVADrawLine(graphFrame, 0, 0, RZVA_GRAPH_WIDTH, 0, 1, unpack(RZVA_COLORS.gridMajor))  -- Bottom
    RZVADrawLine(graphFrame, 0, RZVA_GRAPH_HEIGHT, RZVA_GRAPH_WIDTH, RZVA_GRAPH_HEIGHT, 1, unpack(RZVA_COLORS.gridMajor))  -- Top
    RZVADrawLine(graphFrame, 0, 0, 0, RZVA_GRAPH_HEIGHT, 1, unpack(RZVA_COLORS.gridMajor))  -- Left
    RZVADrawLine(graphFrame, RZVA_GRAPH_WIDTH, 0, RZVA_GRAPH_WIDTH, RZVA_GRAPH_HEIGHT, 1, unpack(RZVA_COLORS.gridMajor))  -- Right

    -- Y-axis labels (Zoom values)
    rzvaFrame.yAxisMin = rzvaFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rzvaFrame.yAxisMin:SetPoint("RIGHT", graphFrame, "TOPLEFT", -5, 0)
    rzvaFrame.yAxisMin:SetText("0")
    rzvaFrame.yAxisMin:SetTextColor(unpack(RZVA_COLORS.gridLabel))

    rzvaFrame.yAxisMax = rzvaFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rzvaFrame.yAxisMax:SetPoint("RIGHT", graphFrame, "BOTTOMLEFT", -5, 0)
    rzvaFrame.yAxisMax:SetText(tostring(DynamicCam.cameraDistanceMaxZoomFactor_max))
    rzvaFrame.yAxisMax:SetTextColor(unpack(RZVA_COLORS.gridLabel))

    -- Current zoom marker (red, right side)
    graphFrame.zm = CreateFrame("Frame", nil, graphFrame)
    graphFrame.zm:SetSize(RZVA_GRAPH_HALF_WIDTH, 1)
    graphFrame.zm:Show()
    RZVADrawLine(graphFrame.zm, 0, 0, RZVA_GRAPH_HALF_WIDTH, 0, 5, unpack(RZVA_COLORS.currentZoom))

    -- Reactive zoom target marker (blue, left side)
    graphFrame.rzt = CreateFrame("Frame", nil, graphFrame)
    graphFrame.rzt:SetSize(RZVA_GRAPH_HALF_WIDTH, 1)
    graphFrame.rzt:Show()
    RZVADrawLine(graphFrame.rzt, 0, 0, RZVA_GRAPH_HALF_WIDTH, 0, 5, unpack(RZVA_COLORS.targetZoom))

    -- Reactive zoom increment marker (yellow area)
    graphFrame.rzi = CreateFrame("Frame", nil, graphFrame)
    graphFrame.rzi:SetWidth(RZVA_GRAPH_HALF_WIDTH)
    graphFrame.rzi:SetPoint("TOP", graphFrame.rzt, "BOTTOM", 0, 0)
    graphFrame.rzi.t = graphFrame.rzi:CreateTexture()
    graphFrame.rzi.t:SetAllPoints()
    graphFrame.rzi.t:SetColorTexture(unpack(RZVA_COLORS.increment))

    -- Current zoom display (static label + dynamic value)
    rzvaFrame.cameraZoomLabelText = rzvaFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rzvaFrame.cameraZoomLabelText:SetPoint("TOP", graphFrame, "BOTTOM", RZVA_GRAPH_WIDTH/4, -8)
    rzvaFrame.cameraZoomLabelText:SetText(L["Current\nZoom\nValue"])
    rzvaFrame.cameraZoomLabelText:SetTextColor(unpack(RZVA_COLORS.currentZoom))

    rzvaFrame.cameraZoomValue = rzvaFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    rzvaFrame.cameraZoomValue:SetPoint("TOP", rzvaFrame.cameraZoomLabelText, "BOTTOM", 0, -3)
    rzvaFrame.cameraZoomValue:SetTextColor(unpack(RZVA_COLORS.currentZoom))
    rzvaFrame.cameraZoomValue:SetText("0.0")

    -- Reactive zoom target display (static label + dynamic value)
    rzvaFrame.reactiveZoomTargetLabelText = rzvaFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rzvaFrame.reactiveZoomTargetLabelText:SetPoint("TOP", graphFrame, "BOTTOM", -RZVA_GRAPH_WIDTH/4, -8)
    rzvaFrame.reactiveZoomTargetLabelText:SetText(L["Reactive\nZoom\nTarget"])
    rzvaFrame.reactiveZoomTargetLabelText:SetTextColor(unpack(RZVA_COLORS.targetZoom))

    rzvaFrame.reactiveZoomTargetValue = rzvaFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    rzvaFrame.reactiveZoomTargetValue:SetPoint("TOP", rzvaFrame.reactiveZoomTargetLabelText, "BOTTOM", 0, -3)
    rzvaFrame.reactiveZoomTargetValue:SetTextColor(unpack(RZVA_COLORS.targetZoom))
    rzvaFrame.reactiveZoomTargetValue:SetText("---")

    -- Instructions
    rzvaFrame.instructions = rzvaFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rzvaFrame.instructions:SetPoint("BOTTOM", rzvaFrame, "BOTTOM", 0, 10)
    rzvaFrame.instructions:SetText(L["This graph helps you to\nunderstand how\nReactive Zoom works."])
    rzvaFrame.instructions:SetTextColor(unpack(RZVA_COLORS.gridLabel))

    -- Initial hide
    rzvaFrame:Hide()

    rzvaFrame:HookScript("OnShow", function()
      reactiveZoomGraphUpdateFrame:SetScript("OnUpdate", ReactiveZoomGraphUpdateFunction)
    end)

    rzvaFrame:HookScript("OnHide", function()
      reactiveZoomGraphUpdateFrame:SetScript("OnUpdate", nil)
    end)
  end

  if not rzvaFrame:IsShown() then
    rzvaFrame:Show()
  else
    rzvaFrame:Hide()
  end

end
