package.path = './smarr_are_we_fast_yet/benchmarks/Lua/?.lua;' .. package.path
local benchmark = require('nbody')
local inner_iterations = arg[1] + 0

local system = benchmark.NBodySystem.new()
for _ = 1, inner_iterations do
    system:advance(0.01)
end
print (string.format("%f", system:energy()))