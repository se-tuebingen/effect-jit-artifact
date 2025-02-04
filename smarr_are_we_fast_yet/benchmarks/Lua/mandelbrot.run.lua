package.path = './smarr_are_we_fast_yet/benchmarks/Lua/?.lua;' .. package.path
local _mandelbrot
if _VERSION < 'Lua 5.3' then
    _mandelbrot = require 'mandelbrot-fn'
else
    _mandelbrot = require 'mandelbrot-fn-53'
end
local n = arg[1] + 0
print (_mandelbrot(n))

