local utils = require('modes.utils')
local statusbar_middle_colors = {}
local lsp_kinds = require('modes.lsp_kinds')
local M = {}

M.define = function(config)
	statusbar_middle_colors = utils.define_component_opacity(
		config,
		'lualine',
		'statusbar_middle_opacity'
	)
end

M.highlight = function(config, scene_event, scene_name)
	if
		not config.lualine.enabled
		and type(config.lualine.aerial_component) ~= 'string'
	then
		return
	end

	local colors = config.colors
	local lualine = config.lualine
	local fg_def =
		{ fg = colors.black_text, bg = colors[scene_name], gui = 'bold' }
	local bg_def =
		{ fg = colors.white_text, bg = statusbar_middle_colors[scene_name] }

	if
		scene_event == 'copy'
		or scene_event == 'delete'
		or scene_event == 'pending'
		or scene_event == 'char_replace'
		or scene_event == 'undo'
		or scene_event == 'redo'
		or scene_event == 'change'
	then
		scene_event = 'normal'
	end

	-- "lualine_c_aerial_Key_insert"
	for _, kind in ipairs(lsp_kinds) do
		local aerial_kind_highlight_name = ('lualine_%s_aerial_%s_%s'):format(
			config.lualine.aerial_component,
			kind,
			scene_event
		)
		local ok, aerial_kind_colors =
			pcall(vim.api.nvim_get_hl_by_name, aerial_kind_highlight_name, true)

		if ok and aerial_kind_colors.foreground then
			local fg_color = '#'
				.. string.format('%06x', aerial_kind_colors.foreground)
			utils.set_hl(aerial_kind_highlight_name, {
				fg = fg_color,
				bg = statusbar_middle_colors[scene_name],
			})
		end

		local aerial_kind_icon_highlight_name = ('lualine_%s_aerial_%sIcon_%s'):format(
			config.lualine.aerial_component,
			kind,
			scene_event
		)
		local ok, aerial_kind_icon_colors = pcall(
			vim.api.nvim_get_hl_by_name,
			aerial_kind_icon_highlight_name,
			true
		)

		if ok and aerial_kind_icon_colors.foreground then
			local fg_color = '#'
				.. string.format('%06x', aerial_kind_icon_colors.foreground)
			utils.set_hl(aerial_kind_icon_highlight_name, {
				fg = fg_color,
				bg = statusbar_middle_colors[scene_name],
			})
		end
	end
end

return M
