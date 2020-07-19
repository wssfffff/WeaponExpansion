---@type LeaderLibLocalizedText
local LocalizedText = LeaderLib.LocalizedText
---@type TranslatedString
local TranslatedString = LeaderLib.Classes.TranslatedString

---@type tooltip TooltipData
---@type item EsvCharacter
---@type weaponTypeName string
---@type scaleText string
---@type damageRange table<string,number[]>
---@type attackCost integer
local function CreateFakeWeaponTooltip(tooltip, item, weaponTypeName, scaleText, damageRange, attackCost, weaponRange, equippedLabel)
	local armorSlotType = tooltip:GetElement("ArmorSlotType")
	if armorSlotType ~= nil then
		local itemType = armorSlotType.Label
		armorSlotType.Label = weaponTypeName
		local equipped = tooltip:GetElement("Equipped")
		if equipped ~= nil then
			if equippedLabel ~= nil then
				equipped.Warning = equippedLabel
			else
				--equipped.Label = itemType
				equipped.Warning = itemType
			end
		elseif equippedLabel ~= nil then
			-- local element = {
			-- 	Type = "Equipped",
			-- 	EquippedBy = "",
			-- 	Label = "",
			-- 	Warning = equippedLabel,
			-- }
			-- tooltip:AppendElement(element)
		end
	end
	
	local element = {
		Type = "ItemAttackAPCost",
		Value = attackCost,
		Label = Text.Game.Attack.Value,
		RequirementMet = true,
		Warning = "",
	}
	tooltip:AppendElement(element)
	element = {
		Type = "APCostBoost",
		Value = attackCost,
		Label = Text.Game.ActionPoints.Value,
	}
	tooltip:AppendElement(element)
	element = {
		Type = "ItemRequirement",
		Label = scaleText,
		RequirementMet = true
	}
	tooltip:AppendElement(element)
	print("damageRange", Common.Dump(damageRange))
	for damageType,data in pairs(damageRange) do
		element = {
			Type = "WeaponDamage",
			Label = LocalizedText.DamageTypeNames[damageType].Text.Value,
			MinDamage = data[1],
			MaxDamage = data[2],
			DamageType = LeaderLib.Data.DamageTypeEnums[damageType],
		}
		tooltip:AppendElement(element)
	end
	element = {
		Type = "WeaponCritMultiplier",
		Label = Text.Game.CriticalDamage.Value,
		Value = "100%",
	}
	tooltip:AppendElement(element)
	if weaponRange ~= nil then
		element = {
			Type = "WeaponRange",
			Label = Text.Game.Range.Value,
			Value = weaponRange,
		}
		tooltip:AppendElement(element)
	end
end

local LLWEAPONEX_HandCrossbow = TranslatedString:Create("hd8d02aa1g5c35g48b5gbde6ga76293ef2798", "Hand Crossbow")
local LLWEAPONEX_Pistol = TranslatedString:Create("h9ead3ee9g63e6g4fdbg987dg87f8c9f5220c", "Pistol")
local LLWEAPONEX_Unarmed = TranslatedString:Create("h1e98bcebg2e42g4699gba2bg6f647d428699", "Unarmed")
local LLWEAPONEX_UnarmedWeapon = TranslatedString:Create("h4eb213a7g4793g4007g95c6gbaf47584f29d", "Unarmed Weapon[1]")
local GlovesSlot = TranslatedString:Create("h185545eagdaf0g4286ga411gd50cbdcabc8b", "Gloves")
local TwoHandedText = TranslatedString:Create("h3fb5cd5ag9ec8g4746g8f9cg03100b26bd3a", "Two-Handed")

---@class WeaponTypeNameEntry
---@field Tag string
---@field Text TranslatedString
---@field TwoHandedText TranslatedString|nil

---@type WeaponTypeNameEntry[]
local WeaponTypeNames = {
	{Tag="LLWEAPONEX_Banner", Text=TranslatedString:Create("hbe8ca1e2g4683g4a93g8e20g984992e30d22", "Banner")},
	{Tag="LLWEAPONEX_BattleBook", Text=TranslatedString:Create("he053a3abge5d8g4d14g9333ga18d6eba3df1", "Battle Book")},
	{Tag="LLWEAPONEX_Blunderbuss", Text=TranslatedString:Create("h59b52860gd0e3g4e65g9e61gd66b862178c3", "Blunderbuss")},
	{Tag="LLWEAPONEX_DualShields", Text=TranslatedString:Create("h00157a58g9ae0g4119gba1ag3f1e9f11db14", "Dual Shields")},
	{Tag="LLWEAPONEX_Firearm", Text=TranslatedString:Create("h8d02e345ged4ag4d60g9be9g68a46dda623b", "Firearm")},
	{Tag="LLWEAPONEX_Greatbow", Text=TranslatedString:Create("h52a81f92g3549g4cb4g9b18g066ba15399c0", "Greatbow")},
	{Tag="LLWEAPONEX_Katana", Text=TranslatedString:Create("he467f39fg8b65g4136g828fg949f9f3aef15", "Katana"), TwoHandedText=TranslatedString:Create("hd1f993bag9dadg49cbga5edgb92880c38e46", "Odachi")},
	{Tag="LLWEAPONEX_Quarterstaff", Text=TranslatedString:Create("h8d11d8efg0bb8g4130g9393geb30841eaea5", "Quarterstaff")},
	{Tag="LLWEAPONEX_Polearm", Text=TranslatedString:Create("hd61320b6ge4e6g4f51g8841g132159d6b282", "Polearm")},
	{Tag="LLWEAPONEX_Rapier", Text=TranslatedString:Create("h84b2d805gff5ag44a5g9f81g416aaf5abf18", "Rapier")},
	{Tag="LLWEAPONEX_Runeblade", Text=TranslatedString:Create("hb66213fdg1a98g4127ga55fg429f9cde9c6a", "Runeblade")},
	{Tag="LLWEAPONEX_Scythe", Text=TranslatedString:Create("h1e98bd0bg867dg4a57gb2d4g6d820b4e7dfa", "Scythe")},
	{Tag="LLWEAPONEX_Unarmed", Text=LLWEAPONEX_Unarmed},
	{Tag="LLWEAPONEX_Rod", Text=TranslatedString:Create("heb1c0428g158fg46d6gafa3g6d6143534f37", "One-Handed Scepter")},
	--{Tag="LLWEAPONEX_Bludgeon", Text=TranslatedString:Create("h448753f3g7785g4681gb639ga0e9d58bfadd", "Bludgeon")},
}

local AutoLevelingDescription = TranslatedString:Create("hca27994egc60eg495dg8146g7f81c970e265", "<font color='#80FFC3'>Automatically levels up with the user, gaining new bonuses at various levels.</font>")

---@param item EsvItem
---@param tooltip TooltipData
local function OnItemTooltip(item, tooltip)
	if item ~= nil then
		if item:HasTag("LLWEAPONEX_Pistol") then
			local character = Ext.GetCharacter(CLIENT_UI.ACTIVE_CHARACTER)
			local damageRange = Skills.DamageFunctions.PistolDamage(character, true)
			local apCost = Ext.StatGetAttribute("Target_LLWEAPONEX_Pistol_Shoot", "ActionPoints")
			local weaponRange = string.format("%sm", Ext.StatGetAttribute("Target_LLWEAPONEX_Pistol_Shoot", "TargetRadius"))
			CreateFakeWeaponTooltip(tooltip, item, LLWEAPONEX_Pistol.Value, Text.WeaponScaling.Pistol.Value, damageRange, apCost, weaponRange)
		elseif item:HasTag("LLWEAPONEX_HandCrossbow") then
			local character = Ext.GetCharacter(CLIENT_UI.ACTIVE_CHARACTER)
			local damageRange = Skills.DamageFunctions.HandCrossbowDamage(character, true)
			local apCost = Ext.StatGetAttribute("Projectile_LLWEAPONEX_HandCrossbow_Shoot", "ActionPoints")
			local weaponRange = string.format("%sm", Ext.StatGetAttribute("Projectile_LLWEAPONEX_HandCrossbow_Shoot", "TargetRadius"))
			CreateFakeWeaponTooltip(tooltip, item, LLWEAPONEX_HandCrossbow.Value, Text.WeaponScaling.HandCrossbow.Value, damageRange, apCost, weaponRange)
		elseif item:HasTag("LLWEAPONEX_Unarmed") then
			local character = Ext.GetCharacter(CLIENT_UI.ACTIVE_CHARACTER)
			local damageRange,highestAttribute = GetUnarmedWeaponDamageRange(character.Stats, item.Stats)
			--local highestAttribute = "Finesse"
			--local bonusWeapon = Skills.CreateWeaponTable("WPN_LLWEAPONEX_Rapier_1H_A", character.Stats.Level, highestAttribute)
			--local damageRange = CalculateWeaponDamageRangeTest(character.Stats, bonusWeapon)
			local apCost = Ext.StatGetAttribute("NoWeapon", "AttackAPCost")
			local weaponRange = string.format("%sm", Ext.StatGetAttribute("NoWeapon", "WeaponRange") / 100)
			local scalesWithText = Text.WeaponScaling.General.Value:gsub("%[1%]", LeaderLib.LocalizedText.AttributeNames[highestAttribute].Value)
			local slotInfoText = ""
			local equipped = tooltip:GetElement("Equipped")
			if equipped == nil then
				slotInfoText = string.format(" (%s)", LeaderLib.LocalizedText.Slots[item.Stats.Slot].Value)
			end
			local typeText = LLWEAPONEX_UnarmedWeapon.Value:gsub("%[1%]", slotInfoText)
			CreateFakeWeaponTooltip(tooltip, item, typeText, scalesWithText, damageRange, apCost, weaponRange)
		else
			for i,entry in ipairs(WeaponTypeNames) do
				if item:HasTag(entry.Tag) then
					local armorSlotType = tooltip:GetElement("ArmorSlotType")
					if armorSlotType == nil then
						armorSlotType = {
							Type = "ArmorSlotType",
							Label = ""
						}
					end
					if entry.TwoHanded ~= nil and item.Stats.IsTwoHanded and not Game.Math.IsRangedWeapon(item.Stats) then
						armorSlotType.Label = TwoHandedText.Value .. " " .. entry.TwoHandedText.Value
					else
						armorSlotType.Label = entry.Text.Value
					end
					break
				end
			end
		end

		if item:HasTag("LeaderLib_AutoLevel") then
			local element = tooltip:GetElement("ItemDescription")
			if element ~= nil and not string.find(element.Label, "Automatically levels up") then
				if not StringHelpers.IsNullOrEmpty(element.Label) then
					element.Label = element.Label .. "<br>" .. AutoLevelingDescription.Value
				else
					element.Label = AutoLevelingDescription.Value
				end
			end
		end
	end
end

return OnItemTooltip