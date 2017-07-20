do
	-- [[ Optimization ]] --
	local wipe = wipe;
	local pairs = pairs;
	local string_format = string.format;
	local SendChatMessage = SendChatMessage;
	local string_sub = string.sub;
	local string_len = string.len;

	-- [[ Initiate ]] --
	local Shame = {
		tracking = false, -- Flag for tracking state.
		boardGroup = {},
		strings = {}, -- Localized strings.
		modeChannel = "party", -- Real-time shaming channel.
	};

	-- Add feed-through to strings table for localization.
	setmetatable(Shame, { __index = function(t, k) return t.strings[k]; end });
	_G["Shame"] = Shame; -- Expose addon container.

	--[[
		Shame.ApplyLocalization
		Copies all given localization into the string table.

			self - Reference to the addon container.
			locale - Localization table.
	]]--
	Shame.ApplyLocalization = function(self, locale)
		local strings = self.strings;
		for key, str in pairs(locale) do
			strings[key] = str;
		end
	end

	--[[
		Shame.Message
		Send a text message to a specified (or default) output.

			self - Reference to the addon container.
			text - Message to be sent.
			channel - Output channel, leave blank for default.
	]]--
	Shame.Message = function(self, text, channel, ...)
		text = text:format(...);

		if not channel then
			-- Print message to users chat.
			DEFAULT_CHAT_FRAME:AddMessage(self.CHAT_PREFIX:format(text));
		else			
			-- Print message to specified channel.
			SendChatMessage(text, channel);
		end
	end

	--[[
		Shame.OnLoad
		Invoked when the addon is loaded.

			self - Reference to the addon container.
	]]--
	Shame.OnLoad = function(self)
		-- Assign default values.
		self.currentMode = self.L_MODE_SELF;

		-- Create chat command.
		_G["SLASH_SHAME1"] = "/" .. self.ADDON_NAME:lower();
		SlashCmdList[self.ADDON_NAME:upper()] = self.OnCommand;

		-- Create table containing valid channels.
		self.validChannels = {
			["guild"] = true,
			["instance"] = true,
			["officer"] = true,
			["party"] = true,
			["raid"] = true
		};

		-- Create table containing valid modes.
		self.validModes = {
			[self.L_MODE_ALL] = true,
			[self.L_MODE_SILENT] = true,
			[self.L_MODE_SELF] = true
		};

		-- Create command table.
		self.commandList = {
			[self.L_CMD_START] = { desc = self.L_CMD_DESC_START, func = self.Command_Enable },
			[self.L_CMD_STOP] = { desc = self.L_CMD_DESC_STOP, func = self.Command_Disable },
			[self.L_CMD_MODE] = { desc = self.L_CMD_DESC_MODE, usage = self.L_CMD_MODE_HELP, func = self.Command_SetMode },
			[self.L_CMD_PRINT] = { desc = self.L_CMD_DESC_PRINT, usage = self.L_CMD_PRINT_HELP, func = self.Command_Print },
			[self.L_CMD_HELP] = { desc = self.L_CMD_DESC_HELP, func = self.ListCommands },
			["?"] = { hidden = true, func = self.ListCommands },
		};

		-- Print loaded message.
		self:Message(self.L_LOADED:format(GetAddOnMetadata(self.ADDON_NAME, "Version")));
	end

	--[[
		Shame.RegisterMistake
		Register a player mistake.

			self - Reference to the addon container.
			actor - Name of the actor.
			message - Message to display for this mistake.
	]]--
	Shame.RegisterMistake = function(self, actor, message)
		if not self.tracking then return; end
		if not UnitIsPlayer(actor) then return; end

		local newWorth = (self.boardGroup[actor] or 0) + 1;

		self.boardGroup[actor] = newWorth;

		if self.currentMode == self.L_MODE_ALL or self.currentMode == self.L_MODE_SELF then
			local target = nil;
			if self.currentMode == self.L_MODE_ALL then
				target = self.modeChannel;
			end

			self:Message(message, target);
		end
	end

	--[[
		Shame.Enable
		Enable the shaming.

			self - Reference to the addon container.
	]]--
	Shame.Enable = function(self)
		self.tracking = true;
		wipe(self.boardGroup);
	end

	--[[
		Shame.Disable
		Disable the shaming.

			self - Reference to the addon container.
	]]--
	Shame.Disable = function(self)
		self.tracking = false;
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
		Shame.PrintCurrentMode
		Print the current output mode to chat.

			self - Reference to the addon container.
	]]--
	Shame.PrintCurrentMode = function(self)
		if self.currentMode == self.L_MODE_ALL then
			self:Message(self.L_MODE_SET, nil, self.currentMode, self.modeChannel);
		else
			self:Message(self.L_MODE_SET_SIMPLE, nil, self.currentMode);
		end
	end
end