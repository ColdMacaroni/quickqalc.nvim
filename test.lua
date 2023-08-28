local ffi = require "ffi"

ffi.cdef [[
  void init();
  const char *calculate(const char *expr, int timeout);
  void freeStr(const char *ptr);
]]

local lib = ffi.load "./quickqalc.so"

lib.init()

-- Converts the given pointer to a lua string and then frees it.
local function toLuaString(cPtr)
  local str = ffi.string(cPtr)
  lib.freeStr(cPtr)
  return str
end

-- Wrapper around string conversion
local function calculate(expr)
  return toLuaString(lib.calculate(ffi.new("const char *", expr), 2000))
end
