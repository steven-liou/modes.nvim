local utils = require('modes.utils')
local statusbar_side_colors = {}
local statusbar_middle_colors = {}
local M = {}

M.define = function(config)
	statusbar_middle_colors =
		utils.define_lualine_colors(config, 'statusbar_middle_opacity')
	statusbar_side_colors =
		utils.define_lualine_colors(config, 'statusbar_side_opacity')
end

M.highlight = function(config, scene_event, scene_name)
	if not config.lualine.enabled then
		return
	end

	local colors = config.colors
	local lualine = config.lualine
	local fg_def =
		{ fg = colors.black_text, bg = colors[scene_name], gui = 'bold' }
	local bg_def =
		{ fg = colors.white_text, bg = statusbar_middle_colors[scene_name] }
	local statusbar_def =
		{ fg = colors[scene_event], bg = statusbar_side_colors[scene_name] }

	if
		scene_event == 'copy'
		or scene_event == 'delete'
		or scene_event == 'pending'
		or scene_event == 'char_replace'
		or scene_event == 'history'
	then
		scene_event = 'normal'
	end
	utils.set_hl(('lualine_a_%s'):format(scene_event), fg_def)
	utils.set_hl(('lualine_b_%s'):format(scene_event), statusbar_def)
	utils.set_hl(('lualine_c_%s'):format(scene_event), bg_def)
	utils.set_hl(('lualine_x_%s'):format(scene_event), statusbar_def)
	utils.set_hl(('lualine_y_%s'):format(scene_event), statusbar_def)

	local ft = utils.titlecase(vim.bo.filetype)
	local filetype_highlight_name = (
		'lualine_'
		.. lualine.filetype_component
		.. '_filetype_DevIcon%s_%s'
	):format(ft, scene_event)
	local ok, ft_colors =
		pcall(vim.api.nvim_get_hl_by_name, filetype_highlight_name, true)

	if ok and ft_colors.foreground then
		local fg_color = '#' .. string.format('%06x', ft_colors.foreground)
		utils.set_hl(filetype_highlight_name, {
			fg = fg_color,
			bg = statusbar_middle_colors[scene_name],
		})
	end

	utils.set_hl(
		'lualine_' .. lualine.diagnostics_component .. '_diagnostics_error',
		{ fg = colors.delete, bg = statusbar_middle_colors[scene_name] }
	)
	utils.set_hl(
		'lualine_' .. lualine.diagnostics_component .. '_diagnostics_warn',
		{ fg = colors.command, bg = statusbar_middle_colors[scene_name] }
	)
	utils.set_hl(
		'lualine_' .. lualine.diagnostics_component .. '_diagnostics_hint',
		{ fg = colors.pending, bg = statusbar_middle_colors[scene_name] }
	)
	utils.set_hl(
		'lualine_' .. lualine.diagnostics_component .. '_diagnostics_info',
		{ fg = colors.insert, bg = statusbar_middle_colors[scene_name] }
	)
	utils.set_hl(
		'lualine_' .. lualine.diff_component .. '_diff_added',
		{ fg = colors.pending, bg = statusbar_middle_colors[scene_name] }
	)
	utils.set_hl(
		'lualine_' .. lualine.diff_component .. '_diff_modified',
		{ fg = colors.command, bg = statusbar_middle_colors[scene_name] }
	)
	utils.set_hl(
		'lualine_' .. lualine.diff_component .. '_diff_removed',
		{ fg = colors.delete, bg = statusbar_middle_colors[scene_name] }
	)
end

return M
