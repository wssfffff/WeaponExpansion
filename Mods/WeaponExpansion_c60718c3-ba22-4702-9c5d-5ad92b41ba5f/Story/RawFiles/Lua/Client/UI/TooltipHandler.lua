TooltipParams = {}
local ts = Classes.TranslatedString
local function sortTagParams(a,b)
	return a:upper() < b:upper()
end

---@param skill SkillEventData
---@param character StatCharacter
---@return string
RegisterListener("GetTooltipSkillDamage", function(skill, character)
	local paramText = SkillGetDescriptionParam(skill, character, false, "Damage")
	if paramText ~= nil then
		return paramText
	end
end)

---@param skill SkillEventData
---@param character StatCharacter
---@param param string
---@return string
RegisterListener("GetTooltipSkillParam", function(skill, character, param)
	local paramText = SkillGetDescriptionParam(skill, character, false, param)
	if paramText ~= nil then
		return paramText
	end
end)

---@param character EsvCharacter
---@param data table
---@param skillOrStatus string
---@param tooltipType MasteryBonusDataTooltipID
function TooltipParams.GetDescriptionText(character, data, skillOrStatus, tooltipType)
	local descriptionText = ""
	local namePrefix = ""
	if data.Tags ~= nil then
		local tagKeys = {}
		for tagName,tagData in pairs(data.Tags) do
			table.insert(tagKeys, tagName)
		end
		table.sort(tagKeys, sortTagParams)
		for i,tagName in pairs(tagKeys) do
			---@type MasteryBonusData
			local tagData = data.Tags[tagName]
			if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION or Mastery.HasMasteryRequirement(character, tagName) or Vars.DebugMode then
				if tagData.NamePrefix ~= nil then
					if namePrefix ~= "" then
						namePrefix = namePrefix .. " "
					end
					namePrefix = namePrefix .. tagData.NamePrefix
				end
				local paramText = ""
				--local tagLocalizedName = Text.MasteryRankTagText[tagName]
				local tagLocalizedName = GameHelpers.GetStringKeyText(tagName)
				if tagLocalizedName == nil then 
					tagLocalizedName = ""
				else
					tagLocalizedName = tagLocalizedName .. "<br>"
				end
				if tagData.Type == "MasteryBonusData" then
					local text = tagData:GetTooltipText(skillOrStatus, character, tooltipType)
					if text ~= nil then
						local t = type(text)
						if t == "string" then
							paramText = tagLocalizedName..text
						elseif t == "table" and text.Type == "TranslatedString" then
							paramText = tagLocalizedName..text.Value
						end
					end
				else
					if tagData.Param ~= nil then
						if tagLocalizedName ~= "" then
							paramText = tagLocalizedName..tagData.Param.Value
						else
							paramText = tagData.Param.Value
						end
					end
					if tagData.GetParam ~= nil then
						local status,result = xpcall(tagData.GetParam, debug.traceback, character.Stats, tagName, tagLocalizedName, paramText)
						if status and result ~= nil then
							paramText = result
						elseif not status then
							Ext.PrintError("Error calling GetParam function for "..tagName..":\n", result)
						end
					end
				end
				paramText = GameHelpers.Tooltip.ReplacePlaceholders(paramText)
				if descriptionText ~= "" then descriptionText = descriptionText .. "<br>" end
				descriptionText = descriptionText .. paramText
			end
		end
	end
	return descriptionText
end

local OnItemTooltip = Ext.Require("Client/UI/Tooltips/ItemTooltip.lua")
local OnSkillTooltip = Ext.Require("Client/UI/Tooltips/SkillTooltip.lua")
local OnStatusTooltip = Ext.Require("Client/UI/Tooltips/StatusTooltip.lua")

local OnStatTooltip = Ext.Require("Client/UI/Tooltips/StatTooltips.lua")

Ext.RegisterNetListener("LLWEAPONEX_SetWorldTooltipText", function(cmd, text)
	local ui = Ext.GetUIByType(44)
	if ui ~= nil then
		local main = ui:GetRoot()
		if main ~= nil then
			if main.tf ~= nil then
				main.tf.shortDesc = text
				if main.tf.setText ~= nil then
					main.tf.setText(text,0)
				end
			elseif main.defaultTooltip ~= nil then
				main.defaultTooltip.shortDesc = text
				if main.defaultTooltip.setText ~= nil then
					main.defaultTooltip.setText(text,0)
				end
			end
		end
	end
end)

--local worldTooltipFormat = '<font color="#ffffff">%s</font><font size="15"><br>%s</font>'
local worldTooltipTypeText = '%s<font size="15"><br>%s</font>'

---@param ui UIObject
---@param text string
---@param x number
---@param y number
---@param isFromItem boolean
---@param item EclItem
local function OnWorldTooltip(ui, text, x, y, isFromItem, item)
	if isFromItem then
		local typeText = GetItemTypeText(item)
		if not StringHelpers.IsNullOrEmpty(typeText) then
			local nextText = ""
			local startPos,endPos = string.find(text, '<font size="15"><br>.-</font>')
			if startPos then
				nextText = string.format(worldTooltipTypeText, string.sub(text, 0, startPos-1), typeText)
			else
				nextText = string.format(worldTooltipTypeText, text, typeText)
			end
			return nextText
		end
	end
end
-- local startPos,endPos = string.find(text, '<font size="15"><br>.-</font>')
-- if startPos then
-- 	local nextText = string.sub(text, 0, startPos-1)
-- 	Ext.PostMessageToServer("LLWEAPONEX_SetWorldTooltipText_Request", Ext.JsonStringify({ID=Client.ID, Text=nextText}))
-- end

local LLWEAPONEX_UI_RunicCannonEnergy = ts:Create("h02882207g5e7bg4deaga22eg854b68f8dd29", "<font color='#33FFAA'>Runic Energy [1]</font>")

---@param ui UIObject
---@param tooltip_mc any
---@param isControllerMode boolean
---@param lastItem EclItem|nil
local function OnTooltipPositioned(ui, tooltip_mc, isControllerMode, lastItem, ...)
	if lastItem ~= nil and lastItem:HasTag("LLWEAPONEX_RunicCannon") then
		local array = tooltip_mc.list.content_array
		for i=0,#array do
			local group = array[i]
			if group ~= nil and group.groupID == 2 then
				local max = GameHelpers.GetExtraData("LLWEAPONEX_RunicCannon_MaxEnergy", 3)
				local charges = PersistentVars.SkillData.RunicCannonCharges[lastItem.NetID] or 0
				local text = LLWEAPONEX_UI_RunicCannonEnergy:ReplacePlaceholders(charges, max)
				group.addElNoColour(text)
				--tooltip_mc.list.positionElements()
				--tooltip_mc.resetBackground()
				--tooltip_mc.repositionElements()
				break
			end
		end
	end
end

---@type table<string,LeaderLibGetTextPlaceholderCallback>
TooltipParams.SpecialParamFunctions = {
	---@param statCharacter StatCharacter
	LLWEAPONEX_MB_BacklashAPBonus = function(param, statCharacter)
		local apCost = Ext.StatGetAttribute("MultiStrike_Vault", "ActionPoints")
		if apCost > 1 then
			local refundMult = math.min(100, math.max(0, GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_Backlash_APRefundPercentage", 50)))
			if refundMult > 0 then
				if refundMult > 1 then
					refundMult = refundMult * 0.01
				end
				local apBonus = math.max(1, math.floor(apCost * refundMult))
				return tostring(apBonus)
			end
		end
		return "0"
	end,
	LLWEAPONEX_MB_Dagger_CorruptedStatuses = function (param, statCharacter)
		local statuses = {}
		for _,prop in pairs(GameHelpers.Stats.GetSkillProperties("Target_CorruptedBlade")) do
			if prop.Type == "Status" then
				local displayName = GameHelpers.GetStringKeyText(Ext.StatGetAttribute(prop.Action, "DisplayName"), "")
				if not StringHelpers.IsNullOrWhitespace(displayName) then
					statuses[#statuses+1] = displayName
				end
			end
		end
		if #statuses > 0 then
			table.sort(statuses)
			return StringHelpers.Join(", ", statuses, true)
		end
		return GameHelpers.GetStringKeyText(Ext.StatGetAttribute("DISEASED", "DisplayName"), "Diseased")
	end,
	LLWEAPONEX_MasteryBonus_FleshSacrifice_Damage = function(param, statCharacter)
		local potion = Ext.GetStat("Stats_Flesh_Sacrifice")
		if potion then
			if potion.Constitution < 0 then
				--TODO Get actual negative Con from penalty precise qualifier, then translate that into actual vitality
				return "??? piercing damage"
			end
		end
		return "no damage"
	end
}

---@param param string
---@param statCharacter StatCharacter
---@vararg string
---@return string
RegisterListener("GetTextPlaceholder", function(param, statCharacter)
	local callback = TooltipParams.SpecialParamFunctions[param]
	if callback then
		local b,result = xpcall(callback, debug.traceback, param, statCharacter)
		if b then
			return result
		else
			Ext.PrintError(result)
		end
	end
end)

local function Init()
	Game.Tooltip.RegisterListener("Stat", nil, OnStatTooltip)
	Game.Tooltip.RegisterListener("Skill", nil, OnSkillTooltip)
	Game.Tooltip.RegisterListener("Status", nil, OnStatusTooltip)
	Game.Tooltip.RegisterListener("Item", nil, OnItemTooltip)

	RegisterListener("OnWorldTooltip", OnWorldTooltip)
	TooltipHandler.RegisterItemTooltipTag("LLWEAPONEX_UniqueBasilusDagger")
	TooltipHandler.RegisterItemTooltipTag("LLWEAPONEX_SwordofVictory_Equipped")
end
return {
	Init = Init
}