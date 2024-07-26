let bm = require('./nbody.js');

let benchmark = bm.newInstance();
let n = parseInt(process.argv[2], 10);

const system = new bm.NBodySystem();
for (let i = 0; i < n; i += 1) {
    system.advance(0.01);
}
console.log(system.energy().toFixed(6));