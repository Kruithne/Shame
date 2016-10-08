-- [[ Optimization ]] --
local type = type;
local pairs = pairs;
local string_format = string.format;
local SendChatMessage = SendChatMessage;

local TYPE_TABLE = "table";

-- [[ Constants ]] --
local ADDON_NAME = "Shame";
local FORMAT_CHAT_COLORED = string_format("|cffff996f[%s]|r |cffaeebff%%s|r", ADDON_NAME);
local FORMAT_CHAT_PLAIN = string_format("[%s] %%s", ADDON_NAME);

local FAIL_TYPE_TEST = 1;

local ENCOUNTER_DATA;
local FAIL_TYPES;

-- [[ Core ]] --
local _M = {
	eventFrame = CreateFrame("FRAME"),
	eventHandlers = {},
	currentPool = nil,
};

-- [[ Functions ]] --
_M.Message = function(text, channel)
	if not channel then
		return DEFAULT_CHAT_FRAME:AddMessage(string_format(FORMAT_CHAT_COLORED, text));
	end
	return SendChatMessage(string_format(FORMAT_CHAT_PLAIN, text), "CHANNEL");
end

_M.OnLoad = function()
	_M.SetEventHandler({
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
	if type(event) == TYPE_TABLE then
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

_M.ThrowResponse = function(failType, ...)
	if failType then
		_M.Message(string_format(failType.message, ...));
	end
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
end

_M.OnEvent_CombatLogEventUnfiltered = function(serverTime, subEvent, ...)
	local masterPool = _M.currentPool;
	if not masterPool then return; end

	local pool = masterPool[subEvent];
	if not pool then return end;

	if subEvent:find("SWING") or subEvent:find("ENVIRONMENTAL") then
		-- ToDo: Handle these if needed.
	else
		print(select(10, ...));
		local node = pool[select(10, ...)];
		if node then
			local failType = FAIL_TYPES[node.errorType];
			_M.ThrowResponse(failType.func(node, failType, ...));
		end
	end
end

_M.FailCheck_Generic = function(node, failType, ...)
	return failType, select(3, ...), select(11, ...);
end

-- [[ Initial Set-up ]] --
_M.eventFrame:SetScript("OnEvent", _M.OnEvent);
_M.SetEventHandler("ADDON_LOADED", _M.OnEvent_AddonLoaded);

-- [[ Data ]] --

FAIL_TYPES = {
	[FAIL_TYPE_TEST] = { message = "%s cast %s during a test.", func = _M.FailCheck_Generic }
};

ENCOUNTER_DATA = {
	[1077] = {
		["SPELL_HEAL"] = {
			[18562] = { errorType = FAIL_TYPE_TEST, worth = 2 }
		}
	}
};