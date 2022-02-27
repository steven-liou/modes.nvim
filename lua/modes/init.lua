local util = require("modes.util")

local modes = {}
local config = {}
local colors = {}
local dim_colors = {}
local init_colors = {}
local operator_started = false

function modes.reset()
  modes.set_highlights("normal")
  operator_started = false
end

function modes.set_highlights(style)
  -- if style == "init" then
  --   vim.cmd("hi CursorLine guibg=" .. init_colors.cursor_line)
  --   vim.cmd("hi CursorLineNr guifg=" .. init_colors.cursor_line_nr)
  --   vim.cmd("hi ModeMsg guifg=" .. init_colors.mode_msg)
  -- end

  if style == "normal" then
    vim.cmd("hi CursorLine guibg=" .. dim_colors.normal)
    vim.cmd("hi CursorLineNr guifg=" .. colors.normal)
    vim.cmd("hi ModeMsg guifg=" .. colors.normal)
  end

  if style == "copy" then
    vim.cmd("hi CopyLine guibg=" .. dim_colors.copy)
    vim.cmd("hi CursorLine guibg=" .. dim_colors.copy)
    vim.cmd("hi CursorLineNr guifg=" .. colors.copy)
    vim.cmd("hi ModeMsg guifg=" .. colors.copy)
    vim.cmd("hi ModesOperator guifg=NONE guibg=NONE")
    vim.cmd("hi! link ModesOperator ModesCopy")
  end

  if style == "delete" then
    vim.cmd("hi CursorLine guibg=" .. dim_colors.delete)
    vim.cmd("hi CursorLineNr guifg=" .. colors.delete)
    vim.cmd("hi ModeMsg guifg=" .. colors.delete)
    vim.cmd("hi ModesOperator guifg=NONE guibg=NONE")
    vim.cmd("hi! link ModesOperator ModesDelete")
  end

  if style == "replace" then
    vim.cmd("hi CursorLine guibg=" .. dim_colors.replace)
    vim.cmd("hi CursorLineNr guifg=" .. colors.replace)
    vim.cmd("hi ModeMsg guifg=" .. colors.replace)
    vim.cmd("hi ModesOperator guifg=NONE guibg=NONE")
    vim.cmd("hi! link ModesOperator ModesReplace")
  end

  if style == "insert" then
    vim.cmd("hi CursorLine guibg=" .. dim_colors.insert)
    vim.cmd("hi CursorLineNr guifg=" .. colors.insert)
    vim.cmd("hi ModeMsg guifg=" .. colors.insert)
  end

  if style == "visual" then
    vim.cmd("hi CursorLine guibg=" .. dim_colors.visual)
    vim.cmd("hi CursorLineNr guifg=" .. colors.visual)
    vim.cmd("hi ModeMsg guifg=" .. colors.visual)
  end

  if style == "command" then
    vim.cmd("hi CursorLine guibg=" .. dim_colors.command)
    vim.cmd("hi CursorLineNr guifg=" .. colors.command)
    vim.cmd("hi ModeMsg guifg=" .. colors.command)
  end

end

function modes.set_colors()
  init_colors = {
    cursor_line = util.get_bg_from_hl("CursorLine", "CursorLine"),
    cursor_line_nr = util.get_fg_from_hl("CursorLineNr", "CursorLineNr"),
    mode_msg = util.get_fg_from_hl("ModeMsg", "ModeMsg"),
    normal = util.get_bg_from_hl("Normal", "Normal"),
  }
  colors = {
    normal = config.colors.normal or
      util.get_bg_from_hl("ModesNormal", "#608B4E"),
    copy = config.colors.copy or util.get_bg_from_hl("ModesCopy", "#deb974"),
    delete = config.colors.delete or
      util.get_bg_from_hl("ModesDelete", "#F44747"),
    replace = config.colors.replace or
      util.get_bg_from_hl("ModesReplace", "#D16969"),
    insert = config.colors.insert or
      util.get_bg_from_hl("ModesInsert", "#569CD6"),
    visual = config.colors.visual or
      util.get_bg_from_hl("ModesVisual", "#C586C0"),
    command = config.colors.copy or
      util.get_bg_from_hl("ModesCommand", "#deb974"),
  }
  dim_colors = {
    normal = util.blend(colors.normal, init_colors.normal,
                        config.line_opacity.normal),
    copy = util.blend(colors.copy, init_colors.normal, config.line_opacity.copy),
    delete = util.blend(colors.delete, init_colors.normal,
                        config.line_opacity.delete),
    insert = util.blend(colors.insert, init_colors.normal,
                        config.line_opacity.insert),
    visual = util.blend(colors.visual, init_colors.normal,
                        config.line_opacity.visual),
    command = util.blend(colors.command, init_colors.normal,
                         config.line_opacity.command),
    replace = util.blend(colors.replace, init_colors.normal,
                         config.line_opacity.replace),
  }

  vim.cmd("hi ModesNormal guibg=" .. colors.normal)
  vim.cmd("hi ModesCopy guibg=" .. colors.copy)
  vim.cmd("hi ModesDelete guibg=" .. colors.delete)
  vim.cmd("hi ModesInsert guibg=" .. colors.insert)
  vim.cmd("hi ModesVisual guibg=" .. colors.visual)
  vim.cmd("hi ModesCommand guibg=" .. colors.command)
  vim.cmd("hi ModesReplace guibg=" .. colors.replace)
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
      copy = 0.15,
      delete = 0.15,
      insert = 0.15,
      visual = 0.15,
      command = 0.15,
      replace = 0.15,
    },
    set_cursor = true,
    focus_only = false,
  }
  opts = opts or default_config

  -- Resolve configs in the following order:
  -- 1. User config
  -- 2. Theme highlights if present (eg. ModesCopy)
  -- 3. Default config
  config = vim.tbl_deep_extend("force", default_config, opts)

  -- Allow overriding line opacity per colour
  if type(config.line_opacity) == "number" then
    config.line_opacity = {
      normal = config.line_opacity,
      copy = config.line_opacity,
      delete = config.line_opacity,
      insert = config.line_opacity,
      visual = config.line_opacity,
      command = config.line_opacity,
      replace = config.line_opacity,
    }
  end

  -- Hack to ensure theme colors get loaded properly
  modes.set_colors()
  vim.defer_fn(function()
    modes.set_colors()
  end, 15)

  -- Set common highlights
  vim.cmd("hi Visual guibg=" .. dim_colors.visual)

  -- Set guicursor modes
  if config.set_cursor then
    vim.opt.guicursor:append("n:block-ModesNormal")
    vim.opt.guicursor:append("v-sm:block-ModesVisual")
    vim.opt.guicursor:append("i-ci-ve:ver25-ModesInsert")
    vim.opt.guicursor:append("r-cr-o:block-ModesOperator")
    vim.opt.guicursor:append("c:block-ModesCommand")
  end

  local on_key = vim.on_key or vim.register_keystroke_callback
  on_key(function(key)
    local current_mode = vim.fn.mode()

    -- Insert mode
    if current_mode == "i" then
      if key == util.get_termcode("<esc>") then
        modes.reset()
      end
    end

    -- Normal mode
    if current_mode == "n" then
      if key == util.get_termcode("<esc>") then
        modes.reset()
      end

      if key == "y" then
        if operator_started then
          modes.reset()
        else
          modes.set_highlights("copy")
          operator_started = true
        end
      end

      if key == "d" then
        if operator_started then
          modes.reset()
        else
          modes.set_highlights("delete")
          operator_started = true
        end
      end

      if (key == "v" or key == "V") and not operator_started then
        modes.set_highlights("visual")
      end

      if key == "r" then
        if operator_started then
          modes.reset()
        else
          modes.set_highlights("replace")
          operator_started = true
        end
      end

      if key == ":" then
        modes.set_highlights("command")
      end
    end

    -- Visual mode
    if current_mode == "v" then
      if key == util.get_termcode("<esc>") then
        modes.reset()
      end
    end

    -- Visual line mode
    if current_mode == "V" then
      if key == util.get_termcode("<esc>") then
        modes.reset()
      end
    end

    -- Command mode
    if current_mode == "c" then
      if key == util.get_termcode("<esc>") then
        modes.reset()
      end
    end

    -- Replace mode
    if current_mode == "R" then
      if key == util.get_termcode("<esc>") then
        modes.reset()
      end
    end

  end)

  local autocmds = {
    {"ColorScheme", "*", "lua require(\"modes\").set_colors()"},
    {"InsertEnter", "*", "lua require(\"modes\").set_highlights(\"insert\")"},
    {
      "CmdlineLeave,InsertLeave,TextYankPost,WinLeave",
      "*",
      "lua require(\"modes\").reset()",
    },
    {
      "TextYankPost",
      "*",
      "lua vim.highlight.on_yank({higroup='CopyLine', timeout=500})",
    },
    {"VimEnter,SourcePost,FocusGained,CursorHoldI", "*", "lua Block_insert()"},
    {"CursorMovedI", "*", "lua Vertline_insert()"},
  }

  if config.focus_only then
    autocmds["cl"] = {"WinEnter", "*", "set cursorline"}
    autocmds["nocl"] = {"WinLeave", "*", "set nocursorline"}
  end

  util.define_augroups({_modes = autocmds})
end

-- Allow insert mode cursors to change shape when typing and waiting
function Block_insert()
  vim.cmd [[execute 'set guicursor-=i:ver10-ModesInsert']]
  vim.cmd [[execute 'set guicursor+=i:block-ModesInsert']]

end

function Vertline_insert()
  vim.cmd [[execute 'set guicursor-=i:block-ModesInsert']]
  vim.cmd [[execute 'set guicursor+=i:ver10-ModesInsert']]
end

return modes
