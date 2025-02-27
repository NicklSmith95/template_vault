vim.api.nvim_create_user_command('TemplateVaultSave', function()
  require('template_vault').save_template()
end, {})

vim.api.nvim_create_user_command('TemplateVaultBrowse', function()
  require('telescope').load_extension('template_vault')
  require('telescope').extensions.template_vault.template_vault()
end, {})
