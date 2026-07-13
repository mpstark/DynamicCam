-------------------------------------------------------------------------------
-- DynamicCam Options - Custom AceGUI Widgets
-- Custom widgets for the Options interface
-------------------------------------------------------------------------------

local folderName = ...

local L = LibStub("AceLocale-3.0"):GetLocale("DynamicCam")

assert(DynamicCam)

local Options = DynamicCam.Options


-------------------------------------------------------------------------------
-- Registry for Custom Widget Builders
-------------------------------------------------------------------------------
DynamicCam.customWidgetBuilders = {}


-------------------------------------------------------------------------------
-- Export string popup
-- Shows the generated export string in a read-only but selectable text box, so
-- the user can select-all and copy it. Reuses the StaticPopup inserted-frame
-- pattern (see the script error dialog in SituationManager.lua).
-------------------------------------------------------------------------------
local exportPopupWidth = 400
local exportPopupHeight = 110

local exportOuterFrame = CreateFrame("Frame")
exportOuterFrame:SetSize(exportPopupWidth + 80, exportPopupHeight + 20)

local exportBorderFrame = CreateFrame("Frame", nil, exportOuterFrame, "TooltipBackdropTemplate")
exportBorderFrame:SetSize(exportPopupWidth + 34, exportPopupHeight + 10)
exportBorderFrame:SetPoint("CENTER")

local exportScrollFrame = CreateFrame("ScrollFrame", nil, exportOuterFrame, "UIPanelScrollFrameTemplate")
exportScrollFrame:SetPoint("CENTER", -10, 0)
exportScrollFrame:SetSize(exportPopupWidth, exportPopupHeight)

local exportEditBox = CreateFrame("EditBox", nil, exportScrollFrame)
exportEditBox:SetMultiLine(true)
exportEditBox:SetAutoFocus(false)
exportEditBox:SetFontObject(ChatFontNormal)
exportEditBox:SetWidth(exportPopupWidth)
-- Read-only but still selectable: revert any user edit back to the export string,
-- and re-highlight so a stray keypress does not lose the selection.
exportEditBox:SetScript("OnTextChanged", function(self, userInput)
  if userInput and self.dcExportString and self:GetText() ~= self.dcExportString then
    self:SetText(self.dcExportString)
    self:HighlightText()
  end
end)
exportEditBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
exportScrollFrame:SetScrollChild(exportEditBox)

StaticPopupDialogs["DYNAMICCAM_EXPORT_STRING"] = {
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,

  wide = true,
  wideText = true,

  text = "%s",

  OnShow = function(self)
    exportEditBox:SetText(exportEditBox.dcExportString or "")
    exportEditBox:SetCursorPosition(0)
    exportEditBox:HighlightText()
    exportEditBox:SetFocus()
  end,

  button1 = CLOSE,
  OnButton1 = function() end,
}

function DynamicCam:PopupExportString(exportString, promptText)
  exportEditBox.dcExportString = exportString
  exportOuterFrame:Show()
  StaticPopup_Show("DYNAMICCAM_EXPORT_STRING", promptText or L["Select all and copy the export string below."], nil, nil, exportOuterFrame)
end


-------------------------------------------------------------------------------
-- Situation Export / Import tree widget
-------------------------------------------------------------------------------
-- Shared builder for both the export tree (mode "export") and the import tree
-- (mode "import"). Export reads the live situation; import reads the decoded paste
-- string (DynamicCam.Options.pendingImport) and prunes the tree to the settings it
-- contains. The tree/checkbox/collapse machinery is identical.
local function BuildSituationTreeWidget(widget, f, mode)

  local isImport = (mode == "import")

  -- Header with the action button and the (conditional) set-view section, sitting
  -- above the "Select the settings..." text (created once).
  if not f.headerFrame then
    local header = CreateFrame("Frame", nil, f)
    header:SetPoint("TOPLEFT", f, "TOPLEFT")
    header:SetPoint("TOPRIGHT", f, "TOPRIGHT")
    header:SetHeight(24)
    f.headerFrame = header

    -- Action button (Export or Import).
    local actionButton = CreateFrame("Button", nil, header, "UIPanelButtonTemplate")
    actionButton:SetSize(120, 24)
    actionButton:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
    actionButton:SetText(isImport and L["Import"] or L["Export"])
    f.actionButton = actionButton

    -- Set-view section, shown only when a viewZoom setting is selected: export lets
    -- the user write the view description; import shows it and offers Save View.
    local viewSection = CreateFrame("Frame", nil, header)
    viewSection:SetPoint("TOPLEFT", actionButton, "BOTTOMLEFT", 0, -10)
    viewSection:SetPoint("RIGHT", header, "RIGHT")
    viewSection:Hide()
    f.viewSection = viewSection

    local prompt = viewSection:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    prompt:SetJustifyH("LEFT")
    prompt:SetPoint("TOPLEFT", viewSection, "TOPLEFT")
    prompt:SetPoint("TOPRIGHT", viewSection, "TOPRIGHT")
    viewSection.prompt = prompt

    local editBg = CreateFrame("Frame", nil, viewSection, "TooltipBackdropTemplate")
    editBg:SetPoint("TOPLEFT", prompt, "BOTTOMLEFT", 0, -5)
    editBg:SetPoint("TOPRIGHT", prompt, "BOTTOMRIGHT", 0, -5)
    editBg:SetHeight(60)
    viewSection.editBg = editBg

    local editbox = CreateFrame("EditBox", nil, editBg)
    editbox:SetMultiLine(true)
    editbox:SetAutoFocus(false)
    editbox:SetFontObject(ChatFontNormal)
    editbox:SetPoint("TOPLEFT", editBg, "TOPLEFT", 8, -8)
    editbox:SetPoint("BOTTOMRIGHT", editBg, "BOTTOMRIGHT", -8, 8)
    editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    -- Export: the user writes the description here. Import: read-only note display
    -- (revert any edit back to the exporter's note).
    if isImport then
      editbox:SetScript("OnTextChanged", function(self, userInput)
        if userInput and self.dcNote and self:GetText() ~= self.dcNote then
          self:SetText(self.dcNote)
        end
      end)
    end
    viewSection.editbox = editbox

    local testButton = CreateFrame("Button", nil, viewSection, "UIPanelButtonTemplate")
    testButton:SetSize(120, 24)
    testButton:SetPoint("TOPLEFT", editBg, "BOTTOMLEFT", 0, -8)
    viewSection.testButton = testButton

    -- Collect the checked leaves and whether a viewZoom setting is among them.
    -- Returns (selected, setViewSelected, viewNumber) where selected is an array of
    -- { path = fullPath, value = <value> }. Export reads the live situation; import
    -- reads the value stashed on each node from the paste string.
    function f.GatherSelection()
      local selected = {}
      local setViewSelected = false

      -- Import: collect the checked leaves with their value from the paste string.
      if isImport then
        if f.dataProvider then
          f.dataProvider:ForEach(function(node)
            local data = node:GetData()
            if data.fullPath and data.checked then
              selected[#selected + 1] = { path = data.fullPath, value = data.importValue }
              if data.fullPath[1] == "viewZoom" then
                setViewSelected = true
              end
            end
          end, TreeDataProviderConstants.IncludeCollapsed)
        end
        return selected, setViewSelected
      end

      local SID = DynamicCam.Options.SID
      local situation = SID and DynamicCam.db.profile.situations[SID]
      if f.dataProvider and situation then
        f.dataProvider:ForEach(function(node)
          local data = node:GetData()
          if data.fullPath and data.checked then
            local path = data.fullPath
            local value

            -- Read the actual value with its correct type. Note we do NOT use
            -- data.get: some option get-functions return display strings (e.g.
            -- priority and events), which would corrupt the export.
            if path[1] == "situationSettings" and path[2] == "cvars" then
              -- Effective cvar value (situation override or standard fallback).
              value = DynamicCam:GetSettingsValue(SID, "cvars", path[3])
            else
              value = situation
              for i = 1, #path do
                if type(value) ~= "table" then
                  value = nil
                  break
                end
                value = value[path[i]]
                if value == nil then break end
              end
            end

            if value ~= nil then
              selected[#selected + 1] = { path = path, value = value }
            end
            if path[1] == "viewZoom" then
              setViewSelected = true
            end
          end
        end, TreeDataProviderConstants.IncludeCollapsed)
      end

      -- Only a set-view export if the situation actually switches to a saved view.
      local viewNumber
      if setViewSelected and situation and situation.viewZoom
         and situation.viewZoom.enabled and situation.viewZoom.viewZoomType == "view" then
        viewNumber = situation.viewZoom.viewNumber
      else
        setViewSelected = false
      end

      return selected, setViewSelected, viewNumber
    end

    -- Reactively refresh the action button state and the view section.
    function f.UpdateUI()
      local selected, setViewSelected, viewNumber = f.GatherSelection()

      if #selected > 0 then
        actionButton:Enable()
      else
        actionButton:Disable()
      end

      local showView = false
      if isImport then
        local imp = DynamicCam.Options.pendingImport
        local note = imp and imp.viewDescription
        local slot = imp and imp.situation and imp.situation.viewZoom and imp.situation.viewZoom.viewNumber
        if setViewSelected and note and note ~= "" then
          showView = true
          prompt:SetText(L["<importSetView_desc>"])
          editbox.dcNote = note
          editbox:SetText(note)
          testButton:SetText(L["Save current camera to View %d"]:format(slot or 0))
        end
      elseif setViewSelected then
        showView = true
        prompt:SetText(L["<exportSetView_desc>"])
        testButton:SetText(L["Test view %d"]:format(viewNumber or 0))
      end

      if showView then
        viewSection:Show()
        local h = prompt:GetStringHeight() + 5 + editBg:GetHeight() + 8 + testButton:GetHeight()
        viewSection:SetHeight(h)
        header:SetHeight(actionButton:GetHeight() + 10 + h)
      else
        viewSection:Hide()
        header:SetHeight(actionButton:GetHeight())
      end

      if widget.AdjustHeightFunction then widget:AdjustHeightFunction() end
    end

    actionButton:SetScript("OnClick", function()
      local selected, setViewSelected = f.GatherSelection()
      if #selected == 0 then return end
      local SID = DynamicCam.Options.SID

      if isImport then
        DynamicCam:ApplyImportedSettings(SID, selected)
        local acr = LibStub("AceConfigRegistry-3.0")
        acr:NotifyChange("DynamicCam")
        acr:NotifyChange("DynamicCam_Detached")
        DynamicCam:Print(L["Imported %d setting(s) into the current situation."]:format(#selected))
      else
        local viewDescription
        if setViewSelected then
          viewDescription = viewSection.editbox:GetText()
        end
        local exportString = DynamicCam:ExportSelectedSituation(SID, selected, viewDescription)
        DynamicCam:PopupExportString(exportString)
      end
    end)

    -- Export: switch to the saved view so the exporter can look at it while writing
    -- the description. Import: save the current camera into the imported view slot.
    testButton:SetScript("OnClick", function()
      if isImport then
        local imp = DynamicCam.Options.pendingImport
        local slot = imp and imp.situation and imp.situation.viewZoom and imp.situation.viewZoom.viewNumber
        if slot then SaveView(slot) end
      else
        local _, setViewSelected, viewNumber = f.GatherSelection()
        if setViewSelected and viewNumber then
          SetView(viewNumber)
        end
      end
    end)
  end

  -- Description text ("Select the settings you want to export"), below the header.
  if not f.help then
    f.help = f:CreateFontString(nil, "OVERLAY")
    f.help:SetFontObject("GameFontHighlightSmall")
    f.help:SetJustifyH("LEFT")
    f.help:SetPoint("TOPLEFT", f.headerFrame, "BOTTOMLEFT", 0, -10)
    f.help:SetPoint("TOPRIGHT", f.headerFrame, "BOTTOMRIGHT", 0, -10)
    f.help:SetText(isImport and L["Select the settings you want to import."] or L["Select the settings you want to export."])
  end

  -- Tree ScrollBox (created once). Uses Blizzard's ScrollBox + TreeDataProvider so
  -- row frames are recycled and rendered reliably by the engine, and collapse/
  -- expand is handled by the data provider. The ScrollBox has a FIXED height, so
  -- our widget's height never changes on collapse -- the surrounding AceGUI
  -- ScrollFrame is never perturbed, which is what made the old manual layout
  -- fragile (empty box / invisible rows / drift).
  local ROW_HEIGHT = 24
  local TREE_INDENT = 20

  if not f.scrollBox then

    -- Fill the area below the header down to the bottom of the widget frame; the
    -- widget height itself tracks the available viewport (see AdjustHeightFunction),
    -- so the tree grows/shrinks with the options frame instead of a fixed size.
    f.scrollBox = CreateFrame("Frame", nil, f, "WowScrollBoxList")
    f.scrollBox:SetPoint("TOPLEFT", f.help, "BOTTOMLEFT", 0, -10)
    f.scrollBox:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -20, 0)

    f.scrollBar = CreateFrame("EventFrame", nil, f, "MinimalScrollBar")
    f.scrollBar:SetPoint("TOPLEFT", f.scrollBox, "TOPRIGHT", 4, 0)
    f.scrollBar:SetPoint("BOTTOMLEFT", f.scrollBox, "BOTTOMRIGHT", 4, 0)

    -- Tri-state (true / false / "mixed") of a node from its descendants.
    local function GetNodeState(node)
      local children = node:GetNodes()
      if #children == 0 then
        return node:GetData().checked and true or false
      end
      local allChecked, allUnchecked = true, true
      for _, child in ipairs(children) do
        local s = GetNodeState(child)
        if s == true then allUnchecked = false
        elseif s == false then allChecked = false
        else allChecked = false; allUnchecked = false end
      end
      if allChecked then return true end
      if allUnchecked then return false end
      return "mixed"
    end

    local function ApplyCheckVisual(cb, state)
      local tex = cb:GetCheckedTexture()
      if state == true then
        cb:SetChecked(true); tex:SetAlpha(1)
      elseif state == false then
        cb:SetChecked(false)
      else
        cb:SetChecked(true); tex:SetAlpha(0.4)
      end
    end

    local function SetNodeCheckedRecursive(node, checked)
      local data = node:GetData()
      data.checked = checked
      local children = node:GetNodes()
      if #children == 0 then
        -- Leaf holds the source-of-truth checked state; persist it so the
        -- selection survives switching tabs (groups derive their tri-state).
        if data.pathKey and f.checkState then
          f.checkState[data.pathKey] = checked
        end
      else
        for _, child in ipairs(children) do
          SetNodeCheckedRecursive(child, checked)
        end
      end
    end

    -- Refresh the checkbox visuals of all currently-visible rows (ancestors of a
    -- toggled node change their mixed/checked state).
    local function RefreshChecks()
      f.scrollBox:ForEachFrame(function(frame)
        if frame.cb then
          ApplyCheckVisual(frame.cb, GetNodeState(frame:GetElementData()))
        end
      end)
    end

    -- Element initializer: build the row's sub-frames once, then reconfigure them
    -- for the given tree node on each (re)bind.
    local function InitRow(frame, node)
      local data = node:GetData()

      if not frame.created then
        frame.created = true

        frame.expandBtn = CreateFrame("Button", nil, frame)
        frame.expandBtn:SetSize(22, 22)
        frame.expandBtn:SetPoint("LEFT", 0, 0)
        frame.expandBtn:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")

        frame.cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        frame.cb:SetSize(24, 24)

        frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.label:SetJustifyH("LEFT")
        frame.label:SetPoint("LEFT", frame.cb, "RIGHT", 2, 0)
        frame.label:SetPoint("RIGHT", frame, "RIGHT", -4, 0)
      end

      local hasChildren = #node:GetNodes() > 0

      -- Expand/collapse button (groups only, and not the non-collapsible root).
      if hasChildren and not data.notCollapsible then
        local function ApplyExpandAtlas()
          local collapsed = node:IsCollapsed()
          frame.expandBtn:SetNormalAtlas(collapsed and "common-button-dropdown-closed" or "common-button-dropdown-open")
          frame.expandBtn:SetPushedAtlas(collapsed and "common-button-dropdown-closedpressed" or "common-button-dropdown-openpressed")
        end
        ApplyExpandAtlas()
        frame.expandBtn:SetScript("OnClick", function()
          node:ToggleCollapsed()
          -- Update this button's atlas immediately: the ScrollBox re-lays out the
          -- list, but does not re-initialize this already-visible header row.
          ApplyExpandAtlas()
          -- Remember the new state so it survives switching tabs.
          if data.pathKey and f.collapseState then
            f.collapseState[data.pathKey] = node:IsCollapsed()
          end
        end)
        frame.expandBtn:Show()
      else
        frame.expandBtn:SetScript("OnClick", nil)
        frame.expandBtn:Hide()
      end

      -- Checkbox: leave room for the expand-button column unless this is the root.
      frame.cb:ClearAllPoints()
      frame.cb:SetPoint("LEFT", data.notCollapsible and 0 or 24, 0)
      ApplyCheckVisual(frame.cb, GetNodeState(node))
      frame.cb:SetScript("OnClick", function()
        SetNodeCheckedRecursive(node, GetNodeState(node) ~= true)
        RefreshChecks()
        if f.UpdateUI then f.UpdateUI() end
      end)

      -- Label (name, plus a compact value preview for leaves). Import shows the
      -- value from the paste string; export shows the live value.
      local text = data.name or ""
      if not hasChildren then
        local val
        if isImport then
          val = data.importValue
        elseif data.get then
          local ok, v = pcall(data.get)
          if ok then val = v end
        end
        if val ~= nil then
          if type(val) == "table" then
            val = "{...}"
          elseif type(val) == "number" then
            val = math.floor(val * 100 + 0.5) / 100
          end
          val = tostring(val):gsub("\n", " ")
          if #val > 40 then val = val:sub(1, 40) .. "..." end
          text = text .. " |cFF888888[" .. val .. "]|r"
        end
      end
      frame.label:SetText(text)
    end

    local view = CreateScrollBoxListTreeListView(TREE_INDENT, 0, 0, 0, 0, 0)
    view:SetElementExtent(ROW_HEIGHT)
    view:SetElementInitializer("Frame", InitRow)
    ScrollUtil.InitScrollBoxListWithScrollBar(f.scrollBox, f.scrollBar, view)
    -- Hide the scrollbar when everything fits (no scrolling possible).
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(f.scrollBox, f.scrollBar)
    f.scrollBoxView = view
  end

  -- ---- Tree Building Logic (re-evaluated each rebuild) ----

  -- Each exportable leaf carries an _dbPath relative to one of three roots. The
  -- situationSettings tab's paths are relative to situation.situationSettings,
  -- while situationActions/situationControls paths are relative to the situation
  -- root. We prefix accordingly so every leaf ends up with a full situation-root
  -- relative path (fullPath) usable by ExportSelectedSituation.
  local ROOT_PREFIX = {
    situationSettings = {"situationSettings"},
    situationActions = {},
    situationControls = {},
  }

  local function MergePath(rootPath, dbPath)
    local path = {}
    for _, k in ipairs(rootPath) do path[#path + 1] = k end
    if type(dbPath) == "table" then
      for _, k in ipairs(dbPath) do path[#path + 1] = k end
    else
      path[#path + 1] = dbPath
    end
    return path
  end

  local function BuildTreeData(args, rootPath)
    rootPath = rootPath or {}
    local tree = {}
    for key, entry in pairs(args) do
      -- Check disabled status
      local isDisabled = false
      if entry.disabled then
        if type(entry.disabled) == "function" then
          isDisabled = entry.disabled({})
        else
          isDisabled = entry.disabled
        end
      end

      -- Check hidden status. Import includes hidden entries (e.g. the view fields
      -- when the live situation is currently a Set Zoom): the tree is pruned to the
      -- imported paths afterwards, so hidden filtering would wrongly drop them.
      local isHidden = false
      if entry.hidden and not isImport then
        if type(entry.hidden) == "function" then
          isHidden = entry.hidden({})
        else
          isHidden = entry.hidden
        end
      end

      -- For leaf entries with _dbPath (exportable settings), include even if
      -- disabled (e.g. sliders disabled because the cvar is zoom-based).
      local skipDisabled = isDisabled and not entry._dbPath
      if not skipDisabled and not isHidden then
        if entry.type == "group" then
          local children = BuildTreeData(entry.args, ROOT_PREFIX[key] or rootPath)
          if next(children) then
            local rawName = (type(entry.name) == "function" and entry.name() or entry.name)
            local name = rawName and rawName:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") or ""

            -- Optimization: If group has name, but contains only 1 child,
            -- hoist the child and merge the names.
            if name and name ~= "" and #children == 1 then
              local child = children[1]
              local cleanChildName = child.name and child.name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") or ""

              if cleanChildName ~= "" then
                child.name = name .. " |cFFFFFFFF- " .. cleanChildName .. "|r"
              else
                if child.children then
                  child.name = name
                else
                  child.name = "|cFFFFFFFF" .. name .. "|r"
                end
              end
              child.order = entry.order or child.order
              table.insert(tree, child)
            elseif not name or name == "" then
              -- If the group has no name (like inline groups), flatten it by merging children up
              for _, child in ipairs(children) do
                table.insert(tree, child)
              end
            else
              table.insert(tree, {
                key = key,
                name = name,
                children = children,
                order = entry.order or 100,
                checked = false,
                notCollapsible = entry.notCollapsible
              })
            end
          end
        elseif entry._dbPath or entry.get then
          local rawName = (type(entry.name) == "function" and entry.name() or entry.name)
          local cleanName = rawName and rawName:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "") or ""

          local finalName = cleanName
          if cleanName ~= "" then
            finalName = "|cFFFFFFFF" .. cleanName .. "|r"
          end

          local cvarName = nil
          if type(entry._dbPath) == "table" and entry._dbPath[1] == "cvars" then
            cvarName = entry._dbPath[2]
          end

          table.insert(tree, {
            key = key,
            name = finalName,
            dbPath = entry._dbPath,
            fullPath = entry._dbPath and MergePath(rootPath, entry._dbPath) or nil,
            order = entry.order or 100,
            get = entry.get,
            arg = entry.arg,
            type = entry.type,
            multiline = entry.multiline,
            cvarName = cvarName,
            checked = false
          })
        end
      end
    end
    table.sort(tree, function(a,b) return a.order < b.order end)
    return tree
  end

  -- Get options structure - these functions are defined in the main Options.lua
  local fullOptions = Options.CreateSituationSettingsTab(0, true)
  local exportArgs = {
    everything = {
      type = "group",
      name = "Everything",
      order = 1,
      notCollapsible = true,
      args = {
        situationSettings = {
          type = "group",
          name = L["Situation Settings"],
          order = 1,
          args = Options.CreateSettingsTab(0, true, true).args
        },
        situationActions = {
          type = "group",
          name = L["Situation Actions"],
          order = 2,
          args = fullOptions.args.situationActions.args
        },
        situationControls = {
          type = "group",
          name = L["Situation Controls"],
          order = 3,
          args = fullOptions.args.situationControls.args
        }
      }
    }
  }

  local treeData = BuildTreeData(exportArgs)

  -- Import: prune the tree to only the settings present in the paste string, and
  -- stash each leaf's imported value on its node (for display and applying).
  if isImport then
    local importSituation = DynamicCam.Options.pendingImport and DynamicCam.Options.pendingImport.situation
    local function ReadPath(tbl, path)
      local v = tbl
      for i = 1, #path do
        if type(v) ~= "table" then return nil end
        v = v[path[i]]
        if v == nil then return nil end
      end
      return v
    end
    local function Prune(nodes)
      local kept = {}
      for _, node in ipairs(nodes) do
        if node.children then
          node.children = Prune(node.children)
          if #node.children > 0 then kept[#kept + 1] = node end
        elseif node.fullPath then
          local val = importSituation and ReadPath(importSituation, node.fullPath)
          if val ~= nil then
            node.importValue = val
            kept[#kept + 1] = node
          end
        end
      end
      return kept
    end
    treeData = importSituation and Prune(treeData) or {}
  end

  -- ---- Populate the tree ----

  -- Collapse/selection state is remembered across tab switches (module-level, so it
  -- survives the widget being released and reacquired), and resets when the selected
  -- situation changes or on /reload. Export and import keep separate state.
  local sidKey = isImport and "importStateSID" or "exportStateSID"
  local collapseKey = isImport and "importCollapseState" or "exportCollapseState"
  local checkKey = isImport and "importCheckState" or "exportCheckState"
  local currentSID = Options.SID
  if Options[sidKey] ~= currentSID then
    Options[sidKey] = currentSID
    Options[collapseKey] = {}
    Options[checkKey] = {}
    -- Also clear the exporter's view-instruction text, which belonged to the
    -- previous situation. (Import re-fills the note from the paste string, so this
    -- only affects the export description box.)
    if not isImport and f.viewSection and f.viewSection.editbox then
      f.viewSection.editbox:SetText("")
    end
  end
  Options[collapseKey] = Options[collapseKey] or {}
  Options[checkKey] = Options[checkKey] or {}
  local collapseState = Options[collapseKey]
  local checkState = Options[checkKey]
  f.collapseState = collapseState
  f.checkState = checkState

  -- Build a fresh TreeDataProvider from the tree.
  local dataProvider = CreateTreeDataProvider()
  local function InsertNodes(parentNode, myNodes, parentKey, depth)
    for _, myNode in ipairs(myNodes) do
      local pathKey = parentKey .. "/" .. (myNode.name or myNode.key or "?")
      myNode.pathKey = pathKey
      local inserted = parentNode:Insert(myNode)
      if myNode.children and #myNode.children > 0 then
        -- Default: only the top level ("Everything", depth 1) is expanded; its
        -- three children (depth 2) start collapsed. A remembered state overrides.
        local collapsed
        if collapseState[pathKey] ~= nil then
          collapsed = collapseState[pathKey]
        else
          collapsed = (depth == 2)
        end
        inserted:SetCollapsed(collapsed)
        InsertNodes(inserted, myNode.children, pathKey, depth + 1)
      else
        -- Leaf: restore the remembered checked state, else default to selected.
        if checkState[pathKey] ~= nil then
          myNode.checked = checkState[pathKey]
        else
          myNode.checked = true
        end
      end
    end
  end
  InsertNodes(dataProvider, treeData, "", 1)
  f.dataProvider = dataProvider
  f.scrollBox:SetDataProvider(dataProvider)

  -- The widget height tracks the available viewport height so the tree fills the
  -- options frame and grows/shrinks with it. It does NOT depend on the tree
  -- contents, so collapse/expand never resizes the widget or perturbs the
  -- enclosing AceGUI ScrollFrame.
  widget.AdjustHeightFunction = function(self)
    local headerHeight = f.headerFrame and f.headerFrame:GetHeight() or 0
    local overhead = headerHeight + 10 + f.help:GetStringHeight() + 10

    -- Export fills the enclosing AceGUI ScrollFrame's viewport (it is the only
    -- element on its tab). Import sits below a paste box, so it uses a fixed height
    -- to avoid overflowing the viewport.
    local total = overhead + (isImport and 350 or 400)
    local p = widget.parent
    if not isImport and p and p.scrollframe then
      local sf = p.scrollframe

      -- Re-run when the viewport is resized. The detached frame has a fixed width
      -- and only resizes vertically, so OnWidthSet never fires there; hook the
      -- viewport's size change instead. dcFillWidget is refreshed every call so
      -- the hook always drives the currently-acquired widget.
      sf.dcFillWidget = self
      if not sf.dcFillHooked then
        sf.dcFillHooked = true
        sf:HookScript("OnSizeChanged", function(hooked)
          local w = hooked.dcFillWidget
          if w and w.AdjustHeightFunction and w.frame and w.frame:IsShown() then
            w:AdjustHeightFunction()
          end
        end)
      end

      local avail = sf:GetHeight()
      if avail and avail > overhead + 120 then
        total = avail - 16
      end
    end

    -- Guard against redundant sets (and any feedback from the resize hook).
    if math.abs((f:GetHeight() or 0) - total) > 0.5 then
      f:SetHeight(total)
      self:SetHeight(total)
    end
  end

  -- Set the initial action button / view section state and size the widget.
  if f.UpdateUI then f.UpdateUI() end
end

DynamicCam.customWidgetBuilders["SituationExport"] = function(widget, f)
  BuildSituationTreeWidget(widget, f, "export")
end

DynamicCam.customWidgetBuilders["SituationImport"] = function(widget, f)
  BuildSituationTreeWidget(widget, f, "import")
end


-------------------------------------------------------------------------------
-- DynamicCam_CustomWidget
-- My custom widget for Situation Export.
-- Inspired by https://github.com/SFX-WoW/AceGUI-3.0_SFX-Widgets/.
-------------------------------------------------------------------------------
do
  local Type, Version = "DynamicCam_CustomWidget", 1
  local AceGUI = LibStub("AceGUI-3.0", true)

  -- Standard Ace3 version check: If a newer version of this widget is already registered, don't overwrite it.
  if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

  local function Constructor()

    local Widget     = {}
    Widget.frame     = CreateFrame("Frame", nil, UIParent)
    Widget.frame.obj = Widget
    Widget.type      = Type
    Widget.num       = AceGUI:GetNextWidgetNum(Type)

    -- Reccommended place to store ephemeral widget information.
    Widget.userdata = {}

    -- Storage for our different views (builders)
    Widget.views = {}

    -- OnAcquire, SetLabel, SetText, SetDisabled(nil)
    -- all get called when showing the widget.
    Widget.OnAcquire = function(self)
      self.resizing = true

      self:SetDisabled(true)

      -- Hide all views
      for _, view in pairs(self.views) do
        view:Hide()
      end
      self.currentView = nil
      self.AdjustHeightFunction = nil

      self.resizing = nil
    end

    Widget.SetLabel = function(self, name)
      -- Use 'name' as the ID to look up the builder.
      local builder = DynamicCam.customWidgetBuilders[name]
      if not builder then return end

      -- Reuse the existing view frame to avoid leaking frames.
      if not self.views[name] then
        local f = CreateFrame("Frame", nil, self.frame)
        f:SetPoint("TOPLEFT")
        f:SetPoint("TOPRIGHT")
        self.views[name] = f
      end

      local f = self.views[name]
      builder(self, f)

      self.currentView = f
      self.currentView:Show()

      -- Trigger a resize now that we have content
      if self.AdjustHeightFunction then
        self:AdjustHeightFunction()
      end
    end

    -- Not useful to us, but Ace3 needs to call it.
    Widget.SetText = function(self) end

    Widget.OnWidthSet = function(self)
      if self.resizing then return end

      -- Whenever OnWidthSet() is called, adjust the height of the frames to contain all child frames.
      if self.AdjustHeightFunction then self:AdjustHeightFunction() end
    end

    Widget.SetDisabled = function(self, Disabled)
      self.disabled = Disabled
    end

    -- OnRelease gets called when hiding the widget.
    Widget.OnRelease = function(self)
      self:SetDisabled(true)
      self.frame:ClearAllPoints()
      if self.currentView then
        self.currentView:Hide()
      end
      self.currentView = nil
      self.AdjustHeightFunction = nil
    end

    return AceGUI:RegisterAsWidget(Widget)
  end

  AceGUI:RegisterWidgetType(Type, Constructor, Version)
end


-------------------------------------------------------------------------------
-- DynamicCam_ZoomBasedControl
-- Custom AceGUI widget for zoom-based controls.
-- Displays a checkbox and edit button side-by-side with a single label underneath.
-------------------------------------------------------------------------------
do
  local Type, Version = "DynamicCam_ZoomBasedControl", 1
  local AceGUI = LibStub("AceGUI-3.0", true)

  -- Standard Ace3 version check
  if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

  local function Constructor()
    local Widget = {}
    Widget.type = Type
    Widget.num = AceGUI:GetNextWidgetNum(Type)
    Widget.userdata = {}

    -- Main container frame
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetHeight(36)
    Widget.frame = frame
    frame.obj = Widget

    -- Checkbox (no text, we'll use our own label)
    local checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    checkbox:SetSize(24, 24)
    checkbox:SetPoint("TOPRIGHT", frame, "TOP", 0, 0)
    checkbox:SetHitRectInsets(0, 0, 0, 0)
    Widget.checkbox = checkbox


    -- Edit button (gear icon)
    local editBtn = CreateFrame("Button", nil, frame)
    editBtn:SetSize(23, 23)
    editBtn:SetPoint("TOPLEFT", frame, "TOP", 0, -3)
    Widget.editBtn = editBtn

    -- Base texture path
    -- https://wago.tools/files?search=interface%2Fcommon%2Fcommondropdownsettings2x
    -- In classic, this texture is not included in the game files, so we use a local copy.
    local texturePath = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
      and "Interface\\Common\\CommonDropdownSettings2x"
      or  "Interface\\AddOns\\" .. folderName .. "\\BLP\\commondropdownsettings2x"

    -- Store the texture coordinates for different highlight states
    Widget.noHighlightNormalCoords  = {0.21875, 0.43750, 0.00000, 0.43750}  -- Texture: center, top
    Widget.noHighlightPressedCoords = {0.21875, 0.43750, 0.43750, 0.87500}  -- Texture: center, bottom
    Widget.highlightNormalCoords    = {0.00000, 0.21875, 0.43750, 0.87500}  -- Texture: left, bottom
    Widget.highlightPressedCoords   = {0.43750, 0.65625, 0.00000, 0.43750}  -- Texture: right, top
    Widget.disabledCoords           = {0.00000, 0.21875, 0.00000, 0.43750}  -- Texture: left, top


    -- Normal texture - use SetNormalTexture for proper button behavior

    editBtn:SetNormalTexture(texturePath)
    local normalTex = editBtn:GetNormalTexture()
    normalTex:SetTexCoord(unpack(Widget.noHighlightNormalCoords))
    Widget.editIcon = normalTex

    -- Pushed/pressed texture - use SetPushedTexture
    -- Shows when button is pressed but mouse is NOT hovering (pressed-not-highlighted)
    editBtn:SetPushedTexture(texturePath)
    local pushedTex = editBtn:GetPushedTexture()
    pushedTex:SetTexCoord(unpack(Widget.noHighlightPressedCoords))
    Widget.editPushed = pushedTex

    -- Highlight texture - use SetHighlightTexture
    editBtn:SetHighlightTexture(texturePath)
    local highlightTex = editBtn:GetHighlightTexture()
    highlightTex:SetTexCoord(unpack(Widget.highlightNormalCoords))
    highlightTex:SetBlendMode("BLEND")
    Widget.editHighlight = highlightTex

    -- Track button press state (mouse down) and toggle state (editor open)
    Widget.isMousePressed = false
    Widget.isEditorOpen = false

    -- Disabled texture - use SetDisabledTexture
    editBtn:SetDisabledTexture(texturePath)
    local disabledTex = editBtn:GetDisabledTexture()
    disabledTex:SetTexCoord(0, 0.21093750, 0, 0.421875)
    Widget.editDisabled = disabledTex

    -- Helper function to update button textures based on editor open state
    local function UpdateButtonTextures()
      if Widget.isEditorOpen then
        -- When editor is open, show pressed appearance
        Widget.editIcon:SetTexCoord(unpack(Widget.noHighlightPressedCoords))
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      else
        -- Normal appearance
        Widget.editIcon:SetTexCoord(unpack(Widget.noHighlightNormalCoords))
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightNormalCoords))
      end
    end
    Widget.UpdateButtonTextures = UpdateButtonTextures

    -- Open the editor for this widget
    local function OpenEditor()
      if Widget.isEditorOpen then return end

      Widget.isEditorOpen = true

      -- Call the EditFunc to actually open the editor
      if Widget.EditFunc then
        Widget.EditFunc(true, Widget)  -- Pass widget so EditFunc can set up close callbacks
      end

      UpdateButtonTextures()
    end
    Widget.OpenEditor = OpenEditor

    -- Close the editor for this widget
    local function CloseEditor()
      if not Widget.isEditorOpen then return end

      Widget.isEditorOpen = false

      -- Call the EditFunc to actually close the editor
      if Widget.EditFunc then
        Widget.EditFunc(false, Widget)
      end

      UpdateButtonTextures()
    end
    Widget.CloseEditor = CloseEditor

    -- Toggle editor open/closed
    local function ToggleEditor()
      if Widget.isEditorOpen then
        Widget:CloseEditor()
      else
        Widget:OpenEditor()
      end
    end
    Widget.ToggleEditor = ToggleEditor

    -- Label underneath both controls
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("BOTTOM", frame, "BOTTOM", 0, 3)
    label:SetText(L["Zoom-based"])
    Widget.label = label

    -- Checkbox click handler
    checkbox:SetScript("OnClick", function(self)
      local checked = self:GetChecked()
      if Widget.SetValueFunc then
        Widget.SetValueFunc(checked)
      end
      -- Update button disabled state after toggle
      if Widget.UpdateDisabled then
        Widget:UpdateDisabled()
      end
      -- Notify AceConfig to refresh the UI (disables/enables associated slider)
      local acr = LibStub("AceConfigRegistry-3.0")
      acr:NotifyChange("DynamicCam")
      acr:NotifyChange("DynamicCam_Detached")
      PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
    end)

    -- Checkbox tooltip
    checkbox:SetScript("OnEnter", function(self)
      if Widget.checkboxTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Zoom-based"], 1, 1, 1)
        GameTooltip:AddLine(Widget.checkboxTooltip, nil, nil, nil, true)
        GameTooltip:Show()
      end
    end)
    checkbox:SetScript("OnLeave", function(self)
      GameTooltip:Hide()
    end)

    -- Edit button state handlers for highlight texture switching
    editBtn:SetScript("OnMouseDown", function(self)
      if not Widget.editBtnDisabled then
        Widget.isMousePressed = true
        -- Show pressed highlight while mouse is down
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      end
    end)

    editBtn:SetScript("OnMouseUp", function(self)
      Widget.isMousePressed = false
      -- Restore highlight based on editor open state
      if Widget.isEditorOpen then
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      else
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightNormalCoords))
      end
    end)

    -- Edit button click handler - now toggles the editor
    editBtn:SetScript("OnClick", function(self)
      if not Widget.editBtnDisabled then
        Widget:ToggleEditor()
      end
    end)

    -- Edit button tooltip
    editBtn:SetScript("OnEnter", function(self)
      -- Update highlight based on pressed state or editor open state
      if Widget.isMousePressed and not Widget.editBtnDisabled then
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      elseif Widget.isEditorOpen then
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      end

      if Widget.editBtnTooltip then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["Edit Curve"], 1, 1, 1)
        GameTooltip:AddLine(Widget.editBtnTooltip, nil, nil, nil, true)
        GameTooltip:Show()
      end
    end)

    editBtn:SetScript("OnLeave", function(self)
      GameTooltip:Hide()
      -- Restore textures based on state
      if Widget.isMousePressed and not Widget.editBtnDisabled then
        -- Mouse still pressed but left button area
        Widget.editHighlight:SetTexCoord(unpack(Widget.noHighlightPressedCoords))
      elseif Widget.isEditorOpen then
        -- Editor is open, keep pressed highlight look
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightPressedCoords))
      else
        Widget.editHighlight:SetTexCoord(unpack(Widget.highlightNormalCoords))
      end
    end)

    -- Widget methods
    Widget.OnAcquire = function(self)
      self:SetDisabled(false)
      self.checkbox:SetChecked(false)
      self.editBtnDisabled = true
      self.isEditorOpen = false
      self.isMousePressed = false
      self:UpdateButtonTextures()
      self:UpdateDisabled()
    end

    Widget.OnRelease = function(self)
      -- Don't close the editor when widget is released - it should stay open
      -- The editor state will be restored when the widget is reacquired
      if self._registeredConfigId then
        local tbl = DynamicCam._activeZoomWidgets and DynamicCam._activeZoomWidgets[self._registeredConfigId]
        if tbl then tbl[self] = nil end
        self._registeredConfigId = nil
      end
      self.GetValueFunc = nil
      self.SetValueFunc = nil
      self.EditFunc = nil
      self.DisabledFunc = nil
      self.checkboxTooltip = nil
      self.editBtnTooltip = nil
      self.configId = nil
      self.frame:ClearAllPoints()
    end

    Widget.SetDisabled = function(self, disabled)
      self.disabled = disabled
      if disabled then
        self.checkbox:Disable()
        self.checkbox:SetAlpha(0.5)
        self.label:SetAlpha(0.5)
      else
        self.checkbox:Enable()
        self.checkbox:SetAlpha(1)
        self.label:SetAlpha(1)
      end
      self:UpdateDisabled()
    end

    Widget.UpdateDisabled = function(self)
      -- Edit button is disabled if widget is disabled OR if checkbox is unchecked
      local editDisabled = self.disabled or not self.checkbox:GetChecked()
      if self.DisabledFunc then
        editDisabled = editDisabled or self.DisabledFunc()
      end
      self.editBtnDisabled = editDisabled

      -- Use the proper button Enable/Disable methods
      if editDisabled then
        self.editBtn:Disable()
        -- Close editor if it was open
        if self.isEditorOpen then
          self:CloseEditor()
        end
      else
        self.editBtn:Enable()
      end
    end

    Widget.SetValue = function(self, value)
      self.checkbox:SetChecked(value)
      self:UpdateDisabled()
    end

    -- Called by AceConfigDialog - the name is our config ID
    Widget.SetLabel = function(self, configId)
      -- Look up the configuration from the registry
      local config = DynamicCam.zoomBasedControlConfigs and DynamicCam.zoomBasedControlConfigs[configId]
      if not config then return end

      -- Unregister from previous configId (widget may be reused from pool)
      if self._registeredConfigId then
        local prev = DynamicCam._activeZoomWidgets[self._registeredConfigId]
        if prev then prev[self] = nil end
      end

      self.configId = configId
      self._registeredConfigId = configId

      -- Register in the active-widget table so editors can sync all instances
      if not DynamicCam._activeZoomWidgets then
        DynamicCam._activeZoomWidgets = {}
      end
      if not DynamicCam._activeZoomWidgets[configId] then
        DynamicCam._activeZoomWidgets[configId] = {}
      end
      DynamicCam._activeZoomWidgets[configId][self] = true
      self.checkboxTooltip = config.checkboxTooltip
      self.editBtnTooltip = config.editBtnTooltip
      self.EditFunc = config.editFunc
      self.SetValueFunc = config.setFunc
      self.GetValueFunc = config.getFunc

      -- Set initial state
      if config.getFunc then
        self.checkbox:SetChecked(config.getFunc())
      end

      -- Check if editor is currently open for this setting and restore button state
      if config.getSituationId and config.cvarName and DynamicCam.IsEditorOpenForSetting then
        local situationId = config.getSituationId()
        if DynamicCam:IsEditorOpenForSetting(situationId, config.cvarName) then
          self.isEditorOpen = true
          self:UpdateButtonTextures()
          -- Update the editor's widget reference to this widget instance
          if DynamicCam.UpdateEditorWidgetReference then
            DynamicCam:UpdateEditorWidgetReference(self)
          end
        end
      end

      self:UpdateDisabled()
    end

    Widget.SetCallback = function(self, event, func)
      -- Not needed - we handle callbacks through the registry
    end

    -- SetText is called by AceConfigDialog for input widgets, ignore it
    Widget.SetText = function(self, text)
    end

    return AceGUI:RegisterAsWidget(Widget)
  end

  AceGUI:RegisterWidgetType(Type, Constructor, Version)
end
