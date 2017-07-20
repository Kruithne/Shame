--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	CombatGenerics.lua - Contains generic handling functions for encounters.
]]--

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
		local playerName, spellName, healAmount = (select(5, ...)), (select(13, ...)), ((select(15, ...)));
		local spellID = select(7, GetSpellInfo(spellName));

		if spellID == node.spellID then
			self:RegisterMistake(playerName, healAmount, "%s healed themself with %s! (%s)", playerName, spellName, healAmount);
		end
	end
end