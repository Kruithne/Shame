--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_CourtOfStarts.lua - Encounter data for the (Legion) Court of Stars dungeon.
]]--

do
	local Shame = Shame;

	Shame:RegisterInstance({
		instanceID = 1571,
		trackers = {
			-- Trash
			209027, -- Duskwatch Guard - Quelling Strike
			207979, -- Jazsharui - Shockwave
			209477, -- Mana Wyrm - Wild Detonation
			209378, -- Imacu'tya - Whirling Blades
			211391, -- Legion Hound - Felblaze Puddle

			-- Patrol Captain Gerdo
			206574, -- Resonant Slash L
			206580, -- Resonant Slash R
			219498, -- Streetsweeper

			-- Talixae Flamewreath
			207887, -- Infernal Eruption
			211457, -- Infernal Eruption

			-- Advisor Melandrus
			209630, -- Piercing Gale
			209667, -- Blade Surge
			{ spellID = 224333, event = Shame.COMBAT_AURA_APPLIED, func = Shame.CombatGeneric_AuraApplied, failType = Shame.L_CC_STUNNED }, -- Enveloping Winds
		}
	});
end