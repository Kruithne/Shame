do
	local Shame = Shame;

	Shame:RegisterInstance({
		instanceID = 1041,
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