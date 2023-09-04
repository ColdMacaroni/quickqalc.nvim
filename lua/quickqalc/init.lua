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
}

-- Update the options.
---@param opts table
function M.setup(opts)
  M.opts = vim.tbl_deep_extend("force", M.opts, opts)
end

return M
