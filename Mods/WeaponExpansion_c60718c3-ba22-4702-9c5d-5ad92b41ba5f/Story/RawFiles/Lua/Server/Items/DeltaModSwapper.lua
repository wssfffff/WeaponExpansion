local DeltamodSwap = Ext.Require("Server/Data/DeltaModSwapEntries.lua")

---@param item EsvItem
---@return table<string,boolean>|nil
local function GetAllBoosts(item)
	local finalBoosts = {}
	local swapped = false

	local boostType = "DeltaMod"

	for i,v in pairs(item:GetGeneratedBoosts()) do
		--local deltamod = Ext.GetDeltaMod(v, item.ItemType)
		for tag,deltamods in pairs(DeltamodSwap) do
			if item:HasTag(tag) then
				local replacement = deltamods[v]
				if replacement ~= nil then
					if replacement == "" then
						PrintDebug("Disabled deltamod",v,item.StatsId)
						finalBoosts[v] = false
						swapped = true
					elseif type(replacement) == "function" then
						local b,replacementVal = pcall(replacement, item, v)
						if b then
							PrintDebug("Swapped deltamod",v,"for",replacementVal,item.StatsId)
							finalBoosts[v] = replacementVal
							swapped = true
						end
					else
						PrintDebug("Swapped deltamod",v,"for",replacement,item.StatsId)
						finalBoosts[v] = replacement
						swapped = true
					end
				else
					--finalBoosts[v] = boostType
				end
			end
		end
	end

	for i,deltamodName in pairs(item:GetDeltaMods()) do
		local deltamodData = Ext.Stats.DeltaMod.GetLegacy(deltamodName, item.Stats.ItemType)
		if deltamodData ~= nil then
			for i2,boostEntry in pairs(deltamodData.Boosts) do
				local v = boostEntry.Boost
				if finalBoosts[v] ~= true then
					for tag,deltamods in pairs(DeltamodSwap) do
						if item:HasTag(tag) then
							local replacement = deltamods[v]
							if replacement ~= nil then
								if replacement == "" then
									finalBoosts[v] = false
									swapped = true
								elseif type(replacement) == "function" then
									local b,replacementVal = pcall(replacement, item, v)
									if b then
										finalBoosts[v] = replacementVal
										swapped = true
									end
								else
									finalBoosts[v] = replacement
									swapped = true
								end
							else
								--finalBoosts[v] = boostType
							end
						end
					end
				end
			end
		end
	end
	if swapped then
		return finalBoosts
	else
		return nil
	end
end

local BaseStatMap = {
	Durability = "Durability",
	DurabilityDegradeSpeed = "DurabilityDegradeSpeed",
	StrengthBoost = "StrengthBoost",
	FinesseBoost = "FinesseBoost",
	IntelligenceBoost = "IntelligenceBoost",
	ConstitutionBoost = "ConstitutionBoost",
	MemoryBoost = "MemoryBoost",
	WitsBoost = "WitsBoost",
	SightBoost = "SightBoost",
	HearingBoost = "HearingBoost",
	VitalityBoost = "VitalityBoost",
	--SourcePointsBoost = "SourcePointsBoost",
	--MaxAP = "MaxAP",
	--StartAP = "StartAP",
	APRecovery = "APRecovery",
	AccuracyBoost = "AccuracyBoost",
	DodgeBoost = "DodgeBoost",
	CriticalChance = "CriticalChance",
	ChanceToHitBoost = "ChanceToHitBoost",
	--MovementSpeedBoost = "MovementSpeedBoost",
	RuneSlots = "RuneSlots",
	RuneSlots_V1 = "RuneSlots_V1",
	Movement = "Movement",
	Initiative = "Initiative",
	--Willpower = "integer",
	--Bodybuilding = "integer",
	MaxSummons = "MaxSummons",
	Value = "Value",
	Weight = "Weight",
	Skills = "Skills",
	--ItemColor = "string",
	--ModifierType = "integer",
	--ObjectInstanceName = "string",
	--BoostName = "string",
	--StatsType = "string",
}

local StatMap = {
	Weapon = {
		DamageType = "Damage Type",
		--MinDamage = "integer",
		--MaxDamage = "integer",
		DamageBoost = "DamageBoost",
		DamageFromBase = "DamageFromBase",
		CriticalDamage = "CriticalDamage",
		WeaponRange = "WeaponRange",
		CleaveAngle = "CleaveAngle",
		CleavePercentage = "CleavePercentage",
		AttackAPCost = "AttackAPCost",
		LifeSteal = "LifeSteal",
	},
	Armor = {
		FireResistance = "Fire",
		AirResistance = "Air",
		WaterResistance = "Water",
		EarthResistance = "Earth",
		PoisonResistance = "Poison",
		PiercingResistance = "Piercing",
		PhysicalResistance = "Physical",
		ArmorValue = "Armor Defense Value",
		ArmorBoost = "ArmorBoost",
		MagicArmorValue = "Magic Armor Value",
		MagicArmorBoost = "MagicArmorBoost",
	},
	Shield = {
		Blocking = "integer",
	}
}

local function CopyTable(orig, target)
	for orig_key, orig_value in pairs(orig) do
		target[orig_key] = orig_value
	end
end

CopyTable(BaseStatMap, StatMap.Weapon)
CopyTable(BaseStatMap, StatMap.Armor)
CopyTable(StatMap.Armor, StatMap.Shield)

local Qualifiers = {
	StrengthBoost = true,
	FinesseBoost = true,
	IntelligenceBoost = true,
	ConstitutionBoost = true,
	MemoryBoost = true,
	WitsBoost = true,
	MagicPointsBoost = true,
	DurabilityDegradeSpeed = true,
	SightBoost = true,
	HearingBoost = true,
}

local function GetStatValue(stat, attribute)
	if Qualifiers[attribute] == true then
		local val = stat[attribute]
		if val == "None" then
			val = 0
		end
		return val
	else
		return stat[attribute]
	end
end

local function ResetBoostEntry(boostEntryName, boostEntry, itemType, changes)
	local baseBoost = nil
	if itemType == "Weapon" then
		baseBoost = Ext.Stats.Get("_BOOSTS_Weapon", nil, false)
	elseif itemType == "Armor" then
		baseBoost = Ext.Stats.Get("_BOOSTS_Armor", nil, false)
	elseif itemType == "Shield" then
		baseBoost = Ext.Stats.Get("_BOOSTS_Shield", nil, false)
	end
	local changesMade = false
	for boostAttribute,statAttribute in pairs(StatMap[itemType]) do
		local current = boostEntry[boostAttribute]
		local nextValue = GetStatValue(baseBoost, statAttribute)
		if current ~= nextValue then
			boostEntry[boostAttribute] = nextValue
			if changes[boostEntryName] == nil then
				changes[boostEntryName] = {}
			end
			changes[boostEntryName][boostAttribute] = nextValue
			changesMade = true
		end
	end
	return changesMade
end

--[[
!questreward LLWEAPONEX_Rewards_NewWeapons_1 3000
]]

---@param item EsvItem
local function SwapDeltaMods(item)
	local level = item.Stats.Level
	local rarity = item.Stats.ItemTypeReal
	local itemType = item.Stats.ItemType

	local changes = {}
	local hasChanges = false
	local boostMap = {}

	local boosts = GetAllBoosts(item)
	if boosts ~= nil then
		for i=2,#item.Stats.DynamicStats do
			local boost = item.Stats.DynamicStats[i]
			if not StringHelpers.IsNullOrEmpty(boost.ObjectInstanceName) then
				PrintLog("[SwapDeltaMods] [%s] BoostName(%s) ObjectInstanceName(%s)", i, boost.BoostName, boost.ObjectInstanceName)
				boostMap[boost.ObjectInstanceName] = boost
			end
		end
		for replaceDeltaModName,newDeltaModName in pairs(boosts) do
			local replaceBoosts = Ext.Stats.DeltaMod.GetLegacy(replaceDeltaModName, itemType).Boosts
			if newDeltaModName ~= false then
				---@cast newDeltaModName string
				local newBoosts = Ext.Stats.DeltaMod.GetLegacy(newDeltaModName, itemType).Boosts
				local newBoost = newBoosts[1].Boost
	
				for i,replace in pairs(replaceBoosts) do
					local replaceBoost = replace.Boost
					local existingBoostEntry = boostMap[replaceBoost]
					if existingBoostEntry ~= nil then
						--existingBoostEntry.ObjectInstanceName = newBoost
						--existingBoostEntry.BoostName = newBoost
						--generatedBoostNames[#generatedBoostNames+1] = newBoost
						local boostStat = Ext.Stats.Get(newBoost, nil, false)
						local statMap = StatMap[itemType]
						for boostAttribute,statAttribute in pairs(statMap) do
							local nextValue = GetStatValue(boostStat, statAttribute)
							if nextValue ~= nil then
								local current = existingBoostEntry[boostAttribute]
								if current ~= nil and current ~= nextValue then
									if changes[replaceBoost] == nil then
										changes[replaceBoost] = {}
									end
									changes[replaceBoost][boostAttribute] = nextValue
									hasChanges = true
									existingBoostEntry[boostAttribute] = nextValue
								end
							end
						end
						boostMap[newBoost] = existingBoostEntry
						boostMap[replaceBoost] = nil
					end
				end
			else
				for i,replace in pairs(replaceBoosts) do
					local replaceBoost = replace.Boost
					local existingBoostEntry = boostMap[replaceBoost]
					if existingBoostEntry ~= nil then
						if ResetBoostEntry(replaceBoost, existingBoostEntry, itemType, changes) then
							hasChanges = true
							boostMap[replaceBoost] = nil
						end
					end
				end
			end
		end
	end

	if hasChanges then
		if item.SetGeneratedBoosts ~= nil then
			-- Save persistence
			---@type string[]
			local generatedBoostNames = {}
			for name,_ in pairs(boostMap) do
				generatedBoostNames[#generatedBoostNames+1] = name
			end
			if Vars.DebugMode then
				fprint(LOGLEVEL.TRACE, "[WeaponExpansion:SwapDeltaMods] Setting item MyGuid(%s) StatsId(%s) generated boosts to:\n%s", item.MyGuid, item.StatsId, Ext.DumpExport(generatedBoostNames))
			end
			--item:SetGeneratedBoosts(generatedBoostNames)
		end
		GameHelpers.Net.Broadcast("LLWEAPONEX_DeltaModSwapper_SyncBoosts", {NetID = item.NetID, Changes = changes})
	end
end

local skipRarities = {
	Common = true,
	Unique = true
}

local equipmentTypes = {
	Armor = true,
	Weapon = true,
	Shield = true
}
Events.TreasureItemGenerated:Subscribe(function (e)
	if e.Item then
		-- 3 = Potion, 0-2 are Weapon/Armor/Shield
		if e.Item.Stats and equipmentTypes[e.Item.Stats.ItemType] then
			if skipRarities[e.Item.Stats.ItemTypeReal] ~= true then
				SwapDeltaMods(e.Item)
			end
		end

		local _TAGS = GameHelpers.GetAllTags(e.Item, true, false)
		if _TAGS.LLWEAPONEX_DualShields and not _TAGS.LLWEAPONEX_CombatShield then
			local itemGUID = e.Item.MyGuid
			Timer.StartOneshot("", 250, function (e)
				local item = GameHelpers.GetItem(itemGUID)
				if item then
					ItemProcessor.DualShields.GetCombatShield(item, false)
				end
			end)
		end
	end
end)