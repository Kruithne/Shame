do
	-- [[ Local Optimization ]] --
	local Shame = Shame;
	local type = type;
	local pairs = pairs;

	--[[
		Shame.OnEvent_AddonLoaded
		Invoked when the ADDON_LOADED event triggers.

			self - Reference to the addon container.
			addonName - Name of the addon which just loaded.
	]]--
	Shame.OnAddonLoaded = function(self, addonName)
		if addonName == self.ADDON_NAME then
			self:RemoveEventHandler("ADDON_LOADED");
			self:OnLoad();
		end
	end

	--[[
		Shame.OnEvent
		Invoked when a registered event occurred.
	]]--
	Shame.OnEvent = function(self, event, ...)
		local handler = Shame.eventHandlers[event];
		if handler then handler(Shame, ...); end
	end

	--[[
		Shame.SetEventHandler
		Register an event handler.

			self - Reference to the addon container.
			event - Identifer for the event.
			handler - Function to handle the callback.
	]]--
	Shame.SetEventHandler = function(self, event, handler)
		if type(event) == "table" then
			for key, value in pairs(event) do
				self:SetEventHandler(key, value);
			end
		else
			self.eventFrame:RegisterEvent(event);
			self.eventHandlers[event] = handler;
		end
	end

	--[[
		Shame.RemoveEventHandler
		Unregister an existing event handler.

			self - Reference to the addon container.
			event - Identifer for the event.
	]]--
	Shame.RemoveEventHandler = function(self, event)
		self.eventFrame:UnregisterEvent(event);
		self.eventHandlers[event] = nil;
	end

	Shame.eventHandlers = {}; -- Stores event handlers.
	Shame.eventFrame = CreateFrame("FRAME");
	Shame.eventFrame:SetScript("OnEvent", Shame.OnEvent);
	Shame:SetEventHandler("ADDON_LOADED", Shame.OnAddonLoaded);
end