local LibCamera = LibStub("LibCamera-1.0")
local LibEasing = LibStub("LibEasing-1.0")






-- The transition time of SetView() is hard to predict.
-- Use this for now.
local SET_VIEW_TRANSITION_TIME = 0.5




------------
-- LOCALS --
------------

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end









local functionCache = {}
local situationEnvironments = {}
function DynamicCam:RunScript(situationID, scriptID)

  local script = DynamicCam.db.profile.situations[situationID][scriptID]

  if not script or script == "" then return end

  -- make sure that we're not creating tables willy nilly
  if not functionCache[situationID] then
    functionCache[situationID] = {}
  end


  if not functionCache[situationID][scriptID] or functionCache[situationID][scriptID] ~= script then

    local f, msg = loadstring(script)
    if not f then
      DynamicCam:ScriptError(situationID, scriptID, "syntax", msg)
      return nil
    else
      functionCache[situationID][scriptID] = f
    end

    -- if env, set the environment to that
    if situationID then
      if not situationEnvironments[situationID] then
        situationEnvironments[situationID] = setmetatable({}, { __index =
          function(t, k)
            if k == "_G" then
              return t
            elseif k == "this" then
              return situationEnvironments[situationID].this
            else
              return _G[k]
            end
          end
        })
        situationEnvironments[situationID].this = {}
      end

      setfenv(functionCache[situationID][scriptID], situationEnvironments[situationID])
    end
  end


  local result = {pcall(functionCache[situationID][scriptID])}

  if result[1] == false then
    DynamicCam:ScriptError(situationID, scriptID, "runtime", result[2])
    return nil
  else
    tremove(result, 1)
    -- print(DynamicCam.db.profile.situations[situationID].name, unpack(result))
    return unpack(result)
  end

end








-- For EvaluateSituations() below.
-- So the transition has to wait a little.
local moreQuestDialog = false
local unsetMoreQuestDialogTimer = nil
local waitForQuestFrameToReopen = 0.3


-- GetNumActiveQuests() does not exist in classic.
if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then

  -- When an NPC has more than one quest, after accepting/returning the first quest,
  -- the QuestFrame disappears for a short time, which momentarily exits
  -- the NPC interaction situation (not looking nice).
  -- Unfortunately, when exiting the situation, there is no direct way to determine if
  -- the NPC still has quests or if a quest was just accepted.
  -- The QUEST_ACCEPTED event comes a few frames after the PLAYER_INTERACTION_MANAGER_FRAME_HIDE
  -- and QUEST_FINISHED events which are also the only indicators of the quest frame closing
  -- without accepting a quest.
  -- That's why we have to do some tricks to know that the NPC still has quests when exiting
  -- the situation, so we can enforce an extra delay of 0.3 seconds (should be enough).
  local questFrameClosed = true
  local lastQuestFrameCloseTime = GetTime()

  local moreQuestDialogFrame = CreateFrame("Frame")
  moreQuestDialogFrame:RegisterEvent("QUEST_GREETING")
  moreQuestDialogFrame:RegisterEvent("GOSSIP_SHOW")
  moreQuestDialogFrame:RegisterEvent("QUEST_DETAIL")
  moreQuestDialogFrame:RegisterEvent("QUEST_ACCEPTED")
  moreQuestDialogFrame:RegisterEvent("QUEST_REMOVED")  -- For finishing quests.
  moreQuestDialogFrame:RegisterEvent("QUEST_COMPLETE") -- To check if a quest about to be finished in is part of a quest line.
  moreQuestDialogFrame:SetScript("OnEvent", function(_, event)

    if event == "QUEST_GREETING" or event == "GOSSIP_SHOW" then

      -- print(event, "available quests", C_GossipInfo.GetNumAvailableQuests(), GetNumAvailableQuests())
      -- print(event, "active quests", C_GossipInfo.GetNumActiveQuests(), GetNumActiveQuests())
      -- Find out if the active quests can actually be turned in. Because only then do we want to count them.
      -- We need C_GossipInfo.GetNumAvailableQuests and GetNumAvailableQuests, because
      -- apparently one is for normal quests and the other for campaign quests.
      local completeQuests = 0
      if C_GossipInfo.GetNumActiveQuests() > 0 then
        for _, v in pairs(C_GossipInfo.GetActiveQuests()) do
          -- print(v.title, v.isComplete)
          if v.isComplete then
            completeQuests = completeQuests + 1
          end
        end
      elseif GetNumActiveQuests() > 0 then
        for i=1, GetNumActiveQuests() do
          local title, isComplete = GetActiveTitle(i)
          -- print(title, isComplete)
          if isComplete then
            completeQuests = completeQuests + 1
          end
        end
      end

      -- print(event, "(probably) complete quests", completeQuests)


      if (C_GossipInfo.GetNumAvailableQuests() + completeQuests > 1) or (GetNumAvailableQuests() + completeQuests > 1) then
        -- print(GetTime(), event, "setting moreQuestDialog to TRUE.")
        DynamicCam:CancelTimer(unsetMoreQuestDialogTimer)
        moreQuestDialog = true
        questFrameClosed = false
      end


    -- When the quest detail view is shown, we reset moreQuestDialog,
    -- unless we have set moreQuestDialog before without the quest
    -- frame being closed.
    elseif event == "QUEST_DETAIL" then
      if questFrameClosed then
        -- print(GetTime(), event, "setting moreQuestDialog to FALSE.")
        moreQuestDialog = false
      end

    -- Sometimes QUEST_ACCEPTED comes after the quest frame has been reopened. Therefore we check GetNumAvailableQuests too.
    elseif (event == "QUEST_ACCEPTED" or event == "QUEST_REMOVED") and C_GossipInfo.GetNumAvailableQuests() == 0 and GetNumAvailableQuests() == 0 then
      -- print(GetTime(), event, "setting moreQuestDialog to FALSE.")
      moreQuestDialog = false
      questFrameClosed = true




    -- -- TODO: Use grail to determine if NPC has a follow-up quest.
    -- elseif event == "QUEST_COMPLETE" then
      -- print(event, "About to turn in a quest.")


      -- questID = GetQuestID()

      -- print(GetTitleText(), questID)

      -- local questLineInfo = C_QuestLine.GetQuestLineInfo(questID, C_Map.GetBestMapForUnit("player"))

      -- DynamicCam:PrintTable(questLineInfo, 0)

      -- local questLineID = questLineInfo.questLineID



      -- print(questLineID)


      -- local questIDs = C_QuestLine.GetQuestLineQuests(questLineID)

      -- for k, v in pairs(questIDs) do

        -- print("----------------------", v)

        -- local questLineInfo = C_QuestLine.GetQuestLineInfo(v, C_Map.GetBestMapForUnit("player"))

        -- if questLineInfo then
          -- DynamicCam:PrintTable(questLineInfo, 0)
        -- end

        -- print("----------------------")

      -- end


      -- DynamicCam:PrintTable(questIDs, 0)

      -- print("ha", C_QuestLog.GetNextWaypoint(questID))


    end

  end)


  -- Cannot use PLAYER_INTERACTION_MANAGER_FRAME_HIDE or QUEST_FINISHED to update
  -- questFrameClosed, because this gets called at every QuestFrame transition.
  -- We therefore check if the QuestFrame was really closed.
  QuestFrame:HookScript("OnHide", function()
    -- print("QuestFrame closed", GetTime())
    questFrameClosed = true
    lastQuestFrameCloseTime = GetTime()
  end)
  -- When switching to the quest detail view the QuestFrame gets closed and reopened within one frame.
  QuestFrame:HookScript("OnShow", function()
    -- print("QuestFrame shown", GetTime())
    if lastQuestFrameCloseTime == GetTime() then
      questFrameClosed = false
    end
  end)

  if ImmersionFrame then
    ImmersionFrame:HookScript("OnHide", function()
      -- print("ImmersionFrame closed", GetTime())
      questFrameClosed = true
    end)
  end

end







-- Start rotating when entering a situation.
local function StartRotation(newSituation, transitionTime)
  local r = newSituation.rotation
  local profile = DynamicCam.db.profile

  if r.enabled then
    if r.rotationType == "continuous" then

      LibCamera:BeginContinuousYaw(r.rotationSpeed, transitionTime)

    elseif r.rotationType == "degrees" then

      if r.yawDegrees ~= 0 then
        LibCamera:Yaw(r.yawDegrees, transitionTime, LibEasing[profile.easingYaw])
      end
      if r.pitchDegrees ~= 0 then
        LibCamera:Pitch(r.pitchDegrees, transitionTime, LibEasing[profile.easingPitch])
      end

    end
  end
end


-- Stop rotating when leaving a situation.
local function StopRotation(oldSituation)
  local r = oldSituation.rotation
  local profile = DynamicCam.db.profile
  if r.enabled then
    if r.rotationType == "continuous" then
      local yaw = LibCamera:StopYawing()

      -- rotate back if we want to
      if r.rotateBack then
        -- print("Ended rotate, degrees rotated, yaw:", yaw)
        if yaw then
          local yawBack = yaw % 360

          -- we're beyond 180 degrees, go the other way
          if yawBack > 180 then
            yawBack = yawBack - 360
          end

          LibCamera:Yaw(-yawBack, r.rotateBackTime, LibEasing[profile.easingYaw])
        end
      end
    elseif r.rotationType == "degrees" then
      if LibCamera:IsRotating() then
        -- interrupted rotation
        local yaw, pitch = LibCamera:StopRotating()

        -- rotate back if we want to
        if r.rotateBack then
          -- print("Ended rotate early, degrees rotated, yaw:", yaw, "pitch:", pitch)
          if yaw then
            LibCamera:Yaw(-yaw, r.rotateBackTime, LibEasing[profile.easingYaw])
          end

          if pitch then
            LibCamera:Pitch(-pitch, r.rotateBackTime, LibEasing[profile.easingPitch])
          end
        end
      else
        if r.rotateBack then
          if r.yawDegrees ~= 0 then
            LibCamera:Yaw(-r.yawDegrees, r.rotateBackTime, LibEasing[profile.easingYaw])
          end

          if r.pitchDegrees ~= 0 then
            LibCamera:Pitch(-r.pitchDegrees, r.rotateBackTime, LibEasing[profile.easingPitch])
          end
        end
      end
    end
  end
end




-- To store the last zoom when leaving a situation.
local lastZoom = {}

-- To store the previous situation when entering another situation.
local lastSituation = {}
-- Depending on the "Restore Zoom" setting, a user may want to always restore
-- the last zoom when returning to a previous situation. Only for the "adaptive"
-- setting (which is actually the original way DynamicCam did it) we also have
-- to remember the last situation, because we only restore the zoom when returning
-- to the same situation we came from.



-- Used by ChangeSituation() to determine if a stored zoom should
-- be restored when returning to a situation.
local function ShouldRestoreZoom(oldSituationID, newSituationID)

  -- print("Should Restore Zoom")

  if DynamicCam.db.profile.zoomRestoreSetting == "never" then
    -- print("Setting is never.")
    return false
  end


  -- Restore if we're just exiting a situation, and have a stored value for default.
  -- (This is the case for both "always" and "adaptive".)
  if not newSituationID then
    if lastZoom["no-situation"] then
      -- print("Restoring saved zoom for no-situation.", lastZoom["no-situation"])
      return true, lastZoom["no-situation"]
    else
      -- print("Not restoring zoom because returning to no-situation with no saved value.")
      return false
    end
  end


  -- Don't restore if we don't have a saved zoom value.
  -- (Also the case for both "always" and "adaptive".)
  if not lastZoom[newSituationID] then
    -- print("Not restoring zoom because we have no saved value for this situation.")
    return false
  end

  -- From now on we know that we are entering a new situation and have a stored zoom.

  local newSituation = DynamicCam.db.profile.situations[newSituationID]
  -- Don't restore zoom if we're about to go into a view.
  if newSituation.viewZoom.enabled and newSituation.viewZoom.viewZoomType == "view" then
    -- print("Not restoring zoom because entering a view.")
    return false
  end


  local restoreZoom = lastZoom[newSituationID]
  if DynamicCam.db.profile.zoomRestoreSetting == "always" then
    -- print("Setting is always.")
    return true, restoreZoom
  end


  -- The following are for the zoomRestoreSetting == "adaptive" setting.
  -- print("Setting is adaptive.")

  -- Only restore zoom if returning to the same situation
  if oldSituationID and lastSituation[oldSituationID] ~= newSituationID then
    -- print("Not restoring zoom because this is not the situation we came from.")
    return false
  end


  local c = newSituation.viewZoom
  -- Restore zoom based on newSituation viewZoomType.
  if not c.enabled or c.viewZoomType ~= "zoom" then
    -- print("Not restoring zoom because new situation has no zoom setting.")
    return false
  end

  if c.zoomType == "set" then
    -- print("Not restoring zoom because new situation has a fixed zoom setting.")
    return false
  end

  if c.zoomType == "range" then
    -- only restore zoom if zoom will be in the range
    if c.zoomMin <= restoreZoom + .5 and
       c.zoomMax >= restoreZoom - .5 then
      return true, restoreZoom
    else
      return false
    end
  end

  if c.zoomType == "in" then
    -- Only restore if the stored zoom level is smaller or equal to the situation value
    -- and do not zoom out.
    if c.zoomValue >= restoreZoom - .5 and GetCameraZoom() > restoreZoom then
      return true, restoreZoom
    else
      -- print("Not restoring because saved value", restoreZoom, "is not smaller than zoom IN of situation.")
      return false
    end
  elseif c.zoomType == "out" then
    -- restore zoom if newSituation is zooming out and we would already be zooming out farther
    if c.zoomValue <= restoreZoom + .5 and GetCameraZoom() < restoreZoom then
      return true, restoreZoom
    else
      -- print("Not restoring because saved value", restoreZoom, "is not greater than zoom OUT of situation.")
      return false
    end
  end

  -- if nothing else, don't restore
  return false
end






local function gotoView(view, instant)
  -- print("gotoView", view, instant)

  if not view then return end

  -- View change overrides all zooming and rotating.
  LibCamera:StopZooming()
  LibCamera:StopRotating()

  -- Whenever the zoom changes we need to reset the reactiveZoomTarget.
  DynamicCam:ResetReactiveZoomTarget()


  local cameraZoomBefore = GetCameraZoom()

  -- if you call SetView twice, then it's instant
  if instant then
    SetView(view)
  end
  SetView(view)

  local cameraZoomAfter = GetCameraZoom()
  -- print("Going from", cameraZoomBefore, "to", cameraZoomAfter)

  -- If "Adjust Shoulder offset according to zoom level" is activated,
  -- the shoulder offset will be instantaneously set according to the new
  -- camera zoom level. However, we should instead ease it for SET_VIEW_TRANSITION_TIME.
  if DynamicCam:GetSettingsValue(DynamicCam.currentSituationID, "shoulderOffsetZoomEnabled") and not shoulderOffsetZoomTmpDisable then
    DynamicCam.easeShoulderOffsetInProgress = true
    DynamicCam.virtualCameraZoom = cameraZoomBefore

    LibEasing:Ease(
      function(newValue)
        DynamicCam.virtualCameraZoom = newValue
      end,
      cameraZoomBefore,
      cameraZoomAfter,
      SET_VIEW_TRANSITION_TIME,
      LibEasing.Linear,
      function()
        DynamicCam.easeShoulderOffsetInProgress = false
        DynamicCam.virtualCameraZoom = nil
      end
    )
  end
end







function DynamicCam:ChangeSituation(oldSituationID, newSituationID)

  -- print("ChangeSituation", oldSituationID, newSituationID, GetTime())

  LibCamera:StopZooming()


  -- When we are restoring or setting a view, we shall not apply any zoom.
  -- The variable "viewInstant" will define the transition speed below.
  local settingView = false
  local viewInstant

  -- Needed so often that we are setting these shortcuts for the whole function scope.
  local oldSituation
  local newSituation

  if oldSituationID then
    -- Store last zoom level of this situation.
    lastZoom[oldSituationID] = GetCameraZoom()
    -- print("---> Storing zoom", lastZoom[oldSituationID], oldSituationID)

    -- Shortcut variable.
    oldSituation = self.db.profile.situations[oldSituationID]
  end

  if newSituationID then
    -- Store the old situation as the new situation's last situation.
    -- May also be nil in case of coming from the no-situation state.
    -- (Needed for "adaptive restore", where we only restore when
    -- returning to the same situation we came from.)
    lastSituation[newSituationID] = oldSituationID

    -- Shortcut variable.
    newSituation = self.db.profile.situations[newSituationID]
  end


  -- If we are exiting another situation.
  if oldSituation then

    -- Stop rotating if applicable.
    StopRotation(oldSituation)

    -- Restore view if the new situation does not have a view itself.
    -- (Setting a new view has a higher priority than reseting an old one.)
    local old = oldSituation.viewZoom
    if old.enabled and old.viewZoomType == "view" and (not newSituation or not (newSituation.viewZoom.enabled and newSituation.viewZoom.viewZoomType == "view")) then

      if GetCVar("cameraSmoothStyle") == "0" then
        if old.viewRestore then
          gotoView(1, old.viewInstant)
          settingView = true
          viewInstant = old.viewInstant
        end

      -- Special treatment if camera follow is activated.
      else
        if old.restoreDefaultViewNumber then
          ResetView(old.restoreDefaultViewNumber)
          gotoView(old.restoreDefaultViewNumber, old.viewInstant)
          settingView = true
          viewInstant = old.viewInstant
        end
      end

    end

    -- Load and run advanced script onExit.
    self:RunScript(oldSituationID, "executeOnExit")

    -- Unhide UI if applicable.
    if oldSituation.hideUI.enabled then
      self:FadeInUI(oldSituation.hideUI.fadeInTime)
    end

    self:SendMessage("DC_SITUATION_EXITED")


  -- If we are coming from the no-situation state.
  elseif enteredSituationAtLogin then
    lastZoom["no-situation"] = GetCameraZoom()
    -- print("---> Storing default zoom", lastZoom[oldSituationID], oldSituationID)
  end


  -- If we are entering a new situation.
  if newSituation then

    -- Set view settings
    local new = newSituation.viewZoom
    if new.enabled and new.viewZoomType == "view" then
      if new.viewRestore then SaveView(1) end
      gotoView(new.viewNumber, new.viewInstant)
      settingView = true
      viewInstant = new.viewInstant
    end

    -- Load and run advanced script onEnter.
    self:RunScript(newSituationID, "executeOnEnter")

    -- Hide UI if applicable.
    if newSituation.hideUI.enabled then
      self:FadeOutUI(newSituation.hideUI.fadeOutTime, newSituation.hideUI)
    -- If we are currently exiting a situation, we have already called
    -- FadeInUI() above. Only if we are neither entering nor exiting a situation
    -- with UI fade, we show the UI, to be on the safe side.
    elseif not oldSituation or not oldSituation.hideUI.enabled then
      self:FadeInUI(0)
    end


  -- If we are entering the no-situation state.
  -- else
    -- print("Not entering a new situation")

  end



  -- These values are needed for the actual transition.
  local newZoomLevel
  local newShoulderOffset
  local transitionTime


  -- ##### Determine newZoomLevel. #####
  newZoomLevel = GetCameraZoom()

  -- We only need to determine newZoomLevel if we are zooming.
  if not settingView then

    -- Check if we should restore a stored zoom level.
    local shouldRestore, zoomLevel = ShouldRestoreZoom(oldSituationID, newSituationID)
    if shouldRestore then

      newZoomLevel = zoomLevel

    -- Otherwise take the zoom level of the situation we are entering.
    -- (There is no default zoom level for the no-situation case!)
    elseif newSituationID then

      local c = newSituation.viewZoom
      if c.enabled and c.viewZoomType == "zoom" then

        if (c.zoomType == "set") or
           (c.zoomType == "in"  and newZoomLevel > c.zoomValue) or
           (c.zoomType == "out" and newZoomLevel < c.zoomValue) then

            newZoomLevel = c.zoomValue

        elseif c.zoomType == "range" then

          if newZoomLevel < c.zoomMin then
            newZoomLevel = c.zoomMin
          elseif newZoomLevel > c.zoomMax then
            newZoomLevel = c.zoomMax
          end

        end

      end
    end
  end

  -- ##### Determine newShoulderOffset. #####
  if newSituation and newSituation.situationSettings.cvars.test_cameraOverShoulder then
    newShoulderOffset = newSituation.situationSettings.cvars.test_cameraOverShoulder
  else
    newShoulderOffset = self.db.profile.standardSettings.cvars.test_cameraOverShoulder
  end



  -- ##### Determine transitionTime. #####

  -- After reloading the UI we want to enter the current situation immediately!
  if not enteredSituationAtLogin then
    transitionTime = 0

  -- If there is a transitionTime in the environment, it has maximum priority.
  elseif newSituationID and situationEnvironments[newSituationID].this.transitionTime then
    transitionTime = situationEnvironments[newSituationID].this.transitionTime

  -- When restoring or setting a view, there is no additional zoom.
  -- The shoulder offset transition should be as fast at the view change.
  -- SET_VIEW_TRANSITION_TIME = 0.5 seems to be good for non-instant gotoView.
  elseif settingView then
    -- If settingView is true, we know there must be a newSituationID.
    if viewInstant then
      transitionTime = 0
    else
      transitionTime = SET_VIEW_TRANSITION_TIME
    end

  -- Otherwise the new situation's transition time is taken.
  elseif newSituation and newSituation.viewZoom.enabled and newSituation.viewZoom.viewZoomType == "zoom" then
    transitionTime = newSituation.viewZoom.zoomTransitionTime

    -- If the "Don't slow" option is selected, we have to check
    -- if actually a faster transition time is possible.
    if transitionTime > 0 and newSituation.viewZoom.zoomTimeIsMax then

      local difference = math.abs(newZoomLevel - GetCameraZoom())
      local linearSpeed = difference / transitionTime
      local currentSpeed = self:GetSettingsValue(newSituationID, "cvars", "cameraZoomSpeed")
      if linearSpeed < currentSpeed then
        -- min time 10 frames
        transitionTime = math.max(DynamicCam.secondsPerFrame*10, difference / currentSpeed)
      end
    end

  -- Default is this "magic number"...
  else
    transitionTime = 0.75
  end

  -- print("transitionTime", transitionTime)


  -- Start the actual easing.

  local easeFunction = LibEasing[self.db.profile.easingZoom]
  if settingView then
    easeFunction = LibEasing.Linear
  else
    -- We only need to zoom when not going into a view.
    -- Whenever the zoom changes we need to reset the reactiveZoomTarget.
    DynamicCam:ResetReactiveZoomTarget()
    LibCamera:SetZoom(newZoomLevel, transitionTime, easeFunction)
  end

  self:EaseShoulderOffset(newShoulderOffset, transitionTime, easeFunction)


  -- Set default values (possibly for new situation, may be nil).
  self.currentSituationID = newSituationID
  self:ApplySettings(true)

  -- Set situation specific values.
  -- (Except shoulder offset, which we are easing above.)
  if newSituation then

    -- If there is a rotationTime in the environment, it has priority.
    local rotationTime = situationEnvironments[newSituationID].this.rotationTime or newSituation.rotation.rotationTime

    -- Start rotating if applicable.
    StartRotation(newSituation, rotationTime)

    for cvar, value in pairs(newSituation.situationSettings.cvars) do
      if cvar ~= "test_cameraOverShoulder" then
        self:DC_SetCVar(cvar, value)
      end
    end

    self:SendMessage("DC_SITUATION_ENTERED")
  end

end




local delayTime

function DynamicCam:EvaluateSituations()

  -- print("EvaluateSituations", enteredSituationAtLogin, moreQuestDialog, GetTime())


  local highestPriority = -100
  local topSituation

  -- go through all situations pick the best one
  for id, situation in pairs(self.db.profile.situations) do

    if situation.enabled and not situation.errorEncountered then
      -- evaluate the condition, if it checks out and the priority is larger than any other, set it
      local lastEvaluate = self.conditionExecutionCache[id]
      local thisEvaluate = self:RunScript(id, "condition")
      self.conditionExecutionCache[id] = thisEvaluate

      if thisEvaluate then
        -- the condition is true
        if not lastEvaluate then
          -- last evaluate wasn't true, so this we "flipped"
          self:SendMessage("DC_SITUATION_ACTIVE", id)
        end

        -- check to see if we've already found something with higher priority
        if situation.priority > highestPriority then
          highestPriority = situation.priority
          topSituation = id
        end
      else
        -- the condition is false
        if lastEvaluate then
          -- last evaluate was true, so we "flipped"
          self:SendMessage("DC_SITUATION_INACTIVE", id)
        end
      end
    end
  end

  local swap = true
  if self.currentSituationID and (not topSituation or topSituation ~= self.currentSituationID) then
    -- we're in a situation that isn't the topSituation or there is no topSituation

    local delay = self.db.profile.situations[self.currentSituationID].delay
    if self.currentSituationID == "300" and moreQuestDialog and delay < waitForQuestFrameToReopen then
      -- print("got to wait for moreQuestDialog")
      self:CancelTimer(unsetMoreQuestDialogTimer)
      unsetMoreQuestDialogTimer = self:ScheduleTimer(function() moreQuestDialog = false end, waitForQuestFrameToReopen)
      delay = waitForQuestFrameToReopen
    end

    if delay > 0 then
      if not delayTime then
        -- not yet cooling down, make sure to guarentee an evaluate, don't swap
        -- print(delayTime, GetTime(), "Not changing situation because of a delay")
        delayTime = GetTime() + delay
        self:ScheduleTimer("EvaluateSituations", delay)
        swap = false
      -- Need to round, otherwise same times are sometimes not recognised as such.
      elseif round(delayTime, 3) > round(GetTime(), 3) then
        -- print(delayTime, GetTime(), "still cooling down, don't swap")
        swap = false
      end
    end
  end

  if swap then
    if topSituation then
      if topSituation ~= self.currentSituationID then
        -- we want to swap and there is a situation to swap into, and it's not the current situation
        self:ChangeSituation(self.currentSituationID, topSituation)
      end

      -- if we had a delay previously, make sure to reset it
      delayTime = nil
    else
      --none of the situations are active, leave the current situation
      if self.currentSituationID then
        self:ChangeSituation(self.currentSituationID, nil)
      end
    end
  end


  enteredSituationAtLogin = true

  -- print("Finished EvaluateSituations", enteredSituationAtLogin, GetTime())
end





-- Storing which mounts are flying mounts, because the game does not provide a direct reliable way to determine this.
-- See: https://www.wowinterface.com/forums/showthread.php?p=344234#post344234
DynamicCam.FlyingMountList = {}

local maintainFlyingMountListFrame = CreateFrame ("Frame")
maintainFlyingMountListFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
maintainFlyingMountListFrame:SetScript("OnEvent",
  function()

    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then return end

    -- Store current mount journal filter settings for later restoring.

    local collectedFilters = {}
    collectedFilters[LE_MOUNT_JOURNAL_FILTER_COLLECTED] = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED)
    collectedFilters[LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED] = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED)
    collectedFilters[LE_MOUNT_JOURNAL_FILTER_UNUSABLE] = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE)
    -- DynamicCam:PrintTable(collectedFilters, 0)

    local typeFilters = {}
    for filterIndex = 1, Enum.MountTypeMeta.NumValues do
      typeFilters[filterIndex] = C_MountJournal.IsTypeChecked(filterIndex)
    end
    -- DynamicCam:PrintTable(typeFilters, 0)

    local sourceFilters = {}
		for filterIndex = 1, C_PetJournal.GetNumPetSources() do
			if C_MountJournal.IsValidSourceFilter(filterIndex) then
				sourceFilters[filterIndex] = C_MountJournal.IsSourceChecked(filterIndex)
			end
		end
    -- DynamicCam:PrintTable(sourceFilters, 0)


    -- Set filters to flying mounts.
    C_MountJournal.SetDefaultFilters()
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE, true)  -- Include unusable.
    C_MountJournal.SetTypeFilter(1, false)   -- No Ground.
    C_MountJournal.SetTypeFilter(3, false)   -- No Aquatic.


    -- Fill list of flying mount IDs.
    DynamicCam.FlyingMountList = {}
    for displayIndex = 1, C_MountJournal.GetNumDisplayedMounts() do
      local mountId = select(12, C_MountJournal.GetDisplayedMountInfo(displayIndex))
      -- print(displayIndex, mountId)
      DynamicCam.FlyingMountList[mountId] = true
    end


    -- Restore the mount journal filter settings.

    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, collectedFilters[LE_MOUNT_JOURNAL_FILTER_COLLECTED])
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, collectedFilters[LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED])
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE, collectedFilters[LE_MOUNT_JOURNAL_FILTER_UNUSABLE])

    for filterIndex = 1, Enum.MountTypeMeta.NumValues do
      C_MountJournal.SetTypeFilter(filterIndex, typeFilters[filterIndex])
    end

		for filterIndex = 1, C_PetJournal.GetNumPetSources() do
			if C_MountJournal.IsValidSourceFilter(filterIndex) then
				C_MountJournal.SetSourceFilter(filterIndex, sourceFilters[filterIndex])
			end
		end

  end
)




-- Some functions we need in several situation conditions.
-- So we only implement them once.

DynamicCam.lastActiveMount = nil

function DynamicCam:CurrentMountCanFly()

  local checkLastActiveMount = false
  if self.lastActiveMount then
    _, _, _, checkLastActiveMount = C_MountJournal.GetMountInfoByID(self.lastActiveMount)
  end

  local lastActiveMount = nil
  if checkLastActiveMount then
    lastActiveMount = self.lastActiveMount
  else
    for _, v in pairs (C_MountJournal.GetMountIDs()) do
      local _, _, _, isActive = C_MountJournal.GetMountInfoByID(v)
      if isActive then
        lastActiveMount = v
        break
      end
    end
  end

  if lastActiveMount then
    self.lastActiveMount = lastActiveMount

    if DynamicCam.FlyingMountList[self.lastActiveMount] then
      -- print("I believe mount", self.lastActiveMount, "can fly")
      return true
    else
      -- print("I believe mount", self.lastActiveMount, "cannot fly")
      return false
    end

  end

  return false
end


function DynamicCam:SkyridingOn()

  if self.lastActiveMount then
    local _, _, _, isActive, _, _, _, _, _, _, _, _, isSteadyFlight = C_MountJournal.GetMountInfoByID(self.lastActiveMount)
    if isActive and isSteadyFlight then
      return false
    end
  end

  for _, v in pairs (C_MountJournal.GetMountIDs()) do
    local _, _, _, isActive, _, _, _, _, _, _, _, _, isSteadyFlight = C_MountJournal.GetMountInfoByID(v)
    if isActive then
      self.lastActiveMount = v
      if isSteadyFlight then
        return false
      end
    end
  end

  for i = 1, 40 do
    local aura = C_UnitAuras.GetBuffDataByIndex("player", i)
    if aura and aura.spellId == 404464 then return true end
    if aura and aura.spellId == 404468 then return false end
  end

  -- If you have never switched, you have neither buff and Skyriding it the default.
  return true
end







function DynamicCam:CopySituationInto(fromID, toID)

  -- TODO

  -- -- make sure that both from and to are valid situationIDs
  -- if not fromID or not toID or fromID == toID or not self.db.profile.situations[fromID] or not self.db.profile.situations[toID] then
    -- -- print("CopySituationInto has invalid from or to!")
    -- return
  -- end

  -- local from = self.db.profile.situations[fromID]
  -- local to = self.db.profile.situations[toID]

  -- -- copy settings over
  -- to.enabled = from.enabled

  -- -- a more robust solution would be much better!
  -- to.cameraActions = {}
  -- for key, value in pairs(from.cameraActions) do
    -- to.cameraActions[key] = from.cameraActions[key]
  -- end

  -- to.view = {}
  -- for key, value in pairs(from.view) do
    -- to.view[key] = from.view[key]
  -- end

  -- to.extras = {}
  -- for key, value in pairs(from.extras) do
    -- to.extras[key] = from.extras[key]
  -- end

  -- to.situationSettings.cvars = {}
  -- for key, value in pairs(from.situationSettings.cvars) do
    -- to.situationSettings.cvars[key] = from.situationSettings.cvars[key]
  -- end

  -- self:UpdateSituation(toID)
end




function DynamicCam:UpdateSituation(situationID)
  local situation = DynamicCam.db.profile.situations[situationID]

  -- Give this situation a new chance!
  situation.errorEncountered = nil
  situation.errorMessage = nil

  if situation and situationID == DynamicCam.currentSituationID then
    DynamicCam:ApplySettings()
  end

  DynamicCam:RunScript(situationID, "executeOnInit")
  DynamicCam:RegisterSituationEvents(situationID)

  DynamicCam:EvaluateSituations()
end




local function copyTable(originalTable)
  local origType = type(originalTable)
  local copy
  if origType == 'table' then
    -- this child is a table, copy the table recursively
    copy = {}
    for orig_key, orig_value in next, originalTable, nil do
      copy[copyTable(orig_key)] = copyTable(orig_value)
    end
  else
    -- this child is a value, copy it cover
    copy = originalTable
  end
  return copy
end

function DynamicCam:CreateCustomSituation(name)
  -- search for a clear id
  local highest = 0

  -- go through each and every situation, look for the custom ones, and find the
  -- highest custom id
  for id, situation in pairs(self.db.profile.situations) do
    local i, j = string.find(id, "custom")

    if i and j then
      local num = tonumber(string.sub(id, j+1))

      if num and num > highest then
        highest = num
      end
    end
  end

  -- copy the default situation into a new table
  local newSituationID = "custom"..(highest+1)
  local newSituation = copyTable(self.situationDefaults)

  newSituation.name = name

  -- create the entry in the profile with an id 1 higher than the highest already customID
  self.db.profile.situations[newSituationID] = newSituation

  -- make sure that the options panel reselects a situation
  if self.Options then
    self.Options:SelectSituation(newSituationID)
  end

  self:UpdateSituation(newSituationID)
  return newSituation, newSituationID
end

function DynamicCam:DeleteCustomSituation(situationID)
  if not self.db.profile.situations[situationID] then
    -- print("Cannot delete this situation since it doesn't exist", situationID)
  end

  if not string.find(situationID, "custom") then
    -- print("Cannot delete a non-custom situation")
  end

  -- if we're currently in this situation, exit it
  if self.currentSituationID == situationID then
    self:ChangeSituation(situationID, nil)
  end

  -- delete the situation
  self.db.profile.situations[situationID] = nil

  -- make sure that the options panel reselects a situation
  if self.Options then
    self.Options:ClearSelection()
    self.Options:SelectSituation()
  end

  -- EvaluateSituations because we might have changed the current situation
  self:EvaluateSituations()
end


