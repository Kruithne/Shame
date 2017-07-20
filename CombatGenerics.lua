do
	local Shame = Shame;
	local select = select;
	local GetSpellInfo = GetSpellInfo;

	--[[
		Shame.CombatGeneric_Heal
		Triggered when a player is healed by a spell.

			self - Reference to the addon container.
			node - Tracker node.
			... - Combat arguments.
	]]--
	Shame.CombatGeneric_Heal = function(self, node, ...)
		local playerName, spellName = (select(5, ...)), (select(13, ...));
		local spellID = select(7, GetSpellInfo(spellName));

		if spellID == node.spellID then
			self:RegisterMistake(playerName, "%s healed themself with %s!", playerName, spellName);
		end
	end
end