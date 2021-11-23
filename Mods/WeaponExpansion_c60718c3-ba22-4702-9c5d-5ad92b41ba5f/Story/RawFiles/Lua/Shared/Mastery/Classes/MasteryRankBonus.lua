local isClient = Ext.IsClient()

---@alias MasteryRankBonusGetIsTooltipActiveCallback fun(self:MasteryRankBonus, skillOrStatus:string, character:EclCharacter, idType:string, data:EsvStatus|StatEntrySkillData):boolean

---@class MasteryRankBonus
---@field ID string
---@field Skills string[]|string Optional skills associated.
---@field Statuses string[]|string Optional statuses associated.
---@field Tooltip TranslatedString
---@field StatusTooltip TranslatedString If set, statuses will use this for tooltips, instead of Tooltip.
---@field AllStatuses boolean
---@field AllSkills boolean
---@field DisableStatusTooltip boolean
---@field NamePrefix TranslatedString|string
---@field GetIsTooltipActive MasteryRankBonusGetIsTooltipActiveCallback Custom callback to determine if a bonus is "active" when a tooltip occurs.
---@field OnGetTooltip fun(self:MasteryRankBonus, skillOrStatus:string, character:EclCharacter, isStatus:boolean):string|TranslatedString Custom callback to determine tooltip text dynamically.
local MasteryRankBonus = {
	Type = "MasteryRankBonus"
}

setmetatable(MasteryRankBonus, {
	__call = function(tbl, ...)
		return MasteryRankBonus:Create(...)
	end,
	__tostring = function(tbl)
		return string.format("%s%s%s", 
		tbl.ID, 
		tbl.Skills and "|Skills(" .. StringHelpers.Join(";",tbl.Skills) .. ")" or "",
		tbl.Statuses and "|Statuses(" .. StringHelpers.Join(";",tbl.Statuses) .. ")" or "")
	end
})

---@param id string
---@param params MasteryRankBonus
---@return MasteryRankBonus
function MasteryRankBonus:Create(id, params)
	local this = {
		ID = id or ""
	}
	if type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	if this.Skills and Common.TableHasEntry(this.Skills, "All") then
		this.AllSkills = true
	end
	if this.Statuses and Common.TableHasEntry(this.Statuses, "All") then
		this.AllStatuses = true
	end
	setmetatable(this, {
		__index = function(tbl,k)
			return MasteryRankBonus[k]
		end
	})
	return this
end

---Returns a default function for callback that checks for a tag specified, either on the status target or source.
---@return MasteryRankBonusGetIsTooltipActiveCallback
function MasteryRankBonus.DefaultStatusTagCheck(tag, checkSource)
	if checkSource then
		return function(bonus, id, character, tooltipType, status)
			if tooltipType == "status" and status then
				local source = GameHelpers.TryGetObject(status.StatusSourceHandle)
				if source and GameHelpers.CharacterOrEquipmentHasTag(source, tag) or Vars.LeaderDebugMode then
					return true
				end
				return false
			end
			return true
		end
	else
		return function(bonus, id, character, tooltipType, status)
			if tooltipType == "status" then
				return GameHelpers.CharacterOrEquipmentHasTag(character, tag) or Vars.LeaderDebugMode
			end
			return true
		end
	end
end

---@param callback WeaponExpansionMasterySkillListenerCallback
---@return MasteryRankBonus
function MasteryRankBonus:RegisterSkillListener(callback)
	if not isClient then
		MasteryBonusManager.RegisterSkillListener(self.Skills, self.ID, callback)
	end
	return self
end

---@param skillType string
---@param callback WeaponExpansionMasterySkillListenerCallback
---@return MasteryRankBonus
function MasteryRankBonus:RegisterSkillTypeListener(skillType, callback)
	if not isClient then
		MasteryBonusManager.RegisterSkillTypeListener(skillType, self.ID, callback)
	end
	return self
end

---@param event StatusEventID
---@param callback MasteryBonusStatusCallback
---@param specificStatuses string|string[] If set, these statuses will be used instead of the Statuses table. Use this to show text in a specific set of statuses, but listen for a different status.
---@return MasteryRankBonus
function MasteryRankBonus:RegisterStatusListener(event, callback, specificStatuses)
	if not isClient then
		MasteryBonusManager.RegisterStatusListener(event, specificStatuses or self.Statuses, self.ID, callback)
	end
	return self
end

---@param callback MasteryBonusStatusBeforeAttemptCallback
---@param specificStatuses string|string[] If set, these statuses will be used instead of the Statuses table. Use this to show text in a specific set of statuses, but listen for a different status.
---@return MasteryRankBonus
function MasteryRankBonus:RegisterStatusBeforeAttemptListener(callback, specificStatuses)
	if not isClient then
		MasteryBonusManager.RegisterStatusAttemptListener(specificStatuses or self.Statuses, self.ID, callback)
	end
	return self
end

---@param callback BasicAttackOnHitTargetCallback
---@param skipBonusCheck boolean
---@return MasteryRankBonus
function MasteryRankBonus:RegisterOnHit(callback, skipBonusCheck)
	if not isClient then
		if skipBonusCheck then
			AttackManager.RegisterOnHit(callback)
		else
			local wrapper = function(source, target, data, bonuses, bHitObject, isFromSkill)
				if MasteryBonusManager.HasMasteryBonus(source, self.ID) then
					local b,err = xpcall(callback, debug.traceback, source, target, data, bonuses, bHitObject, isFromSkill)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			AttackManager.RegisterOnHit(wrapper)
		end
	end
	return self
end

---@param tag string|string[]
---@param callback BasicAttackOnWeaponTagHitCallback
---@param skipBonusCheck boolean
---@return MasteryRankBonus
function MasteryRankBonus:RegisterOnWeaponTagHit(tag, callback, skipBonusCheck)
	if not isClient then
		if skipBonusCheck then
			AttackManager.RegisterOnWeaponTagHit(tag, callback)
		else
			local wrapper = function(tag, source, target, data, bonuses, bHitObject, isFromSkill)
				if MasteryBonusManager.HasMasteryBonus(source, self.ID) then
					local b,err = xpcall(callback, debug.traceback, tag, source, target, data, bonuses, bHitObject, isFromSkill)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			AttackManager.RegisterOnWeaponTagHit(tag, wrapper)
		end
	end
	return self
end

---@param event string
---@param arity integer
---@param state string
---@param callback function
---@param skipBonusCheck boolean
---@return MasteryRankBonus
function MasteryRankBonus:RegisterOsirisListener(event, arity, state, callback, skipBonusCheck)
	if not isClient then
		if skipBonusCheck then
			RegisterProtectedOsirisListener(event, arity, state, callback)
		else
			local wrapper = function(...)
				local params = {...}
				local hasMasteryBonus = false
				for i,v in pairs(params) do
					if type(v) == "string" and string.find(v, "-", 1, true) then
						if MasteryBonusManager.HasMasteryBonus(v, self.ID) then
							hasMasteryBonus = true
							break
						end
					end
				end
				if hasMasteryBonus then
					local b,err = xpcall(callback, debug.traceback, ...)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			RegisterProtectedOsirisListener(event, arity, state, wrapper)
		end
	end
	return self
end

---@param id string
---@param callback fun(uuid:UUID, id:string):void
---@param skipBonusCheck boolean
---@return MasteryRankBonus
function MasteryRankBonus:RegisterTurnEndedListener(id, callback, skipBonusCheck)
	if not isClient then
		if skipBonusCheck then
			RegisterListener("OnTurnEnded", id, callback)
		else
			local wrapper = function(character, turnId)
				if MasteryBonusManager.HasMasteryBonus(character, self.ID) then
					local b,err = xpcall(callback, debug.traceback, character, turnId)
					if not b then
						Ext.PrintError(err)
					end
				end
			end
			RegisterListener("OnTurnEnded", id, wrapper)
		end
	end
	return self
end

---@param self MasteryRankBonus
---@param character EclCharacter
---@param skillOrStatus string
---@return TranslatedString|string
local function TryGetTooltipText(self, character, skillOrStatus, isStatus, ...)
	if self.GetIsTooltipActive then
		local b,result = xpcall(self.GetIsTooltipActive, debug.traceback, self, skillOrStatus, character, isStatus and "status" or "skill", ...)
		if b then
			if result == false then
				return nil
			end
		else
			Ext.PrintError(result)
		end
	end
	if self.OnGetTooltip then
		local b,result = xpcall(self.OnGetTooltip, debug.traceback, self, skillOrStatus, character, isStatus, ...)
		if b then
			if result then
				return result
			end
		else
			Ext.PrintError(result)
		end
	end
	if isStatus then
		if not self.DisableStatusTooltip and (self.AllStatuses or Common.TableHasEntry(self.Statuses, skillOrStatus)) then
			return self.StatusTooltip or self.Tooltip
		end
	else
		if self.AllSkills or Common.TableHasEntry(self.Skills, skillOrStatus) then
			return self.Tooltip
		end
	end
end

---@param character EclCharacter
---@param skillOrStatus string
---@return TranslatedString
function MasteryRankBonus:GetTooltipText(character, skillOrStatus, isStatus, ...)
	local text = TryGetTooltipText(self, character, skillOrStatus, isStatus, ...)
	if text then
		local t = type(text)
		if t == "string" then
			return text
		elseif t == "table" and text.Type == "TranslatedString" then
			return text.Value
		end
	end
end

MasteryDataClasses.MasteryRankBonus = MasteryRankBonus