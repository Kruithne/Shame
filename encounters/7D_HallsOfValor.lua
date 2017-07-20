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
			{
				-- Used for debugging.
				event = Shame.COMBAT_SPELL_HEAL,
				func = Shame.CombatGeneric_Heal,
				spellID = 5185, -- Healing Touch
			}
		}
	});
end