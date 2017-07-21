--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_VaultOfTheWardens.lua - Encounter data for the (Legion) Vault of the Wardens dungeon.
]]--

do
	local Shame = Shame;

	Shame:RegisterInstance({
		instanceID = 1493,
		trackers = {
			-- Trash
			193610, -- Glayvianna Soulrender - Fel Detonation
			194037, -- Foul Mother - Mortar
			194071, -- Foul Mother - A Mother's Love
			193969, -- Aransai Broodmother - Razors
			202607, -- Grimhorn the Enslaver - Anguished Souls (Impact)
			{ spellID = 202608, event = Shame.COMBAT_SPELL_PERIODIC }, -- Grimhorn the Enslaver - Anguised Souls (DoT)

			-- Tirathon Saltheril
			214625, -- Fel Chain
			202862, -- Hatred
			{ spellID = 191853, event = Shame.COMBAT_SPELL_PERIODIC }, -- Furious Flames

			-- Ash'golm
			202663, -- Detonate
			{ spellID = 199238, event = Shame.COMBAT_AURA_APPLIED, func = Shame.CombatGeneric_AuraApplied }, -- Lava
			{ spellID = 200202, event = Shame.COMBAT_AURA_APPLIED, func = Shame.CombatGeneric_AuraApplied, message = Shame.L_CALLOUT_7D_VOTW_ASH_PLAT }, -- Chilled to the Bone

			-- Glazer
			{ spellID = 202046, event = Shame.COMBAT_SPELL_PERIODIC }, -- Beam
			{ spellID = 194945, event = Shame.COMBAT_SPELL_PERIODIC }, -- Lingering Gaze

			-- Cordana Felsong
			197506, -- Creeping Doom
			197334, -- Fel Glaive
		}
	});
end