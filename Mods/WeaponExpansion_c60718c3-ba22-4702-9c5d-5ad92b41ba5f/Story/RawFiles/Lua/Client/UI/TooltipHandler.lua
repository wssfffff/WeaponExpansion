TooltipParams = {}
local ts = Classes.TranslatedString
local function sortTagParams(a,b)
	return a:upper() < b:upper()
end

Events.GetTooltipSkillDamage:Subscribe(function (e)
	local paramText = SkillGetDescriptionParam(e.SkillData, e.Character, false, "Damage")
	if paramText ~= nil then
		e.Result = paramText
	end
end)

Events.GetTooltipSkillParam:Subscribe(function (e)
	local paramText = SkillGetDescriptionParam(e.SkillData, e.Character, false, e.Param)
	if paramText ~= nil then
		e.Result = paramText
	end
end)

---@param character EsvCharacter
---@param data table
---@param skillOrStatus string
---@param tooltipType MasteryBonusDataTooltipID
---@param tags table<string,boolean>|nil
function TooltipParams.GetDescriptionText(character, data, skillOrStatus, tooltipType, tags)
	local descriptionText = ""
	local namePrefix = ""
	if data.Tags ~= nil then
		local _TAGS = tags or GameHelpers.GetAllTags(character, true, true)
		local alwaysEnabled = SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION or Vars.DebugMode

		local tagKeys = {}
		for tagName,tagData in pairs(data.Tags) do
			table.insert(tagKeys, tagName)
		end
		table.sort(tagKeys, sortTagParams)
		for i,tagName in pairs(tagKeys) do
			---@type MasteryBonusData
			local tagData = data.Tags[tagName]
			if alwaysEnabled
			or Mastery.HasMasteryRequirement(character, tagName, false, _TAGS)
			then
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
							Ext.Utils.PrintError("Error calling GetParam function for "..tagName..":\n", result)
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
local OnRuneTooltip = Ext.Require("Client/UI/Tooltips/RuneTooltip.lua")

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

---@param e OnWorldTooltipEventArgs
local function OnWorldTooltip(e)
	if e.Item and e.IsFromItem then
		local typeText = GetItemTypeText(e.Item)
		if not StringHelpers.IsNullOrEmpty(typeText) then
			local nextText = ""
			local startPos,endPos = string.find(e.Text, '<font size="15"><br>.-</font>')
			if startPos then
				nextText = string.format(worldTooltipTypeText, string.sub(e.Text, 0, startPos-1), typeText)
			else
				nextText = string.format(worldTooltipTypeText, e.Text, typeText)
			end
			e.Text = nextText
		end
	end
end

---@type table<string, LeaderLibGetTextPlaceholderCallback>
TooltipParams.SpecialParamFunctions = {
	---@param statCharacter StatCharacter
	LLWEAPONEX_MB_BacklashAPBonus = function(param, statCharacter)
		local b,result = GameHelpers.Stats.TryGetAttribute("MultiStrike_Vault", "ActionPoints", function (stat, attribute, apCost)
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
		end)
		if b then
			return result
		end
		return "0"
	end,
	LLWEAPONEX_MB_Dagger_CorruptedStatuses = function (param, statCharacter)
		local statuses = {}
		for _,prop in pairs(GameHelpers.Stats.GetSkillProperties("Target_CorruptedBlade")) do
			if prop.Type == "Status" then
				local displayName = GameHelpers.Stats.GetDisplayName(prop.Action, "StatusData")
				if not StringHelpers.IsNullOrWhitespace(displayName) then
					statuses[#statuses+1] = displayName
				end
			end
		end
		if #statuses > 0 then
			table.sort(statuses)
			return StringHelpers.Join(", ", statuses, true)
		end
		return GameHelpers.GetStringKeyText(GameHelpers.Stats.GetDisplayName("DISEASED", "StatusData"), "Diseased")
	end,
	LLWEAPONEX_MasteryBonus_FleshSacrifice_Damage = function(param, statCharacter)
		local potion = Ext.Stats.Get("Stats_Flesh_Sacrifice", nil, false)
		if potion then
			if tonumber(potion.Constitution) < 0 then
				--TODO Get actual negative Con from penalty precise qualifier, then translate that into actual vitality
				return "??? piercing damage"
			end
		end
		return "no damage"
	end
}

Events.GetTextPlaceholder:Subscribe(function(e)
	local callback = TooltipParams.SpecialParamFunctions[e.ID]
	if callback then
		local b,result = xpcall(callback, debug.traceback, e.ID, e.Character)
		if b then
			return result
		else
			Ext.Utils.PrintError(result)
		end
	end
end)

local function Init()
	Game.Tooltip.Register.Stat(OnStatTooltip)
	Game.Tooltip.Register.Skill(OnSkillTooltip)
	Game.Tooltip.Register.Status(OnStatusTooltip)
	Game.Tooltip.Register.Item(OnItemTooltip)
	Game.Tooltip.Register.Rune(OnRuneTooltip)

	--TODO Modify the tooltip array when a tooltip for an unequipped Dual Shields Shield is shown (and there's no shield to compare), to display the combat shield stored inside

	Events.OnWorldTooltip:Subscribe(OnWorldTooltip, {Priority=999})
	TooltipHandler.RegisterItemTooltipTag("LLWEAPONEX_UniqueBasilusDagger")
	TooltipHandler.RegisterItemTooltipTag("LLWEAPONEX_SwordofVictory_Equipped")
	TooltipHandler.RegisterItemTooltipTag("LLWEAPONEX_Omnibolt_Equipped")
end
return {
	Init = Init
}