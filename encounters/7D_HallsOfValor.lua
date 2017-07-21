--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_HallsOfValor.lua - Encounter data for the (Legion) Halls of Valor dungeon.
]]--

do
	local Shame = Shame;
	local UnitDebuff = UnitDebuff;

	-- Sanctify Handler
	local lastSanctifyHit = 0;
	local CombatHandler_Sanctify = function(self, node, ...)
		local timestamp, _, _, _, descName, _, _, _, targetName, _, _, spellID, spellName, _, damageTaken = ...;

		if spellID == node.spellID then
			local diff = timestamp - lastSanctifyHit;
			if diff > 0.3 then
				self:CombatGeneric_HandleMistake(node, targetName, damageTaken, self.L_CALLOUT_TRIGGER, targetName, spellName, damageTaken);
				lastSanctifyHit = timestamp;
			end
		end
	end

	-- Scent of Blood Handler
	local scentOfBloodName = GetSpellInfo(196838);
	local CombatHandler_ScentOfBlood = function(self, node, ...)
		local _, _, _, _, descName, _, _, _, targetName, _, _, damageTaken = ...;

		-- Check if the player hit has the Scent of Blood debuff.
		if UnitDebuff(targetName, scentOfBloodName) then
			self:CombatGeneric_HandleMistake(node, targetName, damageTaken, self.L_CALLOUT_7D_HOV_FENRYR_SCENT, targetName, scentOfBloodName, damageTaken);
		end
	end

	Shame:RegisterInstance({
		instanceID = 1477,
		trackers = {
			-- Trash
			191508, -- Valarjar Aspirant - Blast of Light
			199210, -- Valarjar Marksman - Penetrating Shot
			210875, -- Stormforged Sentinel - Charged Pulse
			199050, -- Valarjar Shieldmaiden - Mortal Hew
			{ spellID = 199818, event = Shame.COMBAT_SPELL_PERIODIC }, -- Stormforged Sentinel - Crackle
			{ spellID = 198903, event = Shame.COMBAT_SPELL_PERIODIC }, -- Storm Drake - Crackling Storm
			{ spellID = 198888, excludeRole = Shame.ROLE_TANK }, -- Storm Drake - Lightning Breath
			{ spellID = 199337, event = Shame.COMBAT_AURA_APPLIED, func = Shame.CombatGeneric_AuraApplied, failType = Shame.L_CC_STUNNED }, -- Valarjar Trapper - Bear Trap

			-- Hyrja
			{ spellID = 192018, excludeRole = Shame.ROLE_TANK },
			{ spellID = 192206, func = CombatHandler_Sanctify }, -- Sanctify
			{ spellID = 200682, excludeDebuff = (GetSpellInfo(200901)) }, -- Eye of the Storm

			-- Hyrmdall
			188395, -- Ball Lightning
			{ spellID = 193234, event = Shame.COMBAT_SPELL_PERIODIC }, -- Dancing Blade
			{ spellID = 193260, event = Shame.COMBAT_SPELL_PERIODIC }, -- Static Field
			{ spellID = 193092, event = Shame.COMBAT_AURA_APPLIED, excludeRole = Shame.ROLE_TANK, func = Shame.CombatGeneric_AuraApplied }, -- Bloodletting Sweep

			-- Fenryr
			{ event = Shame.COMBAT_SWING_DAMAGE, func = CombatHandler_ScentOfBlood }, -- Scent of Blood
			{ spellID = 196543, event = Shame.COMBAT_SPELL_INTERRUPT, func = Shame.CombatGeneric_SpellInterrupt }, -- Unnerving Howl

			-- God-King Skovald
			193660, -- Felblaze Rush
			193827, -- Ragnarok
			{ spellID = 193702, event = Shame.COMBAT_SPELL_PERIODIC }, -- Infernal Flames
			{ spellID = 193686, event = Shame.COMBAT_AURA_APPLIED, func = Shame.CombatGeneric_AuraApplied }, -- Ragged Slash

			-- Odyn
			198088, -- Glowing Fragment
			198263, -- Radiant Tempest
			{ spellID = 198412, message = Shame.L_CALLOUT_7D_HOV_ODYN_RUNE }, -- Feedback
			{ spellID = 200988, event = Shame.COMBAT_SPELL_PERIODIC }, -- Spear of Light
		}
	});
end