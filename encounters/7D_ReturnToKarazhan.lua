--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_ReturnToKarazhan.lua - Encounter data for the (Legion) Return to Karazhan dungeon.
]]--

do
	local Shame = Shame;
	local GetSpellInfo = GetSpellInfo;

	Shame:RegisterInstance({
		instanceID = 1651,
		trackers = {
			-- Trash
			228001, -- Ghostly Philanthropist - Pennies From Heaven
			227925, -- Ghostly Understudy - Final Curtain
			227917, -- Ghostly Understudy - Poetry Slam
			238606, -- Arcane Warden - Arcane Eruption
			242894, -- Damaged Golem - Unstable Energy
			229623, -- Fel Bat - Fel Breath
			229597, -- Fel Bat - Fel Mortar
			227620, -- Mana Devourer - Arcane Bomb
			229384, -- Queen Move
			229298, -- Knight Move
			229988, -- Burning Tile
			{ spellName = (GetSpellInfo(229558)) }, -- Bishop Move
			{ spellID = 229682, event = Shame.COMBAT_SPELL_PERIODIC }, -- Gleeful Immolation
			{ spellID = 241774, event = Shame.COMBAT_AURA_APPLIED, func = Shamn.CombatGeneric_AuraApplied }, -- Shield Smash
			{ spellID = 227977, event = Shame.COMBAT_AURA_APPLIED, func = Shame.CombatGeneric_AuraApplied }, -- Flashlight

			-- The Curator
			227285, -- Power Discharge

			-- Attumen the Huntsman
			227339, -- Mezair
			227645, -- Spectral Charge
			227363, -- Mighty Stomp

			-- Moroes
			227672, -- Will Breaker

			-- Viz'aduum the Watcher
			229151, -- Disintegrate
			229285, -- Bombardment
			229905, -- Soul Harvest
			229248, -- Fel Beam
			{ spellID = 229250, event = Shame.COMBAT_SPELL_PERIODIC }, -- Fel Flames

			-- Opera Hall: Beautiful Beast
			228019, -- Leftovers
			{ spellID = 228200, event = Shame.COMBAT_SPELL_PERIODIC }, -- Burning Blaze

			-- Opera Hall: Wikket
			227776, -- Maagic Magnificent

		}
	});
end