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
		local _, _, _, _, descName, _, _, _, targetName, _, _, spellID, spellName, _, damageTaken = ...;

		if spellID == node.spellID then
			self:RegisterMistake(targetName, damageTaken, self.CALLOUT_DAMAGE, targetName, spellName, damageTaken);
		end
	end
end