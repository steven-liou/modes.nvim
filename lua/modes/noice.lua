local utils = require('modes.utils')
local M = {}

local noice_background_groups = {}

local noice_foreground_groups = {
	'NoiceCmdlinePopupBorder',
	'NoiceCmdlinePopupBorderSearch',
	'NoiceCmdlinePopup',
	'NoiceCmdlineIconCmdline',
	'NoiceCmdlineIconSearch',
}

M.highlight = function(config, scene_name)
	if not (config.noice and config.noice.enabled) then
		return
	end

	if not (scene_name == 'command' or scene_name == 'search') then
		return
	end

	local colors = config.colors

	utils.highlight_foreground_groups(
		scene_name,
		noice_foreground_groups,
		colors
	)

	utils.set_hl('NoiceCursor', { link = 'ModesCommandCursor' })
end

return M
