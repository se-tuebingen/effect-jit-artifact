class Read {}
const READ = new Read();

class Emit {
    constructor(e) {
        this.e = e;
    }
}

class Stop {}
const STOP = new Stop();

function newline() { return 10; }
function isNewline(c) { return c == 10; }
function dollar() { return 36; }
function isDollar(c) { return c == 36; }

function* parse(a) {
    while (true) {
        let c = yield READ;
        if (isDollar(c)) {
            a = a + 1;
        } else if (isNewline(c)) {
            yield new Emit(a);
            a = 0;
        } else {
            throw STOP;
        }
    }
}

function sum(action) {
    let s = 0;
    for(const e of action()) {
        // assert(e instanceof Emit);
        s = s + e.e;
    }
    return s;
}

function* ctch(action) {
    try {
        yield* action();
    } catch (e) {
        // assert(e === STOP);
        return;
    }
}

function* feed(n, action) {
    let i = 0;
    let j = 0;
    let it = action();
    let r = it.next();
    while (true) {
        if (r.value === READ) {
            if (i > n) {
                throw STOP;
            } else if (j === 0) {
                i = i + 1;
                j = i;
                r = it.next(newline());
            } else {
                j = j - 1;
                r = it.next(dollar());
            }
        } else if (r.done) {
            return r.value;
        } else { 
            r = it.next(yield r.value); // needs to re-yield Emits
        }
    }
}

function run(n) {
    return sum(function* () {
        yield* ctch(function* () {
            yield* feed(n, function* () {
                yield* parse(0);
            });
        });
    });
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