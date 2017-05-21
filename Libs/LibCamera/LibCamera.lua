---------------
-- LIBCAMERA --
---------------
local MAJOR, MINOR = "LibCamera-1.0", 1;
local LibCamera = LibStub:NewLibrary(MAJOR, MINOR);

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
local pauseOnUpdate = false;
local MAX_UPDATE_TIME = 1.0/120.0;
local function FrameOnUpdate(self, time)
    if (not pauseOnUpdate) then
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


------------
-- EVENTS --
------------
-- LibCamera.frame:RegisterEvent("PLAYER_ENTERING_WORLD");
-- LibCamera.frame:RegisterEvent("PLAYER_LEAVING_WORLD");

-- -- Script to fire blizzard events into the event listeners
-- LibCamera.frame:SetScript("OnEvent", function(this, event, ...)
--     if (LibCamera[event]) then
--         LibCamera[event](...);
--     end
-- end);

-- function LibCamera:PLAYER_ENTERING_WORLD()
--     -- exiting a loading screen
--     print("PLAYER_ENTERING_WORLD")
--     pauseOnUpdate = false;
-- end

-- function LibCamera:PLAYER_LEAVING_WORLD()
--     -- going into a loading screen
--     print("PLAYER_LEAVING_WORLD")
--     pauseOnUpdate = true;
-- end


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
    -- basically, what this tries to do, is to move the t (time) around
    -- so that it matches the provided x (position) within the given easing function

    -- in other words:
    -- we have some amount of error between where we actually are, and where we were supposed to be
    -- so we jump forward/backwards on the time line to compensate

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

local function reallyStopZooming()
    -- this might be overkill, but we really want to make sure that the camera isn't moving!
    CameraZoomIn(0, true);
    CameraZoomOut(0, true);
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

local easingZoom;
local MAX_POS_ERROR = 0.5;
function LibCamera:SetZoom(endValue, duration, easingFunc, callback)
    -- start every zoom by making sure that we stop zooming
    self:StopZooming();
    -- print("SetZoom", endValue, duration, "Current zoom", GetCameraZoom());

    -- assume easeInOutQuad if not provided
    if (not easingFunc) then
        easingFunc = easeInOutQuad;
    end

    -- we want to start the counter on the frame the the zoom started
    local beginTime;
    local beginValue;
    local change;
    local frameCount = 0;
    local lastFrameTime;

    -- create a closure, for OnUpdate
    local func = function()
        local currentTime = GetTime();
        local currentValue = GetCameraZoom();
        -- local deltaTime = currentTime - (lastFrameTime or currentTime);

        beginTime = beginTime or GetTime();
        beginValue = beginValue or GetCameraZoom();
        change = change or (endValue - beginValue);

        local beyondPosition = ((change > 0 and currentValue >= endValue) or (change < 0 and currentValue <= endValue));

        frameCount = frameCount + 1;
        lastFrameTime = GetTime();

        if ((beginTime + duration > currentTime) and not beyondPosition) then
            -- still in time
            local interval = 1.0/60.0;

            local t = currentTime - beginTime;
            local expectedValue = easingFunc(t, beginValue, change, duration);
            local posError = currentValue - expectedValue;

            if (frameCount > 1) then
                -- we're off the mark, try to rebase our time so that we're in the right time for our current position
                -- don't try to do this on the first frame
                if (math.abs(posError) > MAX_POS_ERROR) then
                    local tPrime = rebaseEaseTime(easingFunc, 0.005, currentValue, t, beginValue, change, duration);
                    local tDiff = tPrime - t;

                    if (tPrime > 0 and tPrime < duration) then
                        beginTime = beginTime - tDiff;
                        t = currentTime - beginTime;
                        -- expectedValue = easingFunc(t, beginValue, change, duration);

                        -- print(string.format("  frame %d: rebasing by %.4f, new expect: %.2f, caused by posError: %.4f", frameCount, tDiff, expectedValue, posError));
                        -- posError = currentValue - expectedValue;
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

            -- print(string.format("frame: %d, position: %.2f, expect: %.2f, speed: %.2f, posError: %.4f, deltaTime: %0.4f", frameCount, currentValue, expectedValue, speed, posError, deltaTime));

            return true;
        else
            -- we're done, either out of time, or beyond position
            reallyStopZooming();

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

local cvarZoom;
local oldSpeed;
local CVAR_ZOOM_NUM_FRAMES_STATIC = 5;
function LibCamera:SetZoomUsingCVar(endValue, duration, callback)
    -- start every zoom by making sure that we stop zooming
    self:StopZooming();

    local beginValue = GetCameraZoom();
    local change = endValue - beginValue;
    local speed = math.abs(math.min(50, math.abs((change/duration))));

    oldSpeed = getZoomSpeed();

    -- set the zoom cvar to what will get us to the endValue in the duration
    SetCVar("cameraZoomSpeed", speed);
    --print("Setting cameraZoomSpeed to", speed);

    local triggeredZoom = false;

    local numFramesStatic = 0;
    local lastValue = GetCameraZoom();
    local func = function()
        -- trigger zoom only once but ON THE NEXT FRAME
        -- this is because you can only do one CameraZoom___ function once a frame
        if (not triggeredZoom) then
            -- actually trigger the zoom
            -- second parameter is just to let other addons know that this is zoom triggered by an addon
            if (change > 0) then
                CameraZoomOut(change, true);
                --print("Zoom out", change);
            elseif (change < 0) then
                CameraZoomIn(-change, true);
                --print("Zoom in", -change);
            end

            triggeredZoom = true;
        end

        local currentValue = GetCameraZoom();

        -- check if we've got beyond the position that we were aiming for
        local beyondPosition = ((change > 0 and currentValue >= endValue) or (change < 0 and currentValue <= endValue));

        -- count the number of frames that we stayed static
        if (lastValue == currentValue and lastValue ~= beginValue) then
            numFramesStatic = numFramesStatic + 1;
            -- print("Static frame!")
        else
            -- reset counter if zoom resumes
            numFramesStatic = 0;
        end

        local goingWrongWay = (change > 0 and lastValue > currentValue) or (change < 0 and lastValue < currentValue);

        lastValue = currentValue;

        if ((numFramesStatic < CVAR_ZOOM_NUM_FRAMES_STATIC) and not beyondPosition and not goingWrongWay) then
            -- we're still zooming or we should be
            return true;
        else
            -- we should have stopped zooming or the camera stood still for a bit

            -- set the zoom cvar to what it was before this happened
            -- print("Ending, setting cameraZoomSpeed back to", oldSpeed);
            if (oldSpeed) then
                SetCVar("cameraZoomSpeed", oldSpeed);
                oldSpeed = nil;
            end

            -- call the callback if provided
            if (callback) then callback() end;

            cvarZoom = nil;
            return nil;
        end
    end

    -- register OnUpdate, to call every frame until done
    RegisterOnUpdateFunc(func);
    cvarZoom = func;
end

function LibCamera:StopZooming()
    -- if we currently have something running, make sure to cancel it!
    if (easingZoom) then
        CancelOnUpdateFunc(easingZoom);
        easingZoom = nil;
    end

    if (cvarZoom) then
        CancelOnUpdateFunc(cvarZoom);
        cvarZoom = nil;

        -- restore old speed if we had one
        if (oldSpeed) then
            SetCVar("cameraZoomSpeed", oldSpeed);
            oldSpeed = nil;
        end
    end

    reallyStopZooming();
end


--------------
-- ROTATION --
--------------
local easingYaw;
local lastYaw;
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

            -- this is the elasped yaw, used if we canceled ahead of time
            lastYaw = easingFunc(currentTime - beginTime, beginValue, change, duration);

            if (speed > 0) then
                MoveViewRightStart(speed/getYawSpeed());
            elseif (speed < 0) then
                MoveViewLeftStart(-speed/getYawSpeed());
            end

            return true;
        else
            -- stop the camera, we're there
            lastYaw = nil;
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

local continousYaw;
local elaspedYaw;
function LibCamera:BeginContinuousYaw(endSpeed, duration)
    self:StopYawing();

    local beginTime;
    local lastSpeed, lastTime;
    local isCoasting = false;

    -- print("begin rotating", endSpeed, duration)

    elaspedYaw = 0;

    local func = function()
        local speed = endSpeed;
        local currentTime = GetTime();
        beginTime = beginTime or GetTime();

        -- accumulate the yaw into elapsed yaw, so that we can return it when we stop
        if (lastSpeed and lastTime) then
            elaspedYaw = elaspedYaw + (lastSpeed * (currentTime - lastTime))
        end
        lastTime = GetTime();

        if (beginTime + duration > currentTime) then
            -- linear increase of velocity
            speed = endSpeed * (currentTime - beginTime) / duration;

            -- print("Ramping up, now speed", speed)
            if (speed > 0) then
                MoveViewRightStart(speed/getYawSpeed());
            elseif (speed < 0) then
                MoveViewLeftStart(-speed/getYawSpeed());
            end

            lastSpeed = speed;

            return true;
        else
            -- start yawing at the endSpeed if we haven't already
            if (not isCoasting) then
                if (speed > 0) then
                    MoveViewRightStart(speed/getYawSpeed());
                elseif (speed < 0) then
                    MoveViewLeftStart(-speed/getYawSpeed());
                end

                lastSpeed = speed;
                isCoasting = true;
            end
            return true;
        end
    end

    RegisterOnUpdateFunc(func);
    continousYaw = func;
end

function LibCamera:StopYawing()
    local yawAmount;

    -- if we currently have something running, make sure to cancel it!
    if (easingYaw) then
        CancelOnUpdateFunc(easingYaw);
        easingYaw = nil;

        -- if we had a last yaw, make sure to save it, to return
        if (lastYaw) then
            yawAmount = lastYaw;
            lastYaw = nil;
        end
    end

    -- if we are continually yawing, then stop that
    if (continousYaw) then
        CancelOnUpdateFunc(continousYaw);
        continousYaw = nil;

        -- return elapsed yaw
        if (elaspedYaw) then
            yawAmount = elaspedYaw;
            elaspedYaw = nil;
        end
    end

    -- this might be overkill, but we really want to make sure that the camera isn't moving!
    MoveViewLeftStop();
    MoveViewRightStop();

    return yawAmount;
end

local easingPitch;
local lastPitch;
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

            -- this is the elasped pitch, used if we canceled ahead of time
            lastPitch = easingFunc(currentTime - beginTime, beginValue, change, duration);

            if (speed > 0) then
                MoveViewUpStart(speed/getPitchSpeed());
            elseif (speed < 0) then
                MoveViewDownStart(-speed/getPitchSpeed());
            end

            return true;
        else
            lastPitch = nil;

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
    local pitchAmount;

    -- if we currently have something running, make sure to cancel it!
    if (easingPitch) then
        CancelOnUpdateFunc(easingPitch);
        easingPitch = nil;

        -- if we had a last pitch, make sure to save it, to return
        if (lastPitch) then
            pitchAmount = lastPitch;
            lastPitch = nil;
        end
    end

    -- this might be overkill, but we really want to make sure that the camera isn't moving!
    MoveViewUpStop();
    MoveViewDownStop();

    return pitchAmount;
end

function LibCamera:IsRotating()
    return (easingYaw ~= nil) or (continousYaw ~= nil) or (easingPitch ~= nil);
end

function LibCamera:StopRotating()
    return self:StopYawing(), self:StopPitching();
end
