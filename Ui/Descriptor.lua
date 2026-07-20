-------------------------------------------------------------------------------
-- DynamicCam new settings UI - declarative settings descriptor.
--
-- The settings pages are data: each category is a list of items rendered by the
-- row factories in Ui/Controls.lua. This is the distilled form of the AceGUI
-- tables in Options.lua; when the transition is complete, this file is their
-- only successor.
--
-- Item kinds:
--   slider    { label, tooltip?, cvar?, dbPath, min, max, step,
--               toDisplay?, fromDisplay?,   -- display-space transform pair
--               minClampZero?,              -- cvar whose real minimum shows as 0
--               zoomBased?,                 -- attach the zoom-based curve control
--               enabledWhen?(sid),          -- gate (greys the row when false)
--               transformNote? }            -- extra grey tooltip line
--   checkbox  { label, tooltip?, cvar?, dbPath, cvarBool?, get?/set? overrides }
--   header    { label, info? }              -- section header; info becomes the
--                                           -- "i" icon's tooltip text
--   subheader { label }                     -- sub-section heading within a category
--   button    { label, onClick }
--   note      { text, shownWhen()? }        -- red warning line
--
-- Each category is { name, info?, items }. The page prepends a header row
-- carrying name and info, so every category opens with a titled heading whose
-- "i" icon holds the category's help text.
--
-- dbPath addresses DynamicCam:Get/SetSettingsValue (standardSettings, or the
-- situation's override when the page runs with a situationId). All ranges are
-- in DISPLAY space; toDisplay/fromDisplay convert from/to the stored value.
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)
local Ui = DynamicCam.Ui


-- Gate helpers: a slider is greyed while its group's enable toggle is off.
local function CvarIsOn(cvar)
  return function(sid)
    return DynamicCam:GetSettingsValue(sid, "cvars", cvar) == 1
  end
end

local function ReactiveZoomOn(sid)
  return DynamicCam:GetSettingsValue(sid, "reactiveZoomEnabled")
end


Ui.standardCategories = {

  {
    name = L["Mouse Zoom"],
    info = L["<reactiveZoom_desc>"],
    items = {
      { kind = "slider", label = L["Maximum Camera Distance"],
        tooltip = L["How many yards the camera can zoom away from your character."],
        cvar = "cameraDistanceMaxZoomFactor", dbPath = {"cvars", "cameraDistanceMaxZoomFactor"},
        min = 15, max = DynamicCam.cameraDistanceMaxZoomFactor_max, step = 0.5,
        toDisplay = function(v) return v * 15 end, fromDisplay = function(v) return v / 15 end },
      { kind = "slider", label = L["Camera Zoom Speed"],
        tooltip = L["How fast the camera can zoom."],
        cvar = "cameraZoomSpeed", dbPath = {"cvars", "cameraZoomSpeed"},
        min = 1, max = 50, step = 0.5 },
      { kind = "slider", label = L["Zoom Increments"],
        tooltip = L["How many yards the camera should travel for each \"tick\" of the mouse wheel."],
        dbPath = {"reactiveZoomAddIncrementsAlways"},
        min = 0.05, max = 10, step = 0.05,
        toDisplay = function(v) return v + 1 end, fromDisplay = function(v) return v - 1 end },

      { kind = "subheader", label = L["Reactive Zoom"] },
      { kind = "checkbox", label = L["Use Reactive Zoom"],
        dbPath = {"reactiveZoomEnabled"} },
      { kind = "slider", label = L["Quick-Zoom Additional Increments"],
        tooltip = L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."],
        dbPath = {"reactiveZoomAddIncrements"},
        min = 0, max = 10, step = 0.1, enabledWhen = ReactiveZoomOn },
      { kind = "slider", label = L["Quick-Zoom Enter Threshold"],
        tooltip = L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."],
        dbPath = {"reactiveZoomIncAddDifference"},
        min = 0.1, max = 5, step = 0.1, enabledWhen = ReactiveZoomOn },
      { kind = "slider", label = L["Maximum Zoom Time"],
        tooltip = L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."],
        dbPath = {"reactiveZoomMaxZoomTime"},
        min = 0.1, max = 5, step = 0.05, enabledWhen = ReactiveZoomOn },

      { kind = "button", label = L["Toggle Visual Aid"],
        onClick = function() DynamicCam:ToggleRZVA() end },

      { kind = "subheader", label = L["Miscellaneous"] },
      { kind = "checkbox", label = L["Enhanced minimal zoom-in"],
        tooltip = L["<enhancedMinZoom_desc>"],
        get = function() return DynamicCam.db.profile.reactiveZoomEnhancedMinZoom end,
        set = function(v) DynamicCam.db.profile.reactiveZoomEnhancedMinZoom = v end },
      { kind = "note", text = L["/reload of the UI required!"],
        shownWhen = function()
          -- The model frame only exists after a reload with the setting on, so a
          -- mismatch means the user toggled it since the last reload.
          return (DynamicCam.modelFrame ~= nil) ~= (DynamicCam.db.profile.reactiveZoomEnhancedMinZoom == true)
        end },
    },
  },

  {
    name = L["Mouse Look"],
    info = L["<mouseLook_desc>"],
    items = {
      { kind = "slider", label = L["Horizontal Speed"],
        tooltip = L["How much the camera yaws horizontally when in mouse look mode."],
        cvar = "cameraYawMoveSpeed", dbPath = {"cvars", "cameraYawMoveSpeed"},
        min = 1, max = 360, step = 1 },
      { kind = "slider", label = L["Vertical Speed"],
        tooltip = L["How much the camera pitches vertically when in mouse look mode."],
        cvar = "cameraPitchMoveSpeed", dbPath = {"cvars", "cameraPitchMoveSpeed"},
        min = 1, max = 360, step = 1 },
    },
  },

  {
    name = L["Field of View"],
    info = L["<cameraFov_desc>"],
    items = {
      { kind = "slider", label = L["Field of View"],
        tooltip = L["The camera's field of view. Lower values are more zoomed in, higher values show more of your surroundings."],
        cvar = "cameraFov", dbPath = {"cvars", "cameraFov"},
        min = DynamicCam.cvarRanges.cameraFov.min, max = DynamicCam.cvarRanges.cameraFov.max,
        step = 0.5, zoomBased = true },
    },
  },

  {
    name = L["Horizontal Offset"],
    info = L["<cameraOverShoulder_desc>"],
    items = {
      { kind = "slider", label = L["Camera Over Shoulder Offset"],
        tooltip = L["Positions the camera left or right from your character."],
        cvar = "test_cameraOverShoulder", dbPath = {"cvars", "test_cameraOverShoulder"},
        min = DynamicCam.cvarRanges.test_cameraOverShoulder.min,
        max = DynamicCam.cvarRanges.test_cameraOverShoulder.max,
        step = 0.1, zoomBased = true },
    },
  },

  {
    name = L["Vertical Pitch"],
    info = L["<pitch_desc>"],
    items = {
      { kind = "checkbox", label = L["Enable"],
        cvar = "test_cameraDynamicPitch", dbPath = {"cvars", "test_cameraDynamicPitch"},
        cvarBool = true },
      { kind = "slider", label = L["Pitch (on ground)"],
        cvar = "test_cameraDynamicPitchBaseFovPad", dbPath = {"cvars", "test_cameraDynamicPitchBaseFovPad"},
        min = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPad.min,
        max = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPad.max,
        step = 0.01, zoomBased = true, enabledWhen = CvarIsOn("test_cameraDynamicPitch") },
      { kind = "slider", label = L["Pitch (flying)"],
        cvar = "test_cameraDynamicPitchBaseFovPadFlying", dbPath = {"cvars", "test_cameraDynamicPitchBaseFovPadFlying"},
        min = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPadFlying.min,
        max = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPadFlying.max,
        step = 0.01, zoomBased = true, enabledWhen = CvarIsOn("test_cameraDynamicPitch") },
      { kind = "slider", label = L["Down Scale"],
        cvar = "test_cameraDynamicPitchBaseFovPadDownScale", dbPath = {"cvars", "test_cameraDynamicPitchBaseFovPadDownScale"},
        min = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPadDownScale.min,
        max = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPadDownScale.max,
        step = 0.01, zoomBased = true, enabledWhen = CvarIsOn("test_cameraDynamicPitch") },
      { kind = "slider", label = L["Smart Pivot Cutoff Distance"],
        cvar = "test_cameraDynamicPitchSmartPivotCutoffDist", dbPath = {"cvars", "test_cameraDynamicPitchSmartPivotCutoffDist"},
        min = 0, max = DynamicCam.cameraDistanceMaxZoomFactor_max, step = 0.5,
        enabledWhen = CvarIsOn("test_cameraDynamicPitch") },
        -- No zoom-based control: its effect itself is zoom based.
    },
  },

  {
    name = L["Target Focus"],
    info = L["<targetFocus_desc>"],
    items = {
      { kind = "subheader", label = L["Enemy Target"] },
      { kind = "checkbox", label = L["Enable"],
        cvar = "test_cameraTargetFocusEnemyEnable", dbPath = {"cvars", "test_cameraTargetFocusEnemyEnable"},
        cvarBool = true },
      { kind = "slider", label = L["Horizontal Strength"],
        cvar = "test_cameraTargetFocusEnemyStrengthYaw", dbPath = {"cvars", "test_cameraTargetFocusEnemyStrengthYaw"},
        min = DynamicCam.cvarRanges.test_cameraTargetFocusEnemyStrengthYaw.min,
        max = DynamicCam.cvarRanges.test_cameraTargetFocusEnemyStrengthYaw.max,
        step = 0.05, zoomBased = true, enabledWhen = CvarIsOn("test_cameraTargetFocusEnemyEnable") },
      { kind = "slider", label = L["Vertical Strength"],
        cvar = "test_cameraTargetFocusEnemyStrengthPitch", dbPath = {"cvars", "test_cameraTargetFocusEnemyStrengthPitch"},
        min = DynamicCam.cvarRanges.test_cameraTargetFocusEnemyStrengthPitch.min,
        max = DynamicCam.cvarRanges.test_cameraTargetFocusEnemyStrengthPitch.max,
        step = 0.05, zoomBased = true, enabledWhen = CvarIsOn("test_cameraTargetFocusEnemyEnable") },

      { kind = "subheader", label = L["Interaction Target (NPCs)"] },
      { kind = "checkbox", label = L["Enable"],
        cvar = "test_cameraTargetFocusInteractEnable", dbPath = {"cvars", "test_cameraTargetFocusInteractEnable"},
        cvarBool = true },
      { kind = "slider", label = L["Horizontal Strength"],
        cvar = "test_cameraTargetFocusInteractStrengthYaw", dbPath = {"cvars", "test_cameraTargetFocusInteractStrengthYaw"},
        min = DynamicCam.cvarRanges.test_cameraTargetFocusInteractStrengthYaw.min,
        max = DynamicCam.cvarRanges.test_cameraTargetFocusInteractStrengthYaw.max,
        step = 0.05, zoomBased = true, enabledWhen = CvarIsOn("test_cameraTargetFocusInteractEnable") },
      { kind = "slider", label = L["Vertical Strength"],
        cvar = "test_cameraTargetFocusInteractStrengthPitch", dbPath = {"cvars", "test_cameraTargetFocusInteractStrengthPitch"},
        min = DynamicCam.cvarRanges.test_cameraTargetFocusInteractStrengthPitch.min,
        max = DynamicCam.cvarRanges.test_cameraTargetFocusInteractStrengthPitch.max,
        step = 0.05, zoomBased = true, enabledWhen = CvarIsOn("test_cameraTargetFocusInteractEnable") },
    },
  },

  {
    name = L["Head Tracking"],
    info = L["<headTracking_desc>"],
    items = {
      { kind = "checkbox", label = L["Enable"],
        tooltip = L["<headTrackingEnable_desc>"],
        cvar = "test_cameraHeadMovementStrength", dbPath = {"cvars", "test_cameraHeadMovementStrength"},
        cvarBool = true },
      { kind = "slider", label = L["Strength (standing)"],
        cvar = "test_cameraHeadMovementStandingStrength", dbPath = {"cvars", "test_cameraHeadMovementStandingStrength"},
        min = DynamicCam.cvarRanges.test_cameraHeadMovementStandingStrength.min,
        max = DynamicCam.cvarRanges.test_cameraHeadMovementStandingStrength.max,
        step = 0.01, zoomBased = true, enabledWhen = CvarIsOn("test_cameraHeadMovementStrength") },
      { kind = "slider", label = L["Inertia (standing)"],
        cvar = "test_cameraHeadMovementStandingDampRate", dbPath = {"cvars", "test_cameraHeadMovementStandingDampRate"},
        min = DynamicCam.cvarRanges.test_cameraHeadMovementStandingDampRate.min,
        max = DynamicCam.cvarRanges.test_cameraHeadMovementStandingDampRate.max,
        step = 0.05, minClampZero = "test_cameraHeadMovementStandingDampRate",
        zoomBased = true, enabledWhen = CvarIsOn("test_cameraHeadMovementStrength") },
      { kind = "slider", label = L["Strength (moving)"],
        cvar = "test_cameraHeadMovementMovingStrength", dbPath = {"cvars", "test_cameraHeadMovementMovingStrength"},
        min = DynamicCam.cvarRanges.test_cameraHeadMovementMovingStrength.min,
        max = DynamicCam.cvarRanges.test_cameraHeadMovementMovingStrength.max,
        step = 0.01, zoomBased = true, enabledWhen = CvarIsOn("test_cameraHeadMovementStrength") },
      { kind = "slider", label = L["Inertia (moving)"],
        cvar = "test_cameraHeadMovementMovingDampRate", dbPath = {"cvars", "test_cameraHeadMovementMovingDampRate"},
        min = DynamicCam.cvarRanges.test_cameraHeadMovementMovingDampRate.min,
        max = DynamicCam.cvarRanges.test_cameraHeadMovementMovingDampRate.max,
        step = 0.05, minClampZero = "test_cameraHeadMovementMovingDampRate",
        zoomBased = true, enabledWhen = CvarIsOn("test_cameraHeadMovementStrength") },
      { kind = "slider", label = L["Inertia (first person)"],
        cvar = "test_cameraHeadMovementFirstPersonDampRate", dbPath = {"cvars", "test_cameraHeadMovementFirstPersonDampRate"},
        min = 0, max = 20, step = 0.05,
        minClampZero = "test_cameraHeadMovementFirstPersonDampRate",
        enabledWhen = CvarIsOn("test_cameraHeadMovementStrength") },
        -- No zoom-based control: only takes effect in first person, when zoom is zero.
      { kind = "slider", label = L["Range Scale"],
        tooltip = L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"],
        cvar = "test_cameraHeadMovementRangeScale", dbPath = {"cvars", "test_cameraHeadMovementRangeScale"},
        min = 0, max = 117, step = 0.5,
        toDisplay = function(v) return (v * 3.25) + 0.1625 end,
        fromDisplay = function(v) return (v - 0.1625) / 3.25 end,
        transformNote = L["(slider value transformed)"],
        enabledWhen = CvarIsOn("test_cameraHeadMovementStrength") },
        -- No zoom-based control: its effect itself is zoom based.
      { kind = "slider", label = L["Dead Zone"],
        tooltip = L["Radius of head movement not affecting the camera. (See explanation below.)"] .. "\n|cffe00000" .. L["Requires /reload to come into effect!"] .. "|r",
        cvar = "test_cameraHeadMovementDeadZone", dbPath = {"cvars", "test_cameraHeadMovementDeadZone"},
        min = 0, max = 10, step = 0.05,
        toDisplay = function(v) return v * 10 end,
        fromDisplay = function(v) return v / 10 end,
        transformNote = L["(slider value devided by 10)"],
        enabledWhen = CvarIsOn("test_cameraHeadMovementStrength") },
        -- No zoom-based control: does not take effect without /reload.
    },
  },

}
