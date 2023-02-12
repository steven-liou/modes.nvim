# modes.nvim

> Prismatic line decorations for the adventurous vim user

Highlight UI elements based on current mode. Inspired by the recent addition of vim bindings in Xcode.

## Usage

```lua
use({
  'steven-liou/modes.nvim',
  dependencies = { "kyazdani42/nvim-web-devicons" },
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
		normal = "#608b4e",
		insert = "#569cd6",
		visual = "#c586c0",
		replace = "#d16969",
		command = "#deb974",
		pending = "#4ec9b0",
		copy = "#f5c359",
		delete = "#c75c6a"
		history = "#9745be",
	},

	-- Cursorline highlight opacity
	line_opacity = {
		normal = 0.1,
		insert = 0.1,
		visual = 0.1,
		replace = 0.1,
		command = 0.1,
		pending = 0.1,
		copy = 0.1,
		delete = 0.1,
		history = 0.1,
	},
	-- Highlight lualine
	lualine = {
		enabled = true,
		statusbar_side_opacity = {
			normal = 0.1,
			copy = 0.2,
			delete = 0.15,
			insert = 0.10,
			visual = 0.15,
			command = 0.17,
			replace = 0.15,
			pending = 0.15,
			history = 0.15,
		},
		statusbar_middle_opacity = {
			normal = 0.08,
			copy = 0.12,
			delete = 0.12,
			insert = 0.12,
			visual = 0.12,
			command = 0.12,
			replace = 0.12,
			pending = 0.12,
			history = 0.12,
		},
		diff_component = "x",
		diagnostics_component = "x",
		filetype_component = "y",
		aerial_component = "c",
	},

    -- Highlight bufferline.nvim
	bufferline = {
		enabled = true,
		background_color = colors.shade_black,
		fill_color = colors.black,
		opacity = {
			normal = 0.08,
			copy = 0.08,
			delete = 0.1,
			insert = 0.06,
			visual = 0.1,
			command = 0.1,
			replace = 0.08,
			pending = 0.09,
			history = 0.08,
		},
	},

	-- Highlight cursor
	set_cursor = true,

	-- Enable cursorline initially, and disable cursorline for inactive windows
	-- or ignored filetypes
	set_cursorline = true,

	-- Enable line number highlights to match cursorline
	set_number = true,

  -- Enable highlight background after text yank (uses copy)
	set_yanked_background = true,

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
vim.cmd('hi ModesVisual guibg=#c586d0')
vim.cmd('hi ModesReplace guibg=#d16969')
vim.cmd('hi ModesCommand guibg=#deb974')
vim.cmd('hi ModesPending guibg=#78ccc5')
vim.cmd('hi ModesCopy guibg=#f5c359')
vim.cmd('hi ModesDelete guibg=#c75c6a')
vim.cmd('hi ModesHistory guibg=#9745be')
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
