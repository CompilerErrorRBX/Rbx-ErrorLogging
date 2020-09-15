--- Handles logging throughout the place and reports log traces to Slack.
-- @author CompilerError

local AssetService = game:GetService('MarketplaceService');
local ReplicatedStorage = game:GetService('ReplicatedStorage');
local ReplicatedFirst = game:GetService('ReplicatedFirst');
local ServerScriptService = game:GetService('ServerScriptService');

local game_name = tostring(AssetService:GetProductInfo(game.PlaceId).Name);

local logger = script.Parent.ReplicatedFirst.ErrorLogging;

local Config = require(script.Parent.Config.Config);

if (Config.LoggingEnabled) then
  local LogSocket = Instance.new('RemoteEvent');
  LogSocket.Name = 'LoggingSocket';
  LogSocket.Parent = ReplicatedStorage;

  script.Parent.Config.ErrorBlacklist.Parent = logger;

  local LoggingService = require(logger.LoggingService);
  local SlackWebhook = require(ServerScriptService.SlackWebhook);
  local Template = require(script.Parent.Config.ReportTemplate);

  logger.Parent = ReplicatedFirst;

  local slack_reporter = SlackWebhook.new(Config.Report.Slack.Webhook);
  local logging_service = LoggingService.new(Config);

  local logged = {};

  local function parse_exception(message)
    local scripts = {};

    local lines = message:split('\n');
    local exception = lines[1];

    for i = 1, #lines do
      if (lines[i] ~= 'Stack Begin' and lines[i] ~= 'Stack End') then
        local line_num = lines[1]:find(':%d*:');
        if (i == 1 and line_num and line_num > -1) then
          local location = lines[i]:gsub(':.+', '');
          table.insert(scripts, location)
        end
        if (i ~= 1) then
          -- We don't want to ever log any errors around this.
          local success, result = pcall(function()
            local location = lines[i]:match('Script \'.+');
            if (location) then
              location = location:gsub("Script '", '');
              location = location:gsub("\'.+", '');
            end

            table.insert(scripts, location);
          end);

          if (not success) then
            warn(result);
          end
        end
      end
    end

    return scripts, exception;
  end

  local function filter_report(message, scripts, player)
    for _, scrpt in pairs(scripts) do
      local legal_pattern = '^(%w+%p*%.*)(.*)(%.%w+.*%w+)$';
      local files = scrpt:match(legal_pattern);
      if ((not files or #scrpt == 0) and player) then
        return true;
      end
    end

    if (player and #scripts == 0 and (not message.script or message.script == 'nil')) then
      return true;
    end

    return false;
  end

  local function report_log(trace, player)
    if (Config.MinimumOccurrences and trace.Occurrences < Config.MinimumOccurrences) then
      return;
    end

    local labels = '`Occurrences: ' ..trace.Occurrences.. '`';

    if (player) then
      local scripts = parse_exception(trace.Message);

      if (filter_report(trace, scripts, player)) then
        return;
      end

      labels = labels.. ' `Player.Name: ' ..player.Name.. '`';
      labels = labels.. ' `Player.UserId: ' ..player.UserId.. '`';
      if (Config.StripPlayerNames) then
        trace.Message = trace.Message:gsub(player.name, '<Player>')
      end

      trace.CustomFields.Player = nil;
    end

    for key, value in pairs(trace.CustomFields) do
      labels = labels.. ' `' ..tostring(key).. ': ' ..tostring(value).. '`';
    end

    if (logged[trace.Message]) then
      if (not Config.RepeatLogs or (Config.MaximumLogRepeats and logged[trace.Message] > Config.MaximumLogRepeats)) then
        logged[trace.Message] = logged[trace.Message] + 1;
        return;
      end
    end

    local report = Template;
    report = report:gsub('<COLOR>', Config.Report.Settings.Colors[trace.Type] or '#F44336');
    report = report:gsub('<GAMENAME>', game_name);
    report = report:gsub('<GAMELINK>', Config.Report.GameLink);
    report = report:gsub('<ERRORMESSAGE>', trace.Message);
    report = report:gsub('<LABELS>', labels);
    report = report:gsub('<TIMESTAMP>', os.time());
    report = report:gsub('<FOOTER>', 'GameId: ' ..game.GameId.. '; PlaceId: ' ..game.PlaceId.. '; Version ' ..game.PlaceVersion);

    slack_reporter:PostRaw([[{
      "attachments": [
        ]] ..report.. [[
      ]
    }]]);

    logged[trace.Message] = 1;
  end

  local function validate_client_log(log_trace)
    return type(log_trace) == 'table' and log_trace.Message and log_trace.Type and log_trace.Occurrences;
  end

  --- Capture and report any logs which occurred on a client.
  LogSocket.OnServerEvent:Connect(function(player, trace)
    if (validate_client_log(trace)) then
      logging_service:AddLog(trace.Message, trace.Type, trace.Script, { Player = player, ClientError = true });
    end
  end);

  --- Capture and report any logs which occurred on the server.
  logging_service.OnLogReport:Connect(function(trace)
    report_log(trace, trace.CustomFields.Player);
  end);

  --- Report any existing logs before the game closes.
  if (Config.ReportOnGameClose) then
    game.Close:Connect(function()
      for _, log in pairs(logging_service.Logs) do
        log:Report();
      end
    end);
  end
else
  script.Parent:Destroy();
end
