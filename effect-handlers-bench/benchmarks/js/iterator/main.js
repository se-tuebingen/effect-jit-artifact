function* range(l, u) {
    while (l <= u) {
        yield l;
        l = l + 1;
    }
}

function run(n) {
    let s = 0;
    for (const r of range(0, n)) {
        s = s + r;
    }
    return s;
}

const args = process.argv.slice(2);
const n = parseInt(args[0], 10);
if (!isNaN(n)) {
    console.log(run(n));
} else {
    console.log(run(5));
}