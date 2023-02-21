local utils = require('modes.utils')
local colors_opacity = {}
local M = {}

local gitsigns_background_groups = {
	'GitSignsAdd',
	'GitSignsChange',
	'GitSignsDelete',
	'GitSignsCurrentLineBlame',
}

local gitsigns_foreground_groups = {
	'GitSignsAddNr',
	'GitSignsChangeNr',
	'GitSignsDeleteNr',
	'GitSignsUntracked',
}

M.define = function(config)
	if not (config.gitsigns and config.gitsigns.enabled) then
		return
	end
	colors_opacity =
		utils.define_component_opacity(config, 'gitsigns', 'opacity')
end

M.highlight = function(config, scene_name)
	if not (config.gitsigns and config.gitsigns.enabled) then
		return
	end

	local colors = config.colors

	utils.highlight_background_groups(
		scene_name,
		gitsigns_background_groups,
		colors_opacity
	)

	utils.highlight_foreground_groups(
		scene_name,
		gitsigns_foreground_groups,
		colors,
		colors_opacity
	)
end

return M
