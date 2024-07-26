#include "parse.h"
#include <bits/types/FILE.h>
#include <cstddef>
#include <fstream>
#include <string>

namespace hvm {
namespace {

std::string ParseString(std::ifstream& fin, size_t n) {

  int k;
  std::string str;

  for (size_t i = 0; i < n; i++) {
    fin >> k;
    str += (char) k;
  }

  return str;
}

} // namespace

Program Parse(std::string filename) {
  std::string op_code;
  std::ifstream fin;
  Program program;

  fin.open(filename.c_str());

  while(fin.good()) {
    Instruction instr;
    fin >> op_code;

    if (op_code == "Push") {
      instr.op_code = OpCode::kPush;
    } else if (op_code == "Jump") {
      instr.op_code = OpCode::kJump;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "JumpZero") {
      instr.op_code = OpCode::kJumpZero;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "JumpNonZero") {
      instr.op_code = OpCode::kJumpNonZero;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "Switch") {
      instr.op_code = OpCode::kSwitch;
      size_t n;
      fin >> n;
      instr.AllocParams(n);
      for (size_t i = 0; i < n; i++)
        fin >> instr.params[i];
    } else if (op_code == "Match") {
      instr.op_code = OpCode::kMatch;
      size_t n;
      fin >> n;
      instr.AllocParams(n);
      for (size_t i = 0; i < n; i++)
        fin >> instr.params[i];
    } else if (op_code == "Let") {
      instr.op_code = OpCode::kLet;
    } else if (op_code == "EndLet") {
      instr.op_code = OpCode::kEndLet;
    } else if (op_code == "ConstInt") {
      instr.op_code = OpCode::kConstInt;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "ConstString") {
      instr.op_code = OpCode::kConstString;
      int n;
      fin >> n;
      instr.string_param = ParseString(fin, n);
    } else if (op_code == "CallExtern") {
      instr.op_code = OpCode::kCallExtern;
      fin >> instr.string_param;
      fin >> instr.extern_function_arity;
    } else if (op_code == "AccessVar") {
      instr.op_code = OpCode::kAccessVar;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "CreateGlobal") {
      instr.op_code = OpCode::kCreateGlobal;
    } else if (op_code == "AccessGlobal") {
      instr.op_code = OpCode::kAccessGlobal;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "Add") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kAdd;
    } else if (op_code == "Sub") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kSub;
    } else if (op_code == "Mult") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kMult;
    } else if (op_code == "Div") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kDiv;
    } else if (op_code == "Mod") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kMod;
    } else if (op_code == "Eq") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kEq;
    } else if (op_code == "Neq") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kNeq;
    } else if (op_code == "Lt") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kLt;
    } else if (op_code == "Le") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kLe;
    } else if (op_code == "Gt") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kGt;
    } else if (op_code == "Ge") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kGe;
    } else if (op_code == "And") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kAnd;
    } else if (op_code == "Or") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kOr;
    } else if (op_code == "Xor") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kXor;
    } else if (op_code == "Lsl") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kLsl;
    } else if (op_code == "Lsr") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kLsr;
    } else if (op_code == "Asr") {
      instr.op_code = OpCode::kPrim;
      instr.prim_code = PrimCode::kAsr;
    } else if (op_code == "Neg") {
      instr.op_code = OpCode::kPrimUnary;
      instr.prim_unary_code = PrimUnaryCode::kNeg;
    } else if (op_code == "Not") {
      instr.op_code = OpCode::kPrimUnary;
      instr.prim_unary_code = PrimUnaryCode::kNot;
    } else if (op_code == "AddConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kAddConst;
    } else if (op_code == "SubConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kSubConst;
    } else if (op_code == "SubFromConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kSubFromConst;
    } else if (op_code == "MultByConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kMultByConst;
    } else if (op_code == "DivByConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kDivByConst;
    } else if (op_code == "DivConstBy") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kDivConstBy;
    } else if (op_code == "ModByConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kModByConst;
    } else if (op_code == "ModConstBy") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kModConstBy;
    } else if (op_code == "EqConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kEqConst;
    } else if (op_code == "NeqConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kNeqConst;
    } else if (op_code == "LtConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kLtConst;
    } else if (op_code == "LeConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kLeConst;
    } else if (op_code == "GtConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kGtConst;
    } else if (op_code == "GeConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kGeConst;
    } else if (op_code == "AndConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kAndConst;
    } else if (op_code == "OrConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kOrConst;
    } else if (op_code == "XorConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kXorConst;
    } else if (op_code == "LslConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kLslConst;
    } else if (op_code == "LsrConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kLsrConst;
    } else if (op_code == "AsrConst") {
      instr.op_code = OpCode::kPrimUnary;
      instr.AllocParams(1);
      fin >> instr.params[0];
      instr.prim_unary_code = PrimUnaryCode::kAsrConst;
    } else if (op_code == "MakeClosure") {
      instr.op_code = OpCode::kMakeClosure;
      instr.AllocParams(2);
      fin >> instr.params[0];
      fin >> instr.params[1];
    } else if (op_code == "Call") {
      instr.op_code = OpCode::kCall;
    } else if (op_code == "TailCall") {
      instr.op_code = OpCode::kTailCall;
    } else if (op_code == "CallGlobal") {
      instr.op_code = OpCode::kCallGlobal;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "TailCallGlobal") {
      instr.op_code = OpCode::kTailCallGlobal;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "CallLocal") {
      instr.op_code = OpCode::kCallLocal;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "TailCallLocal") {
      instr.op_code = OpCode::kTailCallLocal;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "CallRecursiveBinding") {
      instr.op_code = OpCode::kCallRecursiveBinding;
      instr.AllocParams(2);
      fin >> instr.params[0];
      fin >> instr.params[1];
    } else if (op_code == "TailCallRecursiveBinding") {
      instr.op_code = OpCode::kTailCallRecursiveBinding;
      instr.AllocParams(2);
      fin >> instr.params[0];
      fin >> instr.params[1];
    } else if (op_code == "MakeRecursiveBinding") {
      instr.op_code = OpCode::kMakeRecursiveBinding;
      size_t n;
      fin >> n;
      instr.AllocParams(2 * n);
      for (size_t i = 0; i < 2 * n; i++)
        fin >> instr.params[i];
    } else if (op_code == "AccessRecursiveBinding") {
      instr.op_code = OpCode::kAccessRecursiveBinding;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "Return") {
      instr.op_code = OpCode::kReturn;
    } else if (op_code == "MakeRecord") {
      instr.op_code = OpCode::kMakeRecord;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "MakeConstructor") {
      instr.op_code = OpCode::kMakeConstructor;
      instr.AllocParams(2);
      fin >> instr.params[0];
      fin >> instr.params[1];
    } else if (op_code == "GetField") {
      instr.op_code = OpCode::kGetField;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "Handle") {
      instr.op_code = OpCode::kHandle;
      instr.AllocParams(2);
      fin >> instr.params[0];
      fin >> instr.params[1];
    } else if (op_code == "EndHandle") {
      instr.op_code = OpCode::kEndHandle;
    } else if (op_code == "Op") {
      instr.op_code = OpCode::kOp;
      instr.AllocParams(1);
      fin >> instr.params[0];
    } else if (op_code == "Exit") {
      instr.op_code = OpCode::kExit;
    } else if (op_code == "ExitWith") {
      instr.op_code = OpCode::kExitWith;
    } else if (op_code[0] == '#') {

      if (op_code.length() > 1 && op_code[op_code.length() - 1] == '#')
        continue;

      char c;
      do {
        fin >> c;
      } while (c != '#');

      continue;
    } else {
      continue;
    }

    program.push_back(instr);
  }

  fin.close();
  return program;
}

} // namespace hvm
