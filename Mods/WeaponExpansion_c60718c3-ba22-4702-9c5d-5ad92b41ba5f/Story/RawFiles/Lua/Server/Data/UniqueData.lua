---@class UniqueData
local UniqueData = {
	UUID = "",
	LevelData = {},
	Owner = nil,
	---@type string|table<string,string>
	DefaultOwner = nil,
	CurrentLevel = nil,
	AutoEquipOnOwner = false,
	Initialized = false,
	---@type function
	OnEquipped = nil,
	---@type function
	OnOwnerDeath = nil,
	---@type function
	OnGotOwner = nil,
	LastProgressionLevel = 0,
	ProgressionData = nil,
	CanMoveToVendingMachine = true,
	---@type UniqueData
	LinkedItem = nil,
	Tag = "",
	Copies = nil
}
UniqueData.__index = UniqueData

---@param uuid string
---@param progressionData table<string, table<int, UniqueProgressionEntry>>
---@param params table<string,any>
---@return UniqueData
function UniqueData:Create(uuid, progressionData, params)
    local this =
    {
		UUID = uuid,
		LevelData = {},
		Owner = nil,
		DefaultOwner = nil,
		AutoEquipOnOwner = false,
		Initialized = false,
		OnEquipped = nil,
		OnGotOwner = nil,
		OnOwnerDeath = nil,
		LastProgressionLevel = 0,
		ProgressionData = progressionData,
		CanMoveToVendingMachine = true,
		Tag = "",
		Copies = {},
		LinkedItem = nil,
	}
	setmetatable(this, self)
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	if this.DefaultOwner ~= nil or this.Owner ~= nil then
		this.CanMoveToVendingMachine = false
	elseif this.CanMoveToVendingMachine then
		-- Vending Machine
		this.DefaultOwner = NPC.VendingMachine
	end
    return this
end

function UniqueData:CanMoveToOwner(owner, region)
	if StringHelpers.IsNullOrEmpty(owner) then
		return false
	end
	--local inventoryOwner = GetInventoryOwner(self.UUID)
	if owner ~= nil 
	and ObjectExists(owner) == 1
	and CharacterIsDead(owner) == 0
	and GetRegion(owner) == region
	then
		return true
	end
	return false
end

---@param item EsvItem
---@return string
local function TryGetOwner(item, inventoryOnly)
	if inventoryOnly ~= true then
		if item.OwnerHandle ~= nil then
			local object = Ext.GetGameObject(item.OwnerHandle)
			if object ~= nil then
				return object.MyGuid
			end
		end
	end
	-- if item.ParentInventoryHandle ~= nil then
	-- 	local object = Ext.GetGameObject(item.ParentInventoryHandle)
	-- 	if object ~= nil then
	-- 		return object.MyGuid
	-- 	end
	-- end
	local inventory = StringHelpers.GetUUID(GetInventoryOwner(item.MyGuid))
	if not StringHelpers.IsNullOrEmpty(inventory) then
		return inventory
	end
	return nil
end

function UniqueData:GetOwner(itemUUID)
	if self.UUID == itemUUID then
		return self.Owner
	else
		local copyOwner = self.Copies[itemUUID]
		if copyOwner ~= nil then
			local item = Ext.GetItem(itemUUID)
			if item ~= nil then
				return TryGetOwner(item)
			end
		end
	end
	return nil
end

local function GetUUIDAndOwner(self, uuid)
	if uuid == nil then
		uuid = self.UUID
	end
	local owner = self:GetOwner(uuid)
	return uuid,owner
end

---@return boolean
function UniqueData:IsReleasedFromOwner(uuid)
	local uuid,owner = GetUUIDAndOwner(self, uuid)
	if ObjectGetFlag(uuid, "LLWEAPONEX_UniqueData_ReleaseFromOwner") == 1 then
		return true
	elseif owner ~= nil and IsPlayer(owner) then
		return true
	end
	return false
end

function UniqueData:ReleaseFromOwner(unequip, uuid)
	local uuid,owner = GetUUIDAndOwner(self, uuid)
	ObjectSetFlag(uuid, "LLWEAPONEX_UniqueData_ReleaseFromOwner", 0)
	if unequip == true and owner ~= nil then
		ItemLockUnEquip(uuid, 0)
		CharacterUnequipItem(owner, uuid)
		ItemClearOwner(uuid)
	end
	if uuid == self.UUID then
		self.Owner = nil
	end
end

function UniqueData:SetOwner(uuid, owner)
	if uuid == nil then
		uuid = self.UUID
	end
	if self.Copies[uuid] ~= nil then
		self.Copies[uuid] = owner
	elseif uuid == self.UUID then
		self.Owner = owner
	end
end

function UniqueData:ResetRelease(uuid)
	local uuid,owner = GetUUIDAndOwner(self, uuid)
	ObjectClearFlag(uuid, "LLWEAPONEX_UniqueData_ReleaseFromOwner", 0)
end

---@param self UniqueData
---@param region string
---@param item EsvItem|nil
local function MoveToRegionPosition(self, region, item)
	local targetPosition = self.LevelData[region]
	if targetPosition ~= nil then
		local x,y,z,pitch,yaw,roll = table.unpack(targetPosition)
		local host = CharacterGetHostCharacter()
		TeleportTo(self.UUID, host, "", 0, 1, 0)
		ItemToTransform(self.UUID, x,y,z,pitch,yaw,roll,1,nil)
	else
		-- Fallback
		if self.CanMoveToVendingMachine ~= false then
			ItemToInventory(self.UUID, NPC.VendingMachine, 1, 0, 0)
		else
			ItemToInventory(self.UUID, NPC.UniqueHoldingChest, 1, 0, 0)
		end
	end
end

function UniqueData:OnItemLeveledUp(uuid)
	self:ApplyProgression(self.ProgressionData)
end

function UniqueData:AddCopy(uuid, owner)
	if owner == nil then
		uuid,owner = GetUUIDAndOwner(self, uuid)
	end
	if self.Copies[uuid] ~= owner then
		self.Copies[uuid] = owner
		PersistentVars.ExtraUniques[uuid] = self.Tag
		Ext.PrintWarning(string.format("[LLWEAPONEX:UniqueData:AddCopy] Found a copy of a unique. Tag(%s) Copy(%s) Owner(%s)", self.Tag, uuid, owner))
	end
end

function UniqueData:FindPlayerCopies()
	if not StringHelpers.IsNullOrEmpty(self.Tag) then
		for i,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
			local player = StringHelpers.GetUUID(db[1])
			local taggedItem = StringHelpers.GetUUID(CharacterFindTaggedItem(player, self.Tag))
			if not StringHelpers.IsNullOrEmpty(taggedItem) and taggedItem ~= self.UUID then
				self:AddCopy(taggedItem, player)
			end
		end
	end
end

function UniqueData:Initialize(region, firstLoad, uuid)
	if uuid == nil then
		uuid = self.UUID
	end
	if ObjectExists(uuid) == 0 and self.Copies ~= nil then
		for copyUUID,copyOwner in pairs(self.Copies) do
			if ObjectExists(uuid) == 1 then
				self.UUID = copyUUID
				uuid = self.UUID
				break
			end
		end
	end
	if ObjectExists(uuid) == 1 then
		local item = Ext.GetItem(uuid)
		if self.Owner == nil then
			local owner = TryGetOwner(item)
			if owner == NPC.UniqueHoldingChest then
				owner = nil
			end
			if owner ~= nil then
				self.Owner = owner
			end
		end
		if firstLoad == true then
			self:ApplyProgression(self.ProgressionData, nil, item, true)
		end
		if not self:IsReleasedFromOwner() then
			self.Initialized = ObjectGetFlag(uuid, "LLWEAPONEX_UniqueData_Initialized") == 1
			if item.CurrentLevel ~= region then
				if not self.Initialized then
					local targetOwner = self.DefaultOwner
					if type(self.DefaultOwner) == "table" then
						targetOwner = self.DefaultOwner[region] or self.DefaultOwner["Any"]
					end
					if self:CanMoveToOwner(targetOwner, region) then
						self:Transfer(targetOwner, self.AutoEquipOnOwner)
					else
						MoveToRegionPosition(self, region, item)
					end
					ObjectSetFlag(uuid, "LLWEAPONEX_UniqueData_Initialized", 0)
				else
					if self.Owner == NPC.VendingMachine and not self.CanMoveToVendingMachine then
						local linkedItem = UniqueManager.GetLinkedUnique(uuid)
						if linkedItem ~= nil then
							local linkedOwner = TryGetOwner(Ext.GetItem(linkedItem))
							if linkedOwner == NPC.UniqueHoldingChest then
								-- Skip moving out of the vending machine
							else
								ItemToInventory(uuid, NPC.UniqueHoldingChest, 1, 0, 0)
							end
						else
							ItemToInventory(uuid, NPC.UniqueHoldingChest, 1, 0, 0)
						end
					end
				end
				self.Initialized = true
			end
		elseif self.Owner == nil then
			if item.CurrentLevel ~= region then
				MoveToRegionPosition(self, region, item)
			end
		end
		printd("Unique initialized:", uuid, item.DisplayName, self.Owner)
	end
end

function UniqueData:AddPosition(region,x,y,z,rx,ry,rz)
	self.LevelData[region] = {
		x,y,z,
		0.0174533 * rx,
		0.0174533 * ry,
		0.0174533 * rz
	}
end

function UniqueData:Equip(target, uuid)
	local uuid,owner = GetUUIDAndOwner(self, uuid)
	if ObjectExists(uuid) == 0 then
		Ext.PrintError("[UniqueData:Equip] Item", uuid, "does not exist!")
		return
	end
	local item = Ext.GetItem(uuid)
	local locked = item.UnEquipLocked
	ItemLockUnEquip(uuid, 0)
	CharacterEquipItem(target, uuid)
	if self.OnEquipped ~= nil then
		pcall(self.OnEquipped, self, target)
	end
	if locked then
		ItemLockUnEquip(uuid, 1)
	end
end

function UniqueData:Transfer(target, equip, uuid)
	local uuid,owner = GetUUIDAndOwner(self, uuid)
	if target == "host" then target = CharacterGetHostCharacter() end
	if ObjectExists(uuid) == 0 then
		Ext.PrintError("[UniqueData:Transfer] Item", uuid, "does not exist!")
		return false
	elseif ObjectExists(target) == 0 then
		Ext.PrintError("[UniqueData:Transfer] Target", target, "does not exist!")
		return false
	end
	self.Owner = target

	if GetInventoryOwner(uuid) ~= target then
		ItemLockUnEquip(uuid, 0)
		ItemToInventory(uuid, target, 1, 1, 1)
	end
	if equip == true then
		self:Equip(target, uuid)
	end
end

function UniqueData:ClearOwner()
	self.Owner = nil
end

---@param entry UniqueProgressionEntry
---@param stat StatEntryWeapon
---@param item EsvItem
local function ApplyProgressionEntry(entry, stat, item, changes, firstLoad)
	local statChanged = false
	if not StringHelpers.IsNullOrEmpty(entry.MatchStat) then
		if stat ~= entry.MatchStat then
			return false
		end
	end
	if Ext.Version() < 53 then
		Ext.EnableExperimentalPropertyWrites()
	end
	local target = stat
	if entry.IsBoost == true then
		target = item.Stats.DynamicStats[2]
	end
	local attribute = entry:GetBoostAttribute(stat)
	if attribute == "ExtraProperties" then
		local props = target.ExtraProperties or {}
		if not string.find(Common.Dump(props), entry.Value.Action) then
			table.insert(props, entry.Value)
			statChanged = true
		end
	elseif attribute == "WeaponRange" then
		entry.Value = math.ceil(entry.Value / 100)
	elseif attribute == "Boosts" or attribute == "Skills" then
		local current = target[attribute]
		if current ~= "" then
			local boostNames = StringHelpers.Split(entry.Value, ";")
			for i,v in pairs(boostNames) do
				if not string.find(current, v) then
					target[attribute] = current .. ";" .. v
					statChanged = true
				end
			end
		else
			target[attribute] = entry.Value
			statChanged = true
		end
	else
		printd(stat.Name, attribute, target[attribute], "=>", entry.Value)
		target[attribute] = entry.Value
		statChanged = true
	end
	if statChanged or firstLoad == true then
		changes.Boosts[attribute] = target[attribute]
	end
	return statChanged
end

---@param self UniqueData
---@param item EsvItem
---@param template string
---@param stat string
---@param level integer
local function CloneItem(self, item, template, stat, level)
	local constructor = Ext.CreateItemConstructor(item)
	---@type ItemDefinition
	local props = constructor[1]
	props.GoldValueOverwrite = math.floor(item.Stats.Value * 0.4)

	if item.ItemType == "Weapon" then
		-- Damage type fix
		-- Deltamods with damage boosts may make the weapon's damage type be all of that type, so overwriting the statType
		-- fixes this issue.
		local damageTypeString = Ext.StatGetAttribute(stat, "Damage Type")
		if damageTypeString == nil then damageTypeString = "Physical" end
		local damageTypeEnum = LeaderLib.Data.DamageTypeEnums[damageTypeString]
		props.DamageTypeOverwrite = damageTypeEnum
	end

	props.GenerationStatsId = stat
	props.StatsEntryName = stat
	props.IsIdentified = true
	props.OriginalRootTemplate = template
	props.RootTemplate = template
	props.DeltaMods = item.GetDeltaMods()
	props.GenerationLevel = level
	props.StatsLevel = level

	local cloned = constructor:Construct()
	if cloned ~= nil then
		ItemSetOwner(cloned.MyGuid, self.Owner)
		ItemToInventory(cloned, self.Owner, 1, 0, 0)
		PersistentVars.ExtraUniques[cloned.MyGuid] = self.Tag
		self.UUID = cloned.MyGuid
		ItemRemove(item.MyGuid)
	else
		Ext.PrintError("Error constructing item?", item.MyGuid)
	end
end

---@param self UniqueData
---@param item EsvItem
---@param template string
---@param stat string
---@param level integer
local function TransformItem(self, item, template, stat, level, matchStat, matchTemplate)
	local currentTemplate = StringHelpers.GetUUID(GetTemplate(item.MyGuid))
	if currentTemplate == StringHelpers.GetUUID(template) then
		return true
	end
	if not StringHelpers.IsNullOrEmpty(matchTemplate) then
		if currentTemplate ~= matchTemplate then
			return false
		end
	end
	if not StringHelpers.IsNullOrEmpty(matchStat) then
		if item.StatsId ~= matchStat then
			return false
		end
	end
	local slot = ""
	local owner = GetInventoryOwner(item.MyGuid)
	if not StringHelpers.IsNullOrEmpty(owner) ~= nil and ObjectIsCharacter(owner) then
		local character = Ext.GetCharacter(owner)
		if character ~= nil then
			for _,slotid in LeaderLib.Data.VisibleEquipmentSlots:Get() do
				if StringHelpers.GetUUID(CharacterGetEquippedItem(character.MyGuid, slotid)) == item.MyGuid then
					slot = slotid
					break
				end
			end
			if slot ~= "" then
				CharacterUnequipItem(character.MyGuid, item.MyGuid)
			end
		end
	end
	local deltamods = item:GetDeltaMods()
	Transform(item.MyGuid, template, 1, 1, 1)
	if not StringHelpers.IsNullOrEmpty(stat) then
		item.StatsId = stat
	end

	for i,v in pairs(deltamods) do
		if not ItemHasDeltaModifier(item.MyGuid, v) then
			ItemAddDeltaModifier(item.MyGuid, v)
		end
	end

	ItemLevelUpTo(item.MyGuid, level)

	if not StringHelpers.IsNullOrEmpty(slot) and not StringHelpers.IsNullOrEmpty(owner) then
		StartOneshotTimer("Timers_LLWEAPONEX_PostTransformEquip", 250, function()
			NRD_CharacterEquipItem(owner, item.MyGuid, slot, 0, 0, 1, 1)
		end)
	end
	return true
end

if Vars.DebugEnabled then
	function UniqueData:TryTransform(template)
		local item = Ext.GetItem(self.UUID)
		local level = CharacterGetLevel(CharacterGetHostCharacter())
		TransformItem(self, item, template, nil, level)
	end
end

local function EvaluateEntry(self, progressionTable, persist, item, level, stat, entry, changes, firstLoad)
	local statChanged = false
	if entry.Type == "UniqueProgressionEntry" then
		if ApplyProgressionEntry(entry, stat, item, changes, firstLoad) then
			statChanged = true
		end
	elseif entry.Type == "UniqueProgressionTransform" then
		if not StringHelpers.IsNullOrEmpty(entry.Template) then
			if TransformItem(self, item, entry.Template, entry.Stat, level, entry.MatchStat, entry.MatchTemplate) then
				statChanged = true
			end
		end
	elseif #entry > 0 then
		for i,v in pairs(entry) do
			if v.Type == "UniqueProgressionEntry" then
				if ApplyProgressionEntry(v, stat, item, changes, firstLoad) then
					statChanged = true
				end
			elseif v.Type == "UniqueProgressionTransform" then
				if not StringHelpers.IsNullOrEmpty(entry.Template) then
					if TransformItem(self, item, v.Template, v.Stat, level, v.MatchStat, v.MatchTemplate) then
						statChanged = true
					end
				end
			end
		end
	end
	return statChanged
end

local BoostAttributes = {
	--Durability = "integer",
	--DurabilityDegradeSpeed = "integer",
	StrengthBoost = "integer",
	FinesseBoost = "integer",
	IntelligenceBoost = "integer",
	ConstitutionBoost = "integer",
	MemoryBoost = "integer",
	WitsBoost = "integer",
	--SightBoost = "integer",
	--HearingBoost = "integer",
	VitalityBoost = "integer",
	SourcePointsBoost = "integer",
	MaxAP = "integer",
	StartAP = "integer",
	APRecovery = "integer",
	AccuracyBoost = "integer",
	DodgeBoost = "integer",
	LifeSteal = "integer",
	CriticalChance = "integer",
	ChanceToHitBoost = "integer",
	MovementSpeedBoost = "integer",
	RuneSlots = "integer",
	RuneSlots_V1 = "integer",
	FireResistance = "integer",
	AirResistance = "integer",
	WaterResistance = "integer",
	EarthResistance = "integer",
	PoisonResistance = "integer",
	--ShadowResistance = "integer",
	PiercingResistance = "integer",
	--CorrosiveResistance = "integer",
	PhysicalResistance = "integer",
	--MagicResistance = "integer",
	--CustomResistance = "integer",
	Movement = "integer",
	Initiative = "integer",
	Willpower = "integer",
	Bodybuilding = "integer",
	MaxSummons = "integer",
	--Value = "integer",
	--Weight = "integer",
	Skills = "string",
	--ItemColor = "string",
	--ModifierType = "integer",
	--ObjectInstanceName = "string",
	--BoostName = "string",
	--StatsType = "string",
}

local WeaponBoosts = {
	DamageType = "integer",
	MinDamage = "integer",
	MaxDamage = "integer",
	DamageBoost = "integer",
	DamageFromBase = "integer",
	CriticalDamage = "integer",
	WeaponRange = "integer",
	CleaveAngle = "integer",
	CleavePercentage = "integer",
	AttackAPCost = "integer",
}

local ArmorBoosts = {
	ArmorValue = "integer",
	ArmorBoost = "integer",
	MagicArmorValue = "integer",
	MagicArmorBoost = "integer",
	Blocking = "integer",
}

local function ResetBoostAttributes(tbl, target, changes)
	for boost,type in pairs(tbl) do
		if target[boost] ~= nil then
			if type == "integer" then
				changes.Boosts[boost] = 0
				target[boost] = 0
			elseif type == "string" then
				changes.Boosts[boost] = ""
				target[boost] = ""
			end
		end
	end
end

local function ResetUnique(item, stat, level, changes)
	local target = item.Stats.DynamicStats[2]
	ResetBoostAttributes(BoostAttributes, target, changes)
	local itemType = item.ItemType
	if itemType == "Weapon" then
		ResetBoostAttributes(WeaponBoosts, target, changes)
	elseif itemType == "Armor" or itemType == "Shield" then
		ResetBoostAttributes(ArmorBoosts, target, changes)
	end
	local originalValues = Temp.OriginalUniqueStats[item.StatsId]
	if originalValues ~= nil then
		for attribute,value in pairs(originalValues) do
			if attribute == "Damage Range" then
				local damage = Game.Math.GetLevelScaledWeaponDamage(level)
				local baseDamage = damage * (stat.DamageFromBase * 0.01)
				local range = baseDamage * (stat["Damage Range"] * 0.01)
				local min = Ext.Round(baseDamage - (range/2))
				local max = Ext.Round(baseDamage + (range/2))
				changes.Boosts["MinDamage"] = min
				changes.Boosts["MaxDamage"] = max
			else
				if attribute == "WeaponRange" then
					value = math.ceil(value / 100)
				end
				changes.Stats[attribute] = value
				stat[attribute] = value
			end
		end
	end
end

---@param self UniqueData
---@param item EsvItem
local function TryApplyProgression(self, progressionTable, persist, item, level, changes, firstLoad)
	local statChanged = false
	if progressionTable ~= nil then
		local stat = Ext.GetStat(item.StatsId, level)
		for i=1,level do
			local entries = progressionTable[i]
			if entries ~= nil then
				if EvaluateEntry(self, progressionTable, persist, item, level, stat, entries, changes, firstLoad) then
					statChanged = true
				end
			end
		end
		if firstLoad == true then
			ResetUnique(item, stat, level, changes)
		end
		if statChanged or firstLoad == true then
			if persist == nil then
				persist = false
			end
			Ext.SyncStat(item.StatsId, persist)
		end
		item.Stats.ShouldSyncStats = true
	end
	return statChanged or firstLoad == true
end

---@param item EsvItem
local function StartApplyingProgression(self, progressionTable, persist, item, firstLoad)
	-- TODO - Testing. Making sure bonuses don't overlap if they're set to append when you save/load/change level/level up etc.
	-- Maybe they all need to be replacements to avoid that potential issue, in which case the stats need to be reviewed to make sure the progression
	-- enries aren't nerfing things.
	local level = item.Stats.Level
	local changes = {
		Boosts = {},
		Stats = {}
	}
	local b,result = xpcall(TryApplyProgression, debug.traceback, self, progressionTable, persist, item, level, changes, firstLoad)
	if not b then
		Ext.PrintError("[LLWEAPONEX] Error applying progression to unique", item.MyGuid, item.StatsId)
		Ext.PrintError(result)
	elseif result == true or firstLoad == true then
		if changes ~= nil and Common.TableHasAnyEntry(changes) then
			if changes.Stats["Damage Range"] ~= nil then
				local damage = Game.Math.GetLevelScaledWeaponDamage(level)
				local baseDamage = damage * (item.Stats.DamageFromBase * 0.01)
				local range = baseDamage * (item.Stats["Damage Range"] * 0.01)
				local min = Ext.Round(baseDamage - (range/2))
				local max = Ext.Round(baseDamage + (range/2))
				changes.Boosts["MinDamage"] = min
				changes.Boosts["MaxDamage"] = max
				changes.Stats["Damage Range"] = nil
			end
			EquipmentManager.SyncItemStatChanges(item, changes)
			if self.Copies ~= nil then
				for uuid,owner in pairs(self.Copies) do
					if uuid ~= item.MyGuid then
						local copyItem = Ext.GetItem(uuid)
						if copyItem ~= nil then
							EquipmentManager.SyncItemStatChanges(copyItem, changes)
						end
					end
				end
			end
		end
	end
end

---@param progressionTable table<integer,UniqueProgressionEntry|UniqueProgressionEntry[]>
---@param persist boolean
---@param item EsvItem
---@param firstLoad boolean|nil
function UniqueData:ApplyProgression(progressionTable, persist, item, firstLoad)
	progressionTable = progressionTable or self.ProgressionData
	if item == nil then
		item = Ext.GetItem(self.UUID)
		if item == nil then
			if Common.TableHasAnyEntry(self.Copies) then
				for uuid,owner in pairs(self.Copies) do
					local copyItem = Ext.GetItem(uuid)
					if copyItem ~= nil then
						item = copyItem
						break
					end
				end
			end
		end
		if item == nil then
			Ext.PrintError("[WeaponExpansion] Failed to get item object for", self.UUID, self.Tag)
		end
	end
	if item ~= nil then
		StartApplyingProgression(self, progressionTable, persist, item, firstLoad)
		self.LastProgressionLevel = item.Stats.Level
	end
end

return UniqueData