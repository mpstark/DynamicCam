-------------------------------------------------------------------------------
-- DynamicCam new settings UI - Situation Actions descriptor.
--
-- What a situation DOES: how long its transitions take, whether it sets a view
-- or a zoom, whether it rotates the camera, and whether it fades the UI. These
-- live on the situation object itself and are addressed with situationPath (see
-- Ui/Descriptor.lua for what that means and why it is not the settings layer).
--
-- Differences from the old UI's Situation Actions tab, all deliberate:
--   * "Set Zoom/View" was one group with a Set-Zoom-or-Set-View dropdown inside
--     it. It is two categories here, each with its own Enable, and the two
--     enables are mutually exclusive - checking one unchecks the other, which is
--     what that dropdown expressed.
--   * Where the old UI put several controls in one row, each gets its own row.
--   * Where a group had one Reset for all of its values, each value has its own.
--   * "Adjust to Immersion" was a button; it is a checkbox that shows whether
--     the transition times currently match Immersion's, so the state is visible
--     and reversible rather than write-only.
-------------------------------------------------------------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)
local Ui = DynamicCam.Ui


-- ===== Helpers =====

local function Situation(sid)
  return sid and DynamicCam.db.profile.situations[sid]
end

-- The situation's viewZoom block, or nil when nothing is selected.
local function ViewZoom(sid)
  local s = Situation(sid)
  return s and s.viewZoom
end

-- The two Enable checkboxes are one tri-state underneath: viewZoom.enabled plus
-- viewZoomType picking which of the two is meant. Checking one therefore
-- unchecks the other; unchecking either turns the whole block off.
local function ViewZoomModeOn(mode)
  return function(sid)
    local vz = ViewZoom(sid)
    return vz ~= nil and vz.enabled and vz.viewZoomType == mode
  end
end

local function SetViewZoomMode(mode)
  return function(value, sid)
    local vz = ViewZoom(sid)
    if not vz then return end
    vz.enabled = value and true or false
    if value then vz.viewZoomType = mode end
  end
end

-- Gates for the rows below each Enable.
local ViewOn = ViewZoomModeOn("view")
local ZoomOn = ViewZoomModeOn("zoom")

-- Visibility rules below select between MUTUALLY EXCLUSIVE rows - Zoom Value
-- versus Zoom Min/Max, continuous versus by-degrees rotation - so exactly one
-- variant is on screen. They deliberately do NOT consider the category's Enable:
-- turning a category off greys its rows, it never makes them disappear. Falling
-- back to the stock default keeps one variant showing while no situation is
-- selected, instead of the category emptying out.
local function CurrentZoomType(sid)
  local vz = ViewZoom(sid)
  return vz and vz.zoomType or DynamicCam.situationDefaults.viewZoom.zoomType
end

local function ZoomTypeIs(zoomType)
  return function(sid) return CurrentZoomType(sid) == zoomType end
end

local function ZoomTypeIsNot(zoomType)
  return function(sid) return CurrentZoomType(sid) ~= zoomType end
end

-- WoW's camera-following styles put the camera behind the player automatically,
-- which a customised saved view cannot do. So the two restore-on-exit controls
-- are alternatives rather than companions, and only the applicable one is shown
-- - matching how the exit path in SituationManager picks between them: with
-- following off it returns to view 1 ("Restore view when exiting"), with it on
-- it resets to one of the default views instead.
local function CameraFollowingOff()
  return GetCVar("cameraSmoothStyle") == "0"
end

local function CameraFollowingOn()
  return GetCVar("cameraSmoothStyle") ~= "0"
end

-- Which situations claim which view numbers, as a saved view and as a
-- restore-to-default view.
--
-- Deliberately not Options.GetUsedViews, for two reasons. It skips situations
-- that are disabled or erroring, which would make this warning appear and
-- vanish as the situation being looked at is switched on and off - but a clash
-- is a property of the CONFIGURATION, latent whether or not the situation runs
-- today. And it has a bug: its `if not usedDefaultViews[sc.def]` reads a field
-- that does not exist, so the list is reset on every situation and only the last
-- one survives, under-reporting who is on the restore-to-default side.
local function ViewClaims()
  local saved, restoreDefault = {}, {}
  for id, situation in pairs(DynamicCam.db.profile.situations) do
    local vz = situation.viewZoom
    -- Note what each situation is CONFIGURED with, not what it is doing right
    -- now: no test of vz.enabled or vz.viewZoomType. Either would make this
    -- warning vanish the moment the situation being looked at is switched off or
    -- flipped to Set Zoom, when the clash it describes is still sitting in the
    -- profile waiting to bite.
    if vz then
      saved[vz.viewNumber] = saved[vz.viewNumber] or {}
      saved[vz.viewNumber][id] = true
      local restoreTo = vz.restoreDefaultViewNumber
      if restoreTo then
        restoreDefault[restoreTo] = restoreDefault[restoreTo] or {}
        restoreDefault[restoreTo][id] = true
      end
    end
  end
  return saved, restoreDefault
end

-- Views claimed as BOTH a saved view somewhere and a restore-to-default view
-- somewhere: returning to a default view resets it, silently undoing the
-- customisation the other situation relies on. Returns the conflicting view
-- numbers, plus the two claim tables so the warning can name the situations.
local function ConflictingViews()
  local saved, restoreDefault = ViewClaims()
  local conflicts = {}
  for view in pairs(saved) do
    if restoreDefault[view] then conflicts[#conflicts + 1] = view end
  end
  table.sort(conflicts)
  return conflicts, saved, restoreDefault
end

local function SituationNameList(situationIds)
  local names = {}
  for id in pairs(situationIds) do
    names[#names + 1] = "    - " .. DynamicCam.db.profile.situations[id].name .. "\n"
  end
  table.sort(names)   -- pairs() order would otherwise shuffle between refreshes
  return table.concat(names)
end

local function RotationOn(sid)
  local s = Situation(sid)
  return s ~= nil and s.rotation.enabled
end

local function RotationTypeIs(rotationType)
  return function(sid)
    local s = Situation(sid)
    local current = s and s.rotation.rotationType
      or DynamicCam.situationDefaults.rotation.rotationType
    return current == rotationType
  end
end

local function HideUIOn(sid)
  local s = Situation(sid)
  return s ~= nil and s.hideUI.enabled
end

-- Narrower than the category's own condition, which already covers hideUI being
-- enabled at all: fading to an opacity additionally needs the UI not to be
-- hidden outright.
local function FadeOpacityApplies(sid)
  local s = Situation(sid)
  return s ~= nil and not s.hideUI.hideEntireUI
end

local function KeepCustomFramesOn(sid)
  local s = Situation(sid)
  return s ~= nil and s.hideUI.keepCustomFrames
end

-- Rotations run live, so changing one has to restart it; the UI fade likewise
-- has to be re-applied to be seen. Both only matter while the edited situation
-- is the ACTIVE one.
--
-- Deliberately not the old UI's Options.ApplyContinuousRotation/ApplyUIFade:
-- those read Options.S / Options.SID, the OLD frame's selected situation, which
-- has nothing to do with the one this page is editing.
-- Applied on every change, so dragging the speed slider steers the live
-- rotation as it moves - restarting the yaw at the new speed is what the old UI
-- did too, and is not the reason it used to look frantic. That was this reading
-- the wrong situation entirely; see above.
local function ApplyRotation(sid)
  local s = Situation(sid)
  if not s or sid ~= DynamicCam.currentSituationID then return end
  DynamicCam.LibCamera:StopRotating()
  if s.rotation.enabled and s.rotation.rotationType == "continuous" then
    DynamicCam.LibCamera:BeginContinuousYaw(s.rotation.rotationSpeed, 0)
  end
end

local function ApplyFade(sid)
  local s = Situation(sid)
  if not s or sid ~= DynamicCam.currentSituationID then return end
  DynamicCam:FadeInUI(0)
  if s.hideUI.enabled then
    DynamicCam:FadeOutUI(0, s.hideUI)
  end
end

-- Immersion's own fade timings. The NPC Interaction situation is the only one
-- that overlaps with Immersion, hence the row's shownWhen.
local IMMERSION_SITUATION   = "300"
local IMMERSION_TIME_ENTER  = 0.2
local IMMERSION_TIME_EXIT   = 0.5

-- The comma-separated frame list shown in the Fade Out UI text box. Stored as a
-- set, so it is joined for display and split on the way back - and every default
-- frame the user removed has to be stored as an explicit false, or it would
-- reappear on the next reload.
local function GetCustomFrames(sid)
  local s = Situation(sid)
  if not s then return "" end
  local names = {}
  for frame, keep in pairs(s.hideUI.customFramesToKeep) do
    if keep == true then names[#names + 1] = frame end
  end
  table.sort(names)   -- the old UI's pairs() order was arbitrary between reloads
  return table.concat(names, ", ")
end

local function SetCustomFrames(value, sid)
  local s = Situation(sid)
  if not s then return end
  local keep = {}
  for _, frame in ipairs({strsplit(",", (value:gsub("%s+", "")))}) do
    -- Not checking that the frame exists: some are only created on demand
    -- (DebuffFrame), so an unknown name is not necessarily a mistake.
    if frame ~= "" then keep[frame] = true end
  end
  for frame in pairs(DynamicCam.situationDefaults.hideUI.customFramesToKeep) do
    if keep[frame] == nil then keep[frame] = false end
  end
  s.hideUI.customFramesToKeep = keep
  ApplyFade()
end


Ui.actionCategories = {

  {
    name = L["Transition Time"],
    info = L["<transitionTime_desc>"],
    items = {
      { kind = "slider", label = L["Enter Transition Time"],
        tooltip = L["The time in seconds for the transition when ENTERING this situation."],
        situationPath = {"transitionTime", "timeToEnter"},
        min = 0, max = 5, step = 0.1 },
      { kind = "slider", label = L["Exit Transition Time"],
        tooltip = L["The time in seconds for the transition when EXITING this situation."],
        situationPath = {"transitionTime", "timeToExit"},
        min = 0, max = 5, step = 0.1 },
      -- Derived from the two sliders above rather than stored: checked while
      -- they match Immersion's timings. Unchecking restores the stock defaults,
      -- since there would otherwise be no way back except dragging both.
      { kind = "checkbox", label = L["Adjust to Immersion"],
        tooltip = L["<adjustToImmersion_desc>"],
        shownWhen = function(sid) return sid == IMMERSION_SITUATION end,
        get = function(sid)
          local s = Situation(sid)
          return s ~= nil
            and s.transitionTime.timeToEnter == IMMERSION_TIME_ENTER
            and s.transitionTime.timeToExit  == IMMERSION_TIME_EXIT
        end,
        set = function(value, sid)
          local s = Situation(sid)
          if not s then return end
          local defaults = DynamicCam.situationDefaults.transitionTime
          s.transitionTime.timeToEnter = value and IMMERSION_TIME_ENTER or defaults.timeToEnter
          s.transitionTime.timeToExit  = value and IMMERSION_TIME_EXIT  or defaults.timeToExit
        end },
    },
  },

  {
    name = L["Set View"],
    enabledWhen = ViewOn,
    info = L["<view_desc>"],
    items = {
      { kind = "checkbox", label = L["Enable"],
        tooltip = L["<setViewEnable_desc>"],
        ignoreCategoryGate = true, get = ViewOn, set = SetViewZoomMode("view") },
      { kind = "select", label = L["Set view to saved view:"],
        tooltip = L["Select the saved view to switch to when entering this situation."],
        situationPath = {"viewZoom", "viewNumber"},
        options = {
          {value = 2, text = "View 2"}, {value = 3, text = "View 3"},
          {value = 4, text = "View 4"}, {value = 5, text = "View 5"},
        } },
      { kind = "checkbox", label = L["Instant"],
        tooltip = L["Make view transitions instant."],
        situationPath = {"viewZoom", "viewInstant"} },
      { kind = "checkbox", label = L["Restore view when exiting"],
        tooltip = L["When exiting the situation restore the camera position to what it was at the time of entering the situation."],
        situationPath = {"viewZoom", "viewRestore"},
        shownWhen = CameraFollowingOff },
      -- With camera following on, a saved view cannot be restored - so say why,
      -- then offer the default view to return to instead.
      { kind = "note", text = L["cameraSmoothNote"],
        shownWhen = CameraFollowingOn },
      { kind = "select", label = L["Restore to default view:"],
        tooltip = L["<viewRestoreToDefault_desc>"],
        situationPath = {"viewZoom", "restoreDefaultViewNumber"},
        shownWhen = CameraFollowingOn,
        options = {
          {value = 1, text = "View 1"}, {value = 2, text = "View 2"},
          {value = 3, text = "View 3"}, {value = 4, text = "View 4"},
          {value = 5, text = "View 5"},
        } },
      -- Only while there actually is a clash, and it names which situations are
      -- on both sides of it, so it can be acted on rather than just worried about.
      { kind = "note",
        shownWhen = function()
          if not CameraFollowingOn() then return false end
          local conflicts = ConflictingViews()
          return #conflicts > 0
        end,
        text = function()
          local conflicts, usedViews, usedDefaultViews = ConflictingViews()
          local parts = {"|cFFEE0000" .. L["WARNING"] .. ":|r" ..
            L["You are using the same view as saved view and as restore-to-default view. Using a view as restore-to-default view will reset it. Only do this if you really want to use it as a non-customized saved view."]}
          for _, view in ipairs(conflicts) do
            parts[#parts + 1] = L["View %s is used as saved view in the situations:\n%sand as restore-to-default view in the situations:\n%s"]
              :format(view, SituationNameList(usedViews[view]), SituationNameList(usedDefaultViews[view]))
          end
          return table.concat(parts, "\n\n")
        end },
    },
  },

  {
    name = L["Set Zoom"],
    enabledWhen = ZoomOn,
    info = L["<zoom_desc>"],
    items = {
      { kind = "checkbox", label = L["Enable"],
        tooltip = L["<setZoomEnable_desc>"],
        ignoreCategoryGate = true, get = ZoomOn, set = SetViewZoomMode("zoom") },
      { kind = "select", label = L["Zoom Type"],
        tooltip = L["<zoomType_desc>"],
        situationPath = {"viewZoom", "zoomType"},
        options = {
          {value = "set",   text = L["Set"]},
          {value = "out",   text = L["Out"]},
          {value = "in",    text = L["In"]},
          {value = "range", text = L["Range"]},
        } },
      { kind = "slider", label = L["Zoom Value"],
        -- Reads differently per zoom type, as in the old UI.
        tooltip = function(sid)
          local zoomType = CurrentZoomType(sid)
          if zoomType == "out" then
            return L["Zoom out to this zoom level, if the current zoom level is less than this."]
          elseif zoomType == "in" then
            return L["Zoom in to this zoom level, if the current zoom level is greater than this."]
          end
          return L["Zoom to this zoom level."]
        end,
        situationPath = {"viewZoom", "zoomValue"},
        min = 0, max = DynamicCam.cameraDistanceMaxZoomFactor_max, step = 0.5,
        shownWhen = ZoomTypeIsNot("range") },
      { kind = "slider", label = L["Zoom Min"],
        tooltip = L["Zoom out to this zoom level, if the current zoom level is less than this."],
        situationPath = {"viewZoom", "zoomMin"},
        min = 0, max = DynamicCam.cameraDistanceMaxZoomFactor_max, step = 0.5,
        shownWhen = ZoomTypeIs("range") },
      { kind = "slider", label = L["Zoom Max"],
        tooltip = L["Zoom in to this zoom level, if the current zoom level is greater than this."],
        situationPath = {"viewZoom", "zoomMax"},
        min = 0, max = DynamicCam.cameraDistanceMaxZoomFactor_max, step = 0.5,
        shownWhen = ZoomTypeIs("range") },
      { kind = "checkbox", label = L["Don't slow"],
        tooltip = L["Zoom transitions may be executed faster (but never slower) than the specified time above, if the \"Camera Zoom Speed\" (see \"Mouse Zoom\" settings) allows."],
        situationPath = {"viewZoom", "zoomTimeIsMax"} },
    },
  },

  {
    name = L["Rotation"],
    enabledWhen = RotationOn,
    info = L["<rotationCategory_desc>"],
    items = {
      { kind = "checkbox", label = L["Enable"],
        tooltip = L["Start a camera rotation when this situation is active."],
        ignoreCategoryGate = true,
        situationPath = {"rotation", "enabled"}, apply = ApplyRotation },
      { kind = "select", label = L["Rotation Type"],
        tooltip = L["<rotationType_desc>"],
        situationPath = {"rotation", "rotationType"},
        apply = ApplyRotation,
        options = {
          {value = "continuous", text = L["Continuously"]},
          {value = "degrees",    text = L["By Degrees"]},
        } },
      { kind = "slider", label = L["Rotation Speed"],
        tooltip = L["Speed at which to rotate in degrees per second. You can manually enter values between -900 and 900, if you want to get yourself really dizzy..."],
        situationPath = {"rotation", "rotationSpeed"},
        min = -90, max = 90, step = 1,
        shownWhen = RotationTypeIs("continuous"),
        apply = ApplyRotation },
      { kind = "slider", label = L["Yaw (-Left/Right+)"],
        tooltip = L["Degrees to yaw (left or right)."],
        situationPath = {"rotation", "yawDegrees"},
        min = -360, max = 360, step = 5,
        shownWhen = RotationTypeIs("degrees") },
      { kind = "slider", label = L["Pitch (-Down/Up+)"],
        tooltip = L["Degrees to pitch (up or down). There is no going beyond the perpendicular upwards or downwards view."],
        situationPath = {"rotation", "pitchDegrees"},
        min = -180, max = 180, step = 5,
        shownWhen = RotationTypeIs("degrees") },
      { kind = "checkbox", label = L["Rotate Back"],
        tooltip = L["<rotateBack_desc>"],
        situationPath = {"rotation", "rotateBack"},
        shownWhen = RotationTypeIs("degrees") },
    },
  },

  {
    name = L["Fade Out UI"],
    enabledWhen = HideUIOn,
    info = L["<hideUICategory_desc>"],
    items = {
      { kind = "checkbox", label = L["Enable"],
        tooltip = L["Fade out or hide (parts of) the UI when this situation is active."],
        ignoreCategoryGate = true,
        situationPath = {"hideUI", "enabled"}, apply = ApplyFade },
      { kind = "checkbox", label = L["Hide entire UI"],
        tooltip = L["<hideEntireUI_desc>"],
        situationPath = {"hideUI", "hideEntireUI"},
        apply = ApplyFade },
      { kind = "slider", label = L["Fade Opacity"],
        tooltip = L["Fade the UI to this opacity when entering the situation."],
        situationPath = {"hideUI", "fadeOpacity"},
        min = 0, max = 1, step = 0.01,
        enabledWhen = FadeOpacityApplies, apply = ApplyFade },
      { kind = "checkbox", label = L["Keep FPS indicator"],
        tooltip = L["Do not fade out or hide the FPS indicator (the one you typically toggle with Ctrl + R)."],
        situationPath = {"hideUI", "keepFrameRate"},
        apply = ApplyFade },

      { kind = "checkbox", label = L["Keep Alerts"],
        tooltip = L["Still show alert popups from completed achievements, Covenant Renown, etc."],
        situationPath = {"hideUI", "keepAlertFrames"},
        apply = ApplyFade },
      { kind = "checkbox", label = L["Keep Tooltip"],
        tooltip = L["Still show the game tooltip, which appears when you hover your mouse cursor over UI or world elements."],
        situationPath = {"hideUI", "keepTooltip"},
        apply = ApplyFade },
      { kind = "checkbox", label = L["Keep Minimap"],
        tooltip = L["<keepMinimap_desc>"],
        situationPath = {"hideUI", "keepMinimap"},
        apply = ApplyFade },
      { kind = "checkbox", label = L["Keep Chat Box"],
        tooltip = L["Do not fade out the chat box."],
        situationPath = {"hideUI", "keepChatFrame"},
        apply = ApplyFade },
      { kind = "checkbox", label = L["Keep Tracking Bar"],
        tooltip = L["Do not fade out the tracking bar (XP, AP, reputation)."],
        situationPath = {"hideUI", "keepTrackingBar"},
        apply = ApplyFade },
      { kind = "checkbox", label = L["Keep Party/Raid"],
        tooltip = L["Do not fade out the Party/Raid frame."],
        situationPath = {"hideUI", "keepPartyRaidFrame"},
        apply = ApplyFade },
      { kind = "checkbox", label = L["Keep Encounter Frame (Skyriding Vigor)"],
        tooltip = L["Do not fade out the Encounter Frame, which while skyriding is the Vigor display."],
        situationPath = {"hideUI", "keepEncounterBar"},
        apply = ApplyFade },

      { kind = "checkbox", label = L["Keep additional frames"],
        tooltip = L["<keepCustomFrames_desc>"],
        situationPath = {"hideUI", "keepCustomFrames"},
        apply = ApplyFade },
      { kind = "input", label = L["Custom frames to keep"],
        tooltip = L["Separated by commas."],
        enabledWhen = KeepCustomFramesOn,
        get = GetCustomFrames, set = SetCustomFrames },

      { kind = "checkbox", label = L["Pressing Esc fades the UI back in."],
        tooltip = L["<emergencyShow_desc>"],
        situationPath = {"hideUI", "emergencyShowEscEnabled"} },
      -- The one genuinely global value on this page: it is about this settings
      -- window, not about any situation, so it is addressed on the profile - and
      -- it stays usable whether or not THIS situation fades the UI.
      --
      -- TODO: has no effect yet. SettingsPanelSetIgnoreParentAlpha only knows
      -- about the OLD UI's frames (the Blizzard Settings panel, the AceGUI
      -- dropdowns, the detached window) - not this window. Left until the old UI
      -- is retired, so the exemption can be written once for whatever frames
      -- remain, rather than twice for two UIs that fade differently.
      { kind = "checkbox", label = L["Do not fade out this \"Interface\" settings frame."],
        tooltip = L["<hideUIHelp_desc>"],
        ignoreCategoryGate = true,
        get = function() return DynamicCam.db.profile.settingsPanelIgnoreParentAlpha end,
        set = function(value)
          DynamicCam.db.profile.settingsPanelIgnoreParentAlpha = value
          DynamicCam:SettingsPanelSetIgnoreParentAlpha(value)
        end },
    },
  },

}
