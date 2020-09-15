--- Creates an easy to use object to handle Slack webhook messages.
-- @author CompilerError
-- @classmod SlackWebhook

local Http = require(script.HttpHandler);

local SlackWebhook = {};

--- Posts the message to slack.
function SlackWebhook:PostRaw(message)
  return Http.Post(
    self.webhook,
    message,
    nil,
    self.config.retries.max_retries
  );
end

-- Creates a new instance of a Slack webhook object.
-- @param webhook The webhook to communicate through.
function SlackWebhook.new(webhook, config)
	local self = setmetatable({}, { __index = SlackWebhook });

  self.webhook = webhook;
	self.config = config or {};
	self.config.retries = {
		max_retries = self.config.retries and self.config.retries.max_retries or 1;
	}

	return self;
end

return SlackWebhook;
