-- [[ Optimization ]] --
local type = type;
local wipe = wipe;
local pairs = pairs;
local IsInRaid = IsInRaid;
local IsInGroup = IsInGroup;
local string_format = string.format;
local SendChatMessage = SendChatMessage;
local GetCurrentMapAreaID = GetCurrentMapAreaID;
local SetMapToCurrentZone = SetMapToCurrentZone;

local TYPE_TABLE = "table";
local UNIT_TYPE_PLAYER = "player";

-- [[ Constants ]] --
local ADDON_NAME = "Shame";
local FORMAT_CHAT_COLORED = string_format("|cffff996f[%s]|r |cffaeebff%%s|r", ADDON_NAME);
local FORMAT_CHAT_PLAIN = string_format("[%s] %%s", ADDON_NAME);
local FORMAT_READ_OUT = "%s. +%s shame (%s).";
local RAID_SLOTS = {}; for i = 1, 40 do RAID_SLOTS[i] = "raid" .. i; end
local PARTY_SLOTS = {}; for i = 1, 4 do PARTY_SLOTS[i] = "party" .. i; end

local FAIL_TYPE_TEST = 1;
local FAIL_CATCH_OTHER = 2;

local ENCOUNTER_DATA;
local FAIL_TYPES;

-- [[ Core ]] --
local _M = {
	eventFrame = CreateFrame("FRAME"),
	groupData = nil, -- Used to store group GUID cache.
	playerGUID = UnitGUID(UNIT_TYPE_PLAYER), -- Player's GUID.
	eventHandlers = {}, -- Stores assigned event handlers.
	currentPool = nil, -- Current encounter nodes for the map.
	tracking = false, -- Flag for tracking state.
	boardGroup = {}, -- Leaderboard for the group.
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
		["RAID_ROSTER_UPDATE"] = _M.OnEvent_RosterUpdate,
		["GROUP_ROSTER_UPDATE"] = _M.OnEvent_RosterUpdate,
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

_M.ThrowResponse = function(actorGUID, failType, ...)
	if failType then
		local channel = nil;
		if IsInRaid() then
			channel = "RAID";
		elseif IsInGroup() then
			channel = "PARTY";
		end

		local baseMessage = string_format(failType.message, ...);
		local worth = failType.worth or 1;
		local newWorth = (_M.boardGroup[actorGUID] or 0) + worth;

		_M.boardGroup[actorGUID] = newWorth;
		_M.Message(string_format(FORMAT_READ_OUT, baseMessage, worth, newWorth));
	end
end

_M.IsGroupActor = function(guid)
	if guid == _M.playerGUID then
		return UNIT_TYPE_PLAYER;
	end

	local groupData = _M.groupData;
	return groupData and groupData[guid] or nil;
end

_M.Enable = function()
	_M.tracking = true;

	_M.Message("Monitoring enabled.");
end

_M.Disable = function()
	_M.tracking = false;
	wipe(_M.boardGroup);

	_M.Message("Monitoring disabled.");
end

_M.OnCommand = function(text, editbox)
	if _M.tracking then
		_M.Disable();
	else
		_M.Enable();
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
	_M.groupData = _M.currentPool and {} or nil;
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
		local slotPool;

		if IsInRaid() then
			slotPool = RAID_SLOTS;
		elseif IsInGroup() then
			slotPool = PARTY_SLOTS;
		end

		if slotPool then
			for i = 1, #slotPool do
				local unitID = slotPool[i];
				groupData[UnitGUID(unitID)] = unitID;
			end
		end
	end
end

_M.FailCheck_SelfCast = function(node, failType, ...)
	local _, sourceGUID, sourceName, _, _, _, _, _, _, _, spellName = ...;

	if _M.IsGroupActor(sourceGUID) then
		return sourceGUID, failType, sourceName, spellName;
	end

	return nil;
end

-- [[ Initial Set-up ]] --
_M.eventFrame:SetScript("OnEvent", _M.OnEvent);
_M.SetEventHandler("ADDON_LOADED", _M.OnEvent_AddonLoaded);

SLASH_SHAME1 = "/shame";
SlashCmdList["SHAME"] = _M.OnCommand;

-- [[ Data ]] --
FAIL_TYPES = {
	[FAIL_TYPE_TEST] = { message = "%s cast %s during a test", func = _M.FailCheck_SelfCast }
};

ENCOUNTER_DATA = {
	[1077] = {
		["SPELL_HEAL"] = {
			[18562] = { errorType = FAIL_TYPE_TEST, worth = 2 }
		}
	},
	[1041] = { -- Halls of Valor
		["SPELL_DAMAGE"] = {
			[198599] = { errorType = FAIL_CATCH_OTHER, worth = 2 }, -- Thunderstrike AoE damage.
		}
	}
};

-- Thunderstrike
-- 198605 is the direct damage from SPELL_AURA_REMOVED
-- 198599 is the aura that's removed from SPELL_DAMAGE