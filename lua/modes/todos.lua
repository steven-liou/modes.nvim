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

local todos_highlight_groups = {}

M.define = function(config)
	if not (config.todos_comment and config.todos_comment.enabled) then
		return
	end
	colors_opacity =
		utils.define_component_opacity(config, 'todos_comment', 'opacity')
	if config.todos_comment.comment_types ~= nil then
		todos_types = config.todos_comment.comment_types
	end

	for _, type in ipairs(todos_types) do
		local sign_highlight = ('TodoSign%s'):format(type)
		table.insert(todos_highlight_groups, sign_highlight)
	end
end

M.highlight = function(config, scene_name)
	if not (config.todos_comment and config.todos_comment.enabled) then
		return
	end

	local colors = config.colors
	utils.highlight_background_groups(
		scene_name,
		todos_highlight_groups,
		colors_opacity
	)
end

return M
