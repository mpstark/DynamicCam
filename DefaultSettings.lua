local folderName = ...
local DynamicCam = LibStub("AceAddon-3.0"):GetAddon(folderName)




DynamicCam.situationDefaults = {

  name = "",

  enabled = false,

  executeOnInit = "",

  priority = 0,
  events = {},

  condition = "return false",

  executeOnEnter = "",
  executeOnExit = "",

  delay = 0,


  viewZoom = {
    enabled = false,
    viewZoomType = "zoom",

    zoomTransitionTime = 1,
    zoomType = "set",
    zoomValue = 10,
    zoomMin = 5,
    zoomMax = 15,
    zoomTimeIsMax = false,

    viewNumber = 2,
    viewRestore = true,
    viewInstant = false,
    restoreDefaultViewNumber = 1,
  },

  rotation = {
    enabled = false,
    rotationType = "continuous",

    rotationTime = 1,
    rotationSpeed = 10,

    yawDegrees = 0,
    pitchDegrees = 0,

    rotateBack = true,
    rotateBackTime = 1,
  },

  hideUI = {
    enabled            = false,

    fadeOpacity        = 0.6,
    fadeOutTime        = 1,
    fadeInTime         = 1,

    emergencyShowEscEnabled = true,

    hideEntireUI       = false,
    keepFrameRate      = false,

    keepAlertFrames    = true,
    keepTooltip        = true,
    keepMinimap        = false,
    keepChatFrame      = false,
    keepPartyRaidFrame = false,
    keepTrackingBar    = false,
    keepEncounterBar   = false,

    keepCustomFrames   = false,
    customFramesToKeep = {
      ["AuctionHouseFrame"] = true,
      ["BankFrame"]         = true,
      ["BagnonBankFrame1"]  = true,
      ["BuffFrame"]         = true,
      ["ClassTrainerFrame"] = true,
      ["DebuffFrame"]       = true,
      ["GossipFrame"]       = true,
      ["MerchantFrame"]     = true,
      ["PetStableFrame"]    = true,
      ["QuestFrame"]        = true,
      ["StaticPopup1"]      = true,
      ["WardrobeFrame"]     = true,
    },

  },


  situationSettings = {
    cvars = {},
  },
}




DynamicCam.defaults = {
  profile = {

    -- Global settings.

    zoomRestoreSetting = "adaptive",
    reactiveZoomEnhancedMinZoom = true,
    settingsPanelIgnoreParentAlpha = true,

    -- Standard settings (for when no situation is overriding them).
    standardSettings = {

      reactiveZoomEnabled = true,
      reactiveZoomAddIncrementsAlways = 1,
      reactiveZoomAddIncrements = 2.5,
      reactiveZoomIncAddDifference = 1.2,
      reactiveZoomMaxZoomTime = 0.1,

      shoulderOffsetZoomEnabled = true,
      shoulderOffsetZoomLowerBound = 2,
      shoulderOffsetZoomUpperBound = 7,

      -- cvars
      cvars = {
        cameraDistanceMaxZoomFactor = tonumber(GetCVarDefault("cameraDistanceMaxZoomFactor")),
        cameraZoomSpeed = tonumber(GetCVarDefault("cameraZoomSpeed")),

        cameraYawMoveSpeed = tonumber(GetCVarDefault("cameraYawMoveSpeed")),
        cameraPitchMoveSpeed = tonumber(GetCVarDefault("cameraPitchMoveSpeed")),

        test_cameraOverShoulder = tonumber(GetCVarDefault("test_cameraOverShoulder")),

        test_cameraDynamicPitch = tonumber(GetCVarDefault("test_cameraDynamicPitch")),
        test_cameraDynamicPitchBaseFovPad = tonumber(GetCVarDefault("test_cameraDynamicPitchBaseFovPad")),
        test_cameraDynamicPitchBaseFovPadFlying = tonumber(GetCVarDefault("test_cameraDynamicPitchBaseFovPadFlying")),
        test_cameraDynamicPitchBaseFovPadDownScale = tonumber(GetCVarDefault("test_cameraDynamicPitchBaseFovPadDownScale")),
        test_cameraDynamicPitchSmartPivotCutoffDist = tonumber(GetCVarDefault("test_cameraDynamicPitchSmartPivotCutoffDist")),

        test_cameraTargetFocusEnemyEnable = tonumber(GetCVarDefault("test_cameraTargetFocusEnemyEnable")),
        test_cameraTargetFocusEnemyStrengthYaw = tonumber(GetCVarDefault("test_cameraTargetFocusEnemyStrengthYaw")),
        test_cameraTargetFocusEnemyStrengthPitch = tonumber(GetCVarDefault("test_cameraTargetFocusEnemyStrengthPitch")),
        test_cameraTargetFocusInteractEnable = tonumber(GetCVarDefault("test_cameraTargetFocusInteractEnable")),
        test_cameraTargetFocusInteractStrengthYaw = tonumber(GetCVarDefault("test_cameraTargetFocusInteractStrengthYaw")),
        test_cameraTargetFocusInteractStrengthPitch = tonumber(GetCVarDefault("test_cameraTargetFocusInteractStrengthPitch")),

        test_cameraHeadMovementStrength = tonumber(GetCVarDefault("test_cameraHeadMovementStrength")),
        test_cameraHeadMovementStandingStrength = tonumber(GetCVarDefault("test_cameraHeadMovementStandingStrength")),
        test_cameraHeadMovementStandingDampRate = tonumber(GetCVarDefault("test_cameraHeadMovementStandingDampRate")),
        test_cameraHeadMovementMovingStrength = tonumber(GetCVarDefault("test_cameraHeadMovementMovingStrength")),
        test_cameraHeadMovementMovingDampRate = tonumber(GetCVarDefault("test_cameraHeadMovementMovingDampRate")),
        test_cameraHeadMovementFirstPersonDampRate = tonumber(GetCVarDefault("test_cameraHeadMovementFirstPersonDampRate")),
        test_cameraHeadMovementRangeScale = tonumber(GetCVarDefault("test_cameraHeadMovementRangeScale")),
        test_cameraHeadMovementDeadZone = tonumber(GetCVarDefault("test_cameraHeadMovementDeadZone")),
      },

      -- Currently not changeable through UI.
      reactiveZoomEasingFunc = "OutQuad",
      easingZoom = "InOutQuad",
      easingYaw = "InOutQuad",
      easingPitch = "InOutQuad",

    },


    situations = {

      ["001"] = {
        name = "City",
        events = {"PLAYER_UPDATE_RESTING"},
        priority = 1,
        condition = "return IsResting()",
      },
      ["002"] = {
        name = "City - Indoors",
        events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "SPELL_UPDATE_USABLE"},
        priority = 11,
        condition = "return IsResting() and IsIndoors()",
      },
      ["004"] = {
        name = "World",
        events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_NEW_AREA"},
        priority = 0,
        condition = "return not IsResting() and not IsInInstance()",
      },
      ["005"] = {
        name = "World - Indoors",
        events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"},
        priority = 10,
        condition = "return not IsResting() and not IsInInstance() and IsIndoors()",
      },
      ["006"] = {
        name = "World - Combat",
        events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"},
        priority = 50,
        condition = "return not IsInInstance() and UnitAffectingCombat(\"player\")",
      },
      ["020"] = {
        name = "Dungeon/Scenerio",
        events = {"ZONE_CHANGED_NEW_AREA"},
        priority = 2,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and (instanceType == "party" or instanceType == "scenario")]],
      },
      ["021"] = {
        name = "Dungeon/Scenerio (Outdoors)",
        events = {"ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"},
        priority = 12,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and (instanceType == "party" or instanceType == "scenario") and IsOutdoors()]],
      },
      ["023"] = {
        name = "Dungeon/Scenerio (Combat, Boss)",
        events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_END", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"},
        priority = 302,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and (instanceType == "party" or instanceType == "scenario") and UnitAffectingCombat("player") and IsEncounterInProgress()]],
      },
      ["024"] = {
        name = "Dungeon/Scenerio (Combat, Trash)",
        events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_END", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"},
        priority = 202,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and (instanceType == "party" or instanceType == "scenario") and UnitAffectingCombat("player") and not IsEncounterInProgress()]],
      },
      ["030"] = {
        name = "Raid",
        events = {"ZONE_CHANGED_NEW_AREA"},
        priority = 3,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and instanceType == "raid"]],
      },
      ["031"] = {
        name = "Raid - Outdoors",
        events = {"ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"},
        priority = 13,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and instanceType == "raid" and IsOutdoors()]],
      },
      ["033"] = {
        name = "Raid - Combat - Boss",
        events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_END", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"},
        priority = 303,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and instanceType == "raid" and UnitAffectingCombat("player") and IsEncounterInProgress()]],
      },
      ["034"] = {
        name = "Raid - Combat - Trash",
        events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_END", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"},
        priority = 203,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and instanceType == "raid" and UnitAffectingCombat("player") and not IsEncounterInProgress()]],
      },
      ["050"] = {
        name = "Arena",
        events = {"ZONE_CHANGED_NEW_AREA"},
        priority = 3,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and instanceType == "arena"]],
      },
      ["051"] = {
        name = "Arena - Combat",
        events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"},
        priority = 203,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and instanceType == "arena" and UnitAffectingCombat("player")]],
      },
      ["060"] = {
        name = "Battleground",
        events = {"ZONE_CHANGED_NEW_AREA"},
        priority = 3,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and instanceType == "pvp"]],
      },
      ["061"] = {
        name = "Battleground - Combat",
        events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"},
        priority = 203,
        condition = [[local isInstance, instanceType = IsInInstance()
return isInstance and instanceType == "pvp" and UnitAffectingCombat("player")]],
      },
      ["100"] = {
        name = "Mounted",
        events = {"PLAYER_MOUNT_DISPLAY_CHANGED"},
        priority = 100,
        condition = "return IsMounted() and not UnitOnTaxi(\"player\")",
      },
      ["101"] = {
        name = "Taxi",
        events = {"PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED"},
        priority = 1000,
        condition = "return UnitOnTaxi(\"player\")",
      },
      ["102"] = {
        name = "Vehicle",
        events = {"UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE"},
        priority = 1000,
        condition = "return UnitUsingVehicle(\"player\")",
      },
      ["103"] = {
        name = "Druid Travel Form",
        events = {"UPDATE_SHAPESHIFT_FORM"},
        executeOnInit = [[this.travelFormIds = {
  [3] = true,  -- Travel
  [4] = true,  -- Aquatic
  [27] = true, -- Swift Flight
  [29] = true, -- Flight
}]],
        priority = 100,
        condition = [[local formId = GetShapeshiftFormID()
if formId and this.travelFormIds[formId] then
  return true
else
  return false
end]],
      },
      ["120"] = {
        name = "Dracthyr Soar",
        events = {"UNIT_AURA"},
        priority = 100,
        condition = [[for i = 1, 40 do
  local name, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
  if spellId == 369536 then return true end
end
return false]],
      },
      ["125"] = {
        name = "Dragonriding",
        events = {"PLAYER_MOUNT_DISPLAY_CHANGED"},
        executeOnInit = [[this.lastActiveMount = nil

this.IsCurrentMountForDragonriding = function()
  if this.lastActiveMount then
    local _, _, _, isActive, _, _, _, _, _, _, _, _, isForDragonriding = C_MountJournal.GetMountInfoByID(this.lastActiveMount)
    if isActive then
      return isForDragonriding
    end
  end

  for _, v in pairs (C_MountJournal.GetMountIDs()) do
    local _, _, _, isActive, _, _, _, _, _, _, _, _, isForDragonriding = C_MountJournal.GetMountInfoByID(v)
    if isActive then
      this.lastActiveMount = v
      return isForDragonriding
    end
  end

  return nil
end]],
        priority = 101,
        condition = [[return IsMounted() and this.IsCurrentMountForDragonriding()]],
      },
      ["126"] = {
        name = "Dragonriding (flying)",
        events = {"PLAYER_MOUNT_DISPLAY_CHANGED", "UNIT_AURA"},
        executeOnInit = [[this.lastActiveMount = nil

this.IsCurrentMountForDragonriding = function()
  if this.lastActiveMount then
    local _, _, _, isActive, _, _, _, _, _, _, _, _, isForDragonriding = C_MountJournal.GetMountInfoByID(this.lastActiveMount)
    if isActive then
      return isForDragonriding
    end
  end

  for _, v in pairs (C_MountJournal.GetMountIDs()) do
    local _, _, _, isActive, _, _, _, _, _, _, _, _, isForDragonriding = C_MountJournal.GetMountInfoByID(v)
    if isActive then
      this.lastActiveMount = v
      return isForDragonriding
    end
  end

  return nil
end]],
        priority = 102,
        condition = [[return IsMounted() and IsFlying() and this.IsCurrentMountForDragonriding()]],
      },
      ["200"] = {
        name = "Hearth/Teleport",
        events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTED"},
        executeOnInit = [[this.spells = {
     556,  -- Astral Recall
    3561,  -- Teleport: Stormwind
    3562,  -- Teleport: Ironforge
    3563,  -- Teleport: Undercity
    3565,  -- Teleport: Darnassus
    3566,  -- Teleport: Thunder Bluff
    3567,  -- Teleport: Orgrimmar
    8690,  -- Hearthstone
   32271,  -- Teleport: Exodar
   32272,  -- Teleport: Silvermoon
   33690,  -- Teleport: Shattrath
   35715,  -- Teleport: Shattrath
   49358,  -- Teleport: Stonard
   49359,  -- Teleport: Theramore
   49844,  -- Using Direbrew's Remote
   50977,  -- Death Gate
   53140,  -- Teleport: Dalaran - Northrend
   54406,  -- Teleport: Dalaran
   75136,  -- Ethereal Portal
   88342,  -- Teleport: Tol Barad
   88344,  -- Teleport: Tol Barad
   94719,  -- The Innkeeper's Daughter
  120145,  -- Ancient Teleport: Dalaran
  132621,  -- Teleport: Vale of Eternal Blossoms
  132627,  -- Teleport: Vale of Eternal Blossoms
  136508,  -- Dark Portal
  140295,  -- Kirin Tor Beacon
  168487,  -- Home Away from Home
  168499,  -- Home Away from Home
  171253,  -- Garrison Hearthstone
  176242,  -- Teleport: Warspear
  176248,  -- Teleport: Stormshield
  189838,  -- Teleport to Shipyard
  192084,  -- Jump to Skyhold
  192085,  -- Jump to Skyhold
  193669,  -- Basic Dimensional Rifting
  193753,  -- Dreamwalk
  193759,  -- Teleport: Hall of the Guardian
  196079,  -- Recall (to the sanctuary of Frostwolf Keep)
  196080,  -- Recall (to the sanctuary of Dun Baldar)
  216016,  -- Jump to Skyhold
  222695,  -- Dalaran Hearthstone
  223805,  -- Advanced Dimensional Rifting
  224869,  -- Teleport: Dalaran - Broken Isles
  225428,  -- Town Portal: Shala'nir
  225434,  -- Town Portal: Sashj'tar
  225435,  -- Town Portal: Kal'delar
  225440,  -- Town Portal: Lian'tril
  225436,  -- Town Portal: Faronaar
  227334,  -- Flight Master's Whistle
  231504,  -- [Tome of] Town Portal
  231505,  -- [Scroll of] Town Portal
  248906,  -- Vindicaar Teleport Beacon
  262100,  -- Recall (to your Great Hall)
  278244,  -- Greatfather Winter's Hearthstone
  278559,  -- Headless Horseman's Hearthstone
  281403,  -- Teleport: Boralus
  281404,  -- Teleport: Dazar'alor
  285362,  -- Lunar Elder's Hearthstone
  285424,  -- Peddlefeet's Lovely Hearthstone
  286031,  -- Noble Gardener's Hearthstone
  286331,  -- Fire Eater's Hearthstone
  286353,  -- Brewfest Reveler's Hearthstone
  292764,  -- Returning (BfA Quest)
  298068,  -- Holographic Digitalization Hearthstone
  308742,  -- Eternal Traveler's Hearthstone
  311643,  -- Hearth to Faol's Rest
  312372,  -- Return to Camp
  325624,  -- Cypher of Relocation
  326064,  -- Night Fae Hearthstone
  335671,  -- Scroll of Teleport: Theater of Pain
  340200,  -- Necrolord Hearthstone
  340767,  -- Chromie's Teleportation Scroll
  342122,  -- Venthyr Sinstone
  344587,  -- Teleport: Oribos
  345393,  -- Kyrian Hearthstone
  346167,  -- Attendant's Pocket Portal: Bastion
  346168,  -- Attendant's Pocket Portal: Oribos
  346170,  -- Attendant's Pocket Portal: Ardenweald
  346171,  -- Attendant's Pocket Portal: Maldraxxus
  346173,  -- Attendant's Pocket Portal: Revendreth
  363799,  -- Dominated Hearthstone
  367013,  -- Broker Translocation Matrix
  368788,  -- Hearth to Brill
  375357,  -- Timewalker's Hearthstone
  395277,  -- Teleport: Valdrakken
  398099,  -- Thrall's Hearthstone (Orc Heritage Campaign)
  410148,  -- Lost Dragonscale
  412555,  -- Path of the Naaru
  418549,  -- Teleporting to the Vindicaar

}]],
        priority = 130,
        condition = [[local name = UnitCastingInfo("player")
for _, v in pairs(this.spells) do
    local hearthName = GetSpellInfo(v)
    if hearthName and hearthName == name then
        return true
    end
end
return false]],
        executeOnEnter = [[local _, _, _, startTime, endTime = UnitCastingInfo("player")
this.transitionTime = (endTime - startTime)/1000
this.rotationTime = this.transitionTime]],
      },
      ["201"] = {
        name = "Annoying Spells",
        events = {"UNIT_AURA"},
        executeOnInit = [[this.buffs = {
   46924,  -- Bladestorm
   51690,  -- Killing Spree
  188499,  -- Blade Dance
  210152,  -- Death Sweep
}
]],
        priority = 1000,
        condition = [[for _, v in pairs(this.buffs) do
    local name = GetSpellInfo(v)
    if name and AuraUtil.FindAuraByName(name, "player", "HELPFUL") then
        return true
    end
end
return false]],
      },
      ["300"] = {
        name = "NPC Interaction",
        events = {"AUCTION_HOUSE_CLOSED", "AUCTION_HOUSE_SHOW", "BANKFRAME_CLOSED", "BANKFRAME_OPENED", "CLOSE_TABARD_FRAME", "GOSSIP_CLOSED", "GOSSIP_SHOW", "GUILD_REGISTRAR_CLOSED", "GUILD_REGISTRAR_SHOW", "MERCHANT_CLOSED", "MERCHANT_SHOW", "OPEN_TABARD_FRAME", "PET_STABLE_CLOSED", "PET_STABLE_SHOW", "PLAYER_INTERACTION_MANAGER_FRAME_HIDE", "PLAYER_INTERACTION_MANAGER_FRAME_SHOW", "PLAYER_TARGET_CHANGED", "QUEST_COMPLETE", "QUEST_DETAIL", "QUEST_FINISHED", "QUEST_GREETING", "QUEST_PROGRESS", "SHIPMENT_CRAFTER_CLOSED", "SHIPMENT_CRAFTER_OPENED", "TRAINER_CLOSED", "TRAINER_SHOW", "TRANSMOGRIFY_CLOSE", "TRANSMOGRIFY_OPEN"},
        executeOnInit = [[this.frames = {"AuctionHouseFrame", "BagnonBankFrame1", "BankFrame", "ClassTrainerFrame", "GarrisonCapacitiveDisplayFrame", "GossipFrame", "GuildRegistrarFrame", "ImmersionFrame", "MerchantFrame", "PetStableFrame", "QuestFrame", "TabardFrame", "WardrobeFrame"}

this.excludedFrames = {"FlightMapFrame"}

this.mountVendors = {
  ["62821"] = 460, -- Grand Expedition Yak
  ["62822"] = 460, -- Grand Expedition Yak
  -- Add more npcId and mountId pairs here.
  -- To find them, uncomment print command in condition script.
}

function this:GetCurrentMount()
  if this.lastMount then
    local _, _, _, active = C_MountJournal.GetMountInfoByID(this.lastMount)
    if active then
      return this.lastMount
    end
  end
  for _, v in pairs(C_MountJournal.GetMountIDs()) do
    local _, _, _, active = C_MountJournal.GetMountInfoByID(v)
    if active then
      this.lastMount = v
      return v
    end
  end
  return nil
end]],
        priority = 110,
        condition = [[-- Don't want to apply this to my own mount vendors while mounted.
if IsMounted() then
  if UnitGUID("npc") then
    local _, _, _, _, _, npcId = strsplit("-", UnitGUID("npc"))
    -- Uncomment this to find out npcId and mountId pairs.
    -- print("Current npc", npcId, "current mount", this:GetCurrentMount())
    if this.mountVendors[npcId] and this.mountVendors[npcId] == this:GetCurrentMount() then
      return false
    end
  end
end

local shown = false
for _, v in pairs(this.frames) do
  if (_G[v] and _G[v]:IsShown()) then
    shown = true
    break
  end
end

for _, v in pairs(this.excludedFrames) do
  if (_G[v] and _G[v]:IsShown()) then
    shown = false
    break
  end
end

return shown and UnitExists("npc")]],
      },
      ["301"] = {
        name = "Mailbox",
        events = {"MAIL_SHOW", "PLAYER_INTERACTION_MANAGER_FRAME_SHOW", "PLAYER_INTERACTION_MANAGER_FRAME_HIDE", "MAIL_CLOSED", "GOSSIP_CLOSED"},
        priority = 110,
        condition = "return MailFrame and MailFrame:IsShown()",
      },
      ["302"] = {
        name = "Fishing",
        events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTED"},
        priority = 20,
        condition = "return UnitChannelInfo(\"player\") == GetSpellInfo(7620)",
        delay = 1,
      },
      ["320"] = {
        name = "Gathering",
        events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTED"},
        executeOnInit = [[this.spells = {
      10768,  -- Skinning
     265819,  -- Herb Gathering
     366260,  -- Mining

}]],
        priority = 120,
        condition = [[local name, _, _, _, _, _, _, _, spellId  = UnitCastingInfo("player")
-- Uncomment this to find out more spell IDs.
-- print(name, spellId)
for _, v in pairs(this.spells) do
    gatheringName = GetSpellInfo(v)
    if gatheringName and gatheringName == name then
        return true
    end
end
return false]]
      },
      ["303"] = {
        name = "AFK",
        events = {"PLAYER_FLAGS_CHANGED"},
        priority = 120,
        condition = "return UnitIsAFK(\"player\")",
      },
      ["310"] = {
        name = "Pet Battle",
        events = {"PET_BATTLE_OPENING_START", "PET_BATTLE_CLOSE"},
        priority = 130,
        condition = "return C_PetBattles.IsInBattle()",
      },
    },

  },
}


-- Special modifications for classic.
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then

  -- No pet battles before mists.
  DynamicCam.defaults.profile.situations["310"] = nil


  -- No dragonriding or Dracthyr before Dragonflight.
  DynamicCam.defaults.profile.situations["120"] = nil
  DynamicCam.defaults.profile.situations["125"] = nil
  DynamicCam.defaults.profile.situations["126"] = nil


  if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then

    -- Cannot have SHIPMENT_CRAFTER_CLOSED, SHIPMENT_CRAFTER_OPENED, TRANSMOGRIFY_CLOSE, TRANSMOGRIFY_OPEN.
    -- In classic also not PLAYER_INTERACTION_MANAGER_FRAME_HIDE and PLAYER_INTERACTION_MANAGER_FRAME_SHOW.
    DynamicCam.defaults.profile.situations["300"].events = {"AUCTION_HOUSE_CLOSED", "AUCTION_HOUSE_SHOW", "BANKFRAME_CLOSED", "BANKFRAME_OPENED", "CLOSE_TABARD_FRAME", "GOSSIP_CLOSED", "GOSSIP_SHOW", "GUILD_REGISTRAR_CLOSED", "GUILD_REGISTRAR_SHOW", "MERCHANT_CLOSED", "MERCHANT_SHOW", "OPEN_TABARD_FRAME", "PET_STABLE_CLOSED", "PET_STABLE_SHOW", "PLAYER_TARGET_CHANGED", "QUEST_COMPLETE", "QUEST_DETAIL", "QUEST_FINISHED", "QUEST_GREETING", "QUEST_PROGRESS", "TRAINER_CLOSED", "TRAINER_SHOW", "TAXIMAP_OPENED", "TAXIMAP_CLOSED"}

    DynamicCam.defaults.profile.situations["301"].events = {"MAIL_SHOW", "MAIL_CLOSED", "GOSSIP_CLOSED"}

    -- No vehicles before wrath.
    DynamicCam.defaults.profile.situations["102"] = nil

  else

    -- Cannot have "SHIPMENT_CRAFTER_CLOSED", "SHIPMENT_CRAFTER_OPENED", "TRANSMOGRIFY_CLOSE", "TRANSMOGRIFY_OPEN
    DynamicCam.defaults.profile.situations["300"].events = {"AUCTION_HOUSE_CLOSED", "AUCTION_HOUSE_SHOW", "BANKFRAME_CLOSED", "BANKFRAME_OPENED", "CLOSE_TABARD_FRAME", "GOSSIP_CLOSED", "GOSSIP_SHOW", "GUILD_REGISTRAR_CLOSED", "GUILD_REGISTRAR_SHOW", "MERCHANT_CLOSED", "MERCHANT_SHOW", "OPEN_TABARD_FRAME", "PET_STABLE_CLOSED", "PET_STABLE_SHOW", "PLAYER_INTERACTION_MANAGER_FRAME_HIDE", "PLAYER_INTERACTION_MANAGER_FRAME_SHOW", "PLAYER_TARGET_CHANGED", "QUEST_COMPLETE", "QUEST_DETAIL", "QUEST_FINISHED", "QUEST_GREETING", "QUEST_PROGRESS", "TRAINER_CLOSED", "TRAINER_SHOW"}

  end

end




-- Copy the defaults into each situation.
for _, situation in pairs(DynamicCam.defaults.profile.situations) do
  for k, v in pairs(DynamicCam.situationDefaults) do
    -- But only if the situation does not have a custom setting.
    if not situation[k] then
      situation[k] = v
    end
  end
end




-- With DC 2.0, some default values changed. As AceDB does not store default values,
-- non-existent entries may have to be set to the old default when modernizing a profile.
DynamicCam.oldDefaults = {

  shoulderOffsetZoom = {
    enabled = true,
    lowerBound = 2,
    upperBound = 8,
  },

  reactiveZoom = {
    enabled = false,
    addIncrementsAlways = 1,
    addIncrements = 3,
    maxZoomTime = .25,
    incAddDifference = 4,
  },

  defaultCvars = {
    cameraDistanceMaxZoomFactor = 2.6,
    cameraZoomSpeed = 20,

    test_cameraOverShoulder = 0,

    test_cameraDynamicPitch = 0,
    test_cameraDynamicPitchBaseFovPad = .35,
    test_cameraDynamicPitchBaseFovPadFlying = .75,
    test_cameraDynamicPitchBaseFovPadDownScale = .25,
    test_cameraDynamicPitchSmartPivotCutoffDist = 10,

    test_cameraTargetFocusEnemyEnable = 0,
    test_cameraTargetFocusEnemyStrengthYaw = 0.5,
    test_cameraTargetFocusEnemyStrengthPitch = 0.4,
    test_cameraTargetFocusInteractEnable = 0,
    test_cameraTargetFocusInteractStrengthYaw = 1.0,
    test_cameraTargetFocusInteractStrengthPitch = 0.75,

    test_cameraHeadMovementStrength = 0,
    test_cameraHeadMovementStandingStrength = 0.3,
    test_cameraHeadMovementStandingDampRate = 10,
    test_cameraHeadMovementMovingStrength = 0.5,
    test_cameraHeadMovementMovingDampRate = 10,
    test_cameraHeadMovementFirstPersonDampRate = 20,
    test_cameraHeadMovementRangeScale = 5,
    test_cameraHeadMovementDeadZone = 0.015,
  },

  situations = {

    enabled = true,

    cameraActions = {
      transitionTime = 0.75,
      timeIsMax = true,

      rotate = false,
      rotateSetting = "continuous",
      rotateSpeed = 20,
      yawDegrees = 0,
      pitchDegrees = 0,
      rotateBack = false,

      zoomSetting = "off",
      zoomValue = 10,
      zoomMin = 5,
      zoomMax = 15,
    },
    view = {
      enabled = false,
      viewNumber = 5,
      restoreView = false,
      instant = false,
    },
    extras = {
      hideUI = false,
      hideUIFadeOpacity = 0,
      actuallyHideUI = true,
      keepMinimap = false,
    },
  },

  -- AFK was the only situation in DC pre-2.0 that had other defaults.
  afkSituation = {
    cameraActions = {
      transitionTime = 1,
      rotateSpeed = 3,
      zoomValue = 9,
      rotate = true,
      zoomSetting = "out",
    },
    extras = {
      hideUI = true,
    },

  }

}

