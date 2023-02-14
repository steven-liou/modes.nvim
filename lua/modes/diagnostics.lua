local utils = require('modes.utils')
local color_opacity = {}
local M = {}

local gitsigns_background_groups = {
	'DiagnosticSignOk',
	'DiagnosticSignError',
	'DiagnosticSignWarn',
	'DiagnosticSignHint',
	'DiagnosticSignInfo',
}

-- local gitsigns_foreground_groups = {
-- 	'GitSignsAddNr',
-- 	'GitSignsChangeNr',
-- 	'GitSignsDeleteNr',
-- }

M.define = function(config)
	if not config.diagnostic_signs.enabled then
		return
	end
	color_opacity =
		utils.define_component_opacity(config, 'diagnostic_signs', 'opacity')
end

M.highlight = function(config, scene_name)
	if not config.diagnostic_signs.enabled then
		return
	end

	local colors = config.colors

	for _, name in ipairs(gitsigns_background_groups) do
		local highlight_colors = utils.get_highlight_colors_by_name(name)
		if highlight_colors then
			local fg_def = {
				fg = highlight_colors.foreground,
				bg = color_opacity[scene_name],
				gui = 'bold',
			}
			utils.set_hl(name, fg_def)
		end
	end

	-- for _, name in ipairs(gitsigns_foreground_groups) do
	-- 	local highlight_colors = utils.get_highlight_colors_by_name(name)
	-- 	if highlight_colors then
	-- 		local fg_def = {
	-- 			fg = colors[scene_name],
	-- 			bg = color_opacity[scene_name],
	-- 			gui = 'bold',
	-- 		}
	-- 		utils.set_hl(name, fg_def)
	-- 	end
	-- end
end

return M
