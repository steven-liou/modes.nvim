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
	local ft = vim.bo.filetype

	ft = utils.titlecase(ft)
	local filetype_highlight_name = ('BufferLineDevIcon%sSelected'):format(ft)

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

	for _, name in ipairs(bufferline_foreground_groups) do
		local highlight_colors = utils.get_highlight_colors_by_name(name)
		if highlight_colors then
			local fg_def = {
				fg = colors[scene_name],
				bg = colors_opacity[scene_name],
				gui = 'bold',
			}
			utils.set_hl(name, fg_def)
		end
	end

	set_devicon_component_highlight(scene_name)

	if type(config.bufferline.fill_background) then
		utils.set_hl(
			'BufferLineFill',
			{ bg = config.bufferline.fill_background }
		)
	end
end

return M
