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
	local VALID_OUTPUT_CHANNELS = { ["guild"] = true, ["instance"] = true, ["officer"] = true, ["party"] = true, ["raid"] = true };
	local VALID_MODES = { ["all"] = true, ["silent"] = true, ["self"] = true };

	-- [[ Core Container ]] --
	local Shame = {
		eventFrame = CreateFrame("FRAME"),
		eventHandlers = {}, -- Stores assigned event handlers.
		tracking = false, -- Flag for tracking state.
		boardGroup = {},
		strings = {}, -- Localized strings.
		modeChannel = "party", -- Real-time shaming channel.
		mode = "self", -- Real-time shaming mode.
	};

	--[[
		Shame.ApplyLocalization
		Copies all given localization into the string table.

			locale - Localization table.
	]]--
	Shame.ApplyLocalization = function(locale)
		local strings = Shame.strings;
		for key, str in pairs(locale) do
			strings[key] = str;
		end
	end

	--[[
		Shame.Message
		Send a text message to a specified (or default) output.

			text - Message to be sent.
			channel - Output channel, leave blank for default.
	]]--
	Shame.Message = function(text, channel, ...)
		text = text:format(...);

		if not channel then
			-- Print message to users chat.
			DEFAULT_CHAT_FRAME:AddMessage(Shame.CHAT_PREFIX:format(text));
		else			
			-- Print message to specified channel.
			SendChatMessage(text, channel);
		end
	end

	--[[
		Shame.OnLoad
		Invoked when the addon is loaded.
	]]--
	Shame.OnLoad = function()
		-- Create chat command.
		_G["SLASH_SHAME1"] = "/" .. Shame.ADDON_NAME:lower();
		SlashCmdList[Shame.ADDON_NAME:upper()] = Shame.OnCommand;

		-- Create command table.
		Shame.commandList = {
			[Shame.L_CMD_START] = { desc = Shame.L_CMD_DESC_START, func = Shame.Command_Enable },
			[Shame.L_CMD_STOP] = { desc = Shame.L_CMD_DESC_STOP, func = Shame.Command_Disable },
			[Shame.L_CMD_MODE] = { desc = Shame.L_CMD_DESC_MODE, usage = Shame.L_CMD_MODE_HELP, func = Shame.Command_SetMode },
			[Shame.L_CMD_PRINT] = { desc = Shame.L_CMD_DESC_PRINT, usage = Shame.L_CMD_PRINT_HELP, func = Shame.Command_Print },
			[Shame.L_CMD_HELP] = { desc = Shame.L_CMD_DESC_HELP, func = Shame.ListCommands },
			["?"] = { hidden = true, func = Shame.ListCommands },
		};

		-- Print loaded message.
		Shame.Message(Shame.L_LOADED:format(GetAddOnMetadata(Shame.ADDON_NAME, "Version")));
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

			Shame.Message(message, target);
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
		Shame.Message(Shame.L_AVAILABLE_COMMANDS);
		for cmd, cmdData in pairs(Shame.commandList) do
			if not cmdData.hidden then
				Shame.Message(Shame.FORMAT_COMMAND_FULL, nil, cmd, cmdData.usage or "", cmdData.desc);
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
			local commandNode = Shame.commandList[command];

			if not commandNode then
				-- No command found by index match, explore for partial.
				for cmd, cmdData in pairs(Shame.commandList) do
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
					Shame.Message(Shame.L_COMMAND_SYNTAX .. Shame.FORMAT_COMMAND_SYNTAX, nil, command, commandNode.usage);
				end
			else
				Shame.Message(Shame.L_UNKNOWN_COMMAND);
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
			return string_format(Shame.FORMAT_COMMAND, id, command.usage or "");
		end

		return Shame.L_INVALID_COMMAND;
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
			Shame.Message(Shame.L_MODE_SET, nil, Shame.mode, Shame.modeChannel);
		else
			Shame.Message(Shame.L_MODE_SET_SIMPLE, nil, Shame.mode);
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
			Shame.Message(Shame.L_CURRENT_SESSION, channel);

			local rosterIndex = {};
			for actorName, actorWorth in pairs(Shame.boardGroup) do
				rosterIndex[#rosterIndex + 1] = {actorName, actorWorth};
			end

			table_sort(rosterIndex, Shame.RosterSort);

			local done = false;
			for index, node in pairs(rosterIndex) do
				local actorWorth = node[2];
				local suffix = actorWorth > 1 and Shame.L_MISTAKE_MULTI or Shame.L_MISTAKE_SINGLE;

				Shame.Message("%s. %s - %s Shame %s", channel, index, node[1], actorWorth, suffix);
				done = true;
			end

			if not done then
				Shame.Message(Shame.L_NO_SHAME, channel);
			end
		else
			Shame.Message(Shame.L_INVALID_CHANNEL, nil, Shame.GetFormattedList(VALID_OUTPUT_CHANNELS));
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
			Shame.Message(Shame.L_NEW_SESSION);
			Shame.PrintCurrentMode();
		else
			Shame.Message(Shame.L_ALREADY_RUNNING .. Shame.GetCommandFormat(Shame.L_CMD_STOP));
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
			Shame.Message(Shame.L_STOPPED);
		else
			Shame.Message(Shame.L_NOT_STARTED .. Shame.GetCommandFormat(Shame.L_CMD_START));
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
					Shame.Message(Shame.L_VALID_CHANNELS .. Shame.GetFormattedList(VALID_OUTPUT_CHANNELS));
					return false;
				end
			end

			Shame.mode = mode;
			Shame.PrintCurrentMode();
			return true;
		else
			Shame.Message(Shame.L_VALID_MODES .. Shame.GetFormattedList(VALID_MODES));
			return false;
		end
		return false;
	end

	--[[
		Shame.OnEvent_AddonLoaded
		Invoked when the ADDON_LOADED event triggers.
	]]--
	Shame.OnEvent_AddonLoaded = function(addonName)
		if addonName == Shame.ADDON_NAME then
			Shame.RemoveEventHandler("ADDON_LOADED");
			Shame.OnLoad();
		end
	end

	-- [[ Initial Set-up ]] --

	-- Initiate event handling.
	Shame.eventFrame:SetScript("OnEvent", Shame.OnEvent);
	Shame.SetEventHandler("ADDON_LOADED", Shame.OnEvent_AddonLoaded);

	_G["Shame"] = Shame; -- Expose reference globally.
	setmetatable(Shame, { __index = function(t, k) return t.strings[k]; end }); -- Localization.
end