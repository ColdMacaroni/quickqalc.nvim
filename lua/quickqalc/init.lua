local M = {}

-- Define library
local ffi = require "ffi"

ffi.cdef [[
  void init();
  const char *calculate(const char *expr, int timeout);
  void freeStr(const char *ptr);
]]

M._lib = ffi.load "./quickqalc.so"

-- NEEDS to be initialised
M._lib.init()

-- Converts the given char* to a lua string, then frees it
---@param cPtr ffi.cdata*
---@return string
function M._ptrToString(cPtr)
  local str = ffi.string(cPtr)
  M._lib.freeStr(cPtr)
  return str
end

-- Simple interface for calculation. Will create and free the c string.
---@param expr string The expression to calculate
---@return string result
function M.calculate(expr)
  return M._ptrToString(M._lib.calculate(ffi.new("const char *", expr), M.opts.timeout))
end

-- Helper function for killing the floating window and buffer.
---@param win any The nvim window
---@param buf any The nvim buffer
---@param go_insert boolean Whether to go into insert mode at the end
function M._endwin(win, buf, go_insert)
  vim.api.nvim_win_close(win, true)

  vim.api.nvim_buf_delete(buf, { force = true })
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + 1 })

  -- vim.cmd.stopinsert()

  if go_insert then
    vim.cmd.startinsert()
  end
end

-- Writes the text into the current line at the cursor's position.
-- Not sure if there's a better way
---@param text string The text to be inserted.
function M._into_line(text)
  -- Not sure if this is the best approach
  local line = vim.api.nvim_get_current_line()
  local pos = vim.api.nvim_win_get_cursor(0)

  local newline = line:sub(1, pos[2]) .. text .. line:sub(pos[2] + 1)
  vim.api.nvim_set_current_line(newline)

  vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + text:len() })
end

-- Creates a floating window at the cursor
---@param go_insert boolean If it should start insert mode after closing the popup (optional)
function M.popup(go_insert)
  if go_insert == nil then
    go_insert = vim.fn.mode() == "i"
  end

  local winopts = {
    width = 30,
    height = 1,
    relative = "cursor",
    anchor = "NE",
    col = 16,
    row = 1,
    style = "minimal",
    border = "rounded",
    title = "Qalculate",
    title_pos = "center",
  }

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, winopts)

  vim.bo.filetype = M.opts.filetype

  -- Create maps
  vim.keymap.set("i", "<Return>", function()
    local result = M.calculate(vim.api.nvim_get_current_line())
    M._endwin(win, buf, go_insert)
    M._into_line(result)
  end, { buffer = true })
  vim.keymap.set("i", "<Esc>", function()
    M._endwin(win, buf, go_insert)
  end, { buffer = true })

  -- Go into insert for convenience
  vim.cmd.startinsert()
end

-- Creates the nvim commands.
function M.createCmds()
  local cmd = vim.api.nvim_create_user_command
  -- Qalc
  cmd("Qalc", function(attrs)
    local expr = attrs.args
    if expr == "" then
      expr = vim.fn.input { prompt = M.opts.prompt }
      -- Clear command line before printing.
      vim.cmd.redraws { bang = true }
    end

    if expr then
      local result = M.calculate(expr)
      print(result)
    end
  end, { nargs = "*", bang = true })
end

-- Default options
M.opts = {
  -- Time in milliseconds before a calculation is stopped.
  timeout = 2000,

  -- Prompt when running :Qalc without arguments
  prompt = "Qalc> ",

  -- Should it create :Commands
  create_commands = true,

  -- The filetype of the popup window
  filetype = "qalc",
}

-- Update the options.
---@param opts table
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts)

  if M.opts.create_commands then
    M.createCmds()
  end
end

return M
