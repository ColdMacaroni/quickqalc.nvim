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

-------------
--  Tests  --
-------------
-- NOTE: This does not(!) check for ANSI color support.
local function check(name, expr, result)
  local ret = calculate(expr)
  if ret == result then
    print("[1;32mPassed[0m " .. name)
  else
    print(
      "[1;31mFailed[0m "
        .. name
        .. ": Expression '"
        .. expr
        .. "' returned '"
        .. ret
        .. "' instead of '"
        .. result
        .. "'"
    )
  end
end

check("Simple operation #1", "1+1", "2")
check("Simple operation #2", "2 + 6 + 20", "28")
check("Simple operation #3", "10-12", "-2")
check("Simple operation #4", "10*12", "120")
check("Simple operation #5", "34234*21234", "726924756")
check("Simple operation #6", "234/12", "19.5")
check("Algebra #1", "x + 23 = 26", "x = 3")
check("Algebra #2", "x ^ 2 + 5x - 6 = 0", "x = 1 || x = -6")
check("Units #1", "1 Watt * 1 Second", "1 J")
check("Units #2", "10 Ohm * 1 Amp", "10 V")
check("Function #1", "log10(300)", "interval(2.4771212, 2.4771213)")
-- Begin examples from libqalculate's github
check(
  "Function #2",
  "integrate(sinh(x^2)/(5x) + 3xy/sqrt(x))",
  "2x * sqrt(x) * y + 0.1 * Shi(x^2) + C"
)
check("Conversion #1 [Unicode] ", "0xD8 to unicode", "Ø")
check("Conversion #2 [Unicode]", "code(Ø) to hex", "0xD8")
check("Conversion #3 [Binary]", "52 to bin", "0011 0100")
-- End examples
check("Empty", "", "0")
check("Timeout", "500000000000000!", "factorial(5E14)")
