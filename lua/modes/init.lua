local util = require('modes.util')

local modes = {}
local config = {}
local colors = {}
local dim_colors = {}
local init_colors = {}
local operator_started = false
local timer = nil
local style = 'normal'
local block_cursor_timer

function modes.reset()
	modes.set_highlights('normal')
	operator_started = false
end

function modes.block_insert()
	if block_cursor_timer then
		block_cursor_timer:stop()
	end
	block_cursor_timer = vim.defer_fn(function()
		vim.cmd([[execute 'set guicursor-=i:ver10-ModesInsert']])
		vim.cmd([[execute 'set guicursor+=i:block-ModesInsert']])
	end, 1000)
end

function modes.vertline_insert()
	vim.cmd([[execute 'set guicursor-=i:block-ModesInsert']])
	vim.cmd([[execute 'set guicursor+=i:ver10-ModesInsert']])
end

local set_current_line_highlight = function(fg, bg)
	vim.cmd('hi CursorLineNr guifg=' .. fg .. ' guibg=' .. bg)
end

function modes.set_highlights(style)
	-- if style == "init" then
	--   vim.cmd("hi CursorLine guibg=" .. init_colors.cursor_line)
	--   vim.cmd("hi CursorLineNr guifg=" .. init_colors.cursor_line_nr)
	--   vim.cmd("hi ModeMsg guifg=" .. init_colors.mode_msg)
	-- end

	if style == 'normal' then
		vim.cmd('hi CursorLine guibg=' .. dim_colors.normal)
		set_current_line_highlight(colors.normal, dim_colors.normal)
		vim.cmd('hi ModeMsg guifg=' .. colors.normal)
	end

	
	if style == 'replace' then
		vim.cmd('hi CursorLine guibg=' .. dim_colors.replace)
		set_current_line_highlight(colors.replace, dim_colors.replace)
		vim.cmd('hi ModeMsg guifg=' .. colors.replace)
		vim.cmd('hi! ModesOperator guifg=NONE guibg=NONE')
		vim.cmd('hi! link ModesOperator ModesReplace')
		vim.cmd('hi! ModesOperatorText guifg=NONE guibg=NONE')
		vim.cmd('hi! link ModesOperatorText ModesReplaceText')
	end

	if style == 'insert' then
		vim.cmd('hi CursorLine guibg=' .. dim_colors.insert)
		set_current_line_highlight(colors.insert, dim_colors.insert)
		vim.cmd('hi ModeMsg guifg=' .. colors.insert)
	end

	if style == 'visual' then
		vim.cmd('hi CursorLine guibg=' .. dim_colors.visual)
		set_current_line_highlight(colors.visual, dim_colors.visual)
		vim.cmd('hi ModeMsg guifg=' .. colors.visual)
	end

	if style == 'command' then
		vim.cmd('hi CursorLine guibg=' .. dim_colors.command)
		set_current_line_highlight(colors.command, dim_colors.command)
		vim.cmd('hi ModeMsg guifg=' .. colors.command)
		vim.cmd('hi! ModesOperator guifg=NONE guibg=NONE')
		vim.cmd('hi! link ModesOperator ModesCommand')
		vim.cmd('hi! ModesOperatorText guifg=NONE guibg=NONE')
		vim.cmd('hi! link ModesOperatorText ModesCommandText')
	end

	if style == 'pending' then
		vim.cmd('hi CursorLine guibg=' .. dim_colors.pending)
		set_current_line_highlight(colors.pending, dim_colors.pending)
		vim.cmd('hi ModeMsg guifg=' .. colors.pending)
		vim.cmd('hi! ModesOperator guifg=NONE guibg=NONE')
		vim.cmd('hi! link ModesOperator ModesPending')
		vim.cmd('hi! ModesOperatorText guifg=NONE guibg=NONE')
		vim.cmd('hi! link ModesOperatorText ModesPendingText')
	end
end

function modes.set_colors()
	init_colors = {
		cursor_line = util.get_bg_from_hl('CursorLine', 'CursorLine'),
		cursor_line_nr = util.get_fg_from_hl('CursorLineNr', 'CursorLineNr'),
		mode_msg = util.get_fg_from_hl('ModeMsg', 'ModeMsg'),
		normal = util.get_bg_from_hl('Normal', 'Normal'),
	}
	colors = {
		normal = config.colors.normal
			or util.get_bg_from_hl('ModesNormal', '#608B4E'),
		replace = config.colors.replace
			or util.get_bg_from_hl('ModesReplace', '#e3a5a5'),
		insert = config.colors.insert
			or util.get_bg_from_hl('ModesInsert', '#569CD6'),
		visual = config.colors.visual
			or util.get_bg_from_hl('ModesVisual', '#C586C0'),
		command = config.colors.copy
			or util.get_bg_from_hl('ModesCommand', '#deb974'),
		pending = config.colors.pending
			or util.get_bg_from_hl('ModesPending', '#4ec9b0'),
	}
	dim_colors = {
		normal = util.blend(
			colors.normal,
			init_colors.normal,
			config.line_opacity.normal
		),
		insert = util.blend(
			colors.insert,
			init_colors.normal,
			config.line_opacity.insert
		),
		visual = util.blend(
			colors.visual,
			init_colors.normal,
			config.line_opacity.visual
		),
		command = util.blend(
			colors.command,
			init_colors.normal,
			config.line_opacity.command
		),
		replace = util.blend(
			colors.replace,
			init_colors.normal,
			config.line_opacity.replace
		),
		pending = util.blend(
			colors.pending,
			init_colors.normal,
			config.line_opacity.pending
		),
	}

	vim.cmd('hi ModesNormal gui=bold guifg=#262626 guibg=' .. colors.normal)
	vim.cmd('hi ModesInsert gui=bold guifg=#262626 guibg=' .. colors.insert)
	vim.cmd('hi ModesVisual gui=bold guifg=#262626 guibg=' .. colors.visual)
	vim.cmd('hi ModesCommand gui=bold guifg=#262626 guibg=' .. colors.command)
	vim.cmd('hi ModesReplace gui=bold guifg=#262626 guibg=' .. colors.replace)
	vim.cmd('hi ModesPending gui=bold guifg=#262626 guibg=' .. colors.pending)

	vim.cmd('hi ModesNormalText gui=bold guibg=#262626 guifg=' .. colors.normal)
	vim.cmd('hi ModesInsertText gui=bold guibg=#262626 guifg=' .. colors.insert)
	vim.cmd('hi ModesVisualText gui=bold guibg=#262626 guifg=' .. colors.visual)
	vim.cmd(
		'hi ModesCommandText gui=bold guibg=#262626 guifg=' .. colors.command
	)
	vim.cmd(
		'hi ModesReplaceText gui=bold guibg=#262626 guifg=' .. colors.replace
	)
	vim.cmd(
		'hi ModesPendingText gui=bold guibg=#262626 guifg=' .. colors.pending
	)
end

---@class Colors
---@field copy string
---@field delete string
---@field insert string
---@field visual string

---@class Opacity
---@field copy number between 0 and 1
---@field delete number between 0 and 1
---@field insert number between 0 and 1
---@field visual number between 0 and 1

---@class Config
---@field colors Colors
---@field line_opacity Opacity
---@field set_cursor boolean
---@field focus_only boolean

---@param opts Config
function modes.setup(opts)
	local default_config = {
		-- Colors intentionally set to {} to prioritise theme values
		colors = {},
		line_opacity = {
			normal = 0.15,
			insert = 0.15,
			visual = 0.15,
			command = 0.15,
			replace = 0.15,
			pending = 0.15,
		},
		set_cursor = true,
		focus_only = false,
	}
	opts = opts or default_config

	-- Resolve configs in the following order:
	-- 1. User config
	-- 2. Theme highlights if present (eg. ModesCopy)
	-- 3. Default config
	config = vim.tbl_deep_extend('force', default_config, opts)

	-- Allow overriding line opacity per colour
	if type(config.line_opacity) == 'number' then
		config.line_opacity = {
			normal = config.line_opacity,
			insert = config.line_opacity,
			visual = config.line_opacity,
			command = config.line_opacity,
			replace = config.line_opacity,
			pending = config.line_opacity,
		}
	end

	-- Hack to ensure theme colors get loaded properly
	modes.set_colors()
	vim.defer_fn(function()
		modes.set_colors()
		modes.set_highlights('normal')
	end, 0)

	-- Set common highlights
	vim.cmd('hi Visual guibg=' .. dim_colors.visual)

	-- Set guicursor modes
	if config.set_cursor then
		vim.opt.guicursor:append('a-n:block-ModesNormal')
		vim.opt.guicursor:append('v-sm:block-ModesVisual')
		vim.opt.guicursor:append('i-ci-ve:ver25-ModesInsert')
		vim.opt.guicursor:append('c:block-ModesCommand')
		vim.opt.guicursor:append('cr-o:block-ModesOperator')
		vim.opt.guicursor:append('r:ver25-ModesReplace')
	end

	local on_key = vim.on_key or vim.register_keystroke_callback
	on_key(function(key)
		local current_mode = vim.fn.mode()
		-- print("key " .. key .. " operator " .. vim.v.operator .. " mode " ..
		--        current_mode)

		-- Insert mode
		-- if current_mode == "i" then
		--   if key == util.get_termcode("<esc>") then
		--     modes.reset()
		--   end
		-- end

		-- Normal mode
		if current_mode == 'n' then
			-- for some reason some plugins will use v and V to select regions
			if
				operator_started
				or key == util.get_termcode('<esc>')
				or vim.v.operator == 'g@'
				or key == 'v'
				or key == 'V'
			then
				modes.reset()
			end

			if (key == 'r' or key == 'c') and not operator_started then
				modes.set_highlights('replace')
				operator_started = true
				-- fix highlight only in normal mode (this accounts for s, S, and cc actions)
				vim.defer_fn(function()
					if vim.fn.mode() == 'n' then
						modes.reset()
					end
				end, 0)
			end

			-- operating pending mode
			if key == '@' and not operator_started then
				modes.set_highlights('pending')
				operator_started = true
			end

		end
	end)

	-- Set autocommands
	local group =
		vim.api.nvim_create_augroup('VSCodeVimModes', { clear = true })
	vim.api.nvim_create_autocmd('BufEnter', {
		command = 'set cursorline',
		desc = 'Set cursroline when enter neovim',
	})
	vim.api.nvim_create_autocmd('BufLeave', {
		command = 'set nocursorline',
		desc = 'Disable cursorline when leaving neovim',
	})
	vim.api.nvim_create_autocmd('ModeChanged', {
		pattern = '*:n',
		callback = modes.reset,
		desc = 'Highlight yanked text',
	})

	vim.api.nvim_create_autocmd('ModeChanged', {
		pattern = '*:i',
		callback = function()
			modes.set_highlights('insert')
		end,
		desc = 'Change cursor color when entering insert mode',
	})

	vim.api.nvim_create_autocmd('ModeChanged', {
		pattern = 'n:v,n:,n:V',
		callback = function()
			modes.set_highlights('visual')
		end,
		desc = 'Change cursor color when entering visual mode',
	})

	vim.api.nvim_create_autocmd('ModeChanged', {
		pattern = '*:c',
		callback = function()
			modes.set_highlights('command')
		end,
		desc = 'Change cursor color when entering command mode',
	})

	vim.api.nvim_create_autocmd('ModeChanged', {
		pattern = 'n:no',
		callback = function()
			modes.set_highlights('pending')
		end,
		desc = 'Change cursor color when entering pending mode',
	})

	vim.api.nvim_create_autocmd('TextChanged', {
		callback = function()
			modes.set_highlights(style)
			if timer then
				timer:stop()
			end
			timer = vim.defer_fn(function()
				modes.reset()
				timer = nil
			end, 300)
		end,
		desc = 'Change cursor color when text changed',
	})

	vim.api.nvim_create_autocmd('CursorHoldI', {
		callback = modes.block_insert,
		group = group,
		desc = 'Insert mode block cursor on hold',
	})

	vim.api.nvim_create_autocmd('CursorMovedI', {
		callback = modes.vertline_insert,
		group = group,
		desc = 'Insert mode vertical line cursor on type',
	})
end

return modes
