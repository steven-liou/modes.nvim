# modes.nvim

> Prismatic line decorations for the adventurous vim user

Highlight UI elements based on current mode. Inspired by the recent addition of vim bindings in Xcode.

## Usage

```lua
use({
  'steven-liou/modes.nvim',
  config = function()
    vim.opt.cursorline = true
    require('modes').setup()
  end
})
```

![modes.nvim](https://user-images.githubusercontent.com/1474821/127896095-6da221cf-3327-4eed-82be-ce419bdf647c.gif)

## Options

> Note: `vim.opt.cursorline` must be set to true for lines to be highlighted

Default colors can be overridden by passing values to the setup function or updating highlight groups.

```lua
require("modes").setup({
	colors = {
        black_text = "#1e1e1e",
        white_text = "#d4d4d4",
		normal = "#608b4e",
		insert = "#569cd6",
		change = "#41729F",
		visual = "#c586c0",
		replace = "#d16969",
		command = "#deb974",
		pending = "#4ec9b0",
		copy = "#f5c359",
		delete = "#c75c6a"
		undo = "#9745be",
		redo = "#9745be",
	},

    -- For highlight groups you wish to change the colors based on modes
	highlight_groups = {
		Cursorline = {
			bg = {
				enabled = true,
				opacity = {
					normal = 0.08,
					insert = 0.08,
					change = 0.1,
					visual = 0.1,
					replace = 0.1,
					command = 0.1,
					pending = 0.1,
					copy = 0.1,
					delete = 0.1,
					undo = 0.1,
					redo = 0.1,
				},
			},
		},
		CursorLineNr = { fg = { enabled = true }, bg = { enabled = true, opacity = 0.1 } },
		CursorLineSign = { fg = { enabled = true }, bg = { enabled = true, opacity = 0.1 } },
		CursorLineFold = { bg = { enabled = true, opacity = 0.1 } },
		FloatBorder = { fg = { enabled = true, opacity = 0.4 } },
		NvimSeparator = { fg = { enabled = true, opacity = 0.2 } }, -- for colorful-winsep.nvim
		IndentBlanklineContext = { fg = { enabled = true } }, -- for indent-blankline.nvim
		VirtColumn = { fg = { enabled = true, opacity = 0.2 } }, -- for virt-column.nvim
		MatchArea = { bg = { enabled = true, opacity = 0.1 } }, -- for hl_match_area.nvim
		IndentBlanklineIndent1 = { fg = { enabled = true, opacity = 0.5 } }, -- for indent-blankline.nvim
		IndentBlanklineIndent2 = { fg = { enabled = true, opacity = 0.5 } }, -- for indent-blankline.nvim
		IndentBlanklineIndent3 = { fg = { enabled = true, opacity = 0.5 } }, -- for indent-blankline.nvim
		IndentBlanklineIndent4 = { fg = { enabled = true, opacity = 0.5 } }, -- for indent-blankline.nvim
		IndentBlanklineIndent5 = { fg = { enabled = true, opacity = 0.5 } }, -- for indent-blankline.nvim
		IndentBlanklineIndent6 = { fg = { enabled = true, opacity = 0.5 } }, -- for indent-blankline.nvim
	},

	-- Highlight cursor
	set_cursor = true,
	-- Enable line number highlights to match cursorline
	set_number = true,
    set_yanked_background = { enabled = true, timeout = 2000 },


	-- Highlight lualine
	lualine = {
		enabled = true,
		statusbar_side_opacity = {
			normal = 0.1,
			copy = 0.2,
			change = 0.2,
			delete = 0.15,
			insert = 0.10,
			visual = 0.15,
			command = 0.17,
			replace = 0.15,
			pending = 0.15,
			undo = 0.15,
			redo = 0.15,
		},
		statusbar_middle_opacity = {
			normal = 0.08,
			copy = 0.12,
			delete = 0.12,
			insert = 0.12,
            change = 0.12,
			visual = 0.12,
			command = 0.12,
			replace = 0.12,
			pending = 0.12,
			undo = 0.12,
            redo = 0.12,
		},
		diff_component = "x",
		diagnostics_component = "x",
		filetype_component = "y",
		aerial_component = "c",
	},

    -- Highlight bufferline.nvim
	bufferline = {
		enabled = true,
		background_color = "#1e1e1e",
		fill_color = "#1e1e1e",
		opacity = {
			normal = 0.08,
			copy = 0.08,
			delete = 0.1,
			insert = 0.06,
            change = 0.08
			visual = 0.1,
			command = 0.1,
			replace = 0.08,
			pending = 0.09,
			undo = 0.08,
            redo = 0.08,
		},
	},

    -- for gitsigns.nvim support
	gitsigns = {
		enabled = true,
		opacity = 0.08,
	},

    -- for nvim-lspconfig lsp diagnostics support
	diagnostic_signs = {
		enabled = true,
		opacity = 0.1,
	},

	todos_comment = {
		enabled = true,
		comment_types = { "FIX", "HACK", "NOTE", "PERF", "TEST", "TODO", "WARN" },
		opacity = 0.1,
	},


	-- for capslock.nvim
	capslock = {
		enabled = true,
		color = "undo", -- color name based on one of the colors definition key above, like "norma", "insert", "visual"...
		opacity = 0.1,
	},

	-- Highlight in active window only
	focus_only = false,

	-- Disable modes highlights in specified filetypes
	ignore_filetypes = {'NvimTree', 'TelescopePrompt'},
})
```

```lua
-- Exposed highlight groups, useful for themes
vim.cmd('hi ModesNormal guibg=#608b4e')
vim.cmd('hi ModesInsert guibg=#569cd6')
vim.cmd('hi ModesChange guibg=#9745be')
vim.cmd('hi ModesVisual guibg=#c586d0')
vim.cmd('hi ModesReplace guibg=#d16969')
vim.cmd('hi ModesCommand guibg=#deb974')
vim.cmd('hi ModesPending guibg=#78ccc5')
vim.cmd('hi ModesCopy guibg=#f5c359')
vim.cmd('hi ModesDelete guibg=#c75c6a')
vim.cmd('hi ModesUndo guibg=#9745be')
vim.cmd('hi ModesRedo guibg=#9745be')
```

## Known issues

- Some _Which Key_ presets conflict with this plugin. For example, `d` and `y` operators will not apply highlights if `operators = true` because _Which Key_ takes priority

_Workaround:_

```lua
require('which-key').setup({
  plugins = {
    presets = {
      operators = false,
    },
  },
})
```
