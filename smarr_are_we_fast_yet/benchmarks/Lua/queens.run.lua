package.path = './smarr_are_we_fast_yet/benchmarks/Lua/?.lua;' .. package.path
local benchmark = require('queens')
local n = arg[1] - 1
for _ = 1, n do
    benchmark:benchmark()
end
if (benchmark:benchmark()) then print("True") else print("False") end

