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
local Camera;
local Options;
local conditionFunctionCache = {};
local conditionExecutionCache = {};
local evaluateTimer;
local restoration = {};
local delayTime;


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
                    zoomFitNameplate = false,
                    zoomFitContinous = false,
                    zoomFitSave = false,
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
    self.db.RegisterCallback(self, "OnDatabaseShutdown", "OnShutdown");
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
    Camera = self.Camera;
    Options = self.Options;

    -- apply default settings
    for cvar, value in pairs(self.db.profile.defaultCvars) do
        SetCVar(cvar, value);
    end

    -- setup timer for evaluating situations, TODO: advanced settings
    evaluateTimer = self:ScheduleRepeatingTimer("EvaluateSituations", .05);
end

function DynamicCam:OnDisable()
    self.db.profile.enabled = false;
    self:OnShutdown();
end

function DynamicCam:OnShutdown()
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

    -- apply default settings
    for cvar, value in pairs(self.db.profile.defaultCvars) do
        SetCVar(cvar, value);
    end
end

function DynamicCam:DebugPrint(...)
    if (self.db.profile.debugMode) then
        self:Print(...);
    end
end


----------------
-- SITUATIONS --
----------------
function DynamicCam:EvaluateSituations()
    local highestPriority = -100;
    local topSituation = nil;
    local topSituationName = nil;

    -- go through all situations pick the best one
    for name, situation in pairs(self.db.profile.situations) do
        if (situation.enabled) then
            if (not conditionFunctionCache[situation.condition]) then
                conditionFunctionCache[situation.condition] = assert(loadstring(situation.condition));
            end

            -- evaluate the condition, if it checks out and the priority is larger then any other, set it
            conditionExecutionCache[situation] = conditionFunctionCache[situation.condition]();
            if (conditionExecutionCache[situation] and (situation.priority > highestPriority)) then
                highestPriority = situation.priority;
                topSituation = situation;
                topSituationName = name;
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
                        self:DebugPrint("Delaying situation swap by", self.currentSituation.delay);
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
    self:DebugPrint("Entering situation "..situation.name);

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
    if (situation.cameraActions.zoomSetting == "in") then
        adjustedZoom = Camera:ZoomInTo(situation.cameraActions.zoomValue, situation.cameraActions.transitionTime, situation.cameraActions.timeIsMax);
    elseif (situation.cameraActions.zoomSetting == "out") then
        adjustedZoom = Camera:ZoomOutTo(situation.cameraActions.zoomValue, situation.cameraActions.transitionTime, situation.cameraActions.timeIsMax);
    elseif (situation.cameraActions.zoomSetting == "set") then
        adjustedZoom = Camera:SetZoom(situation.cameraActions.zoomValue, situation.cameraActions.transitionTime, situation.cameraActions.timeIsMax);
    elseif (situation.cameraActions.zoomSetting == "range") then
        adjustedZoom = Camera:ZoomToRange(situation.cameraActions.zoomMin, situation.cameraActions.zoomMax, situation.cameraActions.transitionTime, situation.cameraActions.timeIsMax);
    elseif (situation.cameraActions.zoomSetting == "fit") then
        adjustedZoom = Camera:ZoomFit(situation.cameraActions.zoomMin, situation.cameraActions.zoomMax, situation.cameraActions.zoomFitNameplate, 85, .25, 5, 2, situation.cameraActions.zoomFitContinous, situation.cameraActions.zoomFitSave, situation.cameraActions.transitionTime, situation.cameraActions.timeIsMax);
    end

    -- if we didn't adjust the soom, then reset oldZoom
    if (not adjustedZoom) then
        restoration[situation].zoom = nil;
        restoration[situation].zoomSituation = nil;
    end

    -- ROTATE --
    if (situation.cameraActions.rotate) then
        if (situation.cameraActions.rotateSetting == "continous") then
            Camera:StartContinousRotate(situation.cameraActions.rotateSpeed);
        elseif (situation.cameraActions.rotateSetting == "degrees") then
            Camera:RotateDegrees(situation.cameraActions.rotateDegrees, situation.cameraActions.transitionTime);
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
    self:DebugPrint("Exiting situation "..situation.name);

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

    -- stop rotating if we started to
    if (situation.cameraActions.rotate) then
        if (situation.cameraActions.rotateSetting == "continous") then
            local degrees = Camera:StopRotating();
            self:DebugPrint("Ended rotate, degrees rotated:", degrees);
            --Camera:RotateDegrees(-degrees, .5); -- TODO: this is a good idea until it's a bad idea
        elseif (situation.cameraActions.rotateSetting == "degrees") then
            if (Camera:IsRotating()) then
                -- interrupted rotation
                local degrees = Camera:StopRotating();
                Camera:RotateDegrees(-degrees, .75); -- TODO: look into constant time here
            else
                Camera:RotateDegrees(-situation.cameraActions.rotateDegrees, .75); -- TODO: look into constant time here
            end
        end
    end

    -- stop zooming if we're still zooming
    if (situation.cameraActions.zoomSetting ~= "off" and Camera:IsZooming()) then
        self:DebugPrint("Still zooming for situation, stop zooming.")
        Camera:StopZooming();
    end

    -- save zoom for Zoom Fit
    if (Camera:IsConfident() and situation.cameraActions.zoomSetting == "fit" and situation.cameraActions.zoomFitSave) then
        if (UnitExists("target")) then
            self:DebugPrint("Saving fit value for this target");
            local npcID = string.match(UnitGUID("target"), "[^-]+-[^-]+-[^-]+-[^-]+-[^-]+-([^-]+)-[^-]+");
            self.db.global.savedZooms.npcs[npcID] = Camera:GetZoom();
        end
    end

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

    for k, situation in pairs(self.db.profile.situations) do
        local prefix = "";
        local suffix = "";

        if (self.currentSituation == situation) then
            prefix = "|cFF00FF00";
            suffix = "|r";
        elseif (not situation.enabled) then
            prefix = "|cFF808A87";
            suffix = "|r";
        elseif (conditionExecutionCache[situation]) then
            prefix = "|cFF63B8FF";
            suffix = "|r";
        end

        situationList[k] = prefix..situation.name..suffix;
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
    newSituation.cameraActions.zoomSetting = "range";
    newSituation.cameraActions.zoomMin = 8;
    newSituation.cameraActions.zoomMax = 20;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    situations["001"] = newSituation;

    newSituation = self:CreateSituation("City (Indoors)");
    newSituation.priority = 11;
    newSituation.condition = "return IsResting() and IsIndoors();";
    newSituation.cameraActions.zoomSetting = "in";
    newSituation.cameraActions.zoomValue = 8;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    situations["002"] = newSituation;

    newSituation = self:CreateSituation("City (Mounted)");
    newSituation.priority = 101;
    newSituation.condition = "return IsResting() and IsMounted();";
    newSituation.cameraActions.zoomSetting = "out";
    newSituation.cameraActions.zoomValue = 30;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    situations["003"] = newSituation;

    newSituation = self:CreateSituation("World");
    newSituation.priority = 0;
    newSituation.condition = "return not IsResting() and not IsInInstance();";
    newSituation.cameraActions.zoomSetting = "range";
    newSituation.cameraActions.zoomMin = 8;
    newSituation.cameraActions.zoomMax = 20;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    situations["004"] = newSituation;

    newSituation = self:CreateSituation("World (Indoors)");
    newSituation.priority = 10;
    newSituation.condition = "return not IsResting() and not IsInInstance() and IsIndoors();";
    newSituation.cameraActions.zoomSetting = "in";
    newSituation.cameraActions.zoomValue = 10;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    situations["005"] = newSituation;

    newSituation = self:CreateSituation("World (Combat)");
    newSituation.priority = 50;
    newSituation.condition = "return not IsInInstance() and UnitAffectingCombat(\"player\");";
    newSituation.cameraActions.zoomSetting = "fit";
    newSituation.cameraActions.zoomFitNameplate = true;
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
    situations["020"] = newSituation;

    newSituation = self:CreateSituation("Dungeon (Outdoors)");
    newSituation.enabled = false;
    newSituation.priority = 12;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\") and IsOutdoors();";
    situations["021"] = newSituation;

    newSituation = self:CreateSituation("Dungeon (Mounted)");
    newSituation.enabled = false;
    newSituation.priority = 102;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\") and IsMounted();";
    situations["022"] = newSituation;

    newSituation = self:CreateSituation("Dungeon (Combat, Boss)");
    newSituation.enabled = false;
    newSituation.priority = 302;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\") and UnitAffectingCombat(\"player\") and IsEncounterInProgress();";
    situations["023"] = newSituation;

    newSituation = self:CreateSituation("Dungeon (Combat, Trash)");
    newSituation.enabled = false;
    newSituation.priority = 202;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\") and UnitAffectingCombat(\"player\") and not IsEncounterInProgress();";
    situations["024"] = newSituation;



    newSituation = self:CreateSituation("Raid");
    newSituation.enabled = false;
    newSituation.priority = 3;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\");";
    situations["030"] = newSituation;

    newSituation = self:CreateSituation("Raid (Outdoors)");
    newSituation.enabled = false;
    newSituation.priority = 13;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and IsOutdoors();";
    situations["031"] = newSituation;

    newSituation = self:CreateSituation("Raid (Mounted)");
    newSituation.enabled = false;
    newSituation.priority = 103;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and IsMounted();";
    situations["032"] = newSituation;

    newSituation = self:CreateSituation("Raid (Combat, Boss)");
    newSituation.enabled = false;
    newSituation.priority = 303;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and UnitAffectingCombat(\"player\") and IsEncounterInProgress();";
    situations["033"] = newSituation;

    newSituation = self:CreateSituation("Raid (Combat, Trash)");
    newSituation.enabled = false;
    newSituation.priority = 203;
    newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and UnitAffectingCombat(\"player\") and not IsEncounterInProgress();";
    situations["034"] = newSituation;





    newSituation = self:CreateSituation("Taxi");
    newSituation.priority = 1000;
    newSituation.condition = "return UnitOnTaxi(\"player\");";
    newSituation.cameraActions.zoomSetting = "set";
    newSituation.cameraActions.zoomValue = 15;
    newSituation.cameraCVars["cameraovershoulder"] = -1;
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.hideFrames["UIParent"] = true;
    situations["100"] = newSituation;

    newSituation = self:CreateSituation("Vehicle");
    newSituation.priority = 1000;
    newSituation.condition = "return UnitUsingVehicle(\"player\");";
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    situations["101"] = newSituation;

    newSituation = self:CreateSituation("Hearthing");
    newSituation.priority = 20;
    newSituation.condition = "local spells = {8690, 222695}; for k,v in pairs(spells) do if (UnitCastingInfo(\"player\") == GetSpellInfo(v)) then return true; end end return false;";
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
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    situations["201"] = newSituation;

    newSituation = self:CreateSituation("NPC Interaction");
    newSituation.priority = 20;
    newSituation.delay = .5;
    newSituation.condition = "return (UnitExists(\"npc\") and UnitIsUnit(\"npc\", \"target\")) and ((GarrisonCapacitiveDisplayFrame and GarrisonCapacitiveDisplayFrame:IsShown()) or (BankFrame and BankFrame:IsShown()) or (MerchantFrame and MerchantFrame:IsShown()) or (GossipFrame and GossipFrame:IsShown()) or (ClassTrainerFrame and ClassTrainerFrame:IsShown()) or (QuestFrame and QuestFrame:IsShown()))";
    newSituation.cameraActions.zoomSetting = "fit";
    newSituation.cameraActions.zoomFitNameplate = true;
    newSituation.cameraActions.zoomFitSave = true;
    newSituation.cameraActions.zoomMin = 3;
    newSituation.cameraActions.zoomMax = 30;
    newSituation.cameraActions.zoomValue = 4;
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
            zoomFitNameplate = false,
            zoomFitContinous = false,
            zoomFitSave = false,
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


--------------------
-- EVENT HANDLERS --
--------------------
function DynamicCam:RefreshConfig()
    local restartTimer = false;

    -- situation is active, but db killed it
    -- TODO: still restore from restoration, at least, what we can
    if (self.currentSituation) then
        self.currentSituation = nil;

        -- apply default settings
        for cvar, value in pairs(self.db.profile.defaultCvars) do
            SetCVar(cvar, value);
        end
    end

    -- kill the evaluate timer if it's running
    if (evaluateTimer) then
        self:CancelTimer(evaluateTimer);
        evaluateTimer = nil;
        restartTimer = true;
    end

    -- apply default situations
    if (not next(self.db.profile.situations)) then
        self.db.profile.situations = self:GetDefaultSituations();
    end

    -- make sure that options panel selects a situation
    if (Options) then
        Options:SelectSituation();
    end

    -- restart the timer if we shut it down
    if (restartTimer) then
        evaluateTimer = self:ScheduleRepeatingTimer("EvaluateSituations", .05);
    end
end


-----------------
-- TARGET LOCK --
-----------------
function DynamicCam:EvaluateTargetLock()
    -- TODO: this shouldn't set cvar over and over and over
    if (self.currentSituation) then
        if (self.currentSituation.targetLock.enabled) and
            (not self.currentSituation.targetLock.onlyAttackable or UnitCanAttack("player", "target")) and
            (self.currentSituation.targetLock.dead or (not UnitIsDead("target"))) and
            (not self.currentSituation.targetLock.nameplateVisible or (C_NamePlate.GetNamePlateForUnit("target") ~= nil))
        then
            SetCVar ("cameralockedtargetfocusing", 1)
        else
            SetCVar ("cameralockedtargetfocusing", 0)
        end
    end
end


-------------------
-- CHAT COMMANDS --
-------------------
function DynamicCam:OpenMenu(input)
    if (not Options) then
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
