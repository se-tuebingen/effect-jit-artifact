#include "machine.h"
#include "instruction_set.h"
#include "persistent_data_structures/list.h"
#include "value.h"
#include "extern_call.h"
#include <cstdint>
#include <memory>
#include <utility>
#include <vector>
#include <variant>

namespace hvm {
namespace {

void GetFunctionArgs(size_t n, Value& accumulator, ArgStack& arg_stack, Environment& new_environment) {
  if (n > 0) {
    new_environment = list::Cons(std::move(accumulator), std::move(new_environment));

    for (size_t i = 1; i < n; i++) {
      new_environment = list::Cons(arg_stack.back(), std::move(new_environment));
      arg_stack.pop_back();
    }
  }
}

} // namespace


Result Run(int argc, char* argv[], Program program) {
  Value accumulator = 0;
  ArgStack arg_stack;
  ReturnStack return_stack;
  Environment environment;
  MetaStack meta_stack;
  meta_stack.reserve(128);
  std::vector<Value> globals;
  ExitCode exit_code = 0;
  Extern extrn(argc, argv);

  int fresh_label = 0;
  int instruction_pointer = 0;
  bool stop = false;
  std::vector<list::List<Value>> trash_bin_lists;
  std::vector<std::shared_ptr<Value[]>> trash_bin_shared_arrays;

  while (!stop) {
    const Instruction& instruction = program[instruction_pointer];
    instruction_pointer++;

    switch (instruction.op_code) {
    case OpCode::kPush:
      arg_stack.push_back(accumulator);
      break;

    case OpCode::kConstInt:
      accumulator = instruction.params[0];
      break;

    case OpCode::kConstString:
      accumulator = instruction.string_param;
      break;

    case OpCode::kAccessVar:
      accumulator = list::Nth(instruction.params[0], environment);
      break;

    case OpCode::kLet:
      environment = list::Cons(accumulator, std::move(environment));
      break;

    case OpCode::kEndLet:
      environment = environment->tail;
      break;

    case OpCode::kCreateGlobal:
      globals.push_back(accumulator);
      break;

    case OpCode::kAccessGlobal:
      accumulator = globals[instruction.params[0]];
      break;

    case OpCode::kJumpZero:
      if (std::get<HeliumInt>(accumulator) == 0)
        instruction_pointer = instruction.params[0];
      break;

    case OpCode::kJumpNonZero:
      if (std::get<HeliumInt>(accumulator) != 0)
        instruction_pointer = instruction.params[0];
      break;

    case OpCode::kJump:
      instruction_pointer = instruction.params[0];
      break;

    case OpCode::kSwitch:
      instruction_pointer = instruction.params[std::get<HeliumInt>(accumulator)];
      break;

    case OpCode::kMatch:
      if (auto record = std::get_if<Record>(&accumulator))
        instruction_pointer = instruction.params[std::get<HeliumInt>(record->fields[0])];
      else
        instruction_pointer = instruction.params[std::get<HeliumInt>(accumulator)];

      environment = list::Cons(accumulator, std::move(environment));
      break;

    case OpCode::kPrim: {
        HeliumInt prim_arg1 = std::get<HeliumInt>(arg_stack.back());

        arg_stack.pop_back();

        HeliumInt prim_arg2 = std::get<HeliumInt>(std::move(accumulator));

        switch (instruction.prim_code) {
        case PrimCode::kAdd:
          accumulator = prim_arg1 + prim_arg2;
          break;
        case PrimCode::kSub:
          accumulator = prim_arg1 - prim_arg2;
          break;
        case PrimCode::kMult:
          accumulator = prim_arg1 * prim_arg2;
          break;
        case PrimCode::kDiv:
          accumulator = prim_arg1 / prim_arg2;
          break;
        case PrimCode::kMod:
          accumulator = prim_arg1 % prim_arg2;
          break;
        case PrimCode::kEq:
          accumulator = prim_arg1 == prim_arg2;
          break;
        case PrimCode::kNeq:
          accumulator = prim_arg1 != prim_arg2;
          break;
        case PrimCode::kLt:
          accumulator = prim_arg1 < prim_arg2;
          break;
        case PrimCode::kLe:
          accumulator = prim_arg1 <= prim_arg2;
          break;
        case PrimCode::kGt:
          accumulator = prim_arg1 > prim_arg2;
          break;
        case PrimCode::kGe:
          accumulator = prim_arg1 >= prim_arg2;
          break;
        case PrimCode::kAnd:
          accumulator = prim_arg1 & prim_arg2;
          break;
        case PrimCode::kOr:
          accumulator = prim_arg1 | prim_arg2;
          break;
        case PrimCode::kXor:
          accumulator = prim_arg1 ^ prim_arg2;
          break;
        case PrimCode::kLsl:
          accumulator = prim_arg1 << prim_arg2;
          break;
        case PrimCode::kLsr:
          accumulator = (HeliumInt)(((HeliumUnsignedInt) prim_arg1) >> prim_arg2);
          break;
        case PrimCode::kAsr:
          accumulator = prim_arg1 >> prim_arg2;
          break;
        }
      }
      break;

    case OpCode::kPrimUnary: {
        HeliumInt prim_arg = std::get<HeliumInt>(std::move(accumulator));

        switch (instruction.prim_unary_code) {
          case PrimUnaryCode::kNot:
            accumulator = ~prim_arg;
            break;
          case PrimUnaryCode::kNeg:
            accumulator = -prim_arg;
            break;
          case PrimUnaryCode::kAddConst:
            accumulator = prim_arg + instruction.params[0];
            break;
          case PrimUnaryCode::kSubConst:
            accumulator = prim_arg - instruction.params[0];
            break;
          case PrimUnaryCode::kSubFromConst:
            accumulator = instruction.params[0] - prim_arg;
            break;
          case PrimUnaryCode::kMultByConst:
            accumulator = prim_arg * instruction.params[0];
            break;
          case PrimUnaryCode::kDivByConst:
            accumulator = prim_arg / instruction.params[0];
            break;
          case PrimUnaryCode::kDivConstBy:
            accumulator = instruction.params[0] / prim_arg;
            break;
          case PrimUnaryCode::kModByConst:
            accumulator = prim_arg % instruction.params[0];
            break;
          case PrimUnaryCode::kModConstBy:
            accumulator = instruction.params[0] % prim_arg;
            break;
          case PrimUnaryCode::kEqConst:
            accumulator = prim_arg == instruction.params[0];
            break;
          case PrimUnaryCode::kNeqConst:
            accumulator = prim_arg != instruction.params[0];
            break;
          case PrimUnaryCode::kLtConst:
            accumulator = prim_arg < instruction.params[0];
            break;
          case PrimUnaryCode::kLeConst:
            accumulator = prim_arg <= instruction.params[0];
            break;
          case PrimUnaryCode::kGtConst:
            accumulator = prim_arg > instruction.params[0];
            break;
          case PrimUnaryCode::kGeConst:
            accumulator = prim_arg >= instruction.params[0];
            break;
          case PrimUnaryCode::kAndConst:
            accumulator = prim_arg & instruction.params[0];
            break;
          case PrimUnaryCode::kOrConst:
            accumulator = prim_arg | instruction.params[0];
            break;
          case PrimUnaryCode::kXorConst:
            accumulator = prim_arg ^ instruction.params[0];
            break;
          case PrimUnaryCode::kLslConst:
            accumulator = prim_arg << instruction.params[0];
            break;
          case PrimUnaryCode::kLsrConst:
            accumulator = (HeliumInt)(((HeliumUnsignedInt)prim_arg) >> instruction.params[0]);
            break;
          case PrimUnaryCode::kAsrConst:
            accumulator = prim_arg >> instruction.params[0];
            break;
        }
      }

      break;

    case OpCode::kMakeClosure:
      accumulator = std::make_shared<Closure>(instruction.params[0], instruction.params[1], environment);
      break;

    case OpCode::kMakeRecursiveBinding: {
        auto recursive_binding = std::make_shared<RecursiveBinding>(instruction.params_count / 2);
        for (size_t i = 0; i < instruction.params_count / 2; i++) {
          recursive_binding->bindings[i].instruction_pointer = instruction.params[2 * i];
          recursive_binding->bindings[i].arity = instruction.params[2 * i + 1];
          recursive_binding->bindings[i].environment = environment;
          recursive_binding->bindings[i].recursive_binding = recursive_binding;
        }

        accumulator = std::move(recursive_binding);
      }

      break;

    case OpCode::kAccessRecursiveBinding: {
        auto recursive_binding = std::get<std::shared_ptr<RecursiveBinding>>(accumulator);
        auto closure = std::shared_ptr<Closure>(recursive_binding,
          &recursive_binding->bindings[instruction.params[0]]);

        accumulator = std::move(closure);
      }

      break;

    case OpCode::kCallGlobal:
    case OpCode::kTailCallGlobal: {
        Closure* closure =
          std::get<std::shared_ptr<Closure>>(globals[instruction.params[0]]).get();

        Environment new_environment  = closure->environment;
        GetFunctionArgs(closure->arity, accumulator, arg_stack, new_environment);

        if (instruction.op_code == OpCode::kCallGlobal)
          return_stack = list::Cons(ReturnAddress(instruction_pointer, std::move(environment)),
                                    std::move(return_stack));

        environment = new_environment;
        instruction_pointer = closure->instruction_pointer;
    }

    break;

    case OpCode::kCallRecursiveBinding:
    case OpCode::kTailCallRecursiveBinding: {
      Closure& closure = std::get<std::shared_ptr<RecursiveBinding>>(list::Nth(instruction.params[0], environment))->
        bindings[instruction.params[1]];

        Environment new_environment = list::Cons(Value(closure.recursive_binding.lock()),
                                                       closure.environment);

        GetFunctionArgs(closure.arity, accumulator, arg_stack, new_environment);

        if (instruction.op_code == OpCode::kCallRecursiveBinding)
          return_stack = list::Cons(ReturnAddress(instruction_pointer, std::move(environment)), 
                                    std::move(return_stack));

        environment = new_environment;
        instruction_pointer = closure.instruction_pointer;
    }

    break;

    case OpCode::kCall:
    case OpCode::kTailCall: {
        if (auto closure_ptr = std::get_if<std::shared_ptr<Closure>>(&accumulator)) {

          Environment new_environment = (*closure_ptr)->environment;

          if (!(*closure_ptr)->recursive_binding.expired())
            new_environment = list::Cons(Value((*closure_ptr)->recursive_binding.lock()),
                                         std::move(new_environment));

          for (size_t i = 0; i < (*closure_ptr)->arity; i++) {
              new_environment = list::Cons(arg_stack.back(), std::move(new_environment));
              arg_stack.pop_back();
          }

          if (instruction.op_code == OpCode::kCall)
            return_stack = list::Cons(ReturnAddress(instruction_pointer, std::move(environment)),
                                      std::move(return_stack));

          environment = new_environment;
          instruction_pointer = (*closure_ptr)->instruction_pointer;

        } else if (auto resumpion_ptr =
                      std::get_if<std::shared_ptr<Resumption>>(&accumulator)) {

          Value arg = arg_stack.back();
          arg_stack.pop_back();

          if (instruction.op_code == OpCode::kCall)
            return_stack = list::Cons(ReturnAddress(instruction_pointer, std::move(environment)),
                                      std::move(return_stack));

          const MetaStack& reified_meta_stack = (*resumpion_ptr)->reified_meta_stack;

          for (auto frame = reified_meta_stack.crbegin(); frame != reified_meta_stack.crend(); ++frame) {
            meta_stack.push_back(*frame);
            std::swap(return_stack, meta_stack.back().return_stack);
          }

          instruction_pointer = (*resumpion_ptr)->instruction_pointer;
          environment = (*resumpion_ptr)->environment;
          accumulator = arg;
        }
      }

      break;

    case OpCode::kCallLocal:
    case OpCode::kTailCallLocal: {
        auto f = list::Nth(instruction.params[0], environment);

        if (auto closure_ptr = std::get_if<std::shared_ptr<Closure>>(&f)) {

          Environment new_environment  = (*closure_ptr)->environment;

          if (!(*closure_ptr)->recursive_binding.expired())
            new_environment = list::Cons(Value((*closure_ptr)->recursive_binding.lock()),
                                         std::move(new_environment));

          GetFunctionArgs((*closure_ptr)->arity , accumulator, arg_stack, new_environment);

          if (instruction.op_code == OpCode::kCallLocal)
            return_stack = list::Cons(ReturnAddress(instruction_pointer, std::move(environment)),
                                      std::move(return_stack));

          environment = new_environment;
          instruction_pointer = (*closure_ptr)->instruction_pointer;

        } else if (auto resumpion_ptr =
                      std::get_if<std::shared_ptr<Resumption>>(&f)) {

          if (instruction.op_code == OpCode::kCallLocal)
            return_stack = list::Cons(ReturnAddress(instruction_pointer, std::move(environment)),
                                      std::move(return_stack));

          const MetaStack& reified_meta_stack = (*resumpion_ptr)->reified_meta_stack;

          for (auto frame = reified_meta_stack.crbegin(); frame != reified_meta_stack.crend(); ++frame) {
            meta_stack.push_back(*frame);
            std::swap(return_stack, meta_stack.back().return_stack);
          }

          instruction_pointer = (*resumpion_ptr)->instruction_pointer;
          environment = (*resumpion_ptr)->environment;
        }
      }

      break;

    case OpCode::kCallExtern: {
        std::vector<Value> args;

        if (instruction.extern_function_arity > 0) {
          args.emplace_back(accumulator);

          for (size_t i = 0; i < instruction.extern_function_arity - 1; i++) {
            args.push_back(arg_stack.back());
            arg_stack.pop_back();
          }
        }

        accumulator = extrn.ExternCall(instruction.string_param, args);
      }

      break;

    case OpCode::kReturn: {
        instruction_pointer = return_stack->head.instruction_pointer;

        if (return_stack.use_count() == 1) {
          environment = std::move(return_stack->head.environment);
        } else {
          environment = return_stack->head.environment;
        }

        return_stack = return_stack->tail;
      }

      break;

    case OpCode::kMakeRecord: {
        if (instruction.params[0] > 0) {
          auto fields = std::shared_ptr<Value[]> (new Value[instruction.params[0]]);

          fields[instruction.params[0] - 1] = std::move(accumulator);

          for (int i = instruction.params[0] - 2; i >= 0; i--) {
            fields[i] = arg_stack.back();
            arg_stack.pop_back();
          }

          accumulator = Record(fields);
        }
        else {
          accumulator = Record();
        }
      }

      break;

    case OpCode::kMakeConstructor: {
        auto fields = std::shared_ptr<Value[]> (new Value[instruction.params[1] + 1]);

        if (instruction.params[1] > 0) {
          fields[instruction.params[1]] = std::move(accumulator);

          for (int i = instruction.params[1] - 1; i > 0; i--) {
            fields[i] = arg_stack.back();
            arg_stack.pop_back();
          }
        }
        fields[0] = instruction.params[0];

        accumulator = Record(fields);
      }

      break;

    case OpCode::kGetField: {
        auto fields = std::get<Record>(std::move(accumulator)).fields;
        accumulator = fields[instruction.params[0]];
      }

      break;

    case OpCode::kHandle:
      meta_stack.emplace_back(
          MetaStackFrame(
              fresh_label, environment,
              list::Cons(ReturnAddress(instruction.params[1], environment), std::move(return_stack)),
              instruction.params[0])
          );

      environment = list::Cons(Value(fresh_label), std::move(environment));
      fresh_label++;
      break;

    case OpCode::kEndHandle: {
        auto meta_stack_frame = std::move(meta_stack.back());
        meta_stack.pop_back();
        environment = std::move(meta_stack_frame.environment);
        return_stack = std::move(meta_stack_frame.return_stack);
      }
      break;

    case OpCode::kOp: {
        HeliumInt instance = std::get<HeliumInt>(list::Nth(instruction.params[0], environment));
        std::vector<MetaStackFrame> reified_meta_stack;
        MetaStackFrame meta_stack_frame;

        do {
          meta_stack_frame = std::move(meta_stack.back());
          meta_stack.pop_back();
          std::swap(return_stack, meta_stack_frame.return_stack);
          reified_meta_stack.push_back(meta_stack_frame);
        } while (meta_stack_frame.label != instance);

        environment = list::Cons(std::move(accumulator),
                                list::Cons(Value(std::make_shared<Resumption>(
                                                instruction_pointer,
                                                environment, std::move(reified_meta_stack))),
                                            meta_stack_frame.environment));

        instruction_pointer = meta_stack_frame.handler_pointer;
      }

      break;

    case OpCode::kExit:
      stop = true;
      break;
    case OpCode::kExitWith:
      exit_code = (int) std::get<HeliumInt>(accumulator);
      stop = true;
      break;
    }

    while (!ManagedObject::garbage_lists.empty() ||
           !ManagedObject::garbage_shared_arrays.empty()) {
      trash_bin_lists.swap(ManagedObject::garbage_lists);
      trash_bin_lists.clear();

      trash_bin_shared_arrays.swap(ManagedObject::garbage_shared_arrays);
      trash_bin_shared_arrays.clear();
    }
  }

  if (exit_code != 0)
    return exit_code;
  else
    return accumulator;
}

Result Run(Program program) {
  return Run(0, nullptr, program);
}


ExitCode Execute(int argc, char* argv[], Program program) {
  ExitCode exit_code = 0;

  {
    auto res = Run(argc, argv, program);
    if (std::holds_alternative<ExitCode>(res))
      exit_code = std::get<ExitCode>(res);
  }

  std::vector<std::shared_ptr<Value[]>> trash_bin_shared_arrays;
  std::vector<list::List<Value>> trash_bin_lists;

  while (!ManagedObject::garbage_lists.empty() ||
         !ManagedObject::garbage_shared_arrays.empty()) {
    trash_bin_lists.swap(ManagedObject::garbage_lists);
    trash_bin_lists.clear();

    trash_bin_shared_arrays.swap(ManagedObject::garbage_shared_arrays);
    trash_bin_shared_arrays.clear();
  }

  return exit_code;
}

} // namespace hvm