--- Tracks error logs on the client.
-- @author CompilerError

local ReplicatedStorage = game:GetService('ReplicatedStorage');

local ErrorLogging = script.Parent;
local LogSocket = ReplicatedStorage:WaitForChild('LoggingSocket');

local LoggingService = require(ErrorLogging.LoggingService);
local logger = LoggingService.new();

logger.OnLogReport:Connect(function(message)
  LogSocket:FireServer(message);
end);
