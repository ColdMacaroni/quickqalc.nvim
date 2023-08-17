local ffi = require("ffi")

ffi.cdef[[
    void hi();
]]

local lib = ffi.load("./quickqalc.so")

lib.hi()
