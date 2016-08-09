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

local zoom = {
	action = nil,
	time = nil,
	continousSpeed = 1,

	timer = nil,
	oldSpeed = nil,
}

local rotation = {
	action = nil,
	time = nil,
	speed = 0,
	timer = nil,
};

local nameplateRestore = {};
local function RestoreNameplates()
	-- restore nameplates if they need to be restored
	if (not InCombatLockdown()) then
		for k,v in pairs(nameplateRestore) do
			SetCVar(k, v);
		end
		nameplateRestore = {};
	end
end


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
local function GetMaxZoomFactor()
	return tonumber(GetCVar("cameradistancemaxfactor"));
end

local function SetMaxZoomFactor(value)
	SetCVar("cameradistancemaxfactor", value);
end

local function GetMaxZoom()
	return 15*GetMaxZoomFactor();
	--return tonumber(GetCVar("cameradistancemax"));
end

local function SetMaxZoom(value)
    if (value) then
        parent:DebugPrint("SetMaxZoom:", value);
        -- SetCVar("cameradistancemax", value);
		SetMaxZoomFactor(math.max(1, math.min(2.6, value/15)));
		parent:DebugPrint("FACTOR TO:", GetMaxZoomFactor(), value/15, math.max(0, math.min(2.6, value/15)));
    else
        parent:DebugPrint("SERIOUS FUCKING ERROR");
    end
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
function Camera:CameraZoomIn(inc, automated)
	local zoomMax = GetMaxZoom();
	local increments = inc or 1;

	-- maximum maxzoom is 39
	zoomMax = math.min(39, zoomMax);

	-- maximum increments is zoommax
	increments = math.min(increments, zoomMax);

	-- can't zoom in past 0
	if ((GetCameraZoom() - increments) <= 0) then
		increments = GetCameraZoom();
	end

	-- check if we were continously zooming before and stop tracking it if we were
	if (zoom.action == "continousIn") then
		self:MoveViewInStop();
	elseif (zoom.action == "continousOut") then
		self:MoveViewOutStop();
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

	parent:DebugPrint(automated and "Automated" or "Manual", "Zoom in:", "inc", inc, "increments:", increments, "time:", timeToZoom);
end

function Camera:CameraZoomOut(inc, automated)
	local zoomMax = GetMaxZoom();
	local increments = inc or 1;

	-- maximum maxzoom is 39
	zoomMax = math.min(39, zoomMax);

	-- maximum increments is zoommax
	increments = math.min(increments, zoomMax);

	-- can't zoom out past zoomMax
	if ((GetCameraZoom() + increments) >= zoomMax) then
		increments = (zoomMax - GetCameraZoom() > .001) and (zoomMax - GetCameraZoom()) or 0;
	end

	-- check if we were continously zooming before and stop tracking it if we were
	if (zoom.action == "continousIn") then
		self:MoveViewInStop();
	elseif (zoom.action == "continousOut") then
		self:MoveViewOutStop();
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

	parent:DebugPrint(automated and "Automated" or "Manual", "Zoom out:", "inc", inc, "increments:", increments, "time:", timeToZoom);
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
		zoom.action = nil;
		zoom.time = nil;
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
		zoom.action = nil;
		zoom.time = nil;
	end
end

function Camera:SetView(view)
end

function Camera:ResetView(view)
end

function Camera:SaveView(view)
end

function Camera:ResetZoomVars()
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
	parent:Print("Zoom info:", "curValue:", GetCameraZoom(), ((zoom.time and (zoom.time - GetTime() > 0)) and (zoom.action or "no action").." "..(zoom.time - GetTime()) or ""));
end

function Camera:IsZooming()
    local ret = false;

    -- has an active action running
	if (zoom.action and zoom.time) then
		if (zoom.time > GetTime()) then
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

	-- restore nameplates if need to
	RestoreNameplates();

	if ((zoom.action == "in" or zoom.action == "in") and zoom.time and (zoom.time > (GetTime() + .25))) then
		-- we're obviously still zooming in from an incremental zoom, cancel it
		CameraZoomOut(0, true);
		CameraZoomIn(0, true);
		zoom.action = nil;
		zoom.time = nil;
	elseif (zoom.action == "continousIn") then
		MoveViewInStop();
	elseif (zoom.action == "continousOut") then
		MoveViewOutStop();
	end
end

function Camera:SetZoom(level, time, timeIsMax)
	-- know where we are, perform just a zoom in or zoom out to level
	local difference = GetCameraZoom() - level;

	parent:DebugPrint("SetZoom", level, time, timeIsMax, "difference", difference);

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

	if (GetCameraZoom() > level) then
		CameraZoomIn(difference, true);
		return true;
	elseif (GetCameraZoom() < level) then
		CameraZoomOut(-difference, true);
		return true;
	end
end

function Camera:ZoomUntil(condition, continousTime, isFitting)
    if (condition) then
        local command, increments, speed = condition(isFitting);

        if (command) then
            if (speed) then
                -- set speed, StopZooming will set it back
                if (speed > GetZoomSpeed()) then
                    zoom.oldSpeed = zoom.oldSpeed or GetZoomSpeed();
                    SetZoomSpeed(speed);
                end
            end

            -- actually zoom in the direction
            if (command == "in") then
                -- if we're not already zooming out, zoom in
                if (not (zoom.action and zoom.action == "out" and zoom.time and zoom.time >= (GetTime() - .1))) then
                    CameraZoomIn(increments, true);
                end
            elseif (command == "out") then
                -- if we're not already zooming in, zoom out
               if (not (zoom.action and zoom.action == "in" and zoom.time and zoom.time >= (GetTime() - .1))) then
            		CameraZoomOut(increments, true);
               end
            elseif (command == "set") then
                if (not (zoom.action and zoom.time and zoom.time >= (GetTime() - .1))) then
                    parent:DebugPrint("Nameplate setting zoom!", increments);
                    self:SetZoom(increments, .5, true); -- constant value here
                end
            end

            -- if the cammand is to wait, just setup the timer
            if (command == "wait") then
                parent:DebugPrint("Waiting on namemplate zoom");
                zoom.timer = self:ScheduleTimer("ZoomUntil", .1, condition, continousTime);
            end

            if (increments) then
                -- set a timer for when this should be called again
                zoom.timer = self:ScheduleTimer("ZoomUntil", GetEstimatedZoomTime(increments)*.75, condition, continousTime, true);
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
			else
				zoom.timer = nil;

				-- restore nameplates if they need to be restored
				RestoreNameplates();
            end

            return;
        end
	end
end


----------------------
-- ZOOM CONVENIENCE --
----------------------
function Camera:ZoomInTo(level, time, timeIsMax)
	if (GetCameraZoom() > level) then
		return self:SetZoom(level, time, timeIsMax);
	end
end

function Camera:ZoomOutTo(level, time, timeIsMax)
	if (GetCameraZoom() < level) then
		return self:SetZoom(level, time, timeIsMax);
	end
end

function Camera:ZoomToRange(minLevel, maxLevel, time, timeIsMax)
	if (GetCameraZoom() < minLevel) then
		return self:SetZoom(minLevel, time, timeIsMax);
	elseif (GetCameraZoom() > maxLevel) then
		return self:SetZoom(maxLevel, time, timeIsMax);
	end
end

function Camera:FitNameplate(zoomMin, zoomMax, increments, nameplatePosition, sensitivity, speedMultiplier, continously, toggleNameplate)
	parent:DebugPrint("Fitting Nameplate for target");

	-- create a function that returns the zoom direction or nil for stop zooming
	local condition = function(isFitting)
		local nameplate = C_NamePlate.GetNamePlateForUnit("target");

		-- we're out of the min and max
		if (GetCameraZoom() > zoomMax) then
			return "in", (GetCameraZoom() - zoomMax), 20;
		elseif (GetCameraZoom() < zoomMin) then
			return "out", (zoomMin - GetCameraZoom()), 20;
		end

		-- if the nameplate exists, then adjust
		if (nameplate) then
			local top = nameplate:GetTop();
			local screenHeight = GetScreenHeight() * UIParent:GetEffectiveScale();
			local difference = screenHeight - top;
			local ratio = (1 - difference/screenHeight) * 100;

			if (isFitting) then
				parent:DebugPrint("Fitting", "Ratio:", ratio, "Bounds:", math.max(50, nameplatePosition - sensitivity/2), math.min(94, nameplatePosition + sensitivity/2));
			else
				parent:DebugPrint("Ratio:", ratio, "Bounds:", math.max(50, nameplatePosition - sensitivity), math.min(94, nameplatePosition + sensitivity));
			end

			if (difference < 40) then
				-- we're at the top, go at top speed
				if ((GetCameraZoom() + (increments*4)) <= zoomMax) then
					return "out", increments*4, 14*speedMultiplier;
				end
			elseif (ratio > (isFitting and math.min(94, nameplatePosition + sensitivity/2) or math.min(94, nameplatePosition + sensitivity))) then
				-- we're on screen, but above the target
				if ((GetCameraZoom() + increments) <= zoomMax) then
					return "out", increments, 11*speedMultiplier;
				end
			elseif (ratio > 50 and ratio <= (isFitting and math.max(50, nameplatePosition - sensitivity/2) or math.max(50, nameplatePosition - sensitivity))) then
				-- we're on screen, "in front" of the player
				if ((GetCameraZoom() - (increments)) >= zoomMin) then
					return "in", increments, 11*speedMultiplier;
				end
			end
		else
			-- nameplate doesn't exist, toggle it on
			if (toggleNameplate and not InCombatLockdown() and not nameplateRestore["nameplateShowAll"]) then
				nameplateRestore["nameplateShowAll"] = GetCVar("nameplateShowAll");
				nameplateRestore["nameplateShowFriends"] = GetCVar("nameplateShowFriends");
				nameplateRestore["nameplateShowEnemies"] = GetCVar("nameplateShowEnemies");

				-- show nameplates
				SetCVar("nameplateShowAll", 1);
				if (UnitExists("target")) then
					if (UnitIsFriend("player", "target")) then
						SetCVar("nameplateShowFriends", 1);
					else
						SetCVar("nameplateShowEnemies", 1);
					end
				else
					SetCVar("nameplateShowFriends", 1);
					SetCVar("nameplateShowEnemies", 1);
				end
			end

			-- namemplate doesn't exist, just wait
			return "wait";
		end

		return nil;
	end

	zoom.timer = self:ScheduleTimer("ZoomUntil", .25, condition, continously and .75 or nil, true);

	return true;
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
