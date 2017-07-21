--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_BlackRookHold.lua - Encounter data for the (Legion) Black Rook Hold dungeon.
]]--

do
	local Shame = Shame;

	Shame:RegisterInstance({
		instanceID = 1501,
		trackers = {
			-- Trash
			200261, -- Soul-Torn Champion - Bonebreaking Strike
			200256, -- Arcane Minion - Phased Explosion
			200344, -- Risen Archer - Arrow Barrage
			201176, -- Wyrmtounge Scavenger - Throw Priceless Artifact
			201141, -- Wrathguard Bladelord - Brutal Assault
			214002, -- Risen Lancer - Raven's Dive
			214003, -- Risen Swordsman - Coup de Grace
			222397, -- Boulder Crush

			-- The Amalgam of Souls
			194960, -- Soul Echoes
			194956, -- Reap Soul
			196517, -- Swirling Scythe

			-- Illysanna Ravencrest
			{ spellID = 197821, event = Shame.COMBAT_SPELL_PERIODIC }, -- Felblazed Ground

			-- Smashspite the Hateful
			{ spellID = 198501, event = Shame.COMBAT_SPELL_PERIODIC }, -- Fel Vomitus

			-- Lord Kul'talos Ravencrest
			198820, -- Dark Blast
			199567, -- Dark Obliteration
			198781, -- Whirling Blade
			{ spellID = 199143, event = Shame.COMBAT_AURA_APPLIED, func = Shame.CombatGeneric_AuraApplied, failType = Shame.L_CC_ASLEEP }, -- Cloud of Hypnosis
		}
	});
end