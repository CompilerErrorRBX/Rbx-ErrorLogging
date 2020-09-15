--- Custom event implementation.
-- @classmod Event

local Event = {};

function Event:Dispatch(...)
	self._arguments = { ... };
	self._arg_count = select('#', ...);
	self._bindable_event:Fire();
end

function Event:Connect(action)
	return self._bindable_event.Event:Connect(function()
		action(unpack(self._arguments, 1, self._arg_count));
	end);
end

function Event:Wait()
	self._bindable_event.Event:Wait();
	return unpack(self._arguments, 1, self._arg_count);
end

function Event:Destroy()
  if (self._bindable_event) then
    self._bindable_event:Destroy();
    self._bindable_event = nil;
  end

  self._arg_count = nil;
  self._arguments = nil;

  setmetatable(self, nil);
end

function Event.new()
  local self = setmetatable({}, { __index = Event });

	self._bindable_event = Instance.new('BindableEvent');

	return self;
end

return Event;
