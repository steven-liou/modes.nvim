local utils = require('modes.utils')
local statusbar_side_colors = {}
local statusbar_middle_colors = {}
local M = {}

M.define = function(config)
	if not (config.lualine and config.lualine.enabled) then
		return
	end

	statusbar_middle_colors = utils.define_component_opacity(
		config,
		'lualine',
		'statusbar_middle_opacity'
	)
	statusbar_side_colors = utils.define_component_opacity(
		config,
		'lualine',
		'statusbar_side_opacity'
	)
end

local function set_filetype_component_highlight(
	lualine,
	scene_event,
	scene_name
)
	local icon_name = utils.get_current_file_devicon_name()
	local filetype_highlight_name = ('lualine_%s_filetype_%s_%s'):format(
		lualine.filetype_component,
		icon_name,
		scene_event
	)
	local icon_color =
		utils.get_highlight_colors_by_name(filetype_highlight_name)

	if icon_color then
		utils.set_hl(filetype_highlight_name, {
			fg = icon_color.foreground,
			bg = statusbar_side_colors[scene_name],
		})
	end
end

local function set_diagnostics_component_highlight(lualine, colors, scene_name)
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

M.highlight = function(config, scene_event, scene_name)
	if not (config.lualine and config.lualine.enabled) then
		return
	end

	local colors = config.colors
	local lualine = config.lualine
	local fg_def =
		{ fg = colors.black_text, bg = colors[scene_name], gui = 'bold' }
	local bg_def =
		{ fg = colors.white_text, bg = statusbar_middle_colors[scene_name] }
	local statusbar_def =
		{ fg = colors[scene_name], bg = statusbar_side_colors[scene_name] }
	utils.set_hl(('lualine_a_%s'):format(scene_event), fg_def)
	utils.set_hl(
		('lualine_transitional_lualine_a_%s_to_lualine_b_%s'):format(
			scene_event,
			scene_event
		),
		statusbar_def
	)
	utils.set_hl(
		('lualine_transitional_lualine_a_%s_to_lualine_y_%s'):format(
			scene_event,
			scene_event
		),
		statusbar_def
	)
	utils.set_hl(('lualine_b_%s'):format(scene_event), statusbar_def)
	utils.set_hl(('lualine_c_%s'):format(scene_event), bg_def)
	utils.set_hl(('lualine_x_%s'):format(scene_event), bg_def)
	utils.set_hl(('lualine_y_%s'):format(scene_event), statusbar_def)

	set_filetype_component_highlight(lualine, scene_event, scene_name)
	set_diagnostics_component_highlight(lualine, colors, scene_name)
end

return M
