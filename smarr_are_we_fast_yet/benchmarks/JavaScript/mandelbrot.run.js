let bm = require('./mandelbrot.js');

let benchmark = bm.newInstance();
let n = parseInt(process.argv[2], 10);

console.log(benchmark.mandelbrot(n))