--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	CombatGenerics.lua - Contains generic handling functions for encounters.
]]--

do
	local Shame = Shame;
	local select = select;
	local UnitAura = UnitAura;
	local GetSpellInfo = GetSpellInfo;
	local UnitGroupRolesAssigned = UnitGroupRolesAssigned;
	local BreakUpLargeNumbers = BreakUpLargeNumbers;

	local mselect = function(indexes, ...)
		local data = {...};
	end

	--[[
		Shame.CombatGeneric_HandleMistake
		Used by generic combat triggers to trigger mistakes.

			self - Reference to the addon container.
			node - Tracker node.
			actor - Name of the actor who made the mistake.
			damage - Damage value of the mistake.
			message - Unformatted message string.
			... - Arguments for the message string.
	]]--
	Shame.CombatGeneric_HandleMistake = function(self, node, actor, damage, message, ...)
		if node.roleExcluded then
			local role = UnitGroupRolesAssigned(actor);
			if role == node.roleExcluded then
				-- This role is excluded from this fuckery.
				return;
			end
		end

		if node.excludeAura then
			local aura = UnitAura(actor, node.excludeAura);
			if aura then
				-- Players with this aura are excluded from this fuckery.
				return;
			end
		end

		self:RegisterMistake(actor, damage, node.message or message, ...);
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
			self:CombatGeneric_HandleMistake(node, targetName, damageTaken, self.L_CALLOUT_DAMAGE, targetName, spellName, BreakUpLargeNumbers(damageTaken));
		end
	end

	--[[
		Shame.CombatGeneric_SpellInterrupt
		Triggered when a player is interrupted by a spell.

			self - Reference to the addon container.
			node - Tracker node.
			... - Combat arguments.
	]]--
	Shame.CombatGeneric_SpellInterrupt = function(self, node, ...)
		local _, _, _, _, descName, _, _, _, targetName, _, _ spellID, spellName = ...;

		if spellID == node.spellID then
			self:CombatGeneric_HandleMistake(node, targetName, 0, self.L_CALLOUT_INTERRUPT, targetName, spellName);
		end
	end

	--[[
		Shame.CombatGeneric_AuraApplied
		Triggered when a player gains a specific aura.

			self - Reference to the addon container.
			node - Tracker node.
			... - Combat arguments.
	]]--
	Shame.CombatGeneric_AuraApplied = function(self, node, ...)
		local _, _, _, _, descName, _, _, _, targetName, _, _ spellID, spellName, auraType = ...;

		if node.auraType and node.auraType ~= auraType then
			-- Aura type does not match specified.
			return;
		end

		if spellID == node.spellID then
			self:CombatGeneric_HandleMistake(node, targetName, 0, self.L_CALLOUT_GENERIC, targetName, spellName);
		end
	end
end