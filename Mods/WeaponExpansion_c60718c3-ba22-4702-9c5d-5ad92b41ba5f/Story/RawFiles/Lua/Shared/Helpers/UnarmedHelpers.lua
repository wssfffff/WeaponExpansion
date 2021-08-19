if UnarmedHelpers == nil then
	UnarmedHelpers = {}
end

local unarmedAttributes = {
	"Strength",
	"Finesse",
	"Constitution"
}

function UnarmedHelpers.GetMasteryBoost(unarmedMastery)
	if unarmedMastery == 1 then
		return GameHelpers.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost1", 30)
	elseif unarmedMastery == 2 then
		return GameHelpers.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost2", 40)
	elseif unarmedMastery == 3 then
		return GameHelpers.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost3", 60)
	elseif unarmedMastery >= 4 then
		return GameHelpers.GetExtraData("LLWEAPONEX_UnarmedMasteryBoost4", 70)
	end
	return 0
end

local unarmedWeaponSlots = {
	Gloves = true,
	Boots = true
}

local unarmedTags = {"LLWEAPONEX_Unarmed", "LLWEAPONEX_UnarmedWeaponEquipped"}

---@param character EsvCharacter|EclCharacter
---@return EsvItem|EclItem
local function GetEquippedUnarmedArmor(character)
	local foundItems = {}
	local items = character:GetInventoryItems()
	for i=1,math.min(#items, 14) do
		if items[i] then
			local item = Ext.GetItem(items[i])
			if item and unarmedWeaponSlots[Data.EquipmentSlotNames[item.Slot]] == true and GameHelpers.ItemHasTag(item, unarmedTags) then
				foundItems[#foundItems+1] = item
			end
		end
	end
	return foundItems
end

---@param character StatCharacter
---@return StatItem,number,integer,string,boolean
function UnarmedHelpers.GetUnarmedWeapon(character, skipItemCheck)
	local hasUnarmedWeapon = false
	local weaponStat = "NoWeapon"
	local level = character.Level
	if skipItemCheck ~= true then
		for item in pairs(GetEquippedUnarmedArmor(character.Character)) do
			local unarmedWeaponStat = UnarmedWeaponStats[item.StatsId]
			if unarmedWeaponStat ~= nil then
				weaponStat = unarmedWeaponStat
				hasUnarmedWeapon = true
				level = item.Level
				break
			end
		end
	end
	local highestAttribute = Skills.GetHighestAttribute(character, unarmedAttributes)
	local unarmedMasteryRank = 0
	for i=1,Mastery.Variables.MaxRank,1 do
		local tag = "LLWEAPONEX_Unarmed_Mastery" .. i
		if character.Character:HasTag(tag) then
			unarmedMasteryRank = i
		end
	end
	local unarmedMasteryBoost = UnarmedHelpers.GetMasteryBoost(unarmedMasteryRank)
	---@type StatItem
	local weapon = ExtenderHelpers.CreateWeaponTable(weaponStat, level, highestAttribute, "Club", unarmedMasteryBoost)
	--print("Unarmed weapon:", Common.Dump(weapon), getmetatable(character.Character))
	--print(getmetatable(character), type(getmetatable(character)))
	return weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon
end

---@param character StatCharacter
---@return table<string,number[]>,number,integer,string
function UnarmedHelpers.GetDamageRange(character)
	local weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(character)
	local damageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, weapon)
	if character.Character:HasTag("LIZARD") then
		local offHandDamageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, weapon)
		local dualWieldPenalty = Ext.ExtraData.DualWieldingDamagePenalty
		for damageType, range in pairs(offHandDamageRange) do
			local min = math.ceil(range.Min * dualWieldPenalty)
			local max = math.ceil(range.Max * dualWieldPenalty)
			local range = damageRange[damageType]
			if damageRange[damageType] ~= nil then
				range.Min = range.Min + min
				range.Max = range.Max + max
			else
				damageRange[damageType] = {Min = min, Max = max}
			end
		end
	end
	return damageRange,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon
end

---@param character EclCharacter
function UnarmedHelpers.GetUnarmedBaseAndTotalDamage(character)
	local isLizard = character:HasTag("LIZARD")
	local weapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(character.Stats, true)
	local damageList,baseMin,baseMax,totalMin,totalMax = UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, true, highestAttribute, isLizard, false)
	if isLizard then
		local damageList2,baseMin2,baseMax2,totalMin2,totalMax2 = UnarmedHelpers.CalculateWeaponDamage(character.Stats, weapon, true, highestAttribute, isLizard, true)
		baseMin = baseMin + baseMin2
		baseMax = baseMax + baseMax2
		totalMin = totalMin + totalMin2
		totalMax = totalMax + totalMax2
	end
	return baseMin,baseMax,totalMin,totalMax,unarmedMasteryBoost
end

---@param character StatCharacter
---@param item StatItem
---@return table<string,number[]>,string
function UnarmedHelpers.GetUnarmedWeaponDamageRange(character, item)
	local noWeapon,unarmedMasteryBoost,unarmedMasteryRank,highestAttribute,hasUnarmedWeapon = UnarmedHelpers.GetUnarmedWeapon(character, true)
	if GameHelpers.ItemHasTag(item, "LLWEAPONEX_UnarmedWeaponEquipped") then
		local unarmedWeaponStatName = UnarmedWeaponStats[item.Name]
		if unarmedWeaponStatName ~= nil then
			local unarmedWeapon = ExtenderHelpers.CreateWeaponTable(unarmedWeaponStatName, item.Level, highestAttribute, "None", unarmedMasteryBoost)
			if unarmedWeapon ~= nil then
				for i,stat in pairs(unarmedWeapon.DynamicStats) do
					if i > 1 then
						table.insert(noWeapon.DynamicStats, stat)
					elseif i == 1 then
						noWeapon.DynamicStats[1] = stat
					end
				end
			end
		end
	end
	local damageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, noWeapon)
	if character.Character:HasTag("LIZARD") then
		local offHandDamageRange = Common.CopyTable(damageRange, true)
		local dualWieldPenalty = Ext.ExtraData.DualWieldingDamagePenalty
		for damageType, range in pairs(offHandDamageRange) do
			local min = math.ceil(range.Min * dualWieldPenalty)
			local max = math.ceil(range.Max * dualWieldPenalty)
			local range = damageRange[damageType]
			if damageRange[damageType] ~= nil then
				range.Min = range.Min + min
				range.Max = range.Max + max
			else
				damageRange[damageType] = {Min = min, Max = max}
			end
		end
	end
	return damageRange,highestAttribute
end

local function statMatchOrNil(stat, name)
	return stat == nil or (stat ~= nil and stat.Name == name)
end

---@param stat StatEntryWeapon
local function isUnarmedWeaponStat(stat)
	if stat == nil then
		return true
	else
		if not StringHelpers.IsNullOrWhitespace(stat.Tags) and 
		Common.TableHasValue(StringHelpers.Split(stat.Tags, ";"), "LLWEAPONEX_Unarmed") then
			return true
		end
		for _,v in pairs(stat.DynamicStats) do
			if not StringHelpers.IsNullOrWhitespace(v.ObjectInstanceName) then
				local tags = Ext.StatGetAttribute(v.ObjectInstanceName, "Tags")
				if not StringHelpers.IsNullOrWhitespace(tags) and Common.TableHasValue(StringHelpers.Split(tags, ";"), "LLWEAPONEX_Unarmed") then
					return true
				end
			end
		end
	end
end

---@param character StatCharacter
function UnarmedHelpers.HasUnarmedWeaponStats(character, allowShields)
	if type(character) == "string" then
		character = Ext.GetCharacter(character).Stats
	elseif type(character) == "userdata" then
		local objType = getmetatable(character)
		if objType == "ecl::Character" then
			character = character.Stats
		elseif objType ~= "CDivinityStats_Character" then
			Ext.PrintError("[WeaponExpansion:UnarmedHelpers.HasUnarmedWeaponStats] The character param should be a string, EsvCharacter, or StatCharacter. Type is:", character, objType)
			character = nil
		end
	end
	if character ~= nil then
		local hasValidOffhand = (allowShields == true and character.OffHandWeapon ~= nil and character.OffHandWeapon.Slot == "Shield") or character.OffHandWeapon == nil
		local isUnarmedStats = statMatchOrNil(character.MainWeapon, "NoWeapon") and (statMatchOrNil(character.OffHandWeapon, "NoWeapon") or hasValidOffhand)
		if isUnarmedStats then
			return true
		elseif isUnarmedWeaponStat(character.MainWeapon) and (isUnarmedWeaponStat(character.OffHandWeapon) or hasValidOffhand) then
			return true
		end
	end
	return false
end

---@param uuid string
function UnarmedHelpers.IsUnarmedWeapon(uuid)
	if StringHelpers.IsNullOrEmpty(uuid) then
		return true
	else
		local item = Ext.GetItem(uuid)
		if item:HasTag("LLWEAPONEX_Unarmed") then
			return true
		end
	end
	return false
end

---@param mainhand string
---@param offhand string
function UnarmedHelpers.WeaponsAreUnarmed(mainhand, offhand)
	return UnarmedHelpers.IsUnarmedWeapon(mainhand) and UnarmedHelpers.IsUnarmedWeapon(offhand)
end

---@param character EsvCharacter|EclCharacter
function UnarmedHelpers.IsUnarmed(character)
	return character.Stats:GetItemBySlot("Weapon") == nil and character.Stats:GetItemBySlot("Shield") == nil
end