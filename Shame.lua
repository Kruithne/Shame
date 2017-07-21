--[[
	Shame (C) Kruithne <kruithne@gmail.com>
	Licensed under GNU General Public Licence version 3.
	
	https://github.com/Kruithne/Shame

	Shame.lua - Core of the addon.
]]--

do
	-- [[ Optimization ]] --
	local wipe = wipe;
	local type = type;
	local pairs = pairs;
	local select = select;
	local string_format = string.format;
	local string_sub = string.sub;
	local string_len = string.len;
	local SendChatMessage = SendChatMessage;
	local UnitIsPlayer = UnitIsPlayer;
	local GetInstanceInfo = GetInstanceInfo;

	-- [[ Initiate ]] --
	local Shame = {
		tracking = false, -- Flag for tracking state.
		boardGroup = {},
		instances = {},
		combatListeners = {},
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
			SendChatMessage(text, self.validChannels[channel]);
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
			["guild"] = "GUILD",
			["instance"] = "INSTANCE_CHAT",
			["officer"] = "OFFICER",
			["party"] = "PARTY",
			["raid"] = "RAID"
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

		-- Begin monitoring for map changes.
		self:SetEventHandler("ZONE_CHANGED_NEW_AREA", self.OnZoneChange);
		self:SetEventHandler("PLAYER_ENTERING_WORLD", self.OnZoneChange);

		-- Print loaded message.
		self:Message(self.L_LOADED:format(GetAddOnMetadata(self.ADDON_NAME, "Version")));
	end

	--[[
		Shame.OnCombatEvent
		Invoked when a combat log event occurs.

			self - Reference to the addon container.
			timestamp - Integer timestamp for when the event occurred.
			event - Identifier for the event.
			... - Event arguments.
	]]--
	Shame.OnCombatEvent = function(self, timestamp, event, ...)
		local listeners = self.combatListeners[event];
		if listeners then
			for i = 1, #listeners do
				local tracker = listeners[i];
				local func = tracker.func or Shame.CombatGeneric_SpellDamage;

				func(self, tracker, timestamp, event, ...);
			end
		end
	end

	--[[
		Shame.OnZoneChange
		Invoked when the player changes zone.

			self - Reference to the addon container.
	]]--
	Shame.OnZoneChange = function(self)
		local currentMapID = select(8, GetInstanceInfo());
		local instance = self.instances[currentMapID];
		local currentInstance = self.currentInstance;

		-- Disable the active tracking module if there is one.
		if currentInstance and currentInstance.zoneID ~= currentMapID then
			self:ResetCombatListeners(self.currentInstance);
		end

		-- Enable a new tracker module if needed.
		if instance then
			self:RegisterCombatNodes(instance);
			self.currentInstance = instance;
		end
	end

	--[[
		Shame.RegisterCombatNodes
		Register all combat nodes for a tracker.

			self - Reference to the addon container.
			data - Table containing tracker nodes.
	]]--
	Shame.RegisterCombatNodes = function(self, data)
		local trackers = data.trackers;
		for i = 1, #trackers do
			local tracker = trackers[i];

			if type(tracker) ~= "table" then
				tracker = { spellID = tracker };
				trackers[i] = tracker;
			end

			local event = tracker.event or self.COMBAT_SPELL_DAMAGE;
			local nodes = self.combatListeners[event];

			-- No listener table, create one.
			if not nodes then
				nodes = {};
				self.combatListeners[event] = nodes;
			end

			nodes[#nodes + 1] = tracker;
		end
	end

	--[[
		Shame.ResetCombatListeners
		Remove all existing combat listeners.

			self - Reference to the addon container.
	]]--
	Shame.ResetCombatListeners = function(self)
		self.combatListeners = {};
	end

	--[[
		Shame.RegisterMistake
		Register a player mistake.

			self - Reference to the addon container.
			actor - Name of the actor.
			damage - Avoidable damage this mistake cost.
			message - Message to display for this mistake.
			... - String formatting arguments.
	]]--
	Shame.RegisterMistake = function(self, actor, damage, message, ...)
		if not self.tracking then
			-- Prevent mistakes being registered outside a session.
			return;
		end

		if not UnitIsPlayer(actor) then
			-- Prevent non-players being flagged for mistakes.
			return;
		end

		local node = self.boardGroup[actor];
		if not node then
			node = { name = actor };
			self.boardGroup[actor] = node;
		end

		node.mistakes = (node.mistakes or 0) + 1;
		node.damage = (node.damage or 0) + (damage or 0);

		if self.currentMode == self.L_MODE_ALL or self.currentMode == self.L_MODE_SELF then
			local target = nil;
			if self.currentMode == self.L_MODE_ALL then
				target = self.modeChannel;
			end

			self:Message(message, target, ...);
		end
	end

	--[[
		Shame.RegisterInstance
		Register an instance module for tracking.

			self - Reference to the addon container.
			instance - Table containing tracking data.
	]]--
	Shame.RegisterInstance = function(self, instance)
		self.instances[instance.instanceID] = instance;
	end

	--[[
		Shame.Enable
		Enable the shaming.

			self - Reference to the addon container.
	]]--
	Shame.Enable = function(self)
		self.tracking = true;
		wipe(self.boardGroup); -- Reset the score board.

		-- Enable combat log monitoring.
		self:SetEventHandler("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatEvent);
	end

	--[[
		Shame.Disable
		Disable the shaming.

			self - Reference to the addon container.
	]]--
	Shame.Disable = function(self)
		self.tracking = false;

		-- Disable combat log monitoring.
		self:RemoveEventHandler("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatEvent);
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