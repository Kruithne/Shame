--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_HallsOfValor.lua - Encounter data for the (Legion) Halls of Valor dungeon.
]]--

do
	local Shame = Shame;

	Shame:RegisterInstance({
		instanceID = 1477,
		trackers = {
			-- Trash
			199337, -- Valarjar Trapper - Bear Trap
			191508, -- Valarjar Aspirant - Blast of Light
			199210, -- Valarjar Marksman - Penetrating Shot
			210875, -- Stormforged Sentinel - Charged Pulse
			199818, -- Stormforged Sentinel - Crackle
			{ spellID = 198903, event = Shame.COMBAT_SPELL_PERIODIC }, -- Storm Drake - Crackling Storm
			{ spellID = 198888, roleExcluded = "TANK" }, -- Storm Drake - Lightning Breath

			-- Hyrmdall
			188395, -- Ball Lightning
			{ spellID = 193234, event = Shame.COMBAT_SPELL_PERIODIC }, -- Dancing Blade
			{ spellID = 193260, event = Shame.COMBAT_SPELL_PERIODIC }, -- Static Field

			-- Fenryr
			{ spellID = 196543, event = Shame.COMBAT_SPELL_INTERRUPT, func = Shame.CombatGeneric_SpellInterrupt }, -- Unnerving Howl

			-- God-King Skovald
			193660, -- Felblaze Rush
			{ spellID = 193702, event = Shame.COMBAT_SPELL_PERIODIC }, -- Infernal Flames
			{ spellID = 193686, event = Shame.COMBAT_AURA_APPLIED, func = Shame.CombatGeneric_AuraApplied }, -- Ragged Slash

			-- Odyn
			227781, -- Glowing Fragment #1
			198088, -- Glowing Fragment #2
			198263, -- Radiant Tempest
			{ spellID = 198412, message = Shame.L_CALLOUT_7D_HOV_ODYN_RUNE }, -- Feedback
			{ spellID = 200988, event = Shame.COMBAT_SPELL_PERIODIC }, -- Spear of Light
		}
	});
end