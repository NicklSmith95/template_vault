-- plugin/template_vault.lua
local M = {}
local config = {
  -- Default template storage location
  storage_path = vim.fn.stdpath("data") .. "/template_vault",
  -- Default categories
  categories = {"general", "lua", "javascript", "python"},
}

-- Initialize the plugin
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  -- Create template directory if it doesn't exist
  vim.fn.mkdir(config.storage_path, "p")
  for _, category in ipairs(config.categories) do
    vim.fn.mkdir(config.storage_path .. "/" .. category, "p")
  end
end

-- Save current selection or buffer as template
function M.save_template()
  -- Get visual selection or current buffer
  local content = M._get_selection() or M._get_buffer_content()
  
  -- Prompt for template name and category via telescope
  M._prompt_save(content)
end

-- Get current visual selection
function M._get_selection()
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' then
    return nil
  end
  
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[2]-1, end_pos[2], false)
  
  return table.concat(lines, "\n")
end

-- Get entire buffer content
function M._get_buffer_content()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return table.concat(lines, "\n")
end

-- Open Telescope for template browsing
function M.browse_templates()
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewer = require("telescope.previewers")
	
  local template_previewer = previewers.new_buffer_previewer({
	title = "Template Preview",
	define_preview = function(self, entry, status)

	local content = M._read_file(entry.path)

	vim.api.nvim_buf_set_lines(self.state.buffnr, 0, -1, false, vim.split(content, "\n"))
  end,
  })
  
  -- Get all templates from storage
  local templates = M._get_all_templates()
  
  pickers.new({}, {
    prompt_title = "Templates",
    finder = finders.new_table({
      results = templates,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.category .. " > " .. entry.name,
          ordinal = entry.category .. " " .. entry.name,
          path = entry.path,
        }
      end,
    }),
    previewer = template_previewer,
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        M._insert_template(selection.path)
      end)
      return true
    end,
  }):find()

})
end

-- Get all templates from the storage directory
function M._get_all_templates()
  local templates = {}
  for _, category in ipairs(config.categories) do
    local category_path = config.storage_path .. "/" .. category
    local files = vim.fn.glob(category_path .. "/*.tmpl", false, true)
    for _, file in ipairs(files) do
      local name = vim.fn.fnamemodify(file, ":t:r")
      table.insert(templates, {
        name = name,
        category = category,
        path = file
      })
    end
  end
  return templates
end

-- Insert template at cursor position
function M._insert_template(template_path)
  local content = M._read_file(template_path)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line, col = cursor_pos[1] - 1, cursor_pos[2]
  
  local lines = vim.split(content, "\n")
  vim.api.nvim_buf_set_text(0, line, col, line, col, lines)
end

-- Prompt for template name and category, then save
function M._prompt_save(content)
  -- First prompt for category
  vim.ui.select(config.categories, {
    prompt = "Select category:",
    format_item = function(item)
      return item
    end,
  }, function(category)
    if not category then return end
    
    -- Then prompt for name
    vim.ui.input({
      prompt = "Template name: ",
    }, function(name)
      if not name or name == "" then return end
      
      local path = config.storage_path .. "/" .. category .. "/" .. name .. ".tmpl"
      M._write_file(path, content)
      vim.notify("Saved template: " .. category .. " > " .. name)
    end)
  end)
end

-- Read file content
function M._read_file(path)
  local file = io.open(path, "r")
  if not file then return "" end
  local content = file:read("*a")
  file:close()
  return content
end

-- Write content to file
function M._write_file(path, content)
  local file = io.open(path, "w")
  if not file then
    vim.notify("Failed to save template: " .. path, vim.log.levels.ERROR)
    return
  end
  file:write(content)
  file:close()
end

return M

