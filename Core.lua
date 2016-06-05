---------------
-- LIBRARIES --
---------------
local AceAddon = LibStub("AceAddon-3.0");


---------------
-- CONSTANTS --
---------------


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
local conditionFunctionCache = {};
local S;
local Skey;
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
                    zoomFitSave = true,
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


---------
-- GUI --
---------
-- TODO: move to another file
local welcomeMessage = [[Hello and welcome to an extremely prerelease build of DynamicCam!

Things will be a broken, unstable, horrible mess -- but you signed up for that right? Keep in mind that the "ActionCam" is extremely new and could be removed or changed in any new build that Blizzard deploys. Also, keep in mind that Blizzard doesn't provide any ways of getting information about the camera's current state, so I have to keep track of everything that affects the camera and hope that I'm guessing right (and I'm wrong a lot of the time!)

Other than that, I've been very happy with the progress so far with the addon and I hope that you like it as well. Right now, the only situations in are world content and city stuff; the addon shouldn't affect raid/dungeon/instanced PvP.

Use reddit or the Discord (you should have gotten an invite link!) to get in touch with me for now.]];

local changelog = {
[[As always, you have to reset your profile to get the new default changes if you want them.]],
[[Test Version 8:
    - Zoom fit now has a nameplate option, please break it in new and interesting ways
        - Saved zoom levels will take priority for now, but will revisit that later
        - default situation NPC Interaction now uses this, but also saved zoom, so it should only fit once and then remember
    - Should now restore zoom levels in cases where zoom was interrupted
    - Hopefully fix a rotate degrees bug where it would continously rotate
    - '/zi' slash command should be a little better and not say things that don't matter]],
[[Test Version 7:
    - Added a rotate degrees option
        - ROTATION ISN'T EXACT because of Blizzard's smoothing code, right now we're assuming linear
        - will rotate the specified amount on activation and rotate back on exit
    - Fixed max zoom getting stuck permentantly until reload
    - Situations now have a transition time, this can only be configured in advanced mode
        - Zoom speed will be changed to match the transition time
        - Defaults to .75 seconds with an option (normally on) to not slow down the camera
    - Removed "Responsive Zoom" option, since the transition time does everything that it used to and more
    - Reorganized some files, and rewrote most of the camera actions
    - GUI changed slightly to make things a little bit more obvious
    - Default NPC interactions now has a delay of 500ms, should be better for questing
    - Default Hearthing now zooms in slowly while rotating, using the new transition time
    - Hiding frames will disable their "Show" method (with the exception of UIParent)
    - Won't try to hide frames that aren't currently shown or don't exist
    - Won't try to unhide frames that we didn't hide
    - Added a bunch of default UI toggles for hiding in the settings GUI
    - Zoom fit is.. sort of there, though it simply saves/restores the zoom level for the NPC id
        - If a saved NPC id isn't there, it will zoom into min for now
    - Default NPC interactions now uses zoom fit]],
[[Test Version 6:
    - Situations can now specify a delay
        - only use if you suspect that the situation will arise within that time again
    - The NPC Interactions default now has a delay to prevent awful in and out
    - Zoom Range implemented; will zoom in if outside max, zoom out if inside min
    - Default zoom values tweaked, things should be a little further out
    - Removed Target Lock: Target in Combat since it didn't work
    - Default NPC interaction now includes bank
    - Groundwork set for quicker zooms values, max zoom time possible lowered to .5
    - Config UI should now better hide things that don't need to be there]],
[[Test Version 5:
    - NPC Interaction default changed to only trigger if interacting with NPC while also targeting that NPC
    - Fixed bug with swapping profiles
    - New default situation 'Annoying Spells'
        - it removes ActionCam settings during Bladestorm/Blade Dance]],
[[Test Version 4:
    - Changed default situation 'World (Combat)' to work in cities (reset profile to get new defaults)
    - Added new default situation 'Mailbox', I find it annoying so off by default, reset profile to get it
    - Added a vehicle situation that disables all 'ActionCam' features, since they're annoying there
    - Added a toggle in Situation Options for hiding the UI (default situations Hearthing/Taxi use it)
    - Added LICENSE.txt to the folder, we're MIT licenced now. My code is your code (with a notice).]],
[[Test Version 3:
    - Added a few new situations, a NPC interaction one and a casting Hearthstone one.
    - Change it so that zoom is restored properly if zoomed in and going back to another zoomed in]],
[[Test Version 2:
    - Added default camera settings, applied when off as well as before any situations are loaded
    - Added Reactive Zoom, should speed zoom transitions up, it's on by default.
    - Add Debug Mode, just in case, off by default]],
[[Test Version 1:
    - Initial Release]],
[[Known Issues:
    - Things can be odd when the camera has a zoom interrupted.
    - Not all planned default situations are in yet.
    - Not all advanced options are in, like the option to add situations (!), or custom lua.
    - Sometimes it loses track of zoom.
        - '/zc' will go to a known good configuration
        - '/zi' will tell you some info about what the addon currently \"knows\" about zoom.
    - Views can be odd, this is mostly a Blizzard issue.
        - '/sv #' will save a view to that number slot, # can be 2-5
    - View 1 is currently reserved by the addon for restoring views
    - Changing a situation that is active doesn't do anything immediately
        - workaround: toggle it off and then back on."]],
};

--[[
TODO
- SOON
    - implement zoom fit to nameplates
    - find new ways to zoom fit
    - fix problem with rotate degrees where the rotate is canceled on the rotate back
    - Situations should be able to specify that they are 'short term' and the previous situation shouldn't be exited
    - 'Camera Settings' should allow for not adjusting target lock or dynamic pitch at all
    - 'Interface Actions' should allow for hiding the minimap cluster, the chat, the main bar, the quest tracker, closing all panels, etc.
    - Under advanced mode, you should be able to add/delete situations
    - Don't try to hide frames that are already hidden and don't try to show frames that we didn't hide
    - Fix GUI if there is no selectedSituation
    - Shoulder offset should have an indication of what shoulder it's over instead of negative positive
    - Look into just setting the shoulder offset at a default cvar and taking it out of the default situations
- SOONISH
    - There should be several sets of defaults, with ranged classes getting one set (and a profile) and melee classes getting another (and a profile)
    - You should be able to toggle nameplate settings in situations
    - new camera action to rotate x degrees at a quickish speed
    - better combat detection
- DOWN THE LINE
    - Export and import situations
    - Slash commands for temp situations or to force an existing situation
    - Weak Aura's support
    - Have situations be able to specify events
    - Have advanced mode be able to turn off polling
    - Should be using a syntax highlighter for lua code editing in-game, but that's a ways off
    - 'Interface Actions' should allow for hiding arbitary frames while under advanced mode
    - Under advanced mode, you should be able to edit the lua functions (init, onEnter, onExit) that aren't being used right now
]]--

local options = {
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
                            name = "Max Camera Distance",
                            desc = "How far away the camera can get away from your character",
                            min = 0,
                            max = 50,
                            step = .5,
                            get = function() return tonumber(GetCVar("cameradistancemax")) end,
                            set = function(_, newValue) SetCVar("cameradistancemax", newValue) end,
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
                    name = "Target Locking",
                    desc = "If the camera should follow the target",
                    get = function() return (DynamicCam.db.profile.defaultCvars["cameralockedtargetfocusing"] == 1) end,
                    set = function(_, newValue) if (newValue) then DynamicCam.db.profile.defaultCvars["cameralockedtargetfocusing"] = 1; else DynamicCam.db.profile.defaultCvars["cameralockedtargetfocusing"] = 0; end end,
                    order = 0.5,
                },
                cameradistancemax = {
                    type = 'range',
                    name = "Camera Max Distance",
                    desc = "The max the camera can zoom out",
                    min = 0,
                    max = 50,
                    step = .5,
                    get = function() return DynamicCam.db.profile.defaultCvars["cameradistancemax"] end,
                    set = function(_, newValue) DynamicCam.db.profile.defaultCvars["cameradistancemax"] = newValue; end,
                    order = 1,
                    width = "full",
                },
                cameraDistanceMaxFactor = {
                    type = 'range',
                    name = "Camera Distance Max Factor",
                    desc = "Factor for the camera max distance, but total max won't exceed 50",
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
        enabled = {
            type = 'toggle',
            name = "Enabled",
            desc = "If this situation should be checked and activated",
            get = function() return S.enabled end,
            set = function(_, newValue) S.enabled = newValue end,
            width = "half",
            order = 2,
        },
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
        cameraActions = {
            type = 'group',
            name = "Camera Actions",
            order = 10,
            inline = true,
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
                            values = {["fit"] = "Zoom Fit", ["in"] = "Zoom In To", ["out"] = "Zoom Out To", ["set"] = "Zoom Set To", ["range"] = "Zoom Range"},
                            order = 1,
                        },
                        zoomValue = {
                            type = 'range',
                            name = "Zoom Value",
                            desc = "The zoom value to set",
                            hidden = function() return (S.cameraActions.zoomSetting == "range" or S.cameraActions.zoomSetting == "fit") end,
                            min = 0,
                            max = 50,
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
                            max = 50,
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
                            max = 50,
                            step = .5,
                            get = function() return S.cameraActions.zoomMax end,
                            set = function(_, newValue) S.cameraActions.zoomMax = newValue; end,
                            order = 4,
                        },
                        fitNameplate = {
                            type = 'toggle',
                            name = "Fit Nameplates",
                            desc = "When this situation is activated (and only then), the view will try to fit your target's nameplate.",
                            hidden = function() return not (S.cameraActions.zoomSetting == "fit") end,
                            --hidden = true,
                            get = function() return S.cameraActions.zoomFitNameplate end,
                            set = function(_, newValue) S.cameraActions.zoomFitNameplate = newValue end,
                            order = 5,
                        },
                        fitSaveHistory = {
                            type = 'toggle',
                            name = "Save Fit Level",
                            desc = "Save the zoom level for this target while exiting this situation.",
                            hidden = function() return not (S.cameraActions.zoomSetting == "fit") end,
                            get = function() return S.cameraActions.zoomFitSave end,
                            set = function(_, newValue) S.cameraActions.zoomFitSave = newValue end,
                            order = 6,
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
                            values = {"1", "2", "3", "4", "5"},
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

                distanceToggle = {
                    type = 'toggle',
                    name = "Adjust Max Distance",
                    desc = "If this setting should be affected",
                    get = function() return (S.cameraCVars["cameradistancemax"] ~= nil) end,
                    set = function(_, newValue) if (newValue) then S.cameraCVars["cameradistancemax"] = 50 else S.cameraCVars["cameradistancemax"] = nil end end,
                    order = 2,
                },
                distance = {
                    type = 'range',
                    name = "Max Camera Distance Value",
                    desc = "How far away the camera can get away from your character",
                    hidden = function() return (S.cameraCVars["cameradistancemax"] == nil) end,
                    min = 0,
                    max = 50,
                    step = .5,
                    get = function() return S.cameraCVars["cameradistancemax"] end,
                    set = function(_, newValue) S.cameraCVars["cameradistancemax"] = newValue end,
                    order = 11,
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
                    name = "Dynamic Pitch",
                    desc = "Seems to adjust pitch on zoom",
                    get = function() return (S.cameraCVars["cameradynamicpitch"] == 1) end,
                    set = function(_, newValue) S.cameraCVars["cameradynamicpitch"] = (newValue and 1 or 0) end,
                    order = 41,
                },

                targetLock = {
                    type = 'toggle',
                    name = "Target Lock",
                    desc = "Let the camera try to capture the target in view",
                    get = function() return S.targetLock.enabled end,
                    set = function(_, newValue) S.targetLock.enabled = newValue end,
                    order = 40,
                },
                targetLockSettings = {
                    type = 'group',
                    name = "Target Lock Settings",
                    order = 50,
                    inline = true,
                    hidden = function() return (not S.targetLock.enabled) end,
                    args = {
                        onlyAttackable = {
                            type = 'toggle',
                            name = "Only Attackable",
                            desc = "Only target lock attackable targets",
                            get = function() return S.targetLock.onlyAttackable end,
                            set = function(_, newValue) S.targetLock.onlyAttackable = newValue end,
                            order = 1,
                        },
                        dead = {
                            type = 'toggle',
                            name = "Ignore Dead",
                            desc = "Don't target lock dead targets",
                            get = function() return (not S.targetLock.dead) end,
                            set = function(_, newValue) S.targetLock.dead = not newValue end,
                            order = 2,
                        },
                        nameplateVisible = {
                            type = 'toggle',
                            name = "Nameplate Visible",
                            desc = "Only target lock units that have a visible nameplate",
                            get = function() return S.targetLock.nameplateVisible end,
                            set = function(_, newValue) S.targetLock.nameplateVisible = newValue end,
                            order = 4,
                        },
                    },
                },
            },
        },
        interfaceActions = {
            type = 'group',
            name = "Interface Actions",
            order = 30,
            inline = true,
            disabled = function() return (not S.enabled) end,
            args = {
                entireUI = {
                    type = 'toggle',
                    name = "Hide Entire UI",
                    desc = "Hide the entire UI during this situation.",
                    get = function() return (S.hideFrames["UIParent"]) end,
                    set = function(_, newValue) if (newValue) then S.hideFrames["UIParent"] = true else S.hideFrames["UIParent"] = nil end end,
                    order = 1,
                },
                minimap = {
                    type = 'toggle',
                    name = "Hide Minimap",
                    desc = "Hide the minimap during this situation.",
                    get = function() return (S.hideFrames["MinimapCluster"]) end,
                    set = function(_, newValue) if (newValue) then S.hideFrames["MinimapCluster"] = true else S.hideFrames["MinimapCluster"] = nil end end,
                    order = 2,
                },
                buffFrame = {
                    type = 'toggle',
                    name = "Hide Buffs",
                    desc = "Hide the buff frame during this situation.",
                    get = function() return (S.hideFrames["BuffFrame"]) end,
                    set = function(_, newValue) if (newValue) then S.hideFrames["BuffFrame"] = true else S.hideFrames["BuffFrame"] = nil end end,
                    order = 3,
                },
                objectiveFrame = {
                    type = 'toggle',
                    name = "Hide Objectives",
                    desc = "Hide the objective frame during this situation.",
                    get = function() return (S.hideFrames["ObjectiveTrackerFrame"]) end,
                    set = function(_, newValue) if (newValue) then S.hideFrames["ObjectiveTrackerFrame"] = true else S.hideFrames["ObjectiveTrackerFrame"] = nil end end,
                    order = 4,
                },
                -- playerFrame = {
                    -- type = 'toggle',
                    -- name = "Hide Player Frame",
                    -- desc = "Hide the player unit frame.",
                    -- get = function() return (S.hideFrames["PlayerFrame"]) end,
                    -- set = function(_, newValue) if (newValue) then S.hideFrames["PlayerFrame"] = true else S.hideFrames["PlayerFrame"] = nil end end,
                    -- order = 5,
                -- },
                -- targetFrame = {
                    -- type = 'toggle',
                    -- name = "Hide Target Frame",
                    -- desc = "Hide the target unit frame.",
                    -- get = function() return (S.hideFrames["TargetFrame"]) end,
                    -- set = function(_, newValue) if (newValue) then S.hideFrames["TargetFrame"] = true else S.hideFrames["TargetFrame"] = nil end end,
                    -- order = 6,
                -- },
                chatFrame = {
                    type = 'toggle',
                    name = "Hide Chat Frame",
                    desc = "Hide the selected chat frame during this situation.",
                    get = function() return (S.hideFrames["SELECTED_CHAT_FRAME"]) end,
                    set = function(_, newValue) if (newValue) then S.hideFrames["SELECTED_CHAT_FRAME"] = true else S.hideFrames["SELECTED_CHAT_FRAME"] = nil end end,
                    order = 10,
                },
                generalDockManager = {
                    type = 'toggle',
                    name = "Hide Chat Dock",
                    desc = "Hide the \"General Dock Manager\" during this situation.",
                    get = function() return (S.hideFrames["GeneralDockManager"]) end,
                    set = function(_, newValue) if (newValue) then S.hideFrames["GeneralDockManager"] = true else S.hideFrames["GeneralDockManager"] = nil end end,
                    order = 11,
                },
                friendsMicroButton = {
                    type = 'toggle',
                    name = "Hide Friends Button",
                    desc = "Hide the \"Friends Micro Button\" during this situation.",
                    get = function() return (S.hideFrames["FriendsMicroButton"]) end,
                    set = function(_, newValue) if (newValue) then S.hideFrames["FriendsMicroButton"] = true else S.hideFrames["FriendsMicroButton"] = nil end end,
                    order = 12,
                },
                chatFrameMenuButton = {
                    type = 'toggle',
                    name = "Hide Chat Menu",
                    desc = "Hide the Chat Frame Menu Button during this situation.",
                    get = function() return (S.hideFrames["ChatFrameMenuButton"]) end,
                    set = function(_, newValue) if (newValue) then S.hideFrames["ChatFrameMenuButton"] = true else S.hideFrames["ChatFrameMenuButton"] = nil end end,
                    order = 13,
                },
                mainMenuBar = {
                    type = 'toggle',
                    name = "Hide Main Bar",
                    desc = "Hide the Main Bar during this situation.",
                    get = function() return (S.hideFrames["MainMenuBar"]) end,
                    set = function(_, newValue) if (newValue) then S.hideFrames["MainMenuBar"] = true else S.hideFrames["MainMenuBar"] = nil end end,
                    order = 50,
                },
            },
        },
        advanced = {
            type = 'group',
            name = "Advanced",
            order = 40,
            inline = true,
            hidden = function() return (not DynamicCam.db.profile.advanced) end,
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

    -- setup menu
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam", options);
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam", "DynamicCam");

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam Settings", settings);
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam Settings", "Settings", "DynamicCam");

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam Situations", situationOptions);
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam Situations", "Situations", "DynamicCam");

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db));
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam Profiles", "Profiles", "DynamicCam");

    -- disable if the setting is enabled
    if (not self.db.profile.enabled) then
        self:Disable();
    end
end

function DynamicCam:OnEnable()
    self.db.profile.enabled = true;
    Camera = DynamicCam.Camera;

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
        if (not conditionFunctionCache[situation.condition]) then
            conditionFunctionCache[situation.condition] = assert(loadstring(situation.condition));
        end

        -- evaluate the condition, if it checks out and the priority is larger then any other, set it
        if (situation.enabled and conditionFunctionCache[situation.condition]() and (situation.priority > highestPriority)) then
            highestPriority = situation.priority;
            topSituation = situation;
            topSituationName = name;
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
        adjustedZoom = Camera:ZoomFit(situation.cameraActions.zoomMin, situation.cameraActions.zoomMax, situation.cameraActions.zoomFitNameplate, situation.cameraActions.zoomFitSave, situation.cameraActions.transitionTime, situation.cameraActions.timeIsMax);
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
        Camera:SetZoom(restoration[situation].zoom, .75, true); -- look into constant times here
        self:DebugPrint("Restoring zoom level.");
    else
        self:DebugPrint("Not restoring zoom level.");
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

    for k, v in pairs(self.db.profile.situations) do
        situationList[k] = k.." | "..v.name;
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
    newSituation.cameraActions.zoomMin = 10;
    newSituation.cameraActions.zoomMax = 20;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    situations["001"] = newSituation;

    newSituation = self:CreateSituation("City (Indoors)");
    newSituation.priority = 11;
    newSituation.condition = "return IsResting() and IsIndoors();";
    newSituation.cameraActions.zoomSetting = "in";
    newSituation.cameraActions.zoomValue = 7;
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
    newSituation.cameraActions.zoomMin = 12;
    newSituation.cameraActions.zoomMax = 20;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    newSituation.targetLock.enabled = true;
    situations["004"] = newSituation;

    newSituation = self:CreateSituation("World (Indoors)");
    newSituation.priority = 10;
    newSituation.condition = "return not IsResting() and not IsInInstance() and IsIndoors();";
    newSituation.cameraActions.zoomSetting = "in";
    newSituation.cameraActions.zoomValue = 10;
    newSituation.cameraCVars["cameraovershoulder"] = 1;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    newSituation.targetLock.enabled = true;
    situations["005"] = newSituation;

    newSituation = self:CreateSituation("World (Combat)");
    newSituation.priority = 50;
    newSituation.condition = "return not IsInInstance() and UnitAffectingCombat(\"player\");";
    newSituation.cameraActions.zoomSetting = "in";
    newSituation.cameraActions.zoomValue = 8;
    newSituation.cameraCVars["cameraovershoulder"] = 1.5;
    newSituation.cameraCVars["cameradynamicpitch"] = 1;
    newSituation.cameraCVars["cameraheadmovementstrength"] = 2;
    newSituation.targetLock.enabled = true;
    newSituation.targetLock.nameplateVisible = false;
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
    newSituation.condition = "local spells = {46924, 188499}; for k,v in pairs(spells) do if (UnitBuff(\"player\", GetSpellInfo(v))) then return true; end end return false;";
    newSituation.cameraCVars["cameraheadmovementstrength"] = 0;
    newSituation.cameraCVars["cameradynamicpitch"] = 0;
    newSituation.cameraCVars["cameraovershoulder"] = 0;
    situations["201"] = newSituation;

    newSituation = self:CreateSituation("NPC Interaction");
    newSituation.priority = 20;
    newSituation.delay = .5;
    newSituation.condition = "return (UnitExists(\"npc\") and UnitIsUnit(\"npc\", \"target\")) and ((BankFrame and BankFrame:IsShown()) or (MerchantFrame and MerchantFrame:IsShown()) or (GossipFrame and GossipFrame:IsShown()) or (ClassTrainerFrame and ClassTrainerFrame:IsShown()) or (QuestFrame and QuestFrame:IsShown()))";
    newSituation.cameraActions.zoomSetting = "fit";
    newSituation.cameraActions.zoomFitNameplate = true;
    newSituation.cameraActions.zoomFitSave = true;
    newSituation.cameraActions.zoomMin = 3;
    newSituation.cameraActions.zoomMax = 30;
    newSituation.cameraActions.zoomValue = 4;
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
            zoomFitSave = true,
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

    -- make sure to select something for the UI
    Skey, S = next(self.db.profile.situations);

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
    Camera:ResetConfidence();
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
