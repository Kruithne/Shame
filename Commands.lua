do
	-- [[ Local Optimization ]] --
	local _S = Shame;
	local pairs = pairs;
	local table_sort = table.sort;
	local string_len = string.len;
	local table_remove = table.remove;
	local string_gmatch = string.gmatch;
	local table_concat = table.concat;
	local string_sub = string.sub;

	--[[
		Shame.OnCommand
		Invoked when a command is executed.

			text - The input of the user.
			editbox - Which region the command was executed from.
	]]--
	_S.OnCommand = function(text, editbox)
		local args = {};
		for arg in string_gmatch(text, "%S+") do
			args[#args + 1] = arg:lower();
		end

		if #args > 0 then
			-- Command entered, process it.
			local command = table_remove(args, 1);
			local commandNode = _S.commandList[command];

			if not commandNode then
				-- No command found by index match, explore for partial.
				for cmd, cmdData in pairs(_S.commandList) do
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
					_S.Message(_S.L_COMMAND_SYNTAX, nil, command, commandNode.usage);
				end
			else
				_S.Message(_S.L_UNKNOWN_COMMAND);
			end
		else
			-- No command entered, display available commands.
			Shame.ListCommands();
		end
	end

	--[[
		Shame.ListCommands
		List all available commands.
	]]--
	_S.ListCommands = function()
		_S.Message(_S.L_AVAILABLE_COMMANDS);
		for cmd, cmdData in pairs(_S.commandList) do
			if not cmdData.hidden then
				_S.Message(_S.FORMAT_COMMAND_FULL, nil, cmd, cmdData.usage or "", cmdData.desc);
			end
		end
		return true;
	end

	--[[
		Shame.GetCommandFormat
		Format the syntax of a command.

			id - ID of the command.
	]]--
	_S.GetCommandFormat = function(id)
		id = id:lower();

		local command = COMMANDS[id];
		if command then
			return string_format(_S.FORMAT_COMMAND, id, command.usage or "");
		end

		return _S.L_INVALID_COMMAND;
	end

	--[[
		Shame.GetFormattedList
		Get a formatted list of table values.

			pool - Values to format.
	]]--
	_S.GetFormattedList = function(pool)
		local items = {};
		for item, _ in pairs(pool) do
			items[#items + 1] = item;
		end

		return _S.LIST_FORMAT:format(table_concat(items, ", "));
	end

	--[[
		Shame.RosterSort
		Sorting function for roster ordering.
	]]--
	_S.RosterSort = function(a, b)
		return a[2] > b[2];
	end

	--[[
		Shame.Command_Print
		Handler for the 'print' command.

			args - Command arguments.
	]]--
	_S.Command_Print = function(args)
		local channel = _S.Validate(args[1], _S.validChannels);
		if channel then
			_S.Message(_S.L_CURRENT_SESSION, channel);

			local rosterIndex = {};
			for actorName, actorWorth in pairs(_S.boardGroup) do
				rosterIndex[#rosterIndex + 1] = {actorName, actorWorth};
			end

			table_sort(rosterIndex, _S.RosterSort);

			local done = false;
			for index, node in pairs(rosterIndex) do
				local actorWorth = node[2];
				local suffix = actorWorth > 1 and _S.L_MISTAKE_MULTI or _S.L_MISTAKE_SINGLE;

				_S.Message("%s. %s - %s Shame %s", channel, index, node[1], actorWorth, suffix);
				done = true;
			end

			if not done then
				_S.Message(_S.L_NO_SHAME, channel);
			end
		else
			_S.Message(_S.L_INVALID_CHANNEL, nil, _S.GetFormattedList(_S.validChannels));
		end

		return true;
	end

	--[[
		Shame.Command_Enable
		Handler for the 'enable' command.
	]]--
	_S.Command_Enable = function()
		if not _S.tracking then
			_S.Enable();
			_S.Message(_S.L_NEW_SESSION);
			_S.PrintCurrentMode();
		else
			_S.Message(_S.L_ALREADY_RUNNING .. _S.GetCommandFormat(_S.L_CMD_STOP));
		end

		return true;
	end

	--[[
		Shame.Command_Disable
		Handler for the 'disable' command.
	]]--
	_S.Command_Disable = function()
		if _S.tracking then
			_S.Disable();
			_S.Message(_S.L_STOPPED);
		else
			_S.Message(_S.L_NOT_STARTED .. _S.GetCommandFormat(_S.L_CMD_START));
		end

		return true;
	end

	--[[
		Shame.Command_SetMode
		Handler for the 'mode' command.

			args - Command arguments.
	]]--
	_S.Command_SetMode = function(args)
		local mode = _S.Validate(args[1], _S.validModes);
		if mode then
			if mode == _S.L_MODE_ALL then
				local channel = _S.Validate(args[2], _S.validChannels);
				if channel then
					_S.modeChannel = channel;
				else
					_S.Message(_S.L_VALID_CHANNELS, nil, _S.GetFormattedList(_S.validChannels));
					return false;
				end
			end

			_S.currentMode = mode;
			_S.PrintCurrentMode();
			return true;
		else
			_S.Message(_S.L_VALID_MODES, nil, _S.GetFormattedList(_S.validModes));
			return false;
		end
		return false;
	end
end