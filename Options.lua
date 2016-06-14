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
local changelog = {
[[As always, you have to reset your profile to get the changes to the defaults,including changes to condition, or even new situations, if you want them.]],
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
    - More Zoom-to-fit tweaks
        - behavior around the edges of min/max should be better
            - hopefully this should stop zooming more than the set min/max
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
[[Test Version 8:
    - Zoom fit now has a nameplate option, please break it in new and interesting ways
        - Saved zoom levels will take priority for now, but will revisit that later
        - NPC Interaction default now uses this, but also saved zoom, so it should only fit once and then remember
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
                    name = "Target Lock/Focus",
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
                        fitContinously = {
                            type = 'toggle',
                            name = "Fit Continously",
                            desc = "Keep trying to fit after initial fit. EXPERIMENTAL!",
                            hidden = function() return (not (S.cameraActions.zoomSetting == "fit")) or (not S.cameraActions.zoomFitNameplate) end,
                            get = function() return S.cameraActions.zoomFitContinous end,
                            set = function(_, newValue) S.cameraActions.zoomFitContinous = newValue end,
                            order = 6,
                        },
                        fitSaveHistory = {
                            type = 'toggle',
                            name = "Save/Restore Fit",
                            desc = "Save the zoom level for this target while exiting this situation.",
                            hidden = function() return not (S.cameraActions.zoomSetting == "fit") end,
                            get = function() return S.cameraActions.zoomFitSave end,
                            set = function(_, newValue) S.cameraActions.zoomFitSave = newValue end,
                            order = 7,
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
                    order = 41,
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
        interfaceActions = {
            type = 'group',
            name = "Interface Actions",
            order = 30,
            inline = true,
            hidden = function() return (not S) end,
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
        nameplateSettings = {
            type = 'group',
            name = "Nameplate Settings",
            order = 40,
            inline = true,
            hidden = function() return (not S) end,
            disabled = function() return (not S.enabled) end,
            args = {
                adjust = {
                    type = 'toggle',
                    name = "Adjust Nameplates",
                    desc = "If this setting should be affected",
                    get = function() return ((S.cameraCVars["nameplateShowAll"] ~= nil) or (S.cameraCVars["nameplateShowEnemies"] ~= nil) or (S.cameraCVars["nameplateShowFriends"] ~= nil)) end,
                    set = function(_, newValue) if (newValue) then S.cameraCVars["nameplateShowAll"] = 1; S.cameraCVars["nameplateShowEnemies"] = 1; S.cameraCVars["nameplateShowFriends"] = 1; else S.cameraCVars["nameplateShowAll"] = nil; S.cameraCVars["nameplateShowEnemies"] = nil; S.cameraCVars["nameplateShowFriends"] = nil; end end,
                    order = 0,
                },
                all = {
                    type = 'toggle',
                    name = "Global",
                    desc = "If nameplates should be shown at all",
                    hidden = function() return (not S.cameraCVars["nameplateShowAll"]) end,
                    get = function() return (S.cameraCVars["nameplateShowAll"] == 1) end,
                    set = function(_, newValue) if (newValue) then S.cameraCVars["nameplateShowAll"] = 1 else S.cameraCVars["nameplateShowAll"] = 0 end end,
                    order = 1,
                },
                friendly = {
                    type = 'toggle',
                    name = "Friendly",
                    desc = "If friendly nampltes should be shown",
                    hidden = function() return (not S.cameraCVars["nameplateShowFriends"]) end,
                    get = function() return (S.cameraCVars["nameplateShowFriends"] == 1) end,
                    set = function(_, newValue) if (newValue) then S.cameraCVars["nameplateShowFriends"] = 1 else S.cameraCVars["nameplateShowFriends"] = 0 end end,
                    order = 2,
                },
                enemy = {
                    type = 'toggle',
                    name = "Enemy",
                    desc = "If enemy nameplates should be shown",
                    hidden = function() return (not S.cameraCVars["nameplateShowEnemies"]) end,
                    get = function() return (S.cameraCVars["nameplateShowEnemies"] == 1) end,
                    set = function(_, newValue) if (newValue) then S.cameraCVars["nameplateShowEnemies"] = 1 else S.cameraCVars["nameplateShowEnemies"] = 0 end end,
                    order = 3,
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
