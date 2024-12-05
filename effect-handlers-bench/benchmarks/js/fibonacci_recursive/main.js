function fibonacci(n) {
    if (n == 0) {
        return 0;
    } else if (n == 1) {
        return 1;
    } else {
        return fibonacci(n - 1) + fibonacci(n - 2);
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
    console.log(fibonacci(n));
} else {
    console.log(fibonacci(5));
}