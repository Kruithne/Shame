--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_Arcway.lua - Encounter data for the (Legion) Arcway dungeon.
]]--

do
	local Shame = Shame;

	Shame:RegisterInstance({
		instanceID = 1516,
		trackers = {
			-- Trash
			194006, -- Unstable Amalgamation - Ooze Puddle
			211921, -- Priestess of Misery - Felstorm
			211745, -- Wrathguard Felblade - Fel Strike
			203593, -- Mana Wyrm - Nether Spike
			211476, -- Mana Wyrm - Nether Spike
			{ spellID = 211209, event = Shame.COMBAT_SPELL_PERIODIC }, -- Arcane Anomaly - Arcane Slicer
			{ spellID = 210750, event = Shame.COMBAT_SPELL_PERIODIC }, -- Withered Manawraith - Collapsing Rift

			-- General Xakal
			197788, -- Fel Bombardment
			197579, -- Fel Eruption
			212071, -- Shadow Slash

			-- Nal'tira
			199812, -- Blink Strikes
			211501, -- Arcane Discharge
			{ spellID = 200040, event = Shame.COMBAT_SPELL_PERIODIC }, -- Nether Venom

			-- Corstilax
			196142, -- Exterminate
			196213, -- Suppression Protocol
			{ spellID = 220500, event = Shame.COMBAT_SPELL_PERIODIC }, -- Destabilized Orb

			-- Ivanyr
			220597, -- Charged Bolt
		}
	});
end