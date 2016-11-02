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
local FORMAT_READ_OUT = "%s. +%s shame (%s).";
local FORMAT_COMMAND = string_format("/%s %%s|cfff58cba%%s|r", ADDON_NAME_LOWER);
local FORMAT_COMMAND_FULL = string_format("  /%s %%s|cfff58cba%%s|r - |cffabd473%%s|r", ADDON_NAME_LOWER);
local FORMAT_COMMAND_SYNTAX = string_format("Command syntax: |cffabd473/%s %%s|r|cfff58cba%%s|r", ADDON_NAME_LOWER);

local MESSAGE_COMMAND_HELP = string_format("Unknown command. Try '/%s help' for available commands.", ADDON_NAME_LOWER);

local VALID_OUTPUT_CHANNELS = { ["guild"] = true, ["instance"] = true, ["officer"] = true, ["party"] = true, ["raid"] = true };
local VALID_MODES = { ["all"] = true, ["silent"] = true, ["self"] = true };

local COMMANDS;

-- [[ Core ]] --
local _M = {
	eventFrame = CreateFrame("FRAME"),
	eventHandlers = {}, -- Stores assigned event handlers.
	tracking = false, -- Flag for tracking state.
	boardGroup = {},
	modeChannel = "party", -- Real-time shaming channel.
	mode = "self", -- Real-time shaming mode.
};

-- [[ Functions ]] --
_M.Message = function(text, channel)
	if not channel then
		return DEFAULT_CHAT_FRAME:AddMessage(string_format(FORMAT_CHAT_COLORED, text));
	end
	return SendChatMessage(string_format(FORMAT_CHAT_PLAIN, text), channel);
end

_M.MessageFormatted = function(text, channel, ...)
	return _M.Message(string_format(text, ...), channel);
end

_M.OnLoad = function()
	_M.Message("Loaded v" .. GetAddOnMetadata(ADDON_NAME, "Version"));
end

_M.OnEvent = function(self, event, ...)
	local handler = _M.eventHandlers[event];
	if handler then handler(...); end
end

_M.SetEventHandler = function(event, handler)
	if type(event) == "table" then
		for key, value in pairs(event) do
			_M.SetEventHandler(key, value);
		end
	else
		_M.eventFrame:RegisterEvent(event);
		_M.eventHandlers[event] = handler;
	end
end

_M.RemoveEventHandler = function(event)
	_M.eventFrame:UnregisterEvent(event);
	_M.eventHandlers[event] = nil;
end

_M.AddShame = function(actorName, worth, reason, ...)
	if not _M.tracking then return; end

	local baseMessage = string_format(reason, ...);
	local newWorth = (_M.boardGroup[actorName] or 0) + worth;

	_M.boardGroup[actorName] = newWorth;

	if _M.mode == "all" or _M.mode == "self" then
		local target = nil;
		if _M.mode == "all" then
			target = _M.modeChannel;
		end
		
		_M.MessageFormatted(FORMAT_READ_OUT, target, baseMessage, worth, newWorth);
	end
end

_M.Enable = function()
	_M.tracking = true;
	wipe(_M.boardGroup);
	_M.SetEventHandler("CHAT_MSG_OFFICER", _M.OnOfficerChat);
end

_M.Disable = function()
	_M.tracking = false;
end

_M.ListCommands = function()
	_M.Message("|cff3fc7ebAvailable commands:|r");
	for cmd, cmdData in pairs(COMMANDS) do
		if not cmdData.hidden then
			_M.MessageFormatted(FORMAT_COMMAND_FULL, nil, cmd, cmdData.usage or "", cmdData.desc);
		end
	end
	return true;
end

_M.OnOfficerChat = function(message, sender)
	if message:find("^SHAME") then
		local target, worth, reason = message:match("^SHAME:(.+):(%d+):(.+)$");
		_M.AddShame(target, tonumber(worth), reason);
	end
end

_M.OnCommand = function(text, editbox)
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
				_M.MessageFormatted(FORMAT_COMMAND_SYNTAX, nil, command, commandNode.usage);
			end
		else
			_M.Message(MESSAGE_COMMAND_HELP);
		end
	else
		-- No command entered, display available commands.
		_M.ListCommands();
	end
end

_M.Validate = function(input, pool)
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

_M.GetCommandFormat = function(id)
	id = id:lower();

	local command = COMMANDS[id];
	if command then
		return string_format(FORMAT_COMMAND, id, command.usage or "");
	end

	return "Invalid command";
end

_M.GetFormattedList = function(pool)
	local items = {};
	for item, _ in pairs(pool) do
		items[#items + 1] = item;
	end

	return string_format("|cffabd473%s|r", table_concat(items, ", "));
end

_M.PrintCurrentMode = function()
	if _M.mode == "all" then
		_M.MessageFormatted("Real-time shaming mode set to |cfff58cba%s|r |cffaeebffin|r |cfff58cba%s|r|cffaeebff.|r", nil, _M.mode, _M.modeChannel);
	else
		_M.MessageFormatted("Real-time shaming mode set to |cfff58cba%s|r |cffaeebff.", nil, _M.mode);
	end
end

_M.Command_Print = function(args)
	local channel = _M.Validate(args[1], VALID_OUTPUT_CHANNELS);
	if channel then
		_M.Message("Points for current session:", channel);

		local rosterIndex = {};
		for actorName, actorWorth in pairs(_M.boardGroup) do
			rosterIndex[#rosterIndex + 1] = {actorName, actorWorth};
		end

		table_sort(rosterIndex, _M.RosterSort);

		for index, node in pairs(rosterIndex) do
			local actorWorth = node[2];

			local suffix = "Point";
			if actorWorth > 1 then suffix = suffix .. "s"; end

			_M.MessageFormatted("%s. %s - %s Shame %s", channel, index, node[1], actorWorth, suffix);
		end
	else
		_M.MessageFormatted("Invalid channel, use one of these: %s.", nil, _M.GetFormattedList(VALID_OUTPUT_CHANNELS));
	end

	return true;
end

_M.Command_Enable = function()
	if not _M.tracking then
		_M.Enable();
		_M.Message("Started new shaming session.");
		_M.PrintCurrentMode();
	else
		_M.Message("Already shaming; to stop, run: |cffabd473" .. _M.GetCommandFormat("stop"));
	end

	return true;
end

_M.Command_Disable = function()
	if _M.tracking then
		_M.Disable();
		_M.Message("Stopped shaming session.");
	else
		_M.Message("Shaming has not yet begun; to start, run: |cffabd473" .. _M.GetCommandFormat("start"));
	end

	return true;
end

_M.Command_SetMode = function(args)
	local mode = _M.Validate(args[1], VALID_MODES);
	if mode then
		if mode == "all" then
			local channel = _M.Validate(args[2], VALID_OUTPUT_CHANNELS);
			if channel then
				_M.modeChannel = channel;
			else
				_M.Message("Valid channels: " .. _M.GetFormattedList(VALID_OUTPUT_CHANNELS));
				return false;
			end
		end

		_M.mode = mode;
		_M.PrintCurrentMode();
		return true;
	else
		_M.Message("Valid modes: " .. _M.GetFormattedList(VALID_MODES));
		return false;
	end
	return false;
end

_M.OnEvent_AddonLoaded = function(addonName)
	if addonName == ADDON_NAME then
		_M.RemoveEventHandler("ADDON_LOADED");
		_M.OnLoad();
	end
end

-- [[ Initial Set-up ]] --
_M.eventFrame:SetScript("OnEvent", _M.OnEvent);
_M.SetEventHandler("ADDON_LOADED", _M.OnEvent_AddonLoaded);

SLASH_SHAME1 = "/" .. ADDON_NAME_LOWER;
SlashCmdList[ADDON_NAME:upper()] = _M.OnCommand;

-- [[ Data ]] --
COMMANDS = {
	["start"] = { desc = "Start a monitoring session.", func = _M.Command_Enable },
	["stop"] = { desc = "Stop a monitoring session.", func = _M.Command_Disable },
	["mode"] = { desc = "Set the mode for real-time shaming", usage = " [silent|all|self] [channel]", func = _M.Command_SetMode },
	["print"] = { usage = " [channel]", desc = "Output the current leaderboard.", func = _M.Command_Print },
	["help"] = { desc = "Display available commands.", func = _M.ListCommands },
	["?"] = { hidden = true, func = _M.ListCommands },
};