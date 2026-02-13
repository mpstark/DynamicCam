
---------------
-- LIBRARIES --
---------------
local LibCamera = LibStub("LibCamera-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

-------------
-- GLOBALS --
-------------
assert(DynamicCam)
-- Options module is created in Options/Helpers.lua which loads first
local Options = DynamicCam.Options


DynamicCam.cameraDistanceMaxZoomFactor_max = 39
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
  DynamicCam.cameraDistanceMaxZoomFactor_max = 50
end


-- Store min/max ranges for cvars used with zoom-based controls
-- These are the actual cvar value ranges (not transformed slider display values)
DynamicCam.cvarRanges = {
  test_cameraOverShoulder = { min = -15, max = 15 },
  
  test_cameraDynamicPitchBaseFovPad = { min = 0, max = 0.99 },
  test_cameraDynamicPitchBaseFovPadFlying = { min = 0, max = 1 },
  test_cameraDynamicPitchBaseFovPadDownScale = { min = 0, max = 1 },
  
  test_cameraTargetFocusEnemyStrengthYaw = { min = 0, max = 1 },
  test_cameraTargetFocusEnemyStrengthPitch = { min = 0, max = 1 },
  test_cameraTargetFocusInteractStrengthYaw = { min = 0, max = 1 },
  test_cameraTargetFocusInteractStrengthPitch = { min = 0, max = 1 },
  
  test_cameraHeadMovementStandingStrength = { min = 0, max = 1 },
  test_cameraHeadMovementStandingDampRate = { min = 0, max = 20 },
  test_cameraHeadMovementMovingStrength = { min = 0, max = 1 },
  test_cameraHeadMovementMovingDampRate = { min = 0, max = 20 },
  test_cameraHeadMovementFirstPersonDampRate = { min = 0, max = 20 },
}


------------
-- LOCALS --
------------
-- Round function is now in Options/Helpers.lua as Options.Round()
local Round = Options.Round

local _

-- Situation selection state is now managed in Options/Helpers.lua
-- The local S and SID are proxies that stay synchronized with Options.S and Options.SID
-- We use __index and __newindex metamethods to automatically sync them
local S, SID, lastSelectedSID, copiedSituationID

-- Helper functions to update the state and keep Options module in sync
local function UpdateSituationState(situation, situationId)
  S = situation
  SID = situationId
  Options.S = situation
  Options.SID = situationId
end

local function UpdateLastSelectedSID(val)
  lastSelectedSID = val
  Options.lastSelectedSID = val
end

local function UpdateCopiedSituationID(val)
  copiedSituationID = val
  Options.copiedSituationID = val
end

local exportName, exportAuthor




-- Checking if "situation controls" settings deviate from the stock settings.
-- These functions are now defined in Options/Helpers.lua


local EventsIsDefault = Options.EventsIsDefault
local ScriptIsDefault = Options.ScriptIsDefault
local ValueIsDefault = Options.ValueIsDefault
local SituationControlsAreDefault = Options.SituationControlsAreDefault
local SituationControlsToDefault = Options.SituationControlsToDefault
local ColourTextErrorOrModified = Options.ColourTextErrorOrModified
local GetUsedViews = Options.GetUsedViews


-- GetSettingsTable, GetSettingsValue, GetSettingsDefault, SetSettingsValue, SetSettingsDefault
-- are now defined on DynamicCam in Options/Helpers.lua


-- GetInheritedDisabledStatus is now in Options/Helpers.lua
local GetInheritedDisabledStatus = Options.GetInheritedDisabledStatus


-- Control factory functions are now in Options/ControlFactories.lua
local CreateZoomBasedControl = Options.CreateZoomBasedControl
local CreateSliderResetButton = Options.CreateSliderResetButton
local CreateOverriddenText = Options.CreateOverriddenText
local CreateOverrideStandardToggle = Options.CreateOverrideStandardToggle


-- Group variables and helper functions are now in Options/Helpers.lua
local zoomGroupVars = Options.zoomGroupVars
local mouseLookGroupVars = Options.mouseLookGroupVars
local shoulderOffsetGroupVars = Options.shoulderOffsetGroupVars
local pitchGroupVars = Options.pitchGroupVars
local targetFocusGroupVars = Options.targetFocusGroupVars
local headTrackingGroupVars = Options.headTrackingGroupVars
local CheckGroupVars = Options.CheckGroupVars
local SetGroupVars = Options.SetGroupVars
local GreyWhenInactive = Options.GreyWhenInactive
local ColoredNames = Options.ColoredNames
local GetSituationList = Options.GetSituationList
local ApplyContinuousRotation = Options.ApplyContinuousRotation
local ApplyUIFade = Options.ApplyUIFade




local function CreateSettingsTab(tabOrder, forSituations, forExport)

  -- For the situation settings the area is a little smaller.
  local sliderWidth = 1.9
  if forSituations then
    sliderWidth = 1.75
  end

  return {

    type = "group",
    name =
      function()
        if not forSituations then return L["Standard Settings"]
        else return L["Situation Settings"] end
      end,
    order = tabOrder,
    args = {

      help = {
        type = "description",
        name =
          function()
            local text = ""

            if not forSituations then

              text = L["<standardSettings_desc>"]

              if DynamicCam.currentSituationID then
                text = text .. " |cFF00FF00" .. L["<standardSettingsOverridden_desc>"] .. "|r"
              end

            else
              text = L["These Situation Settings override the Standard Settings when the respective situation is active."]
            end

            return text .. "\n\n"
          end,
        order = 0,
      },


      zoomGroup = {
        type = "group",
        name =
          function()
            return ColoredNames(L["Mouse Zoom"], zoomGroupVars, forSituations)
          end,
        order = 1,
        args = {

          overriddenText = CreateOverriddenText(zoomGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(zoomGroupVars, forSituations),
          blank01 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },


          zoomSubGroup = {
            type = "group",
            name = "",
            _dbPath = forExport and "zoomSubGroup" or nil, -- Mark as skippable/mergeable if needed, or just handle empty names
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(zoomGroupVars)
              end,
            args = {

              cameraDistanceMaxFactor = {
                type = "range",
                name = L["Maximum Camera Distance"],
                desc = L["How many yards the camera can zoom away from your character."] .. "\n|cff909090cvar: cameraDistanceMaxZoomFactor|r",
                _dbPath = forExport and {"cvars", "cameraDistanceMaxZoomFactor"} or nil,
                order = 1,
                width = sliderWidth + 0.2,
                min = 15,
                max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                step = 0.5,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "cameraDistanceMaxZoomFactor") * 15
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue/15, forSituations and SID, "cvars", "cameraDistanceMaxZoomFactor")
                  end,
              },
              cameraDistanceMaxFactorReset =
                CreateSliderResetButton(1.1, forSituations, "cvars", "cameraDistanceMaxZoomFactor",
                                        DynamicCam:GetSettingsDefault("cvars", "cameraDistanceMaxZoomFactor") * 15),
              blank12 = {type = "description", name = " ", order = 1.2, },

              cameraZoomSpeed = {
                type = "range",
                name = L["Camera Zoom Speed"],
                desc = L["How fast the camera can zoom."] .. "\n|cff909090cvar: cameraZoomSpeed|r",
                _dbPath = forExport and {"cvars", "cameraZoomSpeed"} or nil,
                order = 2,
                width = sliderWidth + 0.2,
                min = 1,
                max = 50,
                step = 0.5,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "cameraZoomSpeed")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "cameraZoomSpeed")
                  end,
              },
              cameraZoomSpeedReset =
                CreateSliderResetButton(2.1, forSituations, "cvars", "cameraZoomSpeed"),
              blank22 = {type = "description", name = " ", order = 2.2, },

              addIncrementsAlways = {
                type = "range",
                name = L["Zoom Increments"],
                desc = L["How many yards the camera should travel for each \"tick\" of the mouse wheel."],
                order = 3,
                width = sliderWidth + 0.2,
                min = 0.05,
                max = 10,
                step = 0.05,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomAddIncrementsAlways") + 1
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue - 1, forSituations and SID, "reactiveZoomAddIncrementsAlways")
                  end,
              },
              addIncrementsAlwaysReset =
                CreateSliderResetButton(3.1, forSituations, "reactiveZoomAddIncrementsAlways", nil,
                                        DynamicCam:GetSettingsDefault("reactiveZoomAddIncrementsAlways") + 1),
              
              blank32 = {type = "description", name = "\n\n", order = 3.2, },


              reactiveZoomToggle = {
                type = "toggle",
                name = L["Use Reactive Zoom"],
                order = 4,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomEnabled")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "reactiveZoomEnabled")
                  end,
              },

              reactiveZoomGroup = {
                type = "group",
                name = "",
                disabled =
                  function()
                    return not DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomEnabled")
                           or (forSituations and not CheckGroupVars(zoomGroupVars))
                  end,
                order = 5,
                args = {

                  addIncrements = {
                    type = "range",
                    name = L["Quick-Zoom Additional Increments"],
                    desc = L["How many yards per mouse wheel \"tick\" should be added when quick-zooming."],
                    order = 1,
                    width = sliderWidth + 0.2,
                    min = 0,
                    max = 10,
                    step = 0.1,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomAddIncrements")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "reactiveZoomAddIncrements")
                      end,
                  },
                  addIncrementsReset =
                    CreateSliderResetButton(1.1, forSituations, "reactiveZoomAddIncrements"),
                  blank12 = {type = "description", name = " ", order = 1.2, },

                  incAddDifference = {
                    type = "range",
                    name = L["Quick-Zoom Enter Threshold"],
                    desc = L["How many yards the \"Reactive Zoom Target\" and the \"Current Zoom Value\" have to be apart to enter quick-zooming."],
                    order = 2,
                    width = sliderWidth + 0.2,
                    min = 0.1,
                    max = 5,
                    step = 0.1,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomIncAddDifference")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "reactiveZoomIncAddDifference")
                      end,
                  },
                  incAddDifferenceReset =
                    CreateSliderResetButton(2.1, forSituations, "reactiveZoomIncAddDifference"),
                  blank22 = {type = "description", name = " ", order = 2.2, },

                  maxZoomTime = {
                    type = "range",
                    name = L["Maximum Zoom Time"],
                    desc = L["The maximum time the camera should take to make \"Current Zoom Value\" equal to \"Reactive Zoom Target\"."],
                    order = 3,
                    width = sliderWidth + 0.2,
                    min = 0.1,
                    max = 5,
                    step = 0.05,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "reactiveZoomMaxZoomTime")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "reactiveZoomMaxZoomTime")
                      end,
                  },
                  maxZoomTimeReset =
                    CreateSliderResetButton(3.1, forSituations, "reactiveZoomMaxZoomTime"),
                },
              },
            },
          },
          
          blank11 = {type = "description", name = "\n\n", order = 1.1, },


          reactiveZoomDescriptionGroup = {
            type = "group",
            name = L["Help"],
            order = 2,
            inline = true,
            args = {

              toggleVisualAid = {
                type = "execute",
                name = L["Toggle Visual Aid"],
                func = function() DynamicCam:ToggleRZVA() end,
                order = 1,
                width = "full",
              },
              blank11 = {type = "description", name = " ", order = 1.1, },

              reactiveZoomDescription = {
                type = "description",
                name = L["<reactiveZoom_desc>"],
                order = 2,
              },

              blank21 = {type = "description", name = " ", order = 2.1, },

              enhancedMinZoom = {
                type = "toggle",
                name = L["Enhanced minimal zoom-in"],
                desc = L["<enhancedMinZoom_desc>"],
                order = 3,
                width = "full",
                get =
                  function()
                    return DynamicCam.db.profile.reactiveZoomEnhancedMinZoom
                  end,
                set =
                  function(_, newValue)
                    DynamicCam.db.profile.reactiveZoomEnhancedMinZoom = newValue
                  end,
              },

              reloadMessage = {
                type = "description",
                name = "|cFFFF0000" .. L["/reload of the UI required!"] .. "|r",
                hidden =
                  function()
                    return DynamicCam.modelFrame and DynamicCam.db.profile.reactiveZoomEnhancedMinZoom or not DynamicCam.modelFrame and not DynamicCam.db.profile.reactiveZoomEnhancedMinZoom
                  end,
                order = 4,
              },
              -- Placeholder when reloadMessage is not shown.
              blank4 = {
                type = "description",
                name = " ",
                hidden =
                  function()
                    return not DynamicCam.modelFrame and DynamicCam.db.profile.reactiveZoomEnhancedMinZoom or DynamicCam.modelFrame and not DynamicCam.db.profile.reactiveZoomEnhancedMinZoom
                  end,
                order = 4,
              },
            },
          },
        },
      },  -- /zoomGroup


      mouseLookGroup = {
        type = "group",
        name =
          function()
            return ColoredNames(L["Mouse Look"], mouseLookGroupVars, forSituations)
          end,
        order = 2,
        args = {

          overriddenText = CreateOverriddenText(mouseLookGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(mouseLookGroupVars, forSituations),
          blank01 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },

          mouseLookSubGroup = {
            type = "group",
            name = "",
            _dbPath = forExport and "mouseLookSubGroup" or nil,
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(mouseLookGroupVars)
              end,
            args = {

              cameraYawMoveSpeed = {
                type = "range",
                name = L["Horizontal Speed"],
                desc = L["How much the camera yaws horizontally when in mouse look mode."] .. "\n|cff909090cvar: cameraYawMoveSpeed|r",
                _dbPath = forExport and {"cvars", "cameraYawMoveSpeed"} or nil,
                order = 1,
                width = sliderWidth + 0.2,
                min = 1,
                max = 360,
                step = 1,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "cameraYawMoveSpeed")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "cameraYawMoveSpeed")
                  end,
              },
              cameraYawMoveSpeedReset =
                CreateSliderResetButton(1.1, forSituations, "cvars", "cameraYawMoveSpeed"),
              blank12 = {type = "description", name = " ", order = 1.2, },

              cameraPitchMoveSpeed = {
                type = "range",
                name = L["Vertical Speed"],
                desc = L["How much the camera pitches vertically when in mouse look mode."] .. "\n|cff909090cvar: cameraPitchMoveSpeed|r",
                _dbPath = forExport and {"cvars", "cameraPitchMoveSpeed"} or nil,
                order = 2,
                width = sliderWidth + 0.2,
                min = 1,
                max = 360,
                step = 1,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "cameraPitchMoveSpeed")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "cameraPitchMoveSpeed")
                  end,
              },
              cameraPitchMoveSpeedReset =
                CreateSliderResetButton(2.1, forSituations, "cvars", "cameraPitchMoveSpeed"),
                
              blank22 = {type = "description", name = "\n\n", order = 2.2, },


              mouseLookDescriptionGroup = {
                type = "group",
                name = L["Help"],
                order = 3,
                args = {
                  mouseLookDescription = {
                    type = "description",
                    name = L["<mouseLook_desc>"],
                  },
                },
              },
            },
          },
        },
      },  -- /mouseLookGroup


      shoulderOffsetGroup = {

        type = "group",
        name =
          function()
            return ColoredNames(L["Horizontal Offset"], shoulderOffsetGroupVars, forSituations)
          end,
        order = 3,
        args = {

          overriddenText = CreateOverriddenText(shoulderOffsetGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(shoulderOffsetGroupVars, forSituations),
          blank01 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },

          shoulderOffsetSubGroup = {
            type = "group",
            name = "",
            _dbPath = forExport and "shoulderOffsetSubGroup" or nil,
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(shoulderOffsetGroupVars)
              end,
            args = {
              cameraOverShoulder = {
                type = "range",
                name = L["Camera Over Shoulder Offset"],
                desc = L["Positions the camera left or right from your character."] .. "\n|cff909090cvar: test_cameraOverShoulder|r\n\n",
                _dbPath = forExport and {"cvars", "test_cameraOverShoulder"} or nil,
                order = 1,
                width = sliderWidth - 0.2,
                min = DynamicCam.cvarRanges.test_cameraOverShoulder.min,
                max = DynamicCam.cvarRanges.test_cameraOverShoulder.max,
                step = 0.1,
                disabled = function(info)
                  return GetInheritedDisabledStatus(info) or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraOverShoulder")
                end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraOverShoulder")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraOverShoulder")
                  end,
              },
              cameraOverShoulderReset =
                CreateSliderResetButton(1.1, forSituations, "cvars", "test_cameraOverShoulder"),
              blank12 = {type = "description", name = " ", width = 0.1, order = 1.2, },
              cameraOverShoulderZoomBased = CreateZoomBasedControl(1.3, forSituations, "test_cameraOverShoulder"),
              
              blank14 = {type = "description", name = "\n\n", order = 1.4, },


              cameraOverShoulderDescriptionGroup = {
                type = "group",
                name = L["Help"],
                order = 2,
                args = {
                  cameraOverShoulderDescription = {
                    type = "description",
                    name = L["<cameraOverShoulder_desc>"],
                  },
                },
              },

            },
          },
        },
      },  -- shoulderOffsetGroup


      pitchGroup = {

        type = "group",
        name =
          function()
            return ColoredNames(L["Vertical Pitch"], pitchGroupVars, forSituations)
          end,
        order = 4,
        args = {

          overriddenText = CreateOverriddenText(pitchGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(pitchGroupVars, forSituations),
          blank01 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },

          pitchSubGroup = {
            type = "group",
            name = "",
            _dbPath = forExport and "pitchSubGroup" or nil,
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(pitchGroupVars)
              end,
            args = {

              cameraDynamicPitch = {
                type = "toggle",
                name = L["Enable"],
                _dbPath = forExport and {"cvars", "test_cameraDynamicPitch"} or nil,
                order = 1,
                width = "full",
                desc = "|cff909090cvar: test_cameraDynamicPitch|r",
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 1
                  end,
                set =
                  function(_, newValue)
                    if newValue then
                      DynamicCam:SetSettingsValue(1, forSituations and SID, "cvars", "test_cameraDynamicPitch")
                    else
                      DynamicCam:SetSettingsValue(0, forSituations and SID, "cvars", "test_cameraDynamicPitch")
                    end
                  end,
              },
              blank11 = {type = "description", name = " ", order = 1.1, },

              baseFovPad = {
                type = "range",
                name = L["Pitch (on ground)"],
                _dbPath = forExport and {"cvars", "test_cameraDynamicPitchBaseFovPad"} or nil,
                order = 2,
                width = sliderWidth - 0.3,
                desc = "|cff909090cvar: test_cameraDynamicPitch\nBaseFovPad|r",
                min = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPad.min,
                max = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPad.max,
                step = 0.01,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraDynamicPitchBaseFovPad")
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPad")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPad")
                  end,
              },
              baseFovPadReset =
                CreateSliderResetButton(2.1, forSituations, "cvars", "test_cameraDynamicPitchBaseFovPad", nil,
                  function(info)
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0
                  end),
              blank22 = {type = "description", name = " ", width = 0.1, order = 2.2, },
              baseFovPadZoomBased = CreateZoomBasedControl(2.3, forSituations, "test_cameraDynamicPitchBaseFovPad",
                function(info)
                  return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0
                end),
              blank24 = {type = "description", name = " ", order = 2.4, },

              baseFovPadFlying = {
                type = "range",
                name = L["Pitch (flying)"],
                _dbPath = forExport and {"cvars", "test_cameraDynamicPitchBaseFovPadFlying"} or nil,
                order = 3,
                width = sliderWidth - 0.3,
                desc = "|cff909090cvar: test_cameraDynamicPitch\nBaseFovPadFlying|r",
                min = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPadFlying.min,
                max = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPadFlying.max,
                step = 0.01,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraDynamicPitchBaseFovPadFlying")
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPadFlying")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPadFlying")
                  end,
              },
              baseFovPadFlyingReset =
                CreateSliderResetButton(3.1, forSituations, "cvars", "test_cameraDynamicPitchBaseFovPadFlying", nil,
                  function(info)
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0
                  end),
              blank32 = {type = "description", name = " ", width = 0.1, order = 3.2, },
              baseFovPadFlyingZoomBased = CreateZoomBasedControl(3.3, forSituations, "test_cameraDynamicPitchBaseFovPadFlying",
                function(info)
                  return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0
                end),
              
              blank34 = {type = "description", name = "\n\n", order = 3.4, },

              baseFovPadDownScale = {
                type = "range",
                name = L["Down Scale"],
                _dbPath = forExport and {"cvars", "test_cameraDynamicPitchBaseFovPadDownScale"} or nil,
                order = 4,
                width = sliderWidth - 0.3,
                desc = "|cff909090cvar: test_cameraDynamicPitch\nBaseFovPadDownScale|r",
                min = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPadDownScale.min,
                max = DynamicCam.cvarRanges.test_cameraDynamicPitchBaseFovPadDownScale.max,
                step = 0.01,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraDynamicPitchBaseFovPadDownScale")
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPadDownScale")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraDynamicPitchBaseFovPadDownScale")
                  end,
              },
              baseFovPadDownScaleReset =
                CreateSliderResetButton(4.1, forSituations, "cvars", "test_cameraDynamicPitchBaseFovPadDownScale", nil,
                  function(info)
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0
                  end),
              blank42 = {type = "description", name = " ", width = 0.1, order = 4.2, },
              baseFovPadDownScaleZoomBased = CreateZoomBasedControl(4.3, forSituations, "test_cameraDynamicPitchBaseFovPadDownScale",
                function(info)
                  return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0
                end),
              
              blank44 = {type = "description", name = "\n\n", order = 4.4, },

              smartPivotCutoffDist = {
                type = "range",
                name = L["Smart Pivot Cutoff Distance"],
                _dbPath = forExport and {"cvars", "test_cameraDynamicPitchSmartPivotCutoffDist"} or nil,
                order = 5,
                width = sliderWidth + 0.2,
                desc = "|cff909090cvar: test_cameraDynamicPitch\nSmartPivotCutoffDist|r",
                min = 0,
                max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                step = 0.5,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraDynamicPitchSmartPivotCutoffDist")
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitchSmartPivotCutoffDist")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraDynamicPitchSmartPivotCutoffDist")
                  end,
              },
              smartPivotCutoffDistReset =
                CreateSliderResetButton(5.1, forSituations, "cvars", "test_cameraDynamicPitchSmartPivotCutoffDist", nil,
                  function(info)
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraDynamicPitch") == 0
                  end),
              -- No zoom-based settings for this variable, as its effect itself is zoom based.
              
              blank52 = {type = "description", name = "\n\n", width = 0.1, order = 5.2, },


              pitchDescriptionGroup = {
                type = "group",
                name = L["Help"],
                order = 6,
                args = {
                  pitchDescription = {
                    type = "description",
                    name = L["<pitch_desc>"],
                  },
                },
              },
            },
          },
        },
      },  -- /pitchGroup


      targetFocusGroup = {

        type = "group",
        name =
          function()
            return ColoredNames(L["Target Focus"], targetFocusGroupVars, forSituations)
          end,
        order = 5,
        args = {

          overriddenText = CreateOverriddenText(targetFocusGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(targetFocusGroupVars, forSituations),
          blank01 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },

          targetFocusSubGroup = {
            type = "group",
            name = "",
            _dbPath = forExport and "targetFocusSubGroup" or nil,
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(targetFocusGroupVars)
              end,
            args = {

              targetFocusEnemiesGroup = {
                type = "group",
                name = L["Enemy Target"],
                _dbPath = forExport and "targetFocusEnemiesGroup" or nil,
                order = 1,
                args = {

                  targetFocusEnemyEnable = {
                    type = "toggle",
                    name = L["Enable"],
                    _dbPath = forExport and {"cvars", "test_cameraTargetFocusEnemyEnable"} or nil,
                    order = 1,
                    width = "full",
                    desc = "|cff909090cvar: test_cameraTargetFocus\nEnemyEnable|r",
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable") == 1
                      end,
                    set =
                      function(_, newValue)
                        if newValue then
                          DynamicCam:SetSettingsValue(1, forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable")
                        else
                          DynamicCam:SetSettingsValue(0, forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable")
                        end
                      end,
                  },

                  targetFocusEnemyStrengthYaw = {
                    type = "range",
                    name = L["Horizontal Strength"],
                    _dbPath = forExport and {"cvars", "test_cameraTargetFocusEnemyStrengthYaw"} or nil,
                    order = 2,
                    width = sliderWidth - 0.4,
                    desc = "|cff909090cvar: test_cameraTargetFocus\nEnemyStrengthYaw|r",
                    min = DynamicCam.cvarRanges.test_cameraTargetFocusEnemyStrengthYaw.min,
                    max = DynamicCam.cvarRanges.test_cameraTargetFocusEnemyStrengthYaw.max,
                    step = 0.05,
                    disabled =
                      function(info)
                        return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraTargetFocusEnemyStrengthYaw")
                      end,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyStrengthYaw")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraTargetFocusEnemyStrengthYaw")
                      end,
                  },
                  targetFocusEnemyStrengthYawReset =
                    CreateSliderResetButton(2.1, forSituations, "cvars", "test_cameraTargetFocusEnemyStrengthYaw", nil,
                      function(info)
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable") == 0
                      end),
                  blank22 = {type = "description", name = " ", width = 0.1, order = 2.2, },
                  targetFocusEnemyStrengthYawZoomBased = CreateZoomBasedControl(2.3, forSituations, "test_cameraTargetFocusEnemyStrengthYaw",
                    function(info)
                      return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable") == 0
                    end),
                  blank24 = {type = "description", name = " ", order = 2.4, },

                  targetFocusEnemyStrengthPitch = {
                    type = "range",
                    name = L["Vertical Strength"],
                    _dbPath = forExport and {"cvars", "test_cameraTargetFocusEnemyStrengthPitch"} or nil,
                    order = 3,
                    width = sliderWidth - 0.4,
                    desc = "|cff909090cvar: test_cameraTargetFocus\nEnemyStrengthPitch|r",
                    min = DynamicCam.cvarRanges.test_cameraTargetFocusEnemyStrengthPitch.min,
                    max = DynamicCam.cvarRanges.test_cameraTargetFocusEnemyStrengthPitch.max,
                    step = 0.05,
                    disabled =
                      function(info)
                        return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraTargetFocusEnemyStrengthPitch")
                      end,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyStrengthPitch")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraTargetFocusEnemyStrengthPitch")
                      end,
                  },
                  targetFocusEnemyStrengthPitchReset =
                    CreateSliderResetButton(3.1, forSituations, "cvars", "test_cameraTargetFocusEnemyStrengthPitch", nil,
                      function(info)
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable") == 0
                      end),
                  blank32 = {type = "description", name = " ", width = 0.1, order = 3.2, },
                  targetFocusEnemyStrengthPitchZoomBased = CreateZoomBasedControl(3.3, forSituations, "test_cameraTargetFocusEnemyStrengthPitch",
                    function(info)
                      return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusEnemyEnable") == 0
                    end),
                  -- No blank because end of group box.
                },
              },
              blank11 = {type = "description", name = " ", order = 1.1,},

              targetFocusNPCsGroup = {
                type = "group",
                name = L["Interaction Target (NPCs)"],
                _dbPath = forExport and "targetFocusNPCsGroup" or nil,
                order = 2,
                args = {

                  targetFocusInteractEnable = {
                    type = "toggle",
                    name = L["Enable"],
                    _dbPath = forExport and {"cvars", "test_cameraTargetFocusInteractEnable"} or nil,
                    order = 1,
                    width = "full",
                    desc = "|cff909090cvar: test_cameraTargetFocus\nInteractEnable|r",
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable") == 1
                      end,
                    set =
                      function(_, newValue)
                        if newValue then
                          DynamicCam:SetSettingsValue(1, forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable")
                        else
                          DynamicCam:SetSettingsValue(0, forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable")
                        end
                      end,
                  },

                  targetFocusInteractStrengthYaw = {
                    type = "range",
                    name = L["Horizontal Strength"],
                    _dbPath = forExport and {"cvars", "test_cameraTargetFocusInteractStrengthYaw"} or nil,
                    order = 2,
                    width = sliderWidth - 0.4,
                    desc = "|cff909090cvar: test_cameraTargetFocus\nInteractStrengthYaw|r",
                    min = DynamicCam.cvarRanges.test_cameraTargetFocusInteractStrengthYaw.min,
                    max = DynamicCam.cvarRanges.test_cameraTargetFocusInteractStrengthYaw.max,
                    step = 0.05,
                    disabled =
                      function(info)
                        return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraTargetFocusInteractStrengthYaw")
                      end,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractStrengthYaw")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraTargetFocusInteractStrengthYaw")
                      end,
                  },
                  targetFocusInteractStrengthYawReset =
                    CreateSliderResetButton(2.1, forSituations, "cvars", "test_cameraTargetFocusInteractStrengthYaw", nil,
                      function(info)
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable") == 0
                      end),
                  blank22 = {type = "description", name = " ", width = 0.1, order = 2.2, },
                  targetFocusInteractStrengthYawZoomBased = CreateZoomBasedControl(2.3, forSituations, "test_cameraTargetFocusInteractStrengthYaw",
                    function(info)
                      return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable") == 0
                    end),
                  blank24 = {type = "description", name = " ", order = 2.4, },

                  targetFocusInteractStrengthPitch = {
                    type = "range",
                    name = L["Vertical Strength"],
                    _dbPath = forExport and {"cvars", "test_cameraTargetFocusInteractStrengthPitch"} or nil,
                    order = 3,
                    width = sliderWidth - 0.4,
                    desc = "|cff909090cvar: test_cameraTargetFocus\nInteractStrengthPitch|r",
                    min = DynamicCam.cvarRanges.test_cameraTargetFocusInteractStrengthPitch.min,
                    max = DynamicCam.cvarRanges.test_cameraTargetFocusInteractStrengthPitch.max,
                    step = 0.05,
                    disabled =
                      function(info)
                        return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraTargetFocusInteractStrengthPitch")
                      end,
                    get =
                      function()
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractStrengthPitch")
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraTargetFocusInteractStrengthPitch")
                      end,
                  },
                  targetFocusInteractStrengthPitchReset =
                    CreateSliderResetButton(3.1, forSituations, "cvars", "test_cameraTargetFocusInteractStrengthPitch", nil,
                      function(info)
                        return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable") == 0
                      end),
                  blank32 = {type = "description", name = " ", width = 0.1, order = 3.2, },
                  targetFocusInteractStrengthPitchZoomBased = CreateZoomBasedControl(3.3, forSituations, "test_cameraTargetFocusInteractStrengthPitch",
                    function(info)
                      return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraTargetFocusInteractEnable") == 0
                    end),
                  -- No blank because end of group box.
                },
              },

              blank21 = {type = "description", name = "\n\n", order = 2.1, },


              targetFocusDescriptionGroup = {
                type = "group",
                name = L["Help"],
                order = 3,
                args = {
                  targetFocusDescription = {
                    type = "description",
                    name = L["<targetFocus_desc>"],
                  },
                },
              },
            },
          },
        },
      },  -- /targetFocusGroup


      headTrackingGroup = {

        type = "group",
        name =
          function()
            return ColoredNames(L["Head Tracking"], headTrackingGroupVars, forSituations)
          end,
        order = 6,
        args = {

          overriddenText = CreateOverriddenText(headTrackingGroupVars, forSituations),

          overrideStandardToggle = CreateOverrideStandardToggle(headTrackingGroupVars, forSituations),
          blank01 = {type = "description", name = " ", order = 0.1, hidden = function() return not forSituations end, },

          headTrackingSubGroup = {
            type = "group",
            name = "",
            _dbPath = forExport and "headTrackingSubGroup" or nil,
            order = 1,
            inline = true,
            disabled =
              function()
                return forSituations and not CheckGroupVars(headTrackingGroupVars)
              end,
            args = {

              headTrackingEnable = {
                type = "toggle",
                name = L["Enable"],
                _dbPath = forExport and {"cvars", "test_cameraHeadMovementStrength"} or nil,
                order = 1,
                width = "full",
                desc = "|cff909090cvar: test_cameraHeadMovementStrength\n\n" .. L["<headTrackingEnable_desc>"] .. "|r",
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 1
                  end,
                set =
                  function(_, newValue)
                    if newValue then
                      DynamicCam:SetSettingsValue(1, forSituations and SID, "cvars", "test_cameraHeadMovementStrength")
                    else
                      DynamicCam:SetSettingsValue(0, forSituations and SID, "cvars", "test_cameraHeadMovementStrength")
                    end
                  end,
              },
              blank11 = {type = "description", name = " ", order = 1.1, },

              standingStrength = {
                type = "range",
                order = 2,
                width = sliderWidth - 0.3,
                name = L["Strength (standing)"],
                desc = "|cff909090cvar: test_cameraHeadMovement\nStandingStrength|r",
                _dbPath = forExport and {"cvars", "test_cameraHeadMovementStandingStrength"} or nil,
                min = DynamicCam.cvarRanges.test_cameraHeadMovementStandingStrength.min,
                max = DynamicCam.cvarRanges.test_cameraHeadMovementStandingStrength.max,   -- No effect above 1.
                step = 0.01,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraHeadMovementStandingStrength")
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStandingStrength")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementStandingStrength")
                  end,
              },
              standingStrengthReset =
                CreateSliderResetButton(2.1, forSituations, "cvars", "test_cameraHeadMovementStandingStrength", nil,
                  function(info)
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end),
              blank22 = {type = "description", name = " ", width = 0.1, order = 2.2, },
              standingStrengthZoomBased = CreateZoomBasedControl(2.3, forSituations, "test_cameraHeadMovementStandingStrength",
                function(info)
                  return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                end),
              blank24 = {type = "description", name = " ", order = 2.4, },

              standingDampRate = {
                type = "range",
                order = 3,
                width = sliderWidth - 0.3,
                name = L["Inertia (standing)"],
                desc = "|cff909090cvar: test_cameraHeadMovement\nStandingDampRate|r",
                _dbPath = forExport and {"cvars", "test_cameraHeadMovementStandingDampRate"} or nil,
                min = DynamicCam.cvarRanges.test_cameraHeadMovementStandingDampRate.min,
                max = DynamicCam.cvarRanges.test_cameraHeadMovementStandingDampRate.max,
                step = 0.05,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraHeadMovementStandingDampRate")
                  end,
                get =
                  function()
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStandingDampRate") == 0.01 then
                      return 0
                    else
                      return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStandingDampRate")
                    end
                  end,
                set =
                  function(_, newValue)
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if newValue == 0 then newValue = 0.01 end
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementStandingDampRate")
                  end,
              },
              standingDampRateReset =
                CreateSliderResetButton(3.1, forSituations, "cvars", "test_cameraHeadMovementStandingDampRate", nil,
                  function(info)
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end),
              blank32 = {type = "description", name = " ", width = 0.1, order = 3.2, },
              standingDampRateZoomBased = CreateZoomBasedControl(3.3, forSituations, "test_cameraHeadMovementStandingDampRate",
                function(info)
                  return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                end),
              
              blank34 = {type = "description", name = "\n\n", order = 3.4, },


              movingStrength = {
                type = "range",
                order = 4,
                width = sliderWidth - 0.3,
                name = L["Strength (moving)"],
                desc = "|cff909090cvar: test_cameraHeadMovement\nMovingStrength|r",
                _dbPath = forExport and {"cvars", "test_cameraHeadMovementMovingStrength"} or nil,
                min = DynamicCam.cvarRanges.test_cameraHeadMovementMovingStrength.min,
                max = DynamicCam.cvarRanges.test_cameraHeadMovementMovingStrength.max,   -- No effect above 1.
                step = 0.01,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraHeadMovementMovingStrength")
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementMovingStrength")
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementMovingStrength")
                  end,
              },
              movingStrengthReset =
                CreateSliderResetButton(4.1, forSituations, "cvars", "test_cameraHeadMovementMovingStrength", nil,
                  function(info)
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end),
              blank42 = {type = "description", name = " ", width = 0.1, order = 4.2, },
              movingStrengthZoomBased = CreateZoomBasedControl(4.3, forSituations, "test_cameraHeadMovementMovingStrength",
                function(info)
                  return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                end),
              blank44 = {type = "description", name = " ", order = 4.4, },

              movingDampRate = {
                type = "range",
                order = 5,
                width = sliderWidth - 0.3,
                name = L["Inertia (moving)"],
                desc = "|cff909090cvar: test_cameraHeadMovement\nMovingDampRate|r",
                _dbPath = forExport and {"cvars", "test_cameraHeadMovementMovingDampRate"} or nil,
                min = DynamicCam.cvarRanges.test_cameraHeadMovementMovingDampRate.min,
                max = DynamicCam.cvarRanges.test_cameraHeadMovementMovingDampRate.max,
                step = 0.05,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraHeadMovementMovingDampRate")
                  end,
                get =
                  function()
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementMovingDampRate") == 0.01 then
                      return 0
                    else
                      return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementMovingDampRate")
                    end
                  end,
                set =
                  function(_, newValue)
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if newValue == 0 then newValue = 0.01 end
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementMovingDampRate")
                  end,
              },
              movingDampRateReset =
                CreateSliderResetButton(5.1, forSituations, "cvars", "test_cameraHeadMovementMovingDampRate", nil,
                  function(info)
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end),
              blank52 = {type = "description", name = " ", width = 0.1, order = 5.2, },
              movingDampRateZoomBased = CreateZoomBasedControl(5.3, forSituations, "test_cameraHeadMovementMovingDampRate",
                function(info)
                  return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                end),
              
              blank54 = {type = "description", name = "\n\n", order = 5.4, },


              firstPersonDampRate = {
                type = "range",
                order = 6,
                width = sliderWidth - 0.3,
                name = L["Inertia (first person)"],
                desc = "|cff909090cvar: test_cameraHeadMovement\nFirstPersonDampRate|r",
                _dbPath = forExport and {"cvars", "test_cameraHeadMovementFirstPersonDampRate"} or nil,
                min = DynamicCam.cvarRanges.test_cameraHeadMovementFirstPersonDampRate.min,
                max = DynamicCam.cvarRanges.test_cameraHeadMovementFirstPersonDampRate.max,
                step = 0.05,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraHeadMovementFirstPersonDampRate")
                  end,
                get =
                  function()
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementFirstPersonDampRate") == 0.01 then
                      return 0
                    else
                      return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementFirstPersonDampRate")
                    end
                  end,
                set =
                  function(_, newValue)
                    -- Real minimum is 0.01, but makes the slider look odd.
                    if newValue == 0 then newValue = 0.01 end
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementFirstPersonDampRate")
                  end,
              },
              firstPersonDampRateReset =
                CreateSliderResetButton(6.1, forSituations, "cvars", "test_cameraHeadMovementFirstPersonDampRate", nil,
                  function(info)
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end),
              blank62 = {type = "description", name = " ", width = 0.1, order = 6.2, },
              firstPersonDampRateZoomBased = CreateZoomBasedControl(6.3, forSituations, "test_cameraHeadMovementFirstPersonDampRate",
                function(info)
                  return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                end),
              
              blank64 = {type = "description", name = "\n\n", order = 6.4, },


              rangeScale = {
                type = "range",
                order = 7,
                width = sliderWidth + 0.2,
                name = L["Range Scale"],
                desc = L["Camera distance beyond which head tracking is reduced or disabled. (See explanation below.)"] .. "\n|cff909090cvar: test_ cameraHeadMovementRangeScale\n" .. L["(slider value transformed)"] .. "|r",
                _dbPath = forExport and {"cvars", "test_cameraHeadMovementRangeScale"} or nil,
                min = 0,
                max = 117,
                step = 0.5,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraHeadMovementRangeScale")
                  end,
                get =
                  function()
                    return (DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementRangeScale")  * 3.25) + 0.1625
                  end,
                set =
                  function(_, newValue)
                    newValue = (newValue - 0.1625) / 3.25
                    DynamicCam:SetSettingsValue(newValue, forSituations and SID, "cvars", "test_cameraHeadMovementRangeScale")
                  end,
              },
              rangeScaleReset =
                CreateSliderResetButton(7.1, forSituations, "cvars", "test_cameraHeadMovementRangeScale",
                                        Round((DynamicCam:GetSettingsDefault("cvars", "test_cameraHeadMovementRangeScale") * 3.25) + 0.1625, 2),
                  function(info)
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end),
              -- No zoom-based settings for this variable, as its effect itself is zoom based.
              blank73 = {type = "description", name = " ", order = 7.3, },

              deadZone = {
                type = "range",
                order = 8,
                width = sliderWidth + 0.2,
                name = L["Dead Zone"],
                desc = L["Radius of head movement not affecting the camera. (See explanation below.)"] .. "\n|cff909090cvar: test_ cameraHeadMovementDeadZone\n" .. L["(slider value devided by 10)"] .. "|r\n|cffe00000" .. L["Requires /reload to come into effect!"] .. "|r",
                _dbPath = forExport and {"cvars", "test_cameraHeadMovementDeadZone"} or nil,
                min = 0,
                max = 10,
                step = 0.05,
                disabled =
                  function(info)
                    return GetInheritedDisabledStatus(info) or DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0 or DynamicCam:IsCvarZoomBased(forSituations and SID, "test_cameraHeadMovementDeadZone")
                  end,
                get =
                  function()
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementDeadZone") * 10
                  end,
                set =
                  function(_, newValue)
                    DynamicCam:SetSettingsValue(newValue / 10, forSituations and SID, "cvars", "test_cameraHeadMovementDeadZone")
                  end,
              },
              deadZoneReset =
                CreateSliderResetButton(8.1, forSituations, "cvars", "test_cameraHeadMovementDeadZone",
                                            Round(DynamicCam:GetSettingsDefault("cvars", "test_cameraHeadMovementDeadZone") * 10, 2),
                  function(info)
                    return DynamicCam:GetSettingsValue(forSituations and SID, "cvars", "test_cameraHeadMovementStrength") == 0
                  end),
              -- No zoom-based settings for this variable, as it does not take effect without /reload.
              blank83 = {type = "description", name = " ", order = 8.3, },

              headTrackingDescriptionGroup = {
                type = "group",
                name = L["Help"],
                order = 9,
                args = {
                  headTrackingDescription = {
                    type = "description",
                    name = L["<headTracking_desc>"],
                  },
                },
              },
            },
          },
        },
      },  -- /headTrackingGroup

    },  -- /args
  }
end


local function CreateSituationSettingsTab(tabOrder, forExport)

  local returnOptions = {

    type = "group",
    name = L["Situations"],
    order = tabOrder,

    childGroups = "tab",

    args = {

      selectedSituation = {
        type = "select",
        name = L["Select a situation to setup"],
        desc = L["<selectedSituation_desc>"],
        get =
          function()
            UpdateLastSelectedSID(SID)
            return SID
          end,
        set =
          function(_, newValue)
            local newSituation = DynamicCam.db.profile.situations[newValue]
            UpdateSituationState(newSituation, newValue)
            UpdateLastSelectedSID(newValue)
          end,
        values =
          function()
            return GetSituationList()
          end,
        width = 2.2,
        order = 1,
      },
      blank15 = {type = "description", name = " ", width = 0.1, order = 1.5, },

      enabled = {
        type = "toggle",
        name = L["Enable"],
        desc =
          function()
            return L["If this box is checked, DynamicCam will enter the situation \"%s\" whenever its condition is fulfilled and no other situation with higher priority is active."]:format(S.name)
          end,
        disabled =
          function()
            return not S
          end,
        get =
          function()
            return S.enabled
          end,
        set =
          function(_, newValue)
            S.enabled = newValue
            if newValue then
              DynamicCam:UpdateSituation(SID)
            else
              DynamicCam:EvaluateSituations()
            end
          end,
        width = 0.7,
        order = 2,
      },
      blank25 = {type = "description", name = " ", width = 0.1, order = 2.5, },

      deleteCustom = {
        type = "execute",
        name = "-",
        desc =
          function()
            return L["Delete custom situation \"%s\".\n|cFFEE0000Attention: There will be no 'Are you sure?' prompt!|r"]:format(S.name)
          end,
        hidden =
          function()
            return not S or not string.find(SID, "custom")
          end,
        func =
          function()
            DynamicCam:DeleteCustomSituation(SID)
          end,
        order = 3,
        width = 0.23,
      },
      deleteCustomPlaceholder = {
        type = "description",
        name = " ",
        hidden =
          function()
            return S and string.find(SID, "custom")
          end,
        width = 0.23,
        order = 3,
      },
      blank35 = {type = "description", name = " ", width = 0.03, order = 3.5, },

      newSituation = {
        type = "execute",
        name = "+",
        desc = L["Create a new custom situation."],
        func = function() DynamicCam:PopupCreateCustomProfile() end,
        order = 4,
        width = 0.23,
      },


      situationSettings = CreateSettingsTab(5, true),


      situationActions = {

        type = "group",
        name = L["Situation Actions"],
        order = 6,

        args = {

          help = {
            type = "description",
            name = L["Setup stuff to happen while in a situation or when entering/exiting it."] .. "\n\n",
            order = 0,
          },

          transitionTimeSettings = {
            type = "group",
            name =
              function()
                -- Grey out when both times are 0
                local isActive = S.transitionTime.timeToEnter > 0 or S.transitionTime.timeToExit > 0
                return GreyWhenInactive(L["Transition Time"], isActive)
              end,
            order = 0.5,
            args = {

              transitionTimeReset = {
                type = "execute",
                name = L["Reset"],
                image = "Interface\\Transmogrify\\Transmogrify",
                imageCoords = Options.resetButtonImageCoords,
                imageWidth = 25/1.5,
                imageHeight = 24/1.5,
                desc = L["Reset to global default"] .. "!\n" .. L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"],
                order = 1.5,
                width = 0.25,
                func =
                  function()
                    for k in pairs(S.transitionTime) do
                      S.transitionTime[k] = DynamicCam.situationDefaults.transitionTime[k]
                    end
                  end,
                disabled =
                  function()
                    for k in pairs(S.transitionTime) do
                      if S.transitionTime[k] ~= DynamicCam.situationDefaults.transitionTime[k] then
                        return false
                      end
                    end
                    return true
                  end,
              },

              transitionTimeGroup = {
                type = "group",
                name = "",
                order = 2,
                inline = true,
                args = {

                  timeToEnter = {
                    type = "range",
                    name = L["Enter Transition Time"],
                    desc = L["The time in seconds for the transition when ENTERING this situation."],
                    width = "full",
                    min = 0,
                    max = 5,
                    step = 0.1,
                    get =
                      function()
                        return S.transitionTime.timeToEnter
                      end,
                    _dbPath = forExport and {"transitionTime", "timeToEnter"} or nil,
                    set =
                      function(info, newValue)
                        S.transitionTime.timeToEnter = newValue
                      end,
                    order = 1,
                  },

                  timeToExit = {
                    type = "range",
                    name = L["Exit Transition Time"],
                    desc = L["The time in seconds for the transition when EXITING this situation."],
                    width = "full",
                    min = 0,
                    max = 5,
                    step = 0.1,
                    get =
                      function()
                        return S.transitionTime.timeToExit
                      end,
                    _dbPath = forExport and {"transitionTime", "timeToExit"} or nil,
                    set =
                      function(info, newValue)
                        S.transitionTime.timeToExit = newValue
                      end,
                    order = 2,
                  },
                  blank21 = {type = "description", name = " ", order = 2.1, },

                  transitionTimeDescriptionGroup = {
                    type = "group",
                    name = L["Help"],
                    order = 3,
                    args = {
                      transitionTimeDescription = {
                        type = "description",
                        name = L["<transitionTime_desc>"],
                      },
                    },
                  },

                },
              },
            },
          },

          viewZoomSettings = {
            type = "group",
            name =
              function()
                return GreyWhenInactive(L["Zoom/View"], S.viewZoom.enabled)
              end,
            order = 1,
            args = {

              viewZoomToggle = {
                type = "toggle",
                name = L["Enable"],
                desc = L["Zoom to a certain zoom level or switch to a saved camera view when entering this situation."],
                get =
                  function()
                    return S.viewZoom.enabled
                  end,
                _dbPath = forExport and {"viewZoom", "enabled"} or nil,
                set =
                  function(_, newValue)
                    S.viewZoom.enabled = newValue
                  end,
                order = 1,
              },
              viewZoomReset = {
                type = "execute",
                -- name = CreateAtlasMarkup("transmog-icon-revert-small", 20, 20),
                name = L["Reset"],
                image = "Interface\\Transmogrify\\Transmogrify",
                imageCoords = Options.resetButtonImageCoords,
                imageWidth = 25/1.5,
                imageHeight = 24/1.5,
                desc = L["Reset to global default"] .. "!\n" .. L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"],
                order = 1.5,
                width = 0.25,
                func =
                  function()
                    for k in pairs(S.viewZoom) do
                      if k ~= "enabled" and k ~= "viewZoomType" then
                        S.viewZoom[k] = DynamicCam.situationDefaults.viewZoom[k]
                      end
                    end
                  end,
                disabled =
                  function()
                    if not S.viewZoom.enabled then return true end
                    for k in pairs(S.viewZoom) do
                      if k ~= "enabled" and k ~= "viewZoomType" and S.viewZoom[k] ~= DynamicCam.situationDefaults.viewZoom[k] then
                        return false
                      end
                    end
                    return true
                  end,
              },

              viewZoomGroup = {
                type = "group",
                name = "",
                order = 2,
                disabled =
                  function()
                    return not S.viewZoom.enabled
                  end,
                inline = true,
                args = {

                  viewZoomType = {
                    type = "select",
                    name = L["Set Zoom or Set View"],
                    desc = "\n" .. L["<viewZoomType_desc>"],
                    width = "full",
                    disabled =
                      function()
                        return not S.viewZoom.enabled
                      end,
                    get =
                      function()
                        return S.viewZoom.viewZoomType
                      end,
                    set =
                      function(_, newValue)
                        S.viewZoom.viewZoomType = newValue
                      end,
                    values = {
                      ["zoom"] = L["Set Zoom"],
                      ["view"] = L["Set View"],
                    },
                    sorting = {
                      "zoom",
                      "view",
                    },
                    order = 2,
                  },
                  blank21 = {type = "description", name = " ", order = 2.1, },


                  viewBox = {

                    type = "group",
                    name = L["Set View"],
                    order = 3,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "view"
                      end,
                    args = {

                      view = {
                        type = "select",
                        name = L["Set view to saved view:"],
                        desc = L["Select the saved view to switch to when entering this situation."],
                        get =
                          function()
                            return S.viewZoom.viewNumber
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.viewNumber = newValue
                          end,
                        values = {
                          [2] = "View 2",
                          [3] = "View 3",
                          [4] = "View 4",
                          [5] = "View 5"
                        },
                        order = 1,
                        width = 0.8,
                      },
                      blank11 = {type = "description", name = " ", order = 1.1, width = 0.1, },
                      instant = {
                        type = "toggle",
                        name = L["Instant"],
                        desc = L["Make view transitions instant."],
                        get =
                          function()
                            return S.viewZoom.viewInstant
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.viewInstant = newValue
                          end,
                        order = 2,
                        width = "half",
                      },

                      viewRestore = {
                        type = "toggle",
                        name = L["Restore view when exiting"],
                        desc = L["When exiting the situation restore the camera position to what it was at the time of entering the situation."],
                        hidden =
                          function()
                            return GetCVar("cameraSmoothStyle") ~= "0"
                          end,
                        get =
                          function()
                            return S.viewZoom.viewRestore
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.viewRestore = newValue
                          end,
                        order = 3,
                        width = "full",
                      },

                      cameraSmoothNote = {
                        type = "description",
                        hidden =
                          function()
                            return GetCVar("cameraSmoothStyle") == "0"
                          end,
                        order = 4,
                        name = L["cameraSmoothNote"],
                      },

                      viewRestoreToDefault = {
                        type = "select",
                        name = L["Restore to default view:"],
                        desc = L["<viewRestoreToDefault_desc>"],
                        hidden =
                          function()
                            return GetCVar("cameraSmoothStyle") == "0"
                          end,
                        get =
                          function()
                            return S.viewZoom.restoreDefaultViewNumber
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.restoreDefaultViewNumber = newValue
                          end,
                        values = {
                          [1] = "View 1",
                          [2] = "View 2",
                          [3] = "View 3",
                          [4] = "View 4",
                          [5] = "View 5"
                        },
                        order = 5,
                        width = "full",
                      },

                      cameraSmoothWarning = {
                        type = "description",
                        hidden =
                          function ()
                            if GetCVar("cameraSmoothStyle") == "0" then return true end

                            local usedViews, usedDefaultViews = GetUsedViews()

                            for usedView in pairs(usedViews) do
                              -- We know that at least one other situation used this view.
                              if usedDefaultViews[usedView] then
                                -- print("View", usedView, "used as saved and default view.")
                                return false
                              end
                            end
                            return true
                          end,

                        order = 6,
                        name =
                          function()
                            if GetCVar("cameraSmoothStyle") == "0" then return "" end

                            local usedViews, usedDefaultViews = GetUsedViews()

                            local returnString = "|cFFEE0000" .. L["WARNING"] .. ":|r" .. L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."] .. "\n"

                            for usedView, usedViewSituationList in pairs(usedViews) do

                              -- We know that at least one other situation used this view.
                              if usedDefaultViews[usedView] then

                                local savedViewSituations = ""
                                for usedViewSituationId in pairs(usedViewSituationList) do
                                  savedViewSituations = savedViewSituations .. "    - " .. DynamicCam.db.profile.situations[usedViewSituationId].name .. "\n"
                                end

                                local restoreToDefaultSituations = ""
                                for usedDefaultViewSituationId in pairs(usedDefaultViews[usedView]) do
                                  restoreToDefaultSituations = restoreToDefaultSituations .. "    - " ..  DynamicCam.db.profile.situations[usedDefaultViewSituationId].name .. "\n"
                                end


                                returnString = returnString .. "\n\n" .. L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"]:format(usedView, savedViewSituations, restoreToDefaultSituations) .. "\n"




                              end
                            end

                            return returnString
                          end,
                      },
                    },
                  },
                  blank31 = {type = "description", name = " ", order = 3.1, },

                  viewDescriptionGroup = {
                    type = "group",
                    name = L["Help"],
                    order = 4,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "view"
                      end,
                    args = {
                      viewDescription = {
                        type = "description",
                        name = L["<view_desc>"],
                      },
                    },
                  },


                  zoomBox = {
                    type = "group",
                    name = L["Set Zoom"],
                    order = 3,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                    args = {

                      zoomType = {
                        type = "select",
                        name = L["Zoom Type"],
                        desc = L["<zoomType_desc>"],
                        width = 0.8,
                        get =
                          function()
                            return S.viewZoom.zoomType
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.zoomType = newValue
                          end,
                        values = {
                          ["set"] = L["Set"],
                          ["out"] = L["Out"],
                          ["in"] = L["In"],
                          ["range"] = L["Range"],
                        },
                        sorting = {
                          "set",
                          "out",
                          "in",
                          "range",
                        },
                        order = 2,
                      },
                      blank21 = {type = "description", name = " ", order = 2.1, width = 0.2, },

                      zoomTimeIsMaxToggle = {
                        type = "toggle",
                        name = L["Don't slow"],
                        desc = L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."],
                        get =
                          function()
                            return S.viewZoom.zoomTimeIsMax
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.zoomTimeIsMax = newValue
                          end,
                        width = 0.8,
                        order = 2.2,
                      },
                      blank23 = {type = "description", name = " ", order = 2.3, },

                      zoomValue = {
                        type = "range",
                        name = L["Zoom Value"],
                        desc =
                          function()
                            if S.viewZoom.zoomType == "set" then
                              return L["Zoom to this zoom level."]
                            elseif S.viewZoom.zoomType == "out" then
                              return L["Zoom out to this zoom level, if the current zoom level is less than this."]
                            elseif S.viewZoom.zoomType == "in" then
                              return L["Zoom in to this zoom level, if the current zoom level is greater than this."]
                            end
                          end,
                        width = "full",
                        hidden =
                          function()
                            return S.viewZoom.zoomType == "range"
                          end,
                        min = 0,
                        max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                        step = .5,
                        get =
                          function()
                            return S.viewZoom.zoomValue
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.zoomValue = newValue
                          end,
                        order = 3,
                      },

                      zoomMin = {
                        type = "range",
                        name = L["Zoom Min"],
                        desc = L["Zoom out to this zoom level, if the current zoom level is less than this."],
                        width = "full",
                        hidden =
                          function()
                            return S.viewZoom.zoomType ~= "range"
                          end,
                        min = 0,
                        max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                        step = .5,
                        get =
                          function()
                            return S.viewZoom.zoomMin
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.zoomMin = newValue
                            if S.viewZoom.zoomMin > S.viewZoom.zoomMax then
                              S.viewZoom.zoomMax = S.viewZoom.zoomMin
                            end
                          end,
                        order = 3,
                      },
                      blank31 = {
                        type = "description",
                        name = " ",
                        order = 3.1,
                        hidden =
                          function()
                            return S.viewZoom.zoomType ~= "range"
                          end,
                      },
                      zoomMax = {
                        type = "range",
                        name = L["Zoom Max"],
                        desc = L["Zoom in to this zoom level, if the current zoom level is greater than this."],
                        width = "full",
                        hidden =
                          function()
                            return S.viewZoom.zoomType ~= "range"
                          end,
                        min = 0,
                        max = DynamicCam.cameraDistanceMaxZoomFactor_max,
                        step = .5,
                        get =
                          function()
                            return S.viewZoom.zoomMax
                          end,
                        set =
                          function(_, newValue)
                            S.viewZoom.zoomMax = newValue
                            if S.viewZoom.zoomMax < S.viewZoom.zoomMin then
                              S.viewZoom.zoomMin = S.viewZoom.zoomMax
                            end
                          end,
                        order = 4,
                      },

                    },

                  },
                  blank31 = {
                    type = "description",
                    name = " ",
                    order = 3.1,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                  },

                  zoomRestoreSettingGroup = {
                    type = "group",
                    name = L["Restore Zoom"],
                    order = 4,
                    disabled = false,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                    args = {

                      zoomRestoreSettingDescription = {
                        type = "description",
                        name = L["<zoomRestoreSetting_desc>"],
                        order = 0,
                      },

                      zoomRestoreSettingSelect = {
                        type = "select",
                        name = L["Restore Zoom Mode"],
                        desc = L["<zoomRestoreSettingSelect_desc>"],
                        order = 1,
                        width = "full",
                        get =
                          function()
                            return DynamicCam.db.profile.zoomRestoreSetting
                          end,
                        set =
                          function(_, newValue)
                            DynamicCam.db.profile.zoomRestoreSetting = newValue
                          end,
                        values = {
                          ["never"] = L["Never"],
                          ["always"] = L["Always"],
                          ["adaptive"] = L["Adaptive"],
                        },
                        sorting = {
                          "never",
                          "always",
                          "adaptive",
                        },
                      },

                    },
                  },
                  blank41 = {
                    type = "description",
                    name = " ",
                    order = 4.1,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                  },

                  zoomDescriptionGroup = {
                    type = "group",
                    name = L["Help"],
                    order = 5,
                    hidden =
                      function()
                        return S.viewZoom.viewZoomType ~= "zoom"
                      end,
                    args = {
                      zoomDescription = {
                        type = "description",
                        name = L["<zoom_desc>"],
                      },
                    },
                  },

                },
              },

            },

          },


          rotationSettings = {
            type = "group",
            name =
              function()
                return GreyWhenInactive(L["Rotation"], S.rotation.enabled)
              end,
            order = 2,
            args = {

              rotationToggle = {
                type = "toggle",
                name = L["Enable"],
                desc = L["Start a camera rotation when this situation is active."],
                get =
                  function()
                    return S.rotation.enabled
                  end,
                set =
                  function(_, newValue)
                    S.rotation.enabled = newValue
                    ApplyContinuousRotation()
                  end,
                order = 1,
              },
              rotationReset = {
                type = "execute",
                -- name = CreateAtlasMarkup("transmog-icon-revert-small", 20, 20),
                name = L["Reset"],
                image = "Interface\\Transmogrify\\Transmogrify",
                imageCoords = Options.resetButtonImageCoords,
                imageWidth = 25/1.5,
                imageHeight = 24/1.5,
                desc = L["Reset to global default"] .. "!\n" .. L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"],
                order = 1.5,
                width = 0.25,
                func =
                  function()
                    for k in pairs(S.rotation) do
                      if k ~= "enabled" then
                        S.rotation[k] = DynamicCam.situationDefaults.rotation[k]
                      end
                    end
                    ApplyContinuousRotation()
                  end,
                disabled =
                  function()
                    if not S.rotation.enabled then return true end
                    for k in pairs(S.rotation) do
                      if k ~= "enabled" and S.rotation[k] ~= DynamicCam.situationDefaults.rotation[k] then
                        return false
                      end
                    end
                    return true
                  end,
              },

              rotationGroup = {
                type = "group",
                name = "",
                order = 2,
                disabled =
                  function()
                    return not S.rotation.enabled
                  end,
                inline = true,
                args = {

                  rotationType = {
                    type = "select",
                    name = L["Rotation Type"],
                    desc = L["<rotationType_desc>"],
                    get =
                      function()
                        return S.rotation.rotationType
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.rotationType = newValue
                        ApplyContinuousRotation()
                      end,
                    values = {
                      ["continuous"] = L["Continuously"],
                      ["degrees"] = L["By Degrees"],
                    },
                    width = "full",
                    order = 1,
                  },
                  blank11 = {type = "description", name = "\n\n", order = 1.1, },

                  rotationSpeed = {
                    type = "range",
                    name = L["Rotation Speed"],
                    desc = L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."],
                    min = -900,
                    max = 900,
                    softMin = -90,
                    softMax = 90,
                    hidden =
                      function()
                        return S.rotation.rotationType ~= "continuous"
                      end,
                    step = 1,
                    get =
                      function()
                        return S.rotation.rotationSpeed
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.rotationSpeed = newValue
                        ApplyContinuousRotation()
                      end,
                    width = "full",
                    order = 3,
                  },

                  yawDegrees = {
                    type = "range",
                    name = L["Yaw (-Left/Right+)"],
                    desc = L["Degrees to yaw (left or right)."],
                    min = -1400,
                    max = 1440,
                    softMin = -360,
                    softMax = 360,
                    hidden =
                      function()
                        return S.rotation.rotationType == "continuous"
                      end,
                    step = 5,
                    get =
                      function()
                        return S.rotation.yawDegrees
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.yawDegrees = newValue
                      end,
                    width = "full",
                    order = 3,
                  },
                  blank31 = {
                    type = "description",
                    name = " ",
                    hidden =
                      function()
                        return S.rotation.rotationType == "continuous"
                      end,
                    order = 3.1,
                  },
                  pitchDegrees = {
                    type = "range",
                    name = L["Pitch (-Down/Up+)"],
                    desc = L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."],
                    min = -180,
                    max = 180,
                    hidden =
                      function()
                        return S.rotation.rotationType == "continuous"
                      end,
                    step = 5,
                    get =
                      function()
                        return S.rotation.pitchDegrees
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.pitchDegrees = newValue
                      end,
                    width = "full",
                    order = 4,
                  },


                  blank41 = {type = "description", name = "\n\n", order = 4.1, },

                  rotateBack = {
                    type = "toggle",
                    name = L["Rotate Back"],
                    desc = L["<rotateBack_desc>"],
                    get =
                      function()
                        return S.rotation.rotateBack
                      end,
                    set =
                      function(_, newValue)
                        S.rotation.rotateBack = newValue
                      end,
                    width = "normal",
                    order = 5,
                  },
                },
              },
            },
          },


          hideUISettings = {
            type = "group",
            name =
              function()
                return GreyWhenInactive(L["Fade Out UI"], S.hideUI.enabled)
              end,
            order = 3,
            args = {
              hideUIToggle = {
                type = "toggle",
                name = L["Enable"],
                desc = L["Fade out or hide (parts of) the UI when this situation is active."],
                get =
                  function()
                    return S.hideUI.enabled
                  end,
                set =
                  function(_, newValue)
                    S.hideUI.enabled = newValue
                    ApplyUIFade()
                  end,
                order = 1,
              },
              hideUIReset = {
                type = "execute",
                -- name = CreateAtlasMarkup("transmog-icon-revert-small", 20, 20),
                name = L["Reset"],
                image = "Interface\\Transmogrify\\Transmogrify",
                imageCoords = Options.resetButtonImageCoords,
                imageWidth = 25/1.5,
                imageHeight = 24/1.5,
                desc = L["Reset to global default"] .. "!\n" .. L["(To restore the settings of a specific profile, restore the profile in the \"Profiles\" tab.)"],
                order = 1.5,
                width = 0.25,
                func =
                  function()
                    for k in pairs(S.hideUI) do
                      if k ~= "enabled" then
                        S.hideUI[k] = DynamicCam.situationDefaults.hideUI[k]
                      end
                    end
                    ApplyUIFade()
                  end,
                disabled =
                  function()
                    if not S.hideUI.enabled then return true end
                    for k in pairs(S.hideUI) do
                      if k ~= "enabled" and S.hideUI[k] ~= DynamicCam.situationDefaults.hideUI[k] then
                        return false
                      end
                    end
                    return true
                  end,
              },
              blank16 = {type = "description", name = "", width = 0.3, order = 1.6, },

              adjustToImmersion = {
                type = "execute",
                name = L["Adjust to Immersion"],
                desc = L["<adjustToImmersion_desc>"],
                func =
                  function()
                    S.transitionTime.timeToEnter = 0.2
                    S.transitionTime.timeToExit = 0.5
                  end,
                order = 1.7,
                width = 1,
                hidden =
                  function()
                    return SID ~= "300"
                  end,
              },
              blank18 = {type = "description", name = " ", order = 1.8, },

              hideUIGroup = {
                type = "group",
                name = "",
                order = 2,
                disabled =
                  function()
                    return not S.hideUI.enabled
                  end,
                inline = true,
                args = {

                  hideEntireUI = {
                    type = "toggle",
                    name =
                      function()
                        local text = L["Hide entire UI"]
                        if S.hideUI.hideEntireUI then
                          return "|cFFFF4040" .. text .. "|r"
                        else
                          return text
                        end
                      end,
                    desc = L["<hideEntireUI_desc>"],
                    disabled =
                      function()
                        return not S.hideUI.enabled
                      end,
                    get =
                      function()
                        return S.hideUI.hideEntireUI
                      end,
                    set =
                      function(_, newValue)
                        if newValue then
                          S.hideUI.fadeOpacity = 0
                        end
                        S.hideUI.hideEntireUI = newValue
                      end,
                    order = 3,
                  },

                  keepFrameRate = {
                    type = "toggle",
                    name = L["Keep FPS indicator"],
                    desc = L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."],
                    disabled =
                      function()
                        return not S.hideUI.enabled
                      end,
                    get =
                      function()
                        return S.hideUI.keepFrameRate
                      end,
                    set =
                      function(_, newValue)
                        S.hideUI.keepFrameRate = newValue
                      end,
                    order = 4,
                  },
                  blank42 = {type = "description", name = "\n\n", order = 4.2, },

                  hideUIFadeOpacity = {
                    type = "range",
                    name = L["Fade Opacity"],
                    desc = L["Fade the UI to this opacity when entering the situation."],
                    min = 0,
                    max = 1,
                    step = .01,
                    disabled =
                      function()
                        return not S.hideUI.enabled or S.hideUI.hideEntireUI
                      end,
                    get =
                      function()
                        return S.hideUI.fadeOpacity
                      end,
                    set =
                      function(_, newValue)
                        S.hideUI.fadeOpacity = newValue
                        ApplyUIFade()
                      end,
                    width = "full",
                    order = 5,
                  },
                  blank52 = {type = "description", name = "\n\n", order = 5.2, },

                  excludedFramesGroup = {
                    type = "group",
                    name = L["Excluded UI elements"],
                    order = 6,
                    disabled =
                      function()
                        return not S.hideUI.enabled or S.hideUI.hideEntireUI
                      end,
                    args = {

                      keepAlertFrames = {
                        type = "toggle",
                        name = L["Keep Alerts"],
                        desc = L["Still show alert popups from completed achievements, Covenant Renown, etc."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepAlertFrames
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepAlertFrames = newValue
                            ApplyUIFade()
                          end,
                        order = 1,
                        width = 0.9,
                      },

                      keepTooltip = {
                        type = "toggle",
                        name = L["Keep Tooltip"],
                        desc = L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepTooltip
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepTooltip = newValue
                            ApplyUIFade()
                          end,
                        order = 2,
                        width = 0.9,
                      },

                      keepMinimap = {
                        type = "toggle",
                        name = L["Keep Minimap"],
                        desc = L["<keepMinimap_desc>"],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepMinimap
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepMinimap = newValue
                            ApplyUIFade()
                          end,
                        order = 3,
                        width = 0.9,
                      },

                      keepChatFrame = {
                        type = "toggle",
                        name = L["Keep Chat Box"],
                        desc = L["Do not fade out the chat box."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepChatFrame
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepChatFrame = newValue
                            ApplyUIFade()
                          end,
                        order = 4,
                        width = 0.9,
                      },

                      keepTrackingBar = {
                        type = "toggle",
                        name = L["Keep Tracking Bar"],
                        desc = L["Do not fade out the tracking bar (XP, AP, reputation)."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepTrackingBar
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepTrackingBar = newValue
                            ApplyUIFade()
                          end,
                        order = 5,
                        width = 0.9,
                      },

                      keepPartyRaidFrame = {
                        type = "toggle",
                        name = L["Keep Party/Raid"],
                        desc = L["Do not fade out the Party/Raid frame."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepPartyRaidFrame
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepPartyRaidFrame = newValue
                            ApplyUIFade()
                          end,
                        order = 5,
                        width = 0.9,
                      },

                      keepEncounterBar = {
                        type = "toggle",
                        name = L["Keep Encounter Frame (Skyriding Vigor)"],
                        desc = L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepEncounterBar
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepEncounterBar = newValue
                            ApplyUIFade()
                          end,
                        order = 6,
                        width = "full",
                      },

                      blank61 = {type = "description", name = " ", order = 6.1, },

                      keepCustomFrames = {
                        type = "toggle",
                        name = L["Keep additional frames"],
                        desc = L["<keepCustomFrames_desc>"],
                        get =
                          function()
                            if S.hideUI.hideEntireUI then return false end
                            return S.hideUI.keepCustomFrames
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.keepCustomFrames = newValue
                            ApplyUIFade()
                          end,
                        order = 8,
                        width = 2,
                      },

                      customFramesToKeep = {
                        type = "input",
                        name = L["Custom frames to keep"],
                        desc = L["Separated by commas."],
                        get =
                          function()
                            returnString = ""
                            for k, v in pairs(S.hideUI.customFramesToKeep) do
                              if v == true then
                                if returnString ~= "" then
                                  returnString = returnString .. ", "
                                end
                                returnString = returnString .. k
                              end
                            end
                            return returnString
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.customFramesToKeep = {}

                            newValue = string.gsub(newValue, "%s+", "")
                            for k, v in pairs({strsplit(",", newValue)}) do
                              -- Not checking if frame exists, because some frames are only created when needed (e.g. DebuffFrame).
                              S.hideUI.customFramesToKeep[v] = true
                            end

                            -- We have to set unused default frames explicitly to false, otherwise they will be put back on reload.
                            for k, _ in pairs(DynamicCam.situationDefaults.hideUI.customFramesToKeep) do
                              if S.hideUI.customFramesToKeep[k] == nil then
                                S.hideUI.customFramesToKeep[k] = false
                              end
                            end

                            ApplyUIFade()
                          end,
                        disabled = function() return not S.hideUI.keepCustomFrames end,
                        multiline = 3,
                        order = 9,
                        width = "full",
                      },

                    },
                  },
                  blank62 = {type = "description", name = " ", order = 6.2, },

                  emergencyShowGroup = {
                    type = "group",
                    name = L["Emergency Fade In"],
                    order = 7,
                    disabled =
                      function()
                        return not S.hideUI.enabled
                      end,
                    args = {
                      emergencyShowEscEnabled = {
                        type = "toggle",
                        name = L["Pressing Esc fades the UI back in."],
                        get =
                          function()
                            return S.hideUI.emergencyShowEscEnabled
                          end,
                        set =
                          function(_, newValue)
                            S.hideUI.emergencyShowEscEnabled = newValue
                          end,
                        order = 1,
                        width = "full",
                      },
                      emergencyShowDescription = {
                        type = "description",
                        name = L["<emergencyShow_desc>"],
                        order = 2,
                      },
                    },
                  },
                },
              },
              blank22 = {type = "description", name = " ", order = 2.2, },

              hideUIHelpGroup = {
                type = "group",
                name = L["Help"],
                order = 3,
                inline = true,
                args = {
                  hideUIHelpDescription = {
                    type = "description",
                    name = L["<hideUIHelp_desc>"],
                    order = 1,
                  },
                  settingsPanelIgnoreParentAlpha = {
                    type = "toggle",
                    name = L["Do not fade out this \"Interface\" settings frame."],
                    get =
                      function()
                        return SettingsPanel:IsIgnoringParentAlpha()
                      end,
                    set =
                      function(_, newValue)
                        DynamicCam.db.profile.settingsPanelIgnoreParentAlpha = newValue
                        DynamicCam:SettingsPanelSetIgnoreParentAlpha(newValue)
                      end,
                    width = "full",
                    order = 2,
                  },
                },
              },
            },
          },
        },
      },


      situationControls = {

        type = "group",
        name = function() return ColourTextErrorOrModified(L["Situation Controls"]) end,
        order = 7,
        args = {

          help = {
            type = "description",
            name = L["<situationControls_help>"],
            order = 0,
          },

          priority = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified(L["Priority"], "value", "priority")
              end,
            order = 1,
            args = {

              priority = {
                type = "input",
                name = L["Priority"],
                desc = L["The priority of this situation.\nMust be a number."],
                get = function() return ""..S.priority end,
                _dbPath = forExport and "priority" or nil,
                set =
                  function(_, newValue)
                    if tonumber(newValue) then
                      S.priority = tonumber(newValue)
                    end
                    DynamicCam:UpdateSituation(SID)
                  end,
                order = 1,
              },
              priorityDefault = {
                type = "execute",
                name = L["Restore stock setting"],
                desc =
                  function()
                    return L["Your \"Priority\" deviates from the stock setting for this situation (%s). Click here to restore it."]:format(DynamicCam.defaults.profile.situations[SID].priority)
                  end,
                func =
                  function()
                    S.priority = DynamicCam.defaults.profile.situations[SID].priority
                      DynamicCam:UpdateSituation(SID)
                  end,
                hidden =
                  function()
                    return ValueIsDefault(SID, "priority")
                  end,
                order = 2,
              },
              blank22 = {type = "description", name = " ", order = 2.2, },

              priorityDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 3,
                args = {
                  priorityDescription = {
                    type = "description",
                    name = L["<priority_desc>"],
                  },
                },
              },
            },
          },

          events = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified(L["Events"], "events", "events")
              end,
            order = 2,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "events" then
                      return "|cFFEE0000" .. L["Error message:"] .. "\n\n" .. S.errorMessage .. "|r\n\n"
                    end
                  end,
                hidden =
                  function()
                    return not S.errorEncountered or S.errorEncountered ~= "events"
                  end,
                order = 0
              },

              events = {
                type = "input",
                name = L["Events"],
                desc = L["Separated by commas."],
                get = function() return table.concat(S.events, ", ") end,
                _dbPath = forExport and "events" or nil,
                set =
                  function(_, newValue)
                    if newValue == "" then
                      S.events = {}
                    else
                      newValue = string.gsub(newValue, "%s+", "")
                      S.events = {strsplit(",", newValue)}
                    end
                    DynamicCam:UpdateSituation(SID)
                  end,
                multiline = 10,
                width = "full",
                order = 1,
              },

              eventsDefault = {
                type = "execute",
                name = L["Restore stock setting"],
                desc = L["Your \"Events\" deviate from the default for this situation. Click here to restore them."],
                func =
                  function()
                    S.events = DynamicCam.defaults.profile.situations[SID].events
                    DynamicCam:UpdateSituation(SID)
                  end,
                hidden =
                  function()
                    return EventsIsDefault(SID)
                  end,
                order = 2,
              },
              blank22 = {type = "description", name = " ", order = 2.2, },

              eventsDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 3,
                args = {
                  eventsDescription = {
                    type = "description",
                    name = L["<events_desc>"],

-- TODO: Still need this for classic:
-- Notice, that you have to manually scroll down after the window first opens. Then you can use these commands to stop and start the logging:

  -- /eventtrace stop
  -- /eventtrace start

-- If you want to get serious with the event trace, put these two commands into macros and keybind them, so you can stop and start quickly.

                  },
                },
              },
            },
          },

          executeOnInit = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified(L["Initialisation"], "script", "executeOnInit")
              end,
            order = 3,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "executeOnInit" then
                      return "|cFFEE0000" .. L["Error message:"] .. "\n\n" .. S.errorMessage .. "|r\n\n"
                    end
                  end,
                hidden =
                  function()
                    return not S.errorEncountered or S.errorEncountered ~= "executeOnInit"
                  end,
                order = 0
              },

              executeOnInit = {
                type = "input",
                name = L["Initialisation Script"],
                desc = L["Lua code using the WoW UI API."],
                get = function() return S.executeOnInit end,
                _dbPath = forExport and "executeOnInit" or nil,
                set =
                  function(_, newValue)
                    S.executeOnInit = newValue
                    DynamicCam:UpdateSituation(SID)
                  end,
                multiline = 10,
                width = "full",
                order = 1,
              },

              executeOnInitDefault = {
                type = "execute",
                name = L["Restore stock setting"],
                desc = L["Your \"Initialisation Script\" deviates from the stock setting for this situation. Click here to restore it."],
                func =
                  function()
                    S.executeOnInit = DynamicCam.defaults.profile.situations[SID].executeOnInit
                    DynamicCam:UpdateSituation(SID)
                  end,
                hidden =
                  function()
                    return ScriptIsDefault(SID, "executeOnInit")
                  end,
                order = 2,
              },
              blank22 = {type = "description", name = " ", order = 2.2, },

              initialisationDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 3,
                args = {
                  initialisationDescription = {
                    type = "description",
                    name = L["<initialisation_desc>"],
                  },
                },
              },
            },
          },

          condition = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified(L["Condition"], "script", "condition")
              end,
            order = 4,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "condition" then
                      return "|cFFEE0000Error message:\n\n" .. S.errorMessage .. "|r\n\n"
                    end
                  end,
                hidden =
                  function()
                    return not S.errorEncountered or S.errorEncountered ~= "condition"
                  end,
                order = 0
              },

              condition = {
                type = "input",
                name = L["Condition Script"],
                desc = L["Lua code using the WoW UI API.\nShould return \"true\" if and only if the situation should be active."],
                get = function() return S.condition end,
                _dbPath = forExport and "condition" or nil,
                set =
                  function(_, newValue)
                    S.condition = newValue
                    DynamicCam:UpdateSituation(SID)
                  end,
                multiline = 10,
                width = "full",
                order = 1,
              },

              conditionDefault = {
                type = "execute",
                name = L["Restore stock setting"],
                desc = L["Your \"Condition Script\" deviates from the stock setting for this situation. Click here to restore it."],
                func =
                  function()
                    S.condition = DynamicCam.defaults.profile.situations[SID].condition
                    DynamicCam:UpdateSituation(SID)
                  end,
                hidden =
                  function()
                    return ScriptIsDefault(SID, "condition")
                  end,
                order = 2,
              },
              blank22 = {type = "description", name = " ", order = 2.2, },

              conditionDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 3,
                args = {
                  conditionDescription = {
                    type = "description",
                    name = L["<condition_desc>"],
                  },
                },
              },
            },
          },

          executeOnEnter = {
            type = "group",
            name =
              function()
                return ColourTextErrorOrModified(L["Entering"], "script", "executeOnEnter")
              end,
            order = 5,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "executeOnEnter" then
                      return L["|cFFEE0000Error message:\n\n"] .. S.errorMessage .. "|r\n\n"
                    end
                  end,
                hidden =
                  function()
                    return not S.errorEncountered or S.errorEncountered ~= "executeOnEnter"
                  end,
                order = 0
              },

              executeOnEnter = {
                type = "input",
                name = L["On-Enter Script"],
                desc = L["Lua code using the WoW UI API."],
                get = function() return S.executeOnEnter end,
                _dbPath = forExport and "executeOnEnter" or nil,
                set =
                  function(_, newValue)
                    S.executeOnEnter = newValue
                    DynamicCam:UpdateSituation(SID)
                  end,
                multiline = 10,
                width = "full",
                order = 1,
              },

              executeOnEnterDefault = {
                type = "execute",
                name = L["Restore stock setting"],
                desc = L["Your \"On-Enter Script\" deviates from the stock setting for this situation. Click here to restore it."],
                func =
                  function()
                    S.executeOnEnter = DynamicCam.defaults.profile.situations[SID].executeOnEnter
                    DynamicCam:UpdateSituation(SID)
                  end,
                hidden =
                  function()
                    return ScriptIsDefault(SID, "executeOnEnter")
                  end,
                order = 2,
              },
              blank22 = {type = "description", name = " ", order = 2.2, },

              executeOnEnterDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 3,
                args = {
                  executeOnEnterDescription = {
                    type = "description",
                    name = L["<executeOnEnter_desc>"],
                  },
                },
              },

            },
          },

          executeOnExit = {
            type = "group",
            name =
                function()
                    if (S.errorEncountered and S.errorEncountered == executeOnExit) or not ScriptIsDefault(SID, "executeOnExit") then
                        return ColourTextErrorOrModified(L["Exiting"], "script", "executeOnExit")
                    else
                        return ColourTextErrorOrModified(L["Exiting"], "value", "delay")
                    end
                end,
            order = 6,
            args = {

              errorMessage = {
                type = "description",
                name =
                  function()
                    if S.errorEncountered and S.errorEncountered == "executeOnExit" then
                      return L["|cFFEE0000Error message:\n\n"] .. S.errorMessage .. "|r\n\n"
                    end
                  end,
                hidden =
                  function()
                    return not S.errorEncountered or S.errorEncountered ~= "executeOnExit"
                  end,
                order = 0
              },

              executeOnExit = {
                type = "input",
                name = L["On-Exit Script"],
                desc = L["Lua code using the WoW UI API."],
                get = function() return S.executeOnExit end,
                _dbPath = forExport and "executeOnExit" or nil,
                set =
                  function(_, newValue)
                    S.executeOnExit = newValue
                    DynamicCam:UpdateSituation(SID)
                  end,
                multiline = 10,
                width = "full",
                order = 1,
              },
              executeOnExitDefaultWrapper = {
                type = "group",
                name = "",
                inline = true,
                width = "full",
                order = 2,
                args = {
                  executeOnExitDefault = {
                    type = "execute",
                    name = L["Restore stock setting"],
                    desc = L["Your \"On-Exit Script\" deviates from the stock setting for this situation. Click here to restore it."],
                    func =
                      function()
                        S.executeOnExit = DynamicCam.defaults.profile.situations[SID].executeOnExit
                        DynamicCam:UpdateSituation(SID)
                      end,
                  },
                },
                hidden =
                  function()
                    return ScriptIsDefault(SID, "executeOnExit")
                  end,
              },
              blank21 = {type = "description", name = " ", order = 2.1, },

              exitDelay = {
                type = "input",
                name = L["Exit Delay"],
                desc = L["Wait for this many seconds before exiting this situation."],
                get = function() return ""..S.delay end,
                _dbPath = forExport and "delay" or nil,
                set =
                  function(_, newValue)
                    if tonumber(newValue) then
                      S.delay = tonumber(newValue)
                    end
                    DynamicCam:UpdateSituation(SID)
                  end,
                width = "half",
                order = 3,
              },
              exitDelayDefaultWrapper = {
                type = "group",
                name = "",
                inline = true,
                width = "full",
                order = 4,
                args = {
                  exitDelayDefault = {
                    type = "execute",
                    name = L["Restore stock setting"],
                    desc = L["Your \"Exit Delay\" deviates from the stock setting for this situation. Click here to restore it."],
                    func =
                      function()
                        S.delay = DynamicCam.defaults.profile.situations[SID].delay
                        DynamicCam:UpdateSituation(SID)
                      end,
                  },
                },
                hidden =
                  function()
                    return ValueIsDefault(SID, "delay")
                  end,
              },
              blank41 = {type = "description", name = " ", order = 4.1, },

              executeOnExitDescriptionGroup = {
                type = "group",
                name = L["Help"],
                inline = true,
                order = 5,
                args = {
                  executeOnExitDescription = {
                    type = "description",
                    name = L["<executeOnExit_desc>"],
                  },
                },
              },

            },
          },

        },
      },


      export = {

        type = "group",
        name = L["Export"],
        order = 8,

        args = {

          description = {
            type = "description",
            name = L["Coming soon(TM)."] .. " (In the meantime, enjoy this non-functional preview...)\n\n",
            order = 1,
          },

          -- TODO
          exportFrame = {
            type = "input",
            name = "SituationExport",
            dialogControl = "DynamicCam_CustomWidget",
            width = "full",
          },
        },
      },

      import = {

        type = "group",
        name = L["Import"],
        order = 9,

        args = {

          description = {
              type = "description",
              name = L["Coming soon(TM)."],
              order = 1,
          },


          -- TODO
          -- copy = {
              -- type = "execute",
              -- name = "Copy",
              -- desc = "Copy this situations settings so that you can paste it into another situation.\n\nDoesn't copy the condition or the advanced mode Lua scripts.",
              -- hidden = function() return not S end,
              -- func = function() copiedSituationID = SID end,
              -- order = 5,
              -- width = "half",
          -- },

          -- paste = {
              -- type = "execute",
              -- name = "Paste",
              -- desc = "Paste the settings from that last copied situation.",
              -- hidden = function() return not S end,
              -- disabled = function() return not copiedSituationID end,
              -- func = function()
                      -- DynamicCam:CopySituationInto(copiedSituationID, SID)
                      -- copiedSituationID = nil
                  -- end,
              -- order = 6,
              -- width = "half",
          -- },

          -- export = {
              -- type = "execute",
              -- name = "Export",
              -- desc = "If you want to share the settings of this situation with others you can export it into a text string. Use the \"Import\" section of the DynamicCam settings to import strings you have received from others.",
              -- hidden = function() return not S end,
              -- func = function() DynamicCam:PopupExport(DynamicCam:ExportSituation(SID)) end,
              -- order = 7,
              -- width = "half",
          -- },

          -- helpText = {
              -- type = "description",
              -- name = "If you have the DynamicCam import string for a profile or situation, paste it in the text box below to import it. You can generate such import strings yourself using the export functions in the \"Profiles\" or \"Situations\" sections of the DynamicCam settings.\n\n|cFFFF4040YOUR CURRENT PROFILE WILL BE OVERRIDDEN WITHOUT WARNING, SO MAKE A COPY IF YOU WANT TO KEEP IT!|r\n",
              -- order = 8,
          -- },
          -- import = {
              -- type = "input",
              -- name = "Paste and hit Accept to import!",
              -- desc = "Paste the DynamicCam import string of a profile or a situation.",
              -- get = function() return "" end,
              -- set = function(_, newValue) DynamicCam:Import(newValue) end,
              -- multiline = 10,
              -- width = "full",
              -- order = 9,
          -- },

        },

      },

    },
  }

  return returnOptions

end



local about = {
  type = "group",
  name = L["About"],
  order = 10,
  args = {
    situationControlsWarning = {
      type = "group",
      name = " ",
      order = 1,
      inline = true,
      hidden =
        function()
          for situationId in pairs(DynamicCam.defaults.profile.situations) do
            if not SituationControlsAreDefault(situationId) then return false end
          end
          return true
        end,
      args = {
        header = {
          type = "header",
          name = "|cFFEE0000" .. L["WARNING"] .. "!|r",
          order = 1,
        },
        message = {
          type = "description",
          name =
            function()
              local returnString = L["The following game situations have \"Situation Controls\" deviating from DynamicCam's stock settings.\n\n"]

              for situationId, situation in pairs(DynamicCam.defaults.profile.situations) do
                if not SituationControlsAreDefault(situationId) then
                  returnString = returnString .. "  - " .. situation.name .. "\n"
                end
              end

              returnString = returnString .. L["<situationControlsWarning>"]

              return returnString

            end,
          order = 2,
        },
        restoreDefaultsButton = {
          type = "execute",
          name = L["Restore all stock Situation Controls"],
          order = 3,
          width = "full",
          func =
            function()
              for situationId in pairs(DynamicCam.defaults.profile.situations) do
                SituationControlsToDefault(situationId)
              end
            end,
        },
      }
    },
    blank1 = {
      type = "description",
      name = " ",
      order = 1.1,
      hidden =
        function()
          for situationId in pairs(DynamicCam.defaults.profile.situations) do
            if not SituationControlsAreDefault(situationId) then return false end
          end
          return true
        end,
    },
    messageGroup = {
      type = "group",
      name = "",
      order = 2,
      inline = true,
      args = {
        heading = {
          type = "header",
          name = L["Hello and welcome to DynamicCam!"],
        },
        message = {
          type = "description",
          name = L["<welcomeMessage>"],
        },
      }
    },
  },
}





local profileSettings = {
  type = "group",
  name = L["Profiles"],
  order = 4,
  childGroups = "tab",
  args = {

    manageProfiles = {
      type = "group",
      name = L["Manage Profiles"],
      order = 1,
      args = {

        blank99 = {type = "description", name = " ", order = 99, },

        manageProfilesWarningGroup = {
          type = "group",
          name = L["Help"],
          inline = true,
          order = 100,
          args = {
            manageProfilesWarning = {
              type = "description",
              name = L["<manageProfilesWarning>"],
            },
          },
        },
      },
    },

    presets = {
      type = "group",
      name = L["Profile presets"],
      order = 2,
      args = {
        description = {
          type = "description",
          name = L["Coming soon(TM)."],
          order = 1,
        },

        -- TODO
        -- description = {
          -- type = "description",
          -- name = "Here are some preset profiles created by other DynamicCam users. Do you have a profile that's unlike any of these? Please export it and post it together with a name and description on the DynamicCam user forum! We will then consider putting it into the next release.",
          -- order = 1,
        -- },
        -- loadPreset = {
          -- type = "select",
          -- name = "Load Preset",
          -- desc = "Select a preset profile to load it.\n|cFFFF4040YOUR CURRENT PROFILE WILL BE OVERRIDDEN WITHOUT WARNING, SO MAKE A COPY IF YOU WANT TO KEEP IT!|r",
          -- get = function() return "" end,
          -- set = function(_, newValue) DynamicCam:LoadPreset(newValue) end,
          -- values = function() return DynamicCam:GetPresets() end,
          -- sorting = function() return DynamicCam:GetPresetsSorting() end,
          -- width = "full",
          -- order = 2,
        -- },
        -- presetDescriptions = {
          -- type = "group",
          -- name = "Descriptions",
          -- order = 3,
          -- inline = true,
          -- args = {
            -- description = {
              -- type = "description",
              -- name = function() return DynamicCam:GetPresetDescriptions() end,
              -- order = 1,
            -- },
          -- },
        -- },
      },
    },

    importExport = {
      type = "group",
      name = L["Import / Export"],
      order = 3,
      args = {
        description = {
          type = "description",
          name = L["Coming soon(TM)."],
          order = 1,
        },

        -- TODO
        -- helpText = {
          -- type = "description",
          -- name = "If you want to share your profile with others you can export it into a text string. Use \"Import\" to import strings you have received from others.",
          -- order = 0,
        -- },
        -- name = {
          -- type = "input",
          -- name = "Profile Name (Required!)",
          -- desc = "The name that other people will see when importing this profile.",
          -- get = function() return exportName end,
          -- set = function(_, newValue) exportName = newValue end,
          -- --width = "double",
          -- order = 1,
        -- },
        -- author = {
          -- type = "input",
          -- name = "Author (Optional)",
          -- desc = "A name that will be attached to the export so that other people know whom it's from.",
          -- get = function() return exportAuthor end,
          -- set = function(_, newValue) exportAuthor = newValue end,
          -- order = 2,
        -- },
        -- export = {
          -- type = "execute",
          -- name = "Generate export string",
          -- disabled = function() return not (exportName and exportName ~= "") end,
          -- func = function() DynamicCam:PopupExport(DynamicCam:ExportProfile(exportName, exportAuthor)) end,
          -- order = 3,
        -- },

        -- helpText = {
          -- type = "description",
          -- name = "If you have the DynamicCam import string for a profile or situation, paste it in the text box below to import it. You can generate such import strings yourself using the export functions in the \"Profiles\" or \"Situations\" sections of the DynamicCam settings.\n\n|cFFFF4040YOUR CURRENT PROFILE WILL BE OVERRIDDEN WITHOUT WARNING, SO MAKE A COPY IF YOU WANT TO KEEP IT!|r\n",
          -- order = 4,
        -- },
        -- import = {
          -- type = "input",
          -- name = "Paste and hit Accept to import!",
          -- desc = "Paste the DynamicCam import string of a profile or a situation.",
          -- get = function() return "" end,
          -- set = function(_, newValue) DynamicCam:Import(newValue) end,
          -- multiline = 10,
          -- width = "full",
          -- order = 5,
        -- },

      },
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
  UpdateSituationState(nil, nil)
  UpdateLastSelectedSID(nil)
end

-- This function is needed to call SelectSituation() and
-- ignore the "message" argument passed to ReselectSituation().
function Options:ReselectSituation()
  self:SelectSituation()
end


-- If there has been user interaction with situation settings before (lastSelectedSID ~= nil),
-- do not change the currently selected situation.
function Options:SelectSituation(selectMe)
  if selectMe and DynamicCam.db.profile.situations[selectMe] then
    UpdateSituationState(DynamicCam.db.profile.situations[selectMe], selectMe)
  elseif not lastSelectedSID and DynamicCam.currentSituationID then
    UpdateSituationState(DynamicCam.db.profile.situations[DynamicCam.currentSituationID], DynamicCam.currentSituationID)
  elseif not SID or not S then
    local firstSID, firstS = next(DynamicCam.db.profile.situations)
    UpdateSituationState(firstS, firstSID)
  end

  LibStub("AceConfigRegistry-3.0"):NotifyChange("DynamicCam")
end



function Options:RegisterMenus()
  -- setup menu

  -- Add profile managing here, such that we can have export below it.
  profileSettings.args.manageProfiles.args.acedbPanel = LibStub("AceDBOptions-3.0"):GetOptionsTable(DynamicCam.db)

  profileSettings.args.manageProfiles.args.acedbPanel.name = ""
  profileSettings.args.manageProfiles.args.acedbPanel.inline = true
  profileSettings.args.manageProfiles.args.acedbPanel.order = 1


  local allOptions = {
    name = L["DynamicCam"],
    type = "group",
    childGroups = "tab",
    args = {
      aboutTab = about,
      standardSettingsTab = CreateSettingsTab(2),
      situationSettingsTab = CreateSituationSettingsTab(3),
      profileSettingsTab = profileSettings,
    }
  }

  LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("DynamicCam", allOptions)
  self.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DynamicCam", "DynamicCam")

end


-- Export the settings tab creation functions to the Options module
-- so they can be called from Options/Widgets.lua for the SituationExport widget
Options.CreateSettingsTab = CreateSettingsTab
Options.CreateSituationSettingsTab = CreateSituationSettingsTab


-- Custom widgets are now defined in Options/Widgets.lua
-- CVar monitoring is now in Options/CvarMonitor.lua
