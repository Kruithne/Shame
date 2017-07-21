--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_DarkheartThicket.lua - Encounter data for the (Legion) Darkheart Thicket dungeon.
]]--

do
	local Shame = Shame;

	Shame:RegisterInstance({
		instanceID = 1466,
		trackers = {
			-- Trash
			204402, -- Dreadsoul Ruiner - Star Shower
			198916, -- Rotheart Keeper - Vile Burst
			201123, -- Vilethorn Blossom - Root Burst
			201273, -- Bloodtained Fury - Blood Bomb
			201227, -- Bloodtained Fury - Blood Assault
			201191, -- Hatespawn Slime - Dreadburst

			--  Dresaron
			191326, -- Breath of Corruption
		}
	});
end