---@type TranslatedString
local ts = Classes.TranslatedString
---@type MasteryData
local MasteryData = MasteryDataClasses.MasteryData

---@class MasteryRankDisplayInfo
---@field Name TranslatedString
---@field Color string

---@enum WeaponExpansionMasteryID
MasteryID = {
	Axe = "LLWEAPONEX_Axe",
	Banner = "LLWEAPONEX_Banner",
	BattleBook = "LLWEAPONEX_BattleBook",
	Bludgeon = "LLWEAPONEX_Bludgeon",
	Bow = "LLWEAPONEX_Bow",
	Crossbow = "LLWEAPONEX_Crossbow",
	Dagger = "LLWEAPONEX_Dagger",
	DualShields = "LLWEAPONEX_DualShields",
	Firearm = "LLWEAPONEX_Firearm",
	Greatbow = "LLWEAPONEX_Greatbow",
	HandCrossbow = "LLWEAPONEX_HandCrossbow",
	Katana = "LLWEAPONEX_Katana",
	Pistol = "LLWEAPONEX_Pistol",
	Polearm = "LLWEAPONEX_Polearm",
	Quarterstaff = "LLWEAPONEX_Quarterstaff",
	Rapier = "LLWEAPONEX_Rapier",
	Runeblade = "LLWEAPONEX_Runeblade",
	Scythe = "LLWEAPONEX_Scythe",
	Shield = "LLWEAPONEX_Shield",
	Staff = "LLWEAPONEX_Staff",
	Sword = "LLWEAPONEX_Sword",
	Throwing = "LLWEAPONEX_ThrowingAbility",
	Unarmed = "LLWEAPONEX_Unarmed",
	Wand = "LLWEAPONEX_Wand",
}

---@type table<string,MasteryData>
Masteries = {
["LLWEAPONEX_Axe"] = MasteryData:Create("LLWEAPONEX_Axe", ts:Create("h99253a1dgaaf7g49bbga37fgf2c25b70073f", "Axe"), "#F5785A", {
	[0] = {Name = ts:Create("hf503b6cag1d99g488bga8efgf5ead043493d", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("h25afab32g53ccg4cf6g80cfg6c768304a925", "Novice"), Color="#FFAAAA"},
	[2] = {Name = ts:Create("h4795ea48g3ffbg49e2ga99fgc51b65b7bac4", "Journeyman Axefighter"), Color="#D46A6A"},
	[3] = {Name = ts:Create("h0cb1a1eag87c4g42d4gafb6gd862c3856941", "Expert Axefighter"), Color="#DD3939"},
	[4] = {Name = ts:Create("ha149de7fg2151g46cfgbf58gc6294f53da42", "Warmaster, Axe of Legend"), Color="#FF1515"},
}),
["LLWEAPONEX_Banner"] = MasteryData:Create("LLWEAPONEX_Banner", ts:Create("hbe8ca1e2g4683g4a93g8e20g984992e30d22", "Banner"), "#F8FF2D", {
	[0] = {Name = ts:Create("hf573b58dge7abg45a3ga080gb002fa55e696", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("h3ed3f447g6232g427cg948cg376f405f8413", "Novice"), Color="#DDFFB3"},
	[2] = {Name = ts:Create("ha9259747g75d2g452ag8688g3ce77b6cad95", "Journeyman Bannerman"), Color="#94E963"},
	[3] = {Name = ts:Create("h439e053bgd9c6g4dd4gbca4ge54f85d29d22", "Expert Bannerkeeper"), Color="#52D43A"},
	[4] = {Name = ts:Create("hb62e44dfg79b4g4a88gac70gb89724dadf12", "Banner Lord"), Color="#28FF00"},
}),
["LLWEAPONEX_BattleBook"] = MasteryData:Create("LLWEAPONEX_BattleBook", ts:Create("he053a3abge5d8g4d14g9333ga18d6eba3df1", "Battle Book"), "#22AADD", {
	[0] = {Name = ts:Create("h41213086g6611g45f9gb6c1gb07a11f06e64", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("h83caead8g3a51g4daag9145ge0b8a4dd23a5", "Novice"), Color="#DDFFB3"},
	[2] = {Name = ts:Create("he30d8120g13e1g4261g853cgdce0c96a00da", "Journeyman Bookkeeper"), Color="#94E9FF"},
	[3] = {Name = ts:Create("h9bcf36d2g13e1g4d5agb4cbg5184482f14b3", "Expert Bookkeeper"), Color="#52D4FF"},
	[4] = {Name = ts:Create("hcf8ab49dga402g46a3g80d6gfece2661cb1f", "Pagemaster"), Color="#28FFFF"},
}),
["LLWEAPONEX_Bludgeon"] = MasteryData:Create("LLWEAPONEX_Bludgeon", ts:Create("h448753f3g7785g4681gb639ga0e9d58bfadd", "Bludgeon"), "#FFE7AA", {
	[0] = {Name = ts:Create("h2869c187g43c7g4a43g840eg09183a619b9e", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("h9c918f73gf489g4936g95dagb7157c10d36c", "Novice"), Color="#FFE7AA"},
	[2] = {Name = ts:Create("hd56dc0d5g60d2g414egbb54g4eb73600004f", "Journeyman Smasher"), Color="#D4B76A"},
	[3] = {Name = ts:Create("ha7dab5ddg4f9fg474cg9207g1cabc58db110", "Expert Smasher"), Color="#AA8B39"},
	[4] = {Name = ts:Create("hc949152age85ag4ac3gbdd0gc68e2ad4403a", "Master of Smashing"), Color="#A57C5B"},
}),
["LLWEAPONEX_Bow"] = MasteryData:Create("LLWEAPONEX_Bow", ts:Create("h54e7afe8geee9g4aeeg97f5g5ab8421d0329", "Bow"), "#72EE34", {
	[0] = {Name = ts:Create("ha3be6dd1g84d7g41e8g852bg689d2de003a8", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("h051a7395g4959g43b7gac39g18a872617097", "Novice"), Color="#CAEA9C"},
	[2] = {Name = ts:Create("h22c84befg9b94g47a4ga4f2gf5bcb1c84a7d", "Journeyman Archer"), Color="#9BC362"},
	[3] = {Name = ts:Create("hd0bc2243g2842g4282g8dc0g80fd6e300650", "Expert Archer"), Color="#AAFF14"},
	[4] = {Name = ts:Create("hf208e35egd21eg41e9gbadbga737e5e106cf", "Eagle Eye, Master Archer"), Color="#4DFF14"},
}),
["LLWEAPONEX_Crossbow"] = MasteryData:Create("LLWEAPONEX_Crossbow", ts:Create("hcaabd40cg42fag4646g896dg471c77946ed8", "Crossbow"), "#81E500", {
	[0] = {Name = ts:Create("h3215fb30gf588g41dfga22dg9dbadd052fb3", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("h62ec0ff9g689eg4dccg9ad0g5b8de573002e", "Novice"), Color="#B5D48D"},
	[2] = {Name = ts:Create("h1cbd8471gb85fg4e8fg84c7g554d08d2166e", "Journeyman Crossbowman"), Color="#A6D569"},
	[3] = {Name = ts:Create("hbf5ce1ecge54fg4967g9622gf1105f232154", "Expert Crossbowman"), Color="#95D83F"},
	[4] = {Name = ts:Create("h19f2ac8dgf99dg4495g9401g8725f8d4cf6f", "Master Marksman of Crossbows"), Color="#88E213"},
}),
["LLWEAPONEX_Dagger"] = MasteryData:Create("LLWEAPONEX_Dagger", ts:Create("h697f3261gc083g4152g84cdgbe559a5e0388", "Dagger"), "#5B40FF", {
	[0] = {Name = ts:Create("hd89e1abdg82e3g4a40ga636g8e52b22e7009", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("hb38efba3gc9d5g4b93gb11bg595b1d08b47e", "Novice"), Color="#CDBCF0"},
	[2] = {Name = ts:Create("h825a0ab6g2d8ag49d6ga502g430378863966", "Journeyman Thief"), Color="#A17EE8"},
	[3] = {Name = ts:Create("h76954f43gf09ag4dc1gb817g2c0a1abe557e", "Expert Rogue"), Color="#8756EB"},
	[4] = {Name = ts:Create("h1fcd775agd75eg4dc0gbe8bgfb2956f7bfd8", "Master Shadowdancer"), Color="#6827EC"},
}),
["LLWEAPONEX_DualShields"] = MasteryData:Create("LLWEAPONEX_DualShields", ts:Create("h00157a58g9ae0g4119gba1ag3f1e9f11db14", "Dual Shields"), "#D9D9D9", {
	[0] = {Name = ts:Create("h40699bb6gcd49g4a7fg84a0g31a468f0c7c0", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("h497e6434gbaaeg4ef9g8441g90e33058ca6c", "Novice"), Color="#FFDA9E"},
	[2] = {Name = ts:Create("h2ea77ec5g010dg4f42g9ec5g4867c3f92fd2", "Journeyman Dual Shieldsman"), Color="#FFC973"},
	[3] = {Name = ts:Create("hbf879135gcdb1g4a16gbcd7gc3a8b2c8592a", "Expert Dual Shieldsman"), Color="#FFB94A"},
	[4] = {Name = ts:Create("h8406fbf2g4595g403ag8d5cgb007104ebd1c", "Dual Shieldmaster"), Color="#FF9E03"},
}),
["LLWEAPONEX_Firearm"] = MasteryData:Create("LLWEAPONEX_Firearm", ts:Create("h8d02e345ged4ag4d60g9be9g68a46dda623b", "Firearm"), "#FD8826", {
	[0] = {Name = ts:Create("hd4558384gf656g4e7bg96bfg4d2639fd45e6", "Beginner"), Color="#FDC89B"},
	[1] = {Name = ts:Create("hc38fd333g9037g4b10ga3b6g09a18304fa17", "Novice"), Color="#FBBC7F"},
	[2] = {Name = ts:Create("h79cc0244gf33fg4232g9cdfgdaf6ee3d4edd", "Journeyman Firearm Enthusiast"), Color="#F5A36C"},
	[3] = {Name = ts:Create("h7a5aaeb6g4f02g472ag8cdbgb12a14ab5bd3", "Expert Firearm Lunatic"), Color="#F49C4E"},
	[4] = {Name = ts:Create("he301a2cag4ac9g4a73gba19g0449b7366d23", "Master of Firearms"), Color="#FF9D33"},
}),
["LLWEAPONEX_Greatbow"] = MasteryData:Create("LLWEAPONEX_Greatbow", ts:Create("h52a81f92g3549g4cb4g9b18g066ba15399c0", "Greatbow"), "#00FF7F", {
	[0] = {Name = ts:Create("hc5a3ad75ga63fg4fdcgb6bdg7d796b0c9f57", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("hf2a5c017g2c47g42f8g9181ga6a2ba29012e", "Novice"), Color="#DDFFB3"},
	[2] = {Name = ts:Create("h71a161d1g223ag4febg9a4ag0d21239f9cc9", "Journeyman Slayer"), Color="#94E963"},
	[3] = {Name = ts:Create("h2d9d60e3gf171g47ffgbf7fg126af4dd7ef6", "Expert Slayer"), Color="#52D43A"},
	[4] = {Name = ts:Create("h016eba10ga3d5g4741ga89egdf0a8e13386e", "Master Dragonslayer"), Color="#28FF00"},
}),
["LLWEAPONEX_HandCrossbow"] = MasteryData:Create("LLWEAPONEX_HandCrossbow", ts:Create("hd8d02aa1g5c35g48b5gbde6ga76293ef2798", "Hand Crossbow"), "#FF33FF", {
	[0] = {Name = ts:Create("h20915294g90deg456ag821cgadedb811af47", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("hc997c244gb0b1g4968gafe7ge225cc311a0f", "Novice"), Color="#FFDA9E"},
	[2] = {Name = ts:Create("hed2480c5g8fa9g45c5g8f14gcf828d5b6c19", "Journeyman Spy"), Color="#FFC973"},
	[3] = {Name = ts:Create("hd2f9f6c9ge49cg43acgba10g108189b7dd1c", "Expert Spy"), Color="#FFB94A"},
	[4] = {Name = ts:Create("hb4825bd8g4a52g4d14gb1cdgd452ec7883d6", "Spymaster, Elite Assassin"), Color="#FF9E03"},
}),
["LLWEAPONEX_Katana"] = MasteryData:Create("LLWEAPONEX_Katana", ts:Create("he467f39fg8b65g4136g828fg949f9f3aef15", "Katana"), "#FF2D2D", {
	[0] = {Name = ts:Create("h22fb7041g1bfag49f8g9f8egfec10c7b11fa", "Beginner"), Color="#FFEAEA"},
	[1] = {Name = ts:Create("hd21a6fa4g7a9eg4cc0gb127g1ae07e801c4a", "Novice"), Color="#FF9D9D"},
	[2] = {Name = ts:Create("h8360bff4g4ddcg4548g97a5g9ed84484f556", "Journeyman Bladesman"), Color="#F56C6C"},
	[3] = {Name = ts:Create("hca7bbf39gdd37g4310g96efge759ea6d84bd", "Expert Blademaster"), Color="#F44E4E"},
	[4] = {Name = ts:Create("h5b16d546gf2c8g4350g894bg5b409289ae46", "Blademaster"), Color="#FF3333"},
}),
["LLWEAPONEX_Pistol"] = MasteryData:Create("LLWEAPONEX_Pistol", ts:Create("h9ead3ee9g63e6g4fdbg987dg87f8c9f5220c", "Pistol"), "#FF337F", {
	[0] = {Name = ts:Create("h9a9b1b17g6d66g4822g8b55g9d610c5f3da8", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("hdfda7aecg0cc7g49bfga90eg4bf411c1d442", "Novice"), Color="#DDFFB3"},
	[2] = {Name = ts:Create("h060c9019g5c2eg4003gb9cdg9add29793c37", "Journeyman Gunslinger"), Color="#94E963"},
	[3] = {Name = ts:Create("hf4da1996g5ad3g460eg96c5g3f6cc8776e37", "Expert Gunslinger"), Color="#52D43A"},
	[4] = {Name = ts:Create("hf119f146gf85dg404fg8f72g4e1ac0592577", "Master Gunslinger"), Color="#4CFF00"},
}),
["LLWEAPONEX_Polearm"] = MasteryData:Create("LLWEAPONEX_Polearm", ts:Create("hd61320b6ge4e6g4f51g8841g132159d6b282", "Polearm"), "#FFCF29", {
	[0] = {Name = ts:Create("hd39d4278g865ag4b7dg9ad2ga330e22c7274", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("hf574497dg82cdg4f99ga9ccgfddab9e5d443", "Novice"), Color="#FFF2C6"},
	[2] = {Name = ts:Create("h4cfeeee7gd876g4469ga375gbe5690d94373", "Journeyman Polearmsman"), Color="#FFE899"},
	[3] = {Name = ts:Create("hedaa0142g30dbg4ce1g9befgc9566dd8829e", "Expert Polearmsman"), Color="#FFE178"},
	[4] = {Name = ts:Create("hef2e0280g7c09g4fbeg8a29g9735f97725b2", "Polearm Master"), Color="#FFC154"},
}),
["LLWEAPONEX_Quarterstaff"] = MasteryData:Create("LLWEAPONEX_Quarterstaff", ts:Create("h8d11d8efg0bb8g4130g9393geb30841eaea5", "Quarterstaff"), "#FD8826", {
	[0] = {Name = ts:Create("h7d4ee99ag9134g4613ga490g09629a8d1427", "Beginner"), Color="#FDC89B"},
	[1] = {Name = ts:Create("hf55f2e19g5f84g4f5agaf54g7a1f6d3d3b26", "Novice"), Color="#FBBC7F"},
	[2] = {Name = ts:Create("h9826a174g86bag4ed5g8467g7e6ca4a500c2", "Journeyman Staff Monk"), Color="#F5A36C"},
	[3] = {Name = ts:Create("h4a156a46g0af4g4886ga736gdbd690a309bd", "Expert Staff Monk"), Color="#F49C4E"},
	[4] = {Name = ts:Create("h0042fce4g99a9g487egb7d2g3d594b9b4d17", "Master Monk of Staves"), Color="#FF9D33"},
}),
["LLWEAPONEX_Rapier"] = MasteryData:Create("LLWEAPONEX_Rapier", ts:Create("h84b2d805gff5ag44a5g9f81g416aaf5abf18", "Rapier"), "#00FF7F", {
	[0] = {Name = ts:Create("h910a4841g7540g4d45g8dc5g7e90f17fe706", "Beginner"), Color="#FEFFEA"},
	[1] = {Name = ts:Create("h2e79cf8egf0deg4887gaaf5g0d401ee1fd03", "Novice"), Color="#FFF59D"},
	[2] = {Name = ts:Create("hbc7b37e1gf789g4e81g9d3eg892dcd9b6a16", "Journeyman Fencer"), Color="#F5F06C"},
	[3] = {Name = ts:Create("h898afc1cgb1dbg4c75gad22g064b0553b3af", "Expert Fencer"), Color="#F5E06C"},
	[4] = {Name = ts:Create("hb0a53301g24edg44d6g85c7gc1cc1c9553ab", "Master Fencer"), Color="#FFE933"},
}),
["LLWEAPONEX_Runeblade"] = MasteryData:Create("LLWEAPONEX_Runeblade", ts:Create("hb66213fdg1a98g4127ga55fg429f9cde9c6a", "Runeblade"), "#40E0D0", {
	[0] = {Name = ts:Create("hcce32013g6251g4243g9010g549ebc7943a8", "Beginner"), Color="#EAFFFE"},
	[1] = {Name = ts:Create("h50f6e0abgda94g409egb803g6023020bea8e", "Novice"), Color="#9DFCFF"},
	[2] = {Name = ts:Create("h27cd6a49gbf37g46e7gb450g00f023c099a1", "Journeyman Runekeeper"), Color="#6CE3F5"},
	[3] = {Name = ts:Create("hc80e9017g9899g4524g83d2ga48f319a1eff", "Expert Runekeeper"), Color="#6CF5E9"},
	[4] = {Name = ts:Create("hc75c7588gb43fg478egbf7eg85dbef7b8479", "Runemaster"), Color="#33FFB8"},
}),
["LLWEAPONEX_Scythe"] = MasteryData:Create("LLWEAPONEX_Scythe", ts:Create("h1e98bd0bg867dg4a57gb2d4g6d820b4e7dfa", "Scythe"), "#AA11CC", {
	[0] = {Name = ts:Create("h68c5bf7ag177ag4336g9d6ag0493f4769bfb", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("h3e9cc211g2ee5g4148gb6d5g3de5ff3aa17b", "Novice"), Color="#CCDA9E"},
	[2] = {Name = ts:Create("h58bdc191g686fg4de9g8728g9f9aef72eaac", "Journeyman Reaper"), Color="#C8FBFF"},
	[3] = {Name = ts:Create("ha829342ag6a17g44faga080gadab190b6d91", "Expert Reaper"), Color="#96F8FF"},
	[4] = {Name = ts:Create("haa42e32agcf35g40aegb294ga96874080850", "Reaper of Souls"), Color="#73FFCC"},
}),
["LLWEAPONEX_Shield"] = MasteryData:Create("LLWEAPONEX_Shield", ts:Create("h9ffd7826g03eeg4597gad11g03c6b56e547c", "Shield"), "#AE9F95", {
	[0] = {Name = ts:Create("h1a9b3453gfd69g4790g8d60gcf5707b57881", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("hf010c20dg262cg4c78g9facgbc982c680aee", "Novice"), Color="#CCDA9E"},
	[2] = {Name = ts:Create("h1c5ecd4ag935cg4971gab38g92c3a6ef8b0c", "Journeyman Shieldsman"), Color="#CCC973"},
	[3] = {Name = ts:Create("hdc98ec8dg571eg4a24g8963g8d99760058fb", "Expert Shieldsman"), Color="#CCB94A"},
	[4] = {Name = ts:Create("h22cdc225g4472g455cg8f16g8798b840a473", "Shieldmaster"), Color="#CC9E03"},
}),
["LLWEAPONEX_Staff"] = MasteryData:Create("LLWEAPONEX_Staff", ts:Create("h1f41efdegb2b0g4f80gab7cg28b15d2c0039", "Staff"), "#2EFFE9", {
	[0] = {Name = ts:Create("h1f4d3b34g12edg4aeagb41fgd8726c69e151", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("h0759631agf5f6g42c7ga551g96cc79c664ba", "Novice"), Color="#D1F8FF"},
	[2] = {Name = ts:Create("hbfd7a8fdg607fg4176ga182g2be56bbc7209", "Journeyman Staff Acolyte"), Color="#9BF0FF"},
	[3] = {Name = ts:Create("hf0d2102ag607cg4963g8428g16176cd50f2b", "Expert Staffmeister"), Color="#77E9FE"},
	[4] = {Name = ts:Create("h0ada3a43g2943g4b09g900agd1a2b2587c3d", "Sage of Staves"), Color="#5EDBFF"},
}),
["LLWEAPONEX_Sword"] = MasteryData:Create("LLWEAPONEX_Sword", ts:Create("hd7347120gcb02g4fdcgaddcg282a83a42d58", "Sword"), "#FF3E2A", {
	[0] = {Name = ts:Create("hc113eee2g4da2g45b5g8cddgc100d1e5c8a8", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("h76350dd6g3e8dg4b63g92c2ga375f18c1359", "Novice"), Color="#FFAC99"},
	[2] = {Name = ts:Create("hcded86f6g62d9g4e32ga13dg9cdd12583f56", "Journeyman Swordsman"), Color="#FF9178"},
	[3] = {Name = ts:Create("h1fef279cgb576g409dgbea5g9e686a11d92e", "Expert Swordsman"), Color="#FF7251"},
	[4] = {Name = ts:Create("h4cba2525ge1f2g4ee8g8f22ga2cc0d7206ca", "Swordmaster"), Color="#FF662A"},
}),
["LLWEAPONEX_ThrowingAbility"] = MasteryData:Create("LLWEAPONEX_ThrowingAbility", ts:Create("hc4bf9383ga9b2g48fcgb253gcc7546987b56", "Throwing"), "#40E0D0", {
	[0] = {Name = ts:Create("h5a907dc9g1463g4190gae30gd81c1279d708", "Beginner"), Color="#FFEAEA"},
	[1] = {Name = ts:Create("h17265d91g7278g47d2g8109g5966d8291fec", "Novice"), Color="#FF9D9D"},
	[2] = {Name = ts:Create("h397ceaa8g0e58g4377g8079ge9243c2effc5", "Journeyman Thrower"), Color="#F56CA3"},
	[3] = {Name = ts:Create("h878ac150g627eg4f82ga7cegbe7f49f2f606", "Expert Thrower"), Color="#F56C8C"},
	[4] = {Name = ts:Create("h22508ad1g8213g4d5fgab4bg8217b3ca09ae", "Master Thrower"), Color="#FF3376"},
}),
["LLWEAPONEX_Unarmed"] = MasteryData:Create("LLWEAPONEX_Unarmed", ts:Create("h1e98bcebg2e42g4699gba2bg6f647d428699", "Unarmed"), "#FF44FF", {
	[0] = {Name = ts:Create("hd4ffb17bg123dg4776ga98bgcc138cee93af", "Beginner"), Color="#EAFFFE"},
	[1] = {Name = ts:Create("h712c10d3g29d4g4ebfg9c86g84be5ab70519", "Novice"), Color="#9DFCFF"},
	[2] = {Name = ts:Create("h9f4b90d8g40cdg4581g8e41ge26e12f14f77", "Scrapper"), Color="#6CE3F5"},
	[3] = {Name = ts:Create("hfa266fa2ge264g40a5g8ccfg2a42bb76e15e", "Elite Brawler"), Color="#6CF5E9"},
	[4] = {Name = ts:Create("h80ad64beg129dg4b44g86f2g00c666b6cd46", "Master Pugilist"), Color="#33FFB8"},
}),
["LLWEAPONEX_Wand"] = MasteryData:Create("LLWEAPONEX_Wand", ts:Create("h8bf31994gb4a2g4423g949dg8102095a66ea", "Wand"), "#B658FF", {
	[0] = {Name = ts:Create("h6c42488dgcde8g4a2cg86bag9d5a1e952816", "Beginner"), Color="#FDFFEA"},
	[1] = {Name = ts:Create("h9d29b47bg1aceg4b21gb44cgdea621ff49cf", "Novice"), Color="#D8BAFD"},
	[2] = {Name = ts:Create("h6add6a16ge3fdg4cdcg9420gd6320b918928", "Journeyman of Wands"), Color="#C596FE"},
	[3] = {Name = ts:Create("hf3ed32cbg53e8g412fg9156g418c80266425", "Expert of Wands"), Color="#B274FF"},
	[4] = {Name = ts:Create("h0d7f2482ge6afg4ee1gb633g7b0e0769b52d", "Master Wandweaver"), Color="#D258FF"},
}),
}
Masteries.LLWEAPONEX_Rod = Masteries.LLWEAPONEX_Wand