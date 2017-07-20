do
	-- [[ Local Optimization ]] --
	local Shame = Shame;
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
	Shame.OnCommand = function(text, editbox)
		local args, self = {}, Shame;
		for arg in string_gmatch(text, "%S+") do
			args[#args + 1] = arg:lower();
		end

		if #args > 0 then
			-- Command entered, process it.
			local command = table_remove(args, 1);
			local commandNode = self.commandList[command];

			if not commandNode then
				-- No command found by index match, explore for partial.
				for cmd, cmdData in pairs(self.commandList) do
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
				if not commandNode.func(self, args) then
					self:Message(self.L_COMMAND_SYNTAX, nil, command, commandNode.usage);
				end
			else
				self:Message(self.L_UNKNOWN_COMMAND);
			end
		else
			-- No command entered, display available commands.
			self:ListCommands();
		end
	end

	--[[
		Shame.ListCommands
		List all available commands.

			self - Reference to the addon container.
	]]--
	Shame.ListCommands = function(self)
		self:Message(self.L_AVAILABLE_COMMANDS);
		for cmd, cmdData in pairs(self.commandList) do
			if not cmdData.hidden then
				self:Message(self.FORMAT_COMMAND_FULL, nil, cmd, cmdData.usage or "", cmdData.desc);
			end
		end
		return true;
	end

	--[[
		Shame.GetCommandFormat
		Format the syntax of a command.

			self - Reference to the addon container.
			id - ID of the command.
	]]--
	Shame.GetCommandFormat = function(self, id)
		id = id:lower();

		local command = COMMANDS[id];
		if command then
			return string_format(self.FORMAT_COMMAND, id, command.usage or "");
		end

		return self.L_INVALID_COMMAND;
	end

	--[[
		Shame.GetFormattedList
		Get a formatted list of table values.

			self - Reference to the addon container.
			pool - Values to format.
	]]--
	Shame.GetFormattedList = function(self, pool)
		local items = {};
		for item, _ in pairs(pool) do
			items[#items + 1] = item;
		end

		return self.LIST_FORMAT:format(table_concat(items, ", "));
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

			self - Reference to the addon container.
			args - Command arguments.
	]]--
	Shame.Command_Print = function(self, args)
		local channel = self.Validate(args[1], self.validChannels);
		if channel then
			self:Message(self.L_CURRENT_SESSION, channel);

			local rosterIndex = {};
			for actorName, actorWorth in pairs(self.boardGroup) do
				rosterIndex[#rosterIndex + 1] = {actorName, actorWorth};
			end

			table_sort(rosterIndex, self.RosterSort);

			local done = false;
			for index, node in pairs(rosterIndex) do
				local actorWorth = node[2];
				local suffix = actorWorth > 1 and self.L_MISTAKE_MULTI or self.L_MISTAKE_SINGLE;

				self:Message("%s. %s - %s Shame %s", channel, index, node[1], actorWorth, suffix);
				done = true;
			end

			if not done then
				self.Message(self.L_NO_SHAME, channel);
			end
		else
			self:Message(self.L_INVALID_CHANNEL, nil, self:GetFormattedList(self.validChannels));
		end

		return true;
	end

	--[[
		Shame.Command_Enable
		Handler for the 'enable' command.

			self - Reference to the addon container.
	]]--
	Shame.Command_Enable = function(self)
		if not self.tracking then
			self:Enable();
			self:Message(self.L_NEW_SESSION);
			self:PrintCurrentMode();
		else
			self:Message(self.L_ALREADY_RUNNING .. self.GetCommandFormat(self.L_CMD_STOP));
		end

		return true;
	end

	--[[
		Shame.Command_Disable
		Handler for the 'disable' command.

			self - Reference to the addon container.
	]]--
	Shame.Command_Disable = function(self)
		if self.tracking then
			self:Disable();
			self:Message(self.L_STOPPED);
		else
			self:Message(self.L_NOT_STARTED .. self:GetCommandFormat(self.L_CMD_START));
		end

		return true;
	end

	--[[
		Shame.Command_SetMode
		Handler for the 'mode' command.

			self - Reference to the addon container.
			args - Command arguments.
	]]--
	Shame.Command_SetMode = function(self, args)
		local mode = self.Validate(args[1], self.validModes);
		if mode then
			if mode == self.L_MODE_ALL then
				local channel = self.Validate(args[2], self.validChannels);
				if channel then
					self.modeChannel = channel;
				else
					self:Message(self.L_VALID_CHANNELS, nil, self:GetFormattedList(self.validChannels));
					return false;
				end
			end

			self.currentMode = mode;
			self:PrintCurrentMode();
			return true;
		else
			self:Message(self.L_VALID_MODES, nil, self:GetFormattedList(self.validModes));
			return false;
		end
		return false;
	end
end