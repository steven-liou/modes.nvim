local utils = require('modes.utils')
local colors_opacity = {}
local M = {}

local bufferline_foreground_groups = {
	'BufferLineBufferSelected',
	'BufferLineNumbersSelected',
	'BufferLineSeparatorSelected',
	'BufferLineTabSeparatorSelected',
	'BufferLineCloseButtonSelected',
	'BufferLinePickSelected',
	'BufferLineIndicatorSelected',
	'BufferLineModifiedSelected',
}

M.define = function(config)
	if not (config.bufferline and config.bufferline.enabled) then
		return
	end
	colors_opacity =
		utils.define_component_opacity(config, 'bufferline', 'opacity')
end

local function set_devicon_component_highlight(scene_name)
	local icon_name = utils.get_current_file_devicon_name()
	local filetype_highlight_name = ('BufferLine%sSelected'):format(icon_name)

	local icon_color =
		utils.get_highlight_colors_by_name(filetype_highlight_name)

	if icon_color then
		utils.set_hl(filetype_highlight_name, {
			fg = icon_color.foreground,
			bg = colors_opacity[scene_name],
		})
	end
end

M.highlight = function(config, scene_name)
	if not (config.bufferline and config.bufferline.enabled) then
		return
	end

	local colors = config.colors

	utils.highlight_foreground_groups(
		scene_name,
		bufferline_foreground_groups,
		colors,
		colors_opacity
	)

	set_devicon_component_highlight(scene_name)

	if type(config.bufferline.fill_background) then
		utils.set_hl(
			'BufferLineFill',
			{ bg = config.bufferline.fill_background }
		)
	end
end

return M
