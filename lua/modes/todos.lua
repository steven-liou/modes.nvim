local utils = require('modes.utils')
local colors_opacity = {}
local M = {}

local todos_types = {
	'FIX',
	'HACK',
	'NOTE',
	'PERF',
	'TEST',
	'TODO',
	'WARN',
}

M.define = function(config)
	if not (config.todos_comment and config.todos_comment.enabled) then
		return
	end
	colors_opacity =
		utils.define_component_opacity(config, 'todos_comment', 'opacity')
	if config.todos_comment.comment_types ~= nil then
		todos_types = config.todos_comment.comment_types
	end
end

M.highlight = function(config, scene_name)
	if not (config.todos_comment and config.todos_comment.enabled) then
		return
	end

	local colors = config.colors

	for _, type in ipairs(todos_types) do
		local sign_highlight = ('TodoSign%s'):format(type)
		local highlight_colors =
			utils.get_highlight_colors_by_name(sign_highlight)

		if highlight_colors then
			local fg_def = {
				fg = highlight_colors.foreground,
				bg = colors_opacity[scene_name],
				gui = 'bold',
			}
			utils.set_hl(sign_highlight, fg_def)
		end
	end
end

return M
