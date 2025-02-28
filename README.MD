# Template Vault

A Neovim plugin for managing and using code templates with Telescope integration.

## Features

- Save code snippets as templates
- Browse and insert templates with Telescope
- Organize templates by category

## Installation

### Packer
```lua
use {
  'nicklsmith95/template_vault',
  requires = {'nvim-telescope/telescope.nvim'},
  config = function()
    require('template_vault').setup({
      -- Optional custom configuration
    })
    require('telescope').load_extension('template_vault')
  end
}

### Remaps
Here are some sample remaps
```lua
-- Key mappings
vim.keymap.set("n", "<leader>ts", require("template_vault").save_template, { desc = "Save Template" })
vim.keymap.set("v", "<leader>ts", require("template_vault").save_template, { desc = "Save Selection as Template" })
vim.keymap.set("n", "<leader>tt", function() require("telescope").extensions.template_vault.template_vault() end, { desc = "Browse Templates" })

