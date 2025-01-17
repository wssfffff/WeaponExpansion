
local ts = Classes.TranslatedString

local RuneTags = {
	DamageType = {
		"LLWEAPONEX_Rune_HandCrossbow_DamageType",
		"LLWEAPONEX_Rune_Pistol_DamageType",
	}
}

local boltAmmoTypeText = ts:Create("hfc6af8f2gdd0ag40a0g8d9egc63f5cad0a3e", "Ammo Type: [1]")

local function GetHandCrossbowBoltEffects(skill, character, isFromItem, param)
	local rune,weaponBoostStat = Skills.GetRuneBoost(character, "_LLWEAPONEX_HandCrossbow_Bolts", "_LLWEAPONEX_HandCrossbows")
	if rune ~= nil then
		--local runeNameText = Text.RuneNames[rune.BoostName]
		local runeNameText = GameHelpers.GetStringKeyText(rune.BoostName)
		if runeNameText ~= nil then
			return boltAmmoTypeText.Value:gsub("%[1%]", runeNameText)
		else
			Ext.Utils.PrintError("No text for rune: ", rune.BoostName)
		end
	end
	return ""
end

Skills.Params["LLWEAPONEX_HandCrossbowRuneEffects"] = GetHandCrossbowBoltEffects

local PistolRuneBoosts = {
	["_Boost_LLWEAPONEX_Pistol_Bullets_Normal"] = {Transform="", Apply=""},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Air"] = {Transform="Electrify", Apply=""},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Corrosive"] = {Apply="ACID",Transform="Melt"},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Earth"] = {Transform="", Apply="SLOWED", Chance=25, Turns=1},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Fire"] = {Transform="Ignite", Apply="BURNING", Chance=100, Turns=1},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Ice"] = {Transform="Freeze", Apply="CHILLED", Chance=100, Turns=1},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Poison"] = {Transform="", Apply="POISONED", Chance=100, Turns=1},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Piercing"] = {Transform="", Apply="BLEEDING", Chance=100, Turns=1},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Shadow"] = {Apply="CURSED", Transform="Curse"},
	["_Boost_LLWEAPONEX_Pistol_Bullets_Silver"] = {Apply="", Transform=""},
}

local bulletAmmoTypeText = ts:Create("h7eee4e3dg9eb0g4a6fg825egc0981d7c0cad", "Ammo Type: [1]")

local function GetPistolBulletEffects(skill, character, isFromItem, param)
	local rune,weaponBoostStat = Skills.GetRuneBoost(character, "_LLWEAPONEX_Pistol_Bullets", "_LLWEAPONEX_Pistols")
	if rune ~= nil then
		--local runeNameText = Text.RuneNames[rune.BoostName]
		local runeNameText = GameHelpers.GetStringKeyText(rune.BoostName)
		if runeNameText ~= nil then
			return bulletAmmoTypeText.Value:gsub("%[1%]", runeNameText)
		else
			Ext.Utils.PrintError("No text for rune: ", rune.BoostName)
		end
	end
	-- Ext.Utils.Print(bullet,bulletRuneStat)
	-- if bulletRuneStat ~= nil then
	-- 	local boostEffects = bulletRuneBoosts[bulletRuneStat]
	-- 	Ext.Utils.Print(boostEffects.Apply)
	-- 	if boostEffects ~= nil and (boostEffects.Apply ~= nil or boostEffects.Transform ~= nil) then
	-- 		return string.format("<br><font color='#FFBB22'>%s%s</font>", boostEffects.Apply, boostEffects.Transform)
	-- 	end
	-- end
	return ""
end
Skills.Params["LLWEAPONEX_PistolRuneEffects"] = GetPistolBulletEffects

local skillAbility = {
	Projectile_LLWEAPONEX_Pistol_Shoot = {"RogueLore", "LLWEAPONEX_Pistol"},
	Projectile_LLWEAPONEX_Pistol_Shoot_Enemy = {"RogueLore", "LLWEAPONEX_Pistol"},
	Projectile_LLWEAPONEX_HandCrossbow_Shoot = {"RogueLore", "LLWEAPONEX_HandCrossbow"},
	Projectile_LLWEAPONEX_HandCrossbow_Shoot_Enemy = {"RogueLore", "LLWEAPONEX_HandCrossbow"},
	Projectile_LLWEAPONEX_HandCrossbow_Assassinate = {"RogueLore", "LLWEAPONEX_HandCrossbow"},
	Projectile_LLWEAPONEX_HandCrossbow_Assassinate_Enemy = {"RogueLore", "LLWEAPONEX_HandCrossbow"},
}

local function GetSkillAbility(skill, character, isFromItem, param)
	local skillId = skill
	if type(skill) ~= "string" then
		skillId = skill.Name
	end
	local ability = skillAbility[skillId]
	if ability ~= nil then
		local t = type(ability)
		if t == "string" then
			local text = Text.DefaultSkillScaling.LevelBased:ReplacePlaceholders(GameHelpers.GetAbilityName(ability))
			if text ~= nil then
				if param then
					return string.format("<br><font color='#078FC8'>%s</font>", text)
				else
					return text
				end
			end
		elseif t == "table" then
			local allBonuses = {}
			for i,v in pairs(ability) do
				if Data.AbilityEnum[v] ~= nil then
					table.insert(allBonuses, GameHelpers.GetAbilityName(v))
				elseif Masteries[v] ~= nil then
					table.insert(allBonuses, string.format("%s %s", Masteries[v].Name.Value, Text.Mastery.Value))
				end
			end
			local text = Text.DefaultSkillScaling.LevelBased:ReplacePlaceholders(StringHelpers.Join(", ", allBonuses))
			if text ~= nil then
				if param then
					return string.format("<br><font color='#078FC8'>%s</font>", text)
				else
					return text
				end
			end
		end
	end
	return ""
end

Skills.Params["LLWEAPONEX_ScalingStat"] = GetSkillAbility

local function GetHighestAttribute(skill, character, isFromItem, param)
	local att = Skills.GetHighestAttribute(character)
	local text = string.gsub(Text.DefaultSkillScaling.LevelBased.Value, "%[1%]", att)
	return "<br><font color='#078FC8'>"..text.."</font>"
end

Skills.Params["GetHighestAttribute"] = GetHighestAttribute

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
local function GetUnarmedBasicAttackDamage(skill, character, isFromItem, param)
	local weapon = UnarmedHelpers.GetUnarmedWeapon(character)
	local damageRange = Math.GetSkillDamageRange(character, skill, weapon)
	if damageRange ~= nil then
		return GameHelpers.Tooltip.FormatDamageRange(damageRange)
	end
end

Skills.Params["LLWEAPONEX_UnarmedBasicAttackDamage"] = GetUnarmedBasicAttackDamage

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
local function GetStealChance(skill, character, isFromItem, param)
	local chance = GameHelpers.GetExtraData("LLWEAPONEX_Steal_BaseChance", 50.0)
	if character.Character:HasTag("LLWEAPONEX_PirateGloves_Equipped") then
		local glovesBonusChance = GameHelpers.GetExtraData("LLWEAPONEX_Steal_GlovesBonusChance", 30.0)
		chance = chance + glovesBonusChance
	end
	return string.format("%i", chance)
end

Skills.Params["LLWEAPONEX_StealChance"] = GetStealChance

local defaultPos = {[1] = 0.0, [2] = 0.0, [3] = 0.0,}

local function GetDamageParamResult(param_func, skill, character, isFromItem)
	local b,damageRange = xpcall(param_func, debug.traceback, skill, character, isFromItem, false, defaultPos, defaultPos, -1, 0, true)
	if b then
		if damageRange then
			return GameHelpers.Tooltip.FormatDamageRange(damageRange)
		end
	else
		Ext.Utils.PrintError("Error getting param for skill ("..skill.Name.."):\n",damageRange)
	end
end

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
function SkillGetDescriptionParam(skill, character, isFromItem, param)
	if param == "Damage" and skill.UseWeaponDamage == "Yes" and GameHelpers.CharacterOrEquipmentHasTag(character.Character, "LLWEAPONEX_PacifistsWrath_Equipped") then
		return GameHelpers.GetDamageText("Physical", 1)
	end
	if Skills.DamageParam[param] ~= nil then
		local param_func = Skills.DamageParam[param]
		if param_func ~= nil then
			return GetDamageParamResult(param_func, skill, character, isFromItem)
		end
	elseif param == "Damage" then
		if skill.UseWeaponDamage == "Yes" and UnarmedHelpers.HasUnarmedWeaponStats(character) then
			return GetDamageParamResult(Skills.DamageFunctions.UnarmedSkillDamage, skill, character, isFromItem)
		else
			local param_func = Skills.Damage[skill.Name]
			if param_func ~= nil then
				return GetDamageParamResult(param_func, skill, character, isFromItem)
			end
		end
	else
		local param_func = Skills.Params[param]
		if param_func ~= nil then
			local status,txt = xpcall(param_func, debug.traceback, skill, character, isFromItem, param)
			if status then
				if txt ~= nil then
					return txt
				end
			else
				Ext.Utils.PrintError("Error getting param ("..param..") for skill:\n",txt)
				return ""
			end
		end
	end
end

Ext.Events.SkillGetDescriptionParam:Subscribe(function (e)
	local b,result = xpcall(SkillGetDescriptionParam, debug.traceback, e.Skill, e.Character, e.IsFromItem, e.Params and table.unpack(e.Params) or "")
	if not b then
		Ext.Utils.PrintError(result)
	elseif not StringHelpers.IsNullOrEmpty(result) then
		e.Description = result
		e:StopPropagation()
	end
end, {Priority=101})

Events.GetTextPlaceholder:Subscribe(function (e)
	if e.Character then
		e.Result = GetPistolBulletEffects(nil, e.Character, false, e.ID)
	end
end, {MatchArgs={ID="LLWEAPONEX_PistolRuneEffects"}})