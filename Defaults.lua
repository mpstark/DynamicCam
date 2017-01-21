
-- TODO: add to another file
-- TODO: have multiple defaults
-- function DynamicCam:GetDefaultSituations()
--     local situations = {};
--     local newSituation;

--     newSituation = self:CreateSituation("City");
--     newSituation.priority = 1;
--     newSituation.condition = "return IsResting();";
--     newSituation.events = {"PLAYER_UPDATE_RESTING"};
--     newSituation.cameraActions.zoomSetting = "range";
--     newSituation.cameraActions.zoomMin = 10;
--     newSituation.cameraActions.zoomMax = 20;
--     situations["001"] = newSituation;

--     newSituation = self:CreateSituation("City (Indoors)");
--     newSituation.priority = 11;
--     newSituation.condition = "return IsResting() and IsIndoors();";
--     newSituation.events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "SPELL_UPDATE_USABLE"};
--     newSituation.cameraActions.zoomSetting = "in";
--     newSituation.cameraActions.zoomValue = 8;
--     situations["002"] = newSituation;

--     newSituation = self:CreateSituation("World");
--     newSituation.priority = 0;
--     newSituation.condition = "return not IsResting() and not IsInInstance();";
--     newSituation.events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_NEW_AREA"};
--     newSituation.cameraActions.zoomSetting = "range";
--     newSituation.cameraActions.zoomMin = 15;
--     newSituation.cameraActions.zoomMax = 20;
--     situations["004"] = newSituation;

--     newSituation = self:CreateSituation("World (Indoors)");
--     newSituation.priority = 10;
--     newSituation.condition = "return not IsResting() and not IsInInstance() and IsIndoors();";
--     newSituation.events = {"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"};
--     newSituation.cameraActions.zoomSetting = "in";
--     newSituation.cameraActions.zoomValue = 10;
--     situations["005"] = newSituation;

--     newSituation = self:CreateSituation("World (Combat)");
--     newSituation.priority = 50;
--     newSituation.condition = "return not IsInInstance() and UnitAffectingCombat(\"player\");";
--     newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"};
--     newSituation.cameraActions.zoomSetting = "fit";
--     newSituation.cameraActions.zoomFitUseCurAsMin = true;
--     newSituation.cameraActions.zoomMin = 5;
--     newSituation.cameraActions.zoomMax = 35;
--     newSituation.targetLock.enabled = true;
--     newSituation.targetLock.nameplateVisible = true;
--     situations["006"] = newSituation;

--     newSituation = self:CreateSituation("Dungeon");
--     newSituation.enabled = false;
--     newSituation.priority = 2;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\");";
--     newSituation.events = {"ZONE_CHANGED_NEW_AREA"};
--     situations["020"] = newSituation;

--     newSituation = self:CreateSituation("Dungeon (Outdoors)");
--     newSituation.enabled = false;
--     newSituation.priority = 12;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\") and IsOutdoors();";
--     newSituation.events = {"ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"};
--     situations["021"] = newSituation;

--     newSituation = self:CreateSituation("Dungeon (Combat, Boss)");
--     newSituation.enabled = false;
--     newSituation.priority = 302;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\") and UnitAffectingCombat(\"player\") and IsEncounterInProgress();";
--     newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_STOP", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"};
--     situations["023"] = newSituation;

--     newSituation = self:CreateSituation("Dungeon (Combat, Trash)");
--     newSituation.enabled = false;
--     newSituation.priority = 202;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"party\") and UnitAffectingCombat(\"player\") and not IsEncounterInProgress();";
--     newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_STOP", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"};
--     situations["024"] = newSituation;



--     newSituation = self:CreateSituation("Raid");
--     newSituation.enabled = false;
--     newSituation.priority = 3;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\");";
--     newSituation.events = {"ZONE_CHANGED_NEW_AREA"};
--     situations["030"] = newSituation;

--     newSituation = self:CreateSituation("Raid (Outdoors)");
--     newSituation.enabled = false;
--     newSituation.priority = 13;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and IsOutdoors();";
--     newSituation.events = {"ZONE_CHANGED_INDOORS", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "SPELL_UPDATE_USABLE"};
--     situations["031"] = newSituation;

--     newSituation = self:CreateSituation("Raid (Combat, Boss)");
--     newSituation.enabled = false;
--     newSituation.priority = 303;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and UnitAffectingCombat(\"player\") and IsEncounterInProgress();";
--     newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_STOP", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"};
--     situations["033"] = newSituation;

--     newSituation = self:CreateSituation("Raid (Combat, Trash)");
--     newSituation.enabled = false;
--     newSituation.priority = 203;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"raid\") and UnitAffectingCombat(\"player\") and not IsEncounterInProgress();";
--     newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_STOP", "INSTANCE_ENCOUNTER_ENGAGE_UNIT"};
--     situations["034"] = newSituation;



--     newSituation = self:CreateSituation("Arena");
--     newSituation.enabled = false;
--     newSituation.priority = 3;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"arena\");";
--     newSituation.events = {"ZONE_CHANGED_NEW_AREA"};
--     situations["050"] = newSituation;

--     newSituation = self:CreateSituation("Arena (Combat)");
--     newSituation.enabled = false;
--     newSituation.priority = 203;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"arena\") and UnitAffectingCombat(\"player\");";
--     newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"};
--     situations["051"] = newSituation;


--     newSituation = self:CreateSituation("Battleground");
--     newSituation.enabled = false;
--     newSituation.priority = 3;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"pvp\");";
--     newSituation.events = {"ZONE_CHANGED_NEW_AREA"};
--     situations["060"] = newSituation;

--     newSituation = self:CreateSituation("Battleground (Combat)");
--     newSituation.enabled = false;
--     newSituation.priority = 203;
--     newSituation.condition = "local isInstance, instanceType = IsInInstance(); return (isInstance and instanceType == \"pvp\") and UnitAffectingCombat(\"player\");";
--     newSituation.events = {"PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA"};
--     situations["061"] = newSituation;


--     newSituation = self:CreateSituation("Mounted");
--     newSituation.priority = 100;
--     newSituation.condition = "return IsMounted();";
--     newSituation.events = {"SPELL_UPDATE_USABLE", "UNIT_AURA"};
--     newSituation.cameraActions.zoomSetting = "out";
--     newSituation.cameraActions.zoomValue = 30;
--     newSituation.cameraCVars["test_cameraDynamicPitch"] = 0;
--     newSituation.cameraCVars["test_cameraOverShoulder"] = 0;
--     newSituation.cameraCVars["test_cameraHeadMovementStrength"] = 0;
--     situations["100"] = newSituation;

--     newSituation = self:CreateSituation("Taxi");
--     newSituation.priority = 1000;
--     newSituation.condition = "return UnitOnTaxi(\"player\");";
--     newSituation.events = {"PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED"};
--     newSituation.cameraActions.zoomSetting = "set";
--     newSituation.cameraActions.zoomValue = 15;
--     newSituation.cameraCVars["test_cameraOverShoulder"] = -1;
--     newSituation.cameraCVars["test_cameraHeadMovementStrength"] = 0;
--     newSituation.extras.hideUI = true;
--     situations["101"] = newSituation;

--     newSituation = self:CreateSituation("Vehicle");
--     newSituation.priority = 1000;
--     newSituation.condition = "return UnitUsingVehicle(\"player\");";
--     newSituation.events = {"UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE"};
--     newSituation.cameraCVars["test_cameraOverShoulder"] = 0;
--     newSituation.cameraCVars["test_cameraHeadMovementStrength"] = 0;
--     newSituation.cameraCVars["test_cameraDynamicPitch"] = 0;
--     situations["102"] = newSituation;

--     newSituation = self:CreateSituation("Hearth/Teleport");
--     newSituation.priority = 20;
--     newSituation.executeOnInit = "this.spells = {136508, 189838, 54406, 94719, 556, 168487, 168499, 171253, 50977, 8690, 222695, 171253, 224869, 53140, 3565, 32271, 193759, 3562, 3567, 33690, 35715, 32272, 49358, 176248, 3561, 49359, 3566, 88342, 88344, 3563, 132627, 132621, 176242, 192085, 192084, 216016};";
--     newSituation.condition = [[for k,v in pairs(this.spells) do 
--     if (UnitCastingInfo("player") == GetSpellInfo(v)) then 
--         return true;
--     end
-- end
-- return false;]];
--     newSituation.executeOnEnter = "local _, _, _, _, startTime, endTime = UnitCastingInfo(\"player\");\nthis.transitionTime = ((endTime - startTime)/1000) - .25;";
--     newSituation.events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTED"};
--     newSituation.cameraActions.zoomSetting = "in";
--     newSituation.cameraActions.zoomValue = 4;
--     newSituation.cameraActions.rotate = true;
--     newSituation.cameraActions.rotateDegrees = 360;
--     newSituation.cameraActions.rotateSetting = "degrees";
--     newSituation.cameraActions.transitionTime = 10;
--     newSituation.cameraActions.timeIsMax = false;
--     newSituation.cameraCVars["test_cameraDynamicPitch"] = 0;
--     newSituation.cameraCVars["test_cameraOverShoulder"] = 0;
--     newSituation.cameraCVars["test_cameraHeadMovementStrength"] = 0;
--     newSituation.extras.hideUI = true;
--     situations["200"] = newSituation;

--     newSituation = self:CreateSituation("Annoying Spells");
--     newSituation.priority = 1000;
--     newSituation.executeOnInit = "this.buffs = {46924, 51690, 188499, 210152};";
--     newSituation.condition = [[for k,v in pairs(this.buffs) do 
--     if (UnitBuff("player", GetSpellInfo(v))) then
--         return true;
--     end
-- end
-- return false;]];
--     newSituation.events = {"UNIT_AURA"};
--     newSituation.cameraCVars["test_cameraHeadMovementStrength"] = 0;
--     newSituation.cameraCVars["test_cameraDynamicPitch"] = 0;
--     newSituation.cameraCVars["test_cameraOverShoulder"] = 0;
--     situations["201"] = newSituation;

--     newSituation = self:CreateSituation("NPC Interaction");
--     newSituation.enabled = false;
--     newSituation.priority = 20;
--     newSituation.delay = .5;
--     newSituation.executeOnInit = "this.frames = {\"GarrisonCapacitiveDisplayFrame\", \"BankFrame\", \"MerchantFrame\", \"GossipFrame\", \"ClassTrainerFrame\", \"QuestFrame\",}";
--     newSituation.condition = [[local shown = false;
-- for k,v in pairs(this.frames) do
--     if (_G[v] and _G[v]:IsShown()) then
--         shown = true;
--     end
-- end
-- return UnitExists("npc") and UnitIsUnit("npc", "target") and shown;]];
--     newSituation.events = {"PLAYER_TARGET_CHANGED", "GOSSIP_SHOW", "GOSSIP_CLOSED", "QUEST_COMPLETE", "QUEST_DETAIL", "QUEST_FINISHED", "QUEST_GREETING", "BANKFRAME_OPENED", "BANKFRAME_CLOSED", "MERCHANT_SHOW", "MERCHANT_CLOSED", "TRAINER_SHOW", "TRAINER_CLOSED", "SHIPMENT_CRAFTER_OPENED", "SHIPMENT_CRAFTER_CLOSED"};
--     newSituation.cameraActions.zoomSetting = "fit";
--     newSituation.cameraActions.zoomMin = 3;
--     newSituation.cameraActions.zoomMax = 30;
--     newSituation.cameraActions.zoomValue = 4;
--     newSituation.cameraActions.zoomFitIncrements = .5;
--     newSituation.cameraActions.zoomFitPosition = 90;
--     newSituation.cameraActions.zoomFitToggleNameplate = true;
--     newSituation.cameraCVars["test_cameraDynamicPitch"] = 1;
--     newSituation.targetLock.enabled = true;
--     newSituation.targetLock.onlyAttackable = false;
--     newSituation.targetLock.nameplateVisible = false;
--     situations["300"] = newSituation;

--     newSituation = self:CreateSituation("Mailbox");
--     newSituation.enabled = false;
--     newSituation.priority = 20;
--     newSituation.condition = "return (MailFrame and MailFrame:IsShown())";
--     newSituation.events = {"MAIL_CLOSED", "MAIL_SHOW", "GOSSIP_CLOSED"};
--     newSituation.cameraActions.zoomSetting = "in";
--     newSituation.cameraActions.zoomValue = 4;
--     situations["301"] = newSituation;

--     newSituation = self:CreateSituation("Fishing");
--     newSituation.priority = 20;
--     newSituation.condition = "return (UnitChannelInfo(\"player\") == GetSpellInfo(7620))";
--     newSituation.events = {"UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_INTERRUPTED"};
--     newSituation.delay = 2;
--     newSituation.cameraActions.zoomSetting = "set";
--     newSituation.cameraActions.zoomValue = 7;
--     newSituation.cameraCVars["test_cameraDynamicPitch"] = 1;
--     situations["302"] = newSituation;

--     return situations;
-- end

