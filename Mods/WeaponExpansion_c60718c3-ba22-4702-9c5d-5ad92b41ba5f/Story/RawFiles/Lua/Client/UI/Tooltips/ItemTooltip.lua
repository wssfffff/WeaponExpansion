---@type TranslatedString
local ts = Classes.TranslatedString

if ItemTooltipParams == nil then
	ItemTooltipParams = {}
end

---@param tooltip TooltipData
---@param item EsvCharacter
---@param weaponTypeName string
---@param scaleText string
---@param damageRange table<string,number[]>
---@param attackCost integer
local function CreateFakeWeaponTooltip(tooltip, item, weaponTypeName, scaleText, damageRange, attackCost, weaponRange, equippedLabel)
	local armorSlotType = tooltip:GetElement("ArmorSlotType")
	if armorSlotType ~= nil then
		local itemType = armorSlotType.Label
		armorSlotType.Label = weaponTypeName
		local equipped = tooltip:GetElement("Equipped")
		if equipped ~= nil then
			if equippedLabel ~= nil then
				equipped.Slot = equippedLabel
			else
				--equipped.Label = itemType
				equipped.Slot = itemType
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

	--Just in case
	tooltip:RemoveElements("APCostBoost")
	tooltip:RemoveElements("ItemRequirement")
	tooltip:RemoveElements("WeaponDamage")
	tooltip:RemoveElements("ItemAttackAPCost")
	tooltip:RemoveElements("WeaponCritMultiplier")
	tooltip:RemoveElements("WeaponRange")
	
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
	for damageType,data in pairs(damageRange) do
		element = {
			Type = "WeaponDamage",
			Label = LocalizedText.DamageTypeNames[damageType].Text.Value,
			MinDamage = data.Min or data[1],
			MaxDamage = data.Max or data[2],
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

local LLWEAPONEX_HandCrossbow = ts:Create("hd8d02aa1g5c35g48b5gbde6ga76293ef2798", "Hand Crossbow")
local LLWEAPONEX_Pistol = ts:Create("h9ead3ee9g63e6g4fdbg987dg87f8c9f5220c", "Pistol")
local LLWEAPONEX_Unarmed = ts:Create("h1e98bcebg2e42g4699gba2bg6f647d428699", "Unarmed")
local LLWEAPONEX_UnarmedWeapon = ts:Create("h4eb213a7g4793g4007g95c6gbaf47584f29d", "Unarmed Weapon[1]")
local GlovesSlot = ts:Create("h185545eagdaf0g4286ga411gd50cbdcabc8b", "Gloves")
local TwoHandedText = ts:Create("h3fb5cd5ag9ec8g4746g8f9cg03100b26bd3a", "Two-Handed")

---@class WeaponTypeNameEntry
---@field Tag string
---@field Text TranslatedString
---@field TwoHandedText TranslatedString|nil

local UniqueWeaponTypeTags = {
	LLWEAPONEX_UniqueBokken1H = ts:Create("h5264ef62gdc22g401fg8b62g303379cd7693", "Wooden Katana"),
	LLWEAPONEX_Blunderbuss = ts:Create("h59b52860gd0e3g4e65g9e61gd66b862178c3", "Blunderbuss"),
	LLWEAPONEX_RunicCannon = ts:Create("h702bf925gf664g45a7gb3f5g34418bfa2c56", "Runic Weaponry"),
}

UniqueWeaponTypeTags.LLWEAPONEX_UniqueBokken2H = UniqueWeaponTypeTags.LLWEAPONEX_UniqueBokken1H

ItemTooltipParams.UniqueWeaponTypeTags = UniqueWeaponTypeTags

---@type WeaponTypeNameEntry[]
local WeaponTypeNames = {
	--LLWEAPONEX_Bludgeon = {Text=ts:Create("h448753f3g7785g4681gb639ga0e9d58bfadd", "Bludgeon")},
	--LLWEAPONEX_RunicCannon = {Text=ts:Create("h702bf925gf664g45a7gb3f5g34418bfa2c56", "Runic Weaponry")},
	LLWEAPONEX_Banner = {Text=ts:Create("hbe8ca1e2g4683g4a93g8e20g984992e30d22", "Banner")},
	LLWEAPONEX_BattleBook = {Text=ts:Create("he053a3abge5d8g4d14g9333ga18d6eba3df1", "Battle Book")},
	LLWEAPONEX_DualShields = {Text=ts:Create("h00157a58g9ae0g4119gba1ag3f1e9f11db14", "Dual Shields")},
	LLWEAPONEX_Firearm = {Text=ts:Create("h8d02e345ged4ag4d60g9be9g68a46dda623b", "Firearm")},
	LLWEAPONEX_Greatbow = {Text=ts:Create("h52a81f92g3549g4cb4g9b18g066ba15399c0", "Greatbow")},
	LLWEAPONEX_Katana = {Text=ts:Create("he467f39fg8b65g4136g828fg949f9f3aef15", "Katana"), TwoHandedText=ts:Create("hd1f993bag9dadg49cbga5edgb92880c38e46", "Odachi")},
	LLWEAPONEX_Quarterstaff = {Text=ts:Create("h8d11d8efg0bb8g4130g9393geb30841eaea5", "Quarterstaff")},
	LLWEAPONEX_Polearm = {Text=ts:Create("hd61320b6ge4e6g4f51g8841g132159d6b282", "Polearm")},
	LLWEAPONEX_Rapier = {Text=ts:Create("h84b2d805gff5ag44a5g9f81g416aaf5abf18", "Rapier")},
	LLWEAPONEX_Runeblade = {Text=ts:Create("hb66213fdg1a98g4127ga55fg429f9cde9c6a", "Runeblade")},
	LLWEAPONEX_Scythe = {Text=ts:Create("h1e98bd0bg867dg4a57gb2d4g6d820b4e7dfa", "Scythe")},
	LLWEAPONEX_Unarmed = {Text=LLWEAPONEX_Unarmed},
	LLWEAPONEX_Rod = {Text=ts:Create("heb1c0428g158fg46d6gafa3g6d6143534f37", "One-Handed Scepter")},
	--LLWEAPONEX_Dagger = {Text=ts:Create("h697f3261gc083g4152g84cdgbe559a5e0388", "Dagger")}
}
--WeaponTypeNames.LLWEAPONEX_CombatShield = WeaponTypeNames.LLWEAPONEX_DualShields

ItemTooltipParams.WeaponTypeNames = WeaponTypeNames

local weaponTypePreferenceOrder = {
	"LLWEAPONEX_Rapier",
	"LLWEAPONEX_RunicCannon",
	"LLWEAPONEX_Banner",
	"LLWEAPONEX_BattleBook",
	"LLWEAPONEX_DualShields",
	"LLWEAPONEX_Greatbow",
	"LLWEAPONEX_Katana",
	"LLWEAPONEX_Quarterstaff",
	"LLWEAPONEX_Polearm",
	"LLWEAPONEX_Scythe",
	"LLWEAPONEX_Unarmed",
	"LLWEAPONEX_Runeblade",
	"LLWEAPONEX_Rod",
	"LLWEAPONEX_Firearm",
}

ItemTooltipParams.WeaponTypePreferenceOrder = weaponTypePreferenceOrder

---@class StatProperty
---@field Type string Status|Action
---@field Action string LLWEAPONEX_UNARMED_NOWEAPON_HIT etc
---@field Context string[] Target|Self
---@field Duration number
---@field StatusChance number
---@field Arg3 string
---@field Arg4 number
---@field Arg5 number
---@field SurfaceBoost boolean

---@param item EclItem
---@param tooltip TooltipData
---@param character EclCharacter
---@param weaponTypeTag string
---@param slotTag string
local function ReplaceRuneTooltip(item, tooltip, character, weaponTypeTag, slotTag)
	tooltip:RemoveElements("EmptyRuneSlot")
	tooltip:RemoveElements("RuneSlot")
	tooltip:RemoveElements("RuneEffect")
	local boost = Ext.StatGetAttribute(item.StatsId, "RuneEffectWeapon")
	local damageType = Ext.StatGetAttribute(boost, "Damage Type")
	local weaponTypeName = GameHelpers.GetStringKeyText(weaponTypeTag, "")
	if weaponTypeName ~= "" then
		local text = Text.ItemTooltip.SpecialRuneDamageTypeText:ReplacePlaceholders(weaponTypeName, GameHelpers.GetDamageText(damageType))
		local element = {
			Type = "SkillDescription",
			Label = text
		}
		tooltip:AppendElement(element)
	end

	local armorSlotType = tooltip:GetElement("ArmorSlotType")
	if armorSlotType == nil then
		armorSlotType = {
			Type = "ArmorSlotType",
			Label = ""
		}
	end
	local text = GameHelpers.GetStringKeyText(slotTag, "")
	if text ~= "" then
		armorSlotType.Label = text
	end
	local equipped = tooltip:GetElement("Equipped")
	if equipped == nil then
		equipped = {
			Type = "Equipped",
			Label = "",
			EquippedBy = character.DisplayName,
			Slot = Text.ItemTooltip.RuneSlot.Value
		}
		tooltip:AppendElement(equipped)
	else
		equipped.Slot = Text.ItemTooltip.RuneSlot.Value
	end

	---@type StatProperty[]
	local extraProperties = Ext.StatGetAttribute(boost, "ExtraProperties")
	if extraProperties ~= nil then
		for i,v in pairs(extraProperties) do
			if v.Type == "Status" then
				local title = GameHelpers.GetStringKeyText(Ext.StatGetAttribute(v.Action, "DisplayName"), "StatusName")
				local description = GameHelpers.GetStringKeyText(Ext.StatGetAttribute(v.Action, "Description"), "")
				if v.StatusChance < 1.0 then
					title = string.format("%s %s", title, Text.ItemTooltip.ChanceText:ReplacePlaceholders(math.ceil(v.StatusChance * 100)))
				end
				if description ~= nil and description ~= "" then
					local descParams = Ext.StatGetAttribute(v.Action, "DescriptionParams")
					if descParams ~= nil and descParams ~= "" then
						local paramValues = {}
						local params = StringHelpers.Split(descParams, ";")
						for i,v in pairs(params) do
							--local characterStats = ExtenderHelpers.CreateStatCharacterTable(character.Stats.Name)
							local paramValue = StatusGetDescriptionParam(v.Action, character, character.Stats, table.unpack(StringHelpers.Split(v, ":")))
							if paramValue ~= nil then
								table.insert(paramValues, paramValue)
							end
						end
						description = StringHelpers.ReplacePlaceholders(description, paramValues)
					end
				end
				if description == nil then
					description = ""
				end
				tooltip:AppendElement({
					Type = "Tags",
					Label = title,
					Value = description,
					Warning = Text.ItemTooltip.RuneOnHitTagText.Value
				})
			else
				tooltip:AppendElement({
					Type = "ExtraProperties",
					Label = v.Action
				})
			end
		end
	end
end

function GetItemTypeText(item)
	for tag,t in pairs(UniqueWeaponTypeTags) do
		if GameHelpers.ItemHasTag(item, tag) then
			if item.Stats.IsTwoHanded and not Game.Math.IsRangedWeapon(item.Stats) then
				return TwoHandedText.Value .. " " .. t.Value
			else
				return t.Value
			end
		end
	end
	local typeText = ""
	for i=1,#weaponTypePreferenceOrder do
		local tag = weaponTypePreferenceOrder[i]
		if GameHelpers.ItemHasTag(item, tag) then
			local renameWeaponType = WeaponTypeNames[tag]
			if renameWeaponType ~= nil then
				if item.Stats.IsTwoHanded and renameWeaponType.TwoHandedText ~= nil and not Game.Math.IsRangedWeapon(item.Stats) then
					typeText = StringHelpers.Append(typeText, renameWeaponType.TwoHandedText.Value, " ")
				else
					typeText = StringHelpers.Append(typeText, renameWeaponType.Text.Value, " ")
				end
			end
		end
	end
	return typeText
end

---@param item EclItem
---@param tooltip TooltipData
local function OnItemTooltip(item, tooltip)
	if not item then return end
	---@type EclCharacter
	local character = Client:GetCharacter()
	local flags = tooltip:GetElements("Flags")
	if flags ~= nil and #flags > 0 then
		for i,v in pairs(flags) do
			if v.Label == Text.Game.Unbreakable.Value then
				tooltip:RemoveElement(v)
			end
		end
	end

	if not GameHelpers.Item.IsObject(item) then
		if not item:HasTag("LeaderLib_AutoLevel") 
		and item:HasTag("LLWEAPONEX_AutoLevel") 
		and Settings.Global:FlagEquals("LLWEAPONEX_UniqueAutoLevelingDisabled", false)
		then
			local element = tooltip:GetElement("ItemDescription")
			if element ~= nil and not string.find(string.lower(element.Label), "automatically level") then
				if not StringHelpers.IsNullOrEmpty(element.Label) then
					element.Label = element.Label .. "<br>" .. Text.ItemDescription.AutoLeveling.Value
				else
					element.Label = Text.ItemDescription.AutoLeveling.Value
				end
			end
		end

		local statsId = item.Stats and item.Stats.Name or nil

		if statsId == "ARM_UNIQUE_LLWEAPONEX_PowerGauntlets_A" then
			--Removes the Requires Dwarf / Male
			for i,element in pairs(tooltip:GetElements("ItemRequirement")) do
				if element.RequirementMet == true then
					tooltip:RemoveElement(element)
				end
			end
		elseif item:HasTag("LLWEAPONEX_UniqueStrengthTattoos") then
			if character ~= nil then
				if character:GetStatus("UNSHEATHED") then
					local name = GameHelpers.GetStringKeyText("ARM_UNIQUE_LLWEAPONEX_Tattoos_Magic_Upperbody_A_DisplayName", "<font color='#FF4400'>Tattoos of Godly Strength (Unleashed)</font>")
					local element = tooltip:GetElement("ItemName")
					if element == nil then
						element = {Type="ItemName", Label=""}
						tooltip:AppendElement(element)
					end
					element.Label = name
				end
			end
		end

		local renamedArmorSlotType = false

		if character ~= nil then
			if GameHelpers.ItemHasTag(item, "LLWEAPONEX_Pistol") then
				local damageRange = Skills.DamageFunctions.PistolDamage(character, true, true, item.Stats)
				local apCost = Ext.StatGetAttribute("Projectile_LLWEAPONEX_Pistol_Shoot", "ActionPoints")
				local weaponRange = string.format("%sm", Ext.StatGetAttribute("Projectile_LLWEAPONEX_Pistol_Shoot", "TargetRadius"))
				CreateFakeWeaponTooltip(tooltip, item, LLWEAPONEX_Pistol.Value, Text.WeaponScaling.Pistol.Value, damageRange, apCost, weaponRange)
				renamedArmorSlotType = true
			elseif GameHelpers.ItemHasTag(item, "LLWEAPONEX_HandCrossbow") then
				local damageRange = Skills.DamageFunctions.HandCrossbowDamage(character, true, true, item.Stats)
				local apCost = Ext.StatGetAttribute("Projectile_LLWEAPONEX_HandCrossbow_Shoot", "ActionPoints")
				local weaponRange = string.format("%sm", Ext.StatGetAttribute("Projectile_LLWEAPONEX_HandCrossbow_Shoot", "TargetRadius"))
				CreateFakeWeaponTooltip(tooltip, item, LLWEAPONEX_HandCrossbow.Value, Text.WeaponScaling.HandCrossbow.Value, damageRange, apCost, weaponRange)
				renamedArmorSlotType = true
			elseif GameHelpers.ItemHasTag(item, "LLWEAPONEX_Unarmed") and item.ItemType ~= "Weapon" then
				--local damageRange,highestAttribute = UnarmedHelpers.GetUnarmedWeaponDamageRange(character.Stats, item)
				local weapon,highestAttribute = UnarmedHelpers.CreateUnarmedWeaponTable(character.Stats, item.Stats)
				local damageRange = UnarmedHelpers.CalculateBaseWeaponDamageRange(weapon)
				--local highestAttribute = "Finesse"
				--local bonusWeapon = ExtenderHelpers.CreateWeaponTable("WPN_LLWEAPONEX_Rapier_1H_A", character.Stats.Level, highestAttribute)
				--local damageRange = CalculateWeaponDamageRangeTest(character.Stats, bonusWeapon)
				local apCost = Ext.StatGetAttribute("NoWeapon", "AttackAPCost")
				local weaponRange = string.format("%sm", Ext.StatGetAttribute("NoWeapon", "WeaponRange") / 100)
				local scalesWithText = Text.WeaponScaling.General.Value:gsub("%[1%]", LocalizedText.AttributeNames[highestAttribute].Value)
				local slotInfoText = string.format(" (%s)", LocalizedText.Slots[item.Stats.Slot].Value)
				local equipped = tooltip:GetElement("Equipped")
				if equipped and not StringHelpers.IsNullOrWhitespace(equipped.Slot) then
					slotInfoText = string.format(" (%s)", equipped.Slot)
				end
				local typeText = LLWEAPONEX_UnarmedWeapon.Value:gsub("%[1%]", slotInfoText)
				CreateFakeWeaponTooltip(tooltip, item, typeText, scalesWithText, damageRange, apCost, weaponRange)
				renamedArmorSlotType = true
			end
		end

		local enabledMasteriesText = ""
		local totalMasteries = 0
		for tag,entry in pairs(Masteries) do
			if GameHelpers.ItemHasTag(item, tag) then
				totalMasteries = totalMasteries + 1
				local masteryName = GameHelpers.GetStringKeyText(tag, "")
				if masteryName ~= "" then
					if enabledMasteriesText ~= "" then
						enabledMasteriesText = enabledMasteriesText .. ", "
					end
					enabledMasteriesText = enabledMasteriesText .. masteryName
				end
			end
		end
		if not renamedArmorSlotType then
			local itemTypeText = GetItemTypeText(item)
			if not StringHelpers.IsNullOrEmpty(itemTypeText) then
				local armorSlotType = tooltip:GetElement("ArmorSlotType")
				if armorSlotType == nil then
					armorSlotType = {
						Type = "ArmorSlotType",
						Label = ""
					}
					tooltip:AppendElement(armorSlotType)
				end
				armorSlotType.Label = itemTypeText
			end
		end
		if enabledMasteriesText ~= "" then
			local element = tooltip:GetElement("ItemDescription")
			if element == nil then
				element = {Type="ItemDescription", Label=""}
				tooltip:AppendElement(element)
			end
			if element.Label ~= "" then
				element.Label = element.Label .. "<br>"
			end
			if totalMasteries > 1 then
				element.Label = element.Label .. Text.ItemDescription.EnabledMasteries:ReplacePlaceholders(enabledMasteriesText)
			else
				element.Label = element.Label .. Text.ItemDescription.EnabledMastery:ReplacePlaceholders(enabledMasteriesText)
			end
		end

		if character ~= nil then
			if GameHelpers.ItemHasTag(item, "LLWEAPONEX_Rune_HandCrossbow_DamageType") then
				ReplaceRuneTooltip(item, tooltip, character, "LLWEAPONEX_HandCrossbow", "LLWEAPONEX_HandCrossbowBolt")
			end
			if GameHelpers.ItemHasTag(item, "LLWEAPONEX_Rune_Pistol_DamageType") then
				ReplaceRuneTooltip(item, tooltip, character, "LLWEAPONEX_Pistol", "LLWEAPONEX_PistolBullet")
			end
			if GameHelpers.ItemHasTag(item, "LLWEAPONEX_RunicCannon") then
				if item.ItemType == "Weapon" then
					local text = GameHelpers.GetStringKeyText("LLWEAPONEX_ARMCANNON_HIT_DisplayName", "Builds Energy on Hit")
					if text ~= "" then
						tooltip:AppendElement({Type="ExtraProperties", Label = text})
					end
				end
				local max = GameHelpers.GetExtraData("LLWEAPONEX_RunicCannon_MaxEnergy", 3)
				local charges = PersistentVars.SkillData.RunicCannonCharges[item.NetID] or 0
				local text = Text.ItemTooltip.RunicCannonEnergy:ReplacePlaceholders(charges, max)
				local element = {
					Type = "ExtraProperties",
					Label = text
				}
				tooltip:AppendElement(element)
			elseif item:HasTag("LLWEAPONEX_DemolitionBackpack") then

			end
		end

		for tag,v in pairs(Tags.ExtraProperties) do
			if GameHelpers.ItemHasTag(item, tag) then
				local text = ""
				local t = type(v)
				if v == "string" then
					text = GameHelpers.GetStringKeyText(v, "")
				elseif v == "function" then
					local results = {xpcall(v, debug.traceback, tag, item, tooltip)}
					if results[1] == false then
						Ext.PrintError(results[2])
					else
						text = results[2]
					end
				else
					text = GameHelpers.GetStringKeyText(tag, "")
				end
				
				if not StringHelpers.IsNullOrWhitespace(text) then
					local element = {
						Type = "ExtraProperties",
						Label = GameHelpers.Tooltip.ReplacePlaceholders(text, character)
					}
					tooltip:AppendElement(element)
				end
			end
		end
	else
		local statsId = not StringHelpers.IsNullOrWhitespace(item.StatsId) and item.StatsId or nil
		if statsId and (string.find(statsId, "SCROLL") or item:HasTag("SCROLL")) then
			local apCost = Ext.StatGetAttribute(statsId, "UseAPCost")
			if apCost > 0 and Mastery.HasMasteryRequirement(character, "LLWEAPONEX_BattleBook_Mastery2") then
				if not character:HasTag("LLWEAPONEX_BattleBook_ScrollBonusAP") then
					local bonus = MasteryBonusManager.GetRankBonus(MasteryID.BattleBook, 2, "BATTLEBOOK_SCROLLS")
					if bonus then
						--Kind of a hack. "scroll" isn't a skill, but the bonus GetIsTooltipActive function will look for it, and is set to display for AllSkills.
						local text = GameHelpers.Tooltip.ReplacePlaceholders(bonus:GetTooltipText(character, "scroll", "item"), character)
						if text then
							local rankName = GameHelpers.GetStringKeyText("LLWEAPONEX_BattleBook_Mastery2", "")
							if not StringHelpers.IsNullOrWhitespace(rankName) then
								text = rankName .. "<br>" .. text
							end
							local element = tooltip:GetElement("SkillDescription", {
								Type = "SkillDescription",
								Label = ""
							})
							if not StringHelpers.IsNullOrWhitespace(element.Label) then
								element.Label = element.Label .. "<br>"
							end
							element.Label = element.Label .. text
						end
					end
				else
					local text = GameHelpers.GetStringKeyText("LLWEAPONEX_MB_BattleBook_Scrolls_Disabled", "<font color='#FF2222'>Bonus AP already gained this turn.</font>")
					tooltip:AppendElement({Type="ExtraProperties", Label = GameHelpers.Tooltip.ReplacePlaceholders(text, character)})
				end
			end
		end
	end

	if GameHelpers.ItemHasTag(item, "LLWEAPONEX_PacifistsWrath_Equipped") then
		local element = tooltip:GetElement("WeaponDamage")
		if element then
			element.MinDamage = 1
			element.MaxDamage = 1
		end
	end
end

return OnItemTooltip