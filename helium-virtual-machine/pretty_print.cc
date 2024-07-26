#include "pretty_print.h"
#include "value.h"
#include <cassert>
#include <cstddef>
#include <string>

namespace hvm {

std::string PrettyPrintPrimCode(PrimCode prim_code) {
  switch (prim_code) {
    case PrimCode::kAdd:  return "Add";
    case PrimCode::kSub:  return "Sub";
    case PrimCode::kMult: return "Mult";
    case PrimCode::kDiv:  return "Div";
    case PrimCode::kMod:  return "Mod";
    case PrimCode::kEq:   return "Eq";
    case PrimCode::kNeq:  return "Neq";
    case PrimCode::kLt:   return "Lt";
    case PrimCode::kLe:   return "Le";
    case PrimCode::kGt:   return "Gt";
    case PrimCode::kGe:   return "Ge";
    case PrimCode::kAnd:  return "And";
    case PrimCode::kOr:   return "Or";
    case PrimCode::kXor:  return "Xor";
    case PrimCode::kLsl:  return "Lsl";
    case PrimCode::kLsr:  return "Lsr";
    case PrimCode::kAsr:  return "Asr";
    default: assert(false); // To silence GCC warning
  }
}

std::string PrettyPrintPrimUnaryCode(PrimUnaryCode prim_unary_code, HeliumInt params[]) {
  switch (prim_unary_code) {
    case PrimUnaryCode::kNot:          return "Not";
    case PrimUnaryCode::kNeg:          return "Neg";
    case PrimUnaryCode::kAddConst:     return "AddConst " + std::to_string(params[0]);
    case PrimUnaryCode::kSubConst:     return "SubConst " + std::to_string(params[0]);
    case PrimUnaryCode::kSubFromConst: return "SubFromConst " + std::to_string(params[0]);
    case PrimUnaryCode::kMultByConst:  return "MultByConst " + std::to_string(params[0]);
    case PrimUnaryCode::kDivByConst:   return "DivByConst " + std::to_string(params[0]);
    case PrimUnaryCode::kDivConstBy:   return "DivConstBy " + std::to_string(params[0]);
    case PrimUnaryCode::kModByConst:   return "ModByConst " + std::to_string(params[0]);
    case PrimUnaryCode::kModConstBy:   return "ModConstBy " + std::to_string(params[0]);
    case PrimUnaryCode::kEqConst:      return "EqConst " + std::to_string(params[0]);
    case PrimUnaryCode::kNeqConst:     return "NeqConst " + std::to_string(params[0]);
    case PrimUnaryCode::kLtConst:      return "LtConst " + std::to_string(params[0]);
    case PrimUnaryCode::kLeConst:      return "LeConst " + std::to_string(params[0]);
    case PrimUnaryCode::kGtConst:      return "GtConst " + std::to_string(params[0]);
    case PrimUnaryCode::kGeConst:      return "GeConst " + std::to_string(params[0]);
    case PrimUnaryCode::kAndConst:     return "AndConst " + std::to_string(params[0]);
    case PrimUnaryCode::kOrConst:      return "OrConst " + std::to_string(params[0]);
    case PrimUnaryCode::kXorConst:     return "XorConst " + std::to_string(params[0]);
    case PrimUnaryCode::kLslConst:     return "LslConst " + std::to_string(params[0]);
    case PrimUnaryCode::kLsrConst:     return "LsrConst " + std::to_string(params[0]);
    case PrimUnaryCode::kAsrConst:     return "AsrConst " + std::to_string(params[0]);
    default: assert(false); // To silence GCC warning
  }
}

std::string PrettyPrintProgram(Program program) {
  std::string res;

  for (size_t i = 0; i < program.size(); i++) {
    Instruction instruction = program[i];

    switch (instruction.op_code) {
      case OpCode::kPush:
        res += "Push\n";
        break;
      case OpCode::kJump:
        res += "Jump " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kJumpZero:
        res += "JumpZero " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kJumpNonZero:
        res += "JumpNonZero " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kSwitch:
        res += "kSwitch";

        for (size_t j = 0; j < instruction.params_count; j++) {
          res += " ";
          res += std::to_string(instruction.params[j]);
        }

        res += "\n";
        break;
      case OpCode::kMatch:
        res += "Match";

        for (size_t j = 0; j < instruction.params_count; j++) {
          res += " ";
          res += std::to_string(instruction.params[j]);
        }

        res += "\n";
        break;
      case OpCode::kLet:
        res += "Let\n";
        break;
      case OpCode::kEndLet:
        res += "EndLet\n";
        break;
      case OpCode::kCreateGlobal:
        res += "CreateGlobal\n";
        break;
      case OpCode::kAccessGlobal:
        res += "AccessGlobal " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kConstInt:
        res += "ConstInt " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kConstString:
        res += "ConstString \"" + instruction.string_param + "\"\n";
        break;
      case OpCode::kCallExtern:
        res += "CallExtern " + instruction.string_param + "/" +
          std::to_string(instruction.extern_function_arity) + "\n";
        break;
      case OpCode::kAccessVar:
        res += "AccessVar " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kPrim:
        res += PrettyPrintPrimCode(instruction.prim_code) + "\n";
        break;
      case OpCode::kPrimUnary:
        res += PrettyPrintPrimUnaryCode(instruction.prim_unary_code,
                                        instruction.params.get()) + "\n";
        break;
      case OpCode::kMakeClosure:
        res += "MakeClosure " + std::to_string(instruction.params[0]) + " "
                              + std::to_string(instruction.params[1]) + "\n";
        break;
      case OpCode::kMakeRecursiveBinding:
        res += "MakeRecursiveBinding";

        for (size_t j = 0; j < instruction.params_count; j++) {
          res += " ";
          res += std::to_string(instruction.params[j]);
        }

        res += "\n";
        break;
      case OpCode::kAccessRecursiveBinding:
        res += "AccessRecursiveBinding " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kCall:
        res += "Call\n";
        break;
      case OpCode::kTailCall:
        res += "TailCall\n";
        break;
      case OpCode::kCallGlobal:
        res += "CallGlobal " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kTailCallGlobal:
        res += "TailCallGlobal " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kCallLocal:
        res += "CallLocal " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kTailCallLocal:
        res += "TailCallLocal " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kCallRecursiveBinding:
        res += "CallRecursiveBinding " + std::to_string(instruction.params[0]) + " "
                                       + std::to_string(instruction.params[1]) + "\n";
        break;
      case OpCode::kTailCallRecursiveBinding:
        res += "TailCallRecursiveBinding " + std::to_string(instruction.params[0]) + " "
                                           + std::to_string(instruction.params[1]) + "\n";
        break;
      case OpCode::kReturn:
        res += "Return\n";
        break;
      case OpCode::kMakeRecord:
        res += "MakeRecord " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kMakeConstructor:
        res += "MakeConstructor " + std::to_string(instruction.params[0]) + " "
                                  + std::to_string(instruction.params[1]) + "\n";
        break;
      case OpCode::kGetField:
        res += "GetField " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kHandle:
        res += "Handle " +
          std::to_string(instruction.params[0]) + " " +
          std::to_string(instruction.params[1]) + "\n";
        break;
      case OpCode::kEndHandle:
        res += "EndHandle\n";
        break;
      case OpCode::kOp:
        res += "Op " + std::to_string(instruction.params[0]) + "\n";
        break;
      case OpCode::kExit:
        res += "Exit\n";
        break;
      case OpCode::kExitWith:
        res += "ExitWith\n";
        break;
    }
  }

  return res;
};

std::string PrettyPrintValue(Value value) {
  if (std::holds_alternative<HeliumInt>(value))
    return std::to_string(std::get<HeliumInt>(value));
  if (std::holds_alternative<std::string>(value))
    return "\"" + std::get<std::string>(value) + "\"";
  if (std::holds_alternative<Record>(value))
    return "Record";
  if (std::holds_alternative<std::shared_ptr<Closure>>(value))
    return "Closure";
  if (std::holds_alternative<std::shared_ptr<RecursiveBinding>>(value))
    return "RecursiveBinding";

  return "";
}

} // namespace hvm
