SKILL_STATE = LeaderLib.SKILL_STATE

local throwingKnifeBonuses = {
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison",
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive",
}

local function ThrowingKnifeBonus(char, state, funcParams)
	--Ext.Print("[MasteryBonuses:ThrowingKnife] char(",char,") state(",state,") funcParams("..Ext.JsonStringify(funcParams)..")")
	local hasMastery = IsTagged(char, "LLWEAPONEX_Dagger_Mastery1") == 1
	if hasMastery then
		local procSet = ObjectGetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus") == 1
		if state == SKILL_STATE.USED then
			if hasMastery and not procSet and Ext.Random(1,100) <= Ext.ExtraData["LLWEAPONEX_ThrowingKnife_MasteryBonusChance"] then
				-- Position
				if #funcParams == 3 then
					local x = funcParams[1]
					local y = funcParams[2]
					local z = funcParams[3]
					SetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition", x,y,z)
				elseif funcParams[1] ~= nil then
					local x,y,z = GetPosition(funcParams[1])
					SetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition", x,y,z)
				end
				ObjectSetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
			end
		elseif state == SKILL_STATE.CAST then
			if procSet then
				Mods.LeaderLib.StartTimer("LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus", 250, char)
			end
		elseif state == SKILL_STATE.HIT then
			if procSet then
				local target = funcParams[1]
				if target ~= nil then
					Mods.LeaderLib.CancelTimer("LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus", char)
					local explodeSkill = throwingKnifeBonuses[Ext.Random(1,2)]
					local level = CharacterGetLevel(char)
					NRD_ProjectilePrepareLaunch()
					NRD_ProjectileSetString("SkillId", explodeSkill)
					NRD_ProjectileSetInt("CasterLevel", level)
					NRD_ProjectileSetGuidString("Caster", char)
					NRD_ProjectileSetGuidString("Source", char)
					NRD_ProjectileSetGuidString("SourcePosition", target)
					NRD_ProjectileSetGuidString("HitObject", target)
					NRD_ProjectileSetGuidString("HitObjectPosition", target)
					NRD_ProjectileSetGuidString("TargetPosition", target)
					NRD_ProjectileLaunch();
				end
				ObjectClearFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
			end
		end
	end
end

LeaderLib.RegisterSkillListener("Projectile_ThrowingKnife", ThrowingKnifeBonus)

local function ThrowingKnifeDelayedProc(funcParams)
	local char = funcParams[1]
	if char ~= nil and ObjectGetFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus") == 1 then
		local x,y,z = GetVarFloat3(char, "LLWEAPONEX_ThrowingKnife_ExplodePosition")
		local explodeSkill = throwingKnifeBonuses[Ext.Random(1,2)]
		local level = CharacterGetLevel(char)
		NRD_ProjectilePrepareLaunch()
		NRD_ProjectileSetString("SkillId", explodeSkill)
		NRD_ProjectileSetInt("CasterLevel", level)
		NRD_ProjectileSetGuidString("Caster", char)
		NRD_ProjectileSetGuidString("Source", char)
		NRD_ProjectileSetVector3("SourcePosition", x,y,z)
		NRD_ProjectileSetVector3("HitObjectPosition", x,y,z)
		NRD_ProjectileSetVector3("TargetPosition", x,y,z)
		NRD_ProjectileLaunch();
		ObjectClearFlag(char, "LLWEAPONEX_ThrowingKnife_ActivateBonus", 0)
	else
		Ext.Print("ThrowingKnifeDelayedProc params: "..LeaderLib.Common.Dump(funcParams))
	end
end

WeaponExpansion.TimerFinished["LLWEAPONEX_Daggers_ThrowingKnife_ProcBonus"] = ThrowingKnifeDelayedProc