---------------
-- LIBRARIES --
---------------
local AceAddon = LibStub("AceAddon-3.0");
local LibCamera = LibStub("LibCamera-1.0");
local LibEasing = LibStub("LibEasing-1.0");


---------------
-- CONSTANTS --
---------------
local ACTION_CAM_CVARS = {
    ["test_cameraOverShoulder"] = true,

    ["test_cameraTargetFocusEnemyEnable"] = true,
    ["test_cameraTargetFocusEnemyStrengthPitch"] = true,
    ["test_cameraTargetFocusEnemyStrengthYaw"] = true,

    ["test_cameraTargetFocusInteractEnable"] = true,
    ["test_cameraTargetFocusInteractStrengthPitch"] = true,
    ["test_cameraTargetFocusInteractStrengthYaw"] = true,

    ["test_cameraHeadMovementStrength"] = true,
    ["test_cameraHeadMovementRangeScale"] = true,
    ["test_cameraHeadMovementMovingStrength"] = true,
    ["test_cameraHeadMovementStandingStrength"] = true,
    ["test_cameraHeadMovementMovingDampRate"] = true,
    ["test_cameraHeadMovementStandingDampRate"] = true,
    ["test_cameraHeadMovementFirstPersonDampRate"] = true,
    ["test_cameraHeadMovementDeadZone"] = true,

    ["test_cameraDynamicPitch"] = true,
    ["test_cameraDynamicPitchBaseFovPad"] = true,
    ["test_cameraDynamicPitchBaseFovPadFlying"] = true,
    ["test_cameraDynamicPitchBaseFovPadDownScale"] = true,
    ["test_cameraDynamicPitchSmartPivotCutoffDist"] = true,
};


-------------
-- GLOBALS --
-------------
DynamicCam = AceAddon:NewAddon("DynamicCam", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");
DynamicCam.currentSituationID = nil;





-- This is needed to get the timing of changing the shoulder offset as good as possible
-- for some model changes. We also use it to restart SetLastWorgenModelId()
-- when the current Worgen model could not yet been determined.
-- http://wowwiki.wikia.com/wiki/Wait

local DynamicCam_waitTable = {};
local DynamicCam_waitFrame = nil;

function DynamicCam_wait(delay, func, ...)
    if (type(delay) ~= "number" or type(func) ~= "function") then
        return false;
    end
    if (DynamicCam_waitFrame == nil) then
        DynamicCam_waitFrame = CreateFrame("Frame", "WaitFrame", UIParent);
        DynamicCam_waitFrame:SetScript("onUpdate",
            function (self, elapse)
                local count = #DynamicCam_waitTable;
                local i = 1;
                while (i <= count) do
                    local waitRecord = tremove(DynamicCam_waitTable, i);
                    local d = tremove(waitRecord, 1);
                    local f = tremove(waitRecord, 1);
                    local p = tremove(waitRecord, 1);
                    if (d > elapse) then
                        tinsert(DynamicCam_waitTable, i, {d-elapse, f, p});
                        i = i + 1;
                    else
                        count = count - 1;
                        f(unpack(p));
                    end
                end
            end
        );
    end
    tinsert(DynamicCam_waitTable, {delay, func, {...}});
    return true;
end






DynamicCam.modelId = {

    ["Human"]              = {  [2] = 1011653,  [3] = 1000764 },
    ["Worgen"]             = {  [2] = 307454,   [3] = 307453  },

};


DynamicCam.raceAndGenderToShoulderOffsetFactor = {

    -- http://wowwiki.wikia.com/wiki/API_UnitRace
    -- https://wow.gamepedia.com/RaceId
    -- race                         male         female
    ["Orc"]                 = {  [2] = 1.00,  [3] = 1.26  },
    ["MagharOrc"]           = {  [2] = 1.00,  [3] = 1.26  },   -- Assumed same as Orc (not tested).
    ["Scourge"]             = {  [2] = 1.20,  [3] = 1.40  },
    ["Tauren"]              = {  [2] = 1.00,  [3] = 1.15  },
    ["HighmountainTauren"]  = {  [2] = 1.00,  [3] = 1.15  },   -- Assumed same as Tauren (not tested).
    ["Troll"]               = {  [2] = 0.98,  [3] = 1.25  },
    ["BloodElf"]            = {  [2] = 1.32,  [3] = 1.38  },
    ["VoidElf"]             = {  [2] = 1.32,  [3] = 1.38  },   -- Assumed same as BloodElf (not tested).
    ["Goblin"]              = {  [2] = 1.32,  [3] = 1.32  },
    ["Human"]               = {  [2] = 1.25,  [3] = 1.45  },
    ["Dwarf"]               = {  [2] = 1.13,  [3] = 1.42  },
    ["DarkIronDwarf"]       = {  [2] = 1.13,  [3] = 1.42  },   -- Assumed same as Dwarf (not tested).
    ["NightElf"]            = {  [2] = 1.20,  [3] = 1.40  },
    ["Nightborne"]          = {  [2] = 1.20,  [3] = 1.40  },   -- Assumed same as NightElf (not tested).
    ["Gnome"]               = {  [2] = 1.60,  [3] = 1.62  },
    ["Draenei"]             = {  [2] = 0.98,  [3] = 1.28  },
    ["LightforgedDraenei"]  = {  [2] = 0.98,  [3] = 1.28  },   -- Assumed same as Draenei (not tested).
    ["Pandaren"]            = {  [2] = 0.95,  [3] = 1.07  },
    -- These are the factors for Worgen form. For Human form take Human factors.
    ["Worgen"]              = {  [2] = 0.94,  [3] = 1.18  },
    ["WorgenRunningWild"]   = {  [2] = 9.40,  [3] = 11.8  },

};


DynamicCam.shamanGhostwolfToShoulderOffsetFactor = {

    -- Ghostwolf hopefully independent of race and gender...
    -- This is for Orc male:
    [16]  = 0.775,  -- Ghostwolf
};


DynamicCam.demonhunterFormToShoulderOffsetFactor = {
    ["BloodElf"] = {
        [2] = {   -- male
            ["Havoc"]     = 0.52,
            ["Vengeance"] = 0.74,
        },
        [3] = {   -- female
            ["Havoc"]     = 0.57,
            ["Vengeance"] = 0.87,
        },
    },
    ["NightElf"] = {
        [2] = {   -- male
            ["Havoc"]     = 0.52,
            ["Vengeance"] = 0.74,
        },
        [3] = {   -- female
            ["Havoc"]     = 0.61,
            ["Vengeance"] = 0.91,
        },
    },
}


DynamicCam.druidFormIdToShoulderOffsetFactor = {

    ["Tauren"] = {
        [2] = {   -- male
            [1]   = 0.862,   -- Cat
            [2]   = 0.78,    -- Tree of Life
            [3]   = 0.888,   -- Travel
            [4]   = 0.71,    -- Aquatic
            [5]   = 0.83,    -- Bear
            [27]  = 0.54,    -- Swift Flight
            [29]  = 0.54,    -- Flight          -- Assumed same as Swift Flight (not tested).
            [31]  = 0.933,   -- Moonkin
        },
        [3] = {   -- female
            [1]   = 0.75,    -- Cat
            [2]   = 0.67,    -- Tree of Life
            [3]   = 0.79,    -- Travel
            [4]   = 0.625,   -- Aquatic
            [5]   = 0.73,    -- Bear
            [27]  = 0.47,    -- Swift Flight
            [29]  = 0.47,    -- Flight          -- Assumed same as Swift Flight (not tested).
            [31]  = 0.83,    -- Moonkin
        },
    },
    ["Worgen"] = {
        -- Actually the same for male and female...
        [2] = {   -- male
            [1]   = 0.685,   -- Cat
            [2]   = 0.63,    -- Tree of Life
            [3]   = 0.66,    -- Travel
            [4]   = 0.515,   -- Aquatic
            [5]   = 0.68,    -- Bear
            [27]  = 0.38,    -- Swift Flight
            [29]  = 0.38,    -- Flight          -- Assumed same as Swift Flight (not tested).
            [31]  = 0.72,    -- Moonkin
        },
        [3] = {   -- female
            [1]   = 0.685,   -- Cat
            [2]   = 0.63,    -- Tree of Life
            [3]   = 0.66,    -- Travel
            [4]   = 0.515,   -- Aquatic
            [5]   = 0.68,    -- Bear
            [27]  = 0.38,    -- Swift Flight
            [29]  = 0.38,    -- Flight          -- Assumed same as Swift Flight (not tested).
            [31]  = 0.72,    -- Moonkin
        },
    }

};




-- Map mountId to sholder offset factor.
-- TODO: Here we have to fill in offset factors for each and every mount model in the game...
-- We could maybe make this a "croudsourcing" endeavour. People will see the console message below,
-- if their current mount is not yet in the code, and I could make a youtube video tutorial
-- explaining how to determine the correct factor, which they would then send to us.
DynamicCam.mountIdToShoulderOffsetFactor = {

    [6]   = 7.5,   -- Brown Horse
    [17]  = 7.6,   -- Felsteed
    [71]  = 4.7,   -- Gray Kodo
    [72]  = 4.7,   -- Brown Kodo
    [76]  = 4.45,  -- Black War Kodo
    [101] = 4.45,  -- Great White Kodo
    [102] = 4.45,  -- Great Gray Kodo
    [103] = 4.45,  -- Great Brown Kodo
    [152] = 6.45,  -- Red Hawkstryder
    [157] = 6.45,  -- Purple Hawkstryder
    [158] = 6.45,  -- Blue Hawkstryder
    [159] = 6.45,  -- Black Hawkstryder
    [203] = 5.8,   -- Cenarion War Hippogryph
    [268] = 2.5,   -- Albino Drake
    [309] = 4.7,   -- White Kodo
    [435] = 7.6,   -- Mountain Horse
    [780] = 5.4,   -- Felsaber

};


-- TODO: Here we have to fill in offset factors for each and every vehicle model in the game...
-- We could maybe make this a "croudsourcing" endeavour. People will see the console message below,
-- if their current vehicle is not yet in the code, and I could make a youtube video tutorial
-- explaining how to determine the correct factor, which they would then send to us.
DynamicCam.vehicleIdToShoulderOffsetFactor = {

    [35129]  = 0.38,  -- Reprogrammed Shredder
    [40854]  = 0.20,  -- River Boat

};



-- To skip the iteration through all mounts trying to find the active one,
-- we store the last active mount to be checked first.
-- This variable is also used when C_MountJournal.GetMountInfoByID() cannot
-- identify the active mount even though isMounted() returns true. This
-- happens when porting somewhere while being mounted or when in the Worgen
-- "Running wild" state.
DynamicCam.lastActiveMount = nil;

-- Returns the mount ID of the currently active mount if any.
function DynamicCam:GetCurrentMount()

    -- First check if the last active mount is still active.
    -- This will save us the effort of iterating through the whole mount journal.
    if (self.lastActiveMount) then

        -- print("Last active mount: " .. self.lastActiveMount);
        local _, _, _, active = C_MountJournal.GetMountInfoByID(self.lastActiveMount);
        if (active) then
            return self.lastActiveMount;
        end
    end

    -- This looks horribly ineffectice, but apparently there is no way of getting the
    -- currently active mount's id directly...
    for k,v in pairs (C_MountJournal.GetMountIDs()) do

        local _, _, _, active = C_MountJournal.GetMountInfoByID(v);

        if (active) then
            -- Store current mount as last active mount.
            self.lastActiveMount = v;
            return v;
        end
    end

    return nil;
end



-- Sometimes, modelFrame:GetModelFileID() to determine Worgen form does return nil while changing form.
-- For these cases we use the last known form stored in this variable, while waiting for the restart.
DynamicCam.lastWorgenModelId = nil;

-- We call this in the end of UNIT_MODEL_CHANGED to be safe against "hiccups",
-- that my leave lastWorgenModelId at the wrong value.
function DynamicCam:SetLastWorgenModelId()
    -- print("SetLastWorgenModelId()");

    local modelFrame = CreateFrame("PlayerModel");
    modelFrame:SetUnit("player");
    local modelId = modelFrame:GetModelFileID();

    if (modelId == nil) then
        -- print(modelId)
        -- print("Restarting")
        DynamicCam_wait(0.01, DynamicCam.SetLastWorgenModelId, DynamicCam);

        modelId = self.lastWorgenModelId;
    else
        -- print("Determined " .. modelId);
        self.lastWorgenModelId = modelId;
    end
end

-- Switch lastWorgenModelId without having to care about gender.
function DynamicCam:SwitchLastWorgenModelId()

    if     (self.lastWorgenModelId == self.modelId["Human"][2]) then
                               return self.modelId["Worgen"][2];   -- Human to Worgen male.
    elseif (self.lastWorgenModelId == self.modelId["Worgen"][2]) then
                               return self.modelId["Human"][2];   -- Worgen to Human male.
    elseif (self.lastWorgenModelId == self.modelId["Human"][3]) then
                               return self.modelId["Worgen"][3];   -- Human to Worgen female.
    elseif (self.lastWorgenModelId == self.modelId["Worgen"][3]) then
                               return self.modelId["Human"][3];   -- Worgen to Human female.
    else
        -- Should only happen right after logging in.
        return self.lastWorgenModelId;
    end
end


-- Flag to remember that you are on a taxi, because the shoulder offset change while
-- leaving a taxi (PLAYER_MOUNT_DISPLAY_CHANGED) needs special treatment...
DynamicCam.isOnTaxi = false;


-- WoW interprets the test_cameraOverShoulder variable differently depending on the current player model.
-- If we want the camera to always have the same shoulder offset relative to the player's center,
-- we need to adjust the test_cameraOverShoulder value depending on the current player model.
-- Arguments:
--   offset                   The original shoulder offset value that should be adjusted.
--                            Is only required to determine the mountedFactor or to stop the function if not needed.
--   enteringVehicleGuid      (optional) When CorrectShoulderOffset is called while entering a vehicle
--                            we pass the vehicle's GUID to determine the test_cameraOverShoulder adjustment.
--                            This is necessary because while entering the vehicle, UnitInVehicle("player") will
--                            still return 'false' while the camera is already regarding the vehicle's model.
function DynamicCam:CorrectShoulderOffset(offset, enteringVehicleGuid)

    -- print("CorrectShoulderOffset (" .. offset .. ")")

    -- If the "Correct Shoulder Offset" function is deactivated, we do not correct the offset.
    if (self.db.profile.modelIndependentShoulderOffset == 0) then
        return 1;
    end

    -- If no offset is set, there is no need to correct it.
    if (offset == 0) then
        return 1;
    end

    -- Is the player entering a vehicle or already in a vehicle?
    if (enteringVehicleGuid or UnitInVehicle("player")) then
        -- print("You are entering or on a vehicle.")

        local vehicleGuid = "";
        if (enteringVehicleGuid) then
            vehicleGuid = enteringVehicleGuid;
            -- print("Entering vehicle.");
        else
            vehicleGuid = UnitGUID("vehicle");
            -- print("Already in vehicle.");
        end

        -- TODO: Could also be "Player-...." if you mount a player in druid travel form.
        -- TODO: Or what if you mount another player's "double-seater" mount?
        -- print(vehicleGuid)


        local _, _, _, _, _, vehicleId = strsplit("-", vehicleGuid);
        vehicleId = tonumber(vehicleId);
        -- print(vehicleId)

        -- Is the shapeshift form already in the code?
        if (self.vehicleIdToShoulderOffsetFactor[vehicleId]) then
            return self.vehicleIdToShoulderOffsetFactor[vehicleId];
        else
            local vehicleName = GetUnitName("vehicle", false);
            if (vehicleName == nil) then
                DynamicCam:DebugPrint("... TODO: Just entering unknown vehicle with ID " .. vehicleId .. ". Zoom in or out to get message including vehicle name!");
            else
                DynamicCam:DebugPrint("... TODO: Vehicle '" .. vehicleName .. "' (" .. vehicleId .. ") not yet known...");
            end

            -- Default for all unknown vehicles...
            return 0.5;
        end


    -- Is the player mounted?
    elseif (IsMounted()) then
        -- print("You are mounted.");

        -- No idea why this is necessary when mounted; seems to be a persistent bug on Blizzard's side!
        local mountedFactor = 1;
        if (offset < 0) then
            mountedFactor = mountedFactor / 10;
        end

        -- Is the player really mounted and not on a "taxi"?
        if (not UnitOnTaxi("player")) then

            local mountId = self:GetCurrentMount();

            -- Right after logging in while on a mount it happens that "IsMounted()" returns true,
            -- but C_MountJournal.GetMountInfoByID() is not yet able to determine that the mount is active.
            -- Furthermore, when in Worgen "Running wild" state, you get isMounted() without a mount.
            if (mountId == nil) then
                -- print("Mounted but no mount");

                -- Check for Worgen "Running Wild" state.
                local _, raceFile = UnitRace("player");
                if ((raceFile == "Worgen")) then
                    for i = 1,40 do
                        local name, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i);
                        if (spellId == 87840) then
                            -- print("Running wild");
                            local genderCode = UnitSex("player");
                            return mountedFactor * self.raceAndGenderToShoulderOffsetFactor["WorgenRunningWild"][genderCode];
                        end
                    end
                end


                -- Happens when mounted while logging in.
                if (self.lastActiveMount == nil) then
                    -- TODO: If you want to make it better, remember the last mount for each character
                    -- in the add-on database...
                    return mountedFactor * 6;
                -- Use the last active mount.
                else
                    -- Is the mount already in the code?
                    if (self.mountIdToShoulderOffsetFactor[self.lastActiveMount]) then
                        return mountedFactor * self.mountIdToShoulderOffsetFactor[self.lastActiveMount];
                    else
                        local creatureName = C_MountJournal.GetMountInfoByID(self.lastActiveMount);
                        DynamicCam:DebugPrint("... TODO: Mount '" .. creatureName .. "' (" .. self.lastActiveMount .. ") not yet known...");
                        -- Default for all other mounts...
                        return mountedFactor * 6;
                    end
                end

            -- mountId not nil
            else
                -- Is the mount already in the code?
                if (self.mountIdToShoulderOffsetFactor[mountId]) then
                    return mountedFactor * self.mountIdToShoulderOffsetFactor[mountId];
                else
                    local creatureName = C_MountJournal.GetMountInfoByID(mountId);
                    DynamicCam:DebugPrint("... TODO: Mount '" .. creatureName .. "' (" .. mountId .. ") not yet known...");
                    -- Default for all other mounts...
                    return mountedFactor * 6;
                end
            end

        else
            -- print("You are on a taxi!")

            -- Remember that you are on a taxi, because the shoulder offset change while
            -- leaving a taxi (PLAYER_MOUNT_DISPLAY_CHANGED) needs special treatment...
            DynamicCam.isOnTaxi = true;

            -- Works all right for Wind Riders.
            -- TODO: This should probably also be done individually for all taxi models in the game.
            return mountedFactor * 2.5;
        end



    -- Is the player shapeshifted?
    elseif (GetShapeshiftFormID(true) ~= nil) then
        -- print("You are shapeshifted.")

        local _, englishClass = UnitClass("player");
        local formId = GetShapeshiftFormID(true);

        if (englishClass == "DRUID") then

            local _, raceFile = UnitRace("player");
            if (self.druidFormIdToShoulderOffsetFactor[raceFile]) then

                local genderCode = UnitSex("player");
                if (self.druidFormIdToShoulderOffsetFactor[raceFile][genderCode]) then


                    if (self.druidFormIdToShoulderOffsetFactor[raceFile][genderCode][formId]) then
                        return self.druidFormIdToShoulderOffsetFactor[raceFile][genderCode][formId];
                    else
                        DynamicCam:DebugPrint("... TODO: " .. raceFile .. " " .. ((genderCode == 2) and "male" or "female") .. " druid form factor for form id " .. formId .. " not yet known...");
                        return 1;
                    end
                else
                    DynamicCam:DebugPrint("... TODO: " .. raceFile .. " " .. ((genderCode == 2) and "male" or "female") .. " druid form factors not yet known...");
                    return 1;
                end
            else
                DynamicCam:DebugPrint("... TODO: " .. raceFile .. " druid form factors not yet known...");
                return 1;
            end
        else
            return self.shamanGhostwolfToShoulderOffsetFactor[formId];
        end


    -- Is the player "normal"?
    else
        -- print("You are normal ...")

        local _, englishClass = UnitClass("player");
        local _, raceFile = UnitRace("player");
        local genderCode = UnitSex("player");
        -- print(englishClass, raceFile, genderCode);

        -- Check for Demon Hunter Metamorphosis.
        if (englishClass == "DEMONHUNTER") then
            for i = 1,40 do
                local name, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i);
                -- print (name, spellId);
                if (spellId == 162264) then
                    -- print("Demon Hunter Metamorphosis Havoc");
                    if (self.demonhunterFormToShoulderOffsetFactor[raceFile][genderCode]["Havoc"]) then
                        return self.demonhunterFormToShoulderOffsetFactor[raceFile][genderCode]["Havoc"];
                    else
                        DynamicCam:DebugPrint("... TODO: " .. raceFile .. " " .. ((genderCode == 2) and "male" or "female") .. " Demonhunter form factor for form 'Havoc' not yet known...");
                        return 1;
                    end
                elseif (spellId == 187827) then
                    -- print("Demon Hunter Metamorphosis Vengeance");
                    if (self.demonhunterFormToShoulderOffsetFactor[raceFile][genderCode]["Vengeance"]) then
                        return self.demonhunterFormToShoulderOffsetFactor[raceFile][genderCode]["Vengeance"];
                    else
                        DynamicCam:DebugPrint("... TODO: " .. raceFile .. " " .. ((genderCode == 2) and "male" or "female") .. " Demonhunter form factor for form 'Vengeance' not yet known...");
                        return 1;
                    end
                end
            end
        end

        -- Worgen need special treatment!
        if ((raceFile == "Worgen")) then

            -- Try to determine the current form.
            local modelFrame = CreateFrame("PlayerModel");
            modelFrame:SetUnit("player");
            local modelId = modelFrame:GetModelFileID();

            -- While dismounting, modelId may return nil.
            -- When this occurs we use the last known modelId and
            -- call SetLastWorgenModelId, to be sure to get the
            -- correct Worgen form eventually.
            if (modelId == nil) then
                modelId = self.lastWorgenModelId;
                self:SetLastWorgenModelId();
            else
                self.lastWorgenModelId = modelId;
            end

            -- print(modelId)

            if ((modelId == self.modelId["Human"][2]) or (modelId == self.modelId["Human"][3])) then
                -- print("... in Human form");
                return self.raceAndGenderToShoulderOffsetFactor["Human"][genderCode];
            else
                -- print("... in Worgen form");
                return self.raceAndGenderToShoulderOffsetFactor["Worgen"][genderCode];
            end

        -- All other races are less problematic.
        else
            if (self.raceAndGenderToShoulderOffsetFactor[raceFile]) then
                return self.raceAndGenderToShoulderOffsetFactor[raceFile][genderCode];
            else
                DynamicCam:DebugPrint("... TODO: Race " .. raceFile .. " not yet known...");
                return 1.0;
            end
        end

    end


end


-- At zoom levels smaller than finishDecrease, we already want a shoulder offset of 0.
-- At zoom levels greater than startDecrease, we want the user set shoulder offset.
-- In zoom levels between we want a gradual transition.
-- TODO: The startDecrease and finishDecrease constants could be made user configurable.
function DynamicCam:GetShoulderOffsetZoomFactor(zoomLevel)

    -- print("GetShoulderOffsetZoomFactor(" .. zoomLevel .. ")");

    if (self.db.profile.shoulderOffsetZoom == 0) then
        return 1
    end

    local startDecrease = 8;
    local finishDecrease = 2;

    if (zoomLevel < finishDecrease) then
        return 0;
    elseif (zoomLevel < startDecrease) then
        return (zoomLevel-finishDecrease) / (startDecrease-finishDecrease);
    else
        return 1;
    end
end




------------
-- LOCALS --
------------
local _;
local Options;
local functionCache = {};
local situationEnvironments = {}
local conditionExecutionCache = {};

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

    if (cvar == "test_cameraOverShoulder") then
        setting = setting * DynamicCam:GetShoulderOffsetZoomFactor(GetCameraZoom()) * DynamicCam:CorrectShoulderOffset(setting)
    end

    -- don't apply cvars if they're already set to the new value
    if (GetCVar(cvar) ~= tostring(setting)) then
        DynamicCam:DebugPrint(cvar, setting);
        SetCVar(cvar, setting);
    end
end

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0);
    return math.floor(num * mult + 0.5) / mult;
end

local function gotoView(view, instant)
    -- if you call SetView twice, then it's instant
    if (instant) then
        SetView(view);
    end
    SetView(view);
end

local function copyTable(originalTable)
    local origType = type(originalTable);
    local copy;
    if (origType == 'table') then
        -- this child is a table, copy the table recursively
        copy = {};
        for orig_key, orig_value in next, originalTable, nil do
            copy[copyTable(orig_key)] = copyTable(orig_value);
        end
    else
        -- this child is a value, copy it cover
        copy = originalTable;
    end
    return copy;
end


----------------------
-- SHOULDER OFFSET  --
----------------------
local easeShoulderOffsetHandle;

-- This function is only called from within easeShoulderOffset()
-- and we make sure that this itself is only called with the added shoulderOffsetZoomFactor.
local function setShoulderOffset(offset)
    if (offset and type(offset) == 'number') then
        SetCVar("test_cameraOverShoulder", offset)
    end
end

local function stopEasingShoulderOffset()
    if (easeShoulderOffsetHandle) then
        LibEasing:StopEasing(easeShoulderOffsetHandle);
        easeShoulderOffsetHandle = nil;
    end
end

local function easeShoulderOffset(endValue, duration, easingFunc)

    -- print("easeShoulderOffset(" .. endValue .. ", " .. duration .. ")")

    stopEasingShoulderOffset();

    local oldOffest = tonumber(GetCVar("test_cameraOverShoulder"));
    easeShoulderOffsetHandle = LibEasing:Ease(setShoulderOffset, oldOffest, endValue, duration, easingFunc);
    -- DynamicCam:DebugPrint("test_cameraOverShoulder", oldOffest, "->", endValue);
end


-------------
-- FADE UI --
-------------
local easeUIAlphaHandle;
local hidMinimap;
local unfadeUIFrame = CreateFrame("Frame", "DynamicCamUnfadeUIFrame");
local combatSecureFrame = CreateFrame("Frame", "DynamicCamCombatSecureFrame", nil, "SecureHandlerStateTemplate");
combatSecureFrame.hidUI = nil;
combatSecureFrame.lastUIAlpha = nil;

RegisterStateDriver(combatSecureFrame, "dc_combat_state", "[combat] combat; [nocombat] nocombat");
combatSecureFrame:SetAttribute("_onstate-dc_combat_state", [[ -- arguments: self, stateid, newstate
    if (newstate == "combat") then
        if (self.hidUI) then
            setUIAlpha(combatSecureFrame.lastUIAlpha);
            UIParent:Show();

            combatSecureFrame.lastUIAlpha = nil;
            self.hidUI = nil;
        end
    end
]]);

local function setUIAlpha(newAlpha)
    if (newAlpha and type(newAlpha) == 'number') then
        UIParent:SetAlpha(newAlpha);

        -- show unfadeUIFrame if we're faded
        if (newAlpha < 1 and not unfadeUIFrame:IsShown()) then
            unfadeUIFrame:Show();
        elseif (newAlpha == 1) then
            -- UI is no longer faded, remove the esc handler
            if (unfadeUIFrame:IsShown()) then
                -- want to hide the frame without calling it's onhide handler
                local onHide = unfadeUIFrame:GetScript("OnHide");
                unfadeUIFrame:SetScript("OnHide", nil);
                unfadeUIFrame:Hide();
                unfadeUIFrame:SetScript("OnHide", onHide);
            end
        end
    end
end

local function stopEasingUIAlpha()
    -- if we are currently easing the UI out, make sure to stop that
    if (easeUIAlphaHandle) then
        LibEasing:StopEasing(easeUIAlphaHandle);
        easeUIAlphaHandle = nil;
    end

    -- show the minimap if we hid it and it's still hidden
    if (hidMinimap and not Minimap:IsShown()) then
        Minimap:Show();
        hidMinimap = nil;
    end

    -- show the UI if we hid it and it's still hidden
    if (combatSecureFrame.hidUI) then
        if (not UIParent:IsShown() and (not InCombatLockdown() or issecure())) then
            setUIAlpha(combatSecureFrame.lastUIAlpha);
            UIParent:Show();
        end

        combatSecureFrame.hidUI = nil;
        combatSecureFrame.lastUIAlpha = nil;
    end
end

local function easeUIAlpha(endValue, duration, easingFunc, callback)
    stopEasingUIAlpha();

    if (UIParent:GetAlpha() ~= endValue) then
        easeUIAlphaHandle = LibEasing:Ease(setUIAlpha, UIParent:GetAlpha(), endValue, duration, easingFunc, callback);
    else
        -- we're not going to ease because we're already there, have to call the callback anyways
        if (callback) then
            callback();
        end
    end
end

local function fadeUI(opacity, duration, hideUI)
    -- setup a callback that will hide the UI if given or hide the minimap if opacity is 0
    local callback = function()
        if (opacity == 0 and hideUI and UIParent:IsShown() and (not InCombatLockdown() or issecure())) then
            -- hide the UI, but make sure to make opacity 1 so that if escape is pressed, it is shown
            setUIAlpha(1);
            UIParent:Hide();

            combatSecureFrame.lastUIAlpha = opacity;
            combatSecureFrame.hidUI = true;
        elseif (opacity == 0 and Minimap:IsShown()) then
            -- hide the minimap
            Minimap:Hide();
            hidMinimap = true;
        end
    end

    easeUIAlpha(opacity, duration, nil, callback);
end

local function unfadeUI(opacity, duration)
    stopEasingUIAlpha();
    easeUIAlpha(opacity, duration);
end

-- need to be able to clear the faded UI, use dummy frame that Show() on fade, which will cause esc to
-- hide it, make OnHide
unfadeUIFrame:SetScript("OnHide", function(self)
    stopEasingUIAlpha();
    UIParent:SetAlpha(1);
end);
tinsert(UISpecialFrames, unfadeUIFrame:GetName());


-----------------------
-- NAMEPLATE ZOOMING --
-----------------------
local nameplateRestore = {};
local RAMP_TIME = .25;
local HYS = 3;
local SETTLE_TIME = .5;
local ERROR_MULT = 2.5;
local STOPPING_SPEED = 5;

local function restoreNameplates()
	if (not InCombatLockdown()) then
		for k,v in pairs(nameplateRestore) do
			SetCVar(k, v);
		end
		nameplateRestore = {};
	end
end

local function fitNameplate(minZoom, maxZoom, nameplatePosition, continously, toggleNameplates)
    if (toggleNameplates and not InCombatLockdown()) then
        nameplateRestore["nameplateShowAll"] = GetCVar("nameplateShowAll");
        nameplateRestore["nameplateShowFriends"] = GetCVar("nameplateShowFriends");
        nameplateRestore["nameplateShowEnemies"] = GetCVar("nameplateShowEnemies");

        SetCVar("nameplateShowAll", 1);
        SetCVar("nameplateShowFriends", 1);
        SetCVar("nameplateShowEnemies", 1);
    end

    local lastSpeed = 0;
    local startTime = GetTime();
    local settleTimeStart;
    local zoomFunc = function() -- returning 0 will stop camera, returning nil stops camera, returning number puts camera to that speed
        local nameplate = C_NamePlate.GetNamePlateForUnit("target");

        if (nameplate) then
            local yCenter = (nameplate:GetTop() + nameplate:GetBottom())/2;
            local screenHeight = GetScreenHeight() * UIParent:GetEffectiveScale();
            local difference = screenHeight - yCenter;
            local ratio = (1 - difference/screenHeight) * 100;
            local error = ratio - nameplatePosition;

            local speed = 0;
            if (lastSpeed == 0 and abs(error) < HYS) then
                speed = 0;
            elseif (abs(error) > HYS/4 or abs(lastSpeed) > STOPPING_SPEED) then
                speed = ERROR_MULT * error;

                local deltaTime = GetTime() - startTime;
                if (deltaTime < RAMP_TIME) then
                    speed = speed * (deltaTime / RAMP_TIME);
                end
            end

            local curZoom = GetCameraZoom();
            if (speed > 0 and curZoom >= maxZoom) then
                speed = 0;
            elseif (speed < 0 and curZoom <= minZoom) then
                speed = 0;
            end

            if (speed == 0) then
                startTime = GetTime();
                settleTimeStart = settleTimeStart or GetTime();
            else
                settleTimeStart = nil;
            end

            if (speed == 0 and not continously and (GetTime() - settleTimeStart > SETTLE_TIME)) then
                return nil;
            end

            lastSpeed = speed;
            return speed;
        end

        if (continously) then
            startTime = GetTime();
            lastSpeed = 0;
            return 0;
        end

        return nil;
    end

    LibCamera:CustomZoom(zoomFunc, restoreNameplates);
    DynamicCam:DebugPrint("zoom fit nameplate");
end


--------
-- DB --
--------
DynamicCam.defaults = {
    profile = {
        enabled = true,
        version = 0,
        firstRun = true,

        advanced = false,
        debugMode = false,
        actionCam = true,

        easingZoom = "InOutQuad",
        easingYaw = "InOutQuad",
        easingPitch = "InOutQuad",

        modelIndependentShoulderOffset = true,
        shoulderOffsetZoom = true,

        reactiveZoom = {
            enabled = false,
            addIncrementsAlways = 1,
            addIncrements = 3,
            maxZoomTime = .25,
            incAddDifference = 4,
            easingFunc = "OutQuad",
        },
        defaultCvars = {
            ["cameraZoomSpeed"] = 20,
            ["cameraDistanceMaxZoomFactor"] = 2.6,

            ["test_cameraOverShoulder"] = 0,

            ["test_cameraTargetFocusEnemyEnable"] = 0,
            ["test_cameraTargetFocusEnemyStrengthPitch"] = 0.4,
            ["test_cameraTargetFocusEnemyStrengthYaw"] = 0.5,
            ["test_cameraTargetFocusInteractEnable"] = 0,
            ["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
            ["test_cameraTargetFocusInteractStrengthYaw"] = 1.0,

            ["test_cameraHeadMovementStrength"] = 0,
            ["test_cameraHeadMovementRangeScale"] = 5,
            ["test_cameraHeadMovementMovingStrength"] = 0.5,
            ["test_cameraHeadMovementStandingStrength"] = 0.3,
            ["test_cameraHeadMovementMovingDampRate"] = 10,
            ["test_cameraHeadMovementStandingDampRate"] = 10,
            ["test_cameraHeadMovementFirstPersonDampRate"] = 20,
            ["test_cameraHeadMovementDeadZone"] = 0.015,

            ["test_cameraDynamicPitch"] = 0,
            ["test_cameraDynamicPitchBaseFovPad"] = .35,
            ["test_cameraDynamicPitchBaseFovPadFlying"] = .75,
            ["test_cameraDynamicPitchBaseFovPadDownScale"] = .25,
            ["test_cameraDynamicPitchSmartPivotCutoffDist"] = 10,
        },
        situations = {
            ["**"] = {
                name = "",
                enabled = true,
                priority = 0,
                condition = "return false",
                events = {},
                delay = 0,
                executeOnInit = "",
                executeOnEnter = "",
                executeOnExit = "",
                cameraActions = {
                    transitionTime = .75,
                    timeIsMax = true,

                    rotate = false,
                    rotateSetting = "continous",
                    rotateSpeed = 20,
                    yawDegrees = 0,
                    pitchDegrees = 0,
                    rotateBack = false,

                    zoomSetting = "off",
                    zoomValue = 10,
                    zoomMin = 5,
                    zoomMax = 15,

                    zoomFitContinous = false,
                    zoomFitPosition = 84,
                    zoomFitUseCurAsMin = false,
                    zoomFitToggleNameplate = false,
                },
                view = {
                    enabled = false,
                    viewNumber = 5,
                    restoreView = false,
                    instant = false,
                },
                extras = {
                    hideUI = false,
                    actuallyHideUI = true,
                    hideUIFadeOpacity = 0,
                },
                cameraCVars = {},
            },
            ["001"] = {
                name = "City",
                priority = 1,
                condition = "return IsResting();",
                events = {"PLAYER_UPDATE_RESTING"},
            },
            ["002"] = {
                name = "City (Indoors)",
                priority = 11,
                condition = "return IsResting() and IsIndoors();",
                events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "SPELL_UPDATE_USABLE"},
            },
            ["004"] = {
                name = "World",
                priority = 0,
                condition = "return not IsResting() and not IsInInstance();",
                events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_NEW_AREA"},
            },
            ["005"] = {
                name = "World (Indoors)",
                priority = 10,
                condition = "return not IsResting() and not IsInInstance() and IsIndoors();",
                events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"},
            },
            ["006"] = {
                name = "World (Combat)",
                priority = 50,
                condition = "return not IsInInstance() and UnitAffectingCombat(\"player\");",
                events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"},
            },
            ["020"] = {
                name = "Dungeon/Scenerio",
                priority = 2,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and (instanceType == \"party\" or instanceType == \"scenario\"));",
                events = {"ZONE_CHANGED_NEW_AREA"},
            },
            ["021"] = {
                name = "Dungeon/Scenerio (Outdoors)",
                priority = 12,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and (instanceType == \"party\" or instanceType == \"scenario\")) and IsOutdoors();",
                events = {"ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"},
            },
            ["023"] = {
                name = "Dungeon/Scenerio (Combat, Boss)",
                priority = 302,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and (instanceType == \"party\" or instanceType == \"scenario\")) and UnitAffectingCombat(\"player\") and IsEncounterInProgress();",
                events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_END", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"},
            },
            ["024"] = {
                name = "Dungeon/Scenerio (Combat, Trash)",
                priority = 202,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and (instanceType == \"party\" or instanceType == \"scenario\")) and UnitAffectingCombat(\"player\") and not IsEncounterInProgress();",
                events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_END", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"},
            },
            ["030"] = {
                name = "Raid",
                priority = 3,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\");",
                events = {"ZONE_CHANGED_NEW_AREA"},
            },
            ["031"] = {
                name = "Raid (Outdoors)",
                priority = 13,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and IsOutdoors();",
                events = {"ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"},
            },
            ["033"] = {
                name = "Raid (Combat, Boss)",
                priority = 303,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and UnitAffectingCombat(\"player\") and IsEncounterInProgress();",
                events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_END", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"},
            },
            ["034"] = {
                name = "Raid (Combat, Trash)",
                priority = 203,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and UnitAffectingCombat(\"player\") and not IsEncounterInProgress();",
                events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_END", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"},
            },
            ["050"] = {
                name = "Arena",
                priority = 3,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"arena\");",
                events = {"ZONE_CHANGED_NEW_AREA"},
            },
            ["051"] = {
                name = "Arena (Combat)",
                priority = 203,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"arena\") and UnitAffectingCombat(\"player\");",
                events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"},
            },
            ["060"] = {
                name = "Battleground",
                priority = 3,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"pvp\");",
                events = {"ZONE_CHANGED_NEW_AREA"},
            },
            ["061"] = {
                name = "Battleground (Combat)",
                priority = 203,
                condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"pvp\") and UnitAffectingCombat(\"player\");",
                events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"},
            },
            ["100"] = {
                name = "Mounted",
                priority = 100,
                condition = "return IsMounted() and not UnitOnTaxi(\"player\");",
                events = {"SPELL_UPDATE_USABLE", "UNIT_AURA"},
            },
            ["101"] = {
                name = "Taxi",
                priority = 1000,
                condition = "return UnitOnTaxi(\"player\");",
                events = {"PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED"},
            },
            ["102"] = {
                name = "Vehicle",
                priority = 1000,
                condition = "return UnitUsingVehicle(\"player\");",
                events = {"UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE"},
            },
            ["200"] = {
                name = "Hearth/Teleport",
                priority = 20,
                condition = [[for k,v in pairs(this.spells) do
    if (UnitCastingInfo("player") == GetSpellInfo(v)) then
        return true;
    end
end
return false;]],
                executeOnInit = "this.spells = {227334, 136508, 189838, 54406, 94719, 556, 168487, 168499, 171253, 50977, 8690, 222695, 171253, 224869, 53140, 3565, 32271, 193759, 3562, 3567, 33690, 35715, 32272, 49358, 176248, 3561, 49359, 3566, 88342, 88344, 3563, 132627, 132621, 176242, 192085, 192084, 216016};",
                executeOnEnter = "local _, _, _, startTime, endTime = UnitCastingInfo(\"player\");\nthis.transitionTime = ((endTime - startTime)/1000) - .25;",
                events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTED"},
            },
            ["201"] = {
                name = "Annoying Spells",
                priority = 1000,
                condition = [[for k,v in pairs(this.buffs) do
    local name = GetSpellInfo(v);
    if (AuraUtil.FindAuraByName(name, "player", "HELPFUL")) then
        return true;
    end
end
return false;]],
                events = {"UNIT_AURA"},
                executeOnInit = "this.buffs = {46924, 51690, 188499, 210152};",
            },
            ["300"] = {
                name = "NPC Interaction",
                priority = 20,
                condition = "local unit = (UnitExists(\"questnpc\") and \"questnpc\") or (UnitExists(\"npc\") and \"npc\");\nreturn unit and (UnitIsUnit(unit, \"target\"));",
                events = {"PLAYER_TARGET_CHANGED", "GOSSIP_SHOW", "GOSSIP_CLOSED", "QUEST_COMPLETE", "QUEST_DETAIL", "QUEST_FINISHED", "QUEST_GREETING", "QUEST_PROGRESS", "BANKFRAME_OPENED", "BANKFRAME_CLOSED", "MERCHANT_SHOW", "MERCHANT_CLOSED", "TRAINER_SHOW", "TRAINER_CLOSED", "SHIPMENT_CRAFTER_OPENED", "SHIPMENT_CRAFTER_CLOSED"},
                delay = .5,
            },
            ["301"] = {
                name = "Mailbox",
                priority = 20,
                condition = "return (MailFrame and MailFrame:IsShown())",
                events = {"MAIL_CLOSED", "MAIL_SHOW", "GOSSIP_CLOSED"},
            },
            ["302"] = {
                name = "Fishing",
                priority = 20,
                condition = "return (UnitChannelInfo(\"player\") == GetSpellInfo(7620))",
                events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTED"},
                delay = 2,
            },
        },
    },
};


----------
-- CORE --
----------
local started;
local events = {};
local evaluateTimer;

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

    self:RegisterChatCommand("zoom", "ZoomSlash");
    self:RegisterChatCommand("pitch", "PitchSlash");
    self:RegisterChatCommand("yaw", "YawSlash");

    -- make sure to disable the message if ActionCam setting is on
    if (self.db.profile.actionCam) then
        UIParent:UnregisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED");
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
    if (not Options) then
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

    -- turn on reactive zoom if it's enabled
    if (self.db.profile.reactiveZoom.enabled) then
        self:ReactiveZoomOn();
    else
        -- This will make sure that the shoulder offset zoom is hooked if enabled.
        self:ReactiveZoomOff();
    end

    -- This will eventually set the right Worgen model ID.
    local _, raceFile = UnitRace("player");
    if ((raceFile == "Worgen")) then
        self:SetLastWorgenModelId();
    end

    -- If we do not set the shoulder offset once already here, there will always be a
    -- slight delay after logging in, as entering situation comes a little too late.
    -- This only comes into effect, when you switch between characters with different factors.
    local shoulderOffsetZoomFactor = self:GetShoulderOffsetZoomFactor(GetCameraZoom());
    local userSetShoulderOffset = self.db.profile.defaultCvars["test_cameraOverShoulder"];
    local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset);
    SetCVar("test_cameraOverShoulder", correctedShoulderOffset);


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

    events = {};
    self:UnregisterAllEvents();
    self:UnregisterAllMessages();

    -- apply default settings
    self:ApplyDefaultCameraSettings();

    -- turn off reactiveZoom
    self:ReactiveZoomOff();

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
local delayTime;
local delayTimer;
local restoration = {};

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

        local swap = true;
        if (self.currentSituationID and (not topSituation or topSituation ~= self.currentSituationID)) then
            -- we're in a situation that isn't the topSituation or there is no topSituation
            local delay = self.db.profile.situations[self.currentSituationID].delay;
            if (delay > 0) then
                if (not delayTime) then
                    -- not yet cooling down, make sure to guarentee an evaluate, don't swap
                    delayTime = GetTime() + delay;
                    delayTimer = self:ScheduleTimer("EvaluateSituations", delay, "DELAY_TIMER");
                    self:DebugPrint("Not changing situation because of a delay of " .. delay);
                    swap = false;
                elseif (delayTime > GetTime()) then
                    -- still cooling down, don't swap
                    swap = false;
                end
            end
        end

        if (swap) then
            if (topSituation) then
                if (topSituation ~= self.currentSituationID) then
                    -- we want to swap and there is a situation to swap into, and it's not the current situation
                    self:SetSituation(topSituation);
                end

                -- if we had a delay previously, make sure to reset it
                delayTime = nil;
            else
                --none of the situations are active, leave the current situation
                if (self.currentSituationID) then
                    self:ExitSituation(self.currentSituationID);
                end
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
    local this = situationEnvironments[situationID].this;

    self:DebugPrint("Entering situation", situation.name);

    -- load and run advanced script onEnter
    DC_RunScript(situation.executeOnEnter, situationID);

    self.currentSituationID = situationID;

    restoration[situationID] = {};
    local a = situation.cameraActions;

    local transitionTime = a.transitionTime;
    if (this.transitionTime) then
        transitionTime = this.transitionTime;
    end
    -- min 10 frames
    transitionTime = math.max(10.0/60.0, transitionTime);

    -- set view settings
    if (situation.view.enabled) then
        if (situation.view.restoreView) then
            SaveView(1);
        end

        gotoView(situation.view.viewNumber, situation.view.instant);
    end

    -- ZOOM --
    if (not skipZoom) then
        -- save old zoom level
        local cameraZoom = GetCameraZoom();
        restoration[situationID].zoom = round(cameraZoom, 1);
        restoration[situationID].zoomSituation = oldSituationID;

        -- set zoom level
        local newZoomLevel;

        if (a.zoomSetting == "in" and cameraZoom > a.zoomValue) then
            newZoomLevel = a.zoomValue;
        elseif (a.zoomSetting == "out" and cameraZoom < a.zoomValue) then
            newZoomLevel = a.zoomValue;
        elseif (a.zoomSetting == "set") then
            newZoomLevel = a.zoomValue;
        elseif (a.zoomSetting == "range") then
            if (cameraZoom < a.zoomMin) then
                newZoomLevel = a.zoomMin;
            elseif (cameraZoom > a.zoomMax) then
                newZoomLevel = a.zoomMax;
            end
        elseif (a.zoomSetting == "fit") then
            local min = a.zoomMin;
            if (a.zoomFitUseCurAsMin) then
                min = math.min(GetCameraZoom(), a.zoomMax);
            end

            fitNameplate(min, a.zoomMax, a.zoomFitPosition, a.zoomFitContinous, a.zoomFitToggleNameplate);
        end

        -- actually do zoom
        if (newZoomLevel) then
            local difference = math.abs(newZoomLevel - cameraZoom)
            local linearSpeed = difference / transitionTime;
            local currentSpeed = tonumber(GetCVar("cameraZoomSpeed"));
            local duration = transitionTime;

            -- if zoom speed is lower than current speed, then calculate a new transitionTime
            if (a.timeIsMax and linearSpeed < currentSpeed) then
                -- min time 10 frames
                duration = math.max(10.0/60.0, difference / currentSpeed)
            end

            self:DebugPrint("Setting zoom level because of situation entrance", newZoomLevel, duration);

            LibCamera:SetZoom(newZoomLevel, duration, LibEasing[self.db.profile.easingZoom]);
        end

        -- if we didn't adjust the zoom, then reset oldZoom
        if (not newZoomLevel and a.zoomSetting ~= "fit") then
            restoration[situationID].zoom = nil;
            restoration[situationID].zoomSituation = nil;
        end
    else
        self:DebugPrint("Restoring zoom level, so skipping zoom action")
    end

    -- set all cvars
    for cvar, value in pairs(situation.cameraCVars) do
        if (cvar == "test_cameraOverShoulder") then

            local zoomValue = GetCameraZoom();
            if (a.zoomValue) then
                zoomValue = a.zoomValue;
            end

            local correctedShoulderOffset = value * self:GetShoulderOffsetZoomFactor(zoomValue) * self:CorrectShoulderOffset(value);
            if (GetCVar("test_cameraOverShoulder") ~= tostring(correctedShoulderOffset)) then
                stopEasingShoulderOffset();
                easeShoulderOffset(correctedShoulderOffset, transitionTime);
            end
        else
            DC_SetCVar(cvar, value);
        end
    end

    -- ROTATE --
    if (a.rotate) then
        if (a.rotateSetting == "continous") then
            LibCamera:BeginContinuousYaw(a.rotateSpeed, transitionTime);
        elseif (a.rotateSetting == "degrees") then
            if (a.yawDegrees ~= 0) then
                LibCamera:Yaw(a.yawDegrees, transitionTime, LibEasing[self.db.profile.easingYaw]);
            end

            if (a.pitchDegrees ~= 0) then
                LibCamera:Pitch(a.pitchDegrees, transitionTime, LibEasing[self.db.profile.easingPitch]);
            end
        end
    end

    -- EXTRAS --
    if (situation.extras.hideUI) then
        fadeUI(situation.extras.hideUIFadeOpacity, math.min(0.5, transitionTime), situation.extras.actuallyHideUI);
    end

    self:SendMessage("DC_SITUATION_ENTERED");
end

function DynamicCam:ExitSituation(situationID, newSituationID)
    local restoringZoom;
    local situation = self.db.profile.situations[situationID];
    self.currentSituationID = nil;

    self:DebugPrint("Exiting situation "..situation.name);

    -- load and run advanced script onExit
    DC_RunScript(situation.executeOnExit, situationID);

    -- restore cvars to their default values
    -- This normally also restores the shoulder offset, possibly too fast or too slow.
    -- We want to restore it at the same speed as the zoom (see below).
    -- By passing true as the second argument (exitingSituationFlag),
    -- we avoid test_cameraOverShoulder from being set.
    self:ApplyDefaultCameraSettings(newSituationID, true);

    -- restore view that is enabled
    if (situation.view.enabled and situation.view.restoreView) then
        gotoView(1, situation.view.instant);
    end

    local a = situation.cameraActions;

    -- stop rotating if we started to
    if (a.rotate) then
        if (a.rotateSetting == "continous") then
            local yaw = LibCamera:StopYawing();

            -- rotate back if we want to
            if (a.rotateBack) then
                self:DebugPrint("Ended rotate, degrees rotated, yaw:", yaw);
                if (yaw) then
                    local yawBack = yaw % 360;

                    -- we're beyond 180 degrees, go the other way
                    if (yawBack > 180) then
                        yawBack = yawBack - 360;
                    end

                    LibCamera:Yaw(-yawBack, 0.75, LibEasing[self.db.profile.easingYaw]);
                end
            end
        elseif (a.rotateSetting == "degrees") then
            if (LibCamera:IsRotating()) then
                -- interrupted rotation
                local yaw, pitch = LibCamera:StopRotating();

                -- rotate back if we want to
                if (a.rotateBack) then
                    self:DebugPrint("Ended rotate early, degrees rotated, yaw:", yaw, "pitch:", pitch);
                    if (yaw) then
                        LibCamera:Yaw(-yaw, 0.75, LibEasing[self.db.profile.easingYaw]);
                    end

                    if (pitch) then
                        LibCamera:Pitch(-pitch, 0.75, LibEasing[self.db.profile.easingPitch]);
                    end
                end
            else
                if (a.rotateBack) then
                    if (a.yawDegrees ~= 0) then
                        LibCamera:Yaw(-a.yawDegrees, 0.75, LibEasing[self.db.profile.easingYaw]);
                    end

                    if (a.pitchDegrees ~= 0) then
                        LibCamera:Pitch(-a.pitchDegrees, 0.75, LibEasing[self.db.profile.easingPitch]);
                    end
                end
            end
        end
    end

    -- restore zoom level if we saved one
    if (self:ShouldRestoreZoom(situationID, newSituationID)) then
        restoringZoom = true;

        local defaultTime = math.abs(restoration[situationID].zoom - GetCameraZoom()) / tonumber(GetCVar("cameraZoomSpeed"));
        local t = math.max(10.0/60.0, math.min(defaultTime, .75));
        local zoomLevel = restoration[situationID].zoom;

        LibCamera:SetZoom(zoomLevel, t, LibEasing[self.db.profile.easingZoom]);


        -- TODO: Should get the shoulder offset of the newSituationID!
        local userSetShoulderOffset = self.db.profile.defaultCvars["test_cameraOverShoulder"];
        local correctedShoulderOffset = userSetShoulderOffset * self:GetShoulderOffsetZoomFactor(zoomLevel) * self:CorrectShoulderOffset(userSetShoulderOffset);

        easeShoulderOffset(correctedShoulderOffset, t, LibEasing[self.db.profile.easingZoom]);

        self:DebugPrint("Restoring zoom level:", zoomLevel, " and shoulder offset:", correctedShoulderOffset, " with duration:", t);

    else
        -- Just restore test_cameraOverShoulder, because we skipped it by passing true as the second
        -- argument (exitingSituationFlag) to ApplyDefaultCameraSettings() above.
        -- TODO: Should get the shoulder offset of the newSituationID!
        local userSetShoulderOffset = self.db.profile.defaultCvars["test_cameraOverShoulder"];
        local correctedShoulderOffset = userSetShoulderOffset * self:GetShoulderOffsetZoomFactor(GetCameraZoom()) * self:CorrectShoulderOffset(userSetShoulderOffset);

        easeShoulderOffset(correctedShoulderOffset, 0.75);

        self:DebugPrint("Not restoring zoom level but shoulder offset: " .. correctedShoulderOffset);
    end

    -- unhide UI
    if (situation.extras.hideUI) then
        unfadeUI(1, .5);
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
        local customPrefix = "";

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

        if (string.find(id, "custom")) then
            customPrefix = "Custom: ";
        end

        situationList[id] = prefix..customPrefix..situation.name..suffix;
    end

    return situationList;
end

function DynamicCam:CopySituationInto(fromID, toID)
    -- make sure that both from and to are valid situationIDs
    if (not fromID or not toID or fromID == toID or not self.db.profile.situations[fromID] or not self.db.profile.situations[toID]) then
        self:DebugPrint("CopySituationInto has invalid from or to!");
        return;
    end

    local from = self.db.profile.situations[fromID];
    local to = self.db.profile.situations[toID];

    -- copy settings over
    to.enabled = from.enabled;

    -- a more robust solution would be much better!
    to.cameraActions = {};
    for key, value in pairs(from.cameraActions) do
        to.cameraActions[key] = from.cameraActions[key];
    end

    to.view = {};
    for key, value in pairs(from.view) do
        to.view[key] = from.view[key];
    end

    to.extras = {};
    for key, value in pairs(from.extras) do
        to.extras[key] = from.extras[key];
    end

    to.cameraCVars = {};
    for key, value in pairs(from.cameraCVars) do
        to.cameraCVars[key] = from.cameraCVars[key];
    end

    self:SendMessage("DC_SITUATION_UPDATED", toID);
end

function DynamicCam:UpdateSituation(situationID)
    local situation = self.db.profile.situations[situationID];
    if (situation and (situationID == self.currentSituationID)) then
        -- apply cvars
        for cvar, value in pairs(situation.cameraCVars) do
            DC_SetCVar(cvar, value);
        end
        self:ApplyDefaultCameraSettings();
    end
    DC_RunScript(situation.executeOnInit, situationID);
    self:RegisterSituationEvents(situationID);
    self:EvaluateSituations();
end

function DynamicCam:CreateCustomSituation(name)
    -- search for a clear id
    local highest = 0;

    -- go through each and every situation, look for the custom ones, and find the
    -- highest custom id
    for id, situation in pairs(self.db.profile.situations) do
        local i, j = string.find(id, "custom");

        if (i and j) then
            local num = tonumber(string.sub(id, j+1));

            if (num and num > highest) then
                highest = num;
            end
        end
    end

    -- copy the default situation into a new table
    local newSituationID = "custom"..(highest+1);
    local newSituation = copyTable(self.defaults.profile.situations["**"]);

    newSituation.name = name;

    -- create the entry in the profile with an id 1 higher than the highest already customID
    self.db.profile.situations[newSituationID] = newSituation;

    -- make sure that the options panel reselects a situation
    if (Options) then
        Options:SelectSituation(newSituationID);
    end

    self:SendMessage("DC_SITUATION_UPDATED", newSituationID);
    return newSituation, newSituationID;
end

function DynamicCam:DeleteCustomSituation(situationID)
    if (not self.db.profile.situations[situationID]) then
        self:DebugPrint("Cannot delete this situation since it doesn't exist", situationID)
    end

    if (not string.find(situationID, "custom")) then
        self:DebugPrint("Cannot delete a non-custom situation");
    end

    -- if we're currently in this situation, exit it
    if (self.currentSituationID == situationID) then
        self:ExitSituation(situationID);
    end

    -- delete the situation
    self.db.profile.situations[situationID] = nil;

    -- make sure that the options panel reselects a situation
    if (Options) then
        Options:ClearSelection();
        Options:SelectSituation();
    end

    -- EvaluateSituations because we might have changed the current situation
    self:EvaluateSituations();
end


-------------
-- UTILITY --
-------------
-- The second argument (exitingSituationFlag) can be set to true if ApplyDefaultCameraSettings
-- is called when exiting a situation. This will lead to skipping test_cameraOverShoulder in
-- assinging all default settings. Because we would like to ease the shoulder offset transition
-- at the same pace as we change the zoom level when exiting a situation, instead of setting
-- the shoulder offset instantaneously.
function DynamicCam:ApplyDefaultCameraSettings(newSituationID, exitingSituationFlag)
    local curSituation = self.db.profile.situations[self.currentSituationID];

    if (newSituationID) then
        curSituation = self.db.profile.situations[newSituationID];
    end

    -- apply ActionCam setting
    if (self.db.profile.actionCam) then
        -- if it's on, unregister the event, so that we don't get popup
        UIParent:UnregisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED");
    else
        -- if it's off, make sure to reset all ActionCam settings, then reenable popup
        ResetTestCvars();
        UIParent:RegisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED");
    end

    -- apply default settings if the current situation isn't overriding them
    for cvar, value in pairs(self.db.profile.defaultCvars) do
        if (not curSituation or not curSituation.cameraCVars[cvar]) then
            if (cvar == "test_cameraOverShoulder") then

                -- When exiting a situation, we want to restore the shoulderOffset just as fast as the zoom.
                -- Setting it here might result in glitches.
                if (not exitingSituationFlag) then
                    local correctedShoulderOffset = value * self:GetShoulderOffsetZoomFactor(GetCameraZoom()) * self:CorrectShoulderOffset(value);
                    if (GetCVar("test_cameraOverShoulder") ~= tostring(correctedShoulderOffset)) then
                        stopEasingShoulderOffset();
                        easeShoulderOffset(correctedShoulderOffset, 0.75);
                    end
                end
            else
                DC_SetCVar(cvar, value);
            end
        end
    end
end

function DynamicCam:ShouldRestoreZoom(oldSituationID, newSituationID)
    local newSituation = self.db.profile.situations[newSituationID];

    -- don't restore if we don't have a saved zoom value
    if (not restoration[oldSituationID].zoom) then
        return false;
    end

    -- restore if we're just exiting a situation, but not going into a new one
    if (not newSituation) then
        self:DebugPrint("Restoring because just exiting");
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
        -- don't restore zoom if the new situation doesn't zoom at all
        return false;
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


-------------------
-- REACTIVE ZOOM --
-------------------
local targetZoom;
local oldCameraZoomIn = CameraZoomIn;
local oldCameraZoomOut = CameraZoomOut;

local function clearTargetZoom(wasInterrupted)
    if (not wasInterrupted) then
        targetZoom = nil;
    end
end

local function ReactiveZoom(zoomIn, increments, automated)
    increments = increments or 1;

    if (not automated and increments == 1) then
        local currentZoom = GetCameraZoom();

        local addIncrementsAlways = DynamicCam.db.profile.reactiveZoom.addIncrementsAlways;
        local addIncrements = DynamicCam.db.profile.reactiveZoom.addIncrements;
        local maxZoomTime = DynamicCam.db.profile.reactiveZoom.maxZoomTime;
        local incAddDifference = DynamicCam.db.profile.reactiveZoom.incAddDifference;
        local easingFunc = DynamicCam.db.profile.reactiveZoom.easingFunc;

        -- if we've change directions, make sure to reset
        if (zoomIn) then
            if (targetZoom and targetZoom > currentZoom) then
                targetZoom = nil;
            end
        else
            if (targetZoom and targetZoom < currentZoom) then
                targetZoom = nil;
            end
        end

        -- scale increments up
        if (increments == 1) then
            if (targetZoom) then
                local diff = math.abs(targetZoom - currentZoom);

                if (diff > incAddDifference) then
                    increments = increments + addIncrementsAlways + addIncrements;
                else
                    increments = increments + addIncrementsAlways;
                end
            else
                increments = increments + addIncrementsAlways;
            end
        end

        -- if there is already a target zoom, base off that one, or just use the current zoom
        targetZoom = targetZoom or currentZoom;

        if (zoomIn) then
            targetZoom = math.max(0, targetZoom - increments);
        else
            targetZoom = math.min(39, targetZoom + increments);
        end

        -- if we don't need to zoom because we're at the max limits, then don't
        if ((targetZoom == 39 and currentZoom == 39)
            or (targetZoom == 0 and currentZoom == 0)) then
            return;
        end

        -- round target zoom off to the nearest decimal
        targetZoom = round(targetZoom, 1);

        -- get the current time to zoom if we were going linearly or use maxZoomTime, if that's too high
        local zoomTime = math.min(maxZoomTime, math.abs(targetZoom - currentZoom)/tonumber(GetCVar("cameraZoomSpeed")));


        -- Also correct the shoulder offset according to zoom level.
        -- TODO: Should get the shoulder offset of current situation!
        local userSetShoulderOffset = DynamicCam.db.profile.defaultCvars["test_cameraOverShoulder"]
        local correctedShoulderOffset = userSetShoulderOffset * DynamicCam:GetShoulderOffsetZoomFactor(targetZoom) * DynamicCam:CorrectShoulderOffset(userSetShoulderOffset);
        easeShoulderOffset(correctedShoulderOffset, zoomTime, LibEasing[easingFunc]);

        LibCamera:SetZoom(targetZoom, zoomTime, LibEasing[easingFunc], clearTargetZoom);
    else
        if (zoomIn) then
            oldCameraZoomIn(increments, automated);
        else
            oldCameraZoomOut(increments, automated);
        end
    end
end

local function ReactiveZoomIn(increments, automated)
    ReactiveZoom(true, increments, automated);
end

local function ReactiveZoomOut(increments, automated)
    ReactiveZoom(false, increments, automated);
end

function DynamicCam:ReactiveZoomOn()
    CameraZoomIn = ReactiveZoomIn;
    CameraZoomOut = ReactiveZoomOut;
end

function DynamicCam:ReactiveZoomOff()
    -- CameraZoomIn = oldCameraZoomIn;
    -- CameraZoomOut = oldCameraZoomOut;
    -- ShoulderOffsetZoomCheck will make the above hooks.
    self:ShoulderOffsetZoomCheck();
end



-- To enable shoulder offset correction for non-reactive zoom,
-- we need to hook the "old zoom" functions.
function hooked_oldCameraZoomIn(...)

    local increments = ...;
    local currentZoom = GetCameraZoom();

    -- Use the method from reactiveZoom to determine final zoom level.
    if (targetZoom and targetZoom > currentZoom) then
        targetZoom = nil;
    end
    targetZoom = targetZoom or currentZoom;
    targetZoom = math.max(0, targetZoom - increments);

    -- TODO: Should get the shoulder offset of current situation!
    local userSetShoulderOffset = DynamicCam.db.profile.defaultCvars["test_cameraOverShoulder"];
    local correctedShoulderOffset = userSetShoulderOffset * DynamicCam:GetShoulderOffsetZoomFactor(targetZoom) * DynamicCam:CorrectShoulderOffset(userSetShoulderOffset);
    SetCVar("test_cameraOverShoulder", correctedShoulderOffset);
    -- easeShoulderOffset(correctedShoulderOffset, 0.1);

    return oldCameraZoomIn(...);
end


function hooked_oldCameraZoomOut(...)

    local increments = ...;
    local currentZoom = GetCameraZoom();

    -- Use the method from reactiveZoom to determine final zoom level.
    if (targetZoom and targetZoom < currentZoom) then
        targetZoom = nil;
    end
    targetZoom = targetZoom or currentZoom;
    targetZoom = math.min(39, targetZoom + increments);

    -- TODO: Should get the shoulder offset of current situation!
    local userSetShoulderOffset = DynamicCam.db.profile.defaultCvars["test_cameraOverShoulder"];
    local correctedShoulderOffset = userSetShoulderOffset * DynamicCam:GetShoulderOffsetZoomFactor(targetZoom) * DynamicCam:CorrectShoulderOffset(userSetShoulderOffset);
    SetCVar("test_cameraOverShoulder", correctedShoulderOffset);
    -- easeShoulderOffset(correctedShoulderOffset, 0.1);

    return oldCameraZoomOut(...);
end


function DynamicCam:ShoulderOffsetZoomCheck()
    if (self.db.profile.shoulderOffsetZoom == 1) then
        CameraZoomIn  = hooked_oldCameraZoomIn;
        CameraZoomOut = hooked_oldCameraZoomOut;
    else
        CameraZoomIn  = oldCameraZoomIn;
        CameraZoomOut = oldCameraZoomOut;
    end
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





-- While dismounting we need to execute a shoulder offset change at the time
-- of the next UNIT_AURA event; but only then. So we use this variable as a flag.
-- We also need this for the perfect timing while changing from Ghostwolf back to Shaman
-- and from shapeshifted back to Druid.
DynamicCam.activateNextUnitAura = false;

-- The cooldown of "Two Forms" is shorter than it actually takes to perform the transformation.
-- This flag indicates that a change into Worgen with "Two Forms" is in progress.
DynamicCam.changingIntoWorgen = false;

-- To detect a spontaneous change into Worgen when entering combat, we need
-- to react to every execution of UNIT_MODEL_CHANGED. Every Worgen form change triggers
-- two UNIT_MODEL_CHANGED executions, the first of which has the right timing but
-- can only get modelId == nil. So we assume a form change whenever we get
-- UNIT_MODEL_CHANGED and modelId == nil.
-- However, there are certain situations in which we want to suppress the next executions of
-- UNIT_MODEL_CHANGED to do this. (E.g. when "Two Forms" is used again while the change into
-- Worgen is in progress etc.) This variable can be set to skip a certain number of upcoming
-- UNIT_MODEL_CHANGED executions.
DynamicCam.skipNextWorgenUnitModelChanged = 0;


function DynamicCam:ShoulderOffsetEventHandler(event, ...)

    -- print("ShoulderOffsetEventHandler got event: " .. event)
    -- print(...)

    -- If both shoulder offset adjustments are disabled, do nothing!
    if ((self.db.profile.modelIndependentShoulderOffset == 0) and (self.db.profile.shoulderOffsetZoom == 0)) then
        return;
    end


    -- Got to stop shoulder offset easing that might already be in process.
    -- E.g. an easing started in ExitSituation() called at the same time as
    -- the execution of PLAYER_MOUNT_DISPLAY_CHANGED.
    -- Otherweise there is a problem, if you change directly from "mounted" to "shapeshifted".
    -- Because ExitSituation() will find the player temporarily in normal form,
    -- calculate the shoulder offset for it and start the shoulder offset ease.
    -- Then comes the UPDATE_SHAPESHIFT_FORM event triggering ShoulderOffsetEventHandler(),
    -- but its new shoulder offset value will be overridden by the ongoing easing.
    stopEasingShoulderOffset();

    -- TODO: Should get the shoulder offset of current situation!
    local userSetShoulderOffset = self.db.profile.defaultCvars["test_cameraOverShoulder"];
    local shoulderOffsetZoomFactor = self:GetShoulderOffsetZoomFactor(GetCameraZoom());


    -- Needed for Worgen form change and Demon Hunter Metamorphosis.
    if (event == "UNIT_SPELLCAST_SUCCEEDED") then
        local unitName, _, spellId = ...;

        -- Only do something if UNIT_SPELLCAST_SUCCEEDED is for "player".
        if (unitName ~= "player") then
            return;
        end

        local _, raceFile = UnitRace("player");
        if ((raceFile == "Worgen")) then

            -- We only use this for chaning from Worgen into Human,
            -- because then the UNIT_MODEL_CHANGED comes a little too late.
            if (spellId == 68996) then
                -- print("Worgen form change ('Two Forms')!");

                -- The cooldown of "Two Forms" is shorter than it takes to fully change into Worgen.
                -- If you hit "Two Forms" again before completely transforming you just stay in Human form.
                if (self.changingIntoWorgen) then
                    self.changingIntoWorgen = false;
                    -- We need to skip the next two executions of UNIT_MODEL_CHANGED.
                    self.skipNextWorgenUnitModelChanged = 2;
                    return;
                end


                -- Derive the Worgen form you are changing into from the last known form.
                local targetWorgenFormAtSpellcast = self:SwitchLastWorgenModelId();
                if ((targetWorgenFormAtSpellcast == self.modelId["Human"][2]) or (targetWorgenFormAtSpellcast == self.modelId["Human"][3])) then
                    -- print("Changing into Human.");

                    -- WoW sometimes misses that you cannot use "Two Forms" while in combat.
                    -- Then we get UNIT_SPELLCAST_SUCCEEDED but the model does not change.
                    -- So we have to catch this here ourselves.
                    if (InCombatLockdown()) then
                        -- print("InCombatLockdown");
                        return;
                    end

                    -- While changing from Worgen into Human, the next UNIT_MODEL_CHANGED event
                    -- comes a little too late for a smooth shoulder offset change and there
                    -- are no events in between. This is why we have to use DynamicCam_wait here.

                    -- Set lastWorgenModelId to Human.
                    self.lastWorgenModelId = targetWorgenFormAtSpellcast;

                    -- Remember that we are currently chaning into Human in order to suppress
                    -- a shoulder offset change by the next UNIT_MODEL_CHANGED.
                    -- The second next UNIT_MODEL_CHANGED would not hurt, as it would correctly
                    -- identify the Human model, but we can suppress it as well.
                    self.skipNextWorgenUnitModelChanged = 2;

                    -- As we are circumventing CorrectShoulderOffset(), we have to check the setting here!
                    local factor = 1;
                    if (self.db.profile.modelIndependentShoulderOffset == 1) then
                        local genderCode = UnitSex("player");
                        factor = self.raceAndGenderToShoulderOffsetFactor["Human"][genderCode];
                    end

                    local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * factor;
                    return DynamicCam_wait(0.075, SetCVar, "test_cameraOverShoulder", correctedShoulderOffset);

                else
                    -- print("Changing into Worgen.");

                    -- The shoulder offset change will be performed by UNIT_MODEL_CHANGED.

                    -- Remember only that you are currently changing into Worgen
                    -- in case "Two Forms" is called again before change is complete.
                    self.changingIntoWorgen = true;
                end
            end
        end  -- (raceFile == "Worgen")


    -- Needed for Worgen form change.
    elseif (event == "UNIT_MODEL_CHANGED") then

        -- Only do something if UNIT_MODEL_CHANGED is for "player".
        local unitName = ...;
        if (unitName ~= "player") then
            return;
        end

        local _, raceFile = UnitRace("player");
        if ((raceFile == "Worgen")) then

            -- When logging in, there is also a call of UNIT_MODEL_CHANGED.
            -- But when we are mounted, we do not want this to have any effect
            -- on the shoulder offset.
            if (IsMounted()) then
                return;
            end

            -- When changing Worgen form, there are always two UNIT_MODEL_CHANGED calls.
            -- The first has (almost) the right timing to change the camera shoulder offset while
            -- turing from Human into Worgen. For turning from Worgen into Human, we need
            -- our own DynamicCam_wait timer started by UNIT_SPELLCAST_SUCCEEDED of "Two Forms".
            -- Thus, when turning from Worgen into Human, we completely suppress the first
            -- call of UNIT_MODEL_CHANGED. (When using "Two Forms" while chaning into Worgen
            -- we even have to skip the next two calls of UNIT_MODEL_CHANGED.)
            if (self.skipNextWorgenUnitModelChanged > 0) then
                -- print("Suppressing UNIT_MODEL_CHANGED because of skipNextWorgenUnitModelChanged == " .. self.skipNextWorgenUnitModelChanged);
                self.skipNextWorgenUnitModelChanged = self.skipNextWorgenUnitModelChanged - 1;

                -- This will eventually set the right model ID.
                self:SetLastWorgenModelId();

                return;
            end


            -- Try to determine the current form.
            local modelFrame = CreateFrame("PlayerModel");
            modelFrame:SetUnit("player");
            local modelId = modelFrame:GetModelFileID();

            -- print("UNIT_MODEL_CHANGED thinks you are");
            -- print(modelId);
            -- print("while lastWorgenModelId is");
            -- print(self.lastWorgenModelId);

            if (modelId == nil) then
                -- print("Using the opposite of lastWorgenModelId.");
                modelId = self:SwitchLastWorgenModelId();
            end

            -- print("Assuming you turn into");
            -- print(modelId);

            if ((modelId == self.modelId["Worgen"][2]) or (modelId == self.modelId["Worgen"][3])) then
                -- print("UNIT_MODEL_CHANGED ->Worgen");

                -- Remember that the change into Worgen is complete.
                self.changingIntoWorgen = false;

                -- As we are circumventing CorrectShoulderOffset(), we have to check the setting here!
                local factor = 1;
                if (self.db.profile.modelIndependentShoulderOffset == 1) then
                    local genderCode = UnitSex("player");
                    factor = self.raceAndGenderToShoulderOffsetFactor["Worgen"][genderCode];
                end

                -- This will eventually set the right model ID.
                self:SetLastWorgenModelId();

                local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * factor;
                -- TODO: In fact this is still a little bit too late! But if we want to set it earlier, we would have
                -- to capture every event that will force change from worgen into human... Is it possible?
                return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);

            else
                -- This should never happen except directly after logging in.
                -- print("UNIT_MODEL_CHANGED ->Human");

                -- As we are circumventing CorrectShoulderOffset(), we have to check the setting here!
                local factor = 1;
                if (self.db.profile.modelIndependentShoulderOffset == 1) then
                    local genderCode = UnitSex("player");
                    factor = self.raceAndGenderToShoulderOffsetFactor["Human"][genderCode];
                end

                -- This will eventually set the right model ID.
                self:SetLastWorgenModelId();

                local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * factor;
                return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);
            end

        end  -- (raceFile == "Worgen")

        -- print("...doing nothing!");


    -- To suppress Worgen UNIT_MODEL_CHANGED after loading screen.
    elseif (event == "LOADING_SCREEN_DISABLED") then

        local _, raceFile = UnitRace("player");
        if ((raceFile == "Worgen")) then
            self.skipNextWorgenUnitModelChanged = 3;
        end


    -- Needed for shapeshifting.
    elseif (event == "UPDATE_SHAPESHIFT_FORM") then

        local _, englishClass = UnitClass("player");
        if (englishClass == "SHAMAN") then

            if (GetShapeshiftFormID(true) ~= nil) then
                -- print("You are turning into Ghostwolf (" .. GetShapeshiftFormID(true) .. ").");

                -- -- The UPDATE_SHAPESHIFT_FORM while turning into Ghostwolf comes too early.
                -- -- And also the subsequent UNIT_MODEL_CHANGED is still too early.
                -- -- That is why we have to use the DynamicCam_wait timer instead.
                local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset);
                return DynamicCam_wait(0.025, SetCVar, "test_cameraOverShoulder", correctedShoulderOffset);

            else
                -- print("You are turning into normal Shaman!");

                -- Do not change the shoulder offset here.
                -- Wait until the next UNIT_AURA for perfect timing.
                self.activateNextUnitAura = true;

                -- TODO: Very rarely there are *two* UPDATE_SHAPESHIFT_FORM events while turning back into normal.
                -- If this happens, the second event is probably the one that should start a timer to update
                -- the shoulder offset, because then the next UNIT_AURA is too early. To fix this for good we
                -- would need a possibility to start timers like DynamicCam_wait and stop currently queued timers
                -- that have not been executed yet (DynamicCam_waitTable = {};).
                -- Then UPDATE_SHAPESHIFT_FORM could always stop the currently queued
                -- timers and start a new one.
                return;
            end
        -- end (englishClass == "SHAMAN")
        elseif (englishClass == "DRUID") then

            local _, raceFile = UnitRace("player");
            if ((raceFile == "Worgen")) then
                self.skipNextWorgenUnitModelChanged = 1;
            end


            local formId = GetShapeshiftFormID(true);
            if (formId ~= nil) then
                -- print("You are turning into something (" .. formId .. ").");

                -- When turning from druid into shapeshift, two UPDATE_SHAPESHIFT_FORM
                -- are executed, the first of which still gets formId == nil.
                -- So it will set activateNextUnitAura to true which we are revoking here.
                self.activateNextUnitAura = false;

                local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset);

                -- TODO: Still not happy with these transitions... :-(
                -- if (formId == 5) then
                    -- -- For bear this works quite reliable!
                    -- return DynamicCam_wait(0.05, SetCVar, "test_cameraOverShoulder", correctedShoulderOffset);
                -- end
                -- -- When turning from bear into another form, we have to clear the currently queued SetCVars
                -- -- such that the bear factor does not come afterwards.
                -- DynamicCam_waitTable = {};

                return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);

            else
                -- print("You are turning into normal Druid!");

                -- Do not change the shoulder offset here.
                -- Wait until the next UNIT_AURA for perfect timing.
                self.activateNextUnitAura = true;
                return;
            end
        end -- (englishClass == "DRUID")

        -- print("... doing nothing!");


    -- Needed for mounting and entering taxis.
    elseif (event == "PLAYER_MOUNT_DISPLAY_CHANGED") then
        if (IsMounted() == false) then

            -- print("PLAYER_MOUNT_DISPLAY_CHANGED: IsMounted() == false")

            local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset);

            -- Sometimes there is no SPELL_UPDATE_USABLE after leaving a taxi.
            -- But it is also not necessary to wait with setting the corrected value then.
            if (self.isOnTaxi) then
              self.isOnTaxi = false;
              return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);
            end

            -- Sometimes when being dismounted automatically while entering indoors there comes no
            -- SPELL_UPDATE_USABLE after PLAYER_MOUNT_DISPLAY_CHANGED...
            if (IsIndoors()) then
              return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);
            end


            -- Change the shoulder offset once here and then again with the next SPELL_UPDATE_USABLE.
            self.activateNextUnitAura = true;

            -- When shoulder offset is greater than 0, we need to set it to 10 times its actual value
            -- for the time between this PLAYER_MOUNT_DISPLAY_CHANGED and the next SPELL_UPDATE_USABLE.
            -- But only if modelIndependentShoulderOffset is enabled.
            if ((self.db.profile.modelIndependentShoulderOffset == 1) and (correctedShoulderOffset > 0)) then
                correctedShoulderOffset = correctedShoulderOffset * 10;
            end

            return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);
        else
            -- print("PLAYER_MOUNT_DISPLAY_CHANGED: IsMounted() == true")
            local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset);
            return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);
        end


    -- Needed to determine the right time to change shoulder offset when dismounting,
    -- changing from Shaman Ghostwolf into normal, from shapeshifted Druid into normal,
    -- and for Demon Hunter Metamorphosis.
    elseif (event == "UNIT_AURA") then

        -- Only do something if UNIT_AURA is for "player".
        local unitName = ...;
        if (unitName ~= "player") then
            return;
        end

        -- This is flag is set while dismounting, while changing from Ghostwolf into Shaman
        -- and while changing from shapeshifted into Druid.
        if (self.activateNextUnitAura == true) then
            self.activateNextUnitAura = false;
            -- print("UNIT_AURA executing!");
            local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset);
            return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);
        end



        -- We are also using UNIT_AURA to get the right timing for Demon Hunter Metamorphosis.
        -- Demon hunter always has to check for Metamorphosis.
        -- TODO: Mounting and dismounting while in Metamorphosis would have to be taken care of specifically.
        local _, englishClass = UnitClass("player");
        if (englishClass == "DEMONHUNTER") then

            -- Turning into Metamorphosis.
            for i = 1,40 do
                local name, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i);
                -- print (name, spellId);
                if (spellId == 162264) then
                    -- print("UNIT_AURA for METAMORPHOSIS HAVOC");
                    local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset);
                    return DynamicCam_wait(0.69, SetCVar, "test_cameraOverShoulder", correctedShoulderOffset);
                elseif (spellId == 187827) then
                    -- print("UNIT_AURA for METAMORPHOSIS VENGEANCE");
                    local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset);
                    return DynamicCam_wait(0.966, SetCVar, "test_cameraOverShoulder", correctedShoulderOffset);
                end
            end

            -- Turning into normal Demon Hunter.
            local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset);
            -- print("UNIT_AURA for DEMON HUNTER back to normal");
            -- return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);
            return DynamicCam_wait(0.082, SetCVar, "test_cameraOverShoulder", correctedShoulderOffset);

        end  -- (englishClass == "DEMONHUNTER")


        -- print("... doing nothing!");


    -- Needed for vehicles.
    elseif (event == "UNIT_ENTERING_VEHICLE") then
        local unitName, _, _, _, vehicleGuid = ...;
        -- print(unitName);
        -- print(vehicleGuid);

        -- Only do something if UNIT_ENTERING_VEHICLE is for "player".
        if (unitName ~= "player") then
            return;
        end

        local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset, vehicleGuid);
        return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);

    -- Needed for vehicles.
    elseif (event == "UNIT_EXITING_VEHICLE") then
        local unitName = ...;

        -- Only do something if UNIT_EXITING_VEHICLE is for "player".
        if (unitName ~= "player") then
            return;
        end

        local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset);
        return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);


    -- Needed for being teleported into a dungeon while mounted,
    -- because when entering you get automatically dismounted
    -- without PLAYER_MOUNT_DISPLAY_CHANGED being executed.
    elseif (event == "PLAYER_ENTERING_WORLD") then
        local correctedShoulderOffset = userSetShoulderOffset * shoulderOffsetZoomFactor * self:CorrectShoulderOffset(userSetShoulderOffset);
        return SetCVar("test_cameraOverShoulder", correctedShoulderOffset);
    end

end




function DynamicCam:RegisterEvents()

    -- Needed for Worgen form change.
    events["UNIT_SPELLCAST_SUCCEEDED"] = true;
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "ShoulderOffsetEventHandler");

    -- Needed for Worgen form change.
    events["UNIT_MODEL_CHANGED"] = true;
    self:RegisterEvent("UNIT_MODEL_CHANGED", "ShoulderOffsetEventHandler");

    -- To suppress Worgen UNIT_MODEL_CHANGED after loading screen.
    events["LOADING_SCREEN_DISABLED"] = true;
    self:RegisterEvent("LOADING_SCREEN_DISABLED", "ShoulderOffsetEventHandler");

    -- Needed for shapeshifting.
    events["UPDATE_SHAPESHIFT_FORM"] = true;
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "ShoulderOffsetEventHandler");

    -- Needed for mounting and entering taxis.
    events["PLAYER_MOUNT_DISPLAY_CHANGED"] = true;
    self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", "ShoulderOffsetEventHandler");

    -- Needed to determine the right time to change shoulder offset when dismounting,
    -- changing from Shaman Ghostwolf into normal, from shapeshifted Druid into normal,
    -- and for Demon Hunter Metamorphosis.
    events["UNIT_AURA"] = true;
    self:RegisterEvent("UNIT_AURA", "ShoulderOffsetEventHandler");

    -- Needed for vehicles.
    events["UNIT_ENTERING_VEHICLE"] = true;
    self:RegisterEvent("UNIT_ENTERING_VEHICLE", "ShoulderOffsetEventHandler");
    events["UNIT_EXITING_VEHICLE"] = true;
    self:RegisterEvent("UNIT_EXITING_VEHICLE", "ShoulderOffsetEventHandler");

    -- Needed for being teleported into a dungeon while mounted,
    -- because when entering you get automatically dismounted
    -- without PLAYER_MOUNT_DISPLAY_CHANGED being executed.
    events["PLAYER_ENTERING_WORLD"] = true;
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "ShoulderOffsetEventHandler");


    self:RegisterEvent("PLAYER_CONTROL_GAINED", "EventHandler");

    for situationID, situation in pairs(self.db.profile.situations) do
        self:RegisterSituationEvents(situationID);
    end
end

function DynamicCam:RegisterSituationEvents(situationID)
    local situation = self.db.profile.situations[situationID];
    if (situation and situation.events) then
        for i, event in pairs(situation.events) do
            if (not events[event]) then
                events[event] = true;
                self:RegisterEvent(event, "EventHandler");
                -- self:DebugPrint("Registered for event:", event);
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
    self:EvaluateSituations();
end

function DynamicCam:DC_BASE_CAMERA_UPDATED(message)
    self:ApplyDefaultCameraSettings();
end


--------------
-- DATABASE --
--------------
local firstDynamicCamLaunch = false;
local upgradingFromOldVersion = false;
StaticPopupDialogs["DYNAMICCAM_FIRST_RUN"] = {
    text = "Welcome to your first launch of DynamicCam!\n\nIt is highly suggested to load a preset to start, since the addon starts completely unconfigured.",
    button1 = "Open Presets",
    button2 = "Close",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    OnAccept = function()
        InterfaceOptionsFrame_OpenToCategory(Options.presets);
        InterfaceOptionsFrame_OpenToCategory(Options.presets);
    end,
    OnCancel = function(_, reason)
    end,
}

StaticPopupDialogs["DYNAMICCAM_FIRST_LOAD_PROFILE"] = {
    text = "The current DynamicCam profile is fresh and probably empty.\n\nWould you like to see available DynamicCam presets?",
    button1 = "Open Presets",
    button2 = "Close",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    OnAccept = function()
        InterfaceOptionsFrame_OpenToCategory(Options.presets);
        InterfaceOptionsFrame_OpenToCategory(Options.presets);
    end,
    OnCancel = function(_, reason)
    end,
}

StaticPopupDialogs["DYNAMICCAM_UPDATED"] = {
    text = "DynamicCam has been updated, would you like to open the main menu?\n\nThere's a changelog right in there! (You may need to scroll down)",
    button1 = "Open Menu",
    button2 = "Close",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    OnAccept = function()
        InterfaceOptionsFrame_OpenToCategory(Options.menu);
        InterfaceOptionsFrame_OpenToCategory(Options.menu);
    end,
}

function DynamicCam:InitDatabase()
    self.db = LibStub("AceDB-3.0"):New("DynamicCamDB", self.defaults, true);
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig");
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig");
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig");
    self.db.RegisterCallback(self, "OnDatabaseShutdown", "Shutdown");

    -- remove dbVersion, move to a per-profile version number
    if (self.db.global.dbVersion) then
        upgradingFromOldVersion = true;
        self.db.global.dbVersion = nil;
    end

    if (not DynamicCamDB.profiles) then
        firstDynamicCamLaunch = true;
    else
        -- reset db if we've got a really old version
        local veryOldVersion = false;
        for profileName, profile in pairs(DynamicCamDB.profiles) do
            if (profile.defaultCvars and profile.defaultCvars["cameraovershoulder"]) then
                veryOldVersion = true;
            end
        end

        if (veryOldVersion) then
            self:Print("Detected very old version, resetting DB, sorry about that!");
            self.db:ResetDB();
        end

        -- modernize each profile
        for profileName, profile in pairs(DynamicCamDB.profiles) do
            self:ModernizeProfile(profile);
        end

        -- show the updated popup
        if (upgradingFromOldVersion) then
            StaticPopup_Show("DYNAMICCAM_UPDATED");
        end
    end
end

function DynamicCam:ModernizeProfile(profile)
    if (not profile.version) then
        profile.version = 1;
    end

    local startVersion = profile.version;

    if (profile.version == 1) then
        if (profile.defaultCvars and profile.defaultCvars["test_cameraLockedTargetFocusing"] ~= nil) then
            profile.defaultCvars["test_cameraLockedTargetFocusing"] = nil;
        end

        upgradingFromOldVersion = true;
        profile.version = 2;
        profile.firstRun = false;
    end

    -- modernize each situation
    if (profile.situations) then
        for situationID, situation in pairs(profile.situations) do
            self:ModernizeSituation(situation, startVersion);
        end
    end
end

function DynamicCam:ModernizeSituation(situation, version)
    if (version == 1) then
        -- clear unused nameplates db stuff
        if (situation.extras) then
            situation.extras["nameplates"] = nil;
            situation.extras["friendlyNameplates"] = nil;
            situation.extras["enemyNameplates"] = nil;
        end

        -- update targetlock features
        if (situation.targetLock) then
            if (situation.targetLock.enabled) then
                if (not situation.cameraCVars) then
                    situation.cameraCVars = {};
                end

                if (situation.targetLock.onlyAttackable ~= nil and situation.targetLock.onlyAttackable == false) then
                    situation.cameraCVars["test_cameraTargetFocusEnemyEnable"] = 1;
                    situation.cameraCVars["test_cameraTargetFocusInteractEnable"] = 1
                else
                    situation.cameraCVars["test_cameraTargetFocusEnemyEnable"] = 1;
                end
            end

            situation.targetLock = nil;
        end

        -- update camera rotation
        if (situation.cameraActions) then
            -- convert to yaw degrees instead of rotate degrees
            if (situation.cameraActions.rotateDegrees) then
                situation.cameraActions.yawDegrees = situation.cameraActions.rotateDegrees;
                situation.cameraActions.pitchDegrees = 0;
                situation.cameraActions.rotateDegrees = nil;
            end

            -- convert old scalar rotate speed to something that's in degrees/second
            if (situation.cameraActions.rotateSpeed and situation.cameraActions.rotateSpeed < 5) then
                situation.cameraActions.rotateSpeed = situation.cameraActions.rotateSpeed * tonumber(GetCVar("cameraYawMoveSpeed"));
            end
        end
    end
end

function DynamicCam:RefreshConfig()
    local profile = self.db.profile;

    -- shutdown the addon if it's enabled
    if (profile.enabled and started) then
        self:Shutdown();
    end

    -- situation is active, but db killed it
    if (self.currentSituationID) then
        self.currentSituationID = nil;
    end

    -- clear the options panel so that it reselects
    -- make sure that options panel selects a situation
    if (Options) then
        Options:ClearSelection();
        Options:SelectSituation();
    end

    -- present a menu that loads a set of defaults, if this is the profiles first run
    if (profile.firstRun) then
        if (firstDynamicCamLaunch) then
            StaticPopup_Show("DYNAMICCAM_FIRST_RUN");
            firstDynamicCamLaunch = false;
        else
            StaticPopup_Show("DYNAMICCAM_FIRST_LOAD_PROFILE");
        end
        profile.firstRun = false;
    end

    -- start the addon back up
    if (profile.enabled and not started) then
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
local function tokenize(str, delimitor)
    local tokens = {};
    for token in str:gmatch(delimitor or "%S+") do
        table.insert(tokens, token);
    end
    return tokens;
end

StaticPopupDialogs["DYNAMICCAM_NEW_CUSTOM_SITUATION"] = {
    text = "Enter name for custom situation:",
    button1 = "Create!",
    button2 = "Cancel",
    timeout = 0,
    hasEditBox = true,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    OnShow = function (self, data)
        self.editBox:SetFocus();
    end,
    OnAccept = function (self, data)
        DynamicCam:CreateCustomSituation(self.editBox:GetText());
    end,
    EditBoxOnEnterPressed = function(self)
        DynamicCam:CreateCustomSituation(self:GetParent().editBox:GetText());
    self:GetParent():Hide();
  end,
}

local exportString;
StaticPopupDialogs["DYNAMICCAM_EXPORT"] = {
    text = "DynamicCam Export:",
    button1 = "Done!",
    timeout = 0,
    hasEditBox = true,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
    OnShow = function (self, data)
        self.editBox:SetText(exportString);
        self.editBox:HighlightText();
    end,
    EditBoxOnEnterPressed = function(self)
    self:GetParent():Hide();
  end,
}

function DynamicCam:OpenMenu(input)
    if (not Options) then
        Options = self.Options;
    end

    Options:SelectSituation();

    -- just open to the frame, double call because blizz bug
    InterfaceOptionsFrame_OpenToCategory(Options.menu);
    InterfaceOptionsFrame_OpenToCategory(Options.menu);
end

function DynamicCam:SaveViewCC(input)
    local tokens = tokenize(input);

    local viewNum = tonumber(tokens[1]);

    if (viewNum and viewNum <= 5 and viewNum > 1) then
        SaveView(viewNum);
    else
        self:Print("Improper view number provided.")
    end
end

function DynamicCam:ZoomInfoCC(input)
    self:Print(string.format("Zoom level: %0.2f", GetCameraZoom()));
end

function DynamicCam:ZoomSlash(input)
    local tokens = tokenize(input);

    local zoom = tonumber(tokens[1]);
    local time = tonumber(tokens[2]);
    local easingFuncName;
    local easingFunc;

    if (not time) then
        -- time not provided, maybe 2nd param is easingfunc?
        easingFuncName = tokens[2];
    else
        easingFuncName = tokens[3];
    end

    -- look up easing func
    if (easingFuncName) then
        easingFunc = LibEasing[easingFuncName] or LibEasing.InOutQuad;
    end

    if (zoom and (zoom <= 39 or zoom >= 0)) then
        local defaultTime = math.abs(zoom - GetCameraZoom()) / tonumber(GetCVar("cameraZoomSpeed"));
        LibCamera:SetZoom(zoom, time or math.min(defaultTime, 0.75), easingFunc);
    end
end

function DynamicCam:PitchSlash(input)
    local tokens = tokenize(input);

    local pitch = tonumber(tokens[1]);
    local time = tonumber(tokens[2]);
    local easingFuncName;
    local easingFunc;

    if (not time) then
        -- time not provided, maybe 2nd param is easingfunc?
        easingFuncName = tokens[2];
    else
        easingFuncName = tokens[3];
    end

    -- look up easing func
    if (easingFuncName) then
        easingFunc = LibEasing[easingFuncName] or LibEasing.InOutQuad;
    end

    if (pitch and (pitch <= 90 or pitch >= -90)) then
        LibCamera:Pitch(pitch, time or 0.75, easingFunc);
    end
end

function DynamicCam:YawSlash(input)
    local tokens = tokenize(input);

    local yaw = tonumber(tokens[1]);
    local time = tonumber(tokens[2]);
    local easingFuncName;
    local easingFunc;

    if (not time) then
        -- time not provided, maybe 2nd param is easingfunc?
        easingFuncName = tokens[2];
    else
        easingFuncName = tokens[3];
    end

    -- look up easing func
    if (easingFuncName) then
        easingFunc = LibEasing[easingFuncName] or LibEasing.InOutQuad;
    end

    if (yaw) then
        LibCamera:Yaw(yaw, time or 0.75, easingFunc);
    end
end

function DynamicCam:PopupCreateCustomProfile()
    StaticPopup_Show("DYNAMICCAM_NEW_CUSTOM_SITUATION");
end

function DynamicCam:PopupExport(str)
    exportString = str;
    StaticPopup_Show("DYNAMICCAM_EXPORT");
end

function DynamicCam:PopupExportProfile()
    self:PopupExport(self:ExportProfile())
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
