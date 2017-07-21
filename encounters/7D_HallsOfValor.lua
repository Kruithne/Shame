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
			{ -- Valarjar Trapper - Bear Trap
				event = Shame.COMBAT_SPELL_DAMAGE,
				func = Shame.CombatGeneric_SpellDamage,
				spellID = 199337,
			},
			{ -- Valarjar Aspirant - Blast of Light
				event = Shame.COMBAT_SPELL_DAMAGE,
				func = Shame.CombatGeneric_SpellDamage,
				spellID = 191508,
			},
			{ -- Valarjar Marksman - Penetrating Shot
				event = Shame.COMBAT_SPELL_DAMAGE,
				func = Shame.CombatGeneric_SpellDamage,
				spellID = 199210,
			},
			{ -- Hyrmdall - Dancing Blade
				event = Shame.COMBAT_SPELL_PERIODIC,
				func = Shame.CombatGeneric_SpellDamage,
				spellID = 193234
			},
			{ -- Hyrmdall - Ball Lightning
				event = Shame.COMBAT_SPELL_DAMAGE,
				func = Shame.CombatGeneric_SpellDamage,
				spellID = 188395,
			}
		}
	});
end