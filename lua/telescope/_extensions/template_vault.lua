-- lua/telescope/_extensions/template_vault.lua
local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local template_vault = require("template_vault")

return telescope.register_extension({
  exports = {
    template_vault = function()
      template_vault.browse_templates()
    end,
  },
})
