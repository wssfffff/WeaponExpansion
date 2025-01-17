local ts = Classes.TranslatedString
local rb = MasteryDataClasses.MasteryBonusData
local _ISCLIENT = Ext.IsClient()

local _eqSet = "Class_Rogue_Lizards"

local ThrowingKnifeBonus = rb:Create("DAGGER_THROWINGKNIFE", {
	Skills = {"Projectile_ThrowingKnife", "Projectile_EnemyThrowingKnife"},
	Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_ThrowingKnife")
})

MasteryBonusManager.Vars.ThrowingKnifeBonusDamageSkills = {
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison",
	"Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive",
}

---@param self MasteryBonusData
---@param e OnSkillStateHitEventArgs
---@param bonuses MasteryBonusCallbackBonuses
local function ThrowingKnifeBonus_Hit(self, e, bonuses)
	if e.Data.Success then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_ThrowingKnife_Chance", 25)
		if GameHelpers.Math.Roll(chance) then
			GameHelpers.Skill.Explode(e.Data.Target, Common.GetRandomTableEntry(MasteryBonusManager.Vars.ThrowingKnifeBonusDamageSkills), e.Character)
		end
	end
end

---@param self MasteryBonusData
---@param e OnSkillStateProjectileHitEventArgs
---@param bonuses MasteryBonusCallbackBonuses
local function ThrowingKnifeBonus_ProjectileHit(self, e, bonuses)
	--Targeted a position instead of an object
	if StringHelpers.IsNullOrEmpty(e.Data.Target) and e.Data.Position then
		local chance = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_ThrowingKnife_Chance", 25)
		if chance > 0 and GameHelpers.Math.Roll(chance) then
			GameHelpers.Skill.Explode(e.Data.Position, Common.GetRandomTableEntry(MasteryBonusManager.Vars.ThrowingKnifeBonusDamageSkills), e.Character)
		end
	end
end

ThrowingKnifeBonus.Register.SkillHit(ThrowingKnifeBonus_Hit).SkillProjectileHit(ThrowingKnifeBonus_ProjectileHit)

local SneakingPassiveBonus = rb:Create("DAGGER_SNEAKINGBONUS", {
	Skills = {"ActionSkillSneak"},
	Statuses = {"SNEAKING", "INVISIBLE"},
	Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_SneakingBonus", "<font color='#F19824'>For every turn spent [Key:INVISIBLE_DisplayName] or [Handle:h6bf7caf0g7756g443bg926dg1ee5975ee133:Sneaking] [Handle:h2c990ecagc680g4c68g88ccgb5358faa4e33:in combat], gain an increasing damage boost for one attack.</font>"),
	MasteryMenuSettings = {
		OnlyUseTable = "Status",
	}
})

if not _ISCLIENT then
	local function IncreaseSneakingDamageBoost(target, turns)
		local target = GameHelpers.GetCharacter(target)
		if target then
			turns = turns or PersistentVars.MasteryMechanics.SneakingTurnsInCombat[target.MyGuid] or 0
			if turns > 0 then
				local bonusStatus = Ext.PrepareStatus(target.Handle, "LLWEAPONEX_MASTERYBONUS_DAGGER_SNEAKINGBONUS", -1)
				if bonusStatus then
					bonusStatus.StatusSourceHandle = target.Handle
					bonusStatus.ForceStatus = true
					local maxBoost = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_SneakingBonus_MaxMultiplier", 10.0)
					local turnBoost = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_SneakingBonus_TurnBoost", 5.0)
					local nextBoost = math.max(1.0, math.min(maxBoost, math.ceil((turns - 1) * turnBoost)))
					if bonusStatus.StatsMultiplier ~= nextBoost then
						CharacterStatusText(target.MyGuid, string.format("Assassin's Patience Increased (%i)", turns))
					end
					bonusStatus.StatsMultiplier = nextBoost
					Ext.ApplyStatus(bonusStatus)
				end
			end
		end
	end

	local function OnSneakingOrInvisible(e)
		Timer.Cancel("LLWEAPONEX_ClearDaggerSneakingBonus", e.TargetGUID)
		local debugIgnoreCombat = Vars.DebugMode and e.Character:HasTag("LLWEAPONEX_MasteryTestCharacter")
		if GameHelpers.Character.IsInCombat(e.Target) or debugIgnoreCombat then
			if PersistentVars.MasteryMechanics.SneakingTurnsInCombat[e.TargetGUID] == nil then
				TurnCounter.CountUp("LLWEAPONEX_Dagger_SneakingBonus", 0, GameHelpers.Combat.GetID(e.TargetGUID), {
					Target = e.TargetGUID,
					Infinite = true,
					OutOfCombatSpeed = debugIgnoreCombat and 0.5 or nil,
					CombatOnly = not debugIgnoreCombat
				})
			end
			IncreaseSneakingDamageBoost(e.TargetGUID)
		end
	end

	local function OnSneakingOrInvisibleLost(e)
		Timer.StartObjectTimer("LLWEAPONEX_ClearDaggerSneakingBonus", e.TargetGUID, 500)
	end
	
	SneakingPassiveBonus.Register.StatusApplied(OnSneakingOrInvisible, "Target", "SNEAKING").StatusApplied(OnSneakingOrInvisible, "Target", "INVISIBLE", true)
	.StatusRemoved(OnSneakingOrInvisibleLost, "Target", "SNEAKING")
	.StatusRemoved(OnSneakingOrInvisibleLost, "Target", "INVISIBLE", true)
	.TurnCounter("LLWEAPONEX_Dagger_SneakingBonus", function (self, e, bonuses)
		local target = e.Data.Target
		if target then
			if GameHelpers.Character.IsSneakingOrInvisible(target) then
				PersistentVars.MasteryMechanics.SneakingTurnsInCombat[target] = e.Turn
				IncreaseSneakingDamageBoost(target, e.Turn)
				if e.Turn >= 3 then
					TurnCounter.ClearTurnCounter("LLWEAPONEX_Dagger_SneakingBonus", target)
					SignalTestComplete(self.ID)
				end
			else
				Timer.StartObjectTimer("LLWEAPONEX_ClearDaggerSneakingBonus", target, 250)
			end
		end
	end).Osiris("ObjectLeftCombat", 2, "after", function (charGUID)
		charGUID = StringHelpers.GetUUID(charGUID)
		if PersistentVars.MasteryMechanics.SneakingTurnsInCombat[charGUID] then
			Timer.StartObjectTimer("LLWEAPONEX_ClearDaggerSneakingBonus", charGUID, 500)
		end
	end, true).Test(function (test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = function()
			cleanup()
			TurnCounter.ClearTurnCounter("LLWEAPONEX_Dagger_SneakingBonus", char)
			PersistentVars.MasteryMechanics.SneakingTurnsInCombat[char] = nil
		end
		test:Wait(250)
		local x,y,z = table.unpack(GameHelpers.Math.ExtendPositionWithForwardDirection(dummy, 2.0))
		TeleportToPosition(char, x,y,z, "", 0, 1)
		test:Wait(250)
		ApplyStatus(char, "INVISIBLE", -1, 1, char)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		test:Wait(1000)
		return true
	end)

	Timer.Subscribe("LLWEAPONEX_ClearDaggerSneakingBonus", function (e)
		if e.Data.UUID then
			PersistentVars.MasteryMechanics.SneakingTurnsInCombat[e.Data.UUID] = nil
			TurnCounter.ClearTurnCounter("LLWEAPONEX_Dagger_SneakingBonus", e.Data.UUID)
		end
		if e.Data.Object then
			GameHelpers.Status.Remove(e.Data.Object, "LLWEAPONEX_MASTERYBONUS_DAGGER_SNEAKINGBONUS")
		end
	end)
end

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 1, {
	ThrowingKnifeBonus,
	SneakingPassiveBonus
})

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 2, {
	rb:Create("DAGGER_BACKLASH", {
		Skills = {"MultiStrike_Vault", "MultiStrike_EnemyVault"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_BacklashBonus", "<font color='#F19824'>Attacking a target hit by [Key:Projectile_ThrowingKnife_DisplayName] grants [Special:LLWEAPONEX_MB_BacklashAPBonus] AP and refreshs the cooldown of [Key:Projectile_ThrowingKnife_DisplayName]</font>")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success and GameHelpers.Status.IsActive(e.Data.TargetObject, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET") then
			local sourceObject = GameHelpers.Status.GetSourceByID(e.Data.TargetObject, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET")
			if sourceObject and sourceObject.MyGuid == e.Character.MyGuid then
				GameHelpers.Status.Remove(e.Data.Target, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET")
				local sourceSkill = e.Character.SkillManager.Skills.Projectile_EnemyThrowingKnife and "Projectile_EnemyThrowingKnife" or "Projectile_ThrowingKnife"
				GameHelpers.Skill.SetCooldown(e.Character, sourceSkill, 0.0)
				local apCost = GameHelpers.Stats.GetAttribute(sourceSkill, "ActionPoints", 0)
				if apCost > 1 then
					local refundMult = math.min(100, math.max(0, GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_Backlash_APRefundPercentage", 50)))
					if refundMult > 0 then
						if refundMult > 1 then
							refundMult = refundMult * 0.01
						end
						local apBonus = math.max(1, math.floor(apCost * refundMult))
						CharacterAddActionPoints(e.CharacterGUID, apBonus)
					end
				end
				SignalTestComplete(self.ID)
			end
		end
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		test:Wait(1000)
		GameHelpers.Skill.Explode(dummy, "Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive", char, {HitObject=dummy, SkillOverrides={ExplodeRadius=0}})
		test:Wait(500)
		test:AssertEquals(HasActiveStatus(dummy, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET") == 1, true, "LLWEAPONEX_MASTERYBONUS_THROWINGKNIFE_TARGET not applied to target")
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		return true
	end),

	rb:Create("DAGGER_SERRATED_RUPTURE", {
		Skills = {"Target_SerratedEdge", "Target_EnemySerratedEdge"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_SerratedEdgeBonus", "<font color='#F19824'>Deal an additional [SkillDamage:Projectile_LLWEAPONEX_MasteryBonus_Dagger_RuptureBonusDamage] to targets with [Key:BLEEDING_DisplayName].</font>")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success and e.Data.TargetObject:GetStatus("BLEEDING") then
			GameHelpers.Damage.ApplySkillDamage(e.Character, e.Data.Target, "Projectile_LLWEAPONEX_MasteryBonus_Dagger_RuptureBonusDamage", {HitParams=HitFlagPresets.GuaranteedWeaponHit})
			if GameHelpers.Ext.ObjectIsCharacter(e.Data.TargetObject) then
				CharacterStatusText(e.Data.Target, GameHelpers.GetStringKeyText("LLWEAPONEX_RUPTURE_DisplayName", "Ruptured"))
			end
			SignalTestComplete(self.ID)
		end
	end).Test(function(test, self)
		local char,dummy,cleanup = WeaponExTesting.CreateTemporaryCharacterAndDummy(test, nil, _eqSet, nil, true)
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(char, dummy, "", 0, 1, 1)
		CharacterSetFightMode(char, 1, 1)
		ApplyStatus(dummy, "BLEEDING", -1, 1, char)
		test:Wait(500)
		CharacterUseSkill(char, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 30000)
		test:AssertGotSignal(self.ID)
		return true
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 3,{
	rb:Create("DAGGER_THROWINGKNIFE2", {
		Skills = {"Projectile_FanOfKnives", "Projectile_EnemyFanOfKnives"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_ThrowingKnife2", "<font color='#F19824'>Each knife thrown has a <font color='#CC33FF'>[ExtraData:LLWEAPONEX_MB_Dagger_ThrowingKnife_Chance]%</font> to be <font color='#00FFAA'>coated in poison or explosive oil</font>, dealing [SkillDamage:Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Explosive] or [SkillDamage:Projectile_LLWEAPONEX_DaggerMastery_ThrowingKnife_Poison] on hit.</font>")
	}).Register.SkillHit(ThrowingKnifeBonus_Hit).SkillProjectileHit(ThrowingKnifeBonus_ProjectileHit),

	rb:Create("DAGGER_CORRUPTED_BLADE", {
		Skills = {"Target_CorruptedBlade", "Target_EnemyCorruptedBlade"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_CorruptedBlade", "<font color='#F19824'>When the target dies at any point, spread [Special:LLWEAPONEX_MB_Dagger_CorruptedStatuses] to a nearby enemy within [ExtraData:LLWEAPONEX_MB_Dagger_CorruptedBlade_SpreadRadius]m.</font>")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			local listenDelay = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_CorruptedBlade_DeathListenDuration", -1)
			DeathManager.ListenForDeath("CorruptedBladeDiseaseSpread", e.Data.Target, e.Character, listenDelay)
		end
	end).Test(function(test, self)
		local characters,_,cleanup = Testing.Utils.CreateTestCharacters({EquipmentSet=_eqSet, TotalDummies=0, TotalCharacters=2,})
		local character = characters[1]
		local dummy = characters[2]
		test.Cleanup = cleanup
		test:Wait(250)
		TeleportTo(character, dummy, "", 0, 1, 1)
		test:Wait(1000)
		GameHelpers.GetCharacter(dummy).Stats.CurrentVitality = 1
		CharacterUseSkill(character, self.Skills[1], dummy, 1, 1, 1)
		test:WaitForSignal(self.ID, 10000)
		test:AssertGotSignal(self.ID)
		return true
	end)
})

MasteryBonusManager.AddRankBonuses(MasteryID.Dagger, 4, {
	rb:Create("DAGGER_FATALITY", {
		Skills = {"Target_Fatality", "Target_EnemyFatality"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_FatalityBonus")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			e.Data:ConvertAllDamageTo("Piercing")
			DeathManager.ListenForDeath("FatalityRefundBonus", e.Data.Target, e.Character, 1000)
		end
	end),

	rb:Create("DAGGER_CRUELTY", {
		--The corpse explosion can proc the bonus as well
		Skills = {"Target_TerrifyingCruelty", "Target_EnemyTerrifyingCruelty", "Target_EnemyTerrifyingCruelty_Gheist", 
		"Projectile_LLWEAPONEX_MasteryBonus_Dagger_CrueltyCorpseExplosion"},
		Tooltip = ts:CreateFromKey("LLWEAPONEX_MB_Dagger_CrueltyBonus")
	}).Register.SkillHit(function(self, e, bonuses)
		if e.Data.Success then
			DeathManager.ListenForDeath("TerrifyingCrueltyBonus", e.Data.Target, e.Character, 500)
		end
	end)
})

if not _ISCLIENT then
	local function TargetIsEnemy(t, source, status)
		return GameHelpers.Character.CanAttackTarget(t, source, false)
	end

	DeathManager.OnDeath:Subscribe(function (e)
		local radius = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_CorruptedBlade_SpreadRadius", 12.0)
		local pos = GameHelpers.Math.GetPosition(e.Target, false, GameHelpers.Math.GetPosition(e.Source))
		local props = GameHelpers.Stats.GetSkillProperties("Target_CorruptedBlade")
		if not props or #props == 0 then
			--If Corrupted Blade applies no statuses, apply Diseased.
			GameHelpers.Status.Apply(pos, "DISEASED", 12.0, true, e.Source, radius, false, 
			TargetIsEnemy)
		else
			for _,prop in pairs(props) do
				if prop.Type == "Status" and prop.Duration ~= 0 then
					GameHelpers.Status.Apply(pos, prop.Action, prop.Duration, false, e.Source, radius, false, 
					TargetIsEnemy)
				end
			end
		end
		SignalTestComplete("DAGGER_CORRUPTED_BLADE")
	end, {MatchArgs={ID="CorruptedBladeDiseaseSpread", Success=true}})

	DeathManager.OnDeath:Subscribe(function (e)
		local cd = GameHelpers.GetExtraData("LLWEAPONEX_MB_Dagger_Fatality_CooldownOverride", 6.0)
		local sourceSkill = e.Source.SkillManager.Skills.Target_EnemyFatality and "Target_EnemyFatality" or "Target_Fatality"
		GameHelpers.Skill.SetCooldown(e.SourceGUID, sourceSkill, cd)
		local skill = Ext.Stats.Get("Target_Fatality", nil, false)
		if skill["Magic Cost"] > 0 then
			CharacterAddSourcePoints(e.SourceGUID, 1)
		end
		if skill.ActionPoints > 1 then
			CharacterAddActionPoints(e.SourceGUID, Ext.Utils.Round(skill.ActionPoints/2))
		end
	end, {MatchArgs={ID="FatalityRefundBonus", Success=true}})

	DeathManager.OnDeath:Subscribe(function (e)
		GameHelpers.Skill.Explode(e.Target, "Projectile_LLWEAPONEX_MasteryBonus_Dagger_CrueltyCorpseExplosion", e.Source)
	end, {MatchArgs={ID="TerrifyingCrueltyBonus", Success=true}})
else

end