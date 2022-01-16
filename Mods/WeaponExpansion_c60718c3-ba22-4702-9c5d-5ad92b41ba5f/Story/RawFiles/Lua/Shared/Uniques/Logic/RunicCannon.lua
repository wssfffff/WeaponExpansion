if not Vars.IsClient then
	function ArmCannon_OnEnergyChanged(character, item, last, next)
		if Vars.DebugMode then
			Ext.Print(string.format("[LLWEAPONEX:ArmCannon_OnEnergyChanged] character(%s) item(%s) last(%s) next(%s)", character, item, last, next))
		end
		last = tonumber(last)
		next = tonumber(next)
		if next > 0 and last ~= next then
			PlayEffect(character, "RS3_FX_Skills_Soul_Cast_Target_Hand_01_Texkey", "Dummy_R_HandFX")
			PlaySound(character, "LLWEAPONEX_Whoosh_Slow_Deep_All_02")
		end
	end

	function ArmCannon_SyncData(uuid, id)
		local varTable = GameHelpers.Data.GetPersistentVars("WeaponExpansion", true, "SkillData", "RunicCannonCharges")
		if uuid ~= nil then
			local energy = GetVarInteger(uuid, "LLWEAPONEX_ArmCannon_Energy")
			varTable[uuid] = energy
		end
		local data = {}
		for k,v in pairs(varTable) do
			if type(k) == "number" then
				varTable[k] = nil
			else
				local x = Ext.GetItem(k)
				if x ~= nil then
					data[x.NetID] = v
					local weaponUUID = GetVarObject(k, "LLWEAPONEX_ArmCannon_Weapon")
					if not StringHelpers.IsNullOrEmpty(weaponUUID) then
						local weapon = Ext.GetItem(weaponUUID)
						if weapon ~= nil then
							data[weapon.NetID] = v
						end
					end
				end
			end
		end
		if id == nil then
			Ext.BroadcastMessage("LLWEAPONEX_SyncArmCannonData", Ext.JsonStringify(data))
		else
			Ext.PostMessageToUser(id, "LLWEAPONEX_SyncArmCannonData", Ext.JsonStringify(data))
		end
	end

	-- Mods.WeaponExpansion.ArmCannon_DisperseCast(CharacterGetHostCharacter())
	function ArmCannon_DisperseCast(uuid)
		local x,y,z = GetPosition(uuid)
		y = y + 2
		GameHelpers.ExplodeProjectile(uuid, {x,y,z}, "Projectile_LLWEAPONEX_ArmCannon_Disperse_Explosion")
		PlayEffectAtPosition("RS3_FX_Skills_Soul_Impact_Soul_Touch_Hand_01", x, y, z)
	end

	function ArmCannon_OnWeaponSkillHit(source, target, skill)
		Osi.LLWEAPONEX_ArmCannon_OnHit(source, target)
		Osi.LLWEAPONEX_ArmCannon_BlockNextEnergyGain(source, 750)
	end

	---@param data HitData
	local function OnRunicCannonAttack(tag, attacker, target, data, targetIsObject, skill)
		if targetIsObject and (not skill or (skill and not string.find(skill.Name, "LLWEAPONEX_ArmCannon"))) then
			Osi.LLWEAPONEX_ArmCannon_OnHit(attacker.MyGuid, target.MyGuid)
			Osi.LLWEAPONEX_ArmCannon_BlockNextEnergyGain(attacker.MyGuid, 750)
		end
	end

	local registeredListener = false

	Ext.RegisterListener("SessionLoaded", function()
		if not registeredListener then
			AttackManager.OnWeaponTagHit.Register("LLWEAPONEX_RunicCannonEquipped", OnRunicCannonAttack)
			registeredListener = true
		end
	end)
else
	Ext.RegisterNetListener("LLWEAPONEX_SyncArmCannonData", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data ~= nil then
			local varTable = GameHelpers.Data.GetPersistentVars("WeaponExpansion", true, "SkillData", "RunicCannonCharges")
			PersistentVars.SkillData.RunicCannonCharges = data
		end
	end)
end