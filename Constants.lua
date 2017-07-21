--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	Constants.lua - Stores non-localized static values.
]]--

do
	-- This initialized the string table with constant values that don't need localizing.
	Shame.strings = {
		ADDON_NAME = "Shame",

		CHAT_PREFIX = "|cffff996f[Shame]|r |cffaeebff%s|r",
		FORMAT_COMMAND = "/shame %s|cfff58cba%s|r",
		FORMAT_COMMAND_FULL = "  /shame %s|cfff58cba%s|r - |cffabd473%s|r",

		LIST_FORMAT = "|cffabd473%s|r",

		ENABLE_DIFFICULTY = 23, -- Mythic dungeons.

		CALLOUT_DAMAGE = "%s failed to avoid %s! (%s)",
		CALLOUT_INTERRUPT = "%s failed %s! (Interrupted)",
		CALLOUT_GENERIC = "%s failed %s!",

		COMBAT_SPELL_DAMAGE = "SPELL_DAMAGE",
		COMBAT_SPELL_PERIODIC = "SPELL_PERIODIC_DAMAGE",
	};
end