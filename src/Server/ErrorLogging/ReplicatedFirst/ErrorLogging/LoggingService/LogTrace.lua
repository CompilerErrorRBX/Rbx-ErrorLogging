--- Tracks logs as they occur across a given time interval.
-- @author CompilerError
-- @classmod LogTrace

local Event = require(script.Parent.Parent.Helper.Event);

local LogTrace = {};

--- Reports this log trace and alerts any log trace listeners.
-- @return The log trace output for this log trace.
function LogTrace:Report()
  local scrpt_name = nil;

  pcall(function()
    if (self.Script) then
      scrpt_name = tostring(self.Script);
    end
  end);

  local output = {
    Message = self.Message,
    Type = self.Type,
    Occurrences = self.Occurrences,
    CustomFields = self.CustomFields,
    FirstOccurrence = self.FirstOccurrence,
    LastOccurrence = self.LastOccurrence,
    Script = scrpt_name,
  }

  self.OnReport:Dispatch(output);

  self:Destroy();

  return output;
end

--- Applies the log trace reoccurrence to this log trace.
function LogTrace:Reoccurrence()
  self.Occurrences = self.Occurrences + 1;
  self.LastOccurrence = os.time();
end

--- Cleans up any memory used by this log trace.
function LogTrace:Destroy()
  self.OnReport:Destroy();
  setmetatable(self, nil);
end

--- Creates a new LogTrace instance.
-- Tracks the occurrances of a particular error throughout it's lifecycle.
-- @param message The error message.
-- @param message_type The Enum.MessageType of the message.
-- @param interval The interval over which this log trace exists before reporting.
-- @param skript[opt] The script that the log originated from.
-- @param custom_fields Any custom fields to be displayed on the report.
-- @field Message The error message of this log trace.
-- @field Type The Enum.MessageType type of this log trace.
-- @field Interval The number of seconds this log trace will track logs before reporting itself.
-- @field Script The script that this log trace originated from.
-- @field Occurrences The number of times during the given interval that this log trace has occurred.
-- @field CustomFields A list of custom fields to display on the log trace report.
-- @field FirstOccurrence The UTC timestamp that the log trace first occurred at.
-- @field LastOccurrence The UTC timestamp that the log trace last occurred at.
-- @field OnReport Fired when the log trace is reported.
-- @return The newly created log trace.
function LogTrace.new(message, message_type, interval, skript, custom_fields)
  local self = setmetatable({}, { __index = LogTrace });

  self.Message = message;
  self.Type = message_type;
  self.Interval = interval;
  self.Script = skript;
  self.Occurrences = 1;
  self.CustomFields = custom_fields or {};

  self.FirstOccurrence = os.time();
  self.LastOccurrence = os.time();

  self.OnReport = Event.new();

  delay(self.Interval, function()
    self:Report();
  end);

  return self;
end

return LogTrace;
