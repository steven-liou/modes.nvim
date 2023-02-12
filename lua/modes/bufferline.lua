local utils = require('modes.utils')
local devicons = require('nvim-web-devicons')
local color_opacity = {}
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
	color_opacity =
		utils.define_component_opacity(config, 'bufferline', 'opacity')
end

local function set_devicon_component_highlight(scene_name)
	local ft = vim.bo.filetype

	ft = utils.titlecase(ft)
	local filetype_highlight_name = ('BufferLineDevIcon%sSelected'):format(ft)
	local _, icon_color =
		devicons.get_icon_color(vim.fn.expand('%:t'), vim.bo.filetype)
	utils.set_hl(filetype_highlight_name, {
		fg = icon_color,
		bg = color_opacity[scene_name],
	})
end

M.highlight = function(config, scene_name)
	if not config.bufferline.enabled then
		return
	end

	local colors = config.colors

	for _, name in ipairs(bufferline_foreground_groups) do
		local ok, highlight_colors = utils.get_highlight_colors_by_name(name)
		local bg_color = highlight_colors.background
			or config.bufferline.background_color

		if ok then
			local fg_def = {
				fg = colors[scene_name],
				bg = color_opacity[scene_name],
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
