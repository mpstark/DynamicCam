-------------
-- GLOBALS --
-------------
assert(DynamicCam);
DynamicCam.Options = DynamicCam:NewModule("Options");


------------
-- LOCALS --
------------
local Options = DynamicCam.Options;
local parent = DynamicCam;
local _;
local S, Skey;

local welcomeMessage = [[Hello and welcome to an extremely prerelease build of DynamicCam!

Things will be a broken, unstable, horrible mess -- but you signed up for that right? Keep in mind that the "ActionCam" is extremely new and could be removed or changed in any new build that Blizzard deploys. Also keep in mind that the WoW Camera API is extremely limited and I have to restort to "tricks" to do many things, so it might break.

If you find a problem, PLEASE GET IN TOUCH WITH ME! It's really important that I know about problems right now, so I can fix them. Use reddit (I'm /u/mpstark) or the Discord (you should have gotten an invite link!) to get in touch with me for now.]];
local knownIssues = [[- Views in WoW are.. odd, I would recommend using them with caution
- Fit nameplates is still a work in progress, can do a little in-and-out number
- Not all planned situations are in, notably PvP ones are missing
- Missing a lot of the advanced options such as add/remove situation, import/export, etc.
- The defaults are placeholder ones, a much more robust system is planned
- Boss vs. Trash combat can be a little wonky]];
local changelog = {
[[As always, you have to reset your profile to get the changes to the defaults,including changes to condition, or even new situations, if you want them.]],
[[Test Version 13:
    - FORCED DATABASE RESET!
    - Event-based checking instead of polling -- large performance gain!
    - Removed frame hiding functionality, but hiding entire UI still supported
        - out-of-scope -- this is a camera addon
        - problems regarding UI taint didn't help
    - Nameplate Fit has a new option; Entry Zoom as Min, which will basically make fit not zoom in
    - Nameplate fit is more consistant and has a reduced delay (from 250ms instead of 500ms)
    - Defaults:
        - mounted situations now consolidated into a single situation
        - Hearth/Teleport now tracks mage teleports (not portals) and Death Gate and Skyhold Jump
    - Fixed some bugs:
        - zoom restoration not working because of rounding issues or because of other zoom
        - a situation's zoom wouldn't actually be applied if a zoom was already occuring
        - nameplate settings should no longer cause taint]],
[[Test Version 12:
    - The addon is now using the new GetCameraZoom() API
    - Fixed zoom level not restoring after a nameplate fit
    - Nameplate fit is now delayed a tiny bit so that the camera can adjust before we try to fit]],
[[Test Version 11 HOTFIX:
    - Changed the way that we handle lack of zoom confidence, it'll use factor instead
        - This is an imperfect solution because I can't get adjust it lower than 1, so any zoom lower than 15
            will adjust to 15 then adjust to the actual zoom that we wanted
    - Changed defaults to factor in new max zoom
    - Fixed default condition for a couple situations causing a memory leak
    - I WOULD HIGHLY RECOMMEND RESETING YOUR PROFILE]],
[[Test Version 11:
    - Raid and dungeon default situations added
        - These are disabled by default
        - These don't actually do anything, enable them and customize them to your hearts content
        - I'd love to hear if you really like particular settings here
    - PVP situations delayed for now, the dropdown is getting cluttered and I need to find a way to organize it
    - The select-a-situation dropdown is now color-coded
        - Grey is for disabled situations
        - Green is for the currently active situation
        - Blue is for situations that the condition is active but aren't currently selected because of priority
        - White is for everything else
    - "Zoom Fit" now called "Zoom Fit Nameplates"
    - Added some advanced options under "Zoom Fit Nameplates"
    - Save/Restore zoom level has been removed, will probably be back in some form
    - More fit nameplates tweaks
        - Blizz changes to positioning have been adjusted for
        - zoom confidence is restored when the zooming is done
        - add a 100ms delay on zoom-fit between in and out
            - it shouldn't wobble as much and is easier to track
    - MaxZoom and ZoomSpeed should be properly restored in a couple "weird" situations
        - hopefully this resolves ZoomSpeed getting stuck (especially when zoom is slowed)
        - IF YOU ENCOUNTER A PROBLEM WITH MAX ZOOM OR ZOOM SPEED PLEASE TELL ME!
    - Dynamic Pitch in options now can be set to not affect the current setting at all (grey checkbox)]],
[[Test Version 10:
    - Defaults changed to include zoom fit with continous on in the World Combat situations
    - Defaults changed with more overall tweaks, again, won't touch any saved settings
        - Biggest change is, at least for now, headMovement is disabled by default on all situations
    - You can now toggle broad nameplate settings in a situation's settings
        - CAREFUL WITH THIS, IT WILL NOT WORK IN COMBAT
        - Default situation NPC Interaction automatically turns on friendly nameplates now
    - When nameplate fit is used, it will try until it finds a nameplate for a target
        - Useful for waiting for nameplates to turn on, after using the new nameplate toggle settings
    - Hopefully fixed a bug that could set your max zoom to 0, sorry about that!
    - The UI doesn't allow you to use view 1 anymore, since it's reserved for save/restore views
    - Lots of fit nameplate tweaks, should just be overall better
    - Fit nameplates with continous enabled will now work if you don't have a target when situation starts
    - Fit nameplates will work more consistantly (it deals with lack of zoom confidence)]],
[[Test Version 9:
    - Nameplate zoom should be a little more responsive
    - New option for Zoom Fit; Fit Continously, will keep trying to adjust zoom after initial fit
        - only works while fitNameplate is enabled
    - Fixed nameplate zoom-in when the camera is further out than the situation's max
    - Fixed '/zc'; this resets zoom to a known good value
    - Default NPC interaction now affect order hall recruiters
    - GUI will now prefer to have the current situation open
        - An open GUI will swap situations when the current situation swaps as well
            - Tell me if this is annoying!
    - Some code re-organization]],
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
                advanced = {
                    type = 'toggle',
                    name = "Advanced Options",
                    desc = "If you would like to see advanced options",
                    get = function() return DynamicCam.db.profile.advanced; end,
                    set = function(_, newValue) DynamicCam.db.profile.advanced = newValue; end,
                    order = 2,
                },
                debugMode = {
                    type = 'toggle',
                    name = "Debug Mode",
                    desc = "Print out annoying debug messages, don't do this unless you need to.",
                    get = function() return DynamicCam.db.profile.debugMode; end,
                    set = function(_, newValue) DynamicCam.db.profile.debugMode = newValue; end,
                    order = 3,
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
        cvarOptions = {
            name = "Raw CVars",
            type = 'group',
            order = 2,
            inline = true,
            hidden = function() return (not DynamicCam.db.profile.advanced) end,
            args = {
                reset = {
                    type = 'execute',
                    name = "Reset All",
                    desc = "Reset all CVars to default values",
                    confirm = true,
                    func = "ResetCVars",
                    width = "full",
                    order = 0,
                },
                settings = {
                    type = 'group',
                    name = "Settings (Raw CVar)",
                    order = 2,
                    inline = true,
                    args = {
                        focusTarget = {
                            type = 'toggle',
                            name = "Target Focus",
                            desc = "If the camera should try to move to capture the target in frame",
                            get = function() return (GetCVar("cameralockedtargetfocusing") == "1") end,
                            set = function(_, newValue) SetCVar("cameralockedtargetfocusing", (newValue and 1 or 0)) end,
                            order = 1,
                        },
                        overShoulder = {
                            type = 'range',
                            name = "Shoulder Offset",
                            desc = "Positive is over right shoulder, negative is over left shoulder",
                            min = -10,
                            max = 10,
                            softMin = -5,
                            softMax = 5,
                            step = .1,
                            get = function() return tonumber(GetCVar("cameraovershoulder")) end,
                            set = function(_, newValue) SetCVar("cameraovershoulder", newValue) end,
                            order = 2,
                        },
                        distance = {
                            type = 'range',
                            name = "Max Camera Distance Factor",
                            desc = "How far away the camera can get away from your character",
                            min = 0,
                            max = 1.9,
                            step = .1,
                            get = function() return tonumber(GetCVar("cameradistancemaxfactor")) end,
                            set = function(_, newValue) SetCVar("cameradistancemaxfactor", newValue) end,
                            order = 2.5,
                        },
                        cameraDistanceMoveSpeed = {
                            type = 'range',
                            name = "Camera Zoom Speed",
                            desc = "How fast the camera moves",
                            min = 1,
                            max = 50,
                            step = .1,
                            get = function() return tonumber(GetCVar("cameraDistanceMoveSpeed")) end,
                            set = function(_, newValue) SetCVar("cameraDistanceMoveSpeed", newValue) end,
                            order = 2.6,
                        },
                        dynamicPitchToggle = {
                            type = 'toggle',
                            name = "Dynamic Pitch",
                            desc = "Seems to adjust pitch on zoom",
                            get = function() return (GetCVar("cameradynamicpitch") == "1") end,
                            set = function(_, newValue) SetCVar("cameradynamicpitch", (newValue and 1 or 0)) end,
                            width = "full",
                            order = 3,
                        },
                        dynamicPitch = {
                            type = 'group',
                            name = "Dynamic Pitch Options",
                            order = 4,
                            inline = true,
                            disabled = function() return (GetCVar("cameradynamicpitch") == "0") end,
                            args = {
                                basefovpad = {
                                    type = 'range',
                                    name = "Base FOV Pad",
                                    desc = "No idea what this actually does",
                                    min = 0,
                                    max = 1,
                                    step = .01,
                                    get = function() return tonumber(GetCVar("cameradynamicpitchbasefovpad")) end,
                                    set = function(_, newValue) SetCVar("cameradynamicpitchbasefovpad", newValue) end,
                                    order = 2,
                                },
                                basefovpadflying = {
                                    type = 'range',
                                    name = "Base FOV Pad (Flying)",
                                    desc = "No idea what this actually does",
                                    min = 0,
                                    max = 1,
                                    step = .01,
                                    get = function() return tonumber(GetCVar("cameradynamicpitchbasefovpadflying")) end,
                                    set = function(_, newValue) SetCVar("cameradynamicpitchbasefovpadflying", newValue) end,
                                    order = 3,
                                },
                                smartpivotcutoffdist = {
                                    type = 'range',
                                    name = "Smart Pivot Cutoff Distance",
                                    desc = "No idea what this actually does",
                                    min = 0,
                                    max = 100,
                                    softMin = 0,
                                    softMax = 50,
                                    step = .5,
                                    get = function() return tonumber(GetCVar("cameradynamicpitchsmartpivotcutoffdist")) end,
                                    set = function(_, newValue) SetCVar("cameradynamicpitchsmartpivotcutoffdist", newValue) end,
                                    order = 4,
                                },
                            },
                        },
                        headMovementToggle = {
                            type = 'toggle',
                            name = "Track Head Movement",
                            desc = "If the camera should follow the player's head movement",
                            get = function() return (tonumber(GetCVar("cameraheadmovementstrength")) > 0) end,
                            set = function(_, newValue) if (tonumber(GetCVar("cameraheadmovementstrength")) == 0) then SetCVar("cameraheadmovementstrength", 1) else SetCVar("cameraheadmovementstrength", 0) end end,
                            width = "full",
                            order = 5,
                        },
                        headMovement = {
                            type = 'group',
                            name = "Head Tracking Options",
                            order = 6,
                            inline = true,
                            args = {
                                strength = {
                                    type = 'range',
                                    name = "Strength",
                                    desc = "How much head movement affects the camera, 0 is off, 2 is \"Heavy\"",
                                    disabled = function() return (GetCVar("cameraheadmovementstrength") == "0") end,
                                    min = 0,
                                    max = 100,
                                    softMin = .1,
                                    softMax = 5,
                                    step = .1,
                                    get = function() return tonumber(GetCVar("cameraheadmovementstrength")) end,
                                    set = function(_, newValue) SetCVar("cameraheadmovementstrength", newValue) end,
                                    width = "double",
                                    order = 1,
                                },
                                movementRange = {
                                    type = 'range',
                                    name = "Movement Range",
                                    desc = "Seems to be how far the camera is allowed to move, larger is more",
                                    disabled = function() return (GetCVar("cameraheadmovementstrength") == "0") end,
                                    min = 0,
                                    max = 50,
                                    step = .5,
                                    get = function() return tonumber(GetCVar("cameraheadmovementrange")) end,
                                    set = function(_, newValue) SetCVar("cameraheadmovementrange", newValue) end,
                                    order = 3,
                                },
                                smoothRate = {
                                    type = 'range',
                                    name = "Smooth Rate",
                                    desc = "Seems to be how fast that the camera is allowed to move, larger is faster",
                                    disabled = function() return (GetCVar("cameraheadmovementstrength") == "0") end,
                                    min = .5,
                                    max = 50,
                                    step = .5,
                                    get = function() return tonumber(GetCVar("cameraheadmovementsmoothrate")) end,
                                    set = function(_, newValue) SetCVar("cameraheadmovementsmoothrate", newValue) end,
                                    order = 4,
                                },
                                whileStanding = {
                                    type = 'toggle',
                                    name = "Adjust While Standing",
                                    desc = "If the camera should track the head when the player is not moving",
                                    disabled = function() return (GetCVar("cameraheadmovementstrength") == "0") end,
                                    get = function() return (GetCVar("cameraheadmovementwhilestanding") == "1") end,
                                    set = function(_, newValue) SetCVar("cameraheadmovementwhilestanding", (newValue and 1 or 0)) end,
                                    order = 2,
                                },
                            },
                        },
                    },
                },
            },
        },
    },
};
local settings = {
    name = "Settings",
    handler = DynamicCam,
    type = 'group',
    args = {
        settings = {
            type = 'group',
            name = "Global Addon Settings",
            order = 1,
            inline = true,
            hidden = true,
            args = {
                reactiveZoom = {
                    type = 'toggle',
                    name = "Reactive Zoom Speed",
                    desc = "If the camera should adjust its speed based on how far it needs to zoom",
                    get = function() return DynamicCam.db.profile.settings.reactiveZoom; end,
                    set = function(_, newValue) DynamicCam.db.profile.settings.reactiveZoom = newValue; end,
                    order = 0,
                },
                reactiveZoomTime = {
                    type = 'range',
                    name = "Max Zoom Time",
                    desc = "The max time that the camera can take to zoom, though lower values with high zoom amounts can be a little broken",
                    min = .5,
                    max = 2,
                    step = .05,
                    get = function() return DynamicCam.db.profile.settings.reactiveZoomTime; end,
                    set = function(_, newValue) DynamicCam.db.profile.settings.reactiveZoomTime = newValue; end,
                    order = 1,
                    width = "double",
                },
            },
        },
        defaultCvars = {
            type = 'group',
            name = "Default Camera Settings",
            order = 2,
            inline = true,
            args = {
                cameradynamicpitch = {
                    type = 'toggle',
                    name = "Dynamic Pitch",
                    desc = "If the camera should use dynamic pitch",
                    get = function() return (DynamicCam.db.profile.defaultCvars["cameradynamicpitch"] == 1) end,
                    set = function(_, newValue) if (newValue) then DynamicCam.db.profile.defaultCvars["cameradynamicpitch"] = 1; else DynamicCam.db.profile.defaultCvars["cameradynamicpitch"] = 0; end end,
                    order = 0,
                },
                cameralockedtargetfocusing = {
                    type = 'toggle',
                    name = "Target Lock/Focus",
                    desc = "If the camera should follow the target",
                    get = function() return (DynamicCam.db.profile.defaultCvars["cameralockedtargetfocusing"] == 1) end,
                    set = function(_, newValue) if (newValue) then DynamicCam.db.profile.defaultCvars["cameralockedtargetfocusing"] = 1; else DynamicCam.db.profile.defaultCvars["cameralockedtargetfocusing"] = 0; end end,
                    order = 0.5,
                },
                cameraDistanceMaxFactor = {
                    type = 'range',
                    name = "Camera Max Distance",
                    desc = "Factor for the camera max distance, but total max won't exceed 28.5",
                    min = 1,
                    max = 1.9,
                    step = .01,
                    get = function() return DynamicCam.db.profile.defaultCvars["cameraDistanceMaxFactor"] end,
                    set = function(_, newValue) DynamicCam.db.profile.defaultCvars["cameraDistanceMaxFactor"] = newValue; end,
                    order = 2,
                    width = "full",
                },
                cameraDistanceMoveSpeed = {
                    type = 'range',
                    name = "Camera Move Speed",
                    desc = "How fast the camera zooms in",
                    min = 1,
                    max = 50,
                    step = .5,
                    get = function() return DynamicCam.db.profile.defaultCvars["cameraDistanceMoveSpeed"] end,
                    set = function(_, newValue) DynamicCam.db.profile.defaultCvars["cameraDistanceMoveSpeed"] = newValue; end,
                    order = 3,
                    width = "full",
                },
                cameraovershoulder = {
                    type = 'range',
                    name = "Camera Shoulder Offset",
                    desc = "The offset from the shoulder, negative values are to the left, postive to the right",
                    min = -5,
                    max = 5,
                    step = .1,
                    get = function() return DynamicCam.db.profile.defaultCvars["cameraovershoulder"] end,
                    set = function(_, newValue) DynamicCam.db.profile.defaultCvars["cameraovershoulder"] = newValue; end,
                    order = 4,
                    width = "full",
                },
                cameraheadmovementstrength = {
                    type = 'range',
                    name = "Head Movement Strength",
                    desc = "How much the camera should track the character's head movements, 0 is off",
                    min = 0,
                    max = 100,
                    softMax = 5,
                    step = .5,
                    get = function() return DynamicCam.db.profile.defaultCvars["cameraheadmovementstrength"] end,
                    set = function(_, newValue) DynamicCam.db.profile.defaultCvars["cameraheadmovementstrength"] = newValue; end,
                    order = 5,
                    width = "full",
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
            get = function() return Skey end,
            set = function(_, newValue) S = DynamicCam.db.profile.situations[newValue]; Skey = newValue; end,
            values = "GetSituationList",
            width = "full",
            order = 1,
        },
        enabled = {
            type = 'toggle',
            name = "Enabled",
            desc = "If this situation should be checked and activated",
            hidden = function() return (not S) end,
            get = function() return S.enabled end,
            set = function(_, newValue) S.enabled = newValue end,
            width = "half",
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
                    set = function(_, newValue) S.cameraActions.rotate = newValue end,
                    order = 2,
                },
                view = {
                    type = 'toggle',
                    name = "Set View",
                    desc = "When this situation is activated (and only then), the selected view will be set",
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
                            step = .1,
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
                            desc = "How the camera should react to this situation with regards to zoom",
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
                            max = 28.5,
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
                            max = 28.5,
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
                            max = 28.5,
                            step = .5,
                            get = function() return S.cameraActions.zoomMax end,
                            set = function(_, newValue) S.cameraActions.zoomMax = newValue; end,
                            order = 4,
                        },
                        fitContinously = {
                            type = 'toggle',
                            name = "Continously Adjust",
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
                            width = "double",
                            order = 7,
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
            hidden = function() return (not S) end,
            disabled = function() return (not S.enabled) end,
            args = {
                overShoulderToggle = {
                    type = 'toggle',
                    name = "Adjust Shoulder Offset",
                    desc = "If this setting should be affected",
                    get = function() return (S.cameraCVars["cameraovershoulder"] ~= nil) end,
                    set = function(_, newValue) if (newValue) then S.cameraCVars["cameraovershoulder"] = 0 else S.cameraCVars["cameraovershoulder"] = nil end end,
                    order = 0,
                },
                overShoulder = {
                    type = 'range',
                    name = "Shoulder Offset Value",
                    desc = "Positive is over right shoulder, negative is over left shoulder",
                    hidden = function() return (S.cameraCVars["cameraovershoulder"] == nil) end,
                    min = -10,
                    max = 10,
                    softMin = -5,
                    softMax = 5,
                    step = .1,
                    get = function() return S.cameraCVars["cameraovershoulder"] end,
                    set = function(_, newValue) S.cameraCVars["cameraovershoulder"] = newValue end,
                    order = 10,
                    width = "full",
                },
                headTrackingToggle = {
                    type = 'toggle',
                    name = "Adjust Head Tracking",
                    desc = "If this setting should be affected",
                    get = function() return (S.cameraCVars["cameraheadmovementstrength"] ~= nil) end,
                    set = function(_, newValue) if (newValue) then S.cameraCVars["cameraheadmovementstrength"] = 0 else S.cameraCVars["cameraheadmovementstrength"] = nil end end,
                    order = 3,
                },
                headTracking = {
                    type = 'range',
                    name = "Head Tracking Strength",
                    desc = "How much head movement affects the camera, 0 is off, 2 is \"Heavy\"",
                    hidden = function() return (S.cameraCVars["cameraheadmovementstrength"] == nil) end,
                    min = 0,
                    max = 100,
                    softMax = 5,
                    step = .1,
                    get = function() return S.cameraCVars["cameraheadmovementstrength"] end,
                    set = function(_, newValue) S.cameraCVars["cameraheadmovementstrength"] = newValue end,
                    width = "full",
                    order = 12,
                },

                dynamicPitch = {
                    type = 'toggle',
                    tristate = true,
                    name = "Dynamic Pitch",
                    desc = "Adjusts pitch based on zoom level, grey checkmark means that this situation won't change the current setting",
                    get = function()
                        if (S.cameraCVars["cameradynamicpitch"] == nil) then
                            return nil;
                        elseif (S.cameraCVars["cameradynamicpitch"] == 1) then
                            return true;
                        elseif (S.cameraCVars["cameradynamicpitch"] == 0) then
                            return false;
                        end
                    end,
                    set = function(_, newValue)
                        if (newValue == nil) then
                            S.cameraCVars["cameradynamicpitch"] = nil;
                        elseif (newValue == true) then
                            S.cameraCVars["cameradynamicpitch"] = 1;
                        elseif (newValue == false) then
                            S.cameraCVars["cameradynamicpitch"] = 0;
                        end
                    end,
                    order = 4,
                },

                targetLock = {
                    type = 'toggle',
                    name = "Target Lock/Focus",
                    desc = "Let the camera try to capture the target in view",
                    get = function() return S.targetLock.enabled end,
                    set = function(_, newValue) S.targetLock.enabled = newValue end,
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
                            set = function(_, newValue) S.targetLock.onlyAttackable = newValue end,
                            order = 1,
                        },
                        dead = {
                            type = 'toggle',
                            name = "Ignore Dead",
                            desc = "Don't target lock/focus dead targets",
                            get = function() return (not S.targetLock.dead) end,
                            set = function(_, newValue) S.targetLock.dead = not newValue end,
                            order = 2,
                        },
                        nameplateVisible = {
                            type = 'toggle',
                            name = "Nameplate Visible",
                            desc = "Only target lock/focus units that have a visible nameplate",
                            get = function() return S.targetLock.nameplateVisible end,
                            set = function(_, newValue) S.targetLock.nameplateVisible = newValue end,
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
                nameplates = {
                    type = 'toggle',
                    name = "Adjust Nameplates",
                    desc = "If this setting should be affected",
                    get = function() return S.extras.nameplates end,
                    set = function(_, newValue) S.extras.nameplates = newValue end,
                    order = 2,
                },
                nameplatesGroup = {
                    type = 'group',
                    name = "Nameplates",
                    order = 3,
                    inline = true,
                    hidden = function() return (not S.extras.nameplates) end,
                    disabled = function() return (not S.enabled) end,
                    args = {
                        friendly = {
                            type = 'toggle',
                            name = "Friendly",
                            desc = "If friendly nameplates should be shown",
                            get = function() return S.extras.friendlyNP end,
                            set = function(_, newValue) S.extras.friendlyNP = newValue end,
                            order = 3,
                        },
                        enemy = {
                            type = 'toggle',
                            name = "Enemy",
                            desc = "If enemy nameplates should be shown",
                            get = function() return S.extras.enemyNP end,
                            set = function(_, newValue) S.extras.enemyNP = newValue end,
                            order = 4,
                        },
                    },
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
                condition = {
                    type = 'input',
                    name = "Condition",
                    desc = "When this situation should be activated.",
                    get = function() return S.condition end,
                    set = function(_, newValue) S.condition = newValue end,
                    width = "double",
                    order = 1,
                },
                priority = {
                    type = 'input',
                    name = "Priority",
                    desc = "If multiple situations are active at the same time, the one with the highest priority is chosen",
                    get = function() return ""..S.priority end,
                    set = function(_, newValue) if (tonumber(newValue)) then S.priority = tonumber(newValue) end end,
                    width = "half",
                    order = 2,
                },
                delay = {
                    type = 'input',
                    name = "Delay",
                    desc = "How long to delay exiting this situation",
                    get = function() return ""..S.delay end,
                    set = function(_, newValue) if (tonumber(newValue)) then S.delay = tonumber(newValue) end end,
                    width = "half",
                    order = 3,
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
end

function Options:OnDisable()
end


---------
-- GUI --
---------
function Options:SelectSituation()
    if (parent.currentSituation) then
        for key, situation in pairs(parent.db.profile.situations) do
            if (situation == parent.currentSituation) then
                Skey = key;
                S = parent.currentSituation;
            end
        end
    else
        Skey, S = next(parent.db.profile.situations);
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
