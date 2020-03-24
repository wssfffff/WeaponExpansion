Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "Shared.lua");

local LLWEAPONEX_GetDescriptionParam = function (skill, character, param)
    if skill.Name == "Projectile_LLWEAPONEX_ChaosSlash" then
        Ext.Print("==GetDescriptionParam==")
        Ext.Print("** Param: " .. LeaderLib.Common.Dump(param))
        Ext.Print("** Character: " .. LeaderLib.Common.Dump(character))
        Ext.Print("** Skill: " .. LeaderLib.Common.Dump(skill))
    end
end

Ext.RegisterListener("SkillGetDescriptionParam", LLWEAPONEX_GetDescriptionParam)

Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "LLWEAPONEX_StatOverrides.lua");
Ext.Require("WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f", "LLWEAPONEX_SkillDamage.lua");

Ext.AddPathOverride("Public\\Game\\GUI\\tooltip.swf", "Public\\WeaponExpansion_c60718c3-ba22-4702-9c5d-5ad92b41ba5f\\GUI\\LLWEAPONEX_ToolTip.swf")
Ext.Print("[WeaponExpansion] Enabled tooltip.swf override.")