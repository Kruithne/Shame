--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_MawOfSouls.lua - Encounter data for the (Legion) Maw of Souls dungeon.
]]--

do
	local Shame = Shame;
	local GetSpellInfo = GetSpellInfo;

	Shame:RegisterInstance({
		instanceID = 1492,
		trackers = {
			-- Trash
			194099, -- The Grimwalker - Bile Breath
			{ spellName = (GetSpellInfo(195033)) }, -- Seacursed Soulkeeper - Defiant Strike
			{ spellName = (GetSpellInfo(198324)) }, -- Skjal - Give No Quater

			-- Ymiron, the Fallen King
			193513, -- Bane
			{ spellID = 193364, event = Shame.COMBAT_AURA_APPLIED, func = Shame.CombatGeneric_AuraApplied, failType = Shame.L_CC_FEARED }, -- Screams of the Dead

			-- Harbaron
			194218, -- Cosmic Scythe
			194232, -- Nether Rip

			-- Helya
			202098, -- Brackwater Barrage
			202472, -- Tainted Essence
			227234, -- Corrupted Bellow
			195309, -- Swirling Water
		}
	});
end