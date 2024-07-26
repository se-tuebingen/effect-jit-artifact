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
def CONST_INT(reg, val): return CONST_NUMBER(reg, val)
def CONST_DOUBLE(reg, val): return CONST_NUMBER(reg, float2longlong(val))
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
        r.insert(0, (s.target, [(s.len_num()), (s.len_ptr())]))
        return r
def metastack_shape(ms):
    if ms is None:
        return []
    elif isinstance(ms, MetaStack):
        r = metastack_shape(ms.tail)
        r.insert(0, stack_shape(ms.stack))
        return r

def test_const():
    fd = frame_descriptor_for([INT, DOUBLE, STRING])
    double = 2.7
    string = "Hallo"
    _, _, e = interpret(Program([Block('main', [
        CONST_INT(0, 5),
        CONST_DOUBLE(1, double),
        CONST_STRING(0, string)
    ], fd)], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(0) == 5
    assert e.get_double(1) == double
    assert e.get_str(0) == string

def test_add():
    fd = frame_descriptor_for([INT,INT,INT])
    _, _, e = interpret(Program([Block('main', [
        CONST_INT(0, 2),
        CONST_INT(1, 5),
        ADD(2, 0, 1)
    ], fd)], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(2) == 7

def test_mul():
    fd = frame_descriptor_for([INT,INT,INT])
    _, _, e = interpret(Program([Block('main', [
        CONST_INT(0, 2),
        CONST_INT(1, 3),
        PRIM_OP("infixMul(Int, Int): Int", [[2],[]], [[0, 1],[]])
    ], fd)], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(2) == 6

def test_simple():
    fd = frame_descriptor_for([INT,INT,INT])
    ms, s, e = interpret(Program([Block('main', [
        CONST_INT(0, 12),
        CONST_INT(1, 2),
        ADD(2, 1, 0)
    ], fd)], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(2) == 14

def test_push():
    fd = frame_descriptor_for([INT,INT])
    ms, s, e = interpret(Program([Block('main', [
        CONST_INT(0, 12),
        CONST_INT(1, 2)], fd),
        Block('l0', [PUSH (1, mk_args([(INT,0)]))], fd)
                                  ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert stack_shape(s) == [(1,[1,0])]
    assert metastack_shape(ms) == []
    assert s.get_int(0) == 12

def test_push_return():
    fd = frame_descriptor_for([INT])
    ms, s, e = interpret(Program([
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
    p = Program([
        Block("main", [
            PUSH(1, mk_args([])),
            NEW_STACK(0, 2, -1, mk_args([]), -1),
            PUSH_STACK(0),
            JUMP(3)
        ], fd),
        Block("tag1", [], fd),
        Block("tag2", [], fd)
    ], fd, DEFAULT_SYMBOLS)
    ms, s, e = interpret(p, [], Primitives())
    assert stack_shape(s) == [(2,[0,0])]
    assert metastack_shape(ms) == [[(1,[0,0])]]

def test_reset_shift():
    fd = frame_descriptor_for([CONT, OPAQUE_PTR])
    fd2 = frame_descriptor_for([])
    ms, s, e = interpret(Program([
        Block("main", [
            NEW_STACK(1, 1, -1, mk_args([]), -1),
            PUSH_STACK(1),
            SHIFT(0,1),
            JUMP(2)
        ], fd),
        Block("tag1", [], fd2)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert metastack_shape(ms) == []
    assert stack_shape(s) == []
    assert metastack_shape(e.get_cont(0)) == [[(1,[0,0])]]

def test_reset_shiftdyn():
    fd = frame_descriptor_for([CONT,INT,OPAQUE_PTR])
    fd2 = frame_descriptor_for([])
    ms, s, e = interpret(Program([
        Block("main", [
            NEW_STACK(1, 1, -1, mk_args([]), -1),
            PUSH_STACK(1),
            CONST_INT(0,0),
            SHIFT_DYN(0,0,-1),
            JUMP(2)
        ], fd),
        Block("tag1", [], fd2)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert metastack_shape(ms) == []
    assert stack_shape(s) == []
    assert metastack_shape(e.get_cont(0)) == [[(1,[0,0])]]

def test_jump():
    fd = frame_descriptor_for([INT])
    ms, s, e = interpret(Program([
        Block("main", [
            JUMP(1),
            CONST_INT(0, 3221)
        ], fd),
        Block("target", [
            CONST_INT(0, 42),
            JUMP(3)
        ], fd),
        Block("dead", [
            CONST_INT(0, 3222)
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(0) == 42

def test_ifzero():
    fd = frame_descriptor_for([INT, STRING])
    p = Program([
        Block("main", [
            CONST_INT(0, 0),
            PRIM_OP("get_arg(Int): String", mk_args([(STRING,0)]), mk_args([(INT,0)])),
            PRIM_OP("read(String): Int", mk_args([(INT,0)]), mk_args([(STRING,0)])),
            IFZERO(0, 2, mk_args([]))
        ], fd),
        Block("then", [
            CONST_INT(0, 42),
            JUMP(3)
        ], fd),
        Block("else", [
            CONST_INT(0, 322),
            JUMP(3)
        ], fd)
    ], fd, DEFAULT_SYMBOLS)
    primitives = Primitives()
    ms, s, e = interpret(p, ["0"], primitives)
    assert e.get_int(0) == 322
    ms, s, e = interpret(p, ["1"], primitives)
    assert e.get_int(0) == 42

def test_reset_shift_resume():
    fd = frame_descriptor_for([CONT, OPAQUE_PTR])
    fd_tag = frame_descriptor_for([])
    ms, s, e = interpret(Program([
        Block('main', [
            PUSH(1, mk_args([])),
            NEW_STACK(1, 2, -1, mk_args([]), -1),
            PUSH_STACK(1),
            NEW_STACK(1, 3, -1, mk_args([]), -1),
            PUSH_STACK(1),
            SHIFT(0,1),
            PUSH_STACK(0),
            JUMP(4)
        ], fd),
        Block('tag1', [], fd_tag),
        Block('tag2', [], fd_tag),
        Block('tag3', [], fd_tag)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert stack_shape(s) == [(3,[0,0])]
    assert metastack_shape(ms) == [[(2,[0,0])],[(1,[0,0])]]
    assert metastack_shape(e.get_cont(0)) == [[(3,[0,0])]]

def test_copy():
    fd = frame_descriptor_for([INT,INT])
    ms, s, e = interpret(Program([
        Block("main", [
            CONST_INT(0, 42),
            COPY(INT, 0, 1)
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(1) == 42

def test_drop():
    fd = frame_descriptor_for([INT])
    ms, s, e = interpret(Program([
        Block("main", [
            CONST_INT(0, 42),
            DROP(INT, 0)
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(0) == 0

def test_swap():
    fd = frame_descriptor_for([INT,INT])
    ms, s, e = interpret(Program([
        Block("main", [
            CONST_INT(0, 42),
            CONST_INT(1, 322),
            SWAP(INT, 0,1)
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(0) == 322
    assert e.get_int(1) == 42

def test_construct():
    fd = frame_descriptor_for([INT,ALGEBRAIC_DT])
    ms, s, e = interpret(Program([
        Block('main', [
            CONST_INT(0, 12),
            CONSTRUCT(0,1,42,mk_args([(INT,0)]))
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_data(0).tag == 42
    assert e.get_data(0).len_num() == 1
    assert e.get_data(0).get_num(0)== 12
    assert e.get_data(0).len_ptr() == 0

def test_construct_match():
    fd = frame_descriptor_for([INT,INT,INT,ALGEBRAIC_DT])
    fd2 = frame_descriptor_for([INT,INT,INT])
    ms, s, e = interpret(Program([
        Block('main', [
            CONST_INT(0, 42),
            CONSTRUCT(0, 1, 0, mk_args([(INT,0)])),
            MATCH(1, 0, [Clause(0, 1, mk_args([(INT,2)]))], ERROR_CLAUSE)
        ], fd),
        Block('m0', [
            CONST_INT(1, 1001)
        ], fd2)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert e.get_int(0) == 42
    assert e.get_int(1) == 1001
    assert e.get_int(2) == 42

def test_new_push_stack():
    fd = frame_descriptor_for([CONT,CONT])
    fd_tag = frame_descriptor_for([])
    ms, s, e = interpret(Program([
        Block('main', [
            NEW_STACK(0, 1, -1, mk_args([]), -1),
            NEW_STACK(1, 2, -1, mk_args([]), -1),
            PUSH_STACK(0),
            PUSH_STACK(1),
            JUMP(2)
        ], fd),
        Block('tag1', [], fd_tag),
        Block('tag2', [], fd_tag)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert stack_shape(s) == [(2,[0,0])]
    assert metastack_shape(ms) == [[(1,[0,0])],[]]
    assert metastack_shape(e.get_cont(0)) == [[(1,[0,0])]]
    assert metastack_shape(e.get_cont(1)) == [[(2,[0,0])]]

def test_new_stack():
    fd = frame_descriptor_for([CONT])
    fd_tag = frame_descriptor_for([])
    ms, s, e = interpret(Program([
        Block('main', [
            NEW_STACK(0, 1, -1, mk_args([]), -1),
            JUMP(2)
        ], fd),
        Block('tag1', [], fd_tag)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    assert metastack_shape(e.get_cont(0)) == [[(1,[0,0])]]

def test_new():
    fd = frame_descriptor_for([CODATA, INT])
    fd_tag = frame_descriptor_for([])
    args = RegList(mk_args([(INT,0)]))
    ms, s, e = interpret(Program([
        Block('main', [
            CONST_INT(0, 42),
            NEW(0, VTable([0,1], [1,2], CoData.get_concrete_class(args)), args),
            JUMP(3)
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
    ms, s, e = interpret(Program([
        Block('main', [
            CONST_INT(0,42),
            NEW(0, VTable([0,1], [0,1], CoData.get_concrete_class(args)), args),
            CONST_INT(0,4242),
            INVOKE(0, 1, mk_args([(INT, 0),(CODATA,0)]))
        ], fd),
        Block('rest', [
            CONST_INT(2, 424242)
        ], fd)
    ], fd, DEFAULT_SYMBOLS), [], Primitives())
    v = e.get_codata(0)
    assert v.vtable.targets == [0,1]
    assert v.get_int(0) == 42
    assert e.get_int(0) == 4242
    assert e.get_int(1) == 42
    assert e.get_int(2) == 424242
