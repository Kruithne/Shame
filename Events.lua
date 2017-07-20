do
	-- [[ Local Optimization ]] --
	local _S = Shame;
	local type = type;
	local pairs = pairs;

	--[[
		Shame.OnEvent_AddonLoaded
		Invoked when the ADDON_LOADED event triggers.
	]]--
	_S.OnAddonLoaded = function(addonName)
		if addonName == _S.ADDON_NAME then
			_S.RemoveEventHandler("ADDON_LOADED");
			_S.OnLoad();
		end
	end

	--[[
		Shame.OnEvent
		Invoked when a registered event occurred.
	]]--
	_S.OnEvent = function(self, event, ...)
		local handler = _S.eventHandlers[event];
		if handler then handler(...); end
	end

	--[[
		Shame.SetEventHandler
		Register an event handler.

			event - Identifer for the event.
			handler - Function to handle the callback.
	]]--
	_S.SetEventHandler = function(event, handler)
		if type(event) == "table" then
			for key, value in pairs(event) do
				_S.SetEventHandler(key, value);
			end
		else
			_S.eventFrame:RegisterEvent(event);
			_S.eventHandlers[event] = handler;
		end
	end

	--[[
		Shame.RemoveEventHandler
		Unregister an existing event handler.

			event - Identifer for the event.
	]]--
	_S.RemoveEventHandler = function(event)
		_S.eventFrame:UnregisterEvent(event);
		_S.eventHandlers[event] = nil;
	end

	_S.eventHandlers = {}; -- Stores event handlers.
	_S.eventFrame = CreateFrame("FRAME");
	_S.eventFrame:SetScript("OnEvent", _S.OnEvent);
	_S.SetEventHandler("ADDON_LOADED", _S.OnAddonLoaded);
end