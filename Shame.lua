do
	-- [[ Optimization ]] --
	local type = type;
	local wipe = wipe;
	local pairs = pairs;
	local table_sort = table.sort;
	local table_concat = table.concat;
	local table_remove = table.remove;
	local string_format = string.format;
	local SendChatMessage = SendChatMessage;
	local string_gmatch = string.gmatch;
	local string_sub = string.sub;
	local string_len = string.len;

	-- [[ Constants ]] --
	local ADDON_NAME = "Shame";
	local ADDON_NAME_LOWER = ADDON_NAME:lower();

	local FORMAT_CHAT_COLORED = string_format("|cffff996f[%s]|r |cffaeebff%%s|r", ADDON_NAME);
	local FORMAT_CHAT_PLAIN = string_format("[%s] %%s", ADDON_NAME);
	local FORMAT_COMMAND = string_format("/%s %%s|cfff58cba%%s|r", ADDON_NAME_LOWER);
	local FORMAT_COMMAND_FULL = string_format("  /%s %%s|cfff58cba%%s|r - |cffabd473%%s|r", ADDON_NAME_LOWER);
	local FORMAT_COMMAND_SYNTAX = string_format("Command syntax: |cffabd473/%s %%s|r|cfff58cba%%s|r", ADDON_NAME_LOWER);

	local MESSAGE_COMMAND_HELP = string_format("Unknown command. Try '/%s help' for available commands.", ADDON_NAME_LOWER);

	local VALID_OUTPUT_CHANNELS = { ["guild"] = true, ["instance"] = true, ["officer"] = true, ["party"] = true, ["raid"] = true };
	local VALID_MODES = { ["all"] = true, ["silent"] = true, ["self"] = true };

	local COMMANDS;

	-- [[ Core Container ]] --
	local Shame = {
		eventFrame = CreateFrame("FRAME"),
		eventHandlers = {}, -- Stores assigned event handlers.
		tracking = false, -- Flag for tracking state.
		boardGroup = {},
		modeChannel = "party", -- Real-time shaming channel.
		mode = "self", -- Real-time shaming mode.
	};

	--[[
		Shame.Message
		Send a text message to a specified (or default) output.

			text - Message to be sent.
			channel - Output channel, leave blank for default.
	]]--
	Shame.Message = function(text, channel)
		if not channel then
			return DEFAULT_CHAT_FRAME:AddMessage(string_format(FORMAT_CHAT_COLORED, text));
		end
		return SendChatMessage(string_format(FORMAT_CHAT_PLAIN, text), channel);
	end

	--[[
		Shame.MessageFormatted
		Format a message before sending it to Shame.Message

			text - Message to be sent.
			channel - Output channel, leave blank for default.
			... - Formatting arguments.
	]]--
	Shame.MessageFormatted = function(text, channel, ...)
		return Shame.Message(string_format(text, ...), channel);
	end

	--[[
		Shame.OnLoad
		Invoked when the addon is loaded.
	]]--
	Shame.OnLoad = function()
		Shame.Message("Loaded v" .. GetAddOnMetadata(ADDON_NAME, "Version"));
	end

	--[[
		Shame.OnEvent
		Invoked when a registered event occurred.
	]]--
	Shame.OnEvent = function(self, event, ...)
		local handler = Shame.eventHandlers[event];
		if handler then handler(...); end
	end

	--[[
		Shame.SetEventHandler
		Register an event handler.

			event - Identifer for the event.
			handler - Function to handle the callback.
	]]--
	Shame.SetEventHandler = function(event, handler)
		if type(event) == "table" then
			for key, value in pairs(event) do
				Shame.SetEventHandler(key, value);
			end
		else
			Shame.eventFrame:RegisterEvent(event);
			Shame.eventHandlers[event] = handler;
		end
	end

	--[[
		Shame.RemoveEventHandler
		Unregister an existing event handler.

			event - Identifer for the event.
	]]--
	Shame.RemoveEventHandler = function(event)
		Shame.eventFrame:UnregisterEvent(event);
		Shame.eventHandlers[event] = nil;
	end

	--[[
		Shame.RegisterMistake
		Register a player mistake.

			actor - Name of the actor.
			message - Message to display for this mistake.
	]]--
	Shame.RegisterMistake = function(actor, message)
		if not Shame.tracking then return; end
		if not UnitIsPlayer(actor) then return; end

		local newWorth = (Shame.boardGroup[actor] or 0) + 1;

		Shame.boardGroup[actor] = newWorth;

		if Shame.mode == "all" or Shame.mode == "self" then
			local target = nil;
			if Shame.mode == "all" then
				target = Shame.modeChannel;
			end

			Shame.MessageFormatted(message, target);
		end
	end

	--[[
		Shame.Enable
		Enable the shaming.
	]]--
	Shame.Enable = function()
		Shame.tracking = true;
		wipe(Shame.boardGroup);
	end

	--[[
		Shame.Disable
		Disable the shaming.
	]]--
	Shame.Disable = function()
		Shame.tracking = false;
	end

	--[[
		Shame.ListCommands
		List all available commands.
	]]--
	Shame.ListCommands = function()
		Shame.Message("|cff3fc7ebAvailable commands:|r");
		for cmd, cmdData in pairs(COMMANDS) do
			if not cmdData.hidden then
				Shame.MessageFormatted(FORMAT_COMMAND_FULL, nil, cmd, cmdData.usage or "", cmdData.desc);
			end
		end
		return true;
	end

	--[[
		Shame.OnCommand
		Invoked when a command is executed.

			text - The input of the user.
			editbox - Which region the command was executed from.
	]]--
	Shame.OnCommand = function(text, editbox)
		local args = {};
		for arg in string_gmatch(text, "%S+") do
			args[#args + 1] = arg:lower();
		end

		if #args > 0 then
			-- Command entered, process it.
			local command = table_remove(args, 1);
			local commandNode = COMMANDS[command];

			if not commandNode then
				-- No command found by index match, explore for partial.
				for cmd, cmdData in pairs(COMMANDS) do
					if string_sub(cmd, 1, string_len(command)) == command then
						if not commandNode then
							-- First hit, store for possible use.
							commandNode = cmdData;
						else
							-- Multiple hits, abandon partial search.
							commandNode = nil;
							break;
						end
					end
				end
			end

			if commandNode then
				if not commandNode.func(args) then
					Shame.MessageFormatted(FORMAT_COMMAND_SYNTAX, nil, command, commandNode.usage);
				end
			else
				Shame.Message(MESSAGE_COMMAND_HELP);
			end
		else
			-- No command entered, display available commands.
			Shame.ListCommands();
		end
	end

	--[[
		Shame.Validate
		Check if the input is contained within the pool.

			input - Value to check for.
			pool - Table to check inside.
	]]--
	Shame.Validate = function(input, pool)
		if not input then
			return false;
		end

		input = input:lower();

		if pool[input] then
			return input;
		end
		
		for check, _ in pairs(pool) do
			if string_sub(check, 1, string_len(input)) == input then
				return check;
			end
		end

		return false;
	end

	--[[
		Shame.GetCommandFormat
		Format the syntax of a command.

			id - ID of the command.
	]]--
	Shame.GetCommandFormat = function(id)
		id = id:lower();

		local command = COMMANDS[id];
		if command then
			return string_format(FORMAT_COMMAND, id, command.usage or "");
		end

		return "Invalid command";
	end

	--[[
		Shame.GetFormattedList
		Get a formatted list of table values.

			pool - Values to format.
	]]--
	Shame.GetFormattedList = function(pool)
		local items = {};
		for item, _ in pairs(pool) do
			items[#items + 1] = item;
		end

		return string_format("|cffabd473%s|r", table_concat(items, ", "));
	end

	--[[
		Shame.PrintCurrentMode
		Print the current output mode to chat.
	]]--
	Shame.PrintCurrentMode = function()
		if Shame.mode == "all" then
			Shame.MessageFormatted("Real-time shaming mode set to |cfff58cba%s|r |cffaeebffin|r |cfff58cba%s|r|cffaeebff.|r", nil, Shame.mode, Shame.modeChannel);
		else
			Shame.MessageFormatted("Real-time shaming mode set to |cfff58cba%s|r |cffaeebff.", nil, Shame.mode);
		end
	end

	--[[
		Shame.RosterSort
		Sorting function for roster ordering.
	]]--
	Shame.RosterSort = function(a, b)
		return a[2] > b[2];
	end

	--[[
		Shame.Command_Print
		Handler for the 'print' command.

			args - Command arguments.
	]]--
	Shame.Command_Print = function(args)
		local channel = Shame.Validate(args[1], VALID_OUTPUT_CHANNELS);
		if channel then
			Shame.Message("Shame for current session:", channel);

			local rosterIndex = {};
			for actorName, actorWorth in pairs(Shame.boardGroup) do
				rosterIndex[#rosterIndex + 1] = {actorName, actorWorth};
			end

			table_sort(rosterIndex, Shame.RosterSort);

			local done = false;
			for index, node in pairs(rosterIndex) do
				local actorWorth = node[2];

				local suffix = "Mistake";
				if actorWorth > 1 then suffix = suffix .. "s"; end

				Shame.MessageFormatted("%s. %s - %s Shame %s", channel, index, node[1], actorWorth, suffix);
				done = true;
			end

			if not done then
				Shame.MessageFormatted("Nobody has any shame; good job!", channel);
			end
		else
			Shame.MessageFormatted("Invalid channel, use one of these: %s.", nil, Shame.GetFormattedList(VALID_OUTPUT_CHANNELS));
		end

		return true;
	end

	--[[
		Shame.Command_Enable
		Handler for the 'enable' command.
	]]--
	Shame.Command_Enable = function()
		if not Shame.tracking then
			Shame.Enable();
			Shame.Message("Started new shaming session.");
			Shame.PrintCurrentMode();
		else
			Shame.Message("Already shaming; to stop, run: |cffabd473" .. Shame.GetCommandFormat("stop"));
		end

		return true;
	end

	--[[
		Shame.Command_Disable
		Handler for the 'disable' command.
	]]--
	Shame.Command_Disable = function()
		if Shame.tracking then
			Shame.Disable();
			Shame.Message("Stopped shaming session.");
		else
			Shame.Message("Shaming has not yet begun; to start, run: |cffabd473" .. Shame.GetCommandFormat("start"));
		end

		return true;
	end

	--[[
		Shame.Command_SetMode
		Handler for the 'mode' command.

			args - Command arguments.
	]]--
	Shame.Command_SetMode = function(args)
		local mode = Shame.Validate(args[1], VALID_MODES);
		if mode then
			if mode == "all" then
				local channel = Shame.Validate(args[2], VALID_OUTPUT_CHANNELS);
				if channel then
					Shame.modeChannel = channel;
				else
					Shame.Message("Valid channels: " .. Shame.GetFormattedList(VALID_OUTPUT_CHANNELS));
					return false;
				end
			end

			Shame.mode = mode;
			Shame.PrintCurrentMode();
			return true;
		else
			Shame.Message("Valid modes: " .. Shame.GetFormattedList(VALID_MODES));
			return false;
		end
		return false;
	end

	--[[
		Shame.OnEvent_AddonLoaded
		Invoked when the ADDON_LOADED event triggers.
	]]--
	Shame.OnEvent_AddonLoaded = function(addonName)
		if addonName == ADDON_NAME then
			Shame.RemoveEventHandler("ADDON_LOADED");
			Shame.OnLoad();
		end
	end

	-- [[ Initial Set-up ]] --
	Shame.eventFrame:SetScript("OnEvent", Shame.OnEvent);
	Shame.SetEventHandler("ADDON_LOADED", Shame.OnEvent_AddonLoaded);

	SLASH_SHAME1 = "/" .. ADDON_NAME_LOWER;
	SlashCmdList[ADDON_NAME:upper()] = Shame.OnCommand;

	_G["Shame"] = Shame; -- Globalize add-on container.

	-- [[ Data ]] --
	COMMANDS = {
		["start"] = { desc = "Start a monitoring session.", func = Shame.Command_Enable },
		["stop"] = { desc = "Stop a monitoring session.", func = Shame.Command_Disable },
		["mode"] = { desc = "Set the mode for real-time shaming", usage = " [silent|all|self] [channel]", func = Shame.Command_SetMode },
		["print"] = { usage = " [channel]", desc = "Output the current leaderboard.", func = Shame.Command_Print },
		["help"] = { desc = "Display available commands.", func = Shame.ListCommands },
		["?"] = { hidden = true, func = Shame.ListCommands },
	};
end