---------------
-- LIBRARIES --
---------------
local AceAddon = LibStub("AceAddon-3.0");


---------------
-- CONSTANTS --
---------------
local DATABASE_VERSION = 1;
local DEFAULT_VERSION = 1;
local ACTION_CAM_CVARS = {
    ["cameraovershoulder"] = true,
    ["cameralockedtargetfocusing"] = true,
    ["cameraheadmovementstrength"] = true,
    ["cameraheadmovementrange"] = true,
    ["cameraheadmovementsmoothrate"] = true,
    ["cameraheadmovementwhilestanding"] = true,
    ["cameradynamicpitch"] = true,
    ["cameradynamicpitchbasefovpad"] = true,
    ["cameradynamicpitchbasefovpadflying"] = true,
    ["cameradynamicpitchsmartpivotcutoffdist"] = true,
};


-------------
-- GLOBALS --
-------------
DynamicCam = AceAddon:NewAddon("DynamicCam", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");
DynamicCam.currentSituationID = nil;


------------
-- LOCALS --
------------
local _;
local started;
local Camera;
local Options;
local functionCache = {};
local situationEnvironments = {}
local conditionExecutionCache = {};
local evaluateTimer;
local restoration = {};
local delayTime;
local events = {};

local function DC_RunScript(script, situationID)
    if (not script or script == "") then
        return;
    end

    -- make sure that we're not creating tables willy nilly
    if (not functionCache[script]) then
        functionCache[script] = assert(loadstring(script));

        -- if env, set the environment to that
        if (situationID) then
            if (not situationEnvironments[situationID]) then
                situationEnvironments[situationID] = setmetatable({}, { __index =
                    function(t, k)
                        if (k == "_G") then
                            return t;
                        elseif (k == "this") then
                            return situationEnvironments[situationID].this;
                        else
                            return _G[k];
                        end
                    end
                });
                situationEnvironments[situationID].this = {};
            end

            setfenv(functionCache[script], situationEnvironments[situationID]);
        end
    end

    -- return the result
    return functionCache[script]();
end

local function DC_SetCVar(cvar, setting)
    -- if actioncam flag is off and if cvar is an ActionCam setting, don't set it
    if (not DynamicCam.db.profile.actionCam and ACTION_CAM_CVARS[cvar]) then
        return;
    end

    DynamicCam:DebugPrint(cvar, setting);

    SetCVar(cvar, setting);
end


--------
-- DB --
--------
local defaults = {
    global = {
        dbVersion = 0,
    };
    profile = {
        enabled = true,
        advanced = false,
        debugMode = false,
        actionCam = false,
        defaultCvars = {
            ["cameraDistanceMaxFactor"] = 2.6,
            ["cameraDistanceMoveSpeed"] = 8.33,

            ["cameraovershoulder"] = 0,
            ["cameralockedtargetfocusing"] = 0,

            ["cameraheadmovementstrength"] = 0,
            ["cameraheadmovementrange"] = 6,
            ["cameraheadmovementsmoothrate"] = 40,
            ["cameraheadmovementwhilestanding"] = 1,

            ["cameradynamicpitch"] = 0,
            ["cameradynamicpitchbasefovpad"] = .4,
            ["cameradynamicpitchbasefovpadflying"] = .75,
            ["cameradynamicpitchsmartpivotcutoffdist"] = 10,
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
                    rotateBack = false,

                    zoomSetting = "off",
                    zoomValue = 10,
                    zoomMin = 5,
                    zoomMax = 15,

                    zoomFitContinous = false,
                    zoomFitSpeedMultiplier = 2,
                    zoomFitPosition = 84,
                    zoomFitSensitivity = 5,
                    zoomFitIncrements = .25,
                    zoomFitUseCurAsMin = false,
                    zoomFitToggleNameplate = false,
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
                extras = {
                    hideUI = false,
                },
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
    self:InitDatabase();
    self:RefreshConfig();

    -- setup chat commands
    self:RegisterChatCommand("dynamiccam", "OpenMenu");
    self:RegisterChatCommand("dc", "OpenMenu");

    self:RegisterChatCommand("saveview", "SaveViewCC");
    self:RegisterChatCommand("sv", "SaveViewCC");

    self:RegisterChatCommand("zoominfo", "ZoomInfoCC");
    self:RegisterChatCommand("zi", "ZoomInfoCC");

    self:RegisterChatCommand("dcdiscord", "PopupDiscordLink");
    self:RegisterChatCommand("zoom", "ZoomSlash");

    -- show defaults are out of date dialog
    if (not self.db.profile.defaultVersion or self.db.profile.defaultVersion < DEFAULT_VERSION) then
        StaticPopupDialogs["DYNAMICCAM_NEW_DEFAULTS"] = {
            text = "DynamicCam has a new set of default situations. Would you like to reset your profile?",
            button1 = "Upgrade Me!",
            button2 = "No, thanks",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            OnAccept = function()
                DynamicCam.db:ResetProfile();
            end,
            OnCancel = function(_, reason)
                DynamicCam.db.profile.defaultVersion = DEFAULT_VERSION;
            end,
        }

        StaticPopup_Show("DYNAMICCAM_NEW_DEFAULTS");
    end

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

    -- register for dynamiccam messages
    self:RegisterMessage("DC_SITUATION_ENABLED");
    self:RegisterMessage("DC_SITUATION_DISABLED");
    self:RegisterMessage("DC_SITUATION_UPDATED");
    self:RegisterMessage("DC_BASE_CAMERA_UPDATED");
    
    -- initial evaluate needs to be delayed because the camera doesn't like changing cvars on startup
    self:ScheduleTimer("ApplyDefaultCameraSettings", 2.5);
    evaluateTimer = self:ScheduleTimer("EvaluateSituations", 3);
    self:ScheduleTimer("RegisterEvents", 3);
    
    started = true;
end

function DynamicCam:Shutdown()
    -- kill the evaluate timer if it's running
    if (evaluateTimer) then
        self:CancelTimer(evaluateTimer);
        evaluateTimer = nil;
    end

    -- exit the current situation if in one
    if (self.currentSituationID) then
        self:ExitSituation(self.currentSituationID);
    end

    -- reset zoom
    Camera:ResetZoomVars();

    events = {};
    self:UnregisterAllEvents();
    self:UnregisterAllMessages();

    -- apply default settings
    self:ApplyDefaultCameraSettings();

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

function DynamicCam:EvaluateSituations()
    -- if we currently have timer running, kill it
    if (evaluateTimer) then
        self:CancelTimer(evaluateTimer);
        evaluateTimer = nil;
    end

    if (self.db.profile.enabled) then
        local highestPriority = -100;
        local topSituation;

        -- go through all situations pick the best one
        for id, situation in pairs(self.db.profile.situations) do
            if (situation.enabled) then
                -- evaluate the condition, if it checks out and the priority is larger then any other, set it
                local lastEvaluate = conditionExecutionCache[id];
                local thisEvaluate = DC_RunScript(situation.condition, id);
                conditionExecutionCache[id] = thisEvaluate;

                if (thisEvaluate) then
                    -- the condition is true
                    if (not lastEvaluate) then
                        -- last evaluate wasn't true, so this we "flipped"
                        self:SendMessage("DC_SITUATION_ACTIVE", id);
                    end

                    -- check to see if we've already found something with higher priority
                    if (situation.priority > highestPriority) then
                        highestPriority = situation.priority;
                        topSituation = id;
                    end
                else
                    -- the condition is false
                    if (lastEvaluate) then
                        -- last evaluate was true, so we "flipped"
                        self:SendMessage("DC_SITUATION_INACTIVE", id);
                    end
                end
            end
        end

        if (topSituation) then
            if (self.currentSituationID) then
                if (topSituation ~= self.currentSituationID) then
                    -- check if current situation has a delay and if it does, if it's 'cooling down'
                    local delay = self.db.profile.situations[self.currentSituationID].delay;
                    if (delay > 0) then
                        if (not delayTime) then
                            -- not yet cooling down, make sure to guarentee an evaluate
                            delayTime = GetTime() + delay;
                            delayTimer = self:ScheduleTimer("EvaluateSituations", delay, "DELAY_TIMER");
                        elseif (delayTime > GetTime()) then
                            -- still cooling down, don't swap
                        else
                            -- we cooled down and still want to change, so change
                            delayTime = nil;
                            self:SetSituation(topSituation);
                        end
                    else
                        -- there isn't a delay, just change over to the new situation
                        self:SetSituation(topSituation);
                    end
                else
                    -- topSituation is currentSituationID, clear the delay
                    delayTime = nil;
                end
            else
                -- no currentSituationID
                self:SetSituation(topSituation);
            end

            -- do target lock evaluation anyways
            self:EvaluateTargetLock();
        else
            --none of the situations are active, leave the current situation
            if (self.currentSituationID) then
                self:ExitSituation(self.currentSituationID);
            end
        end
    end
end

function DynamicCam:SetSituation(situationID)
    local oldSituationID = self.currentSituationID;
    local restoringZoom;

    -- if currently in a situation, leave it
    if (self.currentSituationID) then
        restoringZoom = self:ExitSituation(self.currentSituationID, situationID);
    end

    -- go into the new situation
    self:EnterSituation(situationID, oldSituationID, restoringZoom);
end

function DynamicCam:EnterSituation(situationID, oldSituationID, skipZoom)
    local situation = self.db.profile.situations[situationID];
    local oldSituation = self.db.profile.situations[oldSituationID];
    local this = situationEnvironments[situationID].this;

    self:DebugPrint("Entering situation", situation.name);

    -- load and run advanced script onEnter
    DC_RunScript(situation.executeOnEnter, situationID);

    -- set currentSituationID
    self.currentSituationID = situationID;

    -- set view settings
    if (situation.view.enabled) then
        if (situation.view.restoreView) then
            SaveView(1);
        end

        Camera:GotoView(situation.view.viewNumber, situation.cameraActions.transitionTime, situation.view.instant);
    end

    -- set all cvars
    restoration[situationID] = {};
    for cvar, value in pairs(situation.cameraCVars) do
        DC_SetCVar(cvar, value);
    end

    local a = situation.cameraActions;
    local transitionTime = a.transitionTime;

    if (this.transitionTime) then
        transitionTime = this.transitionTime;
    end

    -- ZOOM --
    if (not skipZoom) then
        if (Camera:IsZooming()) then
            Camera:StopZooming();
        end

        -- save old zoom level
        restoration[situationID].zoom = GetCameraZoom();
        restoration[situationID].zoomSituation = oldSituationID;

        -- set zoom level
        local adjustedZoom;
        
        if (a.zoomSetting == "in") then
            adjustedZoom = Camera:ZoomInTo(a.zoomValue, transitionTime, a.timeIsMax);
        elseif (a.zoomSetting == "out") then
            adjustedZoom = Camera:ZoomOutTo(a.zoomValue, transitionTime, a.timeIsMax);
        elseif (a.zoomSetting == "set") then
            adjustedZoom = Camera:SetZoom(a.zoomValue, transitionTime, a.timeIsMax);
        elseif (a.zoomSetting == "range") then
            adjustedZoom = Camera:ZoomToRange(a.zoomMin, a.zoomMax, transitionTime, a.timeIsMax);
        elseif (a.zoomSetting == "fit") then
            local min = a.zoomMin;
            if (a.zoomFitUseCurAsMin) then
                min = GetCameraZoom();
                min = math.min(min, a.zoomMax);
            end
            adjustedZoom = Camera:FitNameplate(min, a.zoomMax, a.zoomFitIncrements, a.zoomFitPosition, a.zoomFitSensitivity, a.zoomFitSpeedMultiplier, a.zoomFitContinous, a.zoomFitToggleNameplate);
        end

        -- if we didn't adjust the zoom, then reset oldZoom
        if (not adjustedZoom) then
            restoration[situationID].zoom = nil;
            restoration[situationID].zoomSituation = nil;
        end
    else
        self:DebugPrint("Restoring zoom level, so skipping zoom action")
    end

    -- ROTATE --
    if (a.rotate) then
        if (a.rotateSetting == "continous") then
            Camera:StartContinousRotate(a.rotateSpeed);
        elseif (a.rotateSetting == "degrees") then
            Camera:RotateDegrees(a.rotateDegrees, transitionTime);
        end
    end

    -- EXTRAS --
    if (situation.extras.hideUI) then
        if (not InCombatLockdown()) then
            -- hide UI
            UIParent:Hide();
        else
            self:Print("Couldn't hide UI because of UI Combat Lockdown!'")
        end
    end

    self:SendMessage("DC_SITUATION_ENTERED");
end

function DynamicCam:ExitSituation(situationID, newSituationID)
    local restoringZoom;
    local situation = self.db.profile.situations[situationID];
    local newSituation = self.db.profile.situations[newSituationID];
    self.currentSituationID = nil;

    self:DebugPrint("Exiting situation "..situation.name);

    -- load and run advanced script onExit
    DC_RunScript(situation.executeOnExit, id);

    -- restore cvars to their default values
    self:ApplyDefaultCameraSettings();

    -- restore view that is enabled
    if (situation.view.enabled and situation.view.restoreView) then
        Camera:GotoView(1, .75, situation.view.instant);
    end

    local a = situation.cameraActions;

    -- stop rotating if we started to
    if (a.rotate) then
        if (a.rotateSetting == "continous") then
            local degrees = Camera:StopRotating();
            self:DebugPrint("Ended rotate, degrees rotated:", degrees);
            if (a.rotateBack) then
                Camera:RotateDegrees(-degrees, .5);
            end
        elseif (a.rotateSetting == "degrees") then
            if (Camera:IsRotating()) then
                -- interrupted rotation
                local degrees = (Camera:StopRotating())%360;
                if (a.rotateBack) then
                    Camera:RotateDegrees(-degrees, .5); -- constant time here
                end
            else
                if (a.rotateBack) then
                    Camera:RotateDegrees(-a.rotateDegrees, .5); -- constant time here
                end
            end
        end
    end

    -- stop zooming if we're still zooming
    if (a.zoomSetting ~= "off" and Camera:IsZooming()) then
        self:DebugPrint("Still zooming for situation, stop zooming.")
        Camera:StopZooming();
    end

    -- restore zoom level if we saved one
    if (self:ShouldRestoreZoom(situationID, newSituationID)) then
        self:DebugPrint("Restoring zoom level: ", restoration[situationID].zoom);
        restoringZoom = true;
        Camera:SetZoom(restoration[situationID].zoom, .75, true); -- constant time here
    else
        self:DebugPrint("Not restoring zoom level");
    end

    -- unhide UI
    if (situation.extras.hideUI) then
        if (not InCombatLockdown()) then
            UIParent:Show();
        else
            self:Print("Couldn't show UI because of UI Combat Lockdown!'")
        end
    end

    wipe(restoration[situationID]);
    
    self:SendMessage("DC_SITUATION_EXITED");

    return restoringZoom;
end

function DynamicCam:GetSituationList()
    local situationList = {};

    for id, situation in pairs(self.db.profile.situations) do
        local prefix = "";
        local suffix = "";

        if (self.currentSituationID == id) then
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
    newSituation.cameraActions.zoomMin = 10;
    newSituation.cameraActions.zoomMax = 15;
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

    newSituation = self:CreateSituation("World");
    newSituation.priority = 0;
    newSituation.condition = "return not IsResting() and not IsInInstance();";
    newSituation.events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_NEW_AREA"};
    newSituation.cameraActions.zoomSetting = "range";
    newSituation.cameraActions.zoomMin = 10;
    newSituation.cameraActions.zoomMax = 15;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    situations["004"] = newSituation;

    newSituation = self:CreateSituation("World (Indoors)");
    newSituation.priority = 10;
    newSituation.condition = "return not IsResting() and not IsInInstance() and IsIndoors();";
    newSituation.events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"};
    newSituation.cameraActions.zoomSetting = "in";
    newSituation.cameraActions.zoomValue = 8;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    situations["005"] = newSituation;

    newSituation = self:CreateSituation("World (Combat)");
    newSituation.priority = 50;
    newSituation.condition = "return not IsInInstance() and UnitAffectingCombat(\"player\");";
    newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"};
    newSituation.cameraActions.zoomSetting = "fit";
    --newSituation.cameraActions.zoomFitContinous = true;
    newSituation.cameraActions.zoomFitUseCurAsMin = true;
    newSituation.cameraActions.zoomMin = 5;
    newSituation.cameraActions.zoomMax = 28.5;
    newSituation.cameraCVars["cameraovershoulder"] = 1.5;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    newSituation.targetLock.enabled = true;
    newSituation.targetLock.nameplateVisible = true;
    situations["006"] = newSituation;

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



    newSituation = self:CreateSituation("Arena");
    newSituation.enabled = false;
    newSituation.priority = 3;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"arena\");";
    newSituation.events = {"ZONE_CHANGED_NEW_AREA"};
    situations["050"] = newSituation;

    newSituation = self:CreateSituation("Arena (Combat)");
    newSituation.enabled = false;
    newSituation.priority = 203;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"arena\") and UnitAffectingCombat(\"player\");";
    newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"};
    situations["051"] = newSituation;


    newSituation = self:CreateSituation("Battleground");
    newSituation.enabled = false;
    newSituation.priority = 3;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"pvp\");";
    newSituation.events = {"ZONE_CHANGED_NEW_AREA"};
    situations["060"] = newSituation;

    newSituation = self:CreateSituation("Battleground (Combat)");
    newSituation.enabled = false;
    newSituation.priority = 203;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"pvp\") and UnitAffectingCombat(\"player\");";
    newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"};
    situations["061"] = newSituation;


    newSituation = self:CreateSituation("Mounted");
    newSituation.priority = 100;
    newSituation.condition = "return IsMounted();";
    newSituation.events = {"SPELL_UPDATE_USABLE", "UNIT_AURA"};
    newSituation.cameraActions.zoomSetting = "out";
    newSituation.cameraActions.zoomValue = 28.5;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    situations["100"] = newSituation;

    newSituation = self:CreateSituation("Taxi");
    newSituation.priority = 1000;
    newSituation.condition = "return UnitOnTaxi(\"player\");";
    newSituation.events = {"PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED"};
    newSituation.cameraActions.zoomSetting = "set";
    newSituation.cameraActions.zoomValue = 15;
    newSituation.cameraCVars["cameraovershoulder"] = -1;
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.extras.hideUI = true;
    situations["101"] = newSituation;

    newSituation = self:CreateSituation("Vehicle");
    newSituation.priority = 1000;
    newSituation.condition = "return UnitUsingVehicle(\"player\");";
    newSituation.events = {"UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE"};
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    situations["102"] = newSituation;

    newSituation = self:CreateSituation("Hearth/Teleport");
    newSituation.priority = 20;
    newSituation.executeOnInit = "this.spells = {136508, 189838, 54406, 94719, 556, 168487, 168499, 171253, 50977, 8690, 222695, 171253, 224869, 53140, 3565, 32271, 193759, 3562, 3567, 33690, 35715, 32272, 49358, 176248, 3561, 49359, 3566, 88342, 88344, 3563, 132627, 132621, 176242, 192085, 192084, 216016};";
    newSituation.condition = [[for k,v in pairs(this.spells) do 
    if (UnitCastingInfo("player") == GetSpellInfo(v)) then 
        return true;
    end
end
return false;]];
    newSituation.executeOnEnter = "local _, _, _, _, startTime, endTime = UnitCastingInfo(\"player\");\nthis.transitionTime = ((endTime - startTime)/1000) - .25;";
    newSituation.events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTED"};
    newSituation.cameraActions.zoomSetting = "in";
    newSituation.cameraActions.zoomValue = 4;
    newSituation.cameraActions.rotate = true;
    newSituation.cameraActions.rotateDegrees = 360;
    newSituation.cameraActions.rotateSetting = "degrees";
    newSituation.cameraActions.transitionTime = 10;
    newSituation.cameraActions.timeIsMax = false;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.extras.hideUI = true;
    situations["200"] = newSituation;

    newSituation = self:CreateSituation("Annoying Spells");
    newSituation.priority = 1000;
    newSituation.executeOnInit = "this.buffs = {46924, 51690, 188499, 210152};";
    newSituation.condition = [[for k,v in pairs(this.buffs) do 
    if (UnitBuff("player", GetSpellInfo(v))) then
        return true;
    end
end
return false;]];
    newSituation.events = {"UNIT_AURA"};
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    situations["201"] = newSituation;

    newSituation = self:CreateSituation("NPC Interaction");
    newSituation.enabled = false;
    newSituation.priority = 20;
    newSituation.delay = .5;
    newSituation.executeOnInit = "this.frames = {\"GarrisonCapacitiveDisplayFrame\", \"BankFrame\", \"MerchantFrame\", \"GossipFrame\", \"ClassTrainerFrame\", \"QuestFrame\",}";
    newSituation.condition = [[local shown = false;
for k,v in pairs(this.frames) do
    if (_G[v] and _G[v]:IsShown()) then
        shown = true;
    end
end
return UnitExists("npc") and UnitIsUnit("npc", "target") and shown;]];
    newSituation.events = {"PLAYER_TARGET_CHANGED", "GOSSIP_SHOW", "GOSSIP_CLOSED", "QUEST_COMPLETE", "QUEST_DETAIL", "QUEST_FINISHED", "QUEST_GREETING", "BANKFRAME_OPENED", "BANKFRAME_CLOSED", "MERCHANT_SHOW", "MERCHANT_CLOSED", "TRAINER_SHOW", "TRAINER_CLOSED", "SHIPMENT_CRAFTER_OPENED", "SHIPMENT_CRAFTER_CLOSED"};
    newSituation.cameraActions.zoomSetting = "fit";
    newSituation.cameraActions.zoomMin = 3;
    newSituation.cameraActions.zoomMax = 28.5;
    newSituation.cameraActions.zoomValue = 4;
    newSituation.cameraActions.zoomFitIncrements = .5;
    newSituation.cameraActions.zoomFitPosition = 90;
    newSituation.cameraActions.zoomFitToggleNameplate = true;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
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

    newSituation = self:CreateSituation("Fishing");
    newSituation.priority = 20;
    newSituation.condition = "return (UnitChannelInfo(\"player\") == GetSpellInfo(7620))";
    newSituation.events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTED"};
    newSituation.delay = 2;
    newSituation.cameraActions.zoomSetting = "set";
    newSituation.cameraActions.zoomValue = 10;
    situations["302"] = newSituation;

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
            zoomFitUseCurAsMin = false,
            zoomFitToggleNameplate = true,
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
        extras = {
            hideUI = false,

            nameplates = false,
            friendlyNameplates = true,
            enemyNameplates = true,
        },
        cameraCVars = {},
    };

    return situation;
end

function DynamicCam:UpdateSituation(situationID)
    local situation = self.db.profile.situations[situationID];
    if (situation and (situationID == self.currentSituationID)) then
        -- apply cvars
        for cvar, value in pairs(situation.cameraCVars) do
            DC_SetCVar(cvar, value);
        end
    end
    DC_RunScript(situation.executeOnInit, situationID);
    self:EvaluateSituations();
end


-- TODO: organization
function DynamicCam:ApplyDefaultCameraSettings()
    local curSituation = self.db.profile.situations[self.currentSituationID];

    -- apply default settings if the current situation isn't overriding them
    for cvar, value in pairs(self.db.profile.defaultCvars) do
        if (not curSituation or not curSituation.cameraCVars[cvar]) then
            DC_SetCVar(cvar, value);
        end
    end
end

function DynamicCam:ShouldRestoreZoom(oldSituationID, newSituationID)
    local newSituation = self.db.profile.situations[newSituationID];

    -- don't restore if we don't have a saved zoom value
    if (not restoration[oldSituationID].zoom) then
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
    if (restoration[oldSituationID].zoomSituation ~= newSituationID) then
        return false;
    end

    -- don't restore zoom if we're about to go into a view
    if (newSituation.view.enabled) then
        return false;
    end

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
        if ((newSituation.cameraActions.zoomMin <= restoration[oldSituationID].zoom + .5) and
            (newSituation.cameraActions.zoomMax >= restoration[oldSituationID].zoom - .5)) then
            return true;
        end
    elseif (newSituation.cameraActions.zoomSetting == "in") then
        -- only restore if restoration zoom will still be acceptable
        if (newSituation.cameraActions.zoomValue >= restoration[oldSituationID].zoom - .5) then
            return true;
        end
    elseif (newSituation.cameraActions.zoomSetting == "out") then
        -- restore zoom if newSituation is zooming out and we would already be zooming out farther
        if (newSituation.cameraActions.zoomValue <= restoration[oldSituationID].zoom + .5) then
            return true;
        end
    end

    -- if nothing else, don't restore
    return false;
end


------------
-- EVENTS --
------------
local lastEvaluate;
local TIME_BEFORE_NEXT_EVALUATE = .1;
local EVENT_DOUBLE_TIME = .2;

function DynamicCam:EventHandler(event, possibleUnit, ...)
    -- we don't want to evaluate too often, some of the events can be *very* spammy
    if (not lastEvaluate or (lastEvaluate and ((lastEvaluate + TIME_BEFORE_NEXT_EVALUATE) < GetTime()))) then
        lastEvaluate = GetTime();

        -- call the evaluate
        self:EvaluateSituations();

        -- double the event, since a lot of events happen before the condition turns out to be true
        evaluateTimer = self:ScheduleTimer("EvaluateSituations", EVENT_DOUBLE_TIME);
    else
        -- we're delaying the call of evaluate situations until next evaluate
        if (not evaluateTimer) then
            evaluateTimer = self:ScheduleTimer("EvaluateSituations", TIME_BEFORE_NEXT_EVALUATE);
        end
    end
end

function DynamicCam:RegisterEvents()
    events["NAME_PLATE_UNIT_ADDED"] = true;
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED", "EventHandler");

    events["NAME_PLATE_UNIT_ADDED"] = true;
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", "EventHandler");

    events["PLAYER_TARGET_CHANGED"] = true;
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "EventHandler");

    for name, situation in pairs(self.db.profile.situations) do
        if (situation.events) then
            for i, event in pairs(situation.events) do
                if (not events[event]) then
                    events[event] = true;
                    self:RegisterEvent(event, "EventHandler");
                    -- self:DebugPrint("Registered for event:", event);
                end
            end
        end
    end
end

function DynamicCam:DC_SITUATION_ENABLED(message, situationID)
    self:EvaluateSituations();
end

function DynamicCam:DC_SITUATION_DISABLED(message, situationID)
    self:EvaluateSituations();
end

function DynamicCam:DC_SITUATION_UPDATED(message, situationID)
    self:UpdateSituation(situationID);
    self:ApplyDefaultCameraSettings();
    self:EvaluateSituations();
end

function DynamicCam:DC_BASE_CAMERA_UPDATED(message)
    self:ApplyDefaultCameraSettings();
end


-----------------
-- TARGET LOCK --
-----------------
function DynamicCam:EvaluateTargetLock()
    if (self.currentSituationID) then
        local targetLock = self.db.profile.situations[self.currentSituationID].targetLock;
        if (targetLock.enabled) and
            (not targetLock.onlyAttackable or UnitCanAttack("player", "target")) and
            (targetLock.dead or (not UnitIsDead("target"))) and
            (not targetLock.nameplateVisible or (C_NamePlate.GetNamePlateForUnit("target") ~= nil))
        then
            if (GetCVar("cameralockedtargetfocusing") ~= "1") then
                DC_SetCVar ("cameralockedtargetfocusing", 1)
            end
        else
            if (GetCVar("cameralockedtargetfocusing") ~= "0") then
                 DC_SetCVar ("cameralockedtargetfocusing", 0)
            end
        end
    end
end


--------------
-- DATABASE --
--------------

function DynamicCam:InitDatabase()
    self.db = LibStub("AceDB-3.0"):New("DynamicCamDB", defaults, true);
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig");
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig");
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig");
    self.db.RegisterCallback(self, "OnDatabaseShutdown", "Shutdown");

    if (self.db.global.dbVersion == 0) then
        self:DebugPrint("Upgrading database to level 1");
        self.db.global.dbVersion = 1;
    end

    if (self.db.global.dbVersion == 1) then
        -- at version 1
    end

    self:DebugPrint("Database at level", self.db.global.dbVersion);
end

function DynamicCam:RefreshConfig()
    local restartTimer = false;
    
    -- shutdown the addon if it's enabled
    if (self.db.profile.enabled and started) then
        self:Shutdown();
    end

    -- situation is active, but db killed it
    -- TODO: still restore from restoration, at least, what we can
    if (self.currentSituationID) then
        self.currentSituationID = nil;
    end

    -- clear the options panel so that it reselects
    if (Options) then
        Options:ClearSelection();
    end

    -- load default situations
    local id, situation = next(self.db.profile.situations);
    if (not situation or situation.name == "") then
        self.db.profile.situations = self:GetDefaultSituations();
        self.db.profile.defaultVersion = DEFAULT_VERSION;
    end

    -- make sure that options panel selects a situation
    if (Options) then
        Options:SelectSituation();
    end

    -- start the addon back up
    if (self.db.profile.enabled and not started) then
        self:Startup();
    end

    -- run all situations's advanced init script
    for id, situation in pairs(self.db.profile.situations) do
        DC_RunScript(situation.executeOnInit, id);
    end
end



-------------------
-- CHAT COMMANDS --
-------------------
StaticPopupDialogs["DYNAMICCAM_DISCORD"] = {
    text = "DynamicCam Discord Link:",
    button1 = "Got it!",
    timeout = 0,
    hasEditBox = true,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    OnShow = function (self, data)
        self.editBox:SetText("https://discordapp.com/invite/0kIVitHDdHYYitiO")
        self.editBox:HighlightText();
    end,
}

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

function DynamicCam:ZoomInfoCC(input)
    Camera:PrintCameraVars();
end

function DynamicCam:ZoomSlash(input)
    if (tonumber(input) and tonumber(input) <= 39 and tonumber(input) >= 0) then
        Camera:SetZoom(tonumber(input), .5, true);
    end
end

function DynamicCam:PopupDiscordLink()
    StaticPopup_Show("DYNAMICCAM_DISCORD");
end


-----------
-- CVARS --
-----------
function DynamicCam:ResetCVars()
    for cvar, value in pairs(self.db.profile.defaultCvars) do
        DC_SetCVar(cvar, GetCVarDefault(cvar));
    end

    ResetView(1);
    ResetView(2);
    ResetView(3);
    ResetView(4);
    ResetView(5);
end
