--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	locale/enGB.lua - Defines English (default) localization.
]]--

do
	-- We don't check for the locale here, since the enGB localization will be used
	-- as the default fallback for missing strings in other locale.
	Shame:ApplyLocalization({
		L_LOADED = "Loaded v%s",

		L_CURRENT_SESSION = "Shame for current session:",
		L_MISTAKE_SINGLE = "%s Mistake",
		L_MISTAKE_MULTI= "%s Mistakes",
		L_NO_SHAME = "Nobody has any shame; good job!",

		L_ALREADY_RUNNING = "Already shaming; to stop, run: |cffabd473",
		L_NOT_STARTED = "Shaming has not yet begun; to start, run: |cffabd473",
		L_NEW_SESSION = "Started new shaming session.",
		L_STOPPED = "Stopped shaming session.",

		L_VALID_MODES = "Valid modes: %s.",
		L_MODE_SET = "Real-time shaming mode set to |cfff58cba%s|r |cffaeebffin|r |cfff58cba%s|r|cffaeebff.|r",
		L_MODE_SET_SIMPLE = "Real-time shaming mode set to |cfff58cba%s|r|cffaeebff.",

		L_VALID_CHANNELS = "Valid channels: %s.",
		L_INVALID_CHANNEL = "Invalid channel, use one of these: %s!",

		L_COMMAND_SYNTAX = "Command syntax: |cffabd473/shame %s|r|cfff58cba%s|r",
		L_UNKNOWN_COMMAND = "Unknown command. Try '/shame help' for available commands.",
		L_AVAILABLE_COMMANDS = "|cff3fc7ebAvailable commands:|r",
		L_INVALID_COMMAND = "Invalid command",

		L_CALLOUT_DAMAGE = "%s failed to avoid %s! (%s)",
		L_CALLOUT_GENERIC = "%s failed %s!",
		L_CALLOUT_TRIGGER = "%s triggered %s! (%s)",

		L_CC_UNKNOWN = "Debuff",
		L_CC_INTERRUPTED = "Interrupted",
		L_CC_STUNNED = "Stunned",
		L_CC_ASLEEP = "Asleep",
		L_CC_FEARED = "Feared",
		L_CC_PUNT = "Punted",

		L_CALLOUT_7D_HOV_ODYN_RUNE = "%s picked the wrong rune! (%s)",
		L_CALLOUT_7D_HOV_FENRYR_SCENT = "%s failed to run away from %s! (%s)",

		L_CALLOUT_7D_VOTW_ASH_PLAT = "%s fell off the platform! (%s)",

		L_BOARD_FORMAT = "%s. %s took %s avoidable damage (%s)",

		L_MODE_ALL = "all",
		L_MODE_SILENT = "silent",
		L_MODE_SELF = "self",

		L_CMD_START = "start",
		L_CMD_STOP = "stop",
		L_CMD_PRINT = "print",
		L_CMD_MODE = "mode",
		L_CMD_HELP = "help",

		L_CMD_DESC_START = "Start a monitoring session.",
		L_CMD_DESC_STOP = "Stop a monitoring session.",
		L_CMD_DESC_MODE = "Set the mode for real-time shaming.",
		L_CMD_DESC_PRINT = "Output the current leaderboard.",
		L_CMD_DESC_HELP = "Display available commands.",

		L_CMD_MODE_HELP = " [silent||all||self] [channel]",
		L_CMD_PRINT_HELP = " [channel]",
	});
end