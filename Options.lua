-------------
-- GLOBALS --
-------------
assert(DynamicCam);
DynamicCam.Options = DynamicCam:NewModule("Options", "AceEvent-3.0");


------------
-- LOCALS --
------------
local Options = DynamicCam.Options;
local Camera = DynamicCam.Camera;
local parent = DynamicCam;
local _;
local S, SID;

local welcomeMessage = [[Hello and welcome to the beta of DynamicCam! I'm glad that you're here and I hope that you have fun with the addon.

If you find an problem or want to make a suggestion, please, please leave a note in the Curse comments, PM me on reddit (I'm /u/mpstark), or best of all, come into the Discord (get a link by doing /dcdiscord) and speak with me there.

I've actually managed to stick this up on GitHub, so please, if you'd like to contribute, open a pull request there. 

Some handy slash commands:
    `/dc` will open this menu
    `/zi` will print out the current zoom
    `/zoom #` will zoom to that zoom level
    `/sv #` will save to the specified view slot (where # is a number between 2 and 5)
    `/dcdiscord` will allow you to copy a Discord invite so that you can join]];
local knownIssues = [[- Fit nameplates is still a work in progress, can do a little in-and-out number
- Missing a lot of the advanced options such as add/remove situation, import/export, etc.
- Boss vs. Trash combat detection can be a little wonky]];
local changelog = {
[[As always, you have to reset your profile to get the changes to the defaults, including changes to condition, or even new situations, if you want them.]],
[[Beta 3b:
    - Update to 7.2 changes to ActionCam
]],
[[Beta 3:
    - Forced database reset, there was just too much change on Blizzard's end.
    - Update to 7.1 changes to CVars and the return of ActionCam!
        - ActionCam features are DISABLED by default. Enable them in the options.
    - Defaults have been updated a bit.
    - Added "Reactive Zoom" option, which speeds up manual zooming when going quickly
        - Keep in mind that Blizzard adjusted the default zoom speed to 20 for everyone
        - There are several advanced options, toggle Advanced Mode to see them
        - This option is off by default
    - Some code cleanup
    - Stay tuned for further updates!
]],
[[Beta 2:
    - New `/zoom #` slash command that will set the zoom level to that value
    - Adjust Nameplate feature replaced by 'Toggle Nameplates' feature in "Zoom Fit Nameplates"
        - This should show the nameplate only when it is being used
    - A whole slew of advanced options has been added
        - Can now execute custom scripts on situation Enter/Exit and Initialization
            - Some of the defaults now use these and many of them have been cleaned up for readiblity
        - You can now change the events that trigger a check of situations
    - Several tweaks to the options panel
        - Set View is an advanced mode option, as it's, well, for people that know what they're doing
        - Many advanced options are now applied when the settings are applied
        - Many tooltips have been changed to better reflect what things do
    - Defaults:
        - Added a updated defaults dialog that pops up on load if the defaults have been updated
        - Added Fishing, Arena, and Battleground default situations
        - Add several things to the Hearth/Teleport default situation like Innkeeper's Daughter, Admiral's Compass
        - Hearth/Teleport situation now uses the cast time of the spell as the transitionTime
            - this is just the start of what can be done with the advanced scripts
    - Lots of little bugs squashed]],
[[Beta 1:
    - FORCED DATABASE RESET!
    - Event-based checking instead of polling -- large performance gain!
    - Removed frame hiding functionality, but hiding entire UI still supported
        - out-of-scope -- this is a camera addon
        - problems regarding UI taint didn't help
    - Changes to the current situation (right now only camera settings) will be applied instantly
    - Changes to the camera settings will be applied instantly
    - Nameplate fit has a new option; Entry Zoom as Min, which will basically make fit not zoom in
    - Nameplate fit is more consistant and has a reduced delay (from 250ms instead of 500ms)
    - Defaults:
        - mounted situations now consolidated into a single situation
        - Hearth/Teleport now tracks mage teleports (not portals) and Death Gate and Skyhold Jump
    - Fixed some bugs:
        - zoom restoration not working because of rounding issues or because of other zoom
        - a situation's zoom wouldn't actually be applied if a zoom was already occuring
        - nameplate settings should no longer cause taint]],
};

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
                    set = function(_, newValue) if (not newValue) then DynamicCam:Disable(); else DynamicCam:Enable(); end end,
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
                debugMode = {
                    type = 'toggle',
                    name = "Debug",
                    desc = "Print out debug messages to the chat window.",
                    get = function() return DynamicCam.db.profile.debugMode; end,
                    set = function(_, newValue) DynamicCam.db.profile.debugMode = newValue; end,
                    width = "half",
                    order = 4,
                },
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
        knownIssuesGroup = {
            type = 'group',
            name = "Known Issues",
            order = 5.5,
            inline = true,
            args = {
                issues = {
                    type = 'description',
                    name = knownIssues,
                    fontSize = "small",
                    width = "full",
                    order = 1,
                },
            }
        },
        changeLogGroup = {
            type = 'group',
            name = "Version Info",
            order = 6,
            inline = true,
            args = {
                changelog = {
                    type = 'description',
                    name = function() local l="" for k,v in ipairs(changelog) do l=l..v.."\n\n" end return l end,
                    fontSize = "small",
                    width = "full",
                    order = 1,
                },
            }
        },
    },
};
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
                    set = function(_, newValue) DynamicCam.db.profile.reactiveZoom.enabled = newValue; end,
                    order = 1,
                },
                reactiveZoomAdvanced = {
                    type = 'group',
                    name = "Reactive Zoom Options (Advanced)",
                    hidden = function() return (not DynamicCam.db.profile.advanced) or (not DynamicCam.db.profile.reactiveZoom.enabled) end,
                    order = 1,
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
                    },
                },
            },
        },
        defaultCvars = {
            type = 'group',
            name = "Default Camera Settings",
            order = 2,
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
                    set = function(_, newValue) if (newValue) then DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitch"] = 1; else DynamicCam.db.profile.defaultCvars["test_cameraDynamicPitch"] = 0; end Options:SendMessage("DC_BASE_CAMERA_UPDATED"); end,
                    order = .25,
                },
                cameraLockedTargetFocusing = {
                    type = 'toggle',
                    name = "Target Lock/Focus",
                    desc = "The camera will attempt to get your target on-screen by 'pulling' the camera angle towards the target.",
                    hidden = function() return (not DynamicCam.db.profile.actionCam) end,
                    get = function()
                            return (DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyEnable"] == 1
                                and DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractEnable"] == 1)
                        end,
                    set = function(_, newValue) 
                        if (newValue) then
                            DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyEnable"] = 1;
                            DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractEnable"] = 1;
                        else 
                            DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusEnemyEnable"] = 0;
                            DynamicCam.db.profile.defaultCvars["test_cameraTargetFocusInteractEnable"] = 0;
                        end
                        
                        Options:SendMessage("DC_BASE_CAMERA_UPDATED");
                    end,
                    order = 0.5,
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
                    softMin = -5,
                    softMax = 5,
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
                            desc = "No idea what this actually does",
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
};
local situationOptions = {
    name = "Situation Options",
    handler = DynamicCam,
    type = 'group',
    args = {
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
        enabled = {
            type = 'toggle',
            name = "Enable Situation",
            desc = "If this situation should be checked and activated",
            hidden = function() return (not S) end,
            get = function() return S.enabled end,
            set = function(_, newValue) S.enabled = newValue if (newValue) then Options:SendMessage("DC_SITUATION_ENABLED") else Options:SendMessage("DC_SITUATION_DISABLED") end end,
            order = 2,
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
                    set = function(_, newValue) if (newValue) then S.cameraActions.zoomSetting = "set"; else S.cameraActions.zoomSetting = "off"; end end,
                    order = 1,
                },
                rotate = {
                    type = 'toggle',
                    name = "Rotate",
                    desc = "Start rotating the camera when this situation is activated (and stop when it's done)",
                    get = function() return S.cameraActions.rotate end,
                    set = function(_, newValue) S.cameraActions.rotate = newValue; Camera:StopRotating(); end,
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
                            desc = "Camera shouldn't be slowed down to match the transition time",
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
                            desc = "How the camera should react to this situation with regards to zoom. Choose between:\n\nZoom Fit Nameplate: Zoom in/out to match the target's nameplate position (which is on top of the target's model). This will do nothing if you do not have a target or the nameplate isn't shown.\n\nZoom In To: Zoom in to selected distance for this situation, will not zoom out.\n\nZoom Out To: Zoom out to selected distance for this situation, will not zoom in.\n\nZoom Range: Zoom in if past the maximum value, zoom out if past the minimum value.\n\nZoom Set To: Set the zoom to this value.",
                            get = function() return S.cameraActions.zoomSetting end,
                            set = function(_, newValue) S.cameraActions.zoomSetting = newValue; end,
                            values = {["fit"] = "Zoom Fit Nameplate", ["in"] = "Zoom In To", ["out"] = "Zoom Out To", ["set"] = "Zoom Set To", ["range"] = "Zoom Range"},
                            order = 1,
                        },
                        zoomValue = {
                            type = 'range',
                            name = "Zoom Value",
                            desc = "The zoom value to set",
                            hidden = function() return (S.cameraActions.zoomSetting == "range" or S.cameraActions.zoomSetting == "fit") end,
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
                            hidden = function() return not (S.cameraActions.zoomSetting == "range" or S.cameraActions.zoomSetting == "fit") end,
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
                            hidden = function() return not (S.cameraActions.zoomSetting == "range" or S.cameraActions.zoomSetting == "fit") end,
                            min = 0,
                            max = 39,
                            step = .5,
                            get = function() return S.cameraActions.zoomMax end,
                            set = function(_, newValue) S.cameraActions.zoomMax = newValue; end,
                            order = 4,
                        },
                        fitContinously = {
                            type = 'toggle',
                            name = "Continuously Adjust",
                            desc = "Keep trying to fit after initial fit. This will prevent you from adjusting zoom.",
                            hidden = function() return not (S.cameraActions.zoomSetting == "fit") end,
                            get = function() return S.cameraActions.zoomFitContinous end,
                            set = function(_, newValue) S.cameraActions.zoomFitContinous = newValue end,
                            order = 6,
                        },
                        curZoomAsMin = {
                            type = 'toggle',
                            name = "Entry Zoom As Min",
                            desc = "Use the current zoom (going into the situation) as the minimum value instead. Will not exceed max.",
                            hidden = function() return not (S.cameraActions.zoomSetting == "fit") end,
                            get = function() return S.cameraActions.zoomFitUseCurAsMin end,
                            set = function(_, newValue) S.cameraActions.zoomFitUseCurAsMin = newValue end,
                            order = 7,
                        },
                        showNameplate = {
                            type = 'toggle',
                            name = "Toggle Nameplates",
                            desc = "Try to toggle nameplates on and turn them off after fit is complete",
                            hidden = function() return not (S.cameraActions.zoomSetting == "fit") end,
                            get = function() return S.cameraActions.zoomFitToggleNameplate end,
                            set = function(_, newValue) S.cameraActions.zoomFitToggleNameplate = newValue end,
                            order = 8,
                        },
                        fitPosition = {
                            type = 'select',
                            name = "Closeness (Advanced)",
                            desc = "How close should the camera fit to",
                            hidden = function() return not ((S.cameraActions.zoomSetting == "fit") and DynamicCam.db.profile.advanced) end,
                            get = function() return S.cameraActions.zoomFitPosition end,
                            set = function(_, newValue) S.cameraActions.zoomFitPosition = newValue; end,
                            values = {[60] = "Extremely Far", [70] = "Very Far", [75] = "Far", [80] = "Normal", [84] = "Close", [90] = "Very Close"},
                            order = 10,
                        },
                        fitSpeed = {
                            type = 'select',
                            name = "Speed (Adv)",
                            desc = "How fast the camera should adjust",
                            hidden = function() return not ((S.cameraActions.zoomSetting == "fit") and DynamicCam.db.profile.advanced) end,
                            get = function() return S.cameraActions.zoomFitSpeedMultiplier end,
                            set = function(_, newValue) S.cameraActions.zoomFitSpeedMultiplier = newValue; end,
                            values = {[1.5] = "Normal", [2] = "Quick", [3] = "V.Quick"},
                            width = "half",
                            order = 11,
                        },
                        fitIncrements = {
                            type = 'select',
                            name = "Incr (Adv)",
                            desc = "How much each step should adjust zoom, finer can mean slower",
                            hidden = function() return not ((S.cameraActions.zoomSetting == "fit") and DynamicCam.db.profile.advanced) end,
                            get = function() return S.cameraActions.zoomFitIncrements end,
                            set = function(_, newValue) S.cameraActions.zoomFitIncrements = newValue; end,
                            values = {[.25] = "Fine", [.5] = "Normal", [.75] = "Course"},
                            width = "half",
                            order = 12,
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
                            desc = "Speed at which to rotate",
                            min = -5,
                            max = 5,
                            softMin = -.5,
                            softMax = .5,
                            hidden = function() return (S.cameraActions.rotateSetting ~= "continous") end,
                            step = .01,
                            get = function() return S.cameraActions.rotateSpeed end,
                            set = function(_, newValue) S.cameraActions.rotateSpeed = newValue; end,
                            order = 2,
                            width = "double",
                        },
                        rotateDegrees = {
                            type = 'range',
                            name = "Degrees",
                            desc = "Number of degrees to rotate",
                            min = -1400,
                            max = 1440,
                            softMin = -360,
                            softMax = 360,
                            hidden = function() return (S.cameraActions.rotateSetting == "continous") end,
                            step = 5,
                            get = function() return S.cameraActions.rotateDegrees end,
                            set = function(_, newValue) S.cameraActions.rotateDegrees = newValue; end,
                            order = 2,
                            width = "double",
                        },
                        rotateBack = {
                            type = 'toggle',
                            name = "Rotate Back",
                            desc = "When the situation ends, try to rotate back to the original position.",
                            get = function() return S.cameraActions.rotateBack end,
                            set = function(_, newValue) S.cameraActions.rotateBack = newValue end,
                            order = 3,
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
                    set = function(_, newValue) if (newValue) then S.cameraCVars["test_cameraOverShoulder"] = 0 else S.cameraCVars["test_cameraOverShoulder"] = nil end Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    order = 0,
                },
                overShoulder = {
                    type = 'range',
                    name = "Shoulder Offset Value",
                    desc = "Positive is over right shoulder, negative is over left shoulder",
                    hidden = function() return (S.cameraCVars["test_cameraOverShoulder"] == nil) end,
                    softMin = -5,
                    softMax = 5,
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
                    set = function(_, newValue) if (newValue) then S.cameraCVars["test_cameraHeadMovementStrength"] = 0 else S.cameraCVars["test_cameraHeadMovementStrength"] = nil end Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
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
                        if (S.cameraCVars["test_cameraDynamicPitch"] == nil) then
                            return nil;
                        elseif (S.cameraCVars["test_cameraDynamicPitch"] == 1) then
                            return true;
                        elseif (S.cameraCVars["test_cameraDynamicPitch"] == 0) then
                            return false;
                        end
                        Options:SendMessage("DC_SITUATION_UPDATED", SID);
                    end,
                    set = function(_, newValue)
                        if (newValue == nil) then
                            S.cameraCVars["test_cameraDynamicPitch"] = nil;
                            S.cameraCVars["test_cameraDynamicPitchBaseFovPad"] = nil;
                            S.cameraCVars["test_cameraDynamicPitchBaseFovPadFlying"] = nil;
                            S.cameraCVars["test_cameraDynamicPitchBaseFovPadDownScale"] = nil;
                            S.cameraCVars["test_cameraDynamicPitchSmartPivotCutoffDist"] = nil;
                        elseif (newValue == true) then
                            S.cameraCVars["test_cameraDynamicPitch"] = 1;
                        elseif (newValue == false) then
                            S.cameraCVars["test_cameraDynamicPitch"] = 0;
                        end
                        Options:SendMessage("DC_SITUATION_UPDATED", SID);
                    end,
                    order = 4,
                },
                targetLock = {
                    type = 'toggle',
                    name = "Target Lock/Focus",
                    desc = "The camera will attempt to get your target on-screen by 'pulling' the camera angle towards the target.",
                    get = function() return S.targetLock.enabled end,
                    set = function(_, newValue) S.targetLock.enabled = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID); end,
                    order = 40,
                },
                targetLockSettings = {
                    type = 'group',
                    name = "Target Lock/Focus Settings",
                    order = 50,
                    inline = true,
                    hidden = function() return (not S.targetLock.enabled) end,
                    args = {
                        onlyAttackable = {
                            type = 'toggle',
                            name = "Only Attackable",
                            desc = "Only target lock/focus attackable targets",
                            get = function() return S.targetLock.onlyAttackable end,
                            set = function(_, newValue) S.targetLock.onlyAttackable = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID); end,
                            order = 1,
                        },
                        dead = {
                            type = 'toggle',
                            name = "Ignore Dead",
                            desc = "Don't target lock/focus dead targets",
                            get = function() return (not S.targetLock.dead) end,
                            set = function(_, newValue) S.targetLock.dead = not newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID); end,
                            order = 2,
                        },
                        nameplateVisible = {
                            type = 'toggle',
                            name = "Nameplate Visible",
                            desc = "Only target lock/focus units that have a visible nameplate",
                            get = function() return S.targetLock.nameplateVisible end,
                            set = function(_, newValue) S.targetLock.nameplateVisible = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID); end,
                            order = 4,
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
                            desc = "No idea what this actually does",
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
                entireUI = {
                    type = 'toggle',
                    name = "Hide Entire UI",
                    desc = "Hide the entire UI during this situation.",
                    get = function() return S.extras.hideUI end,
                    set = function(_, newValue) S.extras.hideUI = newValue end,
                    order = 1,
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
                        if (newValue == "") then
                            S.events = {};
                        else
                            newValue = string.gsub(newValue, "%s+", "");
                            S.events = {strsplit(",", newValue)};
                        end
                        Options:SendMessage("DC_SITUATION_UPDATED", SID);
                    end,
                    width = "double",
                    order = 1,
                },
                priority = {
                    type = 'input',
                    name = "Priority",
                    desc = "If multiple situations are active at the same time, the one with the highest priority is chosen",
                    get = function() return ""..S.priority end,
                    set = function(_, newValue) if (tonumber(newValue)) then S.priority = tonumber(newValue) end Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    width = "half",
                    order = 1,
                },
                delay = {
                    type = 'input',
                    name = "Delay",
                    desc = "How long to delay exiting this situation",
                    get = function() return ""..S.delay end,
                    set = function(_, newValue) if (tonumber(newValue)) then S.delay = tonumber(newValue) end Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    width = "half",
                    order = 2,
                },
                condition = {
                    type = 'input',
                    name = "Condition",
                    desc = "When this situation should be activated.",
                    get = function() return S.condition end,
                    set = function(_, newValue) S.condition = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    multiline = 4,
                    width = "full",
                    order = 5,
                },
                init = {
                    type = 'input',
                    name = "Initialization Script",
                    desc = "Called when the situation is loaded and when it is modified.",
                    get = function() return S.executeOnInit end,
                    set = function(_, newValue) S.executeOnInit = newValue; Options:SendMessage("DC_SITUATION_UPDATED", SID) end,
                    multiline = 4,
                    width = "full",
                    order = 10,
                },
                onEnter = {
                    type = 'input',
                    name = "On Enter Script",
                    desc = "Called when the situation is selected as the active situation (before any thing else).",
                    get = function() return S.executeOnEnter end,
                    set = function(_, newValue) S.executeOnEnter = newValue end,
                    multiline = 4,
                    width = "full",
                    order = 20,
                },
                OnExit = {
                    type = 'input',
                    name = "On Exit Script",
                    desc = "Called when the situation is overridden by another situation or the condition fails a check (before any thing else).",
                    get = function() return S.executeOnExit end,
                    set = function(_, newValue) S.executeOnExit = newValue end,
                    multiline = 4,
                    width = "full",
                    order = 30,
                },
            },
        },
    },
};


----------
-- CORE --
----------
function Options:OnInitialize()
    -- make sure to select something for the UI
    self:SelectSituation();

    -- register the gui with AceConfig and Blizz Options
    self:RegisterMenus();
end

function Options:OnEnable()
    -- register for dynamiccam messages
    self:RegisterMessage("DC_SITUATION_ACTIVE", "SelectSituation");
    self:RegisterMessage("DC_SITUATION_INACTIVE", "SelectSituation");
    self:RegisterMessage("DC_SITUATION_ENTERED", "SelectSituation");
    self:RegisterMessage("DC_SITUATION_EXITED", "SelectSituation");
end

function Options:OnDisable()
    self:UnregisterAllMessages();
end


---------
-- GUI --
---------
function Options:ClearSelection()
    SID = nil;
    S = nil;
end

function Options:SelectSituation()
    if (parent.currentSituationID) then
        for id, situation in pairs(parent.db.profile.situations) do
            if (id == parent.currentSituationID) then
                S = situation;
                SID = id;
            end
        end
    else
        if (not SID or not S) then
            SID, S = next(parent.db.profile.situations);
        end
    end

    LibStub("AceConfigRegistry-3.0"):NotifyChange("DynamicCam Situations");
end

function Options:RegisterMenus()
    -- setup menu
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam", general);
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam", "DynamicCam");

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam Settings", settings);
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam Settings", "Settings", "DynamicCam");

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam Situations", situationOptions);
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam Situations", "Situations", "DynamicCam");

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(parent.db));
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam Profiles", "Profiles", "DynamicCam");
end
