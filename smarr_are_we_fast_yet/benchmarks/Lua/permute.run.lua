package.path = './smarr_are_we_fast_yet/benchmarks/Lua/?.lua;' .. package.path
local benchmark = require('permute')
local n = arg[1] - 1
for _ = 1, n do
    benchmark:benchmark()
end
print (benchmark:benchmark())

