-- Log levels are as follows:
-- Enum.MessageType.MessageOutput: 0,
-- Enum.MessageType.MessageInfo: 1,
-- Enum.MessageType.MessageWarning: 2,
-- Enum.MessageType.MessageError: 3

return {
  LoggingEnabled = not game:GetService('RunService'):IsStudio(),
  LogInterval = 1 * 60, -- The number of seconds a log should be held before being sent.

  ReportOnGameClose = true, -- Whether to send all pending logs when the server stops.

  MinimumOccurrences = 1, -- The minimum number of times a log trace must occur for it to be reported.
  MinimumLogLevel = Enum.MessageType.MessageError, -- Minimum log level to report.
  RepeatLogs = false, -- Whether a previously sent recorded error log should ever be sent again.
  MaximumLogRepeats = 5, -- The number of times a particular log can be sent before it is suppressed.
  -- This is ignored if RepeatLogs is false.
  StripPlayerNames = true, -- Whether names should be removed to help reduce duplicate error messages
  -- coming from different users. NOTE: UserIds and Names are attached to each report where applicable.

  Report = {
    GameLink = '',
    Slack = {
      Webhook = 'https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX',
    },
    Settings = {
      Colors = {
        [Enum.MessageType.MessageError] = '#F44336',
        [Enum.MessageType.MessageWarning] = '#FF9800',
        [Enum.MessageType.MessageInfo] = '#4CAF50',
        [Enum.MessageType.MessageOutput] = '#00BCD4',
      }
    }
  },
}