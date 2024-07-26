#ifndef INSTRUCTION_SET_H_
#define INSTRUCTION_SET_H_

#include "value.h"
#include <memory>
#include <string>
#include <vector>

namespace hvm {

enum class PrimCode : short {
  kAdd,
  kSub,
  kMult,
  kDiv,
  kMod,
  kEq,
  kNeq,
  kLt,
  kLe,
  kGt,
  kGe,
  kAnd,
  kOr,
  kXor,
  kLsl,
  kLsr,
  kAsr
};

enum class PrimUnaryCode : short {
  kNeg,
  kNot,
  kAddConst,
  kSubConst,
  kSubFromConst,
  kMultByConst,
  kDivByConst,
  kDivConstBy,
  kModByConst,
  kModConstBy,
  kEqConst,
  kNeqConst,
  kLtConst,
  kLeConst,
  kGtConst,
  kGeConst,
  kAndConst,
  kOrConst,
  kXorConst,
  kLslConst,
  kLsrConst,
  kAsrConst
};

enum class OpCode : short {
  kConstInt,
  kConstString,
  kPush,
  kAccessVar,
  kMakeClosure,
  kMakeRecursiveBinding,
  kAccessRecursiveBinding,
  kLet,
  kEndLet,
  kCreateGlobal,
  kAccessGlobal,
  kPrim,
  kPrimUnary,
  kCall,
  kTailCall,
  kCallGlobal,
  kTailCallGlobal,
  kCallLocal,
  kTailCallLocal,
  kCallRecursiveBinding,
  kTailCallRecursiveBinding,
  kCallExtern,
  kReturn,
  kHandle,
  kEndHandle,
  kMakeRecord,
  kMakeConstructor,
  kGetField,
  kJump,
  kJumpZero,
  kJumpNonZero,
  kSwitch,
  kMatch,
  kOp,
  kExit,
  kExitWith
};

struct Instruction {
  OpCode op_code;
  size_t params_count = 0;
  std::shared_ptr<HeliumInt[]> params = nullptr;
  std::string string_param = "";

  union {
    PrimCode prim_code;
    PrimUnaryCode prim_unary_code;
    size_t extern_function_arity;
  };

  void AllocParams(size_t n) {
    params_count = n;
    params = std::shared_ptr<HeliumInt[]>(new HeliumInt[n]);
  }

  Instruction() = default;
  Instruction(OpCode op_code) : op_code(op_code), params_count(0) {};
  Instruction(OpCode op_code, PrimCode prim_code) : op_code(op_code), prim_code(prim_code) {};
  Instruction(OpCode op_code, PrimUnaryCode prim_unary_code) :
    op_code(op_code), prim_unary_code(prim_unary_code) {};

  Instruction(OpCode op_code, PrimUnaryCode prim_unary_code, HeliumInt param1) :
    op_code(op_code), params_count(1), prim_unary_code(prim_unary_code) {
    params = std::shared_ptr<HeliumInt[]>(new HeliumInt[1]);
    params[0] = param1;
  };

  Instruction(OpCode op_code, std::string string_param) :
    op_code(op_code), params_count(0), string_param(string_param) {};

  Instruction(OpCode op_code, std::string extern_function_name, size_t arity) :
    op_code(op_code), params_count(0),
    string_param(extern_function_name), extern_function_arity(arity) {};

  Instruction(OpCode op_code, HeliumInt param1) : op_code(op_code), params_count(1) {
    params = std::shared_ptr<HeliumInt[]>(new HeliumInt[1]);
    params[0] = param1;
  };

  Instruction(OpCode op_code, HeliumInt param1, HeliumInt param2) : op_code(op_code), params_count(2) {
    params = std::shared_ptr<HeliumInt[]>(new HeliumInt[2]);
    params[0] = param1;
    params[1] = param2;
  };

  Instruction(OpCode op_code, std::initializer_list<HeliumInt> params) : op_code(op_code) {
    this->params = std::shared_ptr<HeliumInt[]>(new HeliumInt[params.size()]);
    params_count = params.size();

    int i = 0;
    for (auto p : params) {
      this->params[i] = p;
      i++;
    }
  }
};

using Program = std::vector<Instruction>;

} // namespace hvm

#endif  // INSTRUCTION_SET_H_