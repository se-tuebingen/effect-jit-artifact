from rpython.rlib.jit import promote_string, promote, unroll_safe, elidable, we_are_jitted
from rpython.rlib.rrandom import Random
from rpython.rlib.rarithmetic import intmask
from rpython.rlib.objectmodel import we_are_translated
from rpython.rlib import rfile
from rpyeffect.types import *
from rpyeffect.stack import fresh_label
from rpyeffect.dynlib import load_lib
from rpyeffect.environment import Environment
from rpyeffect.region import Ref, Ref
from timeit import default_timer
import math
from rpyeffect.util.path import abspath, dirname
from rpyeffect.util.debug import debug, debug_hooks
from rpyeffect.util.interned import InternTable
import rpyeffect.config as cfg
from rpyeffect.representations import encode_str
from rpyeffect.value import ValueNull
from rpyeffect.instructions import ALLOCATE

LINE_BUFFER_LENGTH = 1024


class _State(object): pass
class _KnownPtr(_State):
    _immutable_fields_ = ['val_ptr']
    def __init__(self, val_ptr):
        self.val_ptr = val_ptr
class _NonConst(_State): pass
class _Version(object): pass

class Primitives(object):
    _immutable_fields_ = ['real_script_name?', 'args?', 'args_erased[*]?', 'intern_table', '_ptr_cache_version?']
    def __init__(self):
        self.script_name = None
        self.real_script_name = None
        
        self.rnd = Random(int(default_timer()*100000000) % 1000000)
        self.rnd.jumpahead(10)

        self.stdin, self.stdout, self.stderr = rfile.create_stdio()

        self.args = []
        self.args_erased = []

        self.intern_table = InternTable()
        self._ptr_cache = {}
        self._ptr_cache_version = _Version()

    @elidable
    def _get_ptr_cache(self, pc_block, pc_instruction, _version):
        assert _version is self._ptr_cache_version
        if (pc_block, pc_instruction) in self._ptr_cache:
            return self._ptr_cache[(pc_block, pc_instruction)]
        else:
            return None

    def _set_ptr_cache(self, pc_block, pc_instruction, val):
        self._ptr_cache_version = _Version()
        self._ptr_cache[(pc_block, pc_instruction)] = val

    def parse_args(self, args):
        self.args = promote(args)
        self.args_erased = [encode_str(arg) for arg in args]

    def run_primitive(self, env, opid, ins, outs, program, pc_block, pc_instruction, metastack, stack, stack_label, stack_binding):
        #opid = promote_string(name) # should be const
        debug_hooks.run_primitive(opid, ins, outs)

        if opid == "nop(): Unit":
            pass

        elif opid == "println(Int): Unit / Console" or opid == "println(Int): Unit":
            print(env.get_int(ins.regs[NUMBER][0]))

        elif opid == "println(Boolean): Unit / Console" or opid == "println(Boolean): Unit":
            if env.get_bool(ins.regs[NUMBER][0]):
                print("true")
            else:
                print("false")

        elif opid == "println(Unit): Unit / Console" or opid == "println(Unit): Unit":
            print("()")

        elif opid == "println(String): Unit / Console" or opid == "println(String): Unit":
            print(env.get_str(ins.regs[OPAQUE_PTR][0]))

        elif opid == "print(String): Unit":
            self.stdout.write(env.get_str(ins.regs[OPAQUE_PTR][0]))
            self.stdout.flush()

        elif opid == "infixAdd(Int, Int): Int":
            env.set_int(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) + env.get_int(ins.regs[NUMBER][1]))

        elif opid == "infixMul(Int, Int): Int":
            env.set_int(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) * env.get_int(ins.regs[NUMBER][1]))

        elif opid == "infixDiv(Int, Int): Int":
            num = env.get_int(ins.regs[NUMBER][0])
            denom = env.get_int(ins.regs[NUMBER][1])
            if denom == 0:
                if len(outs.regs[NUMBER]) > 1:
                    env.set_bool(outs.regs[NUMBER][1], False)
            else:
                if len(outs.regs[NUMBER]) > 1:
                    env.set_bool(outs.regs[NUMBER][1], True)
                env.set_int(outs.regs[NUMBER][0], num / denom)

        elif opid == "infixSub(Int, Int): Int":
            env.set_int(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) - env.get_int(ins.regs[NUMBER][1]))

        elif opid == "mod(Int, Int): Int":
            num = env.get_int(ins.regs[NUMBER][0])
            denom = env.get_int(ins.regs[NUMBER][1])
            if denom == 0:
                if len(outs.regs[NUMBER]) > 1:
                    env.set_bool(outs.regs[NUMBER][1], False)
            else:
                if len(outs.regs[NUMBER]) > 1:
                    env.set_bool(outs.regs[NUMBER][1], True)
                env.set_int(outs.regs[NUMBER][0], num % denom)

        elif opid == "abs(Int): Int":
            env.set_int(outs.regs[NUMBER][0], abs(env.get_int(ins.regs[NUMBER][0])))

        elif opid == "infixEq(Int, Int): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) == env.get_int(ins.regs[NUMBER][1]))

        elif opid == "infixNeq(Int, Int): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) != env.get_int(ins.regs[NUMBER][1]))

        elif opid == "infixLt(Int, Int): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) < env.get_int(ins.regs[NUMBER][1]))

        elif opid == "infixLte(Int, Int): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) <= env.get_int(ins.regs[NUMBER][1]))

        elif opid == "infixGt(Int, Int): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) > env.get_int(ins.regs[NUMBER][1]))

        elif opid == "infixGte(Int, Int): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) >= env.get_int(ins.regs[NUMBER][1]))

        elif opid == "println(Double): Unit / Console" or opid == "println(Double): Unit":
            print(env.get_double(ins.regs[NUMBER][0]))

        elif opid == "infixAdd(Double, Double): Double":
            env.set_double(outs.regs[NUMBER][0], env.get_double(ins.regs[NUMBER][0]) + env.get_double(ins.regs[NUMBER][1]))

        elif opid == "infixMul(Double, Double): Double":
            env.set_double(outs.regs[NUMBER][0], env.get_double(ins.regs[NUMBER][0]) * env.get_double(ins.regs[NUMBER][1]))

        elif opid == "infixDiv(Double, Double): Double":
            num = env.get_double(ins.regs[NUMBER][0])
            denom = env.get_double(ins.regs[NUMBER][1])
            if denom == 0:
                if len(outs.regs[NUMBER]) > 1:
                    env.set_bool(outs.regs[NUMBER][1], False)
            else:
                if len(outs.regs[NUMBER]) > 1:
                    env.set_bool(outs.regs[NUMBER][1], True)
                env.set_double(outs.regs[NUMBER][0], num / denom)

        elif opid == "infixSub(Double, Double): Double":
            env.set_double(outs.regs[NUMBER][0], env.get_double(ins.regs[NUMBER][0]) - env.get_double(ins.regs[NUMBER][1]))

        elif opid == "mod(Double, Double): Double":
            num = env.get_double(ins.regs[NUMBER][0])
            denom = env.get_double(ins.regs[NUMBER][0]) 
            if denom == 0.0:
                if len(outs.regs[NUMBER]) > 1:
                    env.set_bool(outs.regs[NUMBER][1], False)
            else:
                if len(outs.regs[NUMBER]) > 1:
                    env.set_bool(outs.regs[NUMBER][1], True)
                env.set_double(outs.regs[NUMBER][0], math.fmod(num, denom))

        elif opid == "abs(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.fabs(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "infixEq(Double, Double): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_double(ins.regs[NUMBER][0]) == env.get_double(ins.regs[NUMBER][1]))

        elif opid == "infixNeq(Double, Double): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_double(ins.regs[NUMBER][0]) != env.get_double(ins.regs[NUMBER][1]))

        elif opid == "infixLt(Double, Double): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_double(ins.regs[NUMBER][0]) < env.get_double(ins.regs[NUMBER][1]))

        elif opid == "infixLte(Double, Double): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_double(ins.regs[NUMBER][0]) <= env.get_double(ins.regs[NUMBER][1]))

        elif opid == "infixGt(Double, Double): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_double(ins.regs[NUMBER][0]) > env.get_double(ins.regs[NUMBER][1]))

        elif opid == "infixGte(Double, Double): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_double(ins.regs[NUMBER][0]) >= env.get_double(ins.regs[NUMBER][1]))

        elif opid == "cos(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.cos(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "acos(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.acos(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "sin(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.sin(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "asin(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.asin(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "atan(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.atan(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "tan(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.tan(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "cosh(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.cosh(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "acosh(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.acosh(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "sinh(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.sinh(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "asinh(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.asinh(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "atanh(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.atanh(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "tan(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.tan(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "sqrt(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.sqrt(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "log(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.log(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "log1p(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.log1p(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "exp(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.exp(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "log10(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.log10(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "atan2(Double, Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.atan2(env.get_double(ins.regs[NUMBER][0]), env.get_double(ins.regs[NUMBER][0])))

        elif opid == "floor(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.floor(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "ceil(Double): Double":
            env.set_double(outs.regs[NUMBER][0], math.ceil(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "toInt(Double): Int":
            env.set_int(outs.regs[NUMBER][0], int(env.get_double(ins.regs[NUMBER][0])))

        elif opid == "toDouble(Int): Double":
            env.set_double(outs.regs[NUMBER][0], float(env.get_int(ins.regs[NUMBER][0])))

        elif opid == "not(Boolean): Boolean":
            env.set_bool(outs.regs[NUMBER][0], not env.get_bool(ins.regs[NUMBER][0]))

        elif opid == "infixEq(Boolean, Boolean): Boolean":
            env.set_bool(outs.regs[NUMBER][0], (env.get_bool(ins.regs[NUMBER][0])) == (env.get_bool(ins.regs[NUMBER][1])))

        elif opid == "infixOr(Boolean, Boolean): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_bool(ins.regs[NUMBER][0]) or env.get_bool(ins.regs[NUMBER][1]))

        elif opid == "infixAnd(Boolean, Boolean): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_bool(ins.regs[NUMBER][0]) and env.get_bool(ins.regs[NUMBER][1]))

        elif opid == "infixConcat(String, String): String":
            env.set_str(outs.regs[OPAQUE_PTR][0], env.get_str(ins.regs[OPAQUE_PTR][0]) + env.get_str(ins.regs[OPAQUE_PTR][1]))

        elif opid == "infixEq(String, String): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_str(ins.regs[OPAQUE_PTR][0]) == env.get_str(ins.regs[OPAQUE_PTR][1])) 

        elif opid == "infixNeq(String, String): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_str(ins.regs[OPAQUE_PTR][0]) != env.get_str(ins.regs[OPAQUE_PTR][1]))

        elif opid == "infixLt(String, String): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_str(ins.regs[OPAQUE_PTR][0]) < env.get_str(ins.regs[OPAQUE_PTR][1]))

        elif opid == "infixLte(String, String): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_str(ins.regs[OPAQUE_PTR][0]) <= env.get_str(ins.regs[OPAQUE_PTR][1]))

        elif opid == "infixGt(String, String): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_str(ins.regs[OPAQUE_PTR][0]) > env.get_str(ins.regs[OPAQUE_PTR][1]))

        elif opid == "infixGte(String, String): Boolean":
            env.set_bool(outs.regs[NUMBER][0], env.get_str(ins.regs[OPAQUE_PTR][0]) >= env.get_str(ins.regs[OPAQUE_PTR][1]))

        elif opid == "show(Int): String":
            env.set_str(outs.regs[OPAQUE_PTR][0], ("%d" % (env.get_int(ins.regs[NUMBER][0]))))

        elif opid == "show(Double): String":
            env.set_str(outs.regs[OPAQUE_PTR][0], ("%f" % (env.get_double(ins.regs[NUMBER][0]))))

        elif opid == "show(Boolean): String":
            if env.get_bool(ins.regs[NUMBER][0]):
                env.set_str(outs.regs[OPAQUE_PTR][0], "false")
            else:
                env.set_str(outs.regs[OPAQUE_PTR][0], "true")

        elif opid == "show(Any): String":
            env.set_str(outs.regs[OPAQUE_PTR][0], env.get_ptr(ins.regs[OPAQUE_PTR][0]).show())

        elif opid == "read(String): Int":
            s = env.get_str(ins.regs[OPAQUE_PTR][0])
            v = 0
            e = True
            try:
                v = int(s)
            except ValueError:
                e = False
            if len(outs.regs[NUMBER]) > 1:
                env.set_bool(outs.regs[NUMBER][1], e)
            env.set_int(outs.regs[NUMBER][0], v)
        
        elif opid == "read(String, Int): Int":
            s = env.get_str(ins.regs[OPAQUE_PTR][0])
            v = 0
            base = env.get_int(ins.regs[NUMBER][1])
            e = True
            try:
                if base == 0:
                    # Detect by c-style int literal prefixes
                    if s.startswith("0b"):
                        v = int(s[2:], 2)
                    elif s.startswith("0x"):
                        v = int(s[2:], 16)
                    elif s.startswith("0"):
                        v = int(s[1:], 8)
                    else:
                        v = int(s, 10)
                else:
                    v = int(s, base)
            except ValueError as x:
                e = False
            if len(outs.regs[NUMBER]) > 1:
                env.set_bool(outs.regs[NUMBER][1], e)
            env.set_int(outs.regs[NUMBER][0], v)

        elif opid == "read(String): Double":
            s = env.get_str(ins.regs[OPAQUE_PTR][0])
            v = 0.0
            e = True
            try:
                v = float(s)
            except ValueError:
                e = False
            if len(outs.regs[NUMBER]) > 1:
                env.set_bool(outs.regs[NUMBER][1], e)
            env.set_double(outs.regs[NUMBER][0], v)

        elif opid == "read(String): Boolean":
            s = env.get_str(ins.regs[OPAQUE_PTR][0])
            e = True
            if s == "false":
                env.set_bool(outs.regs[NUMBER][0], False)
            elif s == "true":
                env.set_bool(outs.regs[NUMBER][0], True)
            else:
                e = False
                env.set_bool(outs.regs[NUMBER][0], True)
            if len(outs.regs[NUMBER]) > 1:
                env.set_bool(outs.regs[NUMBER][1], e)

        elif opid == "random(): Int":
            env.set_int(outs.regs[NUMBER][0], intmask(self.rnd.genrand32()))

        elif opid == "random(): Double":
            env.set_double(outs.regs[NUMBER][0], intmask(self.rnd.random()))

        elif opid == "currentTimeNanos(): Int":
            env.set_int(outs.regs[NUMBER][0], int(default_timer()*1000000000))

        elif opid == "readLn(): String / Console" or opid == "readLn(): String":
            i = self.stdin.readline(LINE_BUFFER_LENGTH)
            env.set_str(outs.regs[OPAQUE_PTR][0], i)

        elif opid == "readInt(): Int / Console" or opid == "readInt(): Int":
            i = self.stdin.readline(LINE_BUFFER_LENGTH)
            v = 0
            e = True
            try:
                v = int(i)
            except ValueError:
                e = False
            if len(outs.regs[NUMBER]) > 1:
                env.set_bool(outs.regs[NUMBER][1], e)
            env.set_int(outs.regs[NUMBER][0], v)

        elif opid == "exit(Int): Void":
            self.exit(env.get_int(ins.regs[NUMBER][0]))

        elif opid == "printlnErr(String): Unit":
            self.print_stderr(env.get_str(ins.regs[OPAQUE_PTR][0]))

        elif opid == "get_argc(): Int":
            env.set_int(outs.regs[NUMBER][0], len(self.args))

        elif opid == "get_arg(Int): String":
            index = env.get_int(ins.regs[NUMBER][0])
            if index < len(self.args) and index >= 0:
                env.set_str(outs.regs[OPAQUE_PTR][0], self.args[index])
            else:
                self.panic("Out-of-bounds access to command line arguments")

        elif opid == "length(String): Int":
            env.set_int(outs.regs[NUMBER][0], len(env.get_str(ins.regs[OPAQUE_PTR][0])))

        elif opid == "substring(String, Int, Int): String":
            start = env.get_int(ins.regs[NUMBER][1])
            end = env.get_int(ins.regs[NUMBER][2])
            s = env.get_str(ins.regs[OPAQUE_PTR][0])
            if start < 0 or end < 0 or end < start:
                self.panic("Invalid call substring(s, %d, %d) on string s of length %d" % (start, end, len(s)))
            assert(start >= 0)
            assert(end >= 0)
            env.set_str(outs.regs[OPAQUE_PTR][0], s[start:end])

        elif opid == "unsafeCharAt(String, Int): String":
            s = env.get_str(ins.regs[OPAQUE_PTR][0])
            i = env.get_int(ins.regs[NUMBER][1])
            if len(outs.regs[NUMBER]) > 1:
                env.set_bool(outs.regs[NUMBER][1], i >= 0 and i < len(s))
            assert(i >= 0)
            assert(i < len(s))
            env.set_str(outs.regs[OPAQUE_PTR][0], s[i])

        elif opid == "bytes(String): Bytes":
            env.set_bytearray(outs.regs[OPAQUE_PTR][0], bytearray(env.get_str(ins.regs[OPAQUE_PTR][0])))

        elif opid == "length(Bytes): Int":
            env.set_int(outs.regs[NUMBER][0], len(env.get_bytearray(ins.regs[OPAQUE_PTR][0])))

        elif opid == "unsafeIndex(Bytes, Int): Int":
            ba = env.get_bytearray(ins.regs[OPAQUE_PTR][0])
            i = env.get_int(ins.regs[NUMBER][1])
            if len(outs.regs[NUMBER]) > 1:
                env.set_bool(outs.regs[NUMBER][1], i <= len(ba))
            env.set_int(outs.regs[NUMBER][0], ba[i])

        elif opid == "unsafeGetFileContents(String): String":
            # TODO check if it actually works (exists, read failures)
            filename = env.get_str(ins.regs[OPAQUE_PTR][0])
            with open(filename) as f:
                env.set_str(outs.regs[OPAQUE_PTR][0], f.read())

        elif opid == "panic(String): Bottom":
            self.panic(env.get_str(ins.regs[OPAQUE_PTR][0]))

        elif opid == "freshlabel":
            env.set_label(outs.regs[OPAQUE_PTR][0], fresh_label(pc_block, pc_instruction))

        elif opid == "ptr_eq":
            env.set_bool(outs.regs[NUMBER][0], env.get_ptr(ins.regs[OPAQUE_PTR][0]) == env.get_ptr(ins.regs[OPAQUE_PTR][1]))

        elif opid == "getStdin(): InStream":
            env.set_instream(outs.regs[OPAQUE_PTR][0], self.stdin)

        elif opid == "getStdout(): OutStream":
            env.set_outstream(outs.regs[OPAQUE_PTR][0], self.stdout)

        elif opid == "getStderr(): OutStream":
            env.set_outstream(outs.regs[OPAQUE_PTR][0], self.stderr)

        elif opid == "openIn(String): InStream":
            env.set_instream(outs.regs[OPAQUE_PTR][0], open(env.get_str(ins.regs[OPAQUE_PTR][0]), "r"))

        elif opid == "closeIn(InStream): Unit":
            env.get_instream(ins.regs[OPAQUE_PTR][0]).close()

        elif opid == "openOut(String): OutStream":
            env.set_outstream(outs.regs[OPAQUE_PTR][0], open(env.get_str(ins.regs[OPAQUE_PTR][0]), "w"))

        elif opid == "closeOut(OutStream): Unit":
            env.get_outstream(ins.regs[OPAQUE_PTR][0]).close()

        elif opid == "write(OutStream, String): Unit":
            env.get_outstream(ins.regs[OPAQUE_PTR][0]).write(env.get_str(ins.regs[OPAQUE_PTR][1]))

        elif opid == "readInt(InStream): Int":
            s = env.get_instream(ins.regs[OPAQUE_PTR][0])
            env.set_int(outs.regs[NUMBER][0], int(s.readline(LINE_BUFFER_LENGTH)))

        elif opid == "readLine(InStream): String":
            s = env.get_instream(ins.regs[OPAQUE_PTR][0])
            env.set_str(outs.regs[OPAQUE_PTR][0], s.readline(LINE_BUFFER_LENGTH))

        elif opid == "read(InStream, Int): String":
            s = env.get_instream(ins.regs[OPAQUE_PTR][0])
            env.set_str(outs.regs[OPAQUE_PTR][0], s.read(env.get_int(ins.regs[NUMBER][0])))

        elif opid == "assertFalse(String): Void":
            if env.get_bool(ins.regs[NUMBER][0]):
                self.panic("Assertion failed: " + env.get_str(ins.regs[OPAQUE_PTR][0]))

        elif opid == "charAt(Int, String): String":
            s = env.get_str(ins.regs[OPAQUE_PTR][1])
            i = env.get_int(ins.regs[NUMBER][0])
            if i < 0 or i >= len(s):
                if len(outs.regs[NUMBER]) > 0:
                    env.set_bool(outs.regs[NUMBER][0], False)
                return
            if len(outs.regs[NUMBER]) > 0:
                env.set_bool(outs.regs[NUMBER][0], True)
            env.set_str(outs.regs[OPAQUE_PTR][0], s[i])

        elif opid == "compare(String, String): Int":
            s1 = env.get_str(ins.regs[OPAQUE_PTR][0])
            s2 = env.get_str(ins.regs[OPAQUE_PTR][1])
            if s1 == s2:
                env.set_int(outs.regs[NUMBER][0], 0)
            elif s1 < s2:
                env.set_int(outs.regs[NUMBER][0], -1)
            else:
                env.set_int(outs.regs[NUMBER][0], 1)
        
        elif opid == "repeat(Int, String): String":
            s = env.get_str(ins.regs[OPAQUE_PTR][1])
            n = env.get_int(ins.regs[NUMBER][0])
            env.set_str(outs.regs[OPAQUE_PTR][0], s * n)

        elif opid == "charCode(String): Int":
            s = env.get_str(ins.regs[OPAQUE_PTR][0])
            e = True
            if len(s) == 0:
                e = False
            else:
                env.set_int(outs.regs[NUMBER][0], ord(s[0]))
            if len(outs.regs[NUMBER]) > 1:
                env.set_bool(outs.regs[NUMBER][1], e)
        
        elif opid == "chr(Int): String":
            env.set_str(outs.regs[OPAQUE_PTR][0], chr(env.get_int(ins.regs[NUMBER][0])))

        elif opid == "neg(Int): Int":
            env.set_int(outs.regs[NUMBER][0], -env.get_int(ins.regs[NUMBER][0]))

        elif opid == "infixAnd(Int, Int): Int":
            env.set_int(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) & env.get_int(ins.regs[NUMBER][1]))

        elif opid == "infixOr(Int, Int): Int":
            env.set_int(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) | env.get_int(ins.regs[NUMBER][1]))

        elif opid == "xor(Int, Int): Int":
            env.set_int(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) ^ env.get_int(ins.regs[NUMBER][1]))

        elif opid == "lsl(Int, Int): Int" or opid == "asl(Int, Int): Int":
            env.set_int(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) << env.get_int(ins.regs[NUMBER][1]))

        elif opid == "lsr(Int, Int): Int":
            env.set_int(outs.regs[NUMBER][0], env.get_int(ins.regs[NUMBER][0]) >> env.get_int(ins.regs[NUMBER][1]))

        elif opid == "asr(Int, Int): Int":
            env.set_int(outs.regs[NUMBER][0], intmask(env.get_int(ins.regs[NUMBER][0]) >> env.get_int(ins.regs[NUMBER][1])))

        elif opid == "infixNot(Int): Int":
            env.set_int(outs.regs[NUMBER][0], ~env.get_int(ins.regs[NUMBER][0]))

        elif opid == "loadLibrary(String): Lib":
            self.stderr.write("primitive 'loadLibrary(String): Lib' is deprecated because it can't support static-init.")
            lib, _ = load_lib(program, promote_string(env.get_str(ins.regs[OPAQUE_PTR][0])), self)
            env.set_lib(outs.regs[OPAQUE_PTR][0], lib)

        elif opid == "getGlobal(String): Ptr":
            env.set_ptr(outs.regs[OPAQUE_PTR][0], program.get_global_ptr(env.get_str(ins.regs[OPAQUE_PTR][0])))
        elif opid == "getGlobal(String): Num":
            env.set_num(outs.regs[NUMBER][0], program.get_global_ptr(env.get_str(ins.regs[OPAQUE_PTR][0])))

        elif opid == "setGlobal(String, Ptr): Unit":
            name = env.get_str(ins.regs[OPAQUE_PTR][0])
            value = env.get_ptr(ins.regs[OPAQUE_PTR][1])
            debug("Setting global '%s' to '%s'" % (name, value))
            program.add_global_ptr(name, value)
        elif opid == "setGlobal(String, Num): Unit":
            program.add_global_num(env.get_str(ins.regs[OPAQUE_PTR][0]), env.get_num(ins.regs[NUMBER][0]))

        elif opid == "mkRef(Ptr): Ref[Ptr]" or opid == "mkRef(Num): Ref[Num]":
            self.panic("mkRef in parsed program. Should have been desugared while loading.")

        elif opid == "getRef(Ref[Ptr]): Ptr":
            r = env.get_ref(ins.regs[OPAQUE_PTR][0])
            assert isinstance(r, Ref)
            env.set_ptr(outs.regs[OPAQUE_PTR][0], r.get_ptr())
        elif opid == "getRef(Ref[Num]): Num":
            r = env.get_ref(ins.regs[OPAQUE_PTR][0])
            assert isinstance(r, Ref)
            env.set_num(outs.regs[NUMBER][0], r.get_ptr())

        elif opid == "setRef(Ref[Ptr], Ptr): Unit":
            r = env.get_ref(ins.regs[OPAQUE_PTR][0])
            assert isinstance(r, Ref)
            val = env.get_ptr(ins.regs[OPAQUE_PTR][1])
            r.put_ptr(val)
        elif opid == "setRef(Ref[Num], Num): Unit":
            r = env.get_ref(ins.regs[OPAQUE_PTR][0])
            assert isinstance(r, Ref)
            val = env.get_num(ins.regs[NUMBER][1])
            r.put_ptr(val)

        elif opid == "box(Num): Ptr":
            env.set_ptr(outs.regs[OPAQUE_PTR][0], env.get_num(ins.regs[NUMBER][0]))
        elif opid == "unbox(Ptr): Num":
            box = env.get_ptr(ins.regs[OPAQUE_PTR][0])
            env.set_num(outs.regs[NUMBER][0], box)

        elif opid == "divmod(Int, Int): Int, Int":
            a = env.get_int(ins.regs[NUMBER][0])
            b = env.get_int(ins.regs[NUMBER][1])
            d, m = a // b, a % b # FIXME is there a better way?
            env.set_int(outs.regs[NUMBER][0], d)
            env.set_int(outs.regs[NUMBER][1], m)

        elif opid == "getArgs(): Array[String]":
            env.set_array(outs.regs[OPAQUE_PTR][0], self.args_erased)

        elif opid == "length(Array[Ptr]): Int":
            env.set_int(outs.regs[NUMBER][0], len(env.get_array(ins.regs[OPAQUE_PTR][0])))

        elif opid == "unsafeIndex(Array[Ptr], Int): Ptr":
            arr = env.get_array(ins.regs[OPAQUE_PTR][0])
            i = env.get_int(ins.regs[NUMBER][1])
            env.set_ptr(outs.regs[OPAQUE_PTR][0], arr[i])

        elif opid == "allocate(Int): Array[Top]":
            arr = [ValueNull()] * env.get_int(ins.regs[NUMBER][0])
            env.set_array(outs.regs[OPAQUE_PTR][0], arr)

        elif opid == "unsafeSet(Array[Top], Int, Top): Unit":
            arr = env.get_array(ins.regs[OPAQUE_PTR][0])
            idx = env.get_int(ins.regs[NUMBER][1])
            nv = env.get_ptr(ins.regs[OPAQUE_PTR][2])
            arr[idx] = nv

        elif opid == "equals(Any, Any): Bool":
            l = env.get_ptr(ins.regs[OPAQUE_PTR][0])
            r = env.get_ptr(ins.regs[OPAQUE_PTR][1])
            env.set_bool(outs.regs[OPAQUE_PTR][0], l.equals(r))

        elif opid == "compare(Any, Any): Int":
            l = env.get_ptr(ins.regs[OPAQUE_PTR][0])
            r = env.get_ptr(ins.regs[OPAQUE_PTR][1])
            env.set_int(outs.regs[NUMBER][0], l.compare(r))

        elif opid == "infixLt(Any, Any): Bool":
            l = env.get_ptr(ins.regs[OPAQUE_PTR][0])
            r = env.get_ptr(ins.regs[OPAQUE_PTR][1])
            env.set_bool(outs.regs[OPAQUE_PTR][0], l.compare(r) < 0)

        elif opid == "infixGt(Any, Any): Bool":
            l = env.get_ptr(ins.regs[OPAQUE_PTR][0])
            r = env.get_ptr(ins.regs[OPAQUE_PTR][1])
            env.set_bool(outs.regs[OPAQUE_PTR][0], l.compare(r) > 0)

        elif opid == "infixLte(Any, Any): Bool":
            l = env.get_ptr(ins.regs[OPAQUE_PTR][0])
            r = env.get_ptr(ins.regs[OPAQUE_PTR][1])
            env.set_bool(outs.regs[OPAQUE_PTR][0], l.compare(r) <= 0)

        elif opid == "infixGte(Any, Any): Bool":
            l = env.get_ptr(ins.regs[OPAQUE_PTR][0])
            r = env.get_ptr(ins.regs[OPAQUE_PTR][1])
            env.set_bool(outs.regs[OPAQUE_PTR][0], l.compare(r) >= 0)

        elif opid == "promote_ptr":
            p = env.get_ptr(ins.regs[OPAQUE_PTR][0])
            c = self._get_ptr_cache(pc_block, pc_instruction, self._ptr_cache_version)
            if c is None:
                if not we_are_jitted():
                    self._set_ptr_cache(pc_block, pc_instruction, _KnownPtr(p))
            elif isinstance(c, _KnownPtr):
                if c.val_ptr == p:
                    p = promote(p)
                else:
                    self._set_ptr_cache(pc_block, pc_instruction, _NonConst())
            env.set_ptr(outs.regs[OPAQUE_PTR][0], p)
        elif opid == "promote_num":
            env.set_num(outs.regs[NUMBER][0], promote(env.get_num(ins.regs[NUMBER][0])))

        else:
            self.panic("Unsupported primitive operation %s" % (opid))

    def input(self, prompt):
        self.stdout.write(prompt)
        self.stdout.flush()
        return self.stdin.readline(LINE_BUFFER_LENGTH)

    def exit(self, exit_code):
        from rpython.rlib.rposix import exit
        exit(exit_code)

    def print_stderr(self, output):
        self.stderr.write(output)
        self.stderr.write("\n")
        self.stderr.flush()

    def panic(self, msg):
        self.print_stderr("PANIC: " + msg)
        self.exit(1)

    def resolve_path(self, path):
        base = dirname(self.real_script_name) if self.real_script_name is not None else abspath(".")
        if path[0:2] == "$0":
            path = base + path[2:]
        return abspath(path)

    def intern(self, str):
        return self.intern_table.intern(str)
