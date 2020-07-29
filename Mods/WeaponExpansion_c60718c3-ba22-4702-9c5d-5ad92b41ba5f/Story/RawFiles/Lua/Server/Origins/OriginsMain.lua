Mercs = {
	-- S_Player_LLWEAPONEX_Harken_e446752a-13cc-4a88-a32e-5df244c90d8b
	Harken = "e446752a-13cc-4a88-a32e-5df244c90d8b",
	-- S_Player_LLWEAPONEX_Korvash_3f20ae14-5339-4913-98f1-24476861ebd6
	Korvash = "3f20ae14-5339-4913-98f1-24476861ebd6",
}

local function SetupOriginSkills(char, skillset)
	if CharacterHasSkill(char, "Dome_CircleOfProtection") == 1 then
		CharacterRemoveSkill(char, "Dome_CircleOfProtection")
	end

	for i,skill in pairs(Ext.GetSkillSet(skillset)) do
		if CharacterHasSkill(char, skill) == 0 then
			CharacterAddSkill(char, skill, 0)
		end		
	end
end

function Origins_InitCharacters(region, isEditorMode)
	pcall(SetupOriginSkills, Mercs.Harken, "Avatar_LLWEAPONEX_Harken")
	pcall(SetupOriginSkills, Mercs.Korvash, "Avatar_LLWEAPONEX_Korvash")
	CharacterRemoveSkill(Mercs.Korvash, "Cone_Flamebreath")
	CharacterAddSkill(Mercs.Korvash, "Cone_LLWEAPONEX_DarkFlamebreath", 0)

	if Ext.IsDeveloperMode() then
		isEditorMode = 1
	end

	--IsCharacterCreationLevel(region) == 0
	if CharacterIsPlayer(Mercs.Harken) == 0 then
		if isEditorMode == 1 then
			CharacterAddAbility(Mercs.Harken, "WarriorLore", 1)
			CharacterAddAbility(Mercs.Harken, "TwoHanded", 1)
			CharacterAddAbility(Mercs.Harken, "Barter", 1)
			LeaderLib.Data.Presets.Preview.Knight:ApplyToCharacter(Mercs.Harken, "Uncommon", {"Weapon", "Helmet", "Breast", "Gloves"})
		end
		Uniques.AnvilMace:Transfer(Mercs.Harken, true)
		Uniques.HarkenPowerGloves:Transfer(Mercs.Harken, true)
		ObjectSetFlag(Mercs.Harken, "LLWEAPONEX_FixSkillBar", 0)
	end
	
	if CharacterIsPlayer(Mercs.Korvash) == 0 then
		if isEditorMode == 1 then
			CharacterAddAbility(Mercs.Korvash, "WarriorLore", 1)
			CharacterAddAbility(Mercs.Korvash, "Necromancy", 1)
			CharacterAddAbility(Mercs.Korvash, "Telekinesis", 1)
			CharacterAddTalent(Mercs.Korvash, "Executioner")
			LeaderLib.Data.Presets.Preview.LLWEAPONEX_Reaper:ApplyToCharacter(Mercs.Korvash, "Uncommon", {"Weapon", "Helmet", "Gloves"})
			--Mods.LeaderLib.Data.Presets.Preview.Inquisitor:ApplyToCharacter("3f20ae14-5339-4913-98f1-24476861ebd6", "Uncommon", {"Weapon", "Helmet"})
			--Mods.LeaderLib.Data.Presets.Preview.LLWEAPONEX_Reaper:ApplyToCharacter("3f20ae14-5339-4913-98f1-24476861ebd6", "Uncommon", {"Weapon", "Helmet"})
		end
		Uniques.DeathEdge:Transfer(Mercs.Korvash, true)
		Uniques.DemonGauntlet:Transfer(Mercs.Korvash, true)
		ObjectSetFlag(Mercs.Korvash, "LLWEAPONEX_FixSkillBar", 0)
	end

	if Ext.IsDeveloperMode() or isEditorMode == 1 then
		local totalAdded = 0
		local host = GetUUID(CharacterGetHostCharacter())
		if CharacterIsInPartyWith(host, Mercs.Harken) == 0 then
			Osi.PROC_GLO_PartyMembers_Add(Mercs.Harken, host)
			CharacterAddAttributePoint(Mercs.Harken, 2)
			TeleportTo(Mercs.Harken, host, "", 1, 0, 1)
			totalAdded = totalAdded + 1
		end
		if CharacterIsInPartyWith(host, Mercs.Korvash) == 0 then
			Osi.PROC_GLO_PartyMembers_Add(Mercs.Korvash, host)
			CharacterAddAttributePoint(Mercs.Korvash, 2)
			TeleportTo(Mercs.Korvash, host, "", 1, 0, 1)
			totalAdded = totalAdded + 1
		end
		local frozenCount = Osi.DB_GlobalCounter:Get("FTJ_PlayersWokenUp", nil)
		if frozenCount ~= nil and #frozenCount > 0 then
			local count = frozenCount[1][2]
			Osi.DB_GlobalCounter:Delete("FTJ_PlayersWokenUp", count)
			Osi.DB_GlobalCounter("FTJ_PlayersWokenUp", count + totalAdded)
		end
	end
end

Ext.RegisterOsirisListener("CharacterJoinedParty", 1, "after", function(partyMember)
	if ObjectGetFlag(partyMember, "LLWEAPONEX_FixSkillBar") == 1 then
		ObjectClearFlag(partyMember, "LLWEAPONEX_FixSkillBar")
		for i=0,64,1 do
			local slot = NRD_SkillBarGetItem(partyMember, i)
			if not StringHelpers.IsNullOrEmpty(slot) then
				NRD_SkillBarClear(partyMember, i)
			end
		end
		-- local slot = 0
		-- for i,skill in pairs(Ext.GetCharacter(partyMember):GetSkills()) do
		-- 	NRD_SkillBarSetSkill(partyMember, slot, skill)
		-- 	slot = slot + 1
		-- end
	end
end)


local anvilSwapPresets = {
	Knight = true,
	Inquisitor = true,
	Berserker = true,
	Barbarian = true,
}

function CC_CheckKorvashColor(player)
	if Ext.IsDeveloperMode() then
		local character = Ext.GetCharacter(player)
		local color = character.PlayerCustomData.SkinColor
		if color == 4294902015 then-- Pink?
			NRD_PlayerSetCustomDataInt(player, "SkinColor", 4281936940)
			Ext.EnableExperimentalPropertyWrites()
			character.PlayerCustomData.SkinColor = 4281936940
			Ext.PostMessageToClient(player, "LLWEAPONEX_FixLizardSkin", player)
		end
	end
end

function CC_SwapToHarkenAnvilPreview(player, preset)
	if anvilSwapPresets[preset] == true then
		local weapon = CharacterGetEquippedWeapon(player)
		ItemRemove(weapon)
		NRD_ItemConstructBegin("85e2e75e-4333-425e-adc4-94474c3fc201")
		NRD_ItemCloneSetString("GenerationStatsId", "WPN_UNIQUE_LLWEAPONEX_Anvil_Mace_2H_A_Preview")
		NRD_ItemCloneSetString("StatsEntryName", "WPN_UNIQUE_LLWEAPONEX_Anvil_Mace_2H_A_Preview")
		NRD_ItemCloneSetInt("HasGeneratedStats", 0)
		NRD_ItemCloneSetInt("GenerationLevel", 1)
		NRD_ItemCloneSetInt("StatsLevel", 1)
		NRD_ItemCloneSetInt("IsIdentified", 1)
		local item = NRD_ItemClone()
		NRD_CharacterEquipItem(player, item, "Weapon", 0, 0, 0, 1)
	end
end

---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData HitData
local function ClearOriginSkillRequiredTag(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		ClearTag(char, "LLWEAPONEX_EnemyDiedInCombat")
	end
end
LeaderLib.RegisterSkillListener("Shout_LLWEAPONEX_UnrelentingRage", ClearOriginSkillRequiredTag)


---@param skill string
---@param char string
---@param state SKILL_STATE PREPARE|USED|CAST|HIT
---@param skillData HitData
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_DarkFireball", function(skill, char, state, skillData)
	if state == SKILL_STATE.CAST then
		PersistentVars.SkillData.DarkFireballCount = 0
		UpdateDarkFireballSkill()
		SyncVars()
	end
end)

function UpdateDarkFireballSkill()
	local killCount = PersistentVars.SkillData.DarkFireballCount or 0
	if killCount >= 1 then
		local rangeBonusMult = Ext.ExtraData["LLWEAPONEX_DarkFireball_RangePerCount"] or 1.0
		local radiusBonusMult = Ext.ExtraData["LLWEAPONEX_DarkFireball_ExplosionRadiusPerCount"] or 0.4
	
		local nextRange = math.min(16, math.floor(6 + (rangeBonusMult * killCount)))
		local nextRadius = math.min(8, math.floor(1 + (radiusBonusMult * killCount)))
	
		local stat = Ext.GetStat("Projectile_LLWEAPONEX_DarkFireball")
		stat.TargetRadius = nextRange
		stat.AreaRadius = nextRadius
		stat.ExplodeRadius = nextRadius

		if killCount >= 5 then
			stat.Template = "9bdb7e9c-02ce-4f2f-9e7b-463e3771af9c"
		end

		Ext.SyncStat("Projectile_LLWEAPONEX_DarkFireball", true)
	else
		local stat = Ext.GetStat("Projectile_LLWEAPONEX_DarkFireball")
		stat.TargetRadius = 6
		stat.AreaRadius = 1
		stat.ExplodeRadius = 1
		stat.Template = "f3af4ac9-567c-4ac8-8976-ec9c7bc8260d"
		Ext.SyncStat("Projectile_LLWEAPONEX_DarkFireball", true)
	end
end

Ext.RegisterConsoleCommand("llweaponex_darkfireballtest", function(call, amount)
	PersistentVars.SkillData.DarkFireballCount = tonumber(amount)
	UpdateDarkFireballSkill()
	SyncVars()
end)