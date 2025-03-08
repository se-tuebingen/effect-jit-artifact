from rpyeffect.instructions import *
from rpyeffect.types import *
from rpyeffect.program import *
from rpyeffect.primitives import Primitives
from rpyeffect.data import *
from rpyeffect.codata import *
from rpyeffect.stack import *
from rpyeffect.region import *
from rpyeffect.environment import *
from rpyeffect.stored_environment import *
from rpython.rlib.jit import JitDriver, purefunction, elidable, hint, unroll_safe, promote, assert_green, promote_string, we_are_jitted, record_exact_value, record_exact_class, jit_debug
from rpython.rlib.rstring import startswith
from rpython.rlib import objectmodel
from rpython.rlib.rerased import new_erasing_pair
import rpyeffect.config as cfg
from rpyeffect.dynlib import load_lib
from rpyeffect.util.debug import debug, debug_hooks
from rpyeffect.value import *

# Initialize JIT stuff
def get_location(pc_block, pc_instruction, context, program, primitives):
    return "%d<%s>+%d: %s" % (pc_block, program.blocks[pc_block].name, pc_instruction,
                              program.get_instruction(pc_block, pc_instruction).__repr__())

jitdriver = JitDriver(
    greens = ["pc_block", "pc_instruction", "context", "program", "primitives"], # interpreter state (defines program position)
    reds = ["stack_label", "stack", "env", "metastack", "stack_binding"], # program state
    get_printable_location=get_location,
    virtualizables=['env'] # can be optimized
)

@objectmodel.always_inline
def get_context(pc_block, pc_instruction, stack, metastack):
    if cfg.loop_context_depth == 0:
        return pc_block # Hack so it still works as a green
    elif cfg.loop_context_depth == 1:
        return -1 if stack is None else stack.target
    elif cfg.loop_context_depth == 2:
        return -1 if stack is None else (stack.target if stack.tail is None else stack.target * 16384 + stack.tail.target)
    else:
        print("Invalid compilation configuration: Only contexts for depth up to 2 are implemented.")
        exit(10)

def jitpolicy(driver):
    from rpython.jit.codewriter.policy import JitPolicy
    return JitPolicy()

# Actual interpreter
def interpret(program, args, primitives):
    primitives=promote(primitives)
    pc_block, pc_instruction = program.get_entry()
    env = Environment(program)
    stack_label = None
    stack_binding = eNone
    metastack = None
    stack = None
    # pass parameters to program in special registers
    primitives.parse_args(args)
    context = get_context(pc_block, pc_instruction, stack, metastack)

    # interpreter loop
    while not program.is_end(pc_block, pc_instruction):
        jitdriver.jit_merge_point(program = program, pc_block = pc_block, pc_instruction = pc_instruction, stack_label=stack_label, stack_binding = stack_binding, stack=stack,env=env, metastack=metastack, primitives=primitives, context=context)
        pc_block, pc_instruction, stack_label, stack_binding, stack, metastack, context = interpret_instruction(program = program, pc_block = pc_block, pc_instruction = pc_instruction, stack_label=stack_label, stack_binding=stack_binding, stack=stack,env=env, metastack=metastack, primitives=primitives, context=context)

    return (metastack, stack, env.copy(program))

################################################################################
# Common operations, think "microcode"
################################################################################
@unroll_safe
@objectmodel.always_inline
def maybe_cej(cej, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context):
    if cej or (cfg.additional_can_enter_jit_locations and isinstance(program.get_instruction(pc_block, pc_instruction), PUSH)):
        context = get_context(pc_block, pc_instruction, stack, metastack)
        jitdriver.can_enter_jit(program = program, pc_block=pc_block, pc_instruction=pc_instruction, stack_label=stack_label, stack_binding=stack_binding, stack=stack, env=env, metastack=metastack, primitives=primitives, context=context)
    return pc_block, pc_instruction, stack_label, stack_binding, stack, metastack, context

@unroll_safe
@objectmodel.always_inline
def jump_to(target, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context):
    old_pc_block = pc_block
    pc_block, pc_instruction = target, 0
    return maybe_cej(pc_block <= old_pc_block, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)

@unroll_safe
@objectmodel.always_inline
def do_return(args_regs, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context):
    while stack is None: # will always be unrolled. OK?
        if metastack is None:
            return len(program.blocks)+10, 0, stack_label, stack_binding, stack, metastack, context
        else:
            assert isinstance(metastack, MetaStack)
            debug_hooks.return_through_label(stack_label)
            stack = metastack.stack
            stack_label = metastack.label
            stack_binding = metastack.binding if isinstance(metastack, MetaStackWithBinding) else eNone
            metastack = metastack.tail
    
    side_stack = None
    while isinstance(stack, ConcatStack):
        side_stack = concat_stack(stack.tail, side_stack)
        stack = stack.front

    target = promote(stack.target)
         
    if program.blocks[target].stack_type is not None and we_are_jitted():
        record_exact_class(stack, program.blocks[target].stack_type)

    js = [len(a) for a in args_regs]
    if cfg.debug: debug("  Restored %s" % (", ".join(["%s: %d" % (type_repr(i), j) for i,j in enumerate(js)])))
    env.setfrom_stack(stack, js, program)
    stack = stack.tail

    if side_stack is not None:
        stack = concat_stack(stack, side_stack)

    return jump_to(target, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)

################################################################################
# Actual interpreter dispatch
################################################################################
@unroll_safe
@objectmodel.always_inline
def interpret_instruction(program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context):
    op = program.get_instruction(pc_block, pc_instruction)
    if cfg.debug: debug("%d<%s>+%d:\n \033[96m%s\033[0m" % (pc_block, program.blocks[pc_block].name, pc_instruction, op.__repr__()))
    if isinstance(op, CONST_PTR):
        env.set_ptr(op.out, op.value_ptr)
    elif isinstance(op, PRIM_OP):
        #opid = promote_string(op.name) # Should be const
        if cfg.debug and cfg.print_debug:
            for i in op.ins.regs[OPAQUE_PTR]:
                debug("  ptr %d is %s" %(i, env.get_ptr(i)))
        primitives.run_primitive(env, op.name, op.ins, op.outs, program, pc_block, pc_instruction, metastack, stack, stack_label, stack_binding)
        if cfg.debug:
            debug("  Out:")
            for i in op.outs.regs[OPAQUE_PTR]:
                debug("  ptr %d is %s" %(i, env.get_ptr(i)))
    elif isinstance(op, ADD):
        env.set_int(op.out, env.get_int(op.in1) + env.get_int(op.in2))
    elif isinstance(op, RETURN):
        return do_return(op.args.regs, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)
    elif isinstance(op, PUSH):
        target = op.target
        stack = Stack.make(op.args, env, target, stack)

        if program.blocks[target].stack_type is None:
            program.blocks[target].stack_type = Stack.get_concrete_class(op.args)
    elif isinstance(op, JUMP):
        return jump_to(op.target, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)
    elif isinstance(op, IFZERO):
        cond = env.get_num(op.cond)
        if (isinstance(cond, BoolValue) and not cond.value) or (isinstance(cond, IntValue) and cond.value == 0):
            return jump_to(op.then.target, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)
    elif isinstance(op, SHIFT):
        if op.n == 0:
            env.set_cont(op.out, None)
        else:
            (cont, metastack) = split_metastack_n(makeMetaStack(stack, None, metastack, stack_label, stack_binding), op.n-1, None)
            env.set_cont(op.out, cont)
            record_exact_value(metastack is not None, True)
            #record_exact_class(metastack, MetaStack) # TODO this should be possible, right ?!?!?!?
            if metastack is not None and isinstance(metastack, MetaStack):
                stack = metastack.stack
                stack_label = metastack.label
                stack_binding = metastack.binding if isinstance(metastack, MetaStackWithBinding) else eNone
                metastack = metastack.tail
            else:
                stack = None
    elif isinstance(op, SHIFT_DYN):
        n = promote(env.get_int(op.n))
        label = env.get_label(op.label)
        #if not we_are_jitted() and op.last_n == -1: # last_n => some_n
        #    op.last_n = n
        #if n == op.last_n: # TODO
        #    pass # unrolling
        #else:
        #    pass # dont_look_inside
        (cont, metastack) = split_metastack_n(makeMetaStack(stack, None, metastack, stack_label, stack_binding), n, label)
        env.set_cont(op.out, cont)
        record_exact_value(metastack is not None, True)
        #record_exact_class(metastack, MetaStack) # TODO this should be possible, right ?!?!?!?
        if metastack is not None and isinstance(metastack, MetaStack):
            stack = metastack.stack
            stack_label = metastack.label
            stack_binding = metastack.binding if isinstance(metastack, MetaStackWithBinding) else eNone
            metastack = metastack.tail
        else:
            stack = None
        context = get_context(pc_block, pc_instruction, stack, metastack)
    elif isinstance(op, GET_DYNAMIC):
        n = promote(env.get_int(op.n))
        label = env.get_label(op.label)
        env.set_ptr(op.out, get_dynamic(makeMetaStack(stack, None, metastack, stack_label, stack_binding), n, label))
    elif isinstance(op, CONTROL):
        n = promote(env.get_int(op.n))
        label = env.get_label(op.label)
        #if not we_are_jitted() and op.last_n == -1: # last_n => some_n
        #    op.last_n = n
        #if n == op.last_n: # TODO
        #    pass # unrolling
        #else:
        #    pass # dont_look_inside
        (cont, metastack) = split_metastack_n_open(makeMetaStack(stack, None, metastack, stack_label, stack_binding), n, label)
        env.set_cont(op.out, cont)
        record_exact_value(metastack is not None, True)
        #record_exact_class(metastack, MetaStack) # TODO this should be possible, right ?!?!?!?
        if metastack is not None and isinstance(metastack, MetaStack):
            stack = metastack.stack
            stack_label = metastack.label
            stack_binding = metastack.binding if isinstance(metastack, MetaStackWithBinding) else eNone
            metastack = metastack.tail
        else:
            stack = None
        context = get_context(pc_block, pc_instruction, stack, metastack)
    elif isinstance(op, COPY):
        env.set_ptr(op.to, env.get_ptr(op.fr))
    elif isinstance(op, DROP):
        env.set_ptr(op.reg, eNone)
    elif isinstance(op, SWAP):
        tmp = env.get_ptr(op.b)
        env.set_ptr(op.b, env.get_ptr(op.a))
        env.set_ptr(op.a, tmp)
    elif isinstance(op, CONSTRUCT):
        env.set_data(op.out, Data.make(op.args, env, op.tag))
    elif isinstance(op, MATCH):
        arg = env.get_data(op.arg)
        tag = promote(arg.get_tag())
        if cfg.debug: debug(" Found tag: %s" % tag)
        clause = None
        
        for c in op.clauses:
            if c.tag == tag:
                clause = c
        if clause is None:
            clause = op.default_clause
            # we know that the default clause takes no parameters
            record_exact_value(len(clause.args.regs[OPAQUE_PTR]), 0)
        elif we_are_jitted():
            record_exact_class(arg, clause.scrutinee_cls)

        for i in range(len(clause.args.regs[OPAQUE_PTR])):
            env.set_ptr(clause.args.regs[OPAQUE_PTR][i], arg.get_ptr(i))
        return jump_to(clause.target, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)
    elif isinstance(op, SWITCH):
        arg = env.get_num(op.arg)
        target = op.default_target
        for idx, value in enumerate(op.values):
            if equal(arg, value):
                target = op.targets[idx]
                break
        return jump_to(target, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)
    elif isinstance(op, PROJ):
        arg = env.get_data(op.scrutinee)
        tag = promote(arg.get_tag())
        if tag != op.tag: primitives.panic("Projection from invalid case")
        env.set_ptr(op.out, arg.get_ptr(op.field))
    elif isinstance(op, NEW_STACK):
        reg = Region()

        new_stack = MetaStack(Stack.make(
            op.args, env,
            op.target, None),
            reg,
            None,
            env.get_label(op.label))
        env.set_cont(op.out, new_stack)
        env.set_region(op.region, reg)
    elif isinstance(op, NEW_STACK_WITH_BINDING):
        reg = Region()

        new_stack = MetaStackWithBinding(Stack.make(
            op.args, env,
            op.target, None),
            reg,
            None,
            env.get_label(op.label),
            env.get_ptr(op.binding))
        env.set_cont(op.out, new_stack)
        env.set_region(op.region, reg)
    elif isinstance(op, PUSH_STACK):
        metastack = metastack_push(metastack_push(metastack, 
                        makeMetaStack(stack, None, None, stack_label, stack_binding)), 
                        env.get_cont(op.arg))
        # TODO test/assert MetaStack
        stack = metastack.stack
        stack_label = metastack.label if isinstance(metastack, MetaStack) else None
        stack_binding = metastack.binding if isinstance(metastack, MetaStackWithBinding) else eNone
        metastack = metastack.tail if isinstance(metastack, MetaStack) else None
        context = get_context(pc_block, pc_instruction, stack, metastack)
    elif isinstance(op, NEW):
        env.set_codata(op.out, CoData.make(op.args, env, op.vtable))
    elif isinstance(op, INVOKE):
        recv = env.get_codata(op.receiver)
        vtable = promote(recv.vtable)
        if we_are_jitted(): record_exact_class(recv, vtable.codata_cls)
        target = vtable.get_target(op.tag, primitives)

        js = [len(a) for a in op.args.regs]
        env.setfrom_codata(recv, js, program)

        return jump_to(target, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)
    elif isinstance(op, ALLOCATE):
        init = env.get_ptr(op.init)
        ref = Ref(init, op)
        if op.region >= 0:
            region = env.get_region(op.region)
            region.register(ref)
        env.set_ref(op.out, ref)
    elif isinstance(op, LOAD):
        ref = env.get_ref(op.ref)
        assert(isinstance(ref, Ref))
        env.set_ptr(op.out, ref.get_ptr())
    elif isinstance(op, STORE):
        ref = env.get_ref(op.ref)
        assert(isinstance(ref, Ref))
        val = env.get_ptr(op.value_reg)
        ref.put_ptr(val)
    elif isinstance(op, LOAD_LIB):
        lib, flag = load_lib(program, env.get_str(op.path), primitives)
        env.set_lib(0, lib)

        if lib is not None and not flag and "$static-init" in lib.symbols:
            if cfg.debug: debug("Calling into static init for %s" % lib.filename)
            # Assumption: $static-init WILL return register ptr0 unchanged!
            debug_hooks.enter_static_init()
            return jump_to(lib.symbols["$static-init"].position, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)
        else:
            # directly return, already initialized (or no $static-init)
            return do_return([[0]], program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)
    elif isinstance(op, CALL_LIB):
        lib = promote(env.get_lib(op.lib))
        if lib is None:
            primitives.panic("Trying to call symbol on library that was not loaded successfully.")
            primitives.exit(255)
        if op.cache_lib != lib:
            if op.symbol not in lib.symbols:
               primitives.panic("Library '%s' does not define symbol '%s'." % (lib.filename, op.symbol)) 
               primitives.exit(255)
            target = lib.symbols[op.symbol].position
            # update cache
            op.cache_lib = lib
            op.cache_target = target

        return jump_to(op.cache_target, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)

    elif isinstance(op, DEBUG):
        if cfg.debug and cfg.print_debug:
            if we_are_jitted():
                jit_debug(op.msg)
            else:
                # debug(op.msg)
                for reg in op.traced.regs[OPAQUE_PTR]:
                    debug("  PTR %d: %s" % (reg, env.get_ptr(reg)))                


    else:
        print("Instruction not implemented, skipping")
    pc_block, pc_instruction = program.next_pc(pc_block, pc_instruction)
    return maybe_cej(False, program, pc_block, pc_instruction, stack_label, stack_binding, stack, env, metastack, primitives, context)
