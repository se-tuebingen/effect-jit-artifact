from rpyeffect.interpreter import interpret
from rpyeffect.parse import load_program
from rpyeffect.primitives import Primitives
from rpyeffect.program import EMPTY_PROGRAM, NAME_OF_ENTRYPOINT
from rpyeffect.dynlib import LoadedLib
from rpyeffect.util.path import abspath

from timeit import default_timer
import os

def entry_point(argv):
    primitives = Primitives()
    benchmark, bm_prefix, bm_repetitions, bm_out = False, "", 1, ""
    firstarg = 1
    while len(argv) > firstarg and argv[firstarg].startswith('-'):
        if argv[firstarg] == "--benchmark":
            bm_prefix = argv[firstarg+1]
            bm_repetitions = int(argv[firstarg+2])
            bm_out = argv[firstarg+3]
            firstarg += 3
            benchmark = True
        if argv[firstarg] == "--check":
            if len(argv)-1 == firstarg:
                # check needs to be the last argument (for now)
                # This will later allow us to specifiy, e.g., feature-flags.
                print("OK")
                return 0
            else:
                print("Unsupported: %s" % (" ".join(argv[firstarg+1:])))
                return 78 # EX_CONFIG
        firstarg += 1

    if firstarg >= len(argv):
        primitives.print_stderr("Please supply a source filename")
        return 64 # EX_USAGE

    source_file = argv[firstarg]

    if not os.path.exists(source_file):
        primitives.print_stderr("File %s does not exist." % source_file)
        return 74 # EX_IOERR

    program = EMPTY_PROGRAM
    primitives.script_name = source_file
    primitives.real_script_name = abspath(source_file)
    #try:
    program = load_program(source_file, 0, primitives)

    if program is None:
        primitives.print_stderr("Could not parse %s" % source_file)
        return 64 # EX_USAGE

    if NAME_OF_ENTRYPOINT not in program.symbols:
        primitives.print_stderr("File %s is not an executable, but a library" % source_file)
        return 64 # EX_USAGE
    
    program.loaded_libs[primitives.real_script_name] = LoadedLib(primitives.real_script_name, 0, program.symbols)
    #except Exception as e:
    #    primitives.panic("Loading program failed: " + str(e))
    #    return 255

    args = [argv[i] for i in range(firstarg+1, len(argv))]

    if not benchmark:
        # Run interpreter on program
        interpret(program, args, primitives)
        return 0
    else:
        # Benchmark the interpreter on program
        start = default_timer()
        interpret(program, args, primitives)
        warmup = default_timer()
        for r in range(bm_repetitions):
            interpret(program, args, primitives)
        end = default_timer()

        with open(bm_out, 'w') as o:
            o.write("[\n")
            o.write("{\"name\": \"%s%s %s %s\", \"value\": \"%f\", \"unit\": \"sec\"},\n" \
                    % (bm_prefix, source_file, args, "warmup", warmup-start))
            o.write("{\"name\": \"%s%s %s %s\", \"value\": \"%f\", \"unit\": \"sec\"}\n" \
                    % (bm_prefix, source_file, args, "run", (end-warmup)/bm_repetitions))
            o.write("]\n")

        # output benchmarking results
        return 0


def target(*args):
    return entry_point, None

if __name__ == "__main__":
    import sys
    sys.exit(entry_point(sys.argv))
