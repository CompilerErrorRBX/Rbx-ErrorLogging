--- Tracks logs throughout the game.
-- Creates log trace reports which can be used to track errors, warnings
-- and other logs throughout your place.
--
-- @author CompilerError
-- @classmod LoggingService

local RunService = game:GetService('RunService');
local LogService = game:GetService('LogService');
local ScriptContext = game:GetService('ScriptContext');

local Event = require(script.Parent.Helper.Event);
local Log = require(script.LogTrace);

local LoggingService = {};

local message_blacklist = require(script.Parent.ErrorBlacklist);

--- Creates a new log trace to track this log.
-- Handles the creation, tracking, and reporting of this log.
-- @param message The log message associated with the log.
-- @param message_type The Enum.MessageType of the log.
-- @param skript[opt] The Script from which the log originated.
-- @return The newly created log trace.
function LoggingService:AddLog(message, message_type, skript, custom_fields)
  local log = self.Logs[message];
  if (log) then
    log:Reoccurrence();
  else
    log = Log.new(message, message_type, self.Config and self.Config.LogInterval or 0, skript, custom_fields);

    self.Logs[message] = log;

    local log_listener = nil;
    log_listener = log.OnReport:Connect(function(log_message)
      log_listener:Disconnect();
      self.Logs[message] = nil;
      self.OnLogReport:Dispatch(log_message, log);
    end);

    self.OnLogOpen:Dispatch(log);
  end

  return log;
end

--- Filters out any messages that are in the blacklist.
-- @return Whether the message passed the filter or not.
function LoggingService:FilterMessage(message)
  for _, blacklist_message in pairs(message_blacklist) do
		if (message:match(blacklist_message) == message) then
			return false;
		end
  end

  return true;
end

--- Initializes the logging service listeners for client and server.
function LoggingService:Listen()
  if (RunService:IsServer()) then
    LogService.MessageOut:Connect(function(message, message_type)
      if (not self:FilterMessage(message)) then
        return;
      end

      if (message_type.Value >= self.Config.MinimumLogLevel.Value) then
        self:AddLog(message, message_type);
      end
    end);
  elseif (RunService:IsClient()) then
    ScriptContext.Error:Connect(function(message, stack_trace, scrpt)
      if (not self:FilterMessage(message)) then
        return;
      end

      local err_message = message ..'\n\tStack Begin';

      local lines = stack_trace:split('\n')
      for i = 1, #lines do
        local line = lines[i];
        if (#line > 0) then
          err_message = err_message .. '\n\tScript \'' ..line;
        end
      end
      err_message = err_message:gsub(', ', '\', ').. '\n\tStack End';

      self:AddLog(err_message, Enum.MessageType.MessageError, scrpt);
    end);
  end
end

--- Creates a new instance of the LoggingService.
-- Manages the log traces throughout your place.
-- @param config The configuration file associated with this LoggingService.
-- @field Logs The current pending log traces.
-- @field Config The passed in configuration.
-- @field OnLogOpen Fired when a new log trace is created.
-- @field OnLogReport Fired when a log trace is reported.
-- @return The newly created instance of the LoggingService.
function LoggingService.new(config)
  local self = setmetatable({}, { __index = LoggingService });

  self.Logs = {};
  self.Config = config;

  self.OnLogOpen = Event.new();
  self.OnLogReport = Event.new();

  _G.LoggingService = self;

  self:Listen();

  return self;
end

return LoggingService;
