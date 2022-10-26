---------------
-- LIBRARIES --
---------------
local LibCamera = LibStub("LibCamera-1.0")

-------------
-- GLOBALS --
-------------
assert(DynamicCam)
DynamicCam.Options = DynamicCam:NewModule("Options", "AceEvent-3.0")


------------
-- LOCALS --
------------
local function ScriptEqual(customScript, defaultScript)
    if (customScript == "" and defaultScript == nil) or customScript == defaultScript then return true end
end


local function EventsEqual(customEvents, defaultEvents)
    local customEventsCheck = {}
    local defaultEventsCheck = {}

    for k, v in pairs(customEvents) do
        customEventsCheck[v] = true
    end

    for k, v in pairs(defaultEvents) do
        if not customEventsCheck[v] then
            return false
        end
        defaultEventsCheck[v] = true
    end

    for k, v in pairs(customEvents) do
        if not defaultEventsCheck[v] then
            return false
        end
    end

    return true
end



local Options = DynamicCam.Options
local parent = DynamicCam
local _
local S, SID
local copiedSituationID
local exportName, exportAuthor

local welcomeMessage = [[Hello and welcome to DynamicCam!

We're glad that you're here and we hope that you have fun with the addon.

If you find a problem or want to make a suggestion, please, please leave a note in the Curse comments or use the Issues on GitHub. If you'd like to contribute, also feel free to open a pull request there.

Some handy slash commands:
    `/dynamiccam` or `/dc` will open this menu
    `/zoominfo` or `/zi` will print out the current zoom
    `/saveview #` or `/sv #` will save to the specified view slot (where # is a number between 2 and 5)

    The following slash commands will also accept a time and an easing function:
        `/zoom #` will zoom to that zoom level
        `/yaw #` will yaw the camera left/right by that number of degrees
        `/pitch #` will pitch the camera up/down by that number of degrees

        Example:
            `/zoom 5 5 InOutQuint` will zoom to 5 over 5 seconds using InOutQuint as the easing function.
    ]]


local easingValues = {
    Linear = "Linear",
    InQuad = "In Quadratic",
    OutQuad = "Out Quadratic",
    InOutQuad = "In/Out Quadratic",
    OutInQuad = "Out/In Quadratic",
    InCubic = "In Cubic",
    OutCubic = "Out Cubic",
    InOutCubic = "In/Out Cubic",
    OutInCubic = "Out/In Cubic",
    InQuart = "In Quartic",
    OutQuart = "Out Quartic",
    InOutQuart = "In/Out Quartic",
    OutInQuart = "Out/In Quartic",
    InQuint = "In Quintic",
    OutQuint = "Out Quintic",
    InOutQuint = "In/Out Quintic",
    OutInQuint = "Out/In Quintic",
    InSine = "In Sine",
    OutSine = "Out Sine",
    InOutSine = "In/Out Sine",
    OutInSine = "Out/In Sine",
    InExpo = "In Exponent",
    OutExpo = "Out Exponent",
    InOutExpo = "In/Out Exponent",
    OutInExpo = "Out/In Exponent",
    InCirc = "In Circular",
    OutCirc = "Out Circular",
    InOutCirc = "In/Out Circular",
    OutInCirc = "Out/In Circular",
}

local general = {
    name = "DynamicCam",
    handler = DynamicCam,
    type = 'group',
    args = {
        general = {
            type = 'group',
            name = "General",
            order = 1,
            inline = true,
            args = {
                enable = {
                    type = 'toggle',
                    name = "Enable",
                    desc = "If the addon is enabled.",
                    get = "IsEnabled",
                    set = function(_, newValue) if not newValue then DynamicCam:Disable(); else DynamicCam:Enable(); end end,
                    order = 1,
                    width = "half",
                },
                actionCam = {
                    type = 'toggle',
                    name = "Use ActionCam",
                    desc = "Enables ActionCam features in DynamicCam.\n\nActionCam is an experimental set of features that Blizzard has included in the game for advanced users and these features may cause some motion sickness.\n\nEnabling this feature disables the standard Blizzard reset notification.",
                    get = function() return DynamicCam.db.profile.actionCam; end,
                    set = function(_, newValue) DynamicCam.db.profile.actionCam = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID); end,
                    --width = "half",
                    order = 2,
                },
                advanced = {
                    type = 'toggle',
                    name = "Advanced Mode",
                    desc = "If you would like to see advanced options, like editing the Lua conditions of situations.",
                    get = function() return DynamicCam.db.profile.advanced; end,
                    set = function(_, newValue) DynamicCam.db.profile.advanced = newValue; end,
                    --width = "half",
                    order = 3,
                },
                -- debugMode = {
                    -- type = 'toggle',
                    -- name = "Debug",
                    -- desc = "Print out debug messages to the chat window.",
                    -- get = function() return DynamicCam.db.profile.debugMode; end,
                    -- set = function(_, newValue) DynamicCam.db.profile.debugMode = newValue; end,
                    -- width = "half",
                    -- order = 4,
                -- },

            },
        },
        messageGroup = {
            type = 'group',
            name = "Welcome!",
            order = 5,
            inline = true,
            args = {
                message = {
                    type = 'description',
                    name = welcomeMessage,
                    fontSize = "small",
                    width = "full",
                    order = 1,
                },
            }
        },
    },
}
local settings = {
    name = "Settings",
    handler = DynamicCam,
    type = 'group',
    args = {
        reactiveZoom = {
            type = 'group',
            name = "Reactive Zoom",
            order = 1,
            inline = true,
            args = {
                reactiveZoomEnabled = {
                    type = 'toggle',
                    name = "Enabled",
                    desc = "Speed up zoom when manually zooming in quickly.",
                    get = function() return (DynamicCam.db.profile.reactiveZoom.enabled) end,
                    set = function(_, newValue)
                        DynamicCam.db.profile.reactiveZoom.enabled = newValue

                        -- actually turn it on
                        if newValue then
                            DynamicCam:ReactiveZoomOn()
                        else
                            DynamicCam:ReactiveZoomOff()
                        end
                    end,
                    order = 1,
                },
                reactiveZoomAdvanced = {
                    type = 'group',
                    name = "Reactive Zoom Options (Advanced)",
                    hidden = function() return (not DynamicCam.db.profile.advanced) or (not DynamicCam.db.profile.reactiveZoom.enabled) end,
                    order = 2,
                    inline = true,
                    args = {
                        maxZoomTime = {
                            type = 'range',
                            name = "Max Manual Zoom Time",
                            desc = "The most time that the camera will take to adjust to a manually set zoom.",
                            min = .1,
                            max = 2,
                            step = .05,
                            get = function() return (DynamicCam.db.profile.reactiveZoom.maxZoomTime) end,
                            set = function(_, newValue) DynamicCam.db.profile.reactiveZoom.maxZoomTime = newValue; end,
                            order = 2,
                            width = "full",
                        },
                        addIncrementsAlways = {
                            type = 'range',
                            name = "Zoom Increments",
                            desc = "The amount of distance that the camera should travel for each \'tick\' of the mousewheel.",
                            min = 1,
                            max = 5,
                            step = .25,
                            get = function() return (DynamicCam.db.profile.reactiveZoom.addIncrementsAlways + 1) end,
                            set = function(_, newValue) DynamicCam.db.profile.reactiveZoom.addIncrementsAlways = newValue - 1; end,
                            order = 3,
                        },
                        addIncrements = {
                            type = 'range',
                            name = "Additional Increments",
                            desc = "When manually zooming quickly, add this amount of additional increments per \'tick\' of the mousewheel.",
                            min = 0,
                            max = 5,
                            step = .25,
                            get = function() return (DynamicCam.db.profile.reactiveZoom.addIncrements) end,
                            set = function(_, newValue) DynamicCam.db.profile.reactiveZoom.addIncrements = newValue; end,
                            order = 4,
                        },
                        incAddDifference = {
                            type = 'range',
                            name = "Zooming Quickly (Difference)",
                            desc = "The amount of ground that the camera needs to make up before it is considered to be moving quickly. Higher is harder to achieve.",
                            min = 2,
                            max = 5,
                            step = .5,
                            get = function() return (DynamicCam.db.profile.reactiveZoom.incAddDifference) end,
                            set = function(_, newValue) DynamicCam.db.profile.reactiveZoom.incAddDifference = newValue; end,
                            order = 5,
                        },
                        easingFunc = {
                            type = 'select',
                            name = "Easing Function",
                            desc = "Which easing function to use. It is highly recommended to use an \'Out\'-type function!",
                            hidden = true,
                            get = function() return (DynamicCam.db.profile.reactiveZoom.easingFunc) end,
                            set = function(_, newValue) DynamicCam.db.profile.reactiveZoom.easingFunc = newValue; end,
                            values = easingValues,
                            width = "full",
                            order = 6,
                        },
                    },
                },
            },
        },
        defaultEasing = {
            type = 'group',
            name = "Default Easing Functions (Advanced)",
            hidden = function() return (not DynamicCam.db.profile.advanced) end,
            order = 2,
            inline = true,
            args = {
                easingZoom = {
                    type = 'select',
                    name = "Zoom Easing",
                    desc = "Which easing function to use for zoom.",
                    hidden = true,
                    get = function() return (DynamicCam.db.profile.easingZoom) end,
                    set = function(_, newValue) DynamicCam.db.profile.easingZoom = newValue; end,
                    values = easingValues,
                    order = 1,
                },
                easingYaw = {
                    type = 'select',
                    name = "Yaw Easing",
                    desc = "Which easing function to use for yaw.",
                    get = function() return (DynamicCam.db.profile.easingYaw) end,
                    set = function(_, newValue) DynamicCam.db.profile.easingYaw = newValue; end,
                    values = easingValues,
                    order = 2,
                },
                easingPitch = {
                    type = 'select',
                    name = "Pitch Easing",
                    desc = "Which easing function to use for pitch.",
                    get = function() return (DynamicCam.db.profile.easingPitch) end,
                    set = function(_, newValue) DynamicCam.db.profile.easingPitch = newValue; end,
                    values = easingValues,
                    order = 3,
                },
            },
        },
        defaultCvars = {
            type = 'group',
            name = "Default Camera Settings",
            order = 3,
            inline = true,
            args = {
                description = {
                    type = 'description',
                    name = "Settings here are only applied if the currently active situation doesn't modify the settings. Think of these settings as the \"fallback\".\n",
                    hidden = function() return (not DynamicCam.db.profile.actionCam) end,
                    --fontSize = "small",
                    width = "full",
                    order = 0,
                },
                cameraDynamicPitch = {
                    type = 'toggle',
                    name = "Dynamic Pitch",
                    desc = "The camera will adjust the camera's pitch (the angle at which the camera looks at your character in the up/down direction) according to the current zoom level.\n\nAngles the camera up while farther away from the character and down coming towards your character.",
                    hidden = function() return (not DynamicCam.db.profile.actionCam) end,
                    get = function() return (DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitch"] == 1) end,
                    set = function(_, newValue) if newValue then DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitch"] = 1; else DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitch"] = 0; end Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                    order = .25,
                },
                cameraDistanceMaxFactor = {
                    type = 'range',
                    name = "Camera Max Distance",
                    desc = "How far away from your character the camera can get.",
                    min = 15,
                    max = 39,
                    step = .5,
                    get = function() return (15*DynamicCam.db.profile.defaultCvars["cameraDistanceMaxZoomFactor"]) end,
                    set = function(_, newValue) DynamicCam.db.profile.defaultCvars["cameraDistanceMaxZoomFactor"] = newValue/15; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                    order = 2,
                    width = "full",
                },
                cameraZoomSpeed = {
                    type = 'range',
                    name = "Camera Move Speed",
                    desc = "How fast the camera can zoom in/out.",
                    min = 1,
                    max = 50,
                    step = .5,
                    get = function() return DynamicCam.db.profile.defaultCvars["cameraZoomSpeed"] end,
                    set = function(_, newValue) DynamicCam.db.profile.defaultCvars["cameraZoomSpeed"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                    order = 3,
                    width = "full",
                },
                cameraOverShoulder = {
                    type = 'range',
                    name = "Camera Shoulder Offset",
                    desc = "Moves the camera left or right from your character, negative values are to the left, postive to the right",
                    hidden = function() return (not DynamicCam.db.profile.actionCam) end,
                    min = -15,
                    max = 15,
                    step = .1,
                    get = function() return DynamicCam.db.profile.defaultCvars["test_cameraOverShoulder"] end,
                    set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraOverShoulder"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                    order = 4,
                    width = "full",
                },
                cameraHeadMovementStrength = {
                    type = 'range',
                    name = "Head Movement Strength",
                    desc = "If above 0, the camera will move to follow your character's head movements, tracking it forward, back, left and right. The strength controls how much it follows the head.\n\nThis can cause some nausea if you are prone to motion sickness.",
                    hidden = function() return (not DynamicCam.db.profile.actionCam) end,
                    min = 0,
                    max = 100,
                    softMax = 2,
                    step = .5,
                    get = function() return DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementStrength"] end,
                    set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementStrength"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                    order = 5,
                    width = "full",
                },
                shoulderOffsetZoomGroup = {
                    type = 'group',
                    name = "Adjust shoulder offset according to zoom level",
                    order = 10,
                    inline = true,
                    args = {
                        shoulderOffsetZoomEnabled = {
                            type = 'toggle',
                            name = "Enable",
                            desc = "When enabled the Camera Shoulder Offset will gradually change towards zero as you zoom-in on your character.",
                            get = function() return DynamicCam.db.profile.shoulderOffsetZoom.enabled end,
                            set = function(_, newValue)
                                DynamicCam.db.profile.shoulderOffsetZoom.enabled = newValue
                                DynamicCam:ZoomSlash(GetCameraZoom() .. " " .. 0)
                            end,
                            order = 1,
                        },
                        shoulderOffsetZoomLowerBound = {
                            type = 'range',
                            name = "Zero when below:",
                            desc = "When you are closer than this zoom level, the Camera Shoulder Offset will be zero.",
                            min = 0,
                            max = 39,
                            step = 1,
                            hidden = function() return not DynamicCam.db.profile.shoulderOffsetZoom.enabled end,
                            get = function() return DynamicCam.db.profile.shoulderOffsetZoom.lowerBound end,
                            set = function(_, newValue)
                                DynamicCam.db.profile.shoulderOffsetZoom.lowerBound = newValue
                                if DynamicCam.db.profile.shoulderOffsetZoom.upperBound < newValue then
                                    DynamicCam.db.profile.shoulderOffsetZoom.upperBound = newValue
                                end
                                DynamicCam:ZoomSlash(GetCameraZoom() .. " " .. 0)
                            end,
                            order = 2,
                        },
                        shoulderOffsetZoomUpperBound = {
                            type = 'range',
                            name = "Normal when above:",
                            desc = "When you are further away than this zoom level, the Camera Shoulder Offset will have its normal value.",
                            min = 0,
                            max = 39,
                            step = 1,
                            hidden = function() return not DynamicCam.db.profile.shoulderOffsetZoom.enabled end,
                            get = function() return DynamicCam.db.profile.shoulderOffsetZoom.upperBound end,
                            set = function(_, newValue)
                                DynamicCam.db.profile.shoulderOffsetZoom.upperBound = newValue
                                if DynamicCam.db.profile.shoulderOffsetZoom.lowerBound > newValue then
                                    DynamicCam.db.profile.shoulderOffsetZoom.lowerBound = newValue
                                end
                                DynamicCam:ZoomSlash(GetCameraZoom() .. " " .. 0)
                            end,
                            order = 3,
                        },
                    },
                },
                targetLockGroup = {
                    type = 'group',
                    name = "Target Lock/Focus",
                    order = 50,
                    inline = true,
                    args = {
                        targetLockEnemies = {
                            type = 'toggle',
                            name = "Focus Enemies",
                            desc = "Lock/focus enemies. This includes both dead enemies, and targets that have gone offscreen.\n\nA gray checkbox means that the default will be used instead.",
                            get = function() return (DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyEnable"] == 1) end,
                            set = function(_, newValue)
                                if newValue then
                                    DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyEnable"] = 1
                                else
                                    DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyEnable"] = 0
                                end

                                Options:SendMessage("DC_BASE_CAMERA_UPDATED")
                            end,
                            order = 1,
                        },
                        targetLockEnemiesPitch = {
                            type = 'range',
                            name = "Focus Enemy Pitch Strength (Advanced)",
                            desc = "",
                            min = 0,
                            max = 1,
                            step = .05,
                            hidden = function()
                                return ((not DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyEnable"])
                                    or (DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyEnable"] == 0)
                                    or (not DynamicCam.db.profile.advanced))
                            end,
                            get = function()
                                return (DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyStrengthPitch"]
                                    or tonumber(GetCVarDefault("test_cameraTargetFocusEnemyStrengthPitch")))
                            end,
                            set = function(_, newValue)
                                DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyStrengthPitch"] = newValue
                                Options:SendMessage("DC_BASE_CAMERA_UPDATED")
                            end,
                            width = "full",
                            order = 2,
                        },
                        targetLockEnemiesYaw = {
                            type = 'range',
                            name = "Focus Enemy Yaw Strength (Advanced)",
                            desc = "",
                            min = 0,
                            max = 1,
                            step = .05,
                            hidden = function()
                                return ((not DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyEnable"])
                                    or (DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyEnable"] == 0)
                                    or (not DynamicCam.db.profile.advanced))
                            end,
                            get = function()
                                return (DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyStrengthYaw"]
                                    or tonumber(GetCVarDefault("test_cameraTargetFocusEnemyStrengthYaw")))
                            end,
                            set = function(_, newValue)
                                DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyStrengthYaw"] = newValue
                                Options:SendMessage("DC_BASE_CAMERA_UPDATED")
                            end,
                            width = "full",
                            order = 3,
                        },
                        targetLockInteractables = {
                            type = 'toggle',
                            tristate = true,
                            name = "Focus On Interact",
                            desc = "Lock/focus NPCs in interactions\n\nA gray checkbox means that the default will be used instead.",
                            get = function() return (DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractEnable"] == 1) end,
                            set = function(_, newValue)
                                if newValue then
                                    DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractEnable"] = 1
                                else
                                    DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractEnable"] = 0
                                end

                                Options:SendMessage("DC_BASE_CAMERA_UPDATED")
                            end,
                            order = 11,
                        },
                        targetLockInteractPitch = {
                            type = 'range',
                            name = "Focus Interact Pitch Strength (Advanced)",
                            desc = "",
                            min = 0,
                            max = 1,
                            step = .05,
                            hidden = function()
                                return ((not DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractEnable"])
                                    or (DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractEnable"] == 0)
                                    or (not DynamicCam.db.profile.advanced))
                            end,
                            get = function()
                                return (DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractStrengthPitch"]
                                    or tonumber(GetCVarDefault("test_cameraTargetFocusInteractStrengthPitch")))
                            end,
                            set = function(_, newValue)
                                DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractStrengthPitch"] = newValue
                                Options:SendMessage("DC_BASE_CAMERA_UPDATED")
                            end,
                            width = "full",
                            order = 12,
                        },
                        targetLockInteractYaw = {
                            type = 'range',
                            name = "Focus Interact Yaw Strength (Advanced)",
                            desc = "",
                            min = 0,
                            max = 1,
                            step = .05,
                            hidden = function()
                                return ((not DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractEnable"])
                                    or (DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractEnable"] == 0)
                                    or (not DynamicCam.db.profile.advanced))
                            end,
                            get = function()
                                return (DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractStrengthYaw"]
                                    or tonumber(GetCVarDefault("test_cameraTargetFocusInteractStrengthYaw")))
                            end,
                            set = function(_, newValue)
                                DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractStrengthYaw"] = newValue
                                Options:SendMessage("DC_BASE_CAMERA_UPDATED")
                            end,
                            width = "full",
                            order = 13,
                        },
                    },
                },
                dynamicPitchAdvanced = {
                    type = 'group',
                    name = "Dynamic Pitch Settings (Advanced)",
                    order = 102,
                    inline = true,
                    hidden = function() return (not DynamicCam.db.profile.advanced) or (not DynamicCam.db.profile.actionCam) end,
                    args = {
                        baseFovPad = {
                            type = 'range',
                            name = "Base FOV Pad",
                            desc = "This seems to adjust how far the camera is pitched up or down.\n\nSmaller values pitch up away from the ground while larger values pitch down towards the ground.",
                            min = .01,
                            max = 1,
                            step = .01,
                            get = function() return DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitchBaseFovPad"] end,
                            set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitchBaseFovPad"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                            order = 1,
                        },
                        baseFovPadFlying = {
                            type = 'range',
                            name = "Base FOV Pad (Flying)",
                            desc = "This seems to adjust how far the camera is pitched up or down.\n\nSmaller values pitch up away from the ground while larger values pitch down towards the ground.\n\nThis is presumbly for when you are flying.",
                            min = .01,
                            max = 1,
                            step = .01,
                            get = function() return DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitchBaseFovPadFlying"] end,
                            set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitchBaseFovPadFlying"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                            order = 2,
                        },
                        baseFovPadDownScale = {
                            type = 'range',
                            name = "Base FOV Pad Downscale",
                            desc = "Likely a multiplier for how much pitch is applied. Higher values allow the character to be 'further' down the screen.",
                            min = .0,
                            max = 1,
                            step = .01,
                            get = function() return DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitchBaseFovPadDownScale"] end,
                            set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitchBaseFovPadDownScale"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                            order = 3,
                        },
                        smartPivotCutoffDist = {
                            type = 'range',
                            name = "Smart Pivot Cutoff Distance",
                            -- Thanks to Jordaldo for providing this tooltip info.
                            -- https://github.com/Mpstark/DynamicCam/issues/14
                            desc = "Defines the distance that the camera has to be inside of for the ground collision to either bring the camera closer to the character's feet as the camera collides with the ground, or to simply pivot on the spot of camera-to-ground collision.",
                            min = 0,
                            max = 100,
                            softMin = 0,
                            softMax = 39,
                            step = .5,
                            get = function() return DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitchSmartPivotCutoffDist"] end,
                            set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitchSmartPivotCutoffDist"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                            order = 4,
                        },
                    },
                },
                headTrackingAdvanced = {
                    type = 'group',
                    name = "Head Tracking Settings (Advanced)",
                    order = 103,
                    hidden = function() return (not DynamicCam.db.profile.advanced) or (not DynamicCam.db.profile.actionCam) end,
                    inline = true,
                    args = {
                        rangeScale = {
                            type = 'range',
                            name = "Range Scale",
                            desc = "Higher this scale is, the farther away the camera can be away from the character while still maintaining head movement.",
                            min = 0,
                            max = 50,
                            step = .5,
                            get = function() return DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementRangeScale"] end,
                            set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementRangeScale"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                            order = 1,
                        },
                        movingStrength = {
                            type = 'range',
                            name = "Moving Strength",
                            desc = "Probably a multiplier.\n\nHard max at 50, adjust using editbox.",
                            min = 0,
                            softMax = 2,
                            max = 50,
                            step = .01,
                            get = function() return DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementMovingStrength"] end,
                            set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementMovingStrength"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                            order = 2,
                        },
                        standingStrength = {
                            type = 'range',
                            name = "Standing Strength",
                            desc = "Probably a multiplier.\n\nHard max at 50, adjust using editbox.",
                            min = 0,
                            softMax = 2,
                            max = 50,
                            step = .01,
                            get = function() return DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementStandingStrength"] end,
                            set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementStandingStrength"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                            order = 3,
                        },
                        movingDampRate = {
                            type = 'range',
                            name = "Moving Damp Rate",
                            desc = "Higher values seems to 'loosen' the spring and make head movement more apparent.\n\nHard min at ~0.01, adjust using editbox.",
                            min = 0.01,
                            softMin = 1,
                            max = 50,
                            step = 1,
                            get = function() return DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementMovingDampRate"] end,
                            set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementMovingDampRate"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                            order = 4,
                        },
                        standingDampRate = {
                            type = 'range',
                            name = "Standing Damp Rate",
                            desc = "Higher values seems to 'loosen' the spring and make head movement more apparent.\n\nHard min at ~0.01, adjust using editbox.",
                            min = 0.01,
                            softMin = 1,
                            max = 50,
                            step = 1,
                            get = function() return DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementStandingDampRate"] end,
                            set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementStandingDampRate"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                            order = 5,
                        },
                        firstPersonDampRate = {
                            type = 'range',
                            name = "1st Person Damp Rate",
                            desc = "Higher values seems to 'loosen' the spring and make head movement more apparent.\n\nHard min at ~0.01, adjust using editbox.",
                            min = 0.01,
                            softMin = 1,
                            max = 50,
                            step = 1,
                            get = function() return DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementFirstPersonDampRate"] end,
                            set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementFirstPersonDampRate"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                            order = 6,
                        },
                        deadZone = {
                            type = 'range',
                            name = "Dead Zone",
                            desc = "No concrete description yet.\n\nHard max at 50, use editbox to change.",
                            min = 0,
                            softMax = 1,
                            max = 50,
                            step = .01,
                            get = function() return DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementDeadZone"] end,
                            set = function(_, newValue) DynamicCam.db.profile.defaultCvars["test_cameraHeadMovementDeadZone"] = newValue; Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                            order = 7,
                            width = "full"
                        },
                    },
                },
            },
        },
    },
}
local situationOptions = {
    type = 'group',
    name = "Situation Options",
    handler = DynamicCam,
    args = {
        zoomRestoreSettingGroup = {
            type = 'group',
            name = "Restore Zoom",
            order = 0,
            inline = true,
            args = {
                zoomRestoreSettingDescription = {
                    type = 'description',
                    name = "When you leave a situation (or leave the default of no situation being active), the current zoom level is temporarily stored, such that it can be restored once you return to that situation. These are the options:\n\nNever: The zoom is never restored. I.e. when you enter a situation, no stored zoom is taken into account, but the zoom setting from the situation's options (if any) is applied.\n\nAlways: When entering a situation, the stored zoom (if any) is always restored.\n\nAdaptive: This only restores the zoom level under certain circumstances. E.g. only when returning to the same situation you came from or when the stored zoom fulfills the criteria of the situation's \"in\", \"out\" or \"range\" zoom settings.",
                    order = 0,
                },
                zoomRestoreSetting = {
                    type = 'select',
                    name = "",
                    get = function() return DynamicCam.db.profile.zoomRestoreSetting end,
                    set = function(_, newValue) DynamicCam.db.profile.zoomRestoreSetting = newValue end,
                    values = {["adaptive"] = "Adaptive", ["always"] = "Always", ["never"] = "Never"},
                    order = 1,
                },
            },
        },
        selectedSituation = {
            type = 'select',
            name = "Selected Situation",
            desc = "Which situation you are editing",
            get = function() return SID end,
            set = function(_, newValue) S = DynamicCam.db.profile.situations[newValue]; SID = newValue; end,
            values = "GetSituationList",
            width = "full",
            order = 1,
        },
        newSituation = {
            type = 'execute',
            name = "New Custom Situation (Advanced)",
            desc = "Create a new custom situation.",
            hidden = function() return (not DynamicCam.db.profile.advanced) end,
            func = function() DynamicCam:PopupCreateCustomProfile() end,
            order = 1.5,
            width = "full",
        },
        enabled = {
            type = 'toggle',
            name = "Enable Situation",
            desc = "If this situation should be checked and activated",
            hidden = function() return (not S) end,
            get = function() return S.enabled end,
            set = function(_, newValue) S.enabled = newValue if newValue then Options:SendMessage("DC_SITUATION_ENABLED") else Options:SendMessage("DC_SITUATION_DISABLED") end end,
            order = 2,
        },
        copy = {
            type = 'execute',
            name = "Copy",
            desc = "Copy this situations settings so that you can paste it into another situation.\n\nDoesn't copy the condition or the advanced mode Lua scripts.",
            hidden = function() return (not S) end,
            func = function() copiedSituationID = SID; end,
            order = 5,
            width = "half",
        },
        paste = {
            type = 'execute',
            name = "Paste",
            desc = "Paste the settings from that last copied situation.",
            hidden = function() return (not S) end,
            disabled = function() return (not copiedSituationID) end,
            func = function() parent:CopySituationInto(copiedSituationID, SID); copiedSituationID = nil; end,
            order = 6,
            width = "half",
        },
        export = {
            type = 'execute',
            name = "Export",
            desc = "Export this entire situation to a string",
            hidden = function() return (not S) or (not DynamicCam.db.profile.advanced) end,
            func = function() parent:PopupExport(parent:ExportSituation(SID)); end,
            order = 7,
            width = "half",
        },
        deleteCustom = {
            type = 'execute',
            name = "Delete",
            desc = "Delete this custom situation",
            hidden = function() return (not S) or (not string.find(SID, "custom")); end,
            func = function() DynamicCam:DeleteCustomSituation(SID); end,
            order = 8,
            width = "half",
        },
        cameraActions = {
            type = 'group',
            name = "Camera Actions",
            order = 10,
            inline = true,
            hidden = function() return (not S) end,
            disabled = function() return (not S.enabled) end,
            args = {
                zoom = {
                    type = 'toggle',
                    name = "Zoom",
                    desc = "Set a zoom level when this situation is activated",
                    get = function() return (S.cameraActions.zoomSetting ~= "off") end,
                    set = function(_, newValue) if newValue then S.cameraActions.zoomSetting = "set"; else S.cameraActions.zoomSetting = "off"; end end,
                    order = 1,
                },
                rotate = {
                    type = 'toggle',
                    name = "Rotate (Pitch/Yaw)",
                    desc = "Start rotating the camera when this situation is activated (and stop when it's done)",
                    get = function() return S.cameraActions.rotate end,
                    set = function(_, newValue) S.cameraActions.rotate = newValue; LibCamera:StopRotating(); end,
                    order = 2,
                },
                view = {
                    type = 'toggle',
                    name = "Set View (Advanced)",
                    desc = "When this situation is activated (and only then), the selected view will be set",
                    hidden = function() return (not S) or (not DynamicCam.db.profile.advanced and not S.view.enabled) end,
                    get = function() return S.view.enabled end,
                    set = function(_, newValue) S.view.enabled = newValue end,
                    order = 3,
                },
                transitionTime = {
                    type = 'group',
                    name = "Transition Time (Advanced)",
                    order = 5,
                    hidden = function() return ((not DynamicCam.db.profile.advanced) or ((S.cameraActions.zoomSetting == "off") and (not S.cameraActions.rotate) and (not S.view.enabled))) end,
                    inline = true,
                    args = {
                        transitionTime = {
                            type = 'range',
                            name = "Time",
                            desc = "The time that it takes to transition to this situation",
                            min = .1,
                            max = 10,
                            softMax = 5,
                            step = .05,
                            get = function() return S.cameraActions.transitionTime end,
                            set = function(_, newValue) S.cameraActions.transitionTime = newValue; end,
                            width = "double",
                            order = 2,
                        },
                        timeIsMax = {
                            type = 'toggle',
                            name = "Don't Slow",
                            desc = "Camera shouldn't be slowed down to match the transition time. Thus, the transition takes at most the time given here but is otherwise as fast as the set Camera Move Speed allows.",
                            get = function() return S.cameraActions.timeIsMax end,
                            set = function(_, newValue) S.cameraActions.timeIsMax = newValue; end,
                            order = 1,
                        },
                    },
                },
                zoomSettings = {
                    type = 'group',
                    name = "Zoom Settings",
                    order = 10,
                    hidden = function() return (S.cameraActions.zoomSetting == "off") end,
                    inline = true,
                    args = {
                        zoomSetting = {
                            type = 'select',
                            name = "Zoom Setting",
                            desc = "How the camera should react to this situation with regards to zoom. Choose between:\n\nZoom In To: Zoom in to selected distance for this situation, will not zoom out.\n\nZoom Out To: Zoom out to selected distance for this situation, will not zoom in.\n\nZoom Range: Zoom in if past the maximum value, zoom out if past the minimum value.\n\nZoom Set To: Set the zoom to this value.",
                            get = function() return S.cameraActions.zoomSetting end,
                            set = function(_, newValue) S.cameraActions.zoomSetting = newValue; end,
                            values = {["in"] = "Zoom In To", ["out"] = "Zoom Out To", ["set"] = "Zoom Set To", ["range"] = "Zoom Range"},
                            order = 1,
                        },
                        zoomValue = {
                            type = 'range',
                            name = "Zoom Value",
                            desc = "The zoom value to set",
                            hidden = function() return S.cameraActions.zoomSetting == "range" end,
                            min = 0,
                            max = 39,
                            step = .5,
                            get = function() return S.cameraActions.zoomValue end,
                            set = function(_, newValue) S.cameraActions.zoomValue = newValue; end,
                            order = 2,
                            width = "double",
                        },
                        zoomMin = {
                            type = 'range',
                            name = "Zoom Min",
                            desc = "The min zoom value to set",
                            hidden = function() return S.cameraActions.zoomSetting ~= "range" end,
                            min = 0,
                            max = 39,
                            step = .5,
                            get = function() return S.cameraActions.zoomMin end,
                            set = function(_, newValue) S.cameraActions.zoomMin = newValue; end,
                            order = 3,
                        },
                        zoomMax = {
                            type = 'range',
                            name = "Zoom Max",
                            desc = "The max zoom value to set",
                            hidden = function() return S.cameraActions.zoomSetting ~= "range" end,
                            min = 0,
                            max = 39,
                            step = .5,
                            get = function() return S.cameraActions.zoomMax end,
                            set = function(_, newValue) S.cameraActions.zoomMax = newValue; end,
                            order = 4,
                        },
                    },
                },
                rotateSettings = {
                    type = 'group',
                    name = "Rotate Settings",
                    order = 30,
                    inline = true,
                    hidden = function() return (not S.cameraActions.rotate) end,
                    args = {
                        rotateSetting = {
                            type = 'select',
                            name = "Rotate Setting",
                            desc = "How the camera should react to this situation with regards to rotating",
                            get = function() return S.cameraActions.rotateSetting end,
                            set = function(_, newValue) S.cameraActions.rotateSetting = newValue; end,
                            values = {["continous"] = "Continously", ["degrees"] = "By Degrees",},
                            order = 1,
                        },
                        rotateSpeed = {
                            type = 'range',
                            name = "Speed",
                            desc = "Speed at which to rotate, in degrees/second",
                            min = -900,
                            max = 900,
                            softMin = -90,
                            softMax = 90,
                            hidden = function() return (S.cameraActions.rotateSetting ~= "continous") end,
                            step = 1,
                            get = function() return S.cameraActions.rotateSpeed end,
                            set = function(_, newValue) S.cameraActions.rotateSpeed = newValue; end,
                            order = 2,
                            width = "double",
                        },
                        yawDegrees = {
                            type = 'range',
                            name = "Yaw (-Left/Right+)",
                            desc = "Number of degrees to yaw (left and right)",
                            min = -1400,
                            max = 1440,
                            softMin = -360,
                            softMax = 360,
                            hidden = function() return (S.cameraActions.rotateSetting == "continous") end,
                            step = 5,
                            get = function() return S.cameraActions.yawDegrees end,
                            set = function(_, newValue) S.cameraActions.yawDegrees = newValue; end,
                            order = 2,
                        },
                        pitchDegrees = {
                            type = 'range',
                            name = "Pitch (-Down/Up+)",
                            desc = "Number of degrees to pitch (up and down)",
                            min = -90,
                            max = 90,
                            hidden = function() return (S.cameraActions.rotateSetting == "continous") end,
                            step = 5,
                            get = function() return S.cameraActions.pitchDegrees end,
                            set = function(_, newValue) S.cameraActions.pitchDegrees = newValue; end,
                            order = 3,
                        },
                        rotateBack = {
                            type = 'toggle',
                            name = "Rotate Back",
                            desc = "When the situation ends, try to rotate back to the original position.",
                            get = function() return S.cameraActions.rotateBack end,
                            set = function(_, newValue) S.cameraActions.rotateBack = newValue end,
                            order = 4,
                        },
                    },
                },
                viewSettings = {
                    type = 'group',
                    name = "View Settings",
                    order = 30,
                    inline = true,
                    hidden = function() return (not S.view.enabled) end,
                    args = {
                        view = {
                            type = 'select',
                            name = "View",
                            desc = "Which view should be set",
                            get = function() return S.view.viewNumber end,
                            set = function(_, newValue) S.view.viewNumber = newValue; end,
                            values = {[2] = "2", [3] = "3", [4] = "4", [5] = "5"},
                            order = 2,
                            width = "half",
                        },
                        instant = {
                            type = 'toggle',
                            name = "Instant",
                            desc = "If the transition to this view should be instant",
                            get = function() return S.view.instant end,
                            set = function(_, newValue) S.view.instant = newValue end,
                            order = 3,
                            width = "half",
                        },
                        restoreView = {
                            type = 'toggle',
                            name = "Restore",
                            desc = "Restore view to what it was before the situation arose",
                            get = function() return S.view.restoreView end,
                            set = function(_, newValue) S.view.restoreView = newValue end,
                            order = 5,
                            width = "half",
                        },
                    },
                },
            },
        },
        cameraSettings = {
            type = 'group',
            name = "Camera Settings",
            order = 20,
            inline = true,
            hidden = function() return (not S) or (not DynamicCam.db.profile.actionCam) end,
            disabled = function() return (not S.enabled) end,
            args = {
                overShoulderToggle = {
                    type = 'toggle',
                    name = "Adjust Shoulder Offset",
                    desc = "If this setting should be affected",
                    get = function() return (S.cameraCVars["test_cameraOverShoulder"] ~= nil) end,
                    set = function(_, newValue) if newValue then S.cameraCVars["test_cameraOverShoulder"] = 0 else S.cameraCVars["test_cameraOverShoulder"] = nil end Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    order = 0,
                },
                overShoulder = {
                    type = 'range',
                    name = "Shoulder Offset Value",
                    desc = "Positive is over right shoulder, negative is over left shoulder",
                    hidden = function() return (S.cameraCVars["test_cameraOverShoulder"] == nil) end,
                    min = -15,
                    max = 15,
                    step = .1,
                    get = function() return S.cameraCVars["test_cameraOverShoulder"] end,
                    set = function(_, newValue) S.cameraCVars["test_cameraOverShoulder"] = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    order = 10,
                    width = "full",
                },
                headTrackingToggle = {
                    type = 'toggle',
                    name = "Adjust Head Tracking",
                    desc = "If this setting should be affected",
                    get = function() return (S.cameraCVars["test_cameraHeadMovementStrength"] ~= nil) end,
                    set = function(_, newValue) if newValue then S.cameraCVars["test_cameraHeadMovementStrength"] = 0 else S.cameraCVars["test_cameraHeadMovementStrength"] = nil end Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    order = 3,
                },
                headTracking = {
                    type = 'range',
                    name = "Head Tracking Strength",
                    desc = "The camera will move to follow your character's head movements, tracking it forward, back, left and right. The strength controls how much it follows the head.\n\nThis can cause some nausea if you are prone to motion sickness.",
                    hidden = function() return (S.cameraCVars["test_cameraHeadMovementStrength"] == nil) end,
                    min = 0,
                    max = 100,
                    softMax = 2,
                    step = .1,
                    get = function() return S.cameraCVars["test_cameraHeadMovementStrength"] end,
                    set = function(_, newValue) S.cameraCVars["test_cameraHeadMovementStrength"] = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    width = "full",
                    order = 12,
                },
                dynamicPitch = {
                    type = 'toggle',
                    tristate = true,
                    name = "Dynamic Pitch",
                    desc = "The camera will adjust the camera's pitch (the angle at which the camera looks at your character in the up/down direction) according to the current zoom level.\n\nAngles the camera up while farther away from the character and down coming towards your character.\n\nA gray checkbox means that the default will be used instead.",
                    get = function()
                        if S.cameraCVars["test_cameraDynamicPitch"] == nil then
                            return nil
                        elseif S.cameraCVars["test_cameraDynamicPitch"] == 1 then
                            return true
                        elseif S.cameraCVars["test_cameraDynamicPitch"] == 0 then
                            return false
                        end
                        Options:SendMessage("DC_SITUATION_UPDATED", SID)
                    end,
                    set = function(_, newValue)
                        if newValue == nil then
                            S.cameraCVars["test_cameraDynamicPitch"] = nil
                            S.cameraCVars["test_cameraDynamicPitchBaseFovPad"] = nil
                            S.cameraCVars["test_cameraDynamicPitchBaseFovPadFlying"] = nil
                            S.cameraCVars["test_cameraDynamicPitchBaseFovPadDownScale"] = nil
                            S.cameraCVars["test_cameraDynamicPitchSmartPivotCutoffDist"] = nil
                        elseif newValue == true then
                            S.cameraCVars["test_cameraDynamicPitch"] = 1
                        elseif newValue == false then
                            S.cameraCVars["test_cameraDynamicPitch"] = 0
                        end
                        Options:SendMessage("DC_SITUATION_UPDATED", SID)
                    end,
                    order = 4,
                },
                targetLockGroup = {
                    type = 'group',
                    name = "Target Lock/Focus",
                    order = 50,
                    inline = true,
                    args = {
                        targetLockEnemies = {
                            type = 'toggle',
                            tristate = true,
                            name = "Focus Enemies",
                            desc = "Lock/focus enemies. This includes both dead enemies, and targets that have gone offscreen.\n\nA gray checkbox means that the default will be used instead.",
                            get = function()
                                if S.cameraCVars["test_cameraTargetFocusEnemyEnable"] == nil then
                                    return nil
                                end
                                return (S.cameraCVars["test_cameraTargetFocusEnemyEnable"] == 1) end,
                            set = function(_, newValue)
                                if newValue == nil then
                                    S.cameraCVars["test_cameraTargetFocusEnemyEnable"] = nil
                                    S.cameraCVars["test_cameraTargetFocusEnemyStrengthPitch"] = nil
                                    S.cameraCVars["test_cameraTargetFocusEnemyStrengthYaw"] = nil
                                elseif newValue == true then
                                    S.cameraCVars["test_cameraTargetFocusEnemyEnable"] = 1
                                elseif newValue == false then
                                    S.cameraCVars["test_cameraTargetFocusEnemyEnable"] = 0
                                end

                                Options:SendMessage("DC_SITUATION_UPDATED", SID)
                            end,
                            order = 1,
                        },
                        targetLockEnemiesPitch = {
                            type = 'range',
                            name = "Focus Enemy Pitch Strength (Advanced)",
                            desc = "",
                            min = 0,
                            max = 1,
                            step = .05,
                            hidden = function()
                                return ((not S.cameraCVars["test_cameraTargetFocusEnemyEnable"])
                                    or (S.cameraCVars["test_cameraTargetFocusEnemyEnable"] == 0)
                                    or (not DynamicCam.db.profile.advanced))
                            end,
                            get = function()
                                return (S.cameraCVars["test_cameraTargetFocusEnemyStrengthPitch"]
                                    or tonumber(GetCVarDefault("test_cameraTargetFocusEnemyStrengthPitch")))
                            end,
                            set = function(_, newValue)
                                S.cameraCVars["test_cameraTargetFocusEnemyStrengthPitch"] = newValue
                                Options:SendMessage("DC_SITUATION_UPDATED", SID)
                            end,
                            width = "full",
                            order = 2,
                        },
                        targetLockEnemiesYaw = {
                            type = 'range',
                            name = "Focus Enemy Yaw Strength (Advanced)",
                            desc = "",
                            min = 0,
                            max = 1,
                            step = .05,
                            hidden = function()
                                return ((not S.cameraCVars["test_cameraTargetFocusEnemyEnable"])
                                    or (S.cameraCVars["test_cameraTargetFocusEnemyEnable"] == 0)
                                    or (not DynamicCam.db.profile.advanced))
                            end,
                            get = function()
                                return (S.cameraCVars["test_cameraTargetFocusEnemyStrengthYaw"]
                                    or tonumber(GetCVarDefault("test_cameraTargetFocusEnemyStrengthYaw")))
                            end,
                            set = function(_, newValue)
                                S.cameraCVars["test_cameraTargetFocusEnemyStrengthYaw"] = newValue
                                Options:SendMessage("DC_SITUATION_UPDATED", SID)
                            end,
                            width = "full",
                            order = 3,
                        },
                        targetLockInteractables = {
                            type = 'toggle',
                            tristate = true,
                            name = "Focus On Interact",
                            desc = "Lock/focus NPCs in interactions\n\nA gray checkbox means that the default will be used instead.",
                            get = function()
                                if S.cameraCVars["test_cameraTargetFocusInteractEnable"] == nil then
                                    return nil
                                end
                                return (S.cameraCVars["test_cameraTargetFocusInteractEnable"] == 1) end,
                            set = function(_, newValue)
                                if newValue == nil then
                                    S.cameraCVars["test_cameraTargetFocusInteractEnable"] = nil
                                    S.cameraCVars["test_cameraTargetFocusInteractStrengthPitch"] = nil
                                    S.cameraCVars["test_cameraTargetFocusInteractStrengthYaw"] = nil
                                elseif newValue == true then
                                    S.cameraCVars["test_cameraTargetFocusInteractEnable"] = 1
                                elseif newValue == false then
                                    S.cameraCVars["test_cameraTargetFocusInteractEnable"] = 0
                                end

                                Options:SendMessage("DC_SITUATION_UPDATED", SID)
                            end,
                            order = 11,
                        },
                        targetLockInteractPitch = {
                            type = 'range',
                            name = "Focus Interact Pitch Strength (Advanced)",
                            desc = "",
                            min = 0,
                            max = 1,
                            step = .05,
                            hidden = function()
                                return ((not S.cameraCVars["test_cameraTargetFocusInteractEnable"])
                                    or (S.cameraCVars["test_cameraTargetFocusInteractEnable"] == 0)
                                    or (not DynamicCam.db.profile.advanced))
                            end,
                            get = function()
                                return (S.cameraCVars["test_cameraTargetFocusInteractStrengthPitch"]
                                    or tonumber(GetCVarDefault("test_cameraTargetFocusInteractStrengthPitch")))
                            end,
                            set = function(_, newValue)
                                S.cameraCVars["test_cameraTargetFocusInteractStrengthPitch"] = newValue
                                Options:SendMessage("DC_SITUATION_UPDATED", SID)
                            end,
                            width = "full",
                            order = 12,
                        },
                        targetLockInteractYaw = {
                            type = 'range',
                            name = "Focus Interact Yaw Strength (Advanced)",
                            desc = "",
                            min = 0,
                            max = 1,
                            step = .05,
                            hidden = function()
                                return ((not S.cameraCVars["test_cameraTargetFocusInteractEnable"])
                                    or (S.cameraCVars["test_cameraTargetFocusInteractEnable"] == 0)
                                    or (not DynamicCam.db.profile.advanced))
                            end,
                            get = function()
                                return (S.cameraCVars["test_cameraTargetFocusInteractStrengthYaw"]
                                    or tonumber(GetCVarDefault("test_cameraTargetFocusInteractStrengthYaw")))
                            end,
                            set = function(_, newValue)
                                S.cameraCVars["test_cameraTargetFocusInteractStrengthYaw"] = newValue
                                Options:SendMessage("DC_SITUATION_UPDATED", SID)
                            end,
                            width = "full",
                            order = 13,
                        },
                    },
                },
                advancedDivider = {
                    type = 'header',
                    name = "Advanced",
                    order = 100,
                    hidden = function() return (not DynamicCam.db.profile.advanced) or (((not S.cameraCVars["test_cameraDynamicPitch"]) or (S.cameraCVars["test_cameraDynamicPitch"] == 0)) and ((not S.cameraCVars["test_cameraHeadMovementStrength"]) or (S.cameraCVars["test_cameraHeadMovementStrength"] == 0))) end,
                },
                dynamicPitchAdvanced = {
                    type = 'group',
                    name = "Dynamic Pitch Settings (Advanced)",
                    order = 102,
                    inline = true,
                    hidden = function() return ((not S.cameraCVars["test_cameraDynamicPitch"]) or (S.cameraCVars["test_cameraDynamicPitch"] == 0) or (not DynamicCam.db.profile.advanced)) end,
                    args = {
                        baseFovPad = {
                            type = 'range',
                            name = "Base FOV Pad",
                            desc = "This seems to adjust how far the camera is pitched up or down.\n\nSmaller values pitch up away from the ground while larger values pitch down towards the ground.",
                            min = .01,
                            max = 1,
                            step = .01,
                            get = function() return (S.cameraCVars["test_cameraDynamicPitchBaseFovPad"] or tonumber(GetCVarDefault("test_cameraDynamicPitchBaseFovPad"))) end,
                            set = function(_, newValue) S.cameraCVars["test_cameraDynamicPitchBaseFovPad"] = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID); end,
                            order = 1,
                        },
                        baseFovPadFlying = {
                            type = 'range',
                            name = "Base FOV Pad (Flying)",
                            desc = "This seems to adjust how far the camera is pitched up or down.\n\nSmaller values pitch up away from the ground while larger values pitch down towards the ground.\n\nThis is presumbly for when you are flying.",
                            min = .01,
                            max = 1,
                            step = .01,
                            get = function() return (S.cameraCVars["test_cameraDynamicPitchBaseFovPadFlying"] or tonumber(GetCVarDefault("test_cameraDynamicPitchBaseFovPadFlying"))) end,
                            set = function(_, newValue) S.cameraCVars["test_cameraDynamicPitchBaseFovPadFlying"] = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID); end,
                            order = 2,
                        },
                        baseFovPadDownScale = {
                            type = 'range',
                            name = "Base FOV Pad Downscale",
                            desc = "Likely a multiplier for how much pitch is applied. Higher values allow the character to be 'further' down the screen.",
                            min = .0,
                            max = 1,
                            step = .01,
                            get = function() return (S.cameraCVars["test_cameraDynamicPitchBaseFovPadDownScale"] or tonumber(GetCVarDefault("test_cameraDynamicPitchBaseFovPadDownScale"))) end,
                            set = function(_, newValue) S.cameraCVars["test_cameraDynamicPitchBaseFovPadDownScale"] = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID); end,
                            order = 3,
                        },
                        smartPivotCutoffDist = {
                            type = 'range',
                            name = "Smart Pivot Cutoff Distance",
                            -- Thanks to Jordaldo for providing this tooltip info.
                            -- https://github.com/Mpstark/DynamicCam/issues/14
                            desc = "Defines the distance that the camera has to be inside of for the ground collision to either bring the camera closer to the character's feet as the camera collides with the ground, or to simply pivot on the spot of camera-to-ground collision.",
                            min = 0,
                            max = 100,
                            softMin = 0,
                            softMax = 39,
                            step = .5,
                            get = function() return (S.cameraCVars["test_cameraDynamicPitchSmartPivotCutoffDist"] or tonumber(GetCVarDefault("test_cameraDynamicPitchSmartPivotCutoffDist"))) end,
                            set = function(_, newValue) S.cameraCVars["test_cameraDynamicPitchSmartPivotCutoffDist"] = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID); end,
                            order = 4,
                        },
                    },
                },
            },
        },
        extraActions = {
            type = 'group',
            name = "Extra Actions",
            order = 30,
            inline = true,
            hidden = function() return (not S) end,
            disabled = function() return (not S.enabled) end,
            args = {
                fadeUI = {
                    type = 'toggle',
                    name = "Fade UI",
                    desc = "Fades the UI to transparent during this situation.\n\nPressing escape will cancel the fade.",
                    get = function() return S.extras.hideUI; end,
                    set = function(_, newValue) S.extras.hideUI = newValue; end,
                    order = 1,
                },
                hideUIFadeOpacity = {
                    type = 'range',
                    name = "Fade Opacity",
                    desc = "Fade the UI to this opacity.",
                    hidden = function() return not S.extras.hideUI; end,
                    min = 0,
                    max = 1,
                    step = .01,
                    get = function() return S.extras.hideUIFadeOpacity end,
                    set = function(_, newValue) S.extras.hideUIFadeOpacity = newValue; end,
                    order = 2,
                },
                actuallyHideUI = {
                    type = 'toggle',
                    name = "Hide UI After Fade",
                    desc = "Actually hides the UI after the fade. Otherwise it is still interactable even when faded out.",
                    hidden = function() return not S.extras.hideUI or S.extras.hideUIFadeOpacity ~= 0; end,
                    get = function() return S.extras.actuallyHideUI; end,
                    set = function(_, newValue) S.extras.actuallyHideUI = newValue; end,
                    order = 3,
                },
                keepMinimap = {
                    type = 'toggle',
                    name = "Keep Minimap",
                    desc = "Do not fade the minimap.",
                    hidden = function() return not S.extras.hideUI or S.extras.actuallyHideUI; end,
                    get = function() return S.extras.keepMinimap; end,
                    set = function(_, newValue) S.extras.keepMinimap = newValue; end,
                    order = 4,
                },
            },
        },
        advanced = {
            type = 'group',
            name = "Advanced",
            order = 100,
            inline = true,
            hidden = function() return (not S) or (not DynamicCam.db.profile.advanced) end,
            disabled = function() return (not S.enabled) end,
            args = {
                events = {
                    type = 'input',
                    name = "Events",
                    desc = "",
                    get = function() return table.concat(S.events, ", ") end,
                    set = function(_, newValue)
                        if newValue == "" then
                            S.events = {}
                        else
                            newValue = string.gsub(newValue, "%s+", "")
                            S.events = {strsplit(",", newValue)}
                        end
                        Options:SendMessage("DC_SITUATION_UPDATED", SID)
                    end,
                    width = "double",
                    order = 1,
                },
                eventsDefault = {
                    type = 'execute',
                    name = "Restore default",
                    desc = "Your 'Events' deviate from the default. Click here to restore it.",
                    func = function() S.events = DynamicCam.defaults.profile.situations[SID].events end,
                    hidden = function()
                        if not DynamicCam.defaults.profile.situations[SID] then return true end
                        return EventsEqual(S.events, DynamicCam.defaults.profile.situations[SID].events)
                      end,
                    order = 3,
                },
                priority = {
                    type = 'input',
                    name = "Priority",
                    desc = "If multiple situations are active at the same time, the one with the highest priority is chosen",
                    get = function() return ""..S.priority end,
                    set = function(_, newValue) if tonumber(newValue) then S.priority = tonumber(newValue) end Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    width = "half",
                    order = 1,
                },
                delay = {
                    type = 'input',
                    name = "Delay",
                    desc = "How long to delay exiting this situation",
                    get = function() return ""..S.delay end,
                    set = function(_, newValue) if tonumber(newValue) then S.delay = tonumber(newValue) end Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    width = "half",
                    order = 2,
                },
                condition = {
                    type = 'input',
                    name = "Condition",
                    desc = "When this situation should be activated.",
                    get = function() return S.condition end,
                    set = function(_, newValue) S.condition = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    multiline = 6,
                    width = "full",
                    order = 5,
                },
                conditionDefault = {
                    type = 'execute',
                    name = "Restore default",
                    desc = "Your 'Condition' deviates from the default. Click here to restore it.",
                    func = function() S.condition = DynamicCam.defaults.profile.situations[SID].condition end,
                    hidden = function()
                        if not DynamicCam.defaults.profile.situations[SID] then return true end
                        return ScriptEqual(S.condition, DynamicCam.defaults.profile.situations[SID].condition)
                      end,
                    order = 6,
                },
                executeOnInit = {
                    type = 'input',
                    name = "Initialization Script",
                    desc = "Called when the situation is loaded and when it is modified.",
                    get = function() return S.executeOnInit end,
                    set = function(_, newValue) S.executeOnInit = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    multiline = 6,
                    width = "full",
                    order = 10,
                },
                executeOnInitDefault = {
                    type = 'execute',
                    name = "Restore default",
                    desc = "Your 'Initialization Script' deviates from the default. Click here to restore it.",
                    func = function() S.executeOnInit = DynamicCam.defaults.profile.situations[SID].executeOnInit end,
                    hidden = function()
                        if not DynamicCam.defaults.profile.situations[SID] then return true end
                        return ScriptEqual(S.executeOnInit, DynamicCam.defaults.profile.situations[SID].executeOnInit)
                      end,
                    order = 11,
                },
                executeOnEnter = {
                    type = 'input',
                    name = "On Enter Script",
                    desc = "Called when the situation is selected as the active situation (before any thing else).",
                    get = function() return S.executeOnEnter end,
                    set = function(_, newValue) S.executeOnEnter = newValue end,
                    multiline = 6,
                    width = "full",
                    order = 20,
                },
                executeOnEnterDefault = {
                    type = 'execute',
                    name = "Restore default",
                    desc = "Your 'On Enter Script' deviates from the default. Click here to restore it.",
                    func = function() S.executeOnEnter = DynamicCam.defaults.profile.situations[SID].executeOnEnter end,
                    hidden = function()
                        if not DynamicCam.defaults.profile.situations[SID] then return true end
                        return ScriptEqual(S.executeOnEnter, DynamicCam.defaults.profile.situations[SID].executeOnEnter)
                      end,
                    order = 21,
                },
                executeOnExit = {
                    type = 'input',
                    name = "On Exit Script",
                    desc = "Called when the situation is overridden by another situation or the condition fails a check (before any thing else).",
                    get = function() return S.executeOnExit end,
                    set = function(_, newValue) S.executeOnExit = newValue end,
                    multiline = 6,
                    width = "full",
                    order = 30,
                },
                executeOnExitDefault = {
                    type = 'execute',
                    name = "Restore default",
                    desc = "Your 'On Exit Script' deviates from the default. Click here to restore it.",
                    func = function() S.executeOnExit = DynamicCam.defaults.profile.situations[SID].executeOnExit end,
                    hidden = function()
                        if not DynamicCam.defaults.profile.situations[SID] then return true end
                        return ScriptEqual(S.executeOnExit, DynamicCam.defaults.profile.situations[SID].executeOnExit)
                      end,
                    order = 31,
                },
            },
        },
    },
}
local presets = {
    name = "Presets",
    handler = DynamicCam,
    type = 'group',
    args = {
        description = {
            type = 'description',
            name = "Full configurations of DynamicCam that you can load into your current profile.",
            fontSize = "small",
            width = "full",
            order = 1,
        },
        loadPreset = {
            type = 'select',
            name = "Load Preset",
            desc = "This will load the selected preset into the current profile.\n\nYOUR CURRENT PROFILE WILL BE COMPLETELY OVERRIDDEN!",
            get = function() return ""; end,
            set = function(_, newValue) DynamicCam:LoadPreset(newValue); end,
            values = "GetPresets",
            width = "full",
            order = 2,
        },
        presetDescriptions = {
            name = "Descriptions",
            type = 'group',
            inline = true,
            order = 3,
            args = {
                description = {
                    type = 'description',
                    name = function() return DynamicCam:GetPresetDescriptions(); end,
                    fontSize = "small",
                    width = "full",
                    order = 1,
                },
            },
        },
    },
}
local sharing = {
    name = "Import/Export",
    handler = DynamicCam,
    type = 'group',
    args = {
        exportGroup = {
            name = "Export My Profile",
            type = 'group',
            inline = true,
            order = 1,
            args = {
                name = {
                    type = 'input',
                    name = "Profile Name (Required!)",
                    desc = "The name that other people will see when importing this profile.",
                    get = function() return exportName; end,
                    set = function(_, newValue) exportName = newValue; end,
                    --width = "double",
                    order = 1,
                },
                author = {
                    type = 'input',
                    name = "Author (Optional)",
                    desc = "A name that will be attached to the export so that other people know whom it's from.",
                    get = function() return exportAuthor; end,
                    set = function(_, newValue) exportAuthor = newValue; end,
                    order = 2,
                },
                export = {
                    type = 'execute',
                    name = "Export!",
                    desc = "Export the entire current profile to a string.",
                    disabled = function() return not (exportName and exportName ~= ""); end,
                    func = function() parent:PopupExport(parent:ExportProfile(exportName, exportAuthor)); end,
                    order = 50,
                    --width = "full",
                },
            },
        },
        import = {
            type = 'input',
            name = "Paste and Hit Accept to Import!",
            desc = "Paste DynamicCam import string for profiles or a situation.",
            get = function() return ""; end,
            set = function(_, newValue) DynamicCam:Import(newValue); end,
            multiline = 25,
            width = "full",
            order = 20,
        },
    },
}


----------
-- CORE --
----------
function Options:OnInitialize()
    -- make sure to select something for the UI
    self:SelectSituation()

    -- register the gui with AceConfig and Blizz Options
    self:RegisterMenus()
end

function Options:OnEnable()
    -- register for dynamiccam messages
    self:RegisterMessage("DC_SITUATION_ACTIVE", "ReselectSituation")
    self:RegisterMessage("DC_SITUATION_INACTIVE", "ReselectSituation")
    self:RegisterMessage("DC_SITUATION_ENTERED", "ReselectSituation")
    self:RegisterMessage("DC_SITUATION_EXITED", "ReselectSituation")
end

function Options:OnDisable()
    self:UnregisterAllMessages()
end


---------
-- GUI --
---------
function Options:ClearSelection()
    SID = nil
    S = nil
end

-- This function is needed to call SelectSituation() and
-- ignore the "message" argument passed to ReselectSituation().
function Options:ReselectSituation()
    self:SelectSituation()
end

function Options:SelectSituation(selectMe)
    if selectMe and parent.db.profile.situations[selectMe] then
        S = parent.db.profile.situations[selectMe]
        SID = selectMe
    else
        if parent.currentSituationID then
            S = parent.db.profile.situations[parent.currentSituationID]
            SID = parent.currentSituationID
        else
            if not SID or not S then
                SID, S = next(parent.db.profile.situations)
            end
        end
    end

    LibStub("AceConfigRegistry-3.0"):NotifyChange("DynamicCam Situations")
end

function Options:RegisterMenus()
    -- setup menu
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam", general)
    self.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam", "DynamicCam")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam Settings", settings)
    self.settings = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam Settings", "Settings", "DynamicCam")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam Situations", situationOptions)
    self.situtations = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam Situations", "Situations", "DynamicCam")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam Sharing", sharing)
    self.sharing = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam Sharing", "Import/Export", "DynamicCam")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam Presets", presets)
    self.presets = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam Presets", "Presets", "DynamicCam")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(parent.db))
    self.profiles = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam Profiles", "Profiles", "DynamicCam")
end




C_Timer.After(1, function()


    -- Prevent the user from activating MOTION_SICKNESS_CHARACTER_CENTERED.



    -- Automatically undo forbidden cvar changes.
    hooksecurefunc("SetCVar", function(cvar, value)
        if cvar == "CameraKeepCharacterCentered" and value == "1" then
            SetCVar("CameraKeepCharacterCentered", 0)
        end
    end)


end)


