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

	local mselect = function(indexes, ...)
		local data = {...};
	end

	--[[
		Shame.CombatGeneric_Damage
		Triggered when a player is damaged by a spell.

			self - Reference to the addon container.
			node - Tracker node.
			... - Combat arguments.
	]]--
	Shame.CombatGeneric_SpellDamage = function(self, node, ...)
		local playerName, spellName, damageTaken = (select(5, ...)), (select(13, ...)), ((select(15, ...)));
		local spellID = select(7, GetSpellInfo(spellName));

		if spellID == node.spellID then
			self:RegisterMistake(playerName, damageTaken, "%s failed to avoid %s! (%s)", playerName, spellName, damageTaken);
		end
	end
end