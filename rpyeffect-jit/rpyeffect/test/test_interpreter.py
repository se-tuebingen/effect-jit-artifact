from rpyeffect.instructions import *
from rpyeffect.interpreter import *
from rpyeffect.program import *
from rpyeffect.types import *
from rpyeffect.primitives import Primitives
from rpyeffect.data import *
from rpyeffect.stack import *
from rpyeffect.representations import *
import pytest

@pytest.fixture(autouse=True)
def run_around_tests():
    jitdriver._store_last_enter_jit = None

# TODO rewrite tests instead
STRING,CODATA,CONT,ALGEBRAIC_DT,REF,REGION = (OPAQUE_PTR,) * 6
INT,DOUBLE,BOOL = (NUMBER,) * 3
def CONST_INT(reg, val): return CONST_PTR(reg, encode_int(val), "int")
def CONST_DOUBLE(reg, val): return CONST_PTR(reg, encode_double(val), "double")
def CONST_STRING(reg, val): return CONST_PTR(reg, encode_str(val), "string")

def frame_descriptor_for(register_types):
    res = [0] * NUMBER_OF_TYPES
    for reg in register_types:
        res[reg] +=1
    return res
def mk_args(args_with_types):
    res = [[]] * NUMBER_OF_TYPES
    for ty in range(NUMBER_OF_TYPES):
        res[ty] = list()
    for arg in args_with_types:
        ty, idx = arg
        res[ty].append(idx)
    return res
def stack_shape(s):
    if s is None:
        return []
    elif isinstance(s, Stack):
        r = stack_shape(s.tail)
        r.insert(0, (s.target, [(s.len_ptr())]))
        return r
def metastack_shape(ms):
    if ms is None:
        return []
    elif isinstance(ms, MetaStack):
        r = metastack_shape(ms.tail)
        r.insert(0, stack_shape(ms.stack))
        return r

class TestExit(DEBUG, object):
    def __init__(self):
        super(TestExit, self).__init__("Test exit", [])
class TestProgram(Program):
    def is_end(self, pc_block, pc_instruction):
        return super(TestProgram, self).is_end(pc_block, pc_instruction) or isinstance(self.get_instruction(pc_block, pc_instruction), TestExit)

def test_const():
    fd = frame_descriptor_for([INT, DOUBLE, STRING])
    double = 2.7
    string = "Hallo"
    _, _, e = interpret(TestProgram([Block('main', [
        CONST_INT(0, 5),
        CONST_DOUBLE(1, double),
        CONST_STRING(2, string),
        TestExit()
    ], fd)], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(0) == 5
    assert e.get_double(1) == double
    assert e.get_str(2) == string

def test_add():
    fd = frame_descriptor_for([INT,INT,INT])
    _, _, e = interpret(TestProgram([Block('main', [
        CONST_INT(0, 2),
        CONST_INT(1, 5),
        ADD(2, 0, 1),
        TestExit()
    ], fd)], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(2) == 7

def test_mul():
    fd = frame_descriptor_for([INT,INT,INT])
    _, _, e = interpret(TestProgram([Block('main', [
        CONST_INT(0, 2),
        CONST_INT(1, 3),
        PRIM_OP("infixMul(Int, Int): Int", [[2],[]], [[0, 1],[]]),
        TestExit()
    ], fd)], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(2) == 6

def test_simple():
    fd = frame_descriptor_for([INT,INT,INT])
    ms, s, e = interpret(TestProgram([Block('main', [
        CONST_INT(0, 12),
        CONST_INT(1, 2),
        ADD(2, 1, 0),
        TestExit()
    ], fd)], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(2) == 14

def test_push():
    fd = frame_descriptor_for([INT,INT])
    ms, s, e = interpret(TestProgram([
        Block('main', [
            CONST_INT(0, 12),
            CONST_INT(1, 2),
            JUMP(1)
        ], fd),
        Block('l0', [
            PUSH(1, mk_args([(INT,0)])),
            TestExit()
        ], fd),
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert stack_shape(s) == [(1,[1])]
    assert metastack_shape(ms) == []
    assert s.get_int(0) == 12

def test_push_return():
    fd = frame_descriptor_for([INT])
    ms, s, e = interpret(TestProgram([
        Block("main", [
            CONST_INT(0, 42),
            PUSH(1, mk_args([])),
            RETURN(mk_args([(INT,0)]))
        ], [1,0,0]),
        Block("fn", [RETURN(mk_args([(INT,0)]))], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert stack_shape(s) == []
    assert metastack_shape(ms) == []
    assert e.get_int(0) == 42

def test_reset():
    fd = frame_descriptor_for([OPAQUE_PTR])
    p = TestProgram([
        Block("main", [
            PRIM_OP("freshlabel", mk_args([(OPAQUE_PTR, 0)]), []),
            PUSH(1, mk_args([])),
            NEW_STACK(0, 2, -1, mk_args([]), 0),
            PUSH_STACK(0),
            TestExit()
        ], fd),
        Block("tag1", [], fd),
        Block("tag2", [], fd)
    ], fd, DEFAULT_SYMBOLS)
    ms, s, e = interpret(p, [], Primitives())
    assert stack_shape(s) == [(2,[0])]
    assert metastack_shape(ms) == [[(1,[0])]]

def test_reset_shiftdyn():
    fd = frame_descriptor_for([CONT,INT,OPAQUE_PTR,OPAQUE_PTR])
    fd2 = frame_descriptor_for([])
    ms, s, e = interpret(TestProgram([
        Block("main", [
            PRIM_OP("freshlabel", mk_args([(OPAQUE_PTR, 3)]), []),
            NEW_STACK(1, 1, -1, mk_args([]), 3),
            PUSH_STACK(1),
            CONST_INT(0,0),
            SHIFT_DYN(0,0,3),
            TestExit()
        ], fd),
        Block("tag1", [], fd2)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert metastack_shape(ms) == []
    assert stack_shape(s) == []
    assert metastack_shape(e.get_cont(0)) == [[(1,[0])]]

def test_jump():
    fd = frame_descriptor_for([INT])
    ms, s, e = interpret(TestProgram([
        Block("main", [
            JUMP(1),
            CONST_INT(0, 3221)
        ], fd),
        Block("target", [
            CONST_INT(0, 42),
            TestExit()
        ], fd),
        Block("dead", [
            CONST_INT(0, 3222)
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(0) == 42

def test_ifzero():
    fd = frame_descriptor_for([INT, STRING])
    p = TestProgram([
        Block("main", [
            CONST_INT(0, 0),
            PRIM_OP("get_arg(Int): String", mk_args([(STRING,0)]), mk_args([(INT,0)])),
            PRIM_OP("read(String): Int", mk_args([(INT,0)]), mk_args([(STRING,0)])),
            IFZERO(0, 2, mk_args([]))
        ], fd),
        Block("then", [
            CONST_INT(0, 42),
            TestExit()
        ], fd),
        Block("else", [
            CONST_INT(0, 322),
            TestExit()
        ], fd)
    ], fd, DEFAULT_SYMBOLS)
    primitives = Primitives()
    ms, s, e = interpret(p, ["0"], primitives)
    assert e.get_int(0) == 322
    ms, s, e = interpret(p, ["1"], primitives)
    assert e.get_int(0) == 42

def test_reset_shift_resume():
    fd = frame_descriptor_for([CONT, OPAQUE_PTR, OPAQUE_PTR, INT])
    fd_tag = frame_descriptor_for([])
    ms, s, e = interpret(TestProgram([
        Block('main', [
            PUSH(1, mk_args([])),
            PRIM_OP("freshlabel", mk_args([(OPAQUE_PTR, 2)]), []),
            NEW_STACK(1, 2, -1, mk_args([]), 2),
            PUSH_STACK(1),
            NEW_STACK(1, 3, -1, mk_args([]), 2),
            PUSH_STACK(1),
            CONST_INT(3,0),
            SHIFT_DYN(0,3,2),
            PUSH_STACK(0),
            TestExit()
        ], fd),
        Block('tag1', [], fd_tag),
        Block('tag2', [], fd_tag),
        Block('tag3', [], fd_tag)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert stack_shape(s) == [(3,[0])]
    assert metastack_shape(ms) == [[(2,[0])],[(1,[0])]]
    assert metastack_shape(e.get_cont(0)) == [[(3,[0])]]

def test_copy():
    fd = frame_descriptor_for([INT,INT])
    ms, s, e = interpret(TestProgram([
        Block("main", [
            CONST_INT(0, 42),
            COPY(INT, 0, 1),
            TestExit()
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(1) == 42

def test_drop():
    fd = frame_descriptor_for([INT])
    ms, s, e = interpret(TestProgram([
        Block("main", [
            CONST_INT(0, 42),
            DROP(INT, 0),
            TestExit()
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert isinstance(e.get_ptr(0), ValueNull)

def test_swap():
    fd = frame_descriptor_for([INT,INT])
    ms, s, e = interpret(TestProgram([
        Block("main", [
            CONST_INT(0, 42),
            CONST_INT(1, 322),
            SWAP(INT, 0,1),
            TestExit()
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(0) == 322
    assert e.get_int(1) == 42

def test_construct():
    fd = frame_descriptor_for([INT,ALGEBRAIC_DT])
    ms, s, e = interpret(TestProgram([
        Block('main', [
            CONST_INT(0, 12),
            CONSTRUCT(0,1,42,mk_args([(INT,0)])),
            TestExit()
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_data(0).tag == 42
    assert e.get_data(0).len_ptr() == 1
    assert e.get_data(0).get_int(0)== 12

def test_construct_match():
    fd = frame_descriptor_for([INT,INT,INT,ALGEBRAIC_DT])
    fd2 = frame_descriptor_for([INT,INT,INT])
    ms, s, e = interpret(TestProgram([
        Block('main', [
            CONST_INT(0, 42),
            CONSTRUCT(3, 1, 0, mk_args([(INT,0)])),
            MATCH(1, 3, [Clause(0, 1, mk_args([(INT,2)]))], ERROR_CLAUSE)
        ], fd),
        Block('m0', [
            CONST_INT(1, 1001),
            TestExit()
        ], fd2)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(0) == 42
    assert e.get_int(1) == 1001
    assert e.get_int(2) == 42

def test_new_push_stack():
    fd = frame_descriptor_for([CONT,CONT])
    fd_tag = frame_descriptor_for([])
    ms, s, e = interpret(TestProgram([
        Block('main', [
            PRIM_OP("freshlabel", mk_args([(OPAQUE_PTR, 0)]), []),
            PRIM_OP("freshlabel", mk_args([(OPAQUE_PTR, 1)]), []),
            NEW_STACK(0, 1, -1, mk_args([]), 0),
            NEW_STACK(1, 2, -1, mk_args([]), 1),
            PUSH_STACK(0),
            PUSH_STACK(1),
            TestExit()
        ], fd),
        Block('tag1', [], fd_tag),
        Block('tag2', [], fd_tag)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert stack_shape(s) == [(2,[0])]
    assert metastack_shape(ms) == [[(1,[0])],[]]
    assert metastack_shape(e.get_cont(0)) == [[(1,[0])]]
    assert metastack_shape(e.get_cont(1)) == [[(2,[0])]]

def test_new_stack():
    fd = frame_descriptor_for([CONT])
    fd_tag = frame_descriptor_for([])
    ms, s, e = interpret(TestProgram([
        Block('main', [
            PRIM_OP("freshlabel", mk_args([(OPAQUE_PTR, 0)]), []),
            NEW_STACK(0, 1, -1, mk_args([]), 0),
            TestExit()
        ], fd),
        Block('tag1', [], fd_tag)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert metastack_shape(e.get_cont(0)) == [[(1,[0])]]

def test_new():
    fd = frame_descriptor_for([CODATA, INT])
    fd_tag = frame_descriptor_for([])
    args = RegList(mk_args([(INT,0)]))
    ms, s, e = interpret(TestProgram([
        Block('main', [
            CONST_INT(0, 42),
            NEW(0, VTable([0,1], [1,2], CoData.get_concrete_class(args)), args),
            TestExit()
        ], fd),
        Block('tag1', [], fd_tag),
        Block('tag2', [], fd_tag)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    v = e.get_codata(0)
    assert v.vtable.targets == [1,2]
    assert v.get_int(0) == 42

def test_new_invoke():
    fd = frame_descriptor_for([CODATA,INT,INT,INT])
    args = RegList(mk_args([(INT,0)]))
    m = InternedString("apply")
    ms, s, e = interpret(TestProgram([
        Block('main', [
            CONST_INT(0,42),
            CONST_INT(2,0),
            NEW(1, VTable([m], [1], CoData.get_concrete_class(args)), args),
            CONST_INT(0,4242),
            INVOKE(1, m, mk_args([(INT, 0),(CODATA,1)]))
        ], fd),
        Block('rest', [
            CONST_INT(3, 424242),
            TestExit()
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    v = e.get_codata(1)
    assert v.vtable.targets == [1]
    assert v.get_int(0) == 42
    assert e.get_int(0) == 4242
    assert e.get_int(2) == 42
    assert e.get_int(3) == 424242
