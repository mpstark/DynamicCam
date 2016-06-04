---------------
-- LIBRARIES --
---------------


---------------
-- CONSTANTS --
---------------
local CONTINOUS_FUDGE_FACTOR = 1.1;
local VIEW_TRANSITION_SPEED = 10; -- 


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
	SetCVar("cameradistancemax", value);
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
	SetCVar("cameradistancemovespeed", value);
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
	return increments/time;
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
	if (zoom.action == "out" and zoom.time and zoom.time > GetTime()) then
		-- canceled zooming out, get the time left and guess how much distance we didn't cover
		local timeLeft = zoom.time - GetTime();

		-- (seconds) * (yards/second) = yards
		zoom.value = zoom.value - (timeLeft * GetZoomSpeed());

		zoom.confident = false;
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
			-- TODO: zoom confidence doesn't mean the same thing as relative
		end
	end

	-- TODO: implement dynamic zoom, better, faster.
	-- -- dynamic zoom
	-- if (self.db.profile.settings.reactiveZoom and not self:IsZooming()) then
		-- local zoomSpeed = tonumber(GetCVar("cameraDistanceMoveSpeed"));

		-- if (math.abs(increments) > (zoomSpeed * self.db.profile.settings.reactiveZoomTime)) then
			-- SetCVar("cameraDistanceMoveSpeed", math.min(50, math.abs(increments)/self.db.profile.settings.reactiveZoomTime));

			-- -- set a timer for reverting the zoom speed
			-- self:ScheduleTimer("SetZoomSpeed", (math.abs(increments)/GetCVar("cameraDistanceMoveSpeed")), self.db.profile.defaultCvars["cameraDistanceMoveSpeed"]);
		-- end
	-- end

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
	if (zoom.action == "in" and zoom.time and zoom.time > GetTime()) then
		-- canceled zooming in, get the time left and guess how much distance we didn't cover
		local timeLeft = zoom.time - GetTime();

		-- (seconds) * (yards/second) = yards
		zoom.value = zoom.value + (timeLeft * GetZoomSpeed());

		zoom.confident = false;
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
			-- TODO: zoom confidence doesn't mean the same thing as relative
		end
	end

	-- TODO: implement dynamic zoom, better, faster.
	-- -- dynamic zoom speed
	-- if (self.db.profile.settings.reactiveZoom and not self:IsZooming()) then
		-- local zoomSpeed = tonumber(GetCVar("cameraDistanceMoveSpeed"));

		-- if (math.abs(increments) > (zoomSpeed * self.db.profile.settings.reactiveZoomTime)) then
			-- SetCVar("cameraDistanceMoveSpeed", math.min(50, math.abs(increments)/self.db.profile.settings.reactiveZoomTime));

			-- -- set a timer for reverting the zoom speed
			-- self:ScheduleTimer("SetZoomSpeed", self.db.profile.settings.reactiveZoomTime, self.db.profile.defaultCvars["cameraDistanceMoveSpeed"]);
		-- end
	-- end

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
		zoom.value = math.max(0, zoom.value - ((GetTime() - zoom.time) * GetCVar("cameraDistanceMoveSpeed") * CONTINOUS_FUDGE_FACTOR * zoom.continousSpeed));

		zoom.action = nil;
		zoom.time = nil;
		zoom.confident = false;
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
		zoom.value = math.min(50, zoom.value + ((GetTime() - zoom.time) * GetCVar("cameraDistanceMoveSpeed") * CONTINOUS_FUDGE_FACTOR * zoom.continousSpeed));

		zoom.action = nil;
		zoom.time = nil;
		zoom.confident = false;
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
	zoom.value = 0;
	zoom.confident = false;
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
	parent:Print("Zoom info:", "value:", zoom.value, (zoom.action or "no action"), (zoom.time and ""..(zoom.time - GetTime()) or ""), (zoom.confident and "" or "not confident"));
end

function Camera:ResetConfidence(value)
	ResetView(1);
	SetView(1);
	SetView(1);

	zoom.value = 0;
	zoom.confident = true;

	self:SetZoom(15, .5, true);
end

function Camera:IsConfident()
	return zoom.confident;
end

function Camera:IsZooming()
	if (zoom.action and zoom.time) then
		if (zoom.time > GetTime()) then
			return true;
		else
			zoom.time = nil;
		end
	end

	return false;
end

function Camera:StopZooming()
	-- has a timer waiting
	if (zoom.timer and (self:TimeLeft(zoom.timer) > 0)) then
		-- restore oldMax if it exists
		if (zoom.oldMax) then
			SetMaxZoom(zoom.oldMax);
		end
		
		-- restore oldSpeed if it exists
		if (zoom.oldSpeed) then
			SetZoomSpeed(zoom.oldSpeed);
		end
		
		-- kill the timer
		self:CancelTimer(zoom.timer);
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
		
		-- set zoom speed to match time
		if (difference ~= 0) then
			zoom.oldSpeed = GetZoomSpeed();
			local speed = math.min(50, GetEstimatedZoomSpeed(math.abs(difference), time));
			
			if ((not timeIsMax) or (timeIsMax and (speed > zoom.oldSpeed))) then
				SetZoomSpeed(speed);
				
				local func = function ()
					SetZoomSpeed(zoom.oldSpeed);
					zoom.oldSpeed = nil;
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
		-- we don't know where we are, so use max zoom trick
		zoom.oldMax = GetMaxZoom();
		
		-- set max zoom to the level
		SetMaxZoom(level);

		-- zoom out level increments + 1, guarenteeing that we're at the level after zoom
		CameraZoomOut(level+1);

		-- set a timer to restore max zoom and to set confidence
		local func = function ()
			zoom.confident = true;
			SetMaxZoom(zoom.oldMax);
			zoom.oldMax = nil;
		end
		zoom.timer = self:ScheduleTimer(func, GetEstimatedZoomTime(level+1));
	end
end

function Camera:ZoomUntil(condition, incrPerTick, speed)
	-- TODO: implement
end


----------------------
-- ZOOM CONVENIENCE --
----------------------
function Camera:ZoomInTo(level, time, timeIsMax)
	if (zoom.confident) then
		-- we know where we are, so check zoom level and only zoom in if we need to
		if (self:GetZoom() > level) then
			parent:DebugPrint("Zoom is too far out, zooming in");
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
			parent:DebugPrint("Zoom is too far in, zooming out");
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
			parent:DebugPrint("Zoom is too far in, zooming out");
			return self:SetZoom(minLevel, time, timeIsMax);
		elseif (self:GetZoom() > maxLevel) then
			parent:DebugPrint("Zoom is too far out, zooming in");
			return self:SetZoom(maxLevel, time, timeIsMax);
		end
	else
		-- not confident or relative, just set to the average
		return self:SetZoom((minLevel+maxLevel)/2, time, timeIsMax);
	end
end

function Camera:ZoomFit(zoomMin, zoomMax, fitNameplate, restoreZoom, time, timeIsMax)
	-- TODO: implement nameplate fitting
    if (UnitExists("target")) then
		-- restore saved
		local npcID = string.match(UnitGUID("target"), "[^-]+-[^-]+-[^-]+-[^-]+-[^-]+-([^-]+)-[^-]+");
		if (restoreZoom and parent.db.global.savedZooms.npcs[npcID]) then
            -- TODO: this is messy, clean it up
			parent:DebugPrint("Restoring saved zoom for this NPC");
			return self:SetZoom(math.min(zoomMax, math.max(zoomMin, parent.db.global.savedZooms.npcs[npcID])), time, timeIsMax);
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
end

function Camera:RotateDegrees(degrees, transitionTime)
	parent:DebugPrint("RotateDegrees", degrees, transitionTime);
	local speed = GetEstimatedRotationSpeed(degrees, transitionTime);
	
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





----------
-- ZOOM --
----------
-- local zoomUntilTimer = nil;
-- local zoomUntilZoomTime = nil;

-- local function zoomUntilTick(condition, speed, zoomFunc)
	-- if (condition and not condition()) then
		-- -- condition not yet met
		-- if (zoomFunc and (not zoomUntilZoomTime or zoomUntilZoomTime <= GetTime())) then
			-- zoomFunc(speed/3);
			-- zoomUntilZoomTime = GetTime() + (speed/6)/GetCVar("cameraDistanceMoveSpeed");
		-- end
	-- else
		-- zoomUntilZoomTime = nil;

		-- DynamicCam:CancelTimer(zoomUntilTimer);
	-- end
-- end

-- function Camera:ZoomFit(zoomMin, zoomMax, fitNameplate, restoreZoom)
	-- parent:DebugPrint("Zoom Fit");
	-- --TODO
	-- if (not zoom.relative and UnitExists("target")) then
		-- -- restore saved
		-- local npcID = string.match(UnitGUID("target"), "[^-]+-[^-]+-[^-]+-[^-]+-[^-]+-([^-]+)-[^-]+");
		-- if (restoreZoom and self.db.global.savedZooms.npcs[npcID]) then
			-- parent:DebugPrint("Restoring saved zoom for this NPC");
			-- return self:ZoomSet(math.min(zoomMax, math.max(zoomMin, self.db.global.savedZooms.npcs[npcID])));
		-- end

		-- -- fit nameplate
		-- local nameplate = C_NamePlate.GetNamePlateForUnit("target");
		-- if (fitNameplate and nameplate) then
			-- local _, y = nameplate:GetCenter();
			-- local screenHeight = GetScreenHeight() * UIParent:GetEffectiveScale();
			-- local ratio = (1 - (screenHeight - y)/screenHeight) * 100;

			-- parent:DebugPrint("Fitting Nameplate for target");

			-- if (ratio > 80) then
				-- -- create a function that will check if we've zoomed out enough or reached max
				-- local func = function()
					-- local _, y = nameplate:GetCenter();
					-- local screenHeight = GetScreenHeight() * UIParent:GetEffectiveScale();
					-- local ratio = (1 - (screenHeight - y)/screenHeight) * 100;

					-- return ((ratio <= 80) or (self:GetCurrentZoom() >= zoomMax));
				-- end

				-- self:ZoomOutUntil(1, func);
				-- return true;
			-- elseif (ratio > 50 and ratio < 79) then
				-- -- create a function that will check if we've zoomed in enough or reached min
				-- local func = function()
					-- local _, y = nameplate:GetCenter();
					-- local screenHeight = GetScreenHeight() * UIParent:GetEffectiveScale();
					-- local ratio = (1 - (screenHeight - y)/screenHeight) * 100;

					-- return ((ratio >= 80) or (self:GetCurrentZoom() <= zoomMin));
				-- end

				-- self:ZoomInUntil(1, func);
				-- return true;
			-- end
		-- end
	-- end

	-- return false;
-- end
