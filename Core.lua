---------------
-- LIBRARIES --
---------------
local AceAddon = LibStub("AceAddon-3.0");


-------------
-- GLOBALS --
-------------
DynamicCam = AceAddon:NewAddon("DynamicCam", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");
DynamicCam.currentSituation = nil;


------------
-- LOCALS --
------------
local _;
local started;
local Camera;
local Options;
local conditionFunctionCache = {};
local conditionExecutionCache = {};
local evaluateTimer;
local restoration = {};
local delayTime;
local events = {};


--------
-- DB --
--------
local defaults = {
    global = {
        savedViews = {},
        savedZooms = {
            npcs = {
            },
        },
    },
    profile = {
        enabled = true,
        advanced = false,
        debugMode = false,
        defaultCvars = {
            ["cameradistancemax"] = 50,
            ["cameraDistanceMaxFactor"] = 1,
            ["cameraDistanceMoveSpeed"] = 8.33,
            ["cameraovershoulder"] = 0,
            ["cameraheadmovementstrength"] = 0,
            ["cameradynamicpitch"] = 0,
            ["cameralockedtargetfocusing"] = 0,
            --["cameraheadmovementrange"] = 6,
            --["cameraheadmovementsmoothrate"] = 40,
        },
        settings = {
            reactiveZoom = true,
            reactiveZoomTime = 1,
        },
        situations = {
            ["*"] = {
                name = "",
                enabled = true,
                priority = 0,
                condition = "return false",
                delay = 0,
                executeOnInit = "",
                executeOnEnter = "",
                executeOnExit = "",
                cameraActions = {
                    transitionTime = .75,
                    timeIsMax = true,

                    rotate = false,
                    rotateSetting = "continous",
                    rotateSpeed = .1,
                    rotateDegrees = 0,

                    zoomSetting = "off",
                    zoomValue = 10,
                    zoomMin = 5,
                    zoomMax = 20,

                    zoomFitContinous = false,
                    zoomFitSpeedMultiplier = 2,
                    zoomFitPosition = 84,
                    zoomFitSensitivity = 5,
                    zoomFitIncrements = .25,
                },
                view = {
                    enabled = false,
                    viewNumber = 5,
                    restoreView = false,
                    instant = false,
                },
                targetLock = {
                    enabled = false,
                    onlyAttackable = true,
                    dead = false,
                    nameplateVisible = true,
                },
                hideFrames = {},
                cameraCVars = {},
            },
        },
    },
};


----------
-- CORE --
----------
function DynamicCam:OnInitialize()
    -- setup db
    self.db = LibStub("AceDB-3.0"):New("DynamicCamDB", defaults, true);
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig");
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig");
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig");
    self.db.RegisterCallback(self, "OnDatabaseShutdown", "Shutdown");
    self:RefreshConfig();

    -- setup chat command
    self:RegisterChatCommand("dynamiccam", "OpenMenu");
    self:RegisterChatCommand("dc", "OpenMenu");

    self:RegisterChatCommand("saveview", "SaveViewCC");
    self:RegisterChatCommand("sv", "SaveViewCC");

    self:RegisterChatCommand("zoomconfidence", "ZoomConfidenceCC");
    self:RegisterChatCommand("zc", "ZoomConfidenceCC");

    self:RegisterChatCommand("zoominfo", "ZoomInfoCC");
    self:RegisterChatCommand("zi", "ZoomInfoCC");

    -- disable if the setting is enabled
    if (not self.db.profile.enabled) then
        self:Disable();
    end
end

function DynamicCam:OnEnable()
    self.db.profile.enabled = true;

    self:Startup();
end

function DynamicCam:OnDisable()
    self.db.profile.enabled = false;
    self:Shutdown();
end

function DynamicCam:Startup()
    -- make sure that shortcuts have values
    if (not Options or not Camera) then
        Camera = self.Camera;
        Options = self.Options;
    end

    -- apply default settings
    for cvar, value in pairs(self.db.profile.defaultCvars) do
        SetCVar(cvar, value);
    end

    -- register all events for evaluating situations
    self:RegisterEvents();
    
    -- initial evaluate needs to be delayed because the camera doesn't like changing cvars on startup
    evaluateTimer = self:ScheduleTimer("EvaluateSituations", 3);

    started = true;
end

function DynamicCam:Shutdown()
    -- kill the evaluate timer if it's running
    if (evaluateTimer) then
        self:CancelTimer(evaluateTimer);
        evaluateTimer = nil;
    end

    -- exit the current situation if in one
    if (self.currentSituation) then
        self:ExitSituation(self.currentSituation);
    end

    -- reset zoom
    Camera:ResetZoomVars();

    events = {};
    self:UnregisterAllEvents();

    -- apply default settings
    for cvar, value in pairs(self.db.profile.defaultCvars) do
        SetCVar(cvar, value);
    end

    started = false;
end

function DynamicCam:DebugPrint(...)
    if (self.db.profile.debugMode) then
        self:Print(...);
    end
end


----------------
-- SITUATIONS --
----------------
local delayTimer;
local lastEvaluate;
local TIME_BEFORE_NEXT_EVALUATE = .1;
local EVENT_DOUBLE_TIME = .2;
function DynamicCam:EvaluateSituations(event, possibleUnit, ...)
    if (event and possibleUnit and type(possibleUnit) == 'string' and string.lower(possibleUnit) ~= "player") then
        -- ignore events not pertaining to player state
        -- self:DebugPrint("EvaluateSituations", "IGNORING EVENT", event, possibleUnit, ...);
        return;
    end

    -- we don't want to evaluate too often, some of the events can be *very* spammy
    if (not lastEvaluate or (lastEvaluate and (lastEvaluate + TIME_BEFORE_NEXT_EVALUATE) < GetTime())) then
        local highestPriority = -100;
        local topSituation;

        -- self:DebugPrint("EvaluateSituations", event, possibleUnit, ..., lastEvaluate and (GetTime() - lastEvaluate));

        lastEvaluate = GetTime();
        if (evaluateTimer) then
            self:CancelTimer(evaluateTimer);
            evaluateTimer = nil;
        end

        -- go through all situations pick the best one
        for id, situation in pairs(self.db.profile.situations) do
            if (situation.enabled) then
                if (not conditionFunctionCache[situation.condition]) then
                    conditionFunctionCache[situation.condition] = assert(loadstring(situation.condition));
                end

                -- evaluate the condition, if it checks out and the priority is larger then any other, set it
                conditionExecutionCache[id] = conditionFunctionCache[situation.condition]();
                if (conditionExecutionCache[id] and (situation.priority > highestPriority)) then
                    highestPriority = situation.priority;
                    topSituation = situation;
                end
            end
        end

        if (topSituation) then
            if (self.currentSituation) then
                if (topSituation ~= self.currentSituation) then
                    -- check if current situation has a delay and if it does, if it's 'cooling down'
                    if (self.currentSituation.delay > 0) then
                        if (not delayTime) then
                            -- not yet cooling down
                            delayTime = GetTime() + self.currentSituation.delay;
                            delayTimer = self:ScheduleTimer("EvaluateSituations", self.currentSituation.delay, "DELAY_TIMER");
                        elseif (delayTime > GetTime()) then
                            -- still cooling down, don't swap
                        else
                            delayTime = nil;
                            self:SetSituation(topSituation);
                        end
                    else
                        self:SetSituation(topSituation);
                    end
                else
                    -- topSituation is currentSituation, clear the delay
                    delayTime = nil;
                end
            else
                -- no currentSituation
                self:SetSituation(topSituation);
            end

            -- do target lock evaluation anyways
            self:EvaluateTargetLock();
        else
            --none of the situations are active, leave the current situation
            if (self.currentSituation) then
                self:ExitSituation(self.currentSituation);
            end
        end

        if (event and event ~= "EVENT_DOUBLER" and event ~= "DELAY_TIMER") then
            evaluateTimer = self:ScheduleTimer("EvaluateSituations", EVENT_DOUBLE_TIME, "EVENT_DOUBLER");
        end
    else
        if (not evaluateTimer) then
            evaluateTimer = self:ScheduleTimer("EvaluateSituations", TIME_BEFORE_NEXT_EVALUATE, "EVALUATE_TIMER");
        end
    end
end

function DynamicCam:SetSituation(situation)
    local oldSituation = self.currentSituation;

    -- if currently in a situation, leave it
    if (self.currentSituation) then
        self:ExitSituation(self.currentSituation, situation);
    end

    -- go into the new situation
    self:EnterSituation(situation, oldSituation);
end

function DynamicCam:EnterSituation(situation, oldSituation)
    self:DebugPrint("Entering situation", situation.name);

    -- set currentSituation
    self.currentSituation = situation;

    -- set view settings
    if (situation.view.enabled) then
        if (situation.view.restoreView) then
            SaveView(1);
        end

        -- calculate zoom difference, if we know it
        local zoomAmount;
        if (Camera:IsConfident() and self.db.global.savedViews[view]) then
            zoomAmount = Camera:GetZoom() - self.db.global.savedViews[view];
        end

        Camera:GotoView(situation.view.viewNumber, situation.cameraActions.transitionTime, situation.view.instant, zoomAmount);
    end

    -- set all cvars
    restoration[situation] = {};
    restoration[situation].cvars = {};
    for cvar, value in pairs(situation.cameraCVars) do
        restoration[situation].cvars[cvar] = GetCVar(cvar);
        SetCVar(cvar, value);
    end

    -- make sure to save cameralockedtargetfocusing
    if (situation.targetLock.enabled) then
        restoration[situation].cvars["cameralockedtargetfocusing"] = GetCVar("cameralockedtargetfocusing");
    end

    -- ZOOM --
    -- save old zoom level
    if (Camera:IsConfident()) then
        restoration[situation].zoom = Camera:GetZoom();
        restoration[situation].zoomSituation = oldSituation;
    end

    -- set zoom level
    local adjustedZoom;
    local a = situation.cameraActions;
    if (a.zoomSetting == "in") then
        adjustedZoom = Camera:ZoomInTo(a.zoomValue, a.transitionTime, a.timeIsMax);
    elseif (a.zoomSetting == "out") then
        adjustedZoom = Camera:ZoomOutTo(a.zoomValue, a.transitionTime, a.timeIsMax);
    elseif (a.zoomSetting == "set") then
        adjustedZoom = Camera:SetZoom(a.zoomValue, a.transitionTime, a.timeIsMax);
    elseif (a.zoomSetting == "range") then
        adjustedZoom = Camera:ZoomToRange(a.zoomMin, a.zoomMax, a.transitionTime, a.timeIsMax);
    elseif (a.zoomSetting == "fit") then
        adjustedZoom = Camera:FitNameplate(a.zoomMin, a.zoomMax, a.zoomFitIncrements, a.zoomFitPosition, a.zoomFitSensitivity, a.zoomFitSpeedMultiplier, a.zoomFitContinous);
    end

    -- if we didn't adjust the soom, then reset oldZoom
    if (not adjustedZoom) then
        restoration[situation].zoom = nil;
        restoration[situation].zoomSituation = nil;
    end

    -- ROTATE --
    if (a.rotate) then
        if (a.rotateSetting == "continous") then
            Camera:StartContinousRotate(a.rotateSpeed);
        elseif (a.rotateSetting == "degrees") then
            Camera:RotateDegrees(a.rotateDegrees, a.transitionTime);
        end
    end

    -- hide frames
    restoration[situation].hiddenFrames = {};
    for frameName, value in pairs(situation.hideFrames) do
        if (value and _G[frameName]) then
            local frame = _G[frameName];

            if (frame.Show and frame:IsShown()) then
                restoration[situation].hiddenFrames[frameName] = frame.Show;

                if (frameName ~= "UIParent") then
                    -- prevent from being shown and hide the frame
                    frame.Show = function() end;
                end
            end

            -- hide the frame
            frame:Hide();
        end
    end

    -- update the GUI
    Options:SelectSituation();
end

function DynamicCam:ExitSituation(situation, newSituation)
    self:DebugPrint("Exiting situation", situation.name);

    -- restore cvars to their values before the situation arose
    for cvar, value in pairs(restoration[situation].cvars) do
        SetCVar(cvar, value);
    end

    -- restore view that is enabled
    if (situation.view.enabled and situation.view.restoreView) then
        -- calculate zoom difference, if we know it
        local zoomAmount;
        if (Camera:IsConfident() and self.db.global.savedViews[1]) then
            zoomAmount = Camera:GetZoom() - self.db.global.savedViews[1];
        end

        Camera:GotoView(1, .75, situation.view.instant, zoomAmount); -- TODO: look into constant time here
    end

    local a = situation.cameraActions;

    -- stop rotating if we started to
    if (a.rotate) then
        if (a.rotateSetting == "continous") then
            local degrees = Camera:StopRotating();
            self:DebugPrint("Ended rotate, degrees rotated:", degrees);
            --Camera:RotateDegrees(-degrees, .5); -- TODO: this is a good idea until it's a bad idea
        elseif (a.rotateSetting == "degrees") then
            if (Camera:IsRotating()) then
                -- interrupted rotation
                local degrees = Camera:StopRotating();
                Camera:RotateDegrees(-degrees, .75); -- TODO: look into constant time here
            else
                Camera:RotateDegrees(-a.rotateDegrees, .75); -- TODO: look into constant time here
            end
        end
    end

    -- stop zooming if we're still zooming
    if (a.zoomSetting ~= "off" and Camera:IsZooming()) then
        self:DebugPrint("Still zooming for situation, stop zooming.")
        Camera:StopZooming();
    end

    -- save zoom for Zoom Fit
    -- if (Camera:IsConfident() and a.zoomSetting == "fit" and a.zoomFitSave) then
        -- if (UnitExists("target")) then
            -- self:DebugPrint("Saving fit value for this target");
            -- local npcID = string.match(UnitGUID("target"), "[^-]+-[^-]+-[^-]+-[^-]+-[^-]+-([^-]+)-[^-]+");
            -- self.db.global.savedZooms.npcs[npcID] = Camera:GetZoom();
        -- end
    -- end

    -- restore zoom level if we saved one
    if (self:ShouldRestoreZoom(situation, newSituation)) then
        Camera:SetZoom(restoration[situation].zoom, .75, true); -- TODO: look into constant time here
        self:DebugPrint("Restoring zoom level.");
    end

    -- unhide hidden frames
    for frameName, value in pairs(restoration[situation].hiddenFrames) do
        if (value) then
            local frame = _G[frameName];
            if (frameName ~= "UIParent") then
                -- restore show function
                frame.Show = value;
            end

            -- show the frame and fade it back in
            _G[frameName]:Show();
        end
    end

    wipe(restoration[situation]);
    self.currentSituation = nil;
end

function DynamicCam:GetSituationList()
    local situationList = {};

    for id, situation in pairs(self.db.profile.situations) do
        local prefix = "";
        local suffix = "";

        if (self.currentSituation == situation) then
            prefix = "|cFF00FF00";
            suffix = "|r";
        elseif (not situation.enabled) then
            prefix = "|cFF808A87";
            suffix = "|r";
        elseif (conditionExecutionCache[id]) then
            prefix = "|cFF63B8FF";
            suffix = "|r";
        end

        situationList[id] = prefix..situation.name..suffix;
    end

    return situationList;
end

-- TODO: add to another file
-- TODO: have multiple defaults
function DynamicCam:GetDefaultSituations()
    local situations = {};
    local newSituation;

    newSituation = self:CreateSituation("City");
    newSituation.priority = 1;
    newSituation.condition = "return IsResting();";
    newSituation.events = {"PLAYER_UPDATE_RESTING"};
    newSituation.cameraActions.zoomSetting = "range";
    newSituation.cameraActions.zoomMin = 8;
    newSituation.cameraActions.zoomMax = 20;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    situations["001"] = newSituation;

    newSituation = self:CreateSituation("City (Indoors)");
    newSituation.priority = 11;
    newSituation.condition = "return IsResting() and IsIndoors();";
    newSituation.events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "SPELL_UPDATE_USABLE"};
    newSituation.cameraActions.zoomSetting = "in";
    newSituation.cameraActions.zoomValue = 8;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    situations["002"] = newSituation;

    newSituation = self:CreateSituation("City (Mounted)");
    newSituation.priority = 101;
    newSituation.condition = "return IsResting() and IsMounted();";
    newSituation.events = {"PLAYER_UPDATE_RESTING", "SPELL_UPDATE_USABLE", "UNIT_AURA"};
    newSituation.cameraActions.zoomSetting = "out";
    newSituation.cameraActions.zoomValue = 30;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    situations["003"] = newSituation;

    newSituation = self:CreateSituation("World");
    newSituation.priority = 0;
    newSituation.condition = "return not IsResting() and not IsInInstance();";
    newSituation.events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_NEW_AREA"};
    newSituation.cameraActions.zoomSetting = "range";
    newSituation.cameraActions.zoomMin = 8;
    newSituation.cameraActions.zoomMax = 20;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    situations["004"] = newSituation;

    newSituation = self:CreateSituation("World (Indoors)");
    newSituation.priority = 10;
    newSituation.condition = "return not IsResting() and not IsInInstance() and IsIndoors();";
    newSituation.events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"};
    newSituation.cameraActions.zoomSetting = "in";
    newSituation.cameraActions.zoomValue = 10;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    situations["005"] = newSituation;

    newSituation = self:CreateSituation("World (Combat)");
    newSituation.priority = 50;
    newSituation.condition = "return not IsInInstance() and UnitAffectingCombat(\"player\");";
    newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"};
    newSituation.cameraActions.zoomSetting = "fit";
    newSituation.cameraActions.zoomFitContinous = true;
    newSituation.cameraActions.zoomMin = 7;
    newSituation.cameraActions.zoomMax = 30;
    newSituation.cameraCVars["cameraovershoulder"] = 1.5;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    newSituation.targetLock.enabled = true;
    newSituation.targetLock.nameplateVisible = true;
    situations["006"] = newSituation;

    newSituation = self:CreateSituation("World (Mounted)");
    newSituation.priority = 100;
    newSituation.condition = "return not IsResting() and not IsInInstance() and IsMounted();";
    newSituation.events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE", "UNIT_AURA"};
    newSituation.cameraActions.zoomSetting = "out";
    newSituation.cameraActions.zoomValue = 30;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    situations["007"] = newSituation;



    newSituation = self:CreateSituation("Dungeon");
    newSituation.enabled = false;
    newSituation.priority = 2;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\");";
    newSituation.events = {"ZONE_CHANGED_NEW_AREA"};
    situations["020"] = newSituation;

    newSituation = self:CreateSituation("Dungeon (Outdoors)");
    newSituation.enabled = false;
    newSituation.priority = 12;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\") and IsOutdoors();";
    newSituation.events = {"ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"};
    situations["021"] = newSituation;

    newSituation = self:CreateSituation("Dungeon (Mounted)");
    newSituation.enabled = false;
    newSituation.priority = 102;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\") and IsMounted();";
    newSituation.events = {"ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE", "UNIT_AURA"};
    situations["022"] = newSituation;

    newSituation = self:CreateSituation("Dungeon (Combat, Boss)");
    newSituation.enabled = false;
    newSituation.priority = 302;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\") and UnitAffectingCombat(\"player\") and IsEncounterInProgress();";
    newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_STOP", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"};
    situations["023"] = newSituation;

    newSituation = self:CreateSituation("Dungeon (Combat, Trash)");
    newSituation.enabled = false;
    newSituation.priority = 202;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\") and UnitAffectingCombat(\"player\") and not IsEncounterInProgress();";
    newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_STOP", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"};
    situations["024"] = newSituation;



    newSituation = self:CreateSituation("Raid");
    newSituation.enabled = false;
    newSituation.priority = 3;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\");";
    newSituation.events = {"ZONE_CHANGED_NEW_AREA"};
    situations["030"] = newSituation;

    newSituation = self:CreateSituation("Raid (Outdoors)");
    newSituation.enabled = false;
    newSituation.priority = 13;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and IsOutdoors();";
    newSituation.events = {"ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"};
    situations["031"] = newSituation;

    newSituation = self:CreateSituation("Raid (Mounted)");
    newSituation.enabled = false;
    newSituation.priority = 103;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and IsMounted();";
    newSituation.events = {"ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE", "UNIT_AURA"};
    situations["032"] = newSituation;

    newSituation = self:CreateSituation("Raid (Combat, Boss)");
    newSituation.enabled = false;
    newSituation.priority = 303;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and UnitAffectingCombat(\"player\") and IsEncounterInProgress();";
    newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_STOP", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"};
    situations["033"] = newSituation;

    newSituation = self:CreateSituation("Raid (Combat, Trash)");
    newSituation.enabled = false;
    newSituation.priority = 203;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and UnitAffectingCombat(\"player\") and not IsEncounterInProgress();";
    newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_STOP", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"};
    situations["034"] = newSituation;





    newSituation = self:CreateSituation("Taxi");
    newSituation.priority = 1000;
    newSituation.condition = "return UnitOnTaxi(\"player\");";
    newSituation.events = {"PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED"};
    newSituation.cameraActions.zoomSetting = "set";
    newSituation.cameraActions.zoomValue = 15;
    newSituation.cameraCVars["cameraovershoulder"] = -1;
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.hideFrames["UIParent"] = true;
    situations["100"] = newSituation;

    newSituation = self:CreateSituation("Vehicle");
    newSituation.priority = 1000;
    newSituation.condition = "return UnitUsingVehicle(\"player\");";
    newSituation.events = {"UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE"};
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    situations["101"] = newSituation;

    newSituation = self:CreateSituation("Hearthing");
    newSituation.priority = 20;
    newSituation.condition = "local spells = {8690, 222695}; for k,v in pairs(spells) do if (UnitCastingInfo(\"player\") == GetSpellInfo(v)) then return true; end end return false;";
    newSituation.events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTED"};
    newSituation.cameraActions.zoomSetting = "in";
    newSituation.cameraActions.zoomValue = 4;
    newSituation.cameraActions.rotate = true;
    newSituation.cameraActions.rotateSpeed = .2;
    newSituation.cameraActions.rotateSetting = "continous";
    newSituation.cameraActions.transitionTime = 10;
    newSituation.cameraActions.timeIsMax = false;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.hideFrames["UIParent"] = true;
    situations["200"] = newSituation;

    newSituation = self:CreateSituation("Annoying Spells");
    newSituation.priority = 1000;
    newSituation.condition = "local spells = {46924, 51690, 188499, 210152}; for k,v in pairs(spells) do if (UnitBuff(\"player\", GetSpellInfo(v))) then return true; end end return false;";
    newSituation.events = {"UNIT_AURA"};
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    situations["201"] = newSituation;

    newSituation = self:CreateSituation("NPC Interaction");
    newSituation.priority = 20;
    newSituation.delay = .5;
    newSituation.condition = "return (UnitExists(\"npc\") and UnitIsUnit(\"npc\", \"target\")) and ((GarrisonCapacitiveDisplayFrame and GarrisonCapacitiveDisplayFrame:IsShown()) or (BankFrame and BankFrame:IsShown()) or (MerchantFrame and MerchantFrame:IsShown()) or (GossipFrame and GossipFrame:IsShown()) or (ClassTrainerFrame and ClassTrainerFrame:IsShown()) or (QuestFrame and QuestFrame:IsShown()))";
    newSituation.events = {"PLAYER_TARGET_CHANGED", "GOSSIP_SHOW", "GOSSIP_CLOSED", "QUEST_DETAIL", "QUEST_FINISHED", "QUEST_GREETING", "BANKFRAME_OPENED", "BANKFRAME_CLOSED", "MERCHANT_SHOW", "MERCHANT_CLOSED", "TRAINER_SHOW", "TRAINER_CLOSED", "SHIPMENT_CRAFTER_OPENED", "SHIPMENT_CRAFTER_CLOSED"};
    newSituation.cameraActions.zoomSetting = "fit";
    newSituation.cameraActions.zoomMin = 3;
    newSituation.cameraActions.zoomMax = 30;
    newSituation.cameraActions.zoomValue = 4;
    newSituation.cameraActions.zoomFitIncrements = .5;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    newSituation.cameraCVars["nameplateShowAll"] = 1;
    newSituation.cameraCVars["nameplateShowEnemies"] = 1;
    newSituation.cameraCVars["nameplateShowFriends"] = 1;
    newSituation.targetLock.enabled = true;
    newSituation.targetLock.onlyAttackable = false;
    newSituation.targetLock.nameplateVisible = false;
    situations["300"] = newSituation;

    newSituation = self:CreateSituation("Mailbox");
    newSituation.enabled = false;
    newSituation.priority = 20;
    newSituation.condition = "return (MailFrame and MailFrame:IsShown())";
    newSituation.events = {"MAIL_CLOSED", "MAIL_SHOW", "GOSSIP_CLOSED"};
    newSituation.cameraActions.zoomSetting = "in";
    newSituation.cameraActions.zoomValue = 4;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    situations["301"] = newSituation;

    return situations;
end

function DynamicCam:CreateSituation(name)
    local situation = {
        name = name,
        enabled = true,
        priority = 0,
        condition = "return false",
        delay = 0,
        executeOnInit = "",
        executeOnEnter = "",
        executeOnExit = "",
        cameraActions = {
            transitionTime = .75,
            timeIsMax = true,

            rotate = false,
            rotateSetting = "continous",
            rotateSpeed = .1,
            rotateDegrees = 0,

            zoomSetting = "off",
            zoomValue = 10,
            zoomMin = 5,
            zoomMax = 20,

            zoomFitContinous = false,
            zoomFitSpeedMultiplier = 2,
            zoomFitPosition = 84,
            zoomFitSensitivity = 5,
            zoomFitIncrements = .25,
        },
        view = {
            enabled = false,
            viewNumber = 5,
            restoreView = false,
            instant = false,
        },
        targetLock = {
            enabled = false,
            onlyAttackable = true,
            dead = false,
            nameplateVisible = true,
        },
        hideFrames = {},
        cameraCVars = {},
    };

    return situation;
end


-- TODO: organization
function DynamicCam:ShouldRestoreZoom(oldSituation, newSituation)
    -- don't restore if we don't have a saved zoom value
    if (not restoration[oldSituation].zoom) then
        return false;
    end

    -- don't restore view if we're still zooming
    if (Camera:IsZooming()) then
        return false;
    end

    -- restore if we're just exiting a situation, but not going into a new one
    if (not newSituation) then
        return true;
    end

    -- only restore zoom if returning to the same situation
    if (restoration[oldSituation].zoomSituation ~= newSituation) then
        return false;
    end

    -- don't restore zoom if we're about to go into a view
    if (newSituation.view.enabled) then
        return false;
    end

    -- TODO: check up on
    -- restore zoom based on newSituation zoomSetting
    if (newSituation.cameraActions.zoomSetting == "off") then
        -- restore zoom if the new situation doesn't zoom at all
        return true;
    elseif (newSituation.cameraActions.zoomSetting == "set") then
        -- don't restore zoom if the zoom is going to be setting the zoom anyways
        return false;
    elseif (newSituation.cameraActions.zoomSetting == "fit") then
        -- don't restore zoom to a zoom fit
        return false;
    elseif (newSituation.cameraActions.zoomSetting == "range") then
        --only restore zoom if zoom will be in the range
        if ((newSituation.cameraActions.zoomMin <= restoration[oldSituation].zoom) and
            (newSituation.cameraActions.zoomMax >= restoration[oldSituation].zoom)) then
            return true;
        end
    elseif (newSituation.cameraActions.zoomSetting == "in") then
        -- only restore if restoration zoom will still be acceptable
        if (newSituation.cameraActions.zoomValue >= restoration[oldSituation].zoom) then
            return true;
        end
    elseif (newSituation.cameraActions.zoomSetting == "out") then
        -- restore zoom if newSituation is zooming out and we would already be zooming out farther
        if (newSituation.cameraActions.zoomValue <= restoration[oldSituation].zoom) then
            return true;
        end
    end

    -- if nothing else, don't restore
    return false;
end


------------
-- EVENTS --
------------
function DynamicCam:RefreshConfig()
    local restartTimer = false;

    -- shutdown the addon if it's enabled
    if (self.db.profile.enabled and started) then
        self:Shutdown();
    end

    -- situation is active, but db killed it
    -- TODO: still restore from restoration, at least, what we can
    if (self.currentSituation) then
        self.currentSituation = nil;
    end

    -- load default situations
    if (not next(self.db.profile.situations)) then
        self.db.profile.situations = self:GetDefaultSituations();
    end

    -- make sure that options panel selects a situation
    if (Options) then
        Options:SelectSituation();
    end

    -- start the addon back up
    if (self.db.profile.enabled and not started) then
        self:Startup();
    end
end

function DynamicCam:RegisterEvents()
    for name, situation in pairs(self.db.profile.situations) do
        if (situation.events) then
            for i, event in pairs(situation.events) do
                if (not events[event]) then
                    events[event] = true;
                    self:RegisterEvent(event, "EvaluateSituations");
                    -- self:DebugPrint("Registered for event:", event);
                end
            end
        end
    end
end

-----------------
-- TARGET LOCK --
-----------------
function DynamicCam:EvaluateTargetLock()
    if (self.currentSituation) then
        if (self.currentSituation.targetLock.enabled) and
            (not self.currentSituation.targetLock.onlyAttackable or UnitCanAttack("player", "target")) and
            (self.currentSituation.targetLock.dead or (not UnitIsDead("target"))) and
            (not self.currentSituation.targetLock.nameplateVisible or (C_NamePlate.GetNamePlateForUnit("target") ~= nil))
        then
            if (GetCVar("cameralockedtargetfocusing") ~= "1") then
                SetCVar ("cameralockedtargetfocusing", 1)
            end
        else
            if (GetCVar("cameralockedtargetfocusing") ~= "0") then
                 SetCVar ("cameralockedtargetfocusing", 0)
            end
        end
    end
end


-------------------
-- CHAT COMMANDS --
-------------------
function DynamicCam:OpenMenu(input)
    if (not Options or not Camera) then
        Camera = self.Camera;
        Options = self.Options;
    end

    Options:SelectSituation();

    -- just open to the frame, double call because blizz bug
    InterfaceOptionsFrame_OpenToCategory("DynamicCam");
    InterfaceOptionsFrame_OpenToCategory("DynamicCam");
end

function DynamicCam:SaveViewCC(input)
    if (tonumber(input) and tonumber(input) <= 5 and tonumber(input) > 1) then
        SaveView(tonumber(input));
    end
end

function DynamicCam:ZoomConfidenceCC(input)
    Camera:ResetConfidence(15);
end

function DynamicCam:ZoomInfoCC(input)
    Camera:PrintCameraVars();
end


-----------
-- CVARS --
-----------
function DynamicCam:ResetCVars()
    SetCVar("cameraovershoulder", GetCVarDefault("cameraovershoulder"));
    SetCVar("cameralockedtargetfocusing", GetCVarDefault("cameralockedtargetfocusing"));
    SetCVar("cameradistancemax", GetCVarDefault("cameradistancemax"));
    SetCVar("cameradistancemovespeed", GetCVarDefault("cameradistancemovespeed"));
    SetCVar("cameradynamicpitch", GetCVarDefault("cameradynamicpitch"));
    SetCVar("cameradynamicpitchbasefovpad", GetCVarDefault("cameradynamicpitchbasefovpad"));
    SetCVar("cameradynamicpitchbasefovpadflying", GetCVarDefault("cameradynamicpitchbasefovpadflying"));
    SetCVar("cameradynamicpitchsmartpivotcutoffdist", GetCVarDefault("cameradynamicpitchsmartpivotcutoffdist"));
    SetCVar("cameraheadmovementstrength", GetCVarDefault("cameraheadmovementstrength"));
    SetCVar("cameraheadmovementrange", GetCVarDefault("cameraheadmovementrange"));
    SetCVar("cameraheadmovementsmoothrate", GetCVarDefault("cameraheadmovementsmoothrate"));
    SetCVar("cameraheadmovementwhilestanding", GetCVarDefault("cameraheadmovementwhilestanding"));

    ResetView(1);
    ResetView(2);
    ResetView(3);
    ResetView(4);
    ResetView(5);

    SetCVar("cameradistancemaxfactor", 1);
end
