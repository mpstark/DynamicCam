---------------
-- LIBCAMERA --
---------------
local MAJOR, MINOR = "LibCamera-1.0", 1;
LibCamera = LibStub:NewLibrary(MAJOR, MINOR);

if (not LibCamera) then
    return;
end

LibCamera.frame = LibCamera.frame or CreateFrame("Frame");


------------
-- LOCALS --
------------
local onUpdateFunc = {};


--------------
-- ONUPDATE --
--------------
local lastUpdate;
local MAX_UPDATE_TIME = 1.0/120.0;
local function FrameOnUpdate(self, time)
    if (not lastUpdate or (lastUpdate + MAX_UPDATE_TIME) < GetTime()) then
        for k,func in pairs(onUpdateFunc) do
            -- run the function, if it returns nil, remove it
            if (func() == nil) then
                onUpdateFunc[k] = nil;
            end
        end

        lastUpdate = GetTime();
    end

    -- remove onupdate if there isn't anything to check
    if (next(onUpdateFunc) == nil) then
        LibCamera.frame:SetScript("OnUpdate", nil);
    end
end

local function SetupOnUpdate()
    -- if we have checks to do and there isn't an OnUpdate on the frame, set it up
    if (next(onUpdateFunc) ~= nil and LibCamera.frame:GetScript("OnUpdate") == nil) then
        LibCamera.frame:SetScript("OnUpdate", FrameOnUpdate);

        -- force the next update to happen on the NEXT frame
        lastUpdate = GetTime();
    end
end

local function RegisterOnUpdateFunc(func)
    -- add to the list
    onUpdateFunc[func] = func;

    -- make sure that an OnUpdate script is on our frame
    SetupOnUpdate();
end

local function CancelOnUpdateFunc(func)
    if (onUpdateFunc[func]) then
        -- remove from the list
        onUpdateFunc[func] = nil;
    end
end


-----------
-- HOOKS --
-----------


-------------
-- UTILITY --
-------------
local function getZoomSpeed()
    return tonumber(GetCVar("cameraZoomSpeed"));
end

local function getYawSpeed()
    return tonumber(GetCVar("cameraYawMoveSpeed"));
end

local function getPitchSpeed()
    return tonumber(GetCVar("cameraPitchMoveSpeed"));
end

local function parseSpeed(speed)
    local zoomSpeed = getZoomSpeed();
    local tempSpeed = zoomSpeed;

    if (speed and (type(speed) == "number")) then
        tempSpeed = speed;
    elseif (speed and (type(speed) == "function")) then
        tempSpeed = speed();
    end

    --return math.min(50/zoomSpeed, math.max(0, tempSpeed/zoomSpeed));
    return math.max(0, tempSpeed/zoomSpeed);
end

local function easeInOutQuad(t, b, c, d)
    t = t / d * 2;
    if t < 1 then
        return c / 2 * (t * t) + b;
    else
        return -c / 2 * ((t - 1) * (t - 3) - 1) + b;
    end
end

local function getEaseVelocity(easingFunc, increment, t, b, c, d, ...)
    -- approximate the velocity of the easing function at the given time
    local halfIncrement = increment/2.0;

    if (t > halfIncrement and (t + halfIncrement < d)) then
        --print("    MID");
        return (easingFunc(t + halfIncrement, b, c, d, ...) - easingFunc(t - halfIncrement, b, c, d, ...))/increment;
    elseif (t < halfIncrement and (t + increment < d)) then
        -- before halfIncrement, which means that can can't trust anything before t
        --print("    BEGIN");
        return (easingFunc(t + increment, b, c, d, ...) - easingFunc(t, b, c, d, ...))/increment;
    elseif (t + halfIncrement > d) then
        -- after the last increment, can't go beyond d
        --print("    END");
        return (easingFunc(t, b, c, d, ...) - easingFunc(t - increment, b, c, d, ...))/increment;
    end
end

local function rebaseEaseTime(easingFunc, precision, x, t, b, c, d, ...)
    local currentValue = easingFunc(t, b, c, d, ...);
    local tPrime = t;
    local difference = x - currentValue;
    local change = math.min(d-t, d/12.0);
    local lastWasForward;
    local numIter = 0;

    while ((math.abs(difference) > precision) and (numIter < 100)) do
        if ((difference > 0 and c > 0) or (difference < 0 and c < 0)) then
            -- if we swapped directions, then divide by 2
            if (lastWasForward ~= nil and not lastWasForward) then
                change = change / 2.0;
            end

            -- ahead of time
            tPrime = tPrime + change;
            --print("  +", change)

            lastWasForward = true;
        else
            -- if we swapped directions, then divide by 2
            if (lastWasForward) then
                change = change / 2.0;
            end

            -- behind time
            tPrime = tPrime - change;
            --print("  -", change)
            
            lastWasForward = false;
        end

        -- recompute
        currentValue = easingFunc(tPrime, b, c, d, ...);
        difference = x - currentValue;
        numIter = numIter + 1;
    end

    --print("           ",numIter)
    return tPrime;
end


-----------
-- CVARS --
-----------
local easingCVars = {};
function LibCamera:EaseCVar(cvar, endValue, duration, easingFunc, callback)
    -- make sure that we're only easing each cvar once at a time
    -- so cancel if we're already easing
    if (easingCVars[cvar]) then
        CancelOnUpdateFunc(easingCVars[cvar]);
        easingCVars[cvar] = nil;
    end

    -- assume easeInOutQuad if not provided
    if (not easingFunc) then
        easingFunc = easeInOutQuad;
    end
    
    local beginValue = tonumber(GetCVar(cvar));
    local change = endValue - beginValue;
    local beginTime = GetTime();
    
    -- create a closure, for OnUpdate
    local func = function()
        local currentTime = GetTime();
        local currentValue = tonumber(GetCVar(cvar));
        
        if (beginTime + duration > currentTime) then
            SetCVar(cvar, easingFunc(currentTime - beginTime, beginValue, change, duration));
            return true;
        else
            -- at the set value
            SetCVar(cvar, endValue);
            easingCVars[cvar] = nil;

            -- call the callback if provided
            if (callback) then callback() end;

            return nil;
        end
    end
    
    -- register OnUpdate, to call every frame until done
    RegisterOnUpdateFunc(func);
    easingCVars[cvar] = func;
end


-------------
-- ZOOMING --
-------------
local realCameraZoomIn = CameraZoomIn;
local realCameraZoomOut = CameraZoomOut;
local function LockedZoom()
    --print("Locked zoom!");
end
function LibCamera:LockZoom()
    -- make sure that we're not using the functions
    CameraZoomIn(0, true);
    CameraZoomOut(0, true);

    -- override the default function
    CameraZoomIn = LockedZoom;
    CameraZoomOut = LockedZoom;
end

function LibCamera:UnlockZoom()
    CameraZoomIn = realCameraZoomIn;
    CameraZoomOut = realCameraZoomOut;
end

local easingZoom;
function LibCamera:SetZoom(endValue, duration, easingFunc, callback)
    -- start every zoom by making sure that we stop zooming
    self:StopZooming();
    --print("SetZoom", endValue, duration);

    -- assume easeInOutQuad if not provided
    if (not easingFunc) then
        easingFunc = easeInOutQuad;
    end

    local beginValue = GetCameraZoom();
    local change = endValue - beginValue;
    local trueBeginTime = GetTime();

    -- we want to start the counter on the frame the the zoom started
    local beginTime;

    local frameCount = 0;
    local stopFlag = false;

    -- create a closure, for OnUpdate
    local func = function()
        beginTime = beginTime or GetTime();

        local currentTime = GetTime();
        local currentValue = GetCameraZoom();
        
        local beyondPosition = ((change > 0 and currentValue >= endValue) or (change < 0 and currentValue <= endValue))

        if ((beginTime + duration > currentTime) and not beyondPosition) then
            -- still in time
            local interval = 1.0/60.0;
            
            local t = currentTime - beginTime;
            local expectedValue = easingFunc(t, beginValue, change, duration);
            local posError = currentValue - expectedValue;

            frameCount = frameCount + 1;

            if (frameCount > 1) then
                -- we're off the mark, try to rebase our time so that we're in the right time for our current position
                -- don't try to do this on the first frame
                if (math.abs(posError) > 0.05) then
                    local tPrime = rebaseEaseTime(easingFunc, 0.005, currentValue, t, beginValue, change, duration);
                    local tDiff = tPrime - t;

                    if (tPrime > 0 and tPrime < duration) then
                        beginTime = beginTime - tDiff;
                        t = currentTime - beginTime;
                        expectedValue = easingFunc(t, beginValue, change, duration);
                        
                        --print(string.format("  frame %d: rebasing by %.4f, new expect: %.2f, caused by posError: %.4f", frameCount, tDiff, expectedValue, posError));
                        posError = currentValue - expectedValue;
                    else
                        --print(string.format("  tPrime invalid: %.2f", tPrime));
                    end
                end
            end

            local speed;
            
            if (duration - t > 2*interval) then
                speed = getEaseVelocity(easingFunc, interval, t, beginValue, change, duration);
            else
                -- use linear speed on the last two possible frames
                -- linear assuming next frame is on interval time
                --print("USED LINEAR TIME");
                speed = (endValue - currentValue)/interval;
            end

            -- speed didn't return, which generally means that the duration was shorter than the framerate
            if (not speed) then
                --print("something wrong")
                return nil;
            end

            if (speed > 0) then
                MoveViewOutStart(speed/getZoomSpeed());
            elseif (speed < 0) then
                MoveViewInStart(-speed/getZoomSpeed());
            end

            --print(string.format("frame: %d, position: %.2f, expect: %.2f, speed: %.2f, posError: %.4f", frameCount, currentValue, expectedValue, speed, posError));

            return true;
        elseif (not stopFlag) then
            -- we're out of time
            MoveViewInStop();
            MoveViewOutStop();

            if (beyondPosition) then
                --print("ended because we went beyond position");
            end

            stopFlag = true;
            return true;
        else
            local diff = endValue - GetCameraZoom();
            local diffMult = (change > 0) and -1 or 1;

            --print(string.format("SetZoom ended. deltaX: %.2f, deltaT: %.2f", diff*diffMult, duration - (currentTime - trueBeginTime)));

            -- call the callback if provided
            if (callback) then callback() end;

            easingZoom = nil;
            return nil;
        end
    end

    -- register OnUpdate, to call every frame until done
    RegisterOnUpdateFunc(func);
    easingZoom = func;
end

function LibCamera:StopZooming()
    -- if we currently have something running, make sure to cancel it!
    if (easingZoom) then
        CancelOnUpdateFunc(easingZoom);
        easingZoom = nil;
    end

    -- this might be overkill, but we really want to make sure that the camera isn't moving!
    --CameraZoomIn(0, true);
    --CameraZoomOut(0, true);
    MoveViewOutStart(0);
    MoveViewInStart(0);
    MoveViewOutStart(0);
    MoveViewInStart(0);
    MoveViewOutStart(0);
    MoveViewInStart(0);
    MoveViewInStop();
    MoveViewOutStop();
    MoveViewInStop();
    MoveViewOutStop();
    MoveViewInStop();
    MoveViewOutStop();
end


--------------
-- ROTATION --
--------------
local easingYaw;
function LibCamera:Yaw(endValue, duration, easingFunc, callback)
    --print("Yaw", endValue, duration);
    -- start every yaw
    self:StopYawing();

    -- assume easeInOutQuad if not provided
    if (not easingFunc) then
        easingFunc = easeInOutQuad;
    end

    local beginValue = 0;
    local change = endValue - beginValue;
    local beginTime;

    -- create a closure, for OnUpdate
    local func = function()
        local currentTime = GetTime();
        beginTime = beginTime or GetTime();

        if (beginTime + duration > currentTime) then
            -- still in time
            local speed = getEaseVelocity(easingFunc, 1.0/60.0, currentTime - beginTime, beginValue, change, duration);

            if (speed > 0) then
                MoveViewRightStart(speed/getYawSpeed());
            elseif (speed < 0) then
                MoveViewLeftStart(-speed/getYawSpeed());
            end

            return true;
        else
            -- stop the camera, we're there
            self:StopYawing();

            --print("Stopped yawing");

            -- call the callback if provided
            if (callback) then callback() end;

            return nil;
        end
    end

    -- register OnUpdate, to call every frame until done
    RegisterOnUpdateFunc(func);
    easingYaw = func;
end

function LibCamera:StopYawing()
    -- if we currently have something running, make sure to cancel it!
    if (easingYaw) then
        CancelOnUpdateFunc(easingYaw);
        easingYaw = nil;
    end

    -- this might be overkill, but we really want to make sure that the camera isn't moving!
    MoveViewLeftStop();
    MoveViewRightStop();
end

local easingPitch;
function LibCamera:Pitch(endValue, duration, easingFunc, callback)
    --print("Pitch", endValue, duration);
    -- start every pitch
    self:StopPitching();

    -- assume easeInOutQuad if not provided
    if (not easingFunc) then
        easingFunc = easeInOutQuad;
    end

    local beginValue = 0;
    local change = endValue - beginValue;
    local beginTime;

    -- create a closure, for OnUpdate
    local func = function()
        local currentTime = GetTime();
        beginTime = beginTime or GetTime();

        if (beginTime + duration > currentTime) then
            -- still in time
            local speed = getEaseVelocity(easingFunc, 1.0/60.0, currentTime - beginTime, beginValue, change, duration);

            if (speed > 0) then
                MoveViewUpStart(speed/getPitchSpeed());
            elseif (speed < 0) then
                MoveViewDownStart(-speed/getPitchSpeed());
            end

            return true;
        else
            -- stop the camera, we're there
            self:StopPitching();

            --print("Stopped pitching");

            -- call the callback if provided
            if (callback) then callback() end;

            return nil;
        end
    end

    -- register OnUpdate, to call every frame until done
    RegisterOnUpdateFunc(func);
    easingPitch = func;
end

function LibCamera:StopPitching()
    -- if we currently have something running, make sure to cancel it!
    if (easingPitch) then
        CancelOnUpdateFunc(easingPitch);
        easingPitch = nil;
    end

    -- this might be overkill, but we really want to make sure that the camera isn't moving!
    MoveViewUpStop();
    MoveViewDownStop();
end

function LibCamera:IsRotating()
    return (easingYaw ~= nil) or (easingPitch ~= nil);
end

function LibCamera:StopRotating()
    self:StopPitching();
    self:StopYawing();
end


------------
-- EXTRAS --
------------
local cinemaMode;
local cinemaLastValue;
function LibCamera:CinemaMode(beginValue, endValue, duration, easingFunc, callback)
    --print("CinemaMode", beginValue, endValue, duration);
    self:EndCinemaMode();

    -- assume easeInOutQuad if not provided
    if (not easingFunc) then
        easingFunc = easeInOutQuad;
    end

    -- start at the last value rather than the provided value, because
    -- the last cinemamode thing got canned before it finished.
    if (cinemaLastValue) then
        beginValue = cinemaLastValue;
    end

    local change = endValue - beginValue;
    local beginTime;

    -- create a closure, for OnUpdate
    local func = function()
        local currentTime = GetTime();
        beginTime = beginTime or GetTime();

        if (beginTime + duration > currentTime) then
            -- still in time
            local newValue = easingFunc(currentTime - beginTime, beginValue, change, duration);

            WorldFrame:ClearAllPoints();
            WorldFrame:SetPoint("TOPLEFT", 0, -newValue);
            WorldFrame:SetPoint("BOTTOMRIGHT", 0, newValue);

            cinemaLastValue = newValue;

            return true;
        else
            -- stop the camera, we're there
            --self:EndCinemaMode();

            WorldFrame:ClearAllPoints();
            WorldFrame:SetPoint("TOPLEFT", 0, -endValue);
            WorldFrame:SetPoint("BOTTOMRIGHT", 0, endValue);

            cinemaLastValue = nil;

            -- call the callback if provided
            if (callback) then callback() end;

            return nil;
        end
    end

    -- register OnUpdate, to call every frame until done
    RegisterOnUpdateFunc(func);
    cinemaMode = func;
end

function LibCamera:EndCinemaMode()
    -- if we currently have something running, make sure to cancel it!
    if (cinemaMode) then
        CancelOnUpdateFunc(cinemaMode);
        cinemaMode = nil;
    end

    --WorldFrame:ClearAllPoints();
    --WorldFrame:SetPoint("TOPLEFT", 0, 0);
    --WorldFrame:SetPoint("BOTTOMRIGHT", 0, 0);
end

local fadeUI;
local hidMinimap;
local fadeUILastValue;
function LibCamera:FadeUI(beginValue, endValue, duration, easingFunc, callback)
    --print("FadeUI", beginValue, endValue, duration);
    self:EndFadeUI();

    -- assume easeInOutQuad if not provided
    if (not easingFunc) then
        easingFunc = easeInOutQuad;
    end

    -- start at the last value rather than the provided value, because
    -- the last hideUI thing got canned before it finished.
    if (fadeUILastValue) then
        beginValue = fadeUILastValue;
    end

    local change = endValue - beginValue;
    local beginTime;

    -- create a closure, for OnUpdate
    local func = function()
        local currentTime = GetTime();
        beginTime = beginTime or GetTime();

        if (beginTime + duration > currentTime) then
            -- still in time
            local newValue = easingFunc(currentTime - beginTime, beginValue, change, duration);

            UIParent:SetAlpha(newValue);

            fadeUILastValue = newValue;

            return true;
        else
            if (endValue == 0 and Minimap:IsShown()) then
                Minimap:Hide();
                hidMinimap = true;
            else
                if (hidMinimap and not Minimap:IsShown()) then
                    Minimap:Show();
                    hidMinimap = nil;
                end
            end

            UIParent:SetAlpha(endValue);

            fadeUILastValue = nil;

            -- call the callback if provided
            if (callback) then callback() end;

            return nil;
        end
    end

    -- register OnUpdate, to call every frame until done
    RegisterOnUpdateFunc(func);
    fadeUI = func;
end

function LibCamera:EndFadeUI()
    -- if we currently have something running, make sure to cancel it!
    if (fadeUI) then
        CancelOnUpdateFunc(fadeUI);
        fadeUI = nil;
    end

    if (hidMinimap and not Minimap:IsShown()) then
        Minimap:Show();
        hidMinimap = nil;
    end

    --UIParent:SetAlpha(1);
end
