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
  'yourusername/template_vault.nvim',
  requires = {'nvim-telescope/telescope.nvim'},
  config = function()
    require('template_vault').setup({
      -- Optional custom configuration
    })
    require('telescope').load_extension('template_vault')
  end
}

