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
			spellID = 199337, -- Valarjar Trapper - Bear Trap
			spellID = 191508, -- Valarjar Aspirant - Blast of Light
			spellID = 199210, -- Valarjar Marksman - Penetrating Shot

			-- Hyrmdall
			spellID = 188395, -- Ball Lightning
			{ spellID = 193234, event = Shame.COMBAT_SPELL_PERIODIC }, -- Dancing Blade
	});
end