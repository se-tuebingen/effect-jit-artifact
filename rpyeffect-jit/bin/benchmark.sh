#!/usr/bin/env bash
mkdir -p results
echo '[]' > results/$1_jit.json
echo '[]' > results/$1_nojit.json
ARCH=$(uname -m)
OS=$(uname -s)
while read args; do
    echo Generating jit logs...
    PYPYLOG="jit:results/$1_$args.log" out/bin/${ARCH}-${OS}/rpyeffect-jit test/$1 $args
    echo Timing executions...
    out/bin/${ARCH}-${OS}/rpyeffect-jit --benchmark jit 5 results/$1_${args}_jit.json test/$1 $args
    jq -s 'map(.[])' results/$1_jit.json results/$1_${args}_jit.json > results/$1_jit_new.json
    mv results/$1_jit_new.json results/$1_jit.json
    out/bin/${ARCH}-${OS}/rpyeffect-interpret --benchmark nojit 5 results/$1_${args}_nojit.json test/$1 $args
    jq -s 'map(.[])' results/$1_nojit.json results/$1_${args}_nojit.json > results/$1_nojit_new.json
    mv results/$1_nojit_new.json results/$1_nojit.json
done < "test/$1.args"
