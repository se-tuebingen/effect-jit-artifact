class Get {}
const GET = new Get();
class Set {
    constructor(value) {
        this.value = value;
    }
}

function* countdown() {
    let i = yield GET;
    while (i != 0) {
        yield new Set(i - 1);
        i = yield GET;
    };
    return i
}

function run(n) {
    let s = n;
    let it = countdown();
    let result = it.next();
    while(true) {
        if (result.value == GET) {
            result = it.next(s);
        } else if (result.value instanceof Set) {
            s = result.value.value;
            result = it.next();
        } else if (result.done) {
            return result.value;
        }
    }
}

let args;
if (typeof process !== "undefined") {
    args = process.argv.slice(2);
} else if (typeof scriptArgs !== "undefined") { 
    args = scriptArgs;
} else {
    console.error("Don't know how to get cli args");
}
const n = parseInt(args[0], 10);
if (!isNaN(n)) {
    console.log(run(n));
} else {
    console.log(run(5));
}
