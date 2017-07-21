--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	encounters/7D_VioletHold.lua - Encounter data for the (Legion) Violet Hold dungeon.
]]--

do
	local Shame = Shame;

	Shame:RegisterInstance({
		instanceID = 1544,
		trackers = {
			-- Trash
			205081, -- Wrathlord Bulwark - Fel Shield Blast
			204762, -- Fel Axe - Violent Fel Energy
			224460, -- Venomhide Shadowspinner - Venom Nova
			224465, -- Venomhide Shadowspinner - Spitting Venom

			-- Shivermaw
			201852, -- Relentless Storm

			-- Sael'orn
			202414, -- Venom Spray
		}
	});
end