--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_EyeOfAzshara.lua - Encounter data for the (Legion) Eye of Azshara dungeon.
]]--

do
	local Shame = Shame;

	Shame:RegisterInstance({
		instanceID = 1456,
		trackers = {
			-- Trash
			196871, -- Hatecoil Stormweave - Storm
			195217, -- Hatecoil Arcanist - Aqua Spout
			195473, -- Gritslime Snail - Abrasive Slime
			192801, -- Tidal Wave (Environment)
			192794, -- Lightning Strike (Environment)
			196129, -- Mak'rana Slitwalker - Spray Sand
			195944, -- Skrog Wavecrasher - Rising Fury
			196287, -- Stormwake Hydra - Tail Whip
			196299, -- Stormwake Hydra - Roiling Storm
			{ spellName = (GetSpellInfo(196293)) }, -- Stormwake Hydra - Chaotic Tempest

			-- Lady Hatecoil
			193597, -- Static Nova
			{ spellID = 196610, event = Shame.COMBAT_AURA_APPLIED, func = Shame.CombatGeneric_AuraApplied, failType = Shame.L_CC_PUNT }, -- Monsoon

			-- Serpentrix
			191858, -- Toxic Puddle
			191847, -- Poison Spit

			-- King Deepbeard
			193171, -- Aftershock
			193088, -- Ground Slam

			-- Wrath of Azshara
			192708, -- Arcane Bomb
			192675, -- Mystic Tornado
			192619, -- Massive Deluge
		}
	});
end