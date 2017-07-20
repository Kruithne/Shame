do
	-- Rather than applying the English localization, we initialize
	-- the entire strings table using it, for use as a default.
	Shame.strings = {
		L_LOADED = "Loaded v",
		
		L_CURRENT_SESSION = "Shame for current session:",
		L_MISTAKE_SINGLE = "Mistake",
		L_MISTAKE_MULTI= "Mistakes",
		L_NO_SHAME = "Nobody has any shame; good job!",

		L_ALREADY_RUNNING = "Already shaming; to stop, run: |cffabd473",
		L_NOT_STARTED = "Shaming has not yet begun; to start, run: |cffabd473",
		L_NEW_SESSION = "Started new shaming session.",
		L_STOPPED = "Stopped shaming session.",

		L_VALID_MODES = "Valid modes: ",
		L_MODE_SET = "Real-time shaming mode set to |cfff58cba%s|r |cffaeebffin|r |cfff58cba%s|r|cffaeebff.|r",
		L_MODE_SET_SIMPLE = "Real-time shaming mode set to |cfff58cba%s|r |cffaeebff.",

		L_VALID_CHANNELS = "Valid channels: ",
		L_INVALID_CHANNEL = "Invalid channel, use one of these: ",

		L_COMMAND_SYNTAX = "Command syntax",
		L_UNKNOWN_COMMAND = "Unknown command. Try '/shame help' for available commands.",
		L_AVAILABLE_COMMANDS = "|cff3fc7ebAvailable commands:|r",
		L_INVALID_COMMAND = "Invalid command",

		L_CMD_START = "start",
		L_CMD_STOP = "stop",
		L_CMD_PRINT = "print",
		L_CMD_MODE = "mode",
		L_CMD_HELP = "help",

		L_CMD_DESC_START = "Start a monitoring session.",
		L_CMD_DESC_STOP = "Stop a monitoring session.",
		L_CMD_DESC_MODE = "Set the mode for real-time shaming",
		L_CMD_DESC_PRINT = "Output the current leaderboard.",
		L_CMD_DESC_HELP = "Display available commands.",

		L_CMD_MODE_HELP = " [silent|all|self] [channel]",
		L_CMD_PRINT_HELP = " [channel]",
	};
end