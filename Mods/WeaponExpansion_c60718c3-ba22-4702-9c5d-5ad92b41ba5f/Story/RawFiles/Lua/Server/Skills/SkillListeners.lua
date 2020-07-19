SKILL_STATE = LeaderLib.SKILL_STATE

---@param char string
---@param state SkillState
---@param data SkillEventData
local function AimedShotBonuses(char, state, data)
	if state == SKILL_STATE.PREPARE then
		--ApplyStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY", -1.0, 0, char)
		--Mods.LeaderLib.StartTimer("Timers_LLWEAPONEX_AimedShot_RemoveAccuracyBonus", 1000, char)
	elseif state == SKILL_STATE.USED then
		if HasActiveStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY") == 0 then
			ApplyStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY", 12.0, 1, char)
		end
		data:ForEach(function(target)
			if HasActiveStatus(target, "MARKED") == 1 then
				ApplyStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_CRITICAL", 12.0, 1, char)
			end
		end)
	elseif state == SKILL_STATE.CAST then
		Osi.LeaderLib_Timers_StartObjectTimer(char, 1500, "Timers_LLWEAPONEX_Rifle_AimedShot_ClearBonuses", "LLWEAPONEX_Rifle_AimedShot_ClearBonuses")
	elseif state == SKILL_STATE.HIT then
		Osi.LeaderLib_Timers_CancelObjectObjectTimer(char, "Timers_LLWEAPONEX_Rifle_AimedShot_ClearBonuses")
		SetStoryEvent(char, "LLWEAPONEX_Rifle_AimedShot_ClearBonuses")
	end
end
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_Rifle_AimedShot", AimedShotBonuses)

---@param char string
---@param state SkillState
---@param data SkillEventData
local function Greatbow_PiercingShot_DragonBonus(char, state, data)
	if state == SKILL_STATE.HIT then
		data:ForEach(function(target)
			if IsTagged(target, "DRAGON") == 1 then
				ApplyStatus(target, "LLWEAPONEX_DRAGONS_BANE", 6.0, 0, char)
			end
		end)
	end
end
LeaderLib.RegisterSkillListener("Projectile_LLWEAPONEX_Greatbow_PiercingShot", Greatbow_PiercingShot_DragonBonus)

-- local function CheckAimedShotBonus(data)
-- 	local char = data[1]
-- 	if char ~= nil and HasActiveStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY") == 1 then
-- 		local removeStatus = false
-- 		local action = NRD_CharacterGetCurrentAction(char)
-- 		if action ~= "PrepareSkill" and action ~= "UseSkill" then
-- 			removeStatus = true
-- 		else
-- 			local skillprototype = NRD_ActionStateGetString(char, "SkillId")
-- 			if skillprototype ~= "" and skillprototype ~= nil then
-- 				local skill = string.gsub(skillprototype, "_%-?%d+$", "")
-- 				if skill ~= "Projectile_LLWEAPONEX_Rifle_AimedShot" then
-- 					removeStatus = true
-- 				end
-- 			end
-- 		end
-- 		if removeStatus then
-- 			RemoveStatus(char, "LLWEAPONEX_FIREARM_AIMEDSHOT_ACCURACY")
-- 		else
-- 			Mods.LeaderLib.StartTimer("Timers_LLWEAPONEX_AimedShot_RemoveAccuracyBonus", 1000, char)
-- 		end
-- 	end
-- end

-- OnTimerFinished["Timers_LLWEAPONEX_AimedShot_RemoveAccuracyBonus"] = CheckAimedShotBonus

---@param char string
---@param state SkillState
---@param data SkillEventData
local function SkyShot(char, state, data)
	if IsTagged(char, "LLWEAPONEX_Omnibolt_Equipped") == 1 then
		if state == SKILL_STATE.HIT and ObjectGetFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus") == 0 then
			if hasOmnibolt then
				data:ForEach(function(target)
					GameHelpers.ExplodeProjectile(char, target, "Projectile_LLWEAPONEX_Greatbow_LightningStrike")
				end)
			end
		elseif state == SKILL_STATE.USED then
			if data.TotalTargetObjects > 0 then
				ObjectClearFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus", 0)
			elseif data.TotalTargetPositions > 0 then
				ObjectSetFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus", 0)
				local x,y,z = table.unpack(data.TargetPositions[1])
				SetVarFloat3(char, "LLWEAPONEX_Omnibolt_SkyShotWorldPosition", x, y, z)
			end
		elseif state == SKILL_STATE.CAST then
			LeaderLib.StartTimer("Timers_LLWEAPONEX_ProcGreatbowLightningStrike", 750, char)
		end
	end
end

LeaderLib.RegisterSkillListener("Projectile_SkyShot", SkyShot)
LeaderLib.RegisterSkillListener("Projectile_EnemySkyShot", SkyShot)

local function ProcGreatbowLightningStrike(data)
	local char = data[1]
	if char ~= nil and ObjectGetFlag(char, "LLWEAPONEX_Omnibolt_SkyShotWorldBonus") == 1 then
		local x,y,z = GetVarFloat3(char, "LLWEAPONEX_Omnibolt_SkyShotWorldPosition")
		GameHelpers.ExplodeProjectileAtPosition(char, "Projectile_LLWEAPONEX_Greatbow_LightningStrike", x,y,z)
	end
end

OnTimerFinished["Timers_LLWEAPONEX_ProcGreatbowLightningStrike"] = ProcGreatbowLightningStrike

---@param char string
---@param state SkillState
---@param data SkillEventData
LeaderLib.RegisterSkillListener("Target_LLWEAPONEX_Steal", function(char, state, data)
	if state == SKILL_STATE.HIT then
		if data.TotalTargetObjects > 1 then
			local treasure = {}
			local level = CharacterGetLevel(char)
			local targetOwner = char
			for i,v in pairs(data.TargetObjects) do
				targetOwner = v
				local enemy = Ext.GetCharacter(v)
				local enemyTreasure = enemy.Treasures
				if enemyTreasure ~= nil then
					table.insert(treasure, Common.GetRandomTableEntry(enemyTreasure))
				end
				if enemy.Stats.Level > level then
					level = enemy.Stats.Level
				end
			end
			if #treasure == 0 then
				table.insert(treasure, "GenericEnemy")
			end

			local items = {}
			--LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830
			local x,y,z = GetPosition(char)
			local container = CreateItemTemplateAtPosition("98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
			for i,treasure in pairs(treasure) do
				GenerateTreasure(container, treasure, level, char)
			end
			local treasureItems = Ext.GetItem(container):GetInventoryItems()
			if #treasureItems > 0 then
				local ranItem = Common.GetRandomTableEntry(treasureItems)
				ItemSetOriginalOwner(ranItem, targetOwner) -- So it shows up as stolen
				ItemToInventory(ranItem, char, ItemGetAmount(ranItem), 1, 0)
			else
				GenerateTreasure(container, "ST_LLWEAPONEX_JustGold", level, char)
				MoveAllItemsTo(container, char, 0, 0, 0)
			end
			ItemRemove(container)
		end
	end
end)