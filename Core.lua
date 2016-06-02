---------------
-- LIBRARIES --
---------------
local AceAddon = LibStub("AceAddon-3.0");


---------------
-- CONSTANTS --
---------------
local CONTINOUS_FUDGE_FACTOR = 1.1;


-------------
-- GLOBALS --
-------------
DynamicCam = AceAddon:NewAddon("DynamicCam", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceHook-3.0");
DynamicCam.currentSituation = nil;


------------
-- LOCALS --
------------
local _;
local conditionFunctionCache = {};
local zoom = {
	value = 0,
	relative = true,
	confident = true,
	inDoneTime = nil,
	outDoneTime = nil,
	continousStartTime = nil,
	continousIn = false,
	continousOut = false,
	continousSpeed = 1,
}
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
					rotate = false,
					rotateSpeed = .1,
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
local welcomeMessage = "Hello and welcome to an extremely prerelease build of DynamicCam!\n\nThings will be a broken, unstable, horrible mess -- but you signed up for that right? Keep in mind that the \"ActionCam\" is extremely new and could be removed or changed in any new build that Blizzard deploys. Also, keep in mind that Blizzard doesn't provide any ways of getting information about the camera's current state, so I have to keep track of everything that affects the camera and hope that I'm guessing right (and I'm wrong a lot of the time!)\n\nOther than that, I've been very happy with the progress so far with the addon and I hope that you like it as well. Right now, the only situations in are world content and city stuff; the addon shouldn't affect raid/dungeon/instanced PvP.\n\nUse reddit or the Discord (you should have gotten an invite link!) to get in touch with me for now.";
local changelog = {
	"As always, you have to reset your profile to get the new default changes if you want them.",
	"Test Version 7:\n  - Continous Zooms are now tracked and don't confuse the guessed zoom level.\n",
	"Test Version 6:\n  - Situations can now specify a delay; only use if you suspect that the situation will arise within that time again\n  - The NPC Interactions default now has a delay to prevent awful in and out\n  - Zoom Range implemented; will zoom in if outside max, zoom out if inside min\n  - Default zoom values tweaked, things should be a little further out.\n  - Removed Target Lock: Target in Combat since it didn't work\n  - Default NPC interaction now includes bank\n  - Groundwork set for quicker zooms values, max zoom time possible lowered to .5\n  - Config UI should now better hide things that don't need to be there",
	"Test Version 5:\n  - NPC Interaction default changed to only trigger if interacting with NPC while also targeting that NPC\n  - Fixed bug with swapping profiles\n  - New default situation 'Annoying Spells' -- it removes ActionCam settings during Bladestorm/Blade Dance",
	"Test Version 4:\n  - Changed default situation 'World (Combat)' to work in cities (reset profile to get new defaults)\n  - Added new default situation 'Mailbox', I find it annoying so off by default, reset profile to get it\n  - Added a vehicle situation that disables all 'ActionCam' features, since they're annoying there\n  - Added a toggle in Situation Options for hiding the UI (default situations Hearthing/Taxi use it)\n  - Added LICENSE.txt to the folder, we're MIT licenced now. My code is your code (with a notice).",
	"Test Version 3:\n  - Added a few new situations, a NPC interaction one and a casting Hearthstone one.\n  - Change it so that zoom is restored properly if zoomed in and going back to another zoomed in",
	"Test Version 2:\n  - Added default camera settings, applied when off as well as before any situations are loaded\n  - Added Reactive Zoom, should speed zoom transitions up, it's on by default.\n  - Add Debug Mode, just in case, off by default",
	"Test Version 1:\n  - Initial Release",
	"Known Issues:\n  - Max Zoom can get stuck in very occasionally when swapping situations quickly\n  - Things can be odd when the camera has a zoom interrupted.\n  - Not all planned default situations are in yet.\n  - Not all advanced options are in, like the option to add situations (!), or custom lua.\n  - Sometimes it loses track of zoom.\n      '/zc' will go to a known good configuration\n      '/zi' will tell you some info about what the addon currently \"knows\" about zoom.\n  - Views can be odd, this is mostly a Blizzard issue.\n      '/sv #' will set a view to that number slot, # can be 2-5\n  - View 1 is currently reserved by the addon.\n  - Changing a situation that is active doesn't do anything immediately; workaround, toggle it off and then back on.",
};

--[[
TODO
- SOON
	- implement zoom fit, which will fit zoom to the current target on activation
	- Situations should be able to specify that they are 'short term' and the previous situation shouldn't be exited
	- 'Camera Settings' should allow for not adjusting target lock or dynamic pitch at all
	- 'Interface Actions' should allow for hiding the minimap cluster, the chat, the main bar, the quest tracker, closing all panels, etc.
	- Under advanced mode, you should be able to add/delete situations
	- Don't try to hide frames that are already hidden and don't try to show frames that we didn't hide
	- Fix min zoom speed below ~.5, because there is something really broken there
	- Fix GUI if there is no selectedSituation
	- Shoulder offset should have an indication of what shoulder it's over instead of negative positive
	- Look into just setting the shoulder offset at a default cvar and taking it out of the default situations
- SOONISH
	- There should be several sets of defaults, with ranged classes getting one set (and a profile) and melee classes getting another (and a profile)
	- You should be able to toggle nameplate settings in situations
	- new camera action to rotate x degrees at a quickish speed
	- better combat detection
- DOWN THE LINE
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
	name = "DynamicCam Settings",
    handler = DynamicCam,
    type = 'group',
	args = {
		settings = {
            type = 'group',
            name = "Global Addon Settings",
            order = 1,
            inline = true,
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
	name = function() return S.name end,
	handler = DynamicCam,
	type = 'group',
	args = {
		enabled = {
			type = 'toggle',
			name = "Enabled",
			desc = "If this situation should be checked and activated",
			get = function() return S.enabled end,
			set = function(_, newValue) S.enabled = newValue end,
			width = "double",
			order = 1,
		},
		selectedSituation = {
			type = 'select',
			name = "Selected Situation",
			desc = "Which situation you are editing",
			get = function() return Skey end,
			set = function(_, newValue) S = DynamicCam.db.profile.situations[newValue]; Skey = newValue; end,
			values = "GetSituationList",
			order = 2,
		},
		cameraActions = {
			type = 'group',
			name = "Camera Actions",
			order = 10,
			inline = true,
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
						rotateSpeed = {
							type = 'range',
							name = "Rotate Speed",
							desc = "Speed at which to rotate",
							min = -5,
							max = 5,
							softMin = -.5,
							softMax = .5,
							step = .01,
							get = function() return S.cameraActions.rotateSpeed end,
							set = function(_, newValue) S.cameraActions.rotateSpeed = newValue; end,
							order = 2,
							width = "full",
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
			args = {
				toggleUI = {
					type = 'toggle',
					name = "Hide Entire UI",
					desc = "If the UI should be hidden when this situation is activated and shown when it's exited",
					get = function() return (S.hideFrames["UIParent"]) end,
					set = function(_, newValue) if (newValue) then S.hideFrames["UIParent"] = true else S.hideFrames["UIParent"] = nil end end,
					order = 0,
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

	-- apply default settings
	for cvar, value in pairs(self.db.profile.defaultCvars) do
		SetCVar(cvar, value);
	end

	-- setup timer for evaluating situations, TODO: advanced settings
	evaluateTimer = self:ScheduleRepeatingTimer("EvaluateSituations", .05);

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

	-- unhook all hooks
	self:UnhookAll();

	-- reset zoom
	self:ResetZoomVars();

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


-----------
-- HOOKS --
-----------
function DynamicCam:CameraZoomIn(increments)
	local zoomMax = tonumber(GetCVar("cameradistancemax")) * tonumber(GetCVar("cameraDistanceMaxFactor"));

	-- maximum maxzoom is 50
	zoomMax = math.min(50, zoomMax);

	-- maximum increments is zoommax
	increments = math.min(increments, zoomMax);

	-- check if we were continously zooming before and stop tracking it if we were
	if (zoom.continousIn) then
		self:MoveViewInStop();
	end
	if (zoom.continousOut) then
		self:MoveViewOutStop();
	end

	-- check to see if we were previously zooming out and we're not done yet
	if (zoom.outDoneTime and zoom.outDoneTime > GetTime()) then
		-- canceled zooming out, get the time left and guess how much distance we didn't cover
		local timeLeft = zoom.outDoneTime - GetTime();

		-- (seconds) * (yards/second) = yards
		zoom.value = zoom.value - (timeLeft * GetCVar("cameraDistanceMoveSpeed"));

		zoom.confident = false;
		zoom.outDoneTime = nil;
	end

	-- set the zoom variable
	if (not zoom.relative) then
		--we know where we are, then set the zoom, zoom can only go to 0
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
			zoom.relative = false;
			zoom.confident = true;

			zoom.outDoneTime = nil;
			increments = 0;
		end
	end

	-- dynamic zoom
	if (self.db.profile.settings.reactiveZoom and not self:IsZooming()) then
		local zoomSpeed = tonumber(GetCVar("cameraDistanceMoveSpeed"));

		if (math.abs(increments) > (zoomSpeed * self.db.profile.settings.reactiveZoomTime)) then
			SetCVar("cameraDistanceMoveSpeed", math.min(50, math.abs(increments)/self.db.profile.settings.reactiveZoomTime));

			-- set a timer for reverting the zoom speed
			self:ScheduleTimer("SetZoomSpeed", (math.abs(increments)/GetCVar("cameraDistanceMoveSpeed")), self.db.profile.defaultCvars["cameraDistanceMoveSpeed"]);
		end
	end

	-- set zoom done time
	-- (yard) / (yards/second) = seconds
	local timeToZoom = (increments/GetCVar("cameraDistanceMoveSpeed"));
	if (increments > 0) then
		if (zoom.inDoneTime and zoom.inDoneTime > GetTime()) then
			zoom.inDoneTime = zoom.inDoneTime + timeToZoom;
		else
			zoom.inDoneTime = GetTime() + timeToZoom;
		end
	end

	self:DebugPrint("Zoom in:", "increments:", increments, "new:", zoom.value, "time:", timeToZoom, (zoom.confident and "" or "not confident"));
end

function DynamicCam:CameraZoomOut(increments)
	local zoomMax = tonumber(GetCVar("cameradistancemax")) * tonumber(GetCVar("cameraDistanceMaxFactor"));

	-- maximum maxzoom is 50
	zoomMax = math.min(50, zoomMax);

	-- maximum increments is zoommax
	increments = math.min(increments, zoomMax);

	-- check if we were continously zooming before and stop tracking it if we were
	if (zoom.continousIn) then
		self:MoveViewInStop();
	end
	if (zoom.continousOut) then
		self:MoveViewOutStop();
	end

	-- check to see if we were previously zooming out and we're not done yet
	if (zoom.inDoneTime and zoom.inDoneTime > GetTime()) then
		-- canceled zooming in, get the time left and guess how much distance we didn't cover
		local timeLeft = zoom.inDoneTime - GetTime();

		-- (seconds) * (yards/second) = yards
		zoom.value = zoom.value + (timeLeft * GetCVar("cameraDistanceMoveSpeed"));

		zoom.confident = false;
		zoom.inDoneTime = nil;
	end

	-- set the zoom variable
	if (not zoom.relative) then
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
			zoom.relative = false;
			zoom.confident = true;

			zoom.outDoneTime = nil;
			increments = 0;
		end
	end

	-- dynamic zoom speed
	if (self.db.profile.settings.reactiveZoom and not self:IsZooming()) then
		local zoomSpeed = tonumber(GetCVar("cameraDistanceMoveSpeed"));

		if (math.abs(increments) > (zoomSpeed * self.db.profile.settings.reactiveZoomTime)) then
			SetCVar("cameraDistanceMoveSpeed", math.min(50, math.abs(increments)/self.db.profile.settings.reactiveZoomTime));

			-- set a timer for reverting the zoom speed
			self:ScheduleTimer("SetZoomSpeed", self.db.profile.settings.reactiveZoomTime, self.db.profile.defaultCvars["cameraDistanceMoveSpeed"]);
		end
	end

	-- set zoom done time
	-- (yard) / (yards/second) = seconds
	local timeToZoom = (math.abs(increments)/GetCVar("cameraDistanceMoveSpeed"));
	if (math.abs(increments) > 0) then
		if (zoom.outDoneTime and zoom.outDoneTime > GetTime()) then
			zoom.outDoneTime = zoom.outDoneTime + timeToZoom;
		else
			zoom.outDoneTime = GetTime() + timeToZoom;
		end
	end

	self:DebugPrint("Zoom out:", "increments:", increments, "new:", zoom.value, "time:", timeToZoom, (zoom.confident and "" or "not confident"));
end

function DynamicCam:MoveViewInStart(speed)
	zoom.continousStartTime = GetTime();
	zoom.continousIn = true;

	if (speed) then
		zoom.continousSpeed = speed;
	else
		zoom.continousSpeed = 1;
	end
end

function DynamicCam:MoveViewInStop()
	if (zoom.continousIn) then
		zoom.continousIn = false;

		-- set value based on time and movement
		zoom.value = math.max(0, zoom.value - ((GetTime() - zoom.continousStartTime) * GetCVar("cameraDistanceMoveSpeed") * CONTINOUS_FUDGE_FACTOR * zoom.continousSpeed));
		zoom.continousStartTime = nil;

		zoom.confident = false;
		zoom.relative = true;
	end
end

function DynamicCam:MoveViewOutStart(speed)
	zoom.continousStartTime = GetTime();
	zoom.continousOut = true;

	if (speed) then
		zoom.continousSpeed = speed;
	else
		zoom.continousSpeed = 1;
	end
end

function DynamicCam:MoveViewOutStop()
	if (zoom.continousOut) then
		zoom.continousOut = false;

		-- set value based on time and movement
		zoom.value = math.min(50, zoom.value + ((GetTime() - zoom.continousStartTime) * GetCVar("cameraDistanceMoveSpeed") * CONTINOUS_FUDGE_FACTOR * zoom.continousSpeed));
		zoom.continousStartTime = nil;

		zoom.confident = false;
		zoom.relative = true;
	end
end

function DynamicCam:SetView(view)
	if (self.db.global.savedViews[view]) then
		zoom.value = self.db.global.savedViews[view];
		zoom.relative = false;
		zoom.confident = false;
	else
		self:ResetZoomVars();
	end
end

function DynamicCam:ResetView(view)
	self.db.global.savedViews[view] = nil;
end

function DynamicCam:SaveView(view)
	if (not zoom.relative and zoom.confident) then
		self.db.global.savedViews[view] = zoom.value;

		if (view ~= 1) then
			self:Print("Saved view "..view.." with absolute zoom.");
		end
	else
		if (view ~= 1) then
			self:Print("Saved view "..view.." but couldn't save zoom level!");
		end
	end
end

function DynamicCam:ResetZoomVars()
	-- reset zoom
	zoom.value = 0;
	zoom.relative = true;
	zoom.confident = false;
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

		SetView(situation.view.viewNumber);

		if (situation.view.instant) then
			SetView(situation.view.viewNumber);
		end
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
	if (not zoom.relative) then
		restoration[situation].zoom = zoom.value;
		restoration[situation].zoomSituation = oldSituation;
	end

	-- set zoom level
	local adjustedZoom;
	if (situation.cameraActions.zoomSetting == "in") then
		adjustedZoom = self:ZoomInTo(situation.cameraActions.zoomValue);
	elseif (situation.cameraActions.zoomSetting == "out") then
		adjustedZoom = self:ZoomOutTo(situation.cameraActions.zoomValue);
	elseif (situation.cameraActions.zoomSetting == "set") then
		adjustedZoom = self:ZoomSet(situation.cameraActions.zoomValue);
	elseif (situation.cameraActions.zoomSetting == "range") then
		adjustedZoom = self:ZoomRange(situation.cameraActions.zoomMin, situation.cameraActions.zoomMax);
	elseif (situation.cameraActions.zoomSetting == "fit") then
		adjustedZoom = self:ZoomFit(situation.cameraActions.zoomMin, situation.cameraActions.zoomMax, situation.cameraActions.zoomFitNameplate, situation.cameraActions.zoomFitSave);
	end

	-- if we didn't adjust the soom, then reset oldZoom
	if (not adjustedZoom) then
		restoration[situation].zoom = nil;
		restoration[situation].zoomSituation = nil;
	end

	-- ROTATE --
	if (situation.cameraActions.rotate) then
		MoveViewRightStart(situation.cameraActions.rotateSpeed);
	end

	-- hide frames
	for frameName, value in pairs(situation.hideFrames) do
		if (value) then
			_G[frameName]:Hide();
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
		SetView(1);

		if (situation.view.instant) then
			SetView(1);
		end
	end

	-- stop rotating if we started to
	if (situation.cameraActions.rotate) then
		MoveViewRightStop();
	end

	-- save zoom for Zoom Fit
	if (not zoom.relative and situation.cameraActions.zoomSetting == "fit" and situation.cameraActions.zoomFitSave) then
		if (UnitExists("target")) then
			local npcID = string.match(UnitGUID("target"), "[^-]+-[^-]+-[^-]+-[^-]+-[^-]+-([^-]+)-[^-]+");
			self.db.global.savedZooms.npcs[npcID] = zoom.value;
		end
	end

	-- restore zoom level if we saved one
	if (self:ShouldRestoreZoom(situation, newSituation)) then
		self:ZoomSet(restoration[situation].zoom);
		self:DebugPrint("Restoring zoom level.");
	else
		self:DebugPrint("Not restoring zoom level.");
	end

	-- unhide hidden frames
	for frameName, value in pairs(situation.hideFrames) do
		if (value) then
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
	newSituation.priority = 5;
	newSituation.condition = "local spellName = UnitCastingInfo(\"player\"); if (spellName and (spellName == GetSpellInfo(8690) or spellName == GetSpellInfo(222695))) then return true end return false";
	newSituation.cameraActions.zoomSetting = "in";
	newSituation.cameraActions.zoomValue = 4;
	newSituation.cameraActions.rotate = true;
	newSituation.cameraActions.rotateSpeed = .2;
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
	newSituation.cameraActions.zoomSetting = "in";
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
			rotate = false,
			rotateSpeed = .1,
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


--------------------
-- EVENT HANDLERS --
--------------------
function DynamicCam:RefreshConfig()
	local restartTimer = false;

	-- situation is active, but db killed it
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


----------
-- ZOOM --
----------
local zoomUntilTimer = nil;
local zoomUntilZoomTime = nil;

local function zoomUntilTick(condition, speed, zoomFunc)
	if (condition and not condition()) then
		-- condition not yet met
		if (zoomFunc and (not zoomUntilZoomTime or zoomUntilZoomTime <= GetTime())) then
			zoomFunc(speed/3);
			zoomUntilZoomTime = GetTime() + (speed/6)/GetCVar("cameraDistanceMoveSpeed");
		end
	else
		zoomUntilZoomTime = nil;
		
		DynamicCam:CancelTimer(zoomUntilTimer);
	end
end

function DynamicCam:ZoomOutUntil(speed, condition)
	if (condition and not condition() and not self:IsZooming()) then
		CameraZoomOut(speed);
		-- try to not have noticable ticks
		zoomUntilTimer = self:ScheduleRepeatingTimer(zoomUntilTick, .001, condition, speed, CameraZoomOut);
	end
end

function DynamicCam:ZoomInUntil(speed, condition)
	if (condition and not condition() and not self:IsZooming()) then
		CameraZoomIn(speed);
		-- try not to have noticable ticks
		zoomUntilTimer = self:ScheduleRepeatingTimer(zoomUntilTick, .001, condition, speed, CameraZoomIn);
	end
end

function DynamicCam:IsZooming()
	if (zoom.continousIn or zoom.continousOut or (zoom.outDoneTime and zoom.outDoneTime > GetTime()) or (zoom.inDoneTime and zoom.inDoneTime > GetTime())) then
		return true;
	end

	return false;
end

function DynamicCam:GetCurrentZoom()
	if (zoom.continousIn) then
		return math.max(0, zoom.value - ((GetTime() - zoom.continousStartTime) * GetCVar("cameraDistanceMoveSpeed") * zoom.continousSpeed * CONTINOUS_FUDGE_FACTOR));
	elseif (zoom.continousOut) then
		return math.min(50, zoom.value + ((GetTime() - zoom.continousStartTime) * GetCVar("cameraDistanceMoveSpeed") * zoom.continousSpeed * CONTINOUS_FUDGE_FACTOR));
	-- elseif (zoom.outDoneTime and zoom.outDoneTime > GetTime()) then
		-- return zoom.value - ((zoom.outDoneTime - GetTime()) * GetCVar("cameraDistanceMoveSpeed"));
	-- elseif (zoom.inDoneTime and zoom.inDoneTime > GetTime()) then
		-- return zoom.value + ((zoom.inDoneTime - GetTime()) * GetCVar("cameraDistanceMoveSpeed"));
	end

	return zoom.value;
end

function DynamicCam:ZoomInTo(value)
	local oldMax = GetCVar("cameradistancemax");
	
	-- set max
	self:SetMaxZoom(value);

	-- bump to zoom in
	if (zoom.relative) then
		CameraZoomOut(value+1);
		self:ScheduleTimer("SetMaxZoom", (value+1)/GetCVar("cameraDistanceMoveSpeed"), oldMax);
	else
		CameraZoomOut(0);
		self:ScheduleTimer("SetMaxZoom", .1, oldMax);
	end

	return true;
end

function DynamicCam:ZoomOutTo(value)
	if (not zoom.relative) then
		-- if we know what our zoom is at
		-- if we're zoomed in and need to zoom out
		if (zoom.value < value) then
			CameraZoomOut(value - zoom.value);
			return true;
		end
	else
		-- we don't know where our zoom is at
		local oldMax = GetCVar("cameradistancemax");

		-- set max
		self:SetMaxZoom(value);

		-- zoom out to value
		CameraZoomOut(value+1);

		self:ScheduleTimer("SetMaxZoom", (value+1)/GetCVar("cameraDistanceMoveSpeed"), oldMax);
	end

	return false;
end

function DynamicCam:ZoomSet(value)
	if (not zoom.relative) then
		-- if we know what our zoom is at
		-- if we're zoomed in and need to zoom out
		if (zoom.value < value) then
			CameraZoomOut(value - zoom.value);
			return true;
		elseif (zoom.value > value) then
			CameraZoomIn(zoom.value - value);
			return true;
		end
	else
		return self:ZoomOutTo(value);
	end

	return false;
end

function DynamicCam:ZoomRange(zoomMin, zoomMax)
	if (not zoom.relative) then
		-- if we know what our zoom is at
		if (zoom.value < zoomMin) then
			return self:ZoomSet(zoomMin);
		elseif (zoom.value > zoomMax) then
			return self:ZoomSet(zoomMax);
		end
	else
		-- don't know where we are, set to min
		return self:ZoomSet(zoomMin);
	end

	return false;
end

function DynamicCam:ZoomFit(zoomMin, zoomMax, fitNameplate, restoreZoom)
	self:DebugPrint("Zoom Fit");
	--TODO
	if (not zoom.relative and UnitExists("target")) then
		-- restore saved
		local npcID = string.match(UnitGUID("target"), "[^-]+-[^-]+-[^-]+-[^-]+-[^-]+-([^-]+)-[^-]+");
		if (restoreZoom and self.db.global.savedZooms.npcs[npcID]) then
			self:DebugPrint("Restoring saved zoom for this NPC");
			return self:ZoomSet(math.min(zoomMax, math.max(zoomMin, self.db.global.savedZooms.npcs[npcID])));
		end

		-- fit nameplate
		local nameplate = C_NamePlate.GetNamePlateForUnit("target");
		if (fitNameplate and nameplate) then
			local _, y = nameplate:GetCenter();
			local screenHeight = GetScreenHeight() * UIParent:GetEffectiveScale();
			local ratio = (1 - (screenHeight - y)/screenHeight) * 100;

			self:DebugPrint("Fitting Nameplate for target");

			if (ratio > 80) then
				-- create a function that will check if we've zoomed out enough or reached max
				local func = function()
					local _, y = nameplate:GetCenter();
					local screenHeight = GetScreenHeight() * UIParent:GetEffectiveScale();
					local ratio = (1 - (screenHeight - y)/screenHeight) * 100;

					return ((ratio <= 80) or (self:GetCurrentZoom() >= zoomMax));
				end

				self:ZoomOutUntil(1, func);
				return true;
			elseif (ratio > 50 and ratio < 79) then
				-- create a function that will check if we've zoomed in enough or reached min
				local func = function()
					local _, y = nameplate:GetCenter();
					local screenHeight = GetScreenHeight() * UIParent:GetEffectiveScale();
					local ratio = (1 - (screenHeight - y)/screenHeight) * 100;

					return ((ratio >= 80) or (self:GetCurrentZoom() <= zoomMin));
				end

				self:ZoomInUntil(1, func);
				return true;
			end
		end
	end

	return false;
end

function DynamicCam:SetMaxZoom(value)
	SetCVar("cameradistancemax", value);
end

function DynamicCam:SetZoomSpeed(value)
	SetCVar("cameraDistanceMoveSpeed", value);
end

function DynamicCam:ShouldRestoreZoom(oldSituation, newSituation)
	-- don't restore if we don't know where we are or we don't have a saved zoom value
	if (zoom.relative or (not restoration[oldSituation].zoom)) then
		return false;
	end

	-- don't restore view if we're still zooming
	if (self.IsZooming()) then
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


-------------------
-- CHAT COMMANDS --
-------------------
function DynamicCam:OpenMenu(input)
	-- just open to the frame, double call because blizz bug
	InterfaceOptionsFrame_OpenToCategory("DynamicCam");
	InterfaceOptionsFrame_OpenToCategory("DynamicCam");
end

function DynamicCam:SaveViewCC(input)
	if (tonumber(input) and tonumber(input) <= 5 and tonumber(input) > 0) then
		self:SaveView(tonumber(input));
	end
end

function DynamicCam:ZoomConfidenceCC(input)
	ResetView(1);
	SetView(1);
	SetView(1);
	zoom.value = 0;
	zoom.confident = true;
	zoom.relative = false;

	self:ZoomSet(15);
end

function DynamicCam:ZoomInfoCC(input)
	self:Print("Zoom Info: "..zoom.value..(zoom.confident and "" or ", not confident")..(zoom.relative and ", relative" or ""));
end


-----------
-- CVARS --
-----------
function DynamicCam:ResetCVars()
	SetCVar("cameraovershoulder", GetCVarDefault("cameraovershoulder"));
	SetCVar("cameralockedtargetfocusing", GetCVarDefault("cameralockedtargetfocusing"));
	SetCVar("cameradistancemax", GetCVarDefault("cameradistancemax"));
	SetCVar("cameraDistanceMoveSpeed", GetCVarDefault("cameraDistanceMoveSpeed"));
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

	self:SetMaxZoom(50);
	SetCVar("cameraDistanceMaxFactor", 1);
end
