--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_CathedralOfEternalNight.lua - Encounter data for the (Legion) Cathedral of Eternal Night dungeon.
]]--

do
	local Shame = Shame;

	Shame:RegisterInstance({
		instanceID = 1677,
		trackers = {
			-- Trash
			240279, -- Wrathguard Invader - Fel Strike
			238583, -- Felblight Stalker - Devour Magic
			238656, -- Dul'zak - Shadow Wave
			237599, -- Helblaze Felbringer - Devastating Swipe
			236627, -- Fulminating Lasher - Floral Fulmination
			242792, -- Vilebark Walker - Vile Roots
			237325, -- Toxic Pollen
			240384, -- Wyrmtongue Scavenger - Throw Frost Tome
			239163, -- Wyrmtounge Scavenger - Throw Silence Tome
			239217, -- Gazerax - Blinding Gaze
			239201, -- Gazerax - Fel Glare
			239268, -- Nal'asha - Venom Storm
			{ spellID = 236969, event = Shame.COMBAT_SPELL_PERIODIC }, -- Fel Pool
			{ spellID = 239326, event = Shame.COMBAT_SPELL_PERIODIC }, -- Felstrider Orbcaster - Felblaze Orb

			-- Thrashbite
			240951, -- Destructive Rampage
			238469, -- Scornful Charge

			-- Agronox
			240063, -- Succulent Secretion

			-- Domatrax
			236543, -- Felsoul Cleave

			-- Mephistroth
			236242, -- Shadow Blast
			239525, -- Fel Blaze (Dreadwing)
		}
	});
end