--- Roblox throws a lot of errors that don't provide us any value.
-- Any useless errors should be added to this file.
--
-- NOTE: These are treated as pattern strings,
-- any special characters must be properly escaped.
-- See https://www.lua.org/pil/20.2.html for details on Lua patterns.

return {
	'Failed to load sound rbxassetid://%d+: Unable to download sound data',
	'Failed to load sound http://www.roblox.com/asset/?id=%d+: Unable to download sound data',
	'Animation "rbxassetid://%d+" failed to load in ".*": Animation failed to load',
	'Animation "http://www.roblox.com/asset/?id=%d+" failed to load in ".*": Animation failed to load',
	'The current identity %(2%) cannot Class security check %(lacking permission %d+%)',
	'not enough memory',
	'console:.+',
	'Error while processing packet.',
	'loadChatInfoInternal had an error:.*',
	'Error fetching MarketplaceService receipts:.*',
	'Player:GetRoleInGroup failed because.*',
	'MarketPlace::.*',
	'MarketplaceService:getProductInfo%(%) failed because HTTP .*',
	'Invalid value for enum KeyCode',
	'HTTP unknown error.*',
	'HTTP %d+ .+',
	'HttpError: .+',
	'CorePackages%.Packages%.+',
	'Players:CreateHumanoidModelFromUserId%(%) failed because HTTP .+',
	'GroupService:GetGroupInfoAsync%(%) failed because HTTP .+',
	'Player:GetRankInGroup failed because HTTP .+',
	'Players%..*%.ControlModule%.ClickToMoveDisplay',
	'cannot resume non%-suspended coroutine'
}
