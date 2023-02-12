local utils = require('modes.utils')
local devicons = require('nvim-web-devicons')
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

M.highlight = function(config, scene_name)
	if not config.bufferline.enabled then
		return
	end

	local colors = config.colors

	for _, name in ipairs(bufferline_foreground_groups) do
		local ok, highlight_colors = utils.get_highlight_colors_by_name(name)
		if ok then
			local fg_def = {
				fg = colors[scene_name],
				bg = highlight_colors.background,
				gui = 'bold',
			}
			utils.set_hl(name, fg_def)
		end
	end
end

return M
