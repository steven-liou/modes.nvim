local utils = require('modes.utils')
local lualine = require('modes.lualine')
local aerial = require('modes.aerial')
local bufferline = require('modes.bufferline')
local reset_delay = 500
local reset_timer = nil
local in_change_mode = false

local M = {}
local config = {}
local default_config = {
	colors = {},
	cursorline = {
		enabled = true,
		opacity = {
			normal = 0.15,
			copy = 0.15,
			delete = 0.15,
			insert = 0.15,
			visual = 0.15,
			operator = 0.15,
			command = 0.15,
			replace = 0.15,
		},
	},
	set_cursor = true,
	set_number = true,
	ignore_filetypes = { 'NvimTree', 'TelescopePrompt' },
}
local winhighlight = {
	normal = {
		CursorLine = 'ModesNormalCursorLine',
		CursorLineNr = 'ModesNormalCursorLineNr',
		CursorLineSign = 'ModesNormalCursorLineSign',
		CursorLineFold = 'ModesNormalCursorLineFold',
	},
	copy = {
		CursorLine = 'ModesCopyCursorLine',
		CursorLineNr = 'ModesCopyCursorLineNr',
		CursorLineSign = 'ModesCopyCursorLineSign',
		CursorLineFold = 'ModesCopyCursorLineFold',
	},
	insert = {
		CursorLine = 'ModesInsertCursorLine',
		CursorLineNr = 'ModesInsertCursorLineNr',
		CursorLineSign = 'ModesInsertCursorLineSign',
		CursorLineFold = 'ModesInsertCursorLineFold',
	},
	delete = {
		CursorLine = 'ModesDeleteCursorLine',
		CursorLineNr = 'ModesDeleteCursorLineNr',
		CursorLineSign = 'ModesDeleteCursorLineSign',
		CursorLineFold = 'ModesDeleteCursorLineFold',
	},
	visual = {
		CursorLine = 'ModesVisualCursorLine',
		CursorLineNr = 'ModesVisualCursorLineNr',
		CursorLineSign = 'ModesVisualCursorLineSign',
		CursorLineFold = 'ModesVisualCursorLineFold',
		Visual = 'ModesVisualVisual',
	},
	command = {
		CursorLine = 'ModesCommandCursorLine',
		CursorLineNr = 'ModesCommandCursorLineNr',
		CursorLineSign = 'ModesCommandCursorLineSign',
		CursorLineFold = 'ModesCommandCursorLineFold',
	},
	replace = {
		CursorLine = 'ModesReplaceCursorLine',
		CursorLineNr = 'ModesReplaceCursorLineNr',
		CursorLineSign = 'ModesReplaceCursorLineSign',
		CursorLineFold = 'ModesReplaceCursorLineFold',
	},
	pending = {
		CursorLine = 'ModesPendingCursorLine',
		CursorLineNr = 'ModesPendingCursorLineNr',
		CursorLineSign = 'ModesPendingCursorLineSign',
		CursorLineFold = 'ModesPendingCursorLineFold',
	},
	undo = {
		CursorLine = 'ModesUndoCursorLine',
		CursorLineNr = 'ModesUndoCursorLineNr',
		CursorLineSign = 'ModesUndoCursorLineSign',
		CursorLineFold = 'ModesUndoCursorLineFold',
	},
	redo = {
		CursorLine = 'ModesRedoCursorLine',
		CursorLineNr = 'ModesRedoCursorLineNr',
		CursorLineSign = 'ModesRedoCursorLineSign',
		CursorLineFold = 'ModesRedoCursorLineFold',
	},
	change = {
		CursorLine = 'ModesChangeCursorLine',
		CursorLineNr = 'ModesChangeCursorLineNr',
		CursorLineSign = 'ModesChangeCursorLineSign',
		CursorLineFold = 'ModesChangeCursorLineFold',
	},
}
local colors = {}
local additional_colors = {}
local shaded_colors = {}
local operator_started = false
local in_ignored_buffer = function()
	return vim.tbl_contains(config.ignore_filetypes, vim.bo.filetype)
end

M.reset = function()
	if in_change_mode then
		return
	end
	M.highlight('normal')
	M.swap_insert_highlight()
	reset_timer = nil
	operator_started = false
end

---Update highlights
---@param scene_event 'normal'|'insert'|'change'|'visual'|'copy'|'delete'| 'command' | 'replace' | 'char_replace' | 'pending' | 'undo' | 'redo'
M.highlight = function(scene_event)
	if in_ignored_buffer() then
		return
	end

	-- map keymap events to actual scene names
	local scene_name = scene_event
	if scene_event == 'char_replace' then
		scene_name = 'replace'
	elseif scene_event == 'insert' and in_change_mode then
		scene_name = 'change'
	end

	local winhl_map = {}
	local prev_value = vim.api.nvim_win_get_option(0, 'winhighlight')

	-- mapping the old value of 'winhighlight'
	if prev_value ~= '' then
		for _, winhl in ipairs(vim.split(prev_value, ',')) do
			local pair = vim.split(winhl, ':')
			winhl_map[pair[1]] = pair[2]
		end
	end

	-- overrides 'builtin':'hl' if the current scene has a mapping for it
	for builtin, hl in pairs(winhighlight[scene_name]) do
		winhl_map[builtin] = hl
	end

	local new_value = {}
	for builtin, hl in pairs(winhl_map) do
		table.insert(new_value, ('%s:%s'):format(builtin, hl))
	end
	vim.api.nvim_win_set_option(0, 'winhighlight', table.concat(new_value, ','))

	-- set showmoe message colors in command line section, like --Insert-- or --Visual--
	if vim.api.nvim_get_option('showmode') then
		if scene_event == 'visual' then
			utils.set_hl('ModeMsg', { link = 'ModesVisualModeMsg' })
		elseif scene_event == 'insert' then
			utils.set_hl('ModeMsg', { link = 'ModesInsertModeMsg' })
		elseif scene_event == 'change' then
			utils.set_hl('ModeMsg', { link = 'ModesChangeModeMsg' })
		else
			utils.set_hl('ModeMsg', { link = 'Normal' })
		end
	end

	-- link cursor colors for operator and normal modes
	if config.set_cursor then
		if scene_event == 'normal' then
			utils.set_hl('ModesNormalCursor', { link = 'ModesNormal' })
		elseif scene_event == 'delete' then
			utils.set_hl('ModesOperatorCursor', { link = 'ModesDelete' })
			utils.set_hl('ModesNormalCursor', { link = 'ModesDelete' })
		elseif scene_event == 'change' then
			utils.set_hl('ModesOperatorCursor', { link = 'ModesChange' })
			utils.set_hl('ModesNormalCursor', { link = 'ModesChange' })
		elseif scene_event == 'copy' then
			utils.set_hl('ModesNormalCursor', { link = 'ModesCopy' })
			utils.set_hl('ModesOperatorCursor', { link = 'ModesCopy' })
		elseif scene_event == 'pending' then
			utils.set_hl('ModesOperatorCursor', { link = 'ModesPending' })
		elseif scene_event == 'undo' then
			utils.set_hl('ModesNormalCursor', { link = 'ModesUndo' })
		elseif scene_event == 'redo' then
			utils.set_hl('ModesNormalCursor', { link = 'ModesRedo' })
		end
	end

	-- set additional highlight groups
	for hl_group, settings in pairs(config.additional_highlight_groups) do
		local hl_def = {}
		if settings.fg and settings.fg.enabled then
			hl_def.fg = additional_colors[hl_group].fg_colors[scene_name]
		end

		if settings.bg and settings.bg.enabled then
			hl_def.bg = additional_colors[hl_group].bg_colors[scene_name]
		end
		utils.set_hl(hl_group, hl_def)
	end

	lualine.highlight(config, scene_event, scene_name)
	aerial.highlight(config, scene_event, scene_name)
	bufferline.highlight(config, scene_name)
end

M.swap_insert_highlight = function()
	if in_change_mode then
		colors.insert = colors.change
		shaded_colors.insert = shaded_colors.change
	else
		colors.insert = colors.original_insert
		shaded_colors.insert = shaded_colors.original_insert
	end
	M.define_highlight_groups('Insert')
end

M.define_highlight_groups = function(mode)
	local def = { fg = colors[mode:lower()], bg = shaded_colors[mode:lower()] }
	local bg_def = { bg = colors[mode:lower()] }
	local bg_shade_def = { bg = shaded_colors[mode:lower()] }
	local mode_highlight_name = ('Modes%s'):format(mode)
	utils.set_hl(mode_highlight_name, bg_def)

	utils.set_hl(('Modes%sCursorLine'):format(mode), bg_shade_def)
	utils.set_hl(('Modes%sCursorLineNr'):format(mode), def)
	utils.set_hl(('Modes%sCursorLineSign'):format(mode), bg_shade_def)
	utils.set_hl(('Modes%sCursorLineFold'):format(mode), bg_shade_def)

	if mode == 'Insert' then
		utils.set_hl('ModesInsertModeMsg', { fg = colors.insert })
	elseif mode == 'Change' then
		utils.set_hl('ModesChangeModeMsg', { fg = colors.change })
	elseif mode == 'Visual' then
		utils.set_hl('ModesVisualModeMsg', { fg = colors.visual })
		utils.set_hl('ModesVisualVisual', { bg = shaded_colors.visual })
	end
end

M.define = function()
	colors = {
		black_text = config.colors.text or '#1e1e1e',
		white_text = config.colors.white_text or '#d4d4d4',
		normal = config.colors.normal or utils.get_bg('ModesNormal', '#608B4E'),
		copy = config.colors.copy or utils.get_bg('ModesCopy', '#f5c359'),
		delete = config.colors.delete or utils.get_bg('ModesDelete', '#c75c6a'),
		insert = config.colors.insert or utils.get_bg('ModesInsert', '#569CD6'),
		change = config.colors.change or utils.get_bg('ModesChange', '#c75c6a'),
		visual = config.colors.visual or utils.get_bg('ModesVisual', '#C586C0'),
		pending = config.colors.pending
			or utils.get_bg('ModesVisual', '#4ec9b0'),
		command = config.colors.command
			or utils.get_bg('ModesCommand', '#deb974'),
		replace = config.colors.replace
			or utils.get_bg('ModesReplace', '#e3a5a5'),
		undo = config.colors.undo or utils.get_bg('ModesUndo', '#9745be'),
		redo = config.colors.redo or utils.get_bg('ModesRedo', '#9745be'),
	}

	colors.original_insert = colors.insert
	config.colors = colors

	shaded_colors =
		utils.define_component_opacity(config, 'cursorline', 'opacity')
	shaded_colors.original_insert = shaded_colors.insert
	config.shaded_colors = shaded_colors

	---Create highlight groups
	for _, mode in ipairs({
		'Normal',
		'Copy',
		'Delete',
		'Insert',
		'Visual',
		'Pending',
		'Command',
		'Replace',
		'Undo',
		'Redo',
		'Change',
	}) do
		M.define_highlight_groups(mode)
	end

	if config.set_yanked_background then
		vim.api.nvim_create_autocmd('TextYankPost', {
			pattern = '*',
			command = [[silent! lua require'vim.highlight'.on_yank({higroup="TextYanked", timeout = 500})]],
			desc = 'Highlight yanked text',
		})

		utils.set_hl('TextYanked', { bg = shaded_colors.copy })
	end

	-- create additional highlights
	for hl_group, settings in pairs(config.additional_highlight_groups) do
		local hl_group_colors = {}
		if settings.fg and settings.fg.enabled then
			if settings.fg.opacity ~= nil then
				hl_group_colors.fg_colors = utils.define_component_opacity(
					config,
					'additional_highlight_groups',
					hl_group,
					'fg',
					'opacity'
				)
			else
				hl_group_colors.fg_colors = colors
			end
		end
		if settings.bg and settings.bg.enabled then
			if settings.bg and settings.bg.opacity ~= nil then
				hl_group_colors.bg_colors = utils.define_component_opacity(
					config,
					'additional_highlight_groups',
					hl_group,
					'bg',
					'opacity'
				)
			else
				hl_group_colors.bg_colors = colors
			end
		end
		additional_colors[hl_group] = hl_group_colors
	end

	lualine.define(config)
	aerial.define(config)
	bufferline.define(config)
end

local group = vim.api.nvim_create_augroup('NvimModesCursor', { clear = true })
local block_cursor_timer

local function block_insert()
	if block_cursor_timer then
		block_cursor_timer:stop()
	end
	block_cursor_timer = vim.defer_fn(function()
		vim.cmd([[execute 'set guicursor-=i:ver10-ModesInsert']])
		vim.cmd([[execute 'set guicursor+=i:block-ModesInsert']])
	end, 1000)
end

local function vertline_insert()
	vim.cmd([[execute 'set guicursor-=i:block-ModesInsert']])
	vim.cmd([[execute 'set guicursor+=i:ver10-ModesInsert']])
end

M.enable_managed_ui = function()
	if in_ignored_buffer() then
		return
	end

	if config.set_cursor then
		vim.opt.guicursor:append('n:block-ModesNormalCursor')
		vim.opt.guicursor:append('v-sm:block-ModesVisual')
		vim.opt.guicursor:append('i-ci-ve:ver25-ModesInsert')
		vim.opt.guicursor:append('o:block-ModesOperatorCursor')
		vim.opt.guicursor:append('r:hor20-ModesReplace')
		vim.opt.guicursor:append('c:block-ModesCommand')

		vim.api.nvim_create_autocmd('CursorHoldI', {
			callback = block_insert,
			group = group,
			desc = 'Insert mode block cursor on hold',
		})

		vim.api.nvim_create_autocmd('CursorMovedI', {
			callback = vertline_insert,
			group = group,
			desc = 'Insert mode vertical line cursor on type',
		})
	end

	if config.cursorline.enabled then
		vim.opt.cursorline = true
	end
end

M.disable_managed_ui = function()
	if in_ignored_buffer() then
		return
	end

	if config.set_cursor then
		vim.opt.guicursor:remove('n:block-ModesNormalCursor')
		vim.opt.guicursor:remove('v-sm:block-ModesVisual')
		vim.opt.guicursor:remove('i-ci-ve:ver25-ModesInsert')
		vim.opt.guicursor:remove('o:block-ModesOperatorCursor')
		vim.opt.guicursor:remove('r:hor20-ModesReplace')
		vim.opt.guicursor:remove('c:block-ModesCommand')
		vim.api.nvim_clear_autocmds({ group = group })
	end

	if config.cursorline.enabled then
		vim.opt.cursorline = false
	end
end

local function delay_oprator_reset()
	if reset_timer then
		reset_timer:stop()
	end

	reset_timer = vim.defer_fn(function()
		if vim.fn.mode() == 'n' then
			M.reset()
		end
	end, reset_delay)
end

local last_key_pressed = nil

M.setup = function(opts)
	opts = opts or default_config
	if opts.focus_only then
		print(
			'modes.nvim – `focus_only` has been removed and is now the default behaviour'
		)
	end

	config = vim.tbl_deep_extend('force', default_config, opts)

	M.define()

	vim.on_key(function(key)
		last_key_pressed = key
		local ok, current_mode = pcall(vim.fn.mode)
		if not ok then
			M.reset()
			return
		end

		if key == utils.get_termcode('<esc>') then
			in_change_mode = false
			M.reset()
		end

		if current_mode == 'n' then
			-- reset if coming back from operator pending mode
			if
				operator_started
				and not (reset_timer and reset_timer:get_due_in() > 0)
			then
				M.reset()
				return
			end

			if key == 'c' then
				in_change_mode = true
				M.swap_insert_highlight()
				M.highlight('change')
				operator_started = true
				delay_oprator_reset()
				return
			end

			if key == 'y' then
				M.highlight('copy')
				operator_started = true
				delay_oprator_reset()
				return
			end

			if key == 'd' then
				M.highlight('delete')
				operator_started = true

				delay_oprator_reset()

				return
			end

			if key == 'r' then
				M.highlight('char_replace')
				operator_started = true
				delay_oprator_reset()
				return
			end

			if key == ':' or key == '/' then
				M.highlight('command')
				operator_started = true
				return
			end

			if key == '@' then
				M.highlight('pending')
				operator_started = true
				return
			end
		end
	end)

	---Set highlights when colorscheme changes
	vim.api.nvim_create_autocmd('ColorScheme', {
		pattern = '*',
		callback = M.define,
	})

	---Set insert highlight
	vim.api.nvim_create_autocmd('InsertEnter', {
		pattern = '*',
		callback = function()
			M.highlight('insert')
		end,
	})

	---Reset insert highlight
	vim.api.nvim_create_autocmd('ModeChanged', {
		pattern = 'i:n',
		callback = M.reset,
	})

	---Set visual highlight
	vim.api.nvim_create_autocmd('ModeChanged', {
		pattern = '*:[vV\x16]',
		callback = function()
			M.highlight('visual')
		end,
	})

	---Reset visual highlight
	vim.api.nvim_create_autocmd('ModeChanged', {
		pattern = '[vV\x16]:n',
		callback = M.reset,
	})

	---Set replace highlight
	vim.api.nvim_create_autocmd('ModeChanged', {
		pattern = 'n:r',
		callback = function()
			M.highlight('replace')
		end,
	})

	---Set undo/redo highlights
	vim.api.nvim_create_autocmd('TextChanged', {
		pattern = '*',
		callback = function()
			if last_key_pressed == 'u' then
				M.highlight('undo')
			elseif last_key_pressed == '' then
				M.highlight('redo')
			end
			delay_oprator_reset()
		end,
	})

	---Reset highlights
	vim.api.nvim_create_autocmd({ 'CmdlineLeave', 'WinLeave' }, {
		pattern = '*',
		callback = M.reset,
	})

	---Enable managed UI initially
	M.enable_managed_ui()

	---Enable managed UI for current window
	vim.api.nvim_create_autocmd('WinEnter', {
		pattern = '*',
		callback = M.enable_managed_ui,
	})

	---Disable managed UI for unfocused windows
	vim.api.nvim_create_autocmd('WinLeave', {
		pattern = '*',
		callback = M.disable_managed_ui,
	})

	M.reset()
end

return M
