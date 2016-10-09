-- [[ Optimization ]] --
local type = type;
local wipe = wipe;
local pairs = pairs;
local IsInRaid = IsInRaid;
local After = C_Timer.After;
local IsInGroup = IsInGroup;
local string_sub = string.sub;
local string_len = string.len;
local table_sort = table.sort;
local table_remove = table.remove;
local table_concat = table.concat;
local string_format = string.format;
local string_gmatch = string.gmatch;
local SendChatMessage = SendChatMessage;
local GetCurrentMapAreaID = GetCurrentMapAreaID;
local SetMapToCurrentZone = SetMapToCurrentZone;

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

local RAID_SLOTS = {}; for i = 1, 40 do RAID_SLOTS[i] = "raid" .. i; end
local PARTY_SLOTS = {}; for i = 1, 4 do PARTY_SLOTS[i] = "party" .. i; end

local VALID_OUTPUT_CHANNELS = { ["guild"] = true, ["instance"] = true, ["officer"] = true, ["party"] = true, ["raid"] = true };
local VALID_MODES = { ["all"] = true, ["silent"] = true, ["self"] = true };

local FAIL_TYPE_SELF_CAST = 1;
local FAIL_TYPE_CATCH_OTHER = 2;
local FAIL_TYPE_DANGER_ZONE = 3;
local FAIL_TYPE_TANK_AIM = 4;

local ENCOUNTER_DATA;
local FAIL_TYPES;
local COMMANDS;

-- [[ Core ]] --
local _M = {
	eventFrame = CreateFrame("FRAME"),
	groupData = nil, -- Used to store group GUID cache.
	groupRoles = nil, -- Used to store group roles.
	playerGUID = UnitGUID("player"), -- Player's GUID.
	eventHandlers = {}, -- Stores assigned event handlers.
	currentPool = nil, -- Current encounter nodes for the map.
	nameCache = {}, -- GUID -> name cache.
	tracking = false, -- Flag for tracking state.
	boardGroup = {}, -- Leaderboard for the group.
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
	_M.SetEventHandler({
		["RAID_ROSTER_UPDATE"] = _M.OnEvent_RosterUpdate,
		["GROUP_ROSTER_UPDATE"] = _M.OnEvent_RosterUpdate,
		["PLAYER_SPECIALIZATION_CHANGED"] = _M.OnEvent_RosterUpdate,

		["ZONE_CHANGED_NEW_AREA"] = _M.OnEvent_ZoneChangedNewArea,
		["PLAYER_ENTERING_WORLD"] = _M.OnEvent_ZoneChangedNewArea,

		["COMBAT_LOG_EVENT_UNFILTERED"] = _M.OnEvent_CombatLogEventUnfiltered,
	});

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

_M.ThrowResponse = function(actorGUID, node, failType, ...)
	if failType then
		local baseMessage = string_format(failType.message, ...);
		local worth = node.worth or 1;
		local newWorth = (_M.boardGroup[actorGUID] or 0) + worth;

		_M.boardGroup[actorGUID] = newWorth;
		_M.ActorName(actorGUID);

		if _M.mode == "all" or _M.mode == "self" then
			local target = nil;
			if _M.mode == "all" then target = _M.modeChannel; end

			_M.MessageFormatted(FORMAT_READ_OUT, target, baseMessage, worth, newWorth);
		end
	end
end

_M.ActorName = function(guid)
	local name = _M.nameCache[guid];
	if not name then
		local unitID = guid == _M.playerGUID and "player" or _M.groupData[guid];
		local name = UnitName(unitID);

		_M.nameCache[guid] = name;
		return name;
	end
	return name;
end

_M.IsGroupActor = function(guid)
	if guid == _M.playerGUID then
		return "player";
	end

	local groupData = _M.groupData;
	return groupData and groupData[guid] or nil;
end

_M.GetActorRole = function(guid)
	if _M.roleData then
		local role = _M.roleData[guid];
		if role then
			return role;
		end
	end
	return "NONE";
end

_M.IsActorTank = function(guid)
	return _M.GetActorRole(guid) == "TANK";
end

_M.IsActorDamage = function(guid)
	return _M.GetActorRole(guid) == "DAMAGER";
end

_M.IsActorHealer = function(guid)
	return _M.GetActorRole(guid) == "HEALER";
end

_M.Enable = function()
	_M.tracking = true;
	wipe(_M.boardGroup);
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

_M.RosterSort = function(a, b)
	return a[2] > b[2];
end

_M.Command_Print = function(args)
	local channel = _M.Validate(args[1], VALID_OUTPUT_CHANNELS);
	if channel then
		_M.Message("Points for current session:", channel);

		local rosterIndex = {};
		for actorGUID, actorWorth in pairs(_M.boardGroup) do
			rosterIndex[#rosterIndex + 1] = {actorGUID, actorWorth};
		end

		table_sort(rosterIndex, _M.RosterSort);

		--local index = 1;
		for index, node in pairs(rosterIndex) do
			local actorWorth = node[2];
			local actorGUID = node[1];

			local suffix = "Point";
			if actorWorth > 1 then suffix = suffix .. "s"; end

			_M.MessageFormatted("%s. %s - %s Shame %s", channel, index, _M.ActorName(actorGUID), actorWorth, suffix);
			--index = index + 1;
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

_M.OnEvent_ZoneChangedNewArea = function()
	local mapID, isContinent = GetCurrentMapAreaID();
	SetMapToCurrentZone();

	_M.currentPool = not isContinent and ENCOUNTER_DATA[mapID] or nil;
	_M.groupData = _M.currentPool and {} or nil;
	_M.groupRoles = _M.currentPool and {} or nil;
end

_M.OnEvent_CombatLogEventUnfiltered = function(serverTime, subEvent, ...)
	-- Ensure we're actually tracking.
	if not _M.tracking then return; end

	-- Check we have a valid encounter pool on this map.
	local masterPool = _M.currentPool;
	if not masterPool then return; end

	-- Check we have an event pool for this event.
	local pool = masterPool[subEvent];
	if not pool then return end;

	--if subEvent:find("SWING") or subEvent:find("ENVIRONMENTAL") then
	-- ToDo: We don't use these currently, but if we do, catch them here.

	local node = pool[select(10, ...)];
	if node then
		local failType = FAIL_TYPES[node.errorType];
		_M.ThrowResponse(failType.func(node, failType, ...));
	end
end

_M.OnEvent_RosterUpdate = function()
	if _M.currentPool then
		local groupData = wipe(_M.groupData);
		local roleData = wipe(_M.groupRoles);
		local slotPool;

		if IsInRaid() then
			slotPool = RAID_SLOTS;
		elseif IsInGroup() then
			slotPool = PARTY_SLOTS;
		end

		if slotPool then
			for i = 1, #slotPool do
				local unitID = slotPool[i];
				if UnitExists(unitID) then
					local actorGUID = UnitGUID(unitID);
					groupData[actorGUID] = unitID;
					roleData[actorGUID] = UnitGroupRolesAssigned(unitID);
				end
			end
		end
	end
end

_M.FailCheck_SelfCast = function(node, failType, ...)
	local _, sourceGUID, sourceName, _, _, _, _, _, _, _, spellName = ...;

	if _M.IsGroupActor(sourceGUID) then
		return sourceGUID, node, failType, sourceName, spellName;
	end

	return nil;
end

local _CatchOtherCache = {};
_M.FailCheck_CatchOther = function(node, failType, ...)
	if node.track then
		-- source = NPC which cast the spell in the first place.
		-- dest = Player who just had the aura expire.
		local _, sourceGUID, sourceName, _, _, destGUID = ...;

		if _M.IsGroupActor(destGUID) then
			_CatchOtherCache[sourceGUID] = destGUID;
		end

		return nil;
	else
		-- source = NPC which cast the spell in the first place.
		-- dest = Player who was just hit by the damage.
		local _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, _, spellName = ...;
		local faultActor = _CatchOtherCache[sourceGUID];

		if faultActor then
			local removeFunc = function() _CatchOtherCache[sourceGUID] = nil; end
			After(2, removeFunc);

			if faultActor ~= destGUID then
				return faultActor, node, failType, _M.ActorName(faultActor), destName, spellName; 
			end
		end
	end

	return nil;
end

_M.FailCheck_DangerZone = function(node, failType, ...)
	local _, _, _, _, _, destGUID, destName, _, _, _, spellName = ...;

	if _M.IsGroupActor(destGUID) then
		return destGUID, node, failType, destName, spellName;
	end

	return nil;
end

local _CacheTankAim = {};
_M.FailCheck_TankAim = function(node, failType, ...)
	local _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, _, spellName = ...;

	if not _CacheTankAim[sourceGUID] then
		_CacheTankAim[sourceGUID] = {};

		local verifyFunc = function()
			local tanks = {};
			local victims = {};

			for actorGUID, actorName in pairs(_CacheTankAim) do
				if _M.IsActorTank(actorGUID) then
					tanks[#tanks + 1] = actorGUID;
				else
					victims[#victims + 1] = actorGUID;
				end
			end

			if #victims and #tanks then
				local hitText = #victims > 1 and "multiple people" or victims[1];
				for i = 1, #tanks do 
					local tankGUID = tanks[i];
					if _M.IsGroupActor(tankGUID) then
						_M.ThrowResponse(node, failType, tanks[tankGUID], spellName);
					end
				end
			end

			_CacheTankAim[sourceGUID] = nil;
		end

		After(1, verifyFunc);
	end

	_CacheTankAim[sourceGUID][destGUID] = destName;
	return nil;
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

FAIL_TYPES = {
	[FAIL_TYPE_SELF_CAST] = { message = "%s cast %s", func = _M.FailCheck_SelfCast },
	[FAIL_TYPE_CATCH_OTHER] = { message = "%s hit %s with %s", func = _M.FailCheck_CatchOther },
	[FAIL_TYPE_DANGER_ZONE] = { message = "%s stood in the %s", func = _M.FailCheck_DangerZone },
	[FAIL_TYPE_TANK_AIM] = { message = "%s failed to aim %s properly", func = _M.FailCheck_TankAim },
};

ENCOUNTER_DATA = {
	[1105] = { -- Halls of Valor
		["SPELL_AURA_REMOVED"] = {
			[198599] = { errorType = FAIL_TYPE_CATCH_OTHER, track = true }, -- Valarjar Thundercaller @ Thunderstrike (Aura) [Heroic]
		},
		["SPELL_DAMAGE"] = {
			[198605] = { errorType = FAIL_TYPE_CATCH_OTHER, worth = 2 }, -- Valarjar Thundercaller @ Thunderstrike (Damage Hit) [Heroic]
			[193092] = { errorType = FAIL_TYPE_TANK_AIM }, -- Hymdall @ Bloodletting Sweep (Cleave) [Heroic]
		},
		["SPELL_PERIODIC_DAMAGE"] = {
			[193234] = { errorType = FAIL_TYPE_DANGER_ZONE }, -- Hymdall @ Dancing Blade (Periodic Debuff)
		},
	}
};