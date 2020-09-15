<div align="center">
	<a href="https://github.com/Stephen-Martin/Rbx-ErrorLogging/actions">
		<img src="https://github.com/Stephen-Martin/Rbx-ErrorLogging/workflows/luacheck/badge.svg" alt="Actions Status" />
	</a>
</div>


## About
Provides external error logging from the client and server to a Slack webhook.

## Usage
1. Get started by opening this repo and having Rojo installed.
1. Open the [config file](src/ErrorLogging/Config/Config.lua)
    * Set your [Slack webhook](https://api.slack.com/messaging/webhooks#getting_started) under the Report section in the config.
    * Set the GameLink to a link to your game (this is used as a reference on the Slack message).

## Local testing
In order to see error output in Lua you'll need to go into the [config file](src/ErrorLogging/Config/Config.lua) and modify the LoggingEnabled setting. By default it is set to `not game:GetService('RunService'):IsStudio()` which prevents the error logging from running in Studio. Replace this with `true`.
