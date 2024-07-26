let bm = require('./permute.js');

let benchmark = bm.newInstance();
let n = parseInt(process.argv[2], 10);

for (let i = 0; i < n - 1; i += 1) {
    benchmark.benchmark()
}
console.log(benchmark.benchmark())