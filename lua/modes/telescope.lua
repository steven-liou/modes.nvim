local utils = require('modes.utils')
local colors_opacity = {}
local M = {}

local telescope_background_groups = {
	'TelescopeSelection',
	'TelescopeMultiSelection',
}

local telescope_foreground_groups = {
	'TelescopeTitle',
	'TelescopePromptPrefix',
	'TelescopePromptCounter',
}

M.define = function(config)
	if not (config.telescope and config.telescope.enabled) then
		return
	end

	colors_opacity =
		utils.define_component_opacity(config, 'telescope', 'opacity')
end

M.highlight = function(config, scene_name)
	if not (config.telescope and config.telescope.enabled) then
		return
	end

	local colors = config.colors

	utils.highlight_background_groups(
		scene_name,
		telescope_background_groups,
		colors_opacity
	)

	utils.highlight_foreground_groups(
		scene_name,
		telescope_foreground_groups,
		colors
	)
end

return M
