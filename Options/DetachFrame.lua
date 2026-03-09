---------------
-- LIBRARIES --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)
local Options = DynamicCam.Options


-- Called at the end of Options:RegisterMenus() to add the detach button.
function Options:CreateDetachButton()
  local detachBtn = CreateFrame("Button", nil, self.menu)
  detachBtn:SetSize(24, 24)
  detachBtn:SetPoint("TOPRIGHT", self.menu, "TOPRIGHT", -10, -10)
  detachBtn:SetFrameLevel(self.menu:GetFrameLevel() + 10)
  detachBtn:SetNormalAtlas("RedButton-Expand")
  detachBtn:SetPushedAtlas("RedButton-Expand-Pressed")
  detachBtn:SetDisabledAtlas("RedButton-Expand-Disabled")
  detachBtn:SetHighlightAtlas("RedButton-Highlight", "ADD")
  detachBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(L["Detach"], 1, 0.82, 0, 1, true)
    GameTooltip:AddLine(L["<detach_tooltip>"], 1, 1, 1, 1, true)
    GameTooltip:Show()
  end)
  detachBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
  detachBtn:SetScript("OnClick", function()
    Options:OpenDetached()
  end)
end


function Options:OpenDetached()
  -- If already open just raise it.
  local acd0 = LibStub("AceConfigDialog-3.0")
  if acd0.OpenFrames and acd0.OpenFrames["DynamicCam"] then
    acd0.OpenFrames["DynamicCam"].frame:Raise()
    return
  end

  if SettingsPanel and SettingsPanel:IsShown() then
    SettingsPanel:Hide()
  end

  -- Delay Open until after AceConfigDialog's deferred close (triggered by
  -- the BlizOptionsGroup OnHide callback) has been processed in OnUpdate.
  C_Timer.After(0, function()
      local acd = LibStub("AceConfigDialog-3.0")
      local status = acd:GetStatusTable("DynamicCam")
      status.width = 680
      -- Restore saved height and position from the last session.
      local popOut = DynamicCam.db.global.popOutFrame
      if popOut then
        -- Clamp saved height to 90% of current UI screen height so the
        -- resize handles remain reachable if the resolution was lowered.
        local maxHeight = GetScreenHeight() * 0.9
        if popOut.height then status.height = math.min(popOut.height, maxHeight) end
        if popOut.top    then status.top    = popOut.top    end
        if popOut.left   then status.left   = popOut.left   end
      end
      acd:Open("DynamicCam")
      -- Disable sizer_e (right edge, width only).
      -- Redirect sizer_se (corner) to resize height only, same as sizer_s.
      local widget = acd.OpenFrames["DynamicCam"]
      if widget then
        -- Match the strata of the curve editor frames so they can layer together.
        widget.frame:SetFrameStrata("HIGH")
        widget.frame:Raise()
        widget.frame:SetClampedToScreen(true)

        -- Guard: only create child frames and install hooks once per frame instance.
        -- AceGUI pools Frame widgets, so widget.frame is reused across open/close.
        if not widget.frame._dcCustomized then
          widget.frame._dcCustomized = true

          -- The AceGUI Frame backdrop texture (UI-DialogBox-Background) is
          -- inherently semi-transparent. Layer a solid black ColorTexture
          -- behind the content whose alpha the user can control.
          local solidBg = widget.frame:CreateTexture(nil, "BACKGROUND", nil, -8)
          solidBg:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", 12, -12)
          solidBg:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT", -12, 12)
          solidBg:SetColorTexture(0.2, 0.2, 0.2, 1)
          widget.frame._dcSolidBg = solidBg

          -- "Reattach" button: closes the pop-out frame and reopens settings in the WoW panel.
          local reattachBtn = CreateFrame("Button", nil, widget.frame)
          reattachBtn:SetSize(24, 24)
          reattachBtn:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -20, -20)
          reattachBtn:SetFrameLevel(widget.frame:GetFrameLevel() + 20)
          reattachBtn:SetNormalAtlas("RedButton-Condense")
          reattachBtn:SetPushedAtlas("RedButton-Condense-Pressed")
          reattachBtn:SetDisabledAtlas("RedButton-Condense-disabled")
          reattachBtn:SetHighlightAtlas("RedButton-Highlight", "ADD")
          reattachBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            if InCombatLockdown() then
              GameTooltip:SetText(L["Reattach"], 0.5, 0.5, 0.5, 1, true)
              GameTooltip:AddLine(L["<reattach_combat>"], 1, 0.2, 0.2, 1, true)
            else
              GameTooltip:SetText(L["Reattach"], 1, 0.82, 0, 1, true)
              GameTooltip:AddLine(L["<reattach_tooltip>"], 1, 1, 1, 1, true)
            end
            GameTooltip:Show()
          end)
          reattachBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
          reattachBtn:SetScript("OnClick", function()
            if InCombatLockdown() then return end
            LibStub("AceConfigDialog-3.0"):Close("DynamicCam")
            Settings.OpenToCategory(Options.menu.name)
          end)
          widget.frame._dcReattachBtn = reattachBtn

          -- Visually grey out / restore the reattach button to emulate disabled.
          -- (WoW does not fire OnEnter on truly-disabled buttons, so we fake it.)
          local function setReattachCombatLocked(locked)
            if locked then
              reattachBtn:GetNormalTexture():SetDesaturated(true)
              reattachBtn:GetHighlightTexture():SetAlpha(0)
              reattachBtn:SetPushedAtlas("RedButton-Condense")
              reattachBtn:GetPushedTexture():SetDesaturated(true)
            else
              reattachBtn:GetNormalTexture():SetDesaturated(false)
              reattachBtn:GetHighlightTexture():SetAlpha(1)
              reattachBtn:SetPushedAtlas("RedButton-Condense-Pressed")
              reattachBtn:GetPushedTexture():SetDesaturated(false)
            end
          end
          widget.frame._dcSetReattachCombatLocked = setReattachCombatLocked

          local combatFrame = CreateFrame("Frame")
          combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
          combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
          combatFrame:SetScript("OnEvent", function(self, event)
            setReattachCombatLocked(event == "PLAYER_REGEN_DISABLED")
          end)
          widget.frame._dcCombatFrame = combatFrame

          -- Opacity slider: controls the solid background alpha (0 = default
          -- translucent, 1 = fully opaque).  Frame alpha is always 1.0 so
          -- text and controls remain crisp.
          local opacitySlider = CreateFrame("Slider", nil, widget.frame, "MinimalSliderTemplate")
          opacitySlider:SetWidth(100)
          opacitySlider:SetPoint("RIGHT", reattachBtn, "LEFT", -10, 0)
          opacitySlider:SetFrameLevel(widget.frame:GetFrameLevel() + 20)
          opacitySlider:SetMinMaxValues(0, 1.0)
          opacitySlider:SetValueStep(0.05)
          opacitySlider:SetObeyStepOnDrag(true)
          opacitySlider:SetScript("OnValueChanged", function(self, value)
            widget.frame._dcSolidBg:SetAlpha(value)
            local db = DynamicCam.db.global
            if not db.popOutFrame then db.popOutFrame = {} end
            db.popOutFrame.opacity = value
          end)
          opacitySlider:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            GameTooltip:SetText(L["Increase opacity"], 1, 0.82, 0, 1, true)
            GameTooltip:AddLine(L["<opacity_tooltip>"], 1, 1, 1, 1, true)
            GameTooltip:Show()
          end)
          opacitySlider:SetScript("OnLeave", function() GameTooltip:Hide() end)
          widget.frame._dcOpacitySlider = opacitySlider

          widget.sizer_e:EnableMouse(false)
          widget.sizer_se:SetScript("OnMouseDown", function(this)
            this:GetParent():StartSizing("BOTTOM")
          end)

          -- Allow dragging from any unused background area of the frame.
          local f = widget.frame
          f:EnableMouse(true)
          f:SetMovable(true)

          -- Persists the current frame position and height to a saved variable.
          local function savePopOutState()
            local db = DynamicCam.db.global
            if not db.popOutFrame then db.popOutFrame = {} end
            db.popOutFrame.height = f:GetHeight()
            db.popOutFrame.top    = f:GetTop()
            db.popOutFrame.left   = f:GetLeft()
          end

          f:SetScript("OnMouseDown", function(this, button)
            if button == "LeftButton" then
              this:StartMoving()
            end
          end)
          f:SetScript("OnMouseUp", function(this)
            this:StopMovingOrSizing()
            local s = widget.status or widget.localstatus
            s.top  = this:GetTop()
            s.left = this:GetLeft()
            savePopOutState()
          end)

          -- Hook sizer_s and sizer_se to also persist after height resize.
          widget.sizer_s:HookScript("OnMouseUp", savePopOutState)
          widget.sizer_se:HookScript("OnMouseUp", savePopOutState)

          -- Clamp height during resizing so the bottom edge never leaves the screen.
          local clampingHeight = false
          f:HookScript("OnSizeChanged", function(this)
            if clampingHeight then return end
            local top = this:GetTop()
            if top and this:GetHeight() > top then
              clampingHeight = true
              this:SetHeight(top)
              clampingHeight = false
            end
          end)

          -- Hook the title bar's OnMouseUp to persist position after title-bar drag.
          local knownChildren = {
            [widget.sizer_se] = true,
            [widget.sizer_s]  = true,
            [widget.sizer_e]  = true,
            [widget.content]  = true,
          }
          for _, child in ipairs({f:GetChildren()}) do
            if not knownChildren[child] and child:GetScript("OnMouseUp") then
              child:HookScript("OnMouseUp", savePopOutState)
            end
          end
        end -- _dcCustomized

        -- Apply saved opacity (runs every open so slider reflects current saved value).
        local savedOpacity = (DynamicCam.db.global.popOutFrame and DynamicCam.db.global.popOutFrame.opacity) or 0.0
        widget.frame._dcSolidBg:SetAlpha(savedOpacity)
        widget.frame._dcOpacitySlider:SetValue(savedOpacity)

        -- Sync reattach button visual state with current combat status.
        widget.frame._dcSetReattachCombatLocked(InCombatLockdown())

        -- Disable the dragger (gap between tree and content in TreeGroup widgets).
        local function disableTreeGroupDraggers(container)
          if container.dragger then
            container.dragger:EnableMouse(false)
          end
          if container.children then
            for _, child in ipairs(container.children) do
              disableTreeGroupDraggers(child)
            end
          end
        end
        disableTreeGroupDraggers(widget)

        -- When tabs are switched, AceGUI releases the old TreeGroup and acquires
        -- a new one from its pool, calling OnAcquire which re-enables the dragger.
        -- Install a one-time hook on AceGUI.Create so every TreeGroup acquired
        -- while this pop-out is open has its dragger immediately disabled again.
        local AceGUI = LibStub("AceGUI-3.0")
        if not AceGUI._dcPopOutDraggerHooked then
          AceGUI._dcPopOutDraggerHooked = true
          local origCreate = AceGUI.Create
          AceGUI.Create = function(self, widgetType, ...)
            local w = origCreate(self, widgetType, ...)
            if w and w.type == "TreeGroup" then
              local acd2 = LibStub("AceConfigDialog-3.0")
              if acd2.OpenFrames and acd2.OpenFrames["DynamicCam"] then
                -- Override SetTreeWidth on this instance so no later caller
                -- (e.g. SetStatusTable) can re-enable the dragger.
                local origSTW = w.SetTreeWidth
                w.SetTreeWidth = function(self2, treewidth, resizable)
                  origSTW(self2, treewidth, false)
                end
              end
            end
            return w
          end
        end
      end
    end)
end
