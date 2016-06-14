---------------
-- CONSTANTS --
---------------
local CONTINOUS_FUDGE_FACTOR = 1.1;
local VIEW_TRANSITION_SPEED = 10; -- TODO: remove this awful thing


-------------
-- GLOBALS --
-------------
assert(DynamicCam);
DynamicCam.Camera = DynamicCam:NewModule("Camera", "AceTimer-3.0", "AceHook-3.0");


------------
-- LOCALS --
------------
local Camera = DynamicCam.Camera;
local parent = DynamicCam;
local _;

local viewTimer;

local zoom = {
	value = 0,
	confident = false,

	action = nil,
	time = nil,
	continousSpeed = 1,

	timer = nil,
	oldSpeed = nil,
	oldMaxDistance = nil,
}

local rotation = {
	action = nil,
	time = nil,
	speed = 0,
	timer = nil,
};


----------
-- CORE --
----------
function Camera:OnInitialize()
	-- hook camera functions to figure out wtf is happening
	self:Hook("CameraZoomIn", true);
	self:Hook("CameraZoomOut", true);

	self:Hook("MoveViewInStart", true);
	self:Hook("MoveViewInStop", true);
	self:Hook("MoveViewOutStart", true);
	self:Hook("MoveViewOutStop", true);

	self:Hook("SetView", "SetView", true);
	self:Hook("ResetView", "ResetView", true);
	self:Hook("SaveView", "SaveView", true);

	self:Hook("PrevView", "ResetZoomVars", true)
	self:Hook("NextView", "ResetZoomVars", true)
end

function Camera:OnEnable()
end

function Camera:OnDisable()
end


-----------
-- CVARS --
-----------
local function GetMaxZoom()
	return tonumber(GetCVar("cameradistancemax"));
end

local function SetMaxZoom(value)
    if (value) then
        parent:DebugPrint("SetMaxZoom:", value);
        SetCVar("cameradistancemax", value);
    else
        parent:DebugPrint("SERIOUS FUCKING ERROR");
    end
end

local function GetMaxZoomFactor()
	return tonumber(GetCVar("cameradistancemaxfactor"));
end

local function SetMaxZoomFactor(value)
	SetCVar("cameradistancemaxfactor", value);
end

local function GetZoomSpeed()
	return tonumber(GetCVar("cameradistancemovespeed"));
end

local function SetZoomSpeed(value)
    parent:DebugPrint("SetZoomSpeed:", value);
	SetCVar("cameradistancemovespeed", math.min(50,value));
end

local function GetYawSpeed()
	return tonumber(GetCVar("cameraYawMoveSpeed"));
end

local function GetZoomSmoothSpeed()
    return tonumber(GetCVar("cameraDistanceSmoothSpeed"));
end

local function SetZoomSmoothSpeed(value)
    return SetCVar("cameraDistanceSmoothSpeed", value);
end

local function GetViewMinTime()
    return tonumber(GetCVar("cameraSmoothTimeMin"));
end

local function GetViewMaxTime()
     return tonumber(GetCVar("cameraSmoothTimeMax"));
end

local function SetViewMinTime(value)
    SetCVar("cameraSmoothTimeMin", value);
end

local function SetViewMaxTime(value)
    SetCVar("cameraSmoothTimeMax", value);
end

local function SetViewTime(value)
    SetViewMinTime(value);
    SetViewMaxTime(value);
end

-- TODO: cameradistancesmoothspeed? camerafovsmoothspeed?


---------------------
-- LOCAL FUNCTIONS --
---------------------

local function GetEstimatedZoomTime(increments)
	return increments/GetZoomSpeed();
end

local function GetEstimatedZoomSpeed(increments, time)
	return math.min(50, (increments/time));
end

local function GetEstimatedRotationSpeed(degrees, time)
	-- (DEGREES) / (SECONDS) = SPEED
	-- TODO: compensate for the smoothing factors?
	return (((degrees)/time)/GetYawSpeed());
end

local function GetEstimatedRotationTime(degrees, speed)
	-- (DEGREES) / (SECONDS) = SPEED
	-- (DEGREES) / (SPEED) = SECONDS
	-- TODO: compensate for the smoothing factors?
	return ((degrees)/(speed * GetYawSpeed()));
end

local function GetEstimatedRotationDegrees(time, speed)
	-- (DEGREES) / (SECONDS) = SPEED
	-- DEGREES = SPEED * SECONDS
	-- TODO: compensate for the smoothing factors?
	return (time * speed * GetYawSpeed());
end


-----------
-- HOOKS --
-----------
function Camera:CameraZoomIn(increments)
	local zoomMax = GetMaxZoom() * GetMaxZoomFactor();

	-- maximum maxzoom is 50
	zoomMax = math.min(50, zoomMax);

	-- maximum increments is zoommax
	increments = math.min(increments, zoomMax);

	-- check if we were continously zooming before and stop tracking it if we were
	if (zoom.action == "continousIn") then
		self:MoveViewInStop();
	elseif (zoom.action == "continousOut") then
		self:MoveViewOutStop();
	end

	-- check to see if we were previously zooming out and we're not done yet
	if (zoom.action == "out" and zoom.time and zoom.time >= GetTime()) then
		-- canceled zooming out, get the time left and guess how much distance we didn't cover
		local timeLeft = zoom.time - GetTime();

		-- (seconds) * (yards/second) = yards
		zoom.value = zoom.value - (timeLeft * GetZoomSpeed());

		self:LoseConfidence();
		zoom.action = nil;
		zoom.time = nil;
	end

	-- set the zoom variable
	if (zoom.confident) then
		-- we know where we are, then set the zoom, zoom can only go to 0
		local oldZoom = zoom.value;
		zoom.value = math.max(zoom.value - increments, 0);

		if (zoom.value < 0.5) then
			zoom.value = 0;
			increments = oldZoom;
		end
	else
		-- we don't know where we are, just assume that we're not zooming in further than we can go
		zoom.value = zoom.value - increments;

		-- we've now zoomed in past the max, so we can assume that we're at 0
		if (zoom.value <= -zoomMax) then
			zoom.value = 0;
			zoom.confident = true;
			increments = 0;
		end
	end

	-- set zoom done time
	-- (yard) / (yards/second) = seconds
	local timeToZoom = GetEstimatedZoomTime(increments);
	if (increments > 0) then
		zoom.action = "in";
		if (zoom.time and zoom.time > GetTime()) then
			zoom.time = zoom.time + timeToZoom;
		else
			zoom.time = GetTime() + timeToZoom;
		end
	end

	-- TODO: set timer for this

	parent:DebugPrint("Zoom in:", "increments:", increments, "new:", zoom.value, "time:", timeToZoom, (zoom.confident and "" or "not confident"));
end

function Camera:CameraZoomOut(increments)
	local zoomMax = GetMaxZoom() * GetMaxZoomFactor();

	-- maximum maxzoom is 50
	zoomMax = math.min(50, zoomMax);

	-- maximum increments is zoommax
	increments = math.min(increments, zoomMax);

	-- check if we were continously zooming before and stop tracking it if we were
	if (zoom.action == "continousIn") then
		self:MoveViewInStop();
	elseif (zoom.action == "continousOut") then
		self:MoveViewOutStop();
	end

	-- check to see if we were previously zooming in and we're not done yet
	if (zoom.action == "in" and zoom.time and zoom.time >= GetTime()) then
		-- canceled zooming in, get the time left and guess how much distance we didn't cover
		local timeLeft = zoom.time - GetTime();

		-- (seconds) * (yards/second) = yards
		zoom.value = zoom.value + (timeLeft * GetZoomSpeed());

		self:LoseConfidence();
		zoom.action = nil;
		zoom.time = nil;
	end

	-- set the zoom variable
	if (zoom.confident) then
		--we know where we are, then set the zoom, zoom can only go to zoomMax
		local oldZoom = zoom.value;
		zoom.value = math.min(zoom.value + increments, zoomMax);

		if (zoom.value >= zoomMax) then
			increments = zoomMax - oldZoom;
		end
	else
		-- we don't know where we are, just assume that we're not zooming out further than we can go
		zoom.value = zoom.value + increments;

		-- we've now zoomed out past the max, so we can assume that we're at max
		if (zoom.value >= zoomMax) then
			zoom.value = zoomMax;
			zoom.confident = true;
			increments = 0;
		end
	end

	-- set zoom done time
	-- (yard) / (yards/second) = seconds
	local timeToZoom = GetEstimatedZoomTime(increments);
	if (increments > 0) then
		zoom.action = "out";
		if (zoom.time and zoom.time > GetTime()) then
			zoom.time = zoom.time + timeToZoom;
		else
			zoom.time = GetTime() + timeToZoom;
		end
	end

	-- TODO: set timer for this

	parent:DebugPrint("Zoom out:", "increments:", increments, "new:", zoom.value, "time:", timeToZoom, (zoom.confident and "" or "not confident"));
end

function Camera:MoveViewInStart(speed)
	zoom.action = "continousIn";
	zoom.time = GetTime();

	if (speed) then
		zoom.continousSpeed = speed;
	else
		zoom.continousSpeed = 1;
	end
end

function Camera:MoveViewInStop()
	if (zoom.action == "continousIn") then
		-- set value based on time and movement
		--zoom.value = math.max(0, zoom.value - ((GetTime() - zoom.time) * GetCVar("cameraDistanceMoveSpeed") * CONTINOUS_FUDGE_FACTOR * zoom.continousSpeed));

		zoom.action = nil;
		zoom.time = nil;
		self:LoseConfidence();
	end
end

function Camera:MoveViewOutStart(speed)
	zoom.action = "continousOut";
	zoom.time = GetTime();

	if (speed) then
		zoom.continousSpeed = speed;
	else
		zoom.continousSpeed = 1;
	end
end

function Camera:MoveViewOutStop()
	if (zoom.action == "continousOut") then
		-- set value based on time and movement
		--zoom.value = math.min(50, zoom.value + ((GetTime() - zoom.time) * GetCVar("cameraDistanceMoveSpeed") * CONTINOUS_FUDGE_FACTOR * zoom.continousSpeed));

		zoom.action = nil;
		zoom.time = nil;
		self:LoseConfidence();
	end
end

function Camera:SetView(view)
	-- restore zoom values from saves view if we can,
	if (parent.db.global.savedViews[view]) then
		zoom.value = parent.db.global.savedViews[view];
		viewTimer = self:ScheduleTimer(function() zoom.confident = true; end, VIEW_TRANSITION_SPEED);
	else
		self:ResetZoomVars();
	end
end

function Camera:ResetView(view)
	parent.db.global.savedViews[view] = nil;
end

function Camera:SaveView(view)
	-- if we know where we are, then save the zoom level to be restored when the view is set
	if (zoom.confident) then
		parent.db.global.savedViews[view] = zoom.value;

		if (view ~= 1) then
			parent:Print("Saved view "..view.." with absolute zoom.");
		end
	else
		if (view ~= 1) then
			parent:Print("Saved view "..view.." but couldn't save zoom level!");
		end
	end
end

function Camera:ResetZoomVars()
	self:LoseConfidence();
end


--------------------
-- CAMERA ACTIONS --
--------------------
function Camera:IsPerformingAction()
	return (self:IsZooming() or self:IsRotating());
end

function Camera:StopAllActions()
	if (self:IsZooming()) then
		self:StopZooming();
	end

	if (self:IsRotating()) then
		self:StopRotating();
	end
end


------------------
-- ZOOM ACTIONS --
------------------
function Camera:PrintCameraVars()
	parent:Print("Zoom info:", "value:", zoom.value, ((zoom.time and (zoom.time - GetTime() > 0)) and (zoom.action or "no action").." "..(zoom.time - GetTime()) or ""), (zoom.confident and "" or "not confident"));
end

function Camera:ResetConfidence(value)
	ResetView(1);
	SetView(1);
	SetView(1);

	zoom.value = 0;
	zoom.confident = true;

	self:SetZoom(value, .5, true);
end

function Camera:LoseConfidence()
    zoom.value = 0;
    zoom.confident = false;
end

function Camera:IsConfident()
	return zoom.confident;
end

function Camera:IsZooming()
    local ret = false;

    -- has an active action running
	if (zoom.action and zoom.time) then
		if (zoom.time >= GetTime()) then
			ret = true;
		else
			zoom.time = nil;
		end
    end

    -- has an active timer running
    if (zoom.timer) then
        -- has an active timer running
        parent:DebugPrint("Active timer running, so is zooming")
        ret = true;
	end

	return ret;
end

function Camera:StopZooming()
    -- restore oldMax if it exists
    if (zoom.oldMax) then
        SetMaxZoom(zoom.oldMax);
        zoom.oldMax = nil;
    end

    -- restore oldSpeed if it exists
    if (zoom.oldSpeed) then
        SetZoomSpeed(zoom.oldSpeed);
        zoom.oldSpeed = nil;
    end

	-- has a timer waiting
	if (zoom.timer) then
		-- kill the timer
		self:CancelTimer(zoom.timer);
        parent:DebugPrint("Killing zoom timer!");
        zoom.timer = nil;
	end

	if (zoom.action == "in") then
		CameraZoomOut(0);
	elseif (zoom.action == "out") then
		CameraZoomIn(0);
	elseif (zoom.action == "continousIn") then
		MoveViewInStop();
	elseif (zoom.action == "continousOut") then
		MoveViewOutStop();
	end
end

function Camera:GetZoom()
	-- TODO: check up on
	return zoom.value;
end

function Camera:SetZoom(level, time, timeIsMax)
	if (zoom.confident) then
		-- know where we are, perform just a zoom in or zoom out to level
		local difference = self:GetZoom() - level;

        parent:DebugPrint("SetZoom with confident zoom");

		-- set zoom speed to match time
		if (difference ~= 0) then
			zoom.oldSpeed = zoom.oldSpeed or GetZoomSpeed();
			local speed = GetEstimatedZoomSpeed(math.abs(difference), time);

			if ((not timeIsMax) or (timeIsMax and (speed > zoom.oldSpeed))) then
				SetZoomSpeed(speed);

				local func = function ()
                    if (zoom.oldSpeed) then
                        SetZoomSpeed(zoom.oldSpeed);
                        zoom.oldSpeed = nil;
                        zoom.timer = nil;
                    end
				end

				zoom.timer = self:ScheduleTimer(func, GetEstimatedZoomTime(math.abs(difference)));
			end
		end

		if (self:GetZoom() > level) then
			CameraZoomIn(difference);
			return true;
		elseif (self:GetZoom() < level) then
			CameraZoomOut(-difference);
			return true;
		end
	else
        parent:DebugPrint("SetZoom with not confident zoom");

		-- we don't know where we are, so use max zoom trick
		zoom.oldMax = zoom.oldMax or GetMaxZoom();

		-- set max zoom to the level
		SetMaxZoom(level);

		-- zoom out level increments + 1, guarenteeing that we're at the level after zoom
		CameraZoomOut(level+1);

		-- set a timer to restore max zoom and to set confidence
		local func = function ()
			zoom.confident = true;

            if (zoom.oldMax) then
                SetMaxZoom(zoom.oldMax);
                zoom.oldMax = nil;
                zoom.timer = nil;
            end
		end
		zoom.timer = self:ScheduleTimer(func, GetEstimatedZoomTime(level+1));
	end
end

function Camera:ZoomUntil(condition, continousTime, isFitting)
    if (condition) then
        local command, increments, speed = condition(isFitting);

        if (command) then
            if (speed) then
                -- set speed, StopZooming will set it back
                if (speed ~= GetZoomSpeed()) then
                    zoom.oldSpeed = zoom.oldSpeed or GetZoomSpeed();
                    SetZoomSpeed(speed);
                end
            end

            -- actually zoom in the direction
            if (command == "in") then
                -- if we're not already zooming out, zoom in
                if (not (zoom.action and zoom.action == "out" and zoom.time and zoom.time >= (GetTime() - .1))) then
                    CameraZoomIn(increments);

                    zoom.confident = false; -- TODO: find why nameplate zoom looses track of zoom level
                end
            elseif (command == "out") then
                -- if we're not already zooming in, zoom out
               if (not (zoom.action and zoom.action == "in" and zoom.time and zoom.time >= (GetTime() - .1))) then
                   CameraZoomOut(increments);

                   zoom.confident = false; -- TODO: find why nameplate zoom looses track of zoom level
               end
            elseif (command == "set") then
                if (not (zoom.action and zoom.time and zoom.time >= (GetTime() - .1))) then
                    parent:DebugPrint("Nameplate setting zoom!", increments);
                    self:SetZoom(increments, .5, true); -- TODO: look at constant value here
                end
            end

            -- if the cammand is to wait, just setup the timer
            if (command == "wait") then
                parent:DebugPrint("Waiting on namemplate zoom");
                zoom.timer = self:ScheduleTimer("ZoomUntil", .1, condition, continousTime);
            end

            if (increments) then
                -- set a timer for when this should be called again
                zoom.timer = self:ScheduleTimer("ZoomUntil", GetEstimatedZoomTime(increments)*.9, condition, continousTime);
            end

            return true;
        else
            -- the condition is met
            if (zoom.oldSpeed) then
                SetZoomSpeed(zoom.oldSpeed);
                zoom.oldSpeed = nil;
            end

            -- if continously checking, then set the timer for that
            if (continousTime) then
                zoom.timer = self:ScheduleTimer("ZoomUntil", continousTime, condition, continousTime);
            end

            return;
        end
	end
end


----------------------
-- ZOOM CONVENIENCE --
----------------------
function Camera:ZoomInTo(level, time, timeIsMax)
	if (zoom.confident) then
		-- we know where we are, so check zoom level and only zoom in if we need to
		if (self:GetZoom() > level) then
			return self:SetZoom(level, time, timeIsMax);
		end
	else
		-- not confident or relative, just set to the level
		return self:SetZoom(level, time, timeIsMax);
	end
end

function Camera:ZoomOutTo(level, time, timeIsMax)
	if (zoom.confident) then
		-- we know where we are, so check zoom level and only zoom out if we need to
		if (self:GetZoom() < level) then
			return self:SetZoom(level, time, timeIsMax);
		end
	else
		-- not confident or relative, just set to the level
		return self:SetZoom(level, time, timeIsMax);
	end
end

function Camera:ZoomToRange(minLevel, maxLevel, time, timeIsMax)
	if (zoom.confident) then
		-- we know where we are, so check zoom level and only zoom if we need to
		if (self:GetZoom() < minLevel) then
			return self:SetZoom(minLevel, time, timeIsMax);
		elseif (self:GetZoom() > maxLevel) then
			return self:SetZoom(maxLevel, time, timeIsMax);
		end
	else
		-- not confident or relative, just set to the average
		return self:SetZoom((minLevel+maxLevel)/2, time, timeIsMax);
	end
end

function Camera:ZoomFit(zoomMin, zoomMax, fitNameplate, continously, restoreZoom, time, timeIsMax)
    if (UnitExists("target")) then
		-- restore saved
		local npcID = string.match(UnitGUID("target"), "[^-]+-[^-]+-[^-]+-[^-]+-[^-]+-([^-]+)-[^-]+");
		if (restoreZoom and parent.db.global.savedZooms.npcs[npcID]) then
            -- TODO: this is messy, clean it up, checking db from here is awful, passing a lot of parameters is awful
			parent:DebugPrint("Restoring saved zoom for this NPC");
			return self:SetZoom(math.min(zoomMax, math.max(zoomMin, parent.db.global.savedZooms.npcs[npcID])), time, timeIsMax);
		elseif (fitNameplate) then
            parent:DebugPrint("Fitting Nameplate for target");

            -- create a function that returns the zoom direction or nil for stop zooming
            local condition = function()
                local nameplate = C_NamePlate.GetNamePlateForUnit("target");

                -- we're out of the min and max
                if (zoom.value > zoomMax) then
                    return "in", (zoom.value - zoomMax), 20;
                elseif (zoom.value < zoomMin) then
                    return "out", (zoomMin - zoom.value), 20;
                end

                -- if the nameplate exists, then adjust
                if (nameplate) then
                    local _, y = nameplate:GetCenter();
                    local screenHeight = GetScreenHeight() * UIParent:GetEffectiveScale();
                    local difference = screenHeight - y;
                    local ratio = (1 - difference/screenHeight) * 100;

                    parent:DebugPrint("Nameplate at ratio:", ratio);

                    if (difference < 51) then
                        -- we're at the top, go at top speed
                        if ((zoom.value + 1) <= zoomMax) then
                            return "out", 1, 25;
                        end
                    elseif (ratio > 85) then
                        -- we're on screen, but above the target
                        if ((zoom.value + .25) <= zoomMax) then
                            return "out", .25, 22;
                        end
                    elseif (ratio > 50 and ratio <= 80) then
                        -- we're on screen, "in front" of the player
                        if ((zoom.value - .5) >= zoomMin) then
                            return "in", .5, 22;
                        end
                    end
                else
                    -- namemplate doesn't exist, just wait
                    return "wait";
                end

                -- if no adjustments made, and we're at the limits, re-establish confidence
                if (not zoom.confident) then
                    if (zoom.value == zoomMax) then
                        return "set", zoomMax;
                    elseif (zoom.value == zoomMin) then
                        return "set", zoomMin;
                    end
                end

                return nil;
            end

            -- if we're not confident, then just set to min, then ZoomUntil
            if (not zoom.confident) then
                parent:DebugPrint("Zoom fit with no confidence, going to min");
                self:SetZoom(zoomMin, .3, true);
                zoom.timer = self:ScheduleTimer("ZoomUntil", GetEstimatedZoomTime(zoomMin), condition, continously and .75 or nil);
            else
                return self:ZoomUntil(condition, continously and .75 or nil);
            end
        else
            -- TODO: implement something better than this
            return self:SetZoom(zoomMin, time, timeIsMax);
        end
    end
end


--------------------
-- ROTATE ACTIONS --
--------------------
function Camera:IsRotating()
	if (rotation.action) then
		return true;
	end

	return false;
end

function Camera:StopRotating()
	local degrees = 0;
	if (rotation.action == "continousLeft" or rotation.action == "degreesLeft") then
		-- stop rotating
		MoveViewLeftStop();

		-- find the amount of degrees that we rotated for
		degrees = GetEstimatedRotationDegrees(GetTime() - rotation.time, -rotation.speed)
	elseif (rotation.action == "continousRight" or rotation.action == "degreesRight") then
		-- stop rotating
		MoveViewRightStop();

		-- find the amount of degrees that we rotated for
		degrees = GetEstimatedRotationDegrees(GetTime() - rotation.time, rotation.speed)
	end

	if (degrees ~= 0) then
		-- reset rotation variables
		rotation.action = nil;
		rotation.speed = 0;
		rotation.time = nil;
	end

	return degrees;
end

function Camera:StartContinousRotate(speed)
    -- stop rotating if we are already
    if (self:IsRotating()) then
        self:StopRotating();
    end

	if (speed < 0) then
		rotation.action = "continousLeft";
		rotation.speed = -speed;
		rotation.time = GetTime();
		MoveViewLeftStart(rotation.speed);
	elseif (speed > 0) then
		rotation.action = "continousRight";
		rotation.speed = speed;
		rotation.time = GetTime();
		MoveViewRightStart(rotation.speed);
	end
end

function Camera:StartArcRotate(degrees, speed)
	-- TODO: implement

    -- stop rotating if we are already
    if (self:IsRotating()) then
        self:StopRotating();
    end
end

function Camera:RotateDegrees(degrees, transitionTime)
	parent:DebugPrint("RotateDegrees", degrees, transitionTime);
	local speed = GetEstimatedRotationSpeed(degrees, transitionTime);

    -- stop rotating if we are already
    if (self:IsRotating()) then
        self:StopRotating();
    end

	if (speed < 0) then
		-- save rotation variables
		rotation.action = "degreesLeft";
		rotation.speed = -speed;
		rotation.time = GetTime();

		-- start actually rotating
		MoveViewLeftStart(rotation.speed);
	elseif (speed > 0) then
		-- save rotation variables
		rotation.action = "degreesRight";
		rotation.speed = speed;
		rotation.time = GetTime();

		-- start actually rotating
		MoveViewRightStart(speed);
	end

	-- setup a timer to stop the rotation
	if (speed ~= 0) then
		rotation.timer = self:ScheduleTimer("StopRotating", transitionTime);
	end
end


------------------
-- VIEW ACTIONS --
------------------
function Camera:GotoView(view, time, instant, zoomAmount)
    if (not instant) then
        -- TODO: use time and zoomAmount to change view speed

        -- Actually set the view
        SetView(view);
    else
        SetView(view);
        SetView(view);
    end
end
