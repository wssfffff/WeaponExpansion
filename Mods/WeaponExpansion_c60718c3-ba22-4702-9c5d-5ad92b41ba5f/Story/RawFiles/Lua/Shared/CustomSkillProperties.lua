GameHelpers.Skill.CreateSkillProperty("LLWEAPONEX_ApplyRuneProperties", nil, 
	function(prop, attacker, position, areaRadius, isFromItem, skill, hit, skillId)
		local chance = prop.Arg1
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local items = {}
			for _,slot in Data.EquipmentSlots:Get() do
				local uuid = CharacterGetEquippedItem(attacker.MyGuid, slot)
				if not StringHelpers.IsNullOrEmpty(uuid) then
					local item = Ext.GetItem(uuid)
					if item then
						items[#items+1] = items
					end
				end
			end
			for i=1,#items do
				ApplyRuneExtraProperties(attacker, position, items[i], position, areaRadius, skillId)
			end
		end
	end,
	function(prop, attacker, target, position, isFromItem, skill, hit, skillId)
		local chance = prop.Arg1
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local items = {}
			for _,slot in Data.EquipmentSlots:Get() do
				local uuid = CharacterGetEquippedItem(attacker.MyGuid, slot)
				if not StringHelpers.IsNullOrEmpty(uuid) then
					local item = Ext.GetItem(uuid)
					if item then
						items[#items+1] = items
					end
				end
			end
			for i=1,#items do
				ApplyRuneExtraProperties(attacker, target, items[i], position, math.max(skill.AreaRadius or 1, skill.ExplodeRadius or 1), skillId)
			end
		end
	end)

GameHelpers.Skill.CreateSkillProperty("LLWEAPONEX_ApplyBulletProperties", nil, function (property, attacker, position, areaRadius, isFromItem, skill, hit, skillId)
	local chance = property.Arg1
	if chance >= 1.0 or Ext.Utils.Random(0,1) <= chance then
		local radius = areaRadius
		if skill then
			radius = math.max(1, math.max(skill.StatsObject.AreaRadius or 0, skill.StatsObject.ExplodeRadius or 0))
		end
		local rune,weaponBoostStat = Skills.GetRuneBoost(attacker.Stats, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols")
		if weaponBoostStat ~= nil then
			---@type StatProperty[]
			local props = GameHelpers.Stats.GetExtraProperties(weaponBoostStat)
			if props ~= nil and #props > 0 then
				Ext.PropertyList.ExecuteExtraPropertiesOnPosition(weaponBoostStat, "ExtraProperties", attacker, position, radius, "AoE", false, skillId)
				Ext.PropertyList.ExecuteExtraPropertiesOnPosition(weaponBoostStat, "ExtraProperties", attacker, attacker, attacker.WorldPos, "Self", false, skillId)
			end
		end
	end
end, function (property, attacker, target, position, isFromItem, skill, hit, skillId)
	local chance = property.Arg1
	if chance >= 1.0 or Ext.Utils.Random(0,1) <= chance then
		local radius = 1
		if skill then
			radius = math.max(1, math.max(skill.StatsObject.AreaRadius or 0, skill.StatsObject.ExplodeRadius or 0))
		end
		local rune,weaponBoostStat = Skills.GetRuneBoost(attacker.Stats, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols")
		if weaponBoostStat ~= nil then
			---@type StatProperty[]
			local props = GameHelpers.Stats.GetExtraProperties(weaponBoostStat)
			if props ~= nil and #props > 0 then
				Ext.PropertyList.ExecuteExtraPropertiesOnTarget(weaponBoostStat, "ExtraProperties", attacker, target, target.WorldPos, "Target", false, skillId)
				Ext.PropertyList.ExecuteExtraPropertiesOnTarget(weaponBoostStat, "ExtraProperties", attacker, attacker, attacker.WorldPos, "Self", false, skillId)
			end
		end
	end
end)

GameHelpers.Skill.CreateSkillProperty("LLWEAPONEX_ApplyBoltProperties", nil, function (property, attacker, position, areaRadius, isFromItem, skill, hit, skillId)
	local chance = property.Arg1
	if chance >= 1.0 or Ext.Utils.Random(0,1) <= chance then
		local radius = math.max(1, math.max(skill.StatsObject.AreaRadius or 0, skill.StatsObject.ExplodeRadius or 0))
		local rune,weaponBoostStat = Skills.GetRuneBoost(attacker.Stats, "_LLWEAPONEX_HandCrossbow_Bolts", "_LLWEAPONEX_HandCrossbows")
		if weaponBoostStat ~= nil then
			---@type StatProperty[]
			local props = GameHelpers.Stats.GetExtraProperties(weaponBoostStat)
			if props ~= nil and #props > 0 then
				Ext.PropertyList.ExecuteExtraPropertiesOnPosition(weaponBoostStat, "ExtraProperties", attacker, position, radius, "AoE", false, skillId)
				Ext.PropertyList.ExecuteExtraPropertiesOnPosition(weaponBoostStat, "ExtraProperties", attacker, attacker, attacker.WorldPos, "Self", false, skillId)
			end
		end
	end
end, function (property, attacker, target, position, isFromItem, skill, hit, skillId)
	local chance = property.Arg1
	if chance >= 1.0 or Ext.Utils.Random(0,1) <= chance then
		local rune,weaponBoostStat = Skills.GetRuneBoost(attacker.Stats, "_LLWEAPONEX_HandCrossbow_Bolts", "_LLWEAPONEX_HandCrossbows")
		if weaponBoostStat ~= nil then
			---@type StatProperty[]
			local props = GameHelpers.Stats.GetExtraProperties(weaponBoostStat)
			if props ~= nil and #props > 0 then
				Ext.PropertyList.ExecuteExtraPropertiesOnTarget(weaponBoostStat, "ExtraProperties", attacker, target, target.WorldPos, "Target", false, skillId)
				Ext.PropertyList.ExecuteExtraPropertiesOnTarget(weaponBoostStat, "ExtraProperties", attacker, attacker, attacker.WorldPos, "Self", false, skillId)
			end
		end
	end
end)

GameHelpers.Skill.CreateSkillProperty("LLWEAPONEX_ChaosRuneAbsorbSurface",
	function(prop)
		local chance = prop.Arg1
		if chance >= 1.0 then
			return Text.SkillTooltip.ChaosRuneAbsorbSurface.Value
		else
			return Text.SkillTooltip.ChaosRuneAbsorbSurface_Chance:ReplacePlaceholders(math.floor(chance * 100))
		end
	end,
	function(prop, attacker, position, areaRadius, isFromItem, skill, hit, skillId)
		local chance = prop.Arg1
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local duration = math.max(prop.Arg2 or 6, 6)
			local radius = math.max(areaRadius, math.max(skill.StatsObject.AreaRadius or 1, skill.StatsObject.ExplodeRadius or 1))
			RunebladeManager.AbsorbSurface(attacker, position, radius, duration)
		end
	end,
	function(prop, attacker, target, position, isFromItem, skill, hit, skillId)
		local chance = prop.Arg1
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local duration = math.max(prop.Arg2 or 6, 6)
			local radius = math.max(skill.StatsObject.AreaRadius or 1, skill.StatsObject.ExplodeRadius or 1)
			RunebladeManager.AbsorbSurface(attacker, position, radius, duration)
		end
	end)