local LibCamera = LibStub("LibCamera-1.0")
local LibEasing = LibStub("LibEasing-1.0")



------------
-- LOCALS --
------------

local function round(num, numDecimalPlaces)
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


local rzvaWidth = 120
local rzvaHeight = 200
local rzvaHalfWidth = rzvaWidth/2

local rzvaFrame = nil

local lastReactiveZoomTarget = reactiveZoomTarget
local reactiveZoomGraphUpdateFrame = CreateFrame("Frame")


local function ReactiveZoomGraphUpdateFunction()

  rzvaFrame.zm:ClearAllPoints()
  rzvaFrame.zm:SetPoint("BOTTOMRIGHT", 0, rzvaFrame:GetHeight() - (rzvaFrame:GetHeight() * GetCameraZoom() / DynamicCam.cameraDistanceMaxZoomFactor_max) )
  rzvaFrame.cameraZoomValue:SetText(round(GetCameraZoom(), 3))

  if DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "reactiveZoomEnabled") then

    if not rzvaFrame.rzt:IsShown() then
      rzvaFrame.rzt:Show()
      rzvaFrame.rzi:Show()
      rzvaFrame.reactiveZoomTargetLabel:SetTextColor(.3, .3, 1, 1)
      rzvaFrame.reactiveZoomTargetValue:SetTextColor(.3, .3, 1, 1)
    end

    rzvaFrame.rzt:ClearAllPoints()
    if reactiveZoomTarget then
      rzvaFrame.rzt:SetPoint("BOTTOMLEFT", 0, rzvaFrame:GetHeight() - (rzvaFrame:GetHeight()* reactiveZoomTarget / DynamicCam.cameraDistanceMaxZoomFactor_max) )

      rzvaFrame.reactiveZoomTargetValue:SetText(round(reactiveZoomTarget, 3))

      if lastReactiveZoomTarget then

        local step = lastReactiveZoomTarget - reactiveZoomTarget

        if step > 0 then
          rzvaFrame.rzi:SetHeight(rzvaFrame:GetHeight() * step / DynamicCam.cameraDistanceMaxZoomFactor_max)
          rzvaFrame.rzi:Show()
        elseif step < 0 then
          rzvaFrame.rzi:SetHeight(rzvaFrame:GetHeight() * step / DynamicCam.cameraDistanceMaxZoomFactor_max)
          rzvaFrame.rzi:Show()
        else
          rzvaFrame.rzi:Hide()
        end

      end

      lastReactiveZoomTarget = reactiveZoomTarget

    else
      rzvaFrame.rzi:Hide()
      rzvaFrame.rzt:Hide()
      rzvaFrame.reactiveZoomTargetValue:SetText("---")
    end

  else
    if rzvaFrame.rzt:IsShown() then
      rzvaFrame.rzt:Hide()
      rzvaFrame.rzi:Hide()
      rzvaFrame.reactiveZoomTargetLabel:SetTextColor(.3, .3, .3, 1)
      rzvaFrame.reactiveZoomTargetValue:SetTextColor(.3, .3, .3, 1)
      rzvaFrame.reactiveZoomTargetValue:SetText("---")
    end
  end
end



function DynamicCam:ToggleRZVA()

  if not rzvaFrame then

    rzvaFrame = CreateFrame("Frame", "reactiveZoomVisualAid", UIParent)
    rzvaFrame:SetFrameStrata("TOOLTIP")
    rzvaFrame:SetMovable(true)
    rzvaFrame:EnableMouse(true)
    rzvaFrame:RegisterForDrag("LeftButton")
    rzvaFrame:SetScript("OnDragStart", rzvaFrame.StartMoving)
    rzvaFrame:SetScript("OnDragStop", rzvaFrame.StopMovingOrSizing)
    rzvaFrame:SetClampedToScreen(true)

    -- Closes with right button.
    rzvaFrame:SetScript("OnMouseDown", function(self, button)
      if button == "RightButton" then
        self:Hide()
      end
    end)


    rzvaFrame:SetWidth(rzvaWidth)
    rzvaFrame:SetHeight(rzvaHeight)
    rzvaFrame:ClearAllPoints()
    rzvaFrame:SetPoint("BOTTOMLEFT", SettingsPanel.Container, "BOTTOMLEFT", 45, 35)

    rzvaFrame.t = rzvaFrame:CreateTexture()
    rzvaFrame.t:SetAllPoints()
    rzvaFrame.t:SetTexture("Interface/BUTTONS/WHITE8X8")
    rzvaFrame.t:SetColorTexture(1, 1, 1, .1)

    SetFrameBorder(rzvaFrame, 2, 1, 1, 1, 1)


    rzvaFrame.cameraZoomLabel = rzvaFrame:CreateFontString()
    rzvaFrame.cameraZoomLabel:SetWidth(rzvaHalfWidth)
    rzvaFrame.cameraZoomLabel:SetJustifyH("CENTER")
    rzvaFrame.cameraZoomLabel:SetJustifyV("MIDDLE")
    rzvaFrame.cameraZoomLabel:SetPoint("BOTTOMRIGHT", rzvaFrame, "TOPRIGHT", 0, 19)
    rzvaFrame.cameraZoomLabel:SetFont("Fonts/FRIZQT__.TTF", 12)
    rzvaFrame.cameraZoomLabel:SetTextColor(1, .3, .3, 1)
    rzvaFrame.cameraZoomLabel:SetText("Actual\nZoom\nValue")

    rzvaFrame.cameraZoomValue = rzvaFrame:CreateFontString()
    rzvaFrame.cameraZoomValue:SetWidth(rzvaHalfWidth)
    rzvaFrame.cameraZoomValue:SetJustifyH("CENTER")
    rzvaFrame.cameraZoomValue:SetJustifyV("MIDDLE")
    rzvaFrame.cameraZoomValue:SetPoint("BOTTOMRIGHT", rzvaFrame, "TOPRIGHT", 0, 4)
    rzvaFrame.cameraZoomValue:SetFont("Fonts/FRIZQT__.TTF", 14)
    rzvaFrame.cameraZoomValue:SetTextColor(1, .3, .3, 1)
    rzvaFrame.cameraZoomValue:SetText(GetCameraZoom())


    rzvaFrame.reactiveZoomTargetLabel = rzvaFrame:CreateFontString()
    rzvaFrame.reactiveZoomTargetLabel:SetWidth(rzvaHalfWidth)
    rzvaFrame.reactiveZoomTargetLabel:SetJustifyH("CENTER")
    rzvaFrame.reactiveZoomTargetLabel:SetJustifyV("MIDDLE")
    rzvaFrame.reactiveZoomTargetLabel:SetPoint("BOTTOMLEFT", rzvaFrame, "TOPLEFT", 0, 19)
    rzvaFrame.reactiveZoomTargetLabel:SetFont("Fonts/FRIZQT__.TTF", 12)
    rzvaFrame.reactiveZoomTargetLabel:SetTextColor(.3, .3, 1, 1)
    rzvaFrame.reactiveZoomTargetLabel:SetText("Reactive\nZoom\nTarget")

    rzvaFrame.reactiveZoomTargetValue = rzvaFrame:CreateFontString()
    rzvaFrame.reactiveZoomTargetValue:SetWidth(rzvaHalfWidth)
    rzvaFrame.reactiveZoomTargetValue:SetJustifyH("CENTER")
    rzvaFrame.reactiveZoomTargetValue:SetJustifyV("MIDDLE")
    rzvaFrame.reactiveZoomTargetValue:SetPoint("BOTTOMLEFT", rzvaFrame, "TOPLEFT", 0, 4)
    rzvaFrame.reactiveZoomTargetValue:SetFont("Fonts/FRIZQT__.TTF", 14)
    rzvaFrame.reactiveZoomTargetValue:SetTextColor(.3, .3, 1, 1)



    rzvaFrame.zm = CreateFrame("Frame", "cameraZoomMarker", rzvaFrame)
    rzvaFrame.zm:SetWidth(rzvaHalfWidth)
    rzvaFrame.zm:SetHeight(1)
    rzvaFrame.zm:Show()
    DrawLine(rzvaFrame.zm, "BOTTOMLEFT", 0, 0, "BOTTOMRIGHT", 0, 0, 5, 1, .3, .3, 1)


    rzvaFrame.rzt = CreateFrame("Frame", "reactiveZoomTargetMarker", rzvaFrame)
    rzvaFrame.rzt:SetWidth(rzvaHalfWidth)
    rzvaFrame.rzt:SetHeight(1)
    rzvaFrame.rzt:Show()
    DrawLine(rzvaFrame.rzt, "BOTTOMRIGHT", 0, 0, "BOTTOMLEFT", 0, 0, 5, .3, .3, 1, 1)


    rzvaFrame.rzi = CreateFrame("Frame", "reactiveZoomIncrementMarker", rzvaFrame)
    rzvaFrame.rzi:SetWidth(rzvaHalfWidth)
    -- Must set points here, otherwise the texture is not created...
    rzvaFrame.rzi:SetPoint("TOP", rzvaFrame.rzt, "BOTTOM", 0, 0)
    rzvaFrame.rzi.t = rzvaFrame.rzi:CreateTexture()
    rzvaFrame.rzi.t:SetAllPoints()
    rzvaFrame.rzi.t:SetTexture("Interface/BUTTONS/WHITE8X8")
    rzvaFrame.rzi.t:SetColorTexture(1, 1, 0, 1)

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


