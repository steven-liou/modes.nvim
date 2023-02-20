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
	if not config.gitsigns.enabled then
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

	-- for _, name in ipairs(gitsigns_background_groups) do
	-- 	local highlight_colors = utils.get_highlight_colors_by_name(name)
	-- 	if highlight_colors then
	-- 		local fg_def = {
	-- 			fg = highlight_colors.foreground,
	-- 			bg = color_opacity[scene_name],
	-- 			gui = 'bold',
	-- 		}
	-- 		utils.set_hl(name, fg_def)
	-- 	end
	-- end
	utils.highlight_foreground_groups(
		scene_name,
		gitsigns_foreground_groups,
		colors,
		colors_opacity
	)

	-- for _, name in ipairs(gitsigns_foreground_groups) do
	-- 	local highlight_colors = utils.get_highlight_colors_by_name(name)
	-- 	if highlight_colors then
	-- 		local fg_def = {
	-- 			fg = colors[scene_name],
	-- 			bg = colors_opacity[scene_name],
	-- 			gui = 'bold',
	-- 		}
	-- 		utils.set_hl(name, fg_def)
	-- 	end
	-- end
end

return M
