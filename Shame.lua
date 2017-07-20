do
	-- [[ Optimization ]] --
	local wipe = wipe;
	local pairs = pairs;
	local string_format = string.format;
	local SendChatMessage = SendChatMessage;
	local string_sub = string.sub;
	local string_len = string.len;

	-- [[ Initiate ]] --
	local _S = {
		tracking = false, -- Flag for tracking state.
		boardGroup = {},
		strings = {}, -- Localized strings.
		modeChannel = "party", -- Real-time shaming channel.
	}; Shame = _S;

	-- Add feed-through to strings table for localization.
	setmetatable(_S, { __index = function(t, k) return t.strings[k]; end });

	--[[
		Shame.ApplyLocalization
		Copies all given localization into the string table.

			locale - Localization table.
	]]--
	_S.ApplyLocalization = function(locale)
		local strings = _S.strings;
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
	_S.Message = function(text, channel, ...)
		text = text:format(...);

		if not channel then
			-- Print message to users chat.
			DEFAULT_CHAT_FRAME:AddMessage(_S.CHAT_PREFIX:format(text));
		else			
			-- Print message to specified channel.
			SendChatMessage(text, channel);
		end
	end

	--[[
		Shame.OnLoad
		Invoked when the addon is loaded.
	]]--
	_S.OnLoad = function()
		-- Assign default values.
		_S.currentMode = _S.L_MODE_SELF;

		-- Create chat command.
		_G["SLASH_SHAME1"] = "/" .. _S.ADDON_NAME:lower();
		SlashCmdList[_S.ADDON_NAME:upper()] = _S.OnCommand;

		-- Create table containing valid channels.
		_S.validChannels = {
			["guild"] = true,
			["instance"] = true,
			["officer"] = true,
			["party"] = true,
			["raid"] = true
		};

		-- Create table containing valid modes.
		_S.validModes = {
			[_S.L_MODE_ALL] = true,
			[_S.L_MODE_SILENT] = true,
			[_S.L_MODE_SELF] = true
		};

		-- Create command table.
		_S.commandList = {
			[_S.L_CMD_START] = { desc = _S.L_CMD_DESC_START, func = _S.Command_Enable },
			[_S.L_CMD_STOP] = { desc = _S.L_CMD_DESC_STOP, func = _S.Command_Disable },
			[_S.L_CMD_MODE] = { desc = _S.L_CMD_DESC_MODE, usage = _S.L_CMD_MODE_HELP, func = _S.Command_SetMode },
			[_S.L_CMD_PRINT] = { desc = _S.L_CMD_DESC_PRINT, usage = _S.L_CMD_PRINT_HELP, func = _S.Command_Print },
			[_S.L_CMD_HELP] = { desc = _S.L_CMD_DESC_HELP, func = _S.ListCommands },
			["?"] = { hidden = true, func = _S.ListCommands },
		};

		-- Print loaded message.
		_S.Message(_S.L_LOADED:format(GetAddOnMetadata(_S.ADDON_NAME, "Version")));
	end

	--[[
		Shame.RegisterMistake
		Register a player mistake.

			actor - Name of the actor.
			message - Message to display for this mistake.
	]]--
	_S.RegisterMistake = function(actor, message)
		if not _S.tracking then return; end
		if not UnitIsPlayer(actor) then return; end

		local newWorth = (_S.boardGroup[actor] or 0) + 1;

		_S.boardGroup[actor] = newWorth;

		if _S.currentMode == _S.L_MODE_ALL or _S.currentMode == _S.L_MODE_SELF then
			local target = nil;
			if _S.currentMode == _S.L_MODE_ALL then
				target = _S.modeChannel;
			end

			_S.Message(message, target);
		end
	end

	--[[
		Shame.Enable
		Enable the shaming.
	]]--
	_S.Enable = function()
		_S.tracking = true;
		wipe(_S.boardGroup);
	end

	--[[
		Shame.Disable
		Disable the shaming.
	]]--
	_S.Disable = function()
		_S.tracking = false;
	end

	--[[
		Shame.Validate
		Check if the input is contained within the pool.

			input - Value to check for.
			pool - Table to check inside.
	]]--
	_S.Validate = function(input, pool)
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
	]]--
	_S.PrintCurrentMode = function()
		if _S.currentMode == _S.L_MODE_ALL then
			_S.Message(_S.L_MODE_SET, nil, _S.currentMode, _S.modeChannel);
		else
			_S.Message(_S.L_MODE_SET_SIMPLE, nil, _S.currentMode);
		end
	end
end