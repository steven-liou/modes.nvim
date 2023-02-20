local utils = require('modes.utils')
local colors_opacity = {}
local M = {}

local gitsigns_background_groups = {
	'DiagnosticSignOk',
	'DiagnosticSignError',
	'DiagnosticSignWarn',
	'DiagnosticSignHint',
	'DiagnosticSignInfo',
}

M.define = function(config)
	if not (config.diagnostic_signs and config.diagnostic_signs.enabled) then
		return
	end
	colors_opacity =
		utils.define_component_opacity(config, 'diagnostic_signs', 'opacity')
end

M.highlight = function(config, scene_name)
	if not (config.diagnostic_signs and config.diagnostic_signs.enabled) then
		return
	end

	utils.highlight_background_groups(
		scene_name,
		gitsigns_background_groups,
		colors_opacity
	)
end

return M
