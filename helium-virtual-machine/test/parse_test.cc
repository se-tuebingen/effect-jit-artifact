#include <gtest/gtest-death-test.h>
#include <gtest/gtest.h>
#include "../parse.h"

namespace hvm {

void ComparePrograms(Program program1, Program program2) {
  ASSERT_EQ(program1.size(), program2.size());

  for (size_t i = 0; i < program1.size(); i++)
  {
    ASSERT_EQ(program1[i].op_code, program2[i].op_code);

    switch (program1[i].op_code) {
      case OpCode::kCallExtern:
        ASSERT_EQ(program1[i].extern_function_arity, program2[i].extern_function_arity);
        [[fallthrough]];
      case OpCode::kConstString:
        ASSERT_EQ(program1[i].string_param, program2[i].string_param);
        break;
      case OpCode::kPrim:
        ASSERT_EQ(program1[i].prim_code, program2[i].prim_code);
        break;
      case OpCode::kPrimUnary:
        ASSERT_EQ(program1[i].prim_unary_code, program2[i].prim_unary_code);
        [[fallthrough]];
      default:
        ASSERT_EQ(program1[i].params_count, program2[i].params_count);

        for (size_t j = 0; j < program1[i].params_count; j++)
          ASSERT_EQ(program1[i].params[j], program2[i].params[j]);
    }
  }
}

TEST(ParseTest, Parse1) {
  Program program1 = {
    { OpCode::kMakeClosure, 7, 1 },
    { OpCode::kLet },
    { OpCode::kConstInt, 5 },
    { OpCode::kPush },
    { OpCode::kAccessVar, 0 },
    { OpCode::kCall },
    { OpCode::kExit },
    { OpCode::kAccessVar, 0 },
    { OpCode::kJumpNonZero, 11 },
    { OpCode::kConstInt, 1 },
    { OpCode::kReturn },
    { OpCode::kPush },
    { OpCode::kPush },
    { OpCode::kConstInt, 1 },
    { OpCode::kPrim, PrimCode::kSub },
    { OpCode::kPush },
    { OpCode::kAccessVar, 1 },
    { OpCode::kCall },
    { OpCode::kPrim, PrimCode::kMult },
    { OpCode::kReturn },
  };

  Program program2 = Parse("../../test/parse_test1.txt");

  ComparePrograms(program1, program2);
}

TEST(ParseTest, Parse2) {
  Program program1 = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPush },
    { OpCode::kMakeRecursiveBinding, {1, 1, 2, 2, 3, 3} },
    { OpCode::kCallExtern, "to_string", 1 },
    { OpCode::kAccessVar, 2 },
    { OpCode::kPrimUnary, PrimUnaryCode::kNot },
    { OpCode::kPrimUnary, PrimUnaryCode::kNeg },
    { OpCode::kPrim, PrimCode::kAdd },
    { OpCode::kPrim, PrimCode::kLe },
    { OpCode::kPrim, PrimCode::kEq },
    { OpCode::kMakeClosure, 33, 3 },
    { OpCode::kLet },
    { OpCode::kPrim, PrimCode::kAnd },
    { OpCode::kPrim, PrimCode::kOr },
    { OpCode::kConstString, " " },
    { OpCode::kPrim, PrimCode::kSub },
    { OpCode::kPrim, PrimCode::kMult },
    { OpCode::kPrim, PrimCode::kXor },
    { OpCode::kMakeConstructor, 0, 0 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLeConst, 3 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLtConst, 4 },
    { OpCode::kPrim, PrimCode::kDiv },
    { OpCode::kEndLet },
    { OpCode::kCall },
    { OpCode::kMakeConstructor, 5, 6 },
    { OpCode::kConstString, "" },
    { OpCode::kPrim, PrimCode::kLt },
    { OpCode::kPrim, PrimCode::kNeq },
    { OpCode::kPrimUnary, PrimUnaryCode::kGtConst, 5 },
    { OpCode::kCreateGlobal },
    { OpCode::kPrimUnary, PrimUnaryCode::kGeConst, 6 },
    { OpCode::kMakeRecursiveBinding },
    { OpCode::kCallExtern, "pi", 0 },
    { OpCode::kMakeRecord, 5 },
    { OpCode::kReturn },
    { OpCode::kHandle, 43, 99 },
    { OpCode::kEndHandle },
    { OpCode::kPrimUnary, PrimUnaryCode::kEqConst, 5 },
    { OpCode::kSwitch, 1, 2 },
    { OpCode::kPrimUnary, PrimUnaryCode::kNeqConst, 0 },
    { OpCode::kMakeRecursiveBinding, 44, 1 },
    { OpCode::kAccessGlobal, 5 },
    { OpCode::kGetField, 3 },
    { OpCode::kTailCallLocal, 11 },
    { OpCode::kJump, 23 },
    { OpCode::kTailCallGlobal, 15 },
    { OpCode::kPrimUnary, PrimUnaryCode::kAndConst, 3 },
    { OpCode::kPrimUnary, PrimUnaryCode::kOrConst, 4 },
    { OpCode::kMatch, {11, 22, 33} },
    { OpCode::kPrimUnary, PrimUnaryCode::kXorConst, 6 },
    { OpCode::kPrim, PrimCode::kGe },
    { OpCode::kConstString, "Konrad Werblinski" },
    { OpCode::kPrimUnary, PrimUnaryCode::kAddConst, 1 },
    { OpCode::kPrimUnary, PrimUnaryCode::kSubConst, 2 },
    { OpCode::kPrimUnary, PrimUnaryCode::kSubFromConst, 3 },
    { OpCode::kPrimUnary, PrimUnaryCode::kMultByConst, 4 },
    { OpCode::kAccessRecursiveBinding, 5 },
    { OpCode::kCallExtern, "Ackerman", 2 },
    { OpCode::kCallGlobal, 10 },
    { OpCode::kJumpZero, 22 },
    { OpCode::kJumpNonZero, 21 },
    { OpCode::kOp, 5 },
    { OpCode::kPrim, PrimCode::kXor },
    { OpCode::kPrim, PrimCode::kGt },
    { OpCode::kMatch, 7 },
    { OpCode::kTailCall },
    { OpCode::kCallLocal, 5 },
    { OpCode::kPrim, PrimCode::kMod },
    { OpCode::kExitWith },
    { OpCode::kPrimUnary, PrimUnaryCode::kDivByConst, 5 },
    { OpCode::kPrimUnary, PrimUnaryCode::kDivConstBy, 6 },
    { OpCode::kPrimUnary, PrimUnaryCode::kModByConst, 7 },
    { OpCode::kPrimUnary, PrimUnaryCode::kModConstBy, 8 },
    { OpCode::kConstString, "Judas Priest\nThe Sentinel"},
    { OpCode::kPrim, PrimCode::kLsl },
    { OpCode::kPrim, PrimCode::kLsr },
    { OpCode::kPrim, PrimCode::kAsr },
    { OpCode::kPrimUnary, PrimUnaryCode::kLslConst, 1 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLsrConst, 2 },
    { OpCode::kPrimUnary, PrimUnaryCode::kAsrConst, 3 },
    { OpCode::kCallRecursiveBinding, 5, 1 },
    { OpCode::kTailCallRecursiveBinding, 66, 6 },
    { OpCode::kExit }
  };

  Program program2 = Parse("../../test/parse_test2.txt");

  ComparePrograms(program1, program2);
}

} // namespace hvm