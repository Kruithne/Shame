--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_NeltharionsLair.lua - Encounter data for the (Legion) Neltharion's Lair dungeon.
]]--

do
	local Shame = Shame;
	local GetSpellInfo = GetSpellInfo;

	Shame:RegisterInstance({
		instanceID = 1458,
		trackers = {
			-- Trash
			183088, -- Mightstone Breaker - Avalanche (Melee)
			183100, -- Mightstone Breaker - Avalanche (Ranged)
			202089, -- Burning Geode - Scorch
			{ spellID = 183407, event = Shame.COMBAT_SPELL_PERIODIC }, -- Vileshard Crawled - Acid Splatter
			{ spellID = 192800, event = Shame.COMBAT_SPELL_PERIODIC }, -- Blightshared Skitter - Choking Dust

			-- Ularogg Cragshaper
			198475, -- Strike of the Mountain
		}
	});
end