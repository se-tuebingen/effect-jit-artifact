#include <gtest/gtest.h>
#include "../machine.h"

namespace hvm {

TEST(MachineTest, ConstInt1) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, ConstInt2) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kConstInt, 42 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(42)));
}

TEST(MachineTest, ConstString1) {
  Program program = {
    { OpCode::kConstString, "44" },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("44")));
}

TEST(MachineTest, ConstString2) {
  Program program = {
    { OpCode::kConstString, "44" },
    { OpCode::kConstString, "" },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("")));
}

TEST(MachineTest, ConstString3) {
  Program program = {
    { OpCode::kConstString, "44" },
    { OpCode::kLet },
    { OpCode::kConstString, "" },
    { OpCode::kAccessVar, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("44")));
}

TEST(MachineTest, Let1) {
  Program program = {
    { OpCode::kConstInt, 55 },
    { OpCode::kLet },
    { OpCode::kAccessVar, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(55)));
}

TEST(MachineTest, Let2) {
  Program program = {
    { OpCode::kConstInt, 1 },
    { OpCode::kLet },
    { OpCode::kConstInt, 2 },
    { OpCode::kLet },
    { OpCode::kConstInt, 3 },
    { OpCode::kLet },
    { OpCode::kConstInt, 4 },
    { OpCode::kLet },
    { OpCode::kEndLet },
    { OpCode::kAccessVar, 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(2)));
}

TEST(MachineTest, Let3) {
  Program program = {
    { OpCode::kConstInt, 1 },
    { OpCode::kLet },
    { OpCode::kConstInt, 2 },
    { OpCode::kLet },
    { OpCode::kConstInt, 3 },
    { OpCode::kLet },
    { OpCode::kConstInt, 4 },
    { OpCode::kLet },
    { OpCode::kEndLet },
    { OpCode::kAccessVar, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(3)));
}

TEST(MachineTest, Let4) {
  Program program = {
    { OpCode::kConstInt, 1 },
    { OpCode::kLet },
    { OpCode::kConstInt, 2 },
    { OpCode::kLet },
    { OpCode::kConstInt, 3 },
    { OpCode::kLet },
    { OpCode::kConstInt, 4 },
    { OpCode::kLet },
    { OpCode::kEndLet },
    { OpCode::kEndLet },
    { OpCode::kEndLet },
    { OpCode::kAccessVar, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Let5) {
  Program program = {
    { OpCode::kEndLet },
    { OpCode::kExit }
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, Let6) {
  Program program = {
    { OpCode::kConstInt, 1 },
    { OpCode::kLet },
    { OpCode::kEndLet },
    { OpCode::kEndLet },
    { OpCode::kExit }
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, Let7) {
  Program program = {
    { OpCode::kConstInt, 1 },
    { OpCode::kAccessVar, 1 },
    { OpCode::kExit }
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, Let8) {
  Program program = {
    { OpCode::kConstInt, 55 },
    { OpCode::kLet },
    { OpCode::kAccessVar, 0 },
    { OpCode::kEndLet },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(55)));
}

TEST(MachineTest, Jump1) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kJump, 9 },
  /*  3 */ { OpCode::kConstInt, 2 },
  /*  4 */ { OpCode::kLet },
  /*  5 */ { OpCode::kConstInt, 3 },
  /*  6 */ { OpCode::kLet },
  /*  7 */ { OpCode::kConstInt, 4 },
  /*  8 */ { OpCode::kLet },
  /*  9 */ { OpCode::kAccessVar, 0 },
  /* 10 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Jump2) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kJumpNonZero, 9 },
  /*  3 */ { OpCode::kConstInt, 2 },
  /*  4 */ { OpCode::kLet },
  /*  5 */ { OpCode::kConstInt, 3 },
  /*  6 */ { OpCode::kLet },
  /*  7 */ { OpCode::kConstInt, 4 },
  /*  8 */ { OpCode::kLet },
  /*  9 */ { OpCode::kAccessVar, 0 },
  /* 10 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Jump3) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kJumpZero, 9 },
  /*  3 */ { OpCode::kConstInt, 2 },
  /*  4 */ { OpCode::kLet },
  /*  5 */ { OpCode::kConstInt, 3 },
  /*  6 */ { OpCode::kLet },
  /*  7 */ { OpCode::kConstInt, 4 },
  /*  8 */ { OpCode::kLet },
  /*  9 */ { OpCode::kAccessVar, 0 },
  /* 10 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(4)));
}

TEST(MachineTest, Jump4) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 0 },
  /* 1 */ { OpCode::kLet },
  /* 2 */ { OpCode::kJumpZero, 5 },
  /* 3 */ { OpCode::kConstInt, 2 },
  /* 4 */ { OpCode::kLet },
  /* 5 */ { OpCode::kAccessVar, 0 },
  /* 6 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Jump5) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 1 },
  /* 1 */ { OpCode::kLet },
  /* 2 */ { OpCode::kJumpZero, 5 },
  /* 3 */ { OpCode::kConstInt, 2 },
  /* 4 */ { OpCode::kLet },
  /* 5 */ { OpCode::kAccessVar, 0 },
  /* 6 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(2)));
}

TEST(MachineTest, Switch1) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 0 },
  /* 1 */ { OpCode::kSwitch, {2, 4, 6} },
  /* 2 */ { OpCode::kConstInt, 11 },
  /* 3 */ { OpCode::kJump, 7 },
  /* 4 */ { OpCode::kConstInt, 22 },
  /* 5 */ { OpCode::kJump, 7 },
  /* 6 */ { OpCode::kConstInt, 33 },
  /* 7 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(11)));
}

TEST(MachineTest, Switch2) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 1 },
  /* 1 */ { OpCode::kSwitch, {2, 4, 6} },
  /* 2 */ { OpCode::kConstInt, 11 },
  /* 3 */ { OpCode::kJump, 7 },
  /* 4 */ { OpCode::kConstInt, 22 },
  /* 5 */ { OpCode::kJump, 7 },
  /* 6 */ { OpCode::kConstInt, 33 },
  /* 7 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(22)));
}

TEST(MachineTest, Switch3) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 2 },
  /* 1 */ { OpCode::kSwitch, {2, 4, 6} },
  /* 2 */ { OpCode::kConstInt, 11 },
  /* 3 */ { OpCode::kJump, 7 },
  /* 4 */ { OpCode::kConstInt, 22 },
  /* 5 */ { OpCode::kJump, 7 },
  /* 6 */ { OpCode::kConstInt, 33 },
  /* 7 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(33)));
}

TEST(MachineTest, Match1) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 0 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 55 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 66 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kConstInt, 77 },
  /*  7 */ { OpCode::kMakeRecord, 4 },
  /*  8 */ { OpCode::kMatch, {9, 11, 13} },
  /*  9 */ { OpCode::kGetField, 1 },
  /* 10 */ { OpCode::kJump, 14 },
  /* 11 */ { OpCode::kGetField, 2 },
  /* 12 */ { OpCode::kJump, 14 },
  /* 13 */ { OpCode::kGetField, 3 },
  /* 14 */ { OpCode::kEndLet },
  /* 15 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(55)));
}

TEST(MachineTest, Match2) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 1 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 55 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 66 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kConstInt, 77 },
  /*  7 */ { OpCode::kMakeRecord, 4 },
  /*  8 */ { OpCode::kMatch, {9, 11, 13} },
  /*  9 */ { OpCode::kGetField, 1 },
  /* 10 */ { OpCode::kJump, 14 },
  /* 11 */ { OpCode::kGetField, 2 },
  /* 12 */ { OpCode::kJump, 14 },
  /* 13 */ { OpCode::kGetField, 3 },
  /* 14 */ { OpCode::kEndLet },
  /* 15 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(66)));
}

TEST(MachineTest, Match3) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 2 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 55 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 66 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kConstInt, 77 },
  /*  7 */ { OpCode::kMakeRecord, 4 },
  /*  8 */ { OpCode::kMatch, {9, 11, 13} },
  /*  9 */ { OpCode::kGetField, 1 },
  /* 10 */ { OpCode::kJump, 14 },
  /* 11 */ { OpCode::kGetField, 2 },
  /* 12 */ { OpCode::kJump, 14 },
  /* 13 */ { OpCode::kGetField, 3 },
  /* 14 */ { OpCode::kEndLet },
  /* 15 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(77)));
}

TEST(MachineTest, Match4) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 0 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 55 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 66 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kConstInt, 77 },
  /*  7 */ { OpCode::kMakeRecord, 4 },
  /*  8 */ { OpCode::kMatch, {9, 12, 15} },
  /*  9 */ { OpCode::kAccessVar, 0 },
  /* 10 */ { OpCode::kGetField, 1 },
  /* 11 */ { OpCode::kJump, 14 },
  /* 12 */ { OpCode::kAccessVar, 0 },
  /* 13 */ { OpCode::kGetField, 2 },
  /* 14 */ { OpCode::kJump, 17 },
  /* 15 */ { OpCode::kAccessVar, 0 },
  /* 16 */ { OpCode::kGetField, 3 },
  /* 17 */ { OpCode::kEndLet },
  /* 18 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(55)));
}

TEST(MachineTest, Match5) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 1 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 55 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 66 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kConstInt, 77 },
  /*  7 */ { OpCode::kMakeRecord, 4 },
  /*  8 */ { OpCode::kMatch, {9, 12, 15} },
  /*  9 */ { OpCode::kAccessVar, 0 },
  /* 10 */ { OpCode::kGetField, 1 },
  /* 11 */ { OpCode::kJump, 14 },
  /* 12 */ { OpCode::kAccessVar, 0 },
  /* 13 */ { OpCode::kGetField, 2 },
  /* 14 */ { OpCode::kJump, 17 },
  /* 15 */ { OpCode::kAccessVar, 0 },
  /* 16 */ { OpCode::kGetField, 3 },
  /* 17 */ { OpCode::kEndLet },
  /* 18 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(66)));
}

TEST(MachineTest, Match6) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 2 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 55 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 66 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kConstInt, 77 },
  /*  7 */ { OpCode::kMakeRecord, 4 },
  /*  8 */ { OpCode::kMatch, {9, 12, 15} },
  /*  9 */ { OpCode::kAccessVar, 0 },
  /* 10 */ { OpCode::kGetField, 1 },
  /* 11 */ { OpCode::kJump, 14 },
  /* 12 */ { OpCode::kAccessVar, 0 },
  /* 13 */ { OpCode::kGetField, 2 },
  /* 14 */ { OpCode::kJump, 17 },
  /* 15 */ { OpCode::kAccessVar, 0 },
  /* 16 */ { OpCode::kGetField, 3 },
  /* 17 */ { OpCode::kEndLet },
  /* 18 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(77)));
}

TEST(MachineTest, Match7) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 0 },
  /* 1 */ { OpCode::kMatch, {2, 4, 6} },
  /* 2 */ { OpCode::kConstInt, 55 },
  /* 3 */ { OpCode::kJump, 7 },
  /* 4 */ { OpCode::kConstInt, 66 },
  /* 5 */ { OpCode::kJump, 7 },
  /* 6 */ { OpCode::kConstInt, 77},
  /* 7 */ { OpCode::kEndLet },
  /* 8 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(55)));
}

TEST(MachineTest, Match8) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 1 },
  /* 1 */ { OpCode::kMatch, {2, 4, 6} },
  /* 2 */ { OpCode::kConstInt, 55 },
  /* 3 */ { OpCode::kJump, 7 },
  /* 4 */ { OpCode::kConstInt, 66 },
  /* 5 */ { OpCode::kJump, 7 },
  /* 6 */ { OpCode::kConstInt, 77},
  /* 7 */ { OpCode::kEndLet },
  /* 8 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(66)));
}

TEST(MachineTest, Match9) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 2 },
  /* 1 */ { OpCode::kMatch, {2, 4, 6} },
  /* 2 */ { OpCode::kConstInt, 55 },
  /* 3 */ { OpCode::kJump, 7 },
  /* 4 */ { OpCode::kConstInt, 66 },
  /* 5 */ { OpCode::kJump, 7 },
  /* 6 */ { OpCode::kConstInt, 77},
  /* 7 */ { OpCode::kEndLet },
  /* 8 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(77)));
}

TEST(MachineTest, Prim1) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPrim, PrimCode::kAdd },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(86)));
}

TEST(MachineTest, Prim2) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPrim, PrimCode::kSub },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(-2)));
}

TEST(MachineTest, Prim3) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 42 },
    { OpCode::kPrim, PrimCode::kSub },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(2)));
}

TEST(MachineTest, Prim4) {
  Program program = {
    { OpCode::kConstInt, 11 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kMult },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, Prim5) {
  Program program = {
    { OpCode::kConstInt, 11 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kMult },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, Prim6) {
  Program program = {
    { OpCode::kConstInt, 11 },
    { OpCode::kPush },
    { OpCode::kConstInt, 55 },
    { OpCode::kPrim, PrimCode::kDiv },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Prim7) {
  Program program = {
    { OpCode::kConstInt, 55 },
    { OpCode::kPush },
    { OpCode::kConstInt, 11 },
    { OpCode::kPrim, PrimCode::kDiv },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, Prim8) {
  Program program = {
    { OpCode::kConstInt, 22 },
    { OpCode::kPush },
    { OpCode::kConstInt, 10 },
    { OpCode::kPrim, PrimCode::kDiv },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(2)));
}

TEST(MachineTest, Prim9) {
  Program program = {
    { OpCode::kConstInt, 1756 },
    { OpCode::kPush },
    { OpCode::kConstInt, 35 },
    { OpCode::kPrim, PrimCode::kMod },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(6)));
}

TEST(MachineTest, Prim10) {
  Program program = {
    { OpCode::kConstInt, 444 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kMod },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}


TEST(MachineTest, Prim11) {
  Program program = {
    { OpCode::kConstInt, 444 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kDiv },
    { OpCode::kPush },
    { OpCode::kConstInt, 9 },
    { OpCode::kPrim, PrimCode::kSub },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(102)));
}

TEST(MachineTest, Prim12) {
  Program program = {
    { OpCode::kConstInt, 1756 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 42 },
    { OpCode::kPrim, PrimCode::kAdd },
    { OpCode::kPrim, PrimCode::kMod },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, Prim13) {
  Program program = {
    { OpCode::kConstInt, 1756 },
    { OpCode::kPrim, PrimCode::kAdd },
    { OpCode::kExit }
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, Prim15) {
  Program program = {
    { OpCode::kConstInt, 6 },
    { OpCode::kPush },
    { OpCode::kConstInt, 8 },
    { OpCode::kPrim, PrimCode::kLt },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Prim16) {
  Program program = {
    { OpCode::kConstInt, 4 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kLt },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Prim17) {
  Program program = {
    { OpCode::kConstInt, 444 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kLt },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Prim18) {
  Program program = {
    { OpCode::kConstInt, 6 },
    { OpCode::kPush },
    { OpCode::kConstInt, 8 },
    { OpCode::kPrim, PrimCode::kLe },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Prim19) {
  Program program = {
    { OpCode::kConstInt, 4 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kLe },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Prim20) {
  Program program = {
    { OpCode::kConstInt, 444 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kLe },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Prim21) {
  Program program = {
    { OpCode::kConstInt, 6 },
    { OpCode::kPush },
    { OpCode::kConstInt, 8 },
    { OpCode::kPrim, PrimCode::kGt },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Prim22) {
  Program program = {
    { OpCode::kConstInt, 4 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kGt },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Prim23) {
  Program program = {
    { OpCode::kConstInt, 444 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kGt },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Prim24) {
  Program program = {
    { OpCode::kConstInt, 6 },
    { OpCode::kPush },
    { OpCode::kConstInt, 8 },
    { OpCode::kPrim, PrimCode::kGe },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Prim25) {
  Program program = {
    { OpCode::kConstInt, 4 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kGe },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Prim26) {
  Program program = {
    { OpCode::kConstInt, 444 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kGe },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Prim27) {
  Program program = {
    { OpCode::kConstInt, 444 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kEq },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Prim28) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPrim, PrimCode::kEq },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Prim29) {
  Program program = {
    { OpCode::kConstInt, 444 },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kPrim, PrimCode::kNeq },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Prim30) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPrim, PrimCode::kNeq },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Prim31) {
  Program program = {
    { OpCode::kConstInt, 63 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPrim, PrimCode::kAnd },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, Prim32) {
  Program program = {
    { OpCode::kConstInt, 63 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPrim, PrimCode::kOr },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(63)));
}

TEST(MachineTest, Prim33) {
  Program program = {
    { OpCode::kConstInt, 63 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPrim, PrimCode::kXor },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(19)));
}

TEST(MachineTest, Prim34) {
  Program program = {
    { OpCode::kConstInt, 63 },
    { OpCode::kPush },
    { OpCode::kConstInt, 1 },
    { OpCode::kPrim, PrimCode::kLsl },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(126)));
}

TEST(MachineTest, Prim35) {
  Program program = {
    { OpCode::kConstInt, -63 },
    { OpCode::kPush },
    { OpCode::kConstInt, 63 },
    { OpCode::kPrim, PrimCode::kLsr },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Prim36) {
  Program program = {
    { OpCode::kConstInt, -63 },
    { OpCode::kPush },
    { OpCode::kConstInt, 63 },
    { OpCode::kPrim, PrimCode::kAsr },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(-1)));
}

TEST(MachineTest, PrimUnary1) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kAddConst, 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, PrimUnary2) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kSubConst, 22 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(20)));
}

TEST(MachineTest, PrimUnary3) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kSubFromConst, 44 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(2)));
}

TEST(MachineTest, PrimUnary4) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kMultByConst, 10 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(420)));
}

TEST(MachineTest, PrimUnary5) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kDivByConst, 7 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(6)));
}

TEST(MachineTest, PrimUnary6) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kDivConstBy, 210 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, PrimUnary7) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kPrimUnary, PrimUnaryCode::kModByConst, 7 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(2)));
}

TEST(MachineTest, PrimUnary8) {
  Program program = {
    { OpCode::kConstInt, 5 },
    { OpCode::kPrimUnary, PrimUnaryCode::kModConstBy, 42 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(2)));
}

TEST(MachineTest, PrimUnary9) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLtConst, 222 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, PrimUnary10) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLtConst, 42 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, PrimUnary11) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLtConst, 41 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, PrimUnary12) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLeConst, 222 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, PrimUnary13) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLeConst, 42 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, PrimUnary14) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLeConst, 41 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, PrimUnary15) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kGtConst, 222 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, PrimUnary16) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kGtConst, 42 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, PrimUnary17) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kGtConst, 41 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, PrimUnary18) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kGeConst, 222 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, PrimUnary19) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kGeConst, 42 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, PrimUnary20) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kGeConst, 41 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, PrimUnary21) {
  Program program = {
    { OpCode::kConstInt, -4 },
    { OpCode::kPrimUnary, PrimUnaryCode::kNot },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(3)));
}

TEST(MachineTest, PrimUnary22) {
  Program program = {
    { OpCode::kConstInt, 42 },
    { OpCode::kPrimUnary, PrimUnaryCode::kNeg },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(-42)));
}

TEST(MachineTest, PrimUnary23) {
  Program program = {
    { OpCode::kConstInt, 444 },
    { OpCode::kPrimUnary, PrimUnaryCode::kEqConst, 4 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, PrimUnary24) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kPrimUnary, PrimUnaryCode::kEqConst, 44 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, PrimUnary25) {
  Program program = {
    { OpCode::kConstInt, 444 },
    { OpCode::kPrimUnary, PrimUnaryCode::kNeqConst, 4 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, PrimUnary26) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kPrimUnary, PrimUnaryCode::kNeqConst, 44 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, PrimUnary27) {
  Program program = {
    { OpCode::kConstInt, 63 },
    { OpCode::kPrimUnary, PrimUnaryCode::kAndConst, 44 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, PrimUnary28) {
  Program program = {
    { OpCode::kConstInt, 63 },
    { OpCode::kPrimUnary, PrimUnaryCode::kOrConst, 44 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(63)));
}

TEST(MachineTest, PrimUnary29) {
  Program program = {
    { OpCode::kConstInt, 63 },
    { OpCode::kPrimUnary, PrimUnaryCode::kXorConst, 44 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(19)));
}

TEST(MachineTest, PrimUnary30) {
  Program program = {
    { OpCode::kConstInt, 63 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLslConst, 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(126)));
}

TEST(MachineTest, PrimUnary31) {
  Program program = {
    { OpCode::kConstInt, -63 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLsrConst, 63 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, PrimUnary32) {
  Program program = {
    { OpCode::kConstInt, -63 },
    { OpCode::kPrimUnary, PrimUnaryCode::kAsrConst, 63 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(-1)));
}

TEST(MachineTest, Fun1) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 0 },
  /* 1 */ { OpCode::kPush },
  /* 2 */ { OpCode::kMakeClosure, 5, 1 },
  /* 3 */ { OpCode::kCall },
  /* 4 */ { OpCode::kExit },

  /* 5 */ { OpCode::kConstInt, 5 },
  /* 6 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, Fun2) {
  Program program = {
  /* 0 */ { OpCode::kMakeClosure, 7, 1 },
  /* 1 */ { OpCode::kLet },
  /* 2 */ { OpCode::kConstInt, 1756 },
  /* 3 */ { OpCode::kPush },
  /* 4 */ { OpCode::kAccessVar, 0 },
  /* 5 */ { OpCode::kCall },
  /* 6 */ { OpCode::kExit },

  /* 7 */ { OpCode::kAccessVar, 0 },
  /* 8 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1756)));
}

TEST(MachineTest, Fun3) {
  Program program = {
  /* 0 */ { OpCode::kMakeClosure, 3, 1 },
  /* 1 */ { OpCode::kCall },
  /* 2 */ { OpCode::kExit },

  /* 3 */ { OpCode::kConstInt, 5 },
  /* 4 */ { OpCode::kReturn },
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, Fun4) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 10, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 44 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kAccessVar, 0 },
  /*  5 */ { OpCode::kCall },
  /*  6 */ { OpCode::kPush },
  /*  7 */ { OpCode::kConstInt, 6 },
  /*  8 */ { OpCode::kPrim, PrimCode::kDiv },
  /*  9 */ { OpCode::kExit },

  /* 10 */ { OpCode::kAccessVar, 0 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kConstInt, 2 },
  /* 14 */ { OpCode::kPrim, PrimCode::kSub },
  /* 15 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(7)));
}

TEST(MachineTest, Fun5) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 20, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kMakeClosure, 12, 1 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kConstInt, 44 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kAccessVar, 0 },
  /*  7 */ { OpCode::kCall },
  /*  8 */ { OpCode::kPush },
  /*  9 */ { OpCode::kConstInt, 6 },
  /* 10 */ { OpCode::kPrim, PrimCode::kDiv },
  /* 11 */ { OpCode::kExit },

  /* 12 */ { OpCode::kAccessVar, 0 },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kConstInt, 3 },
  /* 15 */ { OpCode::kPush },
  /* 16 */ { OpCode::kAccessVar, 1 },
  /* 17 */ { OpCode::kCall },
  /* 18 */ { OpCode::kPrim, PrimCode::kSub },
  /* 19 */ { OpCode::kReturn },

  /* 20 */ { OpCode::kConstInt, 2 },
  /* 21 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(7)));
}

TEST(MachineTest, Fun6) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 276 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kMakeClosure, 9, 1 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kConstInt, 1756 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kAccessVar, 0 },
  /*  7 */ { OpCode::kCall },
  /*  8 */ { OpCode::kExit },

  /*  9 */ { OpCode::kAccessVar, 1 },
  /* 10 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(276)));
}

TEST(MachineTest, Fun7) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 17, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 276 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kMakeClosure, 19, 1 },
  /*  5 */ { OpCode::kLet },
  /*  6 */ { OpCode::kConstInt, 1756 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kCall },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kAccessVar, 2 },
  /* 12 */ { OpCode::kCall },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kAccessVar, 0 },
  /* 15 */ { OpCode::kCall },
  /* 16 */ { OpCode::kExit },

  /* 17 */ { OpCode::kConstInt, 22 },
  /* 18 */ { OpCode::kReturn },

  /* 19 */ { OpCode::kAccessVar, 1 },
  /* 20 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(276)));
}

TEST(MachineTest, Fun8) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 14, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 276 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kMakeClosure, 16, 1 },
  /*  5 */ { OpCode::kLet },
  /*  6 */ { OpCode::kConstInt, 1756 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kCall },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kAccessVar, 2 },
  /* 12 */ { OpCode::kCall },
  /* 13 */ { OpCode::kExit },

  /* 14 */ { OpCode::kConstInt, 22 },
  /* 15 */ { OpCode::kReturn },

  /* 16 */ { OpCode::kAccessVar, 1 },
  /* 17 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(22)));
}

TEST(MachineTest, Fun9) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 20, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 276 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kMakeClosure, 22, 1 },
  /*  5 */ { OpCode::kLet },
  /*  6 */ { OpCode::kConstInt, 1756 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kCall },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kAccessVar, 2 },
  /* 12 */ { OpCode::kCall },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kAccessVar, 0 },
  /* 15 */ { OpCode::kEndLet },
  /* 16 */ { OpCode::kEndLet },
  /* 17 */ { OpCode::kEndLet },
  /* 18 */ { OpCode::kCall },
  /* 19 */ { OpCode::kExit },

  /* 20 */ { OpCode::kConstInt, 22 },
  /* 21 */ { OpCode::kReturn },

  /* 22 */ { OpCode::kAccessVar, 1 },
  /* 23 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(276)));
}

TEST(MachineTest, Fun10) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 17, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 276 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kMakeClosure, 19, 1 },
  /*  5 */ { OpCode::kLet },
  /*  6 */ { OpCode::kConstInt, 1756 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kCall },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kAccessVar, 2 },
  /* 12 */ { OpCode::kEndLet },
  /* 13 */ { OpCode::kEndLet },
  /* 14 */ { OpCode::kEndLet },
  /* 15 */ { OpCode::kCall },
  /* 16 */ { OpCode::kExit },

  /* 17 */ { OpCode::kConstInt, 22 },
  /* 18 */ { OpCode::kReturn },

  /* 19 */ { OpCode::kAccessVar, 1 },
  /* 20 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(22)));
}

TEST(MachineTest, Fun11) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 666 },
  /* 1 */ { OpCode::kPush },
  /* 2 */ { OpCode::kMakeClosure, 5, 1 },
  /* 3 */ { OpCode::kCall },
  /* 4 */ { OpCode::kExit },

  /* 5 */ { OpCode::kAccessVar, 0 },
  /* 6 */ { OpCode::kExit },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(666)));
}

TEST(MachineTest, Fun12) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 276 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kMakeClosure, 9, 1 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kConstInt, 1756 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kAccessVar, 0 },
  /*  7 */ { OpCode::kCall },
  /*  8 */ { OpCode::kExit },

  /*  9 */ { OpCode::kAccessVar, 1 },
  /* 10 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(276)));
}

TEST(MachineTest, Fun13) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 14 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 18 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kMakeClosure, 7, 2 },
  /*  5 */ { OpCode::kCall },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kAccessVar, 0 },
  /*  8 */ { OpCode::kPush },
  /* 11 */ { OpCode::kAccessVar, 1 },
  /* 12 */ { OpCode::kPrim, PrimCode::kAdd },
  /* 13 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(32)));
}

TEST(MachineTest, Fun14) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 22 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 3 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kMakeRecursiveBinding, 8, 2 },
  /*  5 */ { OpCode::kAccessRecursiveBinding, 0 },
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kExit },

  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kPush },
  /* 10 */ { OpCode::kAccessVar, 1 },
  /* 11 */ { OpCode::kPrim, PrimCode::kLt },
  /* 12 */ { OpCode::kJumpZero, 15 },
  /* 13 */ { OpCode::kAccessVar, 0 },
  /* 14 */ { OpCode::kReturn },
  /* 15 */ { OpCode::kAccessVar, 0 },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kAccessVar, 1 },
  /* 18 */ { OpCode::kPrim, PrimCode::kSub },
  /* 19 */ { OpCode::kPush },
  /* 20 */ { OpCode::kAccessVar, 1 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kAccessVar, 2 },
  /* 23 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 24 */ { OpCode::kCall },
  /* 25 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Extern1) {
  Program program = {
    { OpCode::kConstString, "44" },
    { OpCode::kCallExtern, "helium_lengthStr", 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(2)));
}

TEST(MachineTest, Extern2) {
  Program program = {
    { OpCode::kConstString, "Konrad" },
    { OpCode::kCallExtern, "helium_lengthStr", 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(6)));
}

TEST(MachineTest, Extern3) {
  Program program = {
    { OpCode::kConstString, "" },
    { OpCode::kCallExtern, "helium_lengthStr", 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Extern4) {
  Program program = {
    { OpCode::kConstString, "Konrad" },
    { OpCode::kPush },
    { OpCode::kConstString, " 44" },
    { OpCode::kCallExtern, "helium_appendStr", 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("Konrad 44")));
}

TEST(MachineTest, Extern5) {
  Program program = {
    { OpCode::kConstString, "Helium" },
    { OpCode::kPush },
    { OpCode::kConstString, "" },
    { OpCode::kCallExtern, "helium_appendStr", 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("Helium")));
}

TEST(MachineTest, Extern6) {
  Program program = {
    { OpCode::kConstString, "" },
    { OpCode::kPush },
    { OpCode::kConstString, "Helium" },
    { OpCode::kCallExtern, "helium_appendStr", 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("Helium")));
}

TEST(MachineTest, Extern7) {
  Program program = {
    { OpCode::kConstString, "Konrad" },
    { OpCode::kPush },
    { OpCode::kConstInt, 3 },
    { OpCode::kPush },
    { OpCode::kConstInt, 3 },
    { OpCode::kCallExtern, "helium_substringStr", 3 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("rad")));
}

TEST(MachineTest, Extern8) {
  Program program = {
    { OpCode::kConstString, "Curry" },
    { OpCode::kPush },
    { OpCode::kConstInt, 3 },
    { OpCode::kPush },
    { OpCode::kConstInt, 1 },
    { OpCode::kCallExtern, "helium_substringStr", 3 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("r")));
}

TEST(MachineTest, Extern9) {
  Program program = {
    { OpCode::kConstString, "Nothing" },
    { OpCode::kPush },
    { OpCode::kConstInt, 3 },
    { OpCode::kPush },
    { OpCode::kConstInt, 0 },
    { OpCode::kCallExtern, "helium_substringStr", 3 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("")));
}

TEST(MachineTest, Extern10) {
  Program program = {
  /*  0 */ { OpCode::kJump, 7 },
  /*  1 */ { OpCode::kConstString, "B" },
  /*  2 */ { OpCode::kPush },
  /*  3 */ { OpCode::kConstString, "W" },
  /*  4 */ { OpCode::kCallExtern, "helium_appendStr", 2 },
  /*  5 */ { OpCode::kReturn },
  /*  6 */ { OpCode::kConstInt, 0 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kMakeClosure, 1, 1 },
  /*  9 */ { OpCode::kCall },
  /* 10 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("BW")));
}

TEST(MachineTest, Extern11) {
  Program program = {
  /*  0 */ { OpCode::kJump, 9 },
  /*  1 */ { OpCode::kConstString, "Helium" },
  /*  2 */ { OpCode::kPush },
  /*  3 */ { OpCode::kConstInt, 0 },
  /*  4 */ { OpCode::kPush },
  /*  5 */ { OpCode::kConstInt, 3 },
  /*  6 */ { OpCode::kCallExtern, "helium_substringStr", 3 },
  /*  7 */ { OpCode::kReturn },
  /*  8 */ { OpCode::kConstInt, 0 },
  /*  9 */ { OpCode::kPush },
  /* 10 */ { OpCode::kMakeClosure, 1, 1 },
  /* 11 */ { OpCode::kCall },
  /* 12 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("Hel")));
}

TEST(MachineTest, Extern12) {
  Program program = {
  /*  0 */ { OpCode::kJump, 11 },
  /*  1 */ { OpCode::kConstString, "B" },
  /*  2 */ { OpCode::kPush },
  /*  3 */ { OpCode::kConstString, "W" },
  /*  4 */ { OpCode::kCallExtern, "helium_appendStr", 2 },
  /*  5 */ { OpCode::kReturn },
  /*  6 */ { OpCode::kConstInt, 0 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kMakeClosure, 1, 1 },
  /*  9 */ { OpCode::kTailCall },
  /* 10 */ { OpCode::kConstInt, 0 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kMakeClosure, 7, 1 },
  /* 13 */ { OpCode::kCall },
  /* 14 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("BW")));
}

TEST(MachineTest, Extern13) {
  Program program = {
  /* 0 */ { OpCode::kJump, 5 },
  /* 1 */ { OpCode::kConstInt, 1756 },
  /* 2 */ { OpCode::kCallExtern, "helium_string_of_int", 1 },
  /* 3 */ { OpCode::kReturn },
  /* 4 */ { OpCode::kConstInt, 0 },
  /* 5 */ { OpCode::kPush },
  /* 6 */ { OpCode::kMakeClosure, 1, 1 },
  /* 7 */ { OpCode::kCall },
  /* 8 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("1756")));
}

TEST(MachineTest, Extern14) {
  Program program = {
    { OpCode::kConstInt, 0 },
    { OpCode::kCallExtern, "helium_string_of_int", 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("0")));
}

TEST(MachineTest, Extern15) {
  Program program = {
    { OpCode::kConstInt, -1997 },
    { OpCode::kCallExtern, "helium_string_of_int", 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("-1997")));
}

TEST(MachineTest, Extern16) {
  Program program = {
    { OpCode::kConstString, "abba" },
    { OpCode::kPush },
    { OpCode::kConstString, "b" },
    { OpCode::kCallExtern, "helium_rawCompareStr", 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(-1)));
}

TEST(MachineTest, Extern17) {
  Program program = {
    { OpCode::kConstString, "Konrad" },
    { OpCode::kPush },
    { OpCode::kConstString, "Konrad" },
    { OpCode::kCallExtern, "helium_rawCompareStr", 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Extern18) {
  Program program = {
    { OpCode::kConstString, "b" },
    { OpCode::kPush },
    { OpCode::kConstString, "abba" },
    { OpCode::kCallExtern, "helium_rawCompareStr", 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Extern19) {
  Program program = {
    { OpCode::kConstString, "Painkiller" },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kCallExtern, "helium_indexStr", 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value((HeliumInt)'k')));
}

TEST(MachineTest, Extern20) {
  Program program = {
    { OpCode::kConstInt, 9 },
    { OpCode::kPush },
    { OpCode::kConstString, "Painkiller" },
    { OpCode::kCallExtern, "helium_stringGet", 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value((HeliumInt)'r')));
}

TEST(MachineTest, Extern21) {
  Program program = {
    { OpCode::kConstInt, 5 },
    { OpCode::kPush },
    { OpCode::kConstString, "Painkiller" },
    { OpCode::kPush },
    { OpCode::kConstInt, 4 },
    { OpCode::kCallExtern, "helium_indexStr", 2 },
    { OpCode::kCallExtern, "helium_stringRepeat", 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("kkkkk")));
}

TEST(MachineTest, Extern22) {
  Program program = {
    { OpCode::kConstInt, 7 },
    { OpCode::kPush },
    { OpCode::kConstInt, 9 },
    { OpCode::kPush },
    { OpCode::kConstString, "Painkiller" },
    { OpCode::kCallExtern, "helium_stringGet", 2 },
    { OpCode::kCallExtern, "helium_stringRepeat", 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value("rrrrrrr")));
}

TEST(MachineTest, Record1) {
  Program program = {
    { OpCode::kConstInt, 1756 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 42 },
    { OpCode::kMakeRecord, 3 },
    { OpCode::kGetField, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1756)));
}

TEST(MachineTest, Record2) {
  Program program = {
    { OpCode::kConstInt, 1756 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 42 },
    { OpCode::kMakeRecord, 3 },
    { OpCode::kGetField, 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, Record3) {
  Program program = {
    { OpCode::kConstInt, 1756 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 42 },
    { OpCode::kMakeRecord, 3 },
    { OpCode::kGetField, 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(42)));
}

TEST(MachineTest, Record4) {
  Program program = {
    { OpCode::kConstInt, 1756 },
    { OpCode::kPush },
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 42 },
    { OpCode::kMakeRecord, 2 },
    { OpCode::kGetField, 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(42)));
}

TEST(MachineTest, Record5) {
  Program program = {
    { OpCode::kMakeRecord, 0 },
    { OpCode::kConstInt, 1756 },
    { OpCode::kMakeRecord, 1 },
    { OpCode::kGetField, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1756)));
}

TEST(MachineTest, Record6) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 42 },
    { OpCode::kMakeRecord, 2 },
    { OpCode::kLet },
    { OpCode::kConstInt, 1756 },
    { OpCode::kMakeRecord, 1 },
    { OpCode::kAccessVar, 0 },
    { OpCode::kEndLet },
    { OpCode::kGetField, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, Record7) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 42 },
    { OpCode::kMakeRecord, 2 },
    { OpCode::kLet },
    { OpCode::kConstInt, 1756 },
    { OpCode::kMakeRecord, 1 },
    { OpCode::kAccessVar, 0 },
    { OpCode::kGetField, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, Record8) {
  Program program = {
    { OpCode::kConstInt, 1756 },
    { OpCode::kPush },
    { OpCode::kConstInt, 42 },
    { OpCode::kMakeRecord, 1 },
    { OpCode::kLet },
    { OpCode::kConstInt, 44 },
    { OpCode::kMakeRecord, 2 },
    { OpCode::kAccessVar, 0 },
    { OpCode::kEndLet },
    { OpCode::kGetField, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(42)));
}

TEST(MachineTest, Record9) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 42 },
    { OpCode::kMakeRecord, 2 },
    { OpCode::kLet },
    { OpCode::kConstInt, 1756 },
    { OpCode::kMakeRecord, 1 },
    { OpCode::kAccessVar, 0 },
    { OpCode::kEndLet },
    { OpCode::kGetField, 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(42)));
}

TEST(MachineTest, Record10) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 13, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 1756 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 44 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kConstInt, 42 },
  /*  7 */ { OpCode::kMakeRecord, 3 },
  /*  8 */ { OpCode::kPush },
  /*  9 */ { OpCode::kAccessVar, 0 },
  /* 10 */ { OpCode::kCall },
  /* 11 */ { OpCode::kGetField, 0 },
  /* 12 */ { OpCode::kExit },

  /* 13 */ { OpCode::kAccessVar, 0 },
  /* 14 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1756)));
}

TEST(MachineTest, Record11) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 1756 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 44 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 42 },
  /*  5 */ { OpCode::kMakeRecord, 3 },
  /*  6 */ { OpCode::kLet },
  /*  7 */ { OpCode::kConstInt, 0 },
  /*  8 */ { OpCode::kPush },
  /*  9 */ { OpCode::kMakeClosure, 13, 1 },
  /* 10 */ { OpCode::kEndLet },
  /* 11 */ { OpCode::kCall},
  /* 12 */ { OpCode::kExit },

  /* 14 */ { OpCode::kAccessVar, 1 },
  /* 15 */ { OpCode::kGetField, 0 },
  /* 16 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1756)));
}

TEST(MachineTest, Constructor1) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 55 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 66 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 77 },
  /*  5 */ { OpCode::kMakeConstructor, 0, 3 },
  /*  6 */ { OpCode::kMatch, {7, 9, 11} },
  /*  7 */ { OpCode::kGetField, 1 },
  /*  8 */ { OpCode::kJump, 12 },
  /*  9 */ { OpCode::kGetField, 2 },
  /* 10 */ { OpCode::kJump, 12 },
  /* 11 */ { OpCode::kGetField, 3 },
  /* 12 */ { OpCode::kEndLet },
  /* 13 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(55)));
}

TEST(MachineTest, Constructor2) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 55 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 66 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 77 },
  /*  5 */ { OpCode::kMakeConstructor, 1, 3 },
  /*  6 */ { OpCode::kMatch, {7, 9, 11} },
  /*  7 */ { OpCode::kGetField, 1 },
  /*  8 */ { OpCode::kJump, 12 },
  /*  9 */ { OpCode::kGetField, 2 },
  /* 10 */ { OpCode::kJump, 12 },
  /* 11 */ { OpCode::kGetField, 3 },
  /* 12 */ { OpCode::kEndLet },
  /* 13 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(66)));
}

TEST(MachineTest, Constructor3) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 55 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 66 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 77 },
  /*  5 */ { OpCode::kMakeConstructor, 2, 3 },
  /*  6 */ { OpCode::kMatch, {7, 9, 11} },
  /*  7 */ { OpCode::kGetField, 1 },
  /*  8 */ { OpCode::kJump, 12 },
  /*  9 */ { OpCode::kGetField, 2 },
  /* 10 */ { OpCode::kJump, 12 },
  /* 11 */ { OpCode::kGetField, 3 },
  /* 12 */ { OpCode::kEndLet },
  /* 13 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(77)));
}

TEST(MachineTest, Constructor4) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 55 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 66 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 77 },
  /*  5 */ { OpCode::kMakeConstructor, 0, 3 },
  /*  6 */ { OpCode::kMatch, {7, 10, 13} },
  /*  7 */ { OpCode::kAccessVar, 0 },
  /*  8 */ { OpCode::kGetField, 1 },
  /*  9 */ { OpCode::kJump, 12 },
  /* 10 */ { OpCode::kAccessVar, 0 },
  /* 11 */ { OpCode::kGetField, 2 },
  /* 12 */ { OpCode::kJump, 15 },
  /* 13 */ { OpCode::kAccessVar, 0 },
  /* 14 */ { OpCode::kGetField, 3 },
  /* 15 */ { OpCode::kEndLet },
  /* 16 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(55)));
}

TEST(MachineTest, Constructor5) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 55 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 66 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 77 },
  /*  5 */ { OpCode::kMakeConstructor, 1, 3 },
  /*  6 */ { OpCode::kMatch, {7, 10, 13} },
  /*  7 */ { OpCode::kAccessVar, 0 },
  /*  8 */ { OpCode::kGetField, 1 },
  /*  9 */ { OpCode::kJump, 12 },
  /* 10 */ { OpCode::kAccessVar, 0 },
  /* 11 */ { OpCode::kGetField, 2 },
  /* 12 */ { OpCode::kJump, 15 },
  /* 13 */ { OpCode::kAccessVar, 0 },
  /* 14 */ { OpCode::kGetField, 3 },
  /* 15 */ { OpCode::kEndLet },
  /* 16 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(66)));
}

TEST(MachineTest, Constructor6) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 55 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 66 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 77 },
  /*  5 */ { OpCode::kMakeConstructor, 2, 3 },
  /*  6 */ { OpCode::kMatch, {7, 10, 13} },
  /*  7 */ { OpCode::kAccessVar, 0 },
  /*  8 */ { OpCode::kGetField, 1 },
  /*  9 */ { OpCode::kJump, 12 },
  /* 10 */ { OpCode::kAccessVar, 0 },
  /* 11 */ { OpCode::kGetField, 2 },
  /* 12 */ { OpCode::kJump, 15 },
  /* 13 */ { OpCode::kAccessVar, 0 },
  /* 14 */ { OpCode::kGetField, 3 },
  /* 15 */ { OpCode::kEndLet },
  /* 16 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(77)));
}

TEST(MachineTest, Handle1) {
  Program program = {
    { OpCode::kHandle, 32, 55 },
    { OpCode::kAccessVar, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Handle2) {
  Program program = {
    { OpCode::kHandle, 32, 55 },
    { OpCode::kHandle, 22, 55 },
    { OpCode::kAccessVar, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Handle3) {
  Program program = {
    { OpCode::kHandle, 32, 55 },
    { OpCode::kHandle, 22, 55 },
    { OpCode::kAccessVar, 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Handle4) {
  Program program = {
    { OpCode::kHandle, 32, 55 },
    { OpCode::kHandle, 22, 55 },
    { OpCode::kHandle, 21, 55 },
    { OpCode::kAccessVar, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(2)));
}

TEST(MachineTest, Handle5) {
  Program program = {
    { OpCode::kHandle, 32, 55 },
    { OpCode::kHandle, 22, 55 },
    { OpCode::kHandle, 21, 55 },
    { OpCode::kAccessVar, 1 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Handle6) {
  Program program = {
    { OpCode::kHandle, 32, 55 },
    { OpCode::kHandle, 22, 55 },
    { OpCode::kHandle, 21, 55 },
    { OpCode::kAccessVar, 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Handle7) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 3 },
  /* 1 */ { OpCode::kLet },
  /* 2 */ { OpCode::kHandle, 32, 5 },
  /* 3 */ { OpCode::kEndHandle },
  /* 4 */ { OpCode::kReturn },
  /* 5 */ { OpCode::kAccessVar, 0 },
  /* 6 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(3)));
}

TEST(MachineTest, Handle8) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 33 },
  /* 1 */ { OpCode::kLet },
  /* 2 */ { OpCode::kHandle, 32, 8 },
  /* 3 */ { OpCode::kHandle, 22, 6 },
  /* 4 */ { OpCode::kEndHandle },
  /* 5 */ { OpCode::kReturn },
  /* 6 */ { OpCode::kEndHandle },
  /* 7 */ { OpCode::kReturn },
  /* 8 */ { OpCode::kAccessVar, 0 },
  /* 9 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(33)));
}

TEST(MachineTest, Handle9) {
  Program program = {
  /* 0 */ { OpCode::kHandle, 32, 9 },
  /* 1 */ { OpCode::kConstInt, 26 },
  /* 2 */ { OpCode::kLet },
  /* 3 */ { OpCode::kHandle, 22, 6 },
  /* 4 */ { OpCode::kEndHandle },
  /* 5 */ { OpCode::kReturn },
  /* 6 */ { OpCode::kAccessVar, 0 },
  /* 7 */ { OpCode::kEndHandle },
  /* 8 */ { OpCode::kReturn },
  /* 9 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(26)));
}

TEST(MachineTest, Handle10) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 28 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kHandle, 32, 11 },
  /*  3 */ { OpCode::kHandle, 22, 9 },
  /*  4 */ { OpCode::kHandle, 21, 7 },
  /*  5 */ { OpCode::kEndHandle },
  /*  6 */ { OpCode::kReturn },
  /*  7 */ { OpCode::kEndHandle },
  /*  8 */ { OpCode::kReturn },
  /*  9 */ { OpCode::kEndHandle },
  /* 10 */ { OpCode::kReturn },
  /* 11 */ { OpCode::kAccessVar, 0 },
  /* 12 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(28)));
}

TEST(MachineTest, Handle11) {
  Program program = {
    { OpCode::kConstInt, 28 },
    { OpCode::kLet },
    { OpCode::kHandle, 32, 55 },
    { OpCode::kHandle, 22, 55 },
    { OpCode::kHandle, 21, 55 },
    { OpCode::kAccessVar, 3 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(28)));
}

TEST(MachineTest, Handle12) {
  Program program = {
  /* 0 */ { OpCode::kConstInt, 35 },
  /* 1 */ { OpCode::kLet },
  /* 2 */ { OpCode::kHandle, 32, 55 },
  /* 3 */ { OpCode::kHandle, 22, 55 },
  /* 4 */ { OpCode::kHandle, 21, 8 },
  /* 5 */ { OpCode::kEndHandle },
  /* 6 */ { OpCode::kAccessVar, 2 },
  /* 7 */ { OpCode::kReturn },
  /* 8 */ { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(35)));
}

TEST(MachineTest, Handle13) {
  Program program = {
    { OpCode::kEndHandle },
    { OpCode::kExit }
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, Handle14) {
  Program program = {
    { OpCode::kHandle, 32, 55 },
    { OpCode::kEndHandle },
    { OpCode::kEndHandle },
    { OpCode::kExit }
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, Op1) {
  Program program = {
  /* 0 */ { OpCode::kHandle, 5, 4 },
  /* 1 */ { OpCode::kOp, 0 },
  /* 2 */ { OpCode::kEndHandle },
  /* 3 */ { OpCode::kReturn },
  /* 4 */ { OpCode::kExit },

  /* 5 */ { OpCode::kConstInt, 36 },
  /* 6 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, Op2) {
  Program program = {
  /* 0 */ { OpCode::kHandle, 7, 6 },
  /* 1 */ { OpCode::kConstInt, 44 },
  /* 2 */ { OpCode::kPush },
  /* 3 */ { OpCode::kOp, 0 },
  /* 4 */ { OpCode::kEndHandle },
  /* 5 */ { OpCode::kReturn },
  /* 6 */ { OpCode::kExit },

  /* 7 */ { OpCode::kAccessVar, 0 },
  /* 8 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, Op3) {
  Program program = {
  /* 0 */ { OpCode::kHandle, 5, 4 },
  /* 1 */ { OpCode::kOp, 0 },
  /* 2 */ { OpCode::kEndHandle },
  /* 3 */ { OpCode::kReturn },
  /* 4 */ { OpCode::kExit },

  /* 5 */ { OpCode::kConstInt, 36 },
  /* 6 */ { OpCode::kPush },
  /* 7 */ { OpCode::kAccessVar, 1 },
  /* 8 */ { OpCode::kCall },
  /* 9 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, Op4) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 7, 6 },
  /*  1 */ { OpCode::kConstInt, 44 },
  /*  2 */ { OpCode::kPush },
  /*  3 */ { OpCode::kOp, 0 },
  /*  4 */ { OpCode::kEndHandle },
  /*  5 */ { OpCode::kReturn },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kAccessVar, 0 },
  /*  8 */ { OpCode::kPush },
  /*  9 */ { OpCode::kAccessVar, 1 },
  /* 10 */ { OpCode::kCall },
  /* 11 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, Op5) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 10, 9 },
  /*  1 */ { OpCode::kConstInt, 44 },
  /*  2 */ { OpCode::kPush },
  /*  3 */ { OpCode::kOp, 0 },
  /*  4 */ { OpCode::kPush },
  /*  5 */ { OpCode::kConstInt, 1 },
  /*  6 */ { OpCode::kPrim, PrimCode::kAdd },
  /*  7 */ { OpCode::kEndHandle },
  /*  8 */ { OpCode::kReturn },
  /*  9 */ { OpCode::kExit },

  /* 10 */ { OpCode::kAccessVar, 0 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kAccessVar, 1 },
  /* 13 */ { OpCode::kCall },
  /* 14 */ { OpCode::kPush },
  /* 15 */ { OpCode::kConstInt, 36 },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kAccessVar, 1 },
  /* 18 */ { OpCode::kCall },
  /* 19 */ { OpCode::kPrim, PrimCode::kAdd },
  /* 20 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(82)));
}

TEST(MachineTest, Op6) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 10, 9 },
  /*  1 */ { OpCode::kConstInt, 44 },
  /*  2 */ { OpCode::kPush },
  /*  3 */ { OpCode::kOp, 0 },
  /*  4 */ { OpCode::kEndHandle },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kConstInt, 1 },
  /*  7 */ { OpCode::kPrim, PrimCode::kAdd },
  /*  8 */ { OpCode::kReturn },
  /*  9 */ { OpCode::kExit },

  /* 10 */ { OpCode::kAccessVar, 0 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kAccessVar, 1 },
  /* 13 */ { OpCode::kCall },
  /* 14 */ { OpCode::kPush },
  /* 15 */ { OpCode::kConstInt, 36 },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kAccessVar, 1 },
  /* 18 */ { OpCode::kCall },
  /* 19 */ { OpCode::kPrim, PrimCode::kAdd },
  /* 20 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(82)));
}

TEST(MachineTest, Op7) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 0 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 32 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kHandle, 12, 11 },
  /*  5 */ { OpCode::kConstInt, 44 },
  /*  6 */ { OpCode::kPush },
  /*  7 */ { OpCode::kOp, 0 },
  /*  8 */ { OpCode::kAccessVar, 1 },
  /*  9 */ { OpCode::kEndHandle },
  /* 10 */ { OpCode::kExit },

  /* 11 */ { OpCode::kCall },
  /* 12 */ { OpCode::kAccessVar, 1 },
  /* 13 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(32)));
}

TEST(MachineTest, Op8) {
  Program program = {
  /* 0 */ { OpCode::kHandle, 6, 5 },
  /* 1 */ { OpCode::kOp, 0 },
  /* 2 */ { OpCode::kEndHandle },
  /* 3 */ { OpCode::kConstInt, 32 },
  /* 4 */ { OpCode::kReturn },
  /* 5 */ { OpCode::kExit },

  /* 6 */ { OpCode::kConstInt, 36 },
  /* 7 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, Op9) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 6, 5 },
  /*  1 */ { OpCode::kOp, 0 },
  /*  2 */ { OpCode::kEndHandle },
  /*  3 */ { OpCode::kConstInt, 32 },
  /*  4 */ { OpCode::kReturn },
  /*  5 */ { OpCode::kExit },

  /*  6 */ { OpCode::kConstInt, 36 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kAccessVar, 1 },
  /*  9 */ { OpCode::kCall },
  /* 10 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(32)));
}

TEST(MachineTest, Op10) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 16, 10 },
  /*  1 */ { OpCode::kHandle, 11, 8 },
  /*  2 */ { OpCode::kOp, 1 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kOp, 0 },
  /*  5 */ { OpCode::kPrim, PrimCode::kSub },
  /*  6 */ { OpCode::kEndHandle },
  /*  7 */ { OpCode::kReturn },
  /*  8 */ { OpCode::kEndHandle },
  /*  9 */ { OpCode::kReturn },
  /* 10 */ { OpCode::kExit },

  /* 11 */ { OpCode::kConstInt, 44 },
  /* 12 */ { OpCode::kPush },
  /* 13 */ { OpCode::kAccessVar, 1 },
  /* 14 */ { OpCode::kCall },
  /* 15 */ { OpCode::kReturn },

  /* 16 */ { OpCode::kConstInt, 36 },
  /* 17 */ { OpCode::kPush },
  /* 18 */ { OpCode::kAccessVar, 1 },
  /* 19 */ { OpCode::kCall },
  /* 20 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(-8)));
}

TEST(MachineTest, Op11) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 16, 10 },
  /*  1 */ { OpCode::kHandle, 11, 8 },
  /*  2 */ { OpCode::kOp, 0 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kOp, 1 },
  /*  5 */ { OpCode::kPrim, PrimCode::kSub },
  /*  6 */ { OpCode::kEndHandle },
  /*  7 */ { OpCode::kReturn },
  /*  8 */ { OpCode::kEndHandle },
  /*  9 */ { OpCode::kReturn },
  /* 10 */ { OpCode::kExit },

  /* 11 */ { OpCode::kConstInt, 44 },
  /* 12 */ { OpCode::kPush },
  /* 13 */ { OpCode::kAccessVar, 1 },
  /* 14 */ { OpCode::kCall },
  /* 15 */ { OpCode::kReturn },

  /* 16 */ { OpCode::kConstInt, 36 },
  /* 17 */ { OpCode::kPush },
  /* 18 */ { OpCode::kAccessVar, 1 },
  /* 19 */ { OpCode::kCall },
  /* 20 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(8)));
}

TEST(MachineTest, Op12) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 16, 10 },
  /*  1 */ { OpCode::kHandle, 11, 5 },
  /*  2 */ { OpCode::kOp, 0 },
  /*  3 */ { OpCode::kEndHandle },
  /*  4 */ { OpCode::kReturn },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kOp, 0 },
  /*  7 */ { OpCode::kPrim, PrimCode::kSub },
  /*  8 */ { OpCode::kEndHandle },
  /*  9 */ { OpCode::kReturn },
  /* 10 */ { OpCode::kExit },

  /* 11 */ { OpCode::kConstInt, 44 },
  /* 12 */ { OpCode::kPush },
  /* 13 */ { OpCode::kAccessVar, 1 },
  /* 14 */ { OpCode::kCall },
  /* 15 */ { OpCode::kReturn },

  /* 16 */ { OpCode::kConstInt, 36 },
  /* 17 */ { OpCode::kPush },
  /* 18 */ { OpCode::kAccessVar, 1 },
  /* 19 */ { OpCode::kCall },
  /* 20 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(8)));
}

TEST(MachineTest, Op13) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 22, 16 },
  /*  1 */ { OpCode::kHandle, 17, 14 },
  /*  2 */ { OpCode::kOp, 0 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kOp, 2 },
  /*  5 */ { OpCode::kLet },
  /*  6 */ { OpCode::kAccessVar, 1 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kEndLet },
  /* 10 */ { OpCode::kEndLet },
  /* 11 */ { OpCode::kPrim, PrimCode::kSub },
  /* 12 */ { OpCode::kEndHandle },
  /* 13 */ { OpCode::kReturn },
  /* 14 */ { OpCode::kEndHandle },
  /* 15 */ { OpCode::kReturn },
  /* 16 */ { OpCode::kExit },

  /* 17 */ { OpCode::kConstInt, 44 },
  /* 18 */ { OpCode::kPush },
  /* 19 */ { OpCode::kAccessVar, 1 },
  /* 20 */ { OpCode::kCall },
  /* 21 */ { OpCode::kReturn },

  /* 22 */ { OpCode::kConstInt, 36 },
  /* 23 */ { OpCode::kPush },
  /* 24 */ { OpCode::kAccessVar, 1 },
  /* 25 */ { OpCode::kCall },
  /* 26 */ { OpCode::kLet },
  /* 27 */ { OpCode::kConstInt, 36 },
  /* 28 */ { OpCode::kPush },
  /* 29 */ { OpCode::kAccessVar, 2 },
  /* 30 */ { OpCode::kCall },
  /* 31 */ { OpCode::kPush },
  /* 32 */ { OpCode::kAccessVar, 0 },
  /* 33 */ { OpCode::kPrim, PrimCode::kAdd },
  /* 34 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(16)));
}

TEST(MachineTest, Op14) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 34, 28 },
  /*  1 */ { OpCode::kHandle, 29, 26 },
  /*  2 */ { OpCode::kHandle, 0, 24 },
  /*  3 */ { OpCode::kHandle, 0, 22 },
  /*  4 */ { OpCode::kHandle, 0, 20 },
  /*  5 */ { OpCode::kHandle, 0, 18 },
  /*  6 */ { OpCode::kHandle, 0, 16 },
  /*  7 */ { OpCode::kOp, 5 },
  /*  8 */ { OpCode::kLet},
  /*  9 */ { OpCode::kOp, 7 },
  /* 10 */ { OpCode::kPush},
  /* 11 */ { OpCode::kAccessVar, 0},
  /* 12 */ { OpCode::kEndLet},
  /* 13 */ { OpCode::kPrim, PrimCode::kSub },
  /* 14 */ { OpCode::kEndHandle },
  /* 15 */ { OpCode::kReturn },
  /* 16 */ { OpCode::kEndHandle },
  /* 17 */ { OpCode::kReturn },
  /* 18 */ { OpCode::kEndHandle },
  /* 19 */ { OpCode::kReturn },
  /* 20 */ { OpCode::kEndHandle },
  /* 21 */ { OpCode::kReturn },
  /* 22 */ { OpCode::kEndHandle },
  /* 23 */ { OpCode::kReturn },
  /* 24 */ { OpCode::kEndHandle },
  /* 25 */ { OpCode::kReturn },
  /* 26 */ { OpCode::kEndHandle },
  /* 27 */ { OpCode::kReturn },
  /* 28 */ { OpCode::kExit },

  /* 29 */ { OpCode::kConstInt, 44 },
  /* 30 */ { OpCode::kPush },
  /* 31 */ { OpCode::kAccessVar, 1 },
  /* 32 */ { OpCode::kCall },
  /* 33 */ { OpCode::kReturn },

  /* 34 */ { OpCode::kConstInt, 36 },
  /* 35 */ { OpCode::kPush },
  /* 36 */ { OpCode::kAccessVar, 1 },
  /* 37 */ { OpCode::kCall },
  /* 38 */ { OpCode::kPush },
  /* 39 */ { OpCode::kConstInt, 36 },
  /* 40 */ { OpCode::kPush },
  /* 41 */ { OpCode::kAccessVar, 1 },
  /* 42 */ { OpCode::kCall },
  /* 43 */ { OpCode::kPrim, PrimCode::kAdd },
  /* 44 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(-16)));
}

TEST(MachineTest, Op15) {
  Program program = {
    { OpCode::kOp, 0 },
  };
 EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, Op16) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 5, 4 },
  /*  1 */ { OpCode::kOp, 1 },
  /*  2 */ { OpCode::kEndHandle },
  /*  3 */ { OpCode::kReturn },
  /*  4 */ { OpCode::kExit },

  /*  5 */ { OpCode::kConstInt, 36 },
  /*  6 */ { OpCode::kReturn }
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, Op17) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 12, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kHandle, 10, 9 },
  /*  3 */ { OpCode::kAccessVar, 0 },
  /*  4 */ { OpCode::kPush },
  /*  5 */ { OpCode::kAccessVar, 1 },
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kEndHandle },
  /*  8 */ { OpCode::kReturn },
  /*  9 */ { OpCode::kExit },

  /* 10 */ { OpCode::kConstInt, 36 },
  /* 11 */ { OpCode::kReturn },

  /* 12 */ { OpCode::kConstInt, 0 },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kMakeClosure, 17, 1 },
  /* 15 */ { OpCode::kCall },
  /* 16 */ { OpCode::kReturn },

  /* 17 */ { OpCode::kOp, 1 },
  /* 18 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, Op18) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 15, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kHandle, 10, 9 },
  /*  3 */ { OpCode::kAccessVar, 0 },
  /*  4 */ { OpCode::kPush },
  /*  5 */ { OpCode::kAccessVar, 1 },
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kEndHandle },
  /*  8 */ { OpCode::kReturn },
  /*  9 */ { OpCode::kExit },

  /* 10 */ { OpCode::kConstInt, 36 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kAccessVar, 1 },
  /* 13 */ { OpCode::kCall },
  /* 14 */ { OpCode::kReturn },

  /* 15 */ { OpCode::kConstInt, 0 },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kMakeClosure, 20, 1 },
  /* 18 */ { OpCode::kCall },
  /* 19 */ { OpCode::kReturn },

  /* 20 */ { OpCode::kOp, 1 },
  /* 21 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, Op19) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 15, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kHandle, 10, 9 },
  /*  3 */ { OpCode::kAccessVar, 0 },
  /*  4 */ { OpCode::kPush },
  /*  5 */ { OpCode::kAccessVar, 1 },
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kEndHandle },
  /*  8 */ { OpCode::kReturn },
  /*  9 */ { OpCode::kExit },

  /* 10 */ { OpCode::kAccessVar, 0 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kAccessVar, 1 },
  /* 13 */ { OpCode::kCall },
  /* 14 */ { OpCode::kReturn },

  /* 15 */ { OpCode::kConstInt, 0 },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kMakeClosure, 20, 1 },
  /* 18 */ { OpCode::kCall },
  /* 19 */ { OpCode::kReturn },

  /* 20 */ { OpCode::kConstInt, 36 },
  /* 21 */ { OpCode::kOp, 1 },
  /* 22 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, Op20) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 32 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kHandle, 9, 8 },
  /*  3 */ { OpCode::kConstInt, 34 },
  /*  4 */ { OpCode::kOp, 0 },
  /*  5 */ { OpCode::kEndHandle },
  /*  6 */ { OpCode::kAccessVar, 0 },
  /*  7 */ { OpCode::kReturn },
  /*  8 */ { OpCode::kExit },

  /*  9 */ { OpCode::kConstInt, 36 },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kAccessVar, 1 },
  /* 12 */ { OpCode::kCall },
  /* 13 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(32)));
}

TEST(MachineTest, TailCall1) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 0 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kMakeClosure, 7, 1 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kMakeClosure, 9, 1 },
  /*  5 */ { OpCode::kCall },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kConstInt, 5 },
  /*  8 */ { OpCode::kReturn },

  /*  9 */ { OpCode::kConstInt, 0 },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kAccessVar, 1 },
  /* 12 */ { OpCode::kTailCall },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, TailCall2) {
  Program program = {
  /* 0 */ { OpCode::kMakeClosure, 3, 1 },
  /* 1 */ { OpCode::kTailCall },
  /* 2 */ { OpCode::kExit },

  /* 3 */ { OpCode::kConstInt, 5 },
  /* 4 */ { OpCode::kReturn },
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, TailCall3) {
  Program program = {
  /* 0 */ { OpCode::kHandle, 5, 4 },
  /* 1 */ { OpCode::kOp, 0 },
  /* 2 */ { OpCode::kEndHandle },
  /* 3 */ { OpCode::kReturn },
  /* 4 */ { OpCode::kExit },

  /* 5 */ { OpCode::kConstInt, 36 },
  /* 6 */ { OpCode::kPush },
  /* 7 */ { OpCode::kAccessVar, 1 },
  /* 8 */ { OpCode::kTailCall }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, TailCall4) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 7, 6 },
  /*  1 */ { OpCode::kConstInt, 44 },
  /*  2 */ { OpCode::kPush },
  /*  3 */ { OpCode::kOp, 0 },
  /*  4 */ { OpCode::kEndHandle },
  /*  5 */ { OpCode::kReturn },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kAccessVar, 0 },
  /*  8 */ { OpCode::kPush },
  /*  9 */ { OpCode::kAccessVar, 1 },
  /* 10 */ { OpCode::kTailCall }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, TailCall5) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 6, 5 },
  /*  1 */ { OpCode::kOp, 0 },
  /*  2 */ { OpCode::kEndHandle },
  /*  3 */ { OpCode::kConstInt, 32 },
  /*  4 */ { OpCode::kReturn },
  /*  5 */ { OpCode::kExit },

  /*  6 */ { OpCode::kConstInt, 36 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kAccessVar, 1 },
  /*  9 */ { OpCode::kTailCall }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(32)));
}

TEST(MachineTest, TailCall6) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 15, 10 },
  /*  1 */ { OpCode::kHandle, 11, 8 },
  /*  2 */ { OpCode::kOp, 1 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kOp, 0 },
  /*  5 */ { OpCode::kPrim, PrimCode::kSub },
  /*  6 */ { OpCode::kEndHandle },
  /*  7 */ { OpCode::kReturn },
  /*  8 */ { OpCode::kEndHandle },
  /*  9 */ { OpCode::kReturn },
  /* 10 */ { OpCode::kExit },

  /* 11 */ { OpCode::kConstInt, 44 },
  /* 12 */ { OpCode::kPush },
  /* 13 */ { OpCode::kAccessVar, 1 },
  /* 14 */ { OpCode::kTailCall },

  /* 15 */ { OpCode::kConstInt, 36 },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kAccessVar, 1 },
  /* 18 */ { OpCode::kTailCall }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(-8)));
}

TEST(MachineTest, TailCall7) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 15, 10 },
  /*  1 */ { OpCode::kHandle, 11, 8 },
  /*  2 */ { OpCode::kOp, 0 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kOp, 1 },
  /*  5 */ { OpCode::kPrim, PrimCode::kSub },
  /*  6 */ { OpCode::kEndHandle },
  /*  7 */ { OpCode::kReturn },
  /*  8 */ { OpCode::kEndHandle },
  /*  9 */ { OpCode::kReturn },
  /* 10 */ { OpCode::kExit },

  /* 11 */ { OpCode::kConstInt, 44 },
  /* 12 */ { OpCode::kPush },
  /* 13 */ { OpCode::kAccessVar, 1 },
  /* 14 */ { OpCode::kTailCall },

  /* 15 */ { OpCode::kConstInt, 36 },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kAccessVar, 1 },
  /* 18 */ { OpCode::kTailCall }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(8)));
}

TEST(MachineTest, TailCall8) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 15, 10 },
  /*  1 */ { OpCode::kHandle, 11, 5 },
  /*  2 */ { OpCode::kOp, 0 },
  /*  3 */ { OpCode::kEndHandle },
  /*  4 */ { OpCode::kReturn },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kOp, 0 },
  /*  7 */ { OpCode::kPrim, PrimCode::kSub },
  /*  8 */ { OpCode::kEndHandle },
  /*  9 */ { OpCode::kReturn },
  /* 10 */ { OpCode::kExit },

  /* 11 */ { OpCode::kConstInt, 44 },
  /* 12 */ { OpCode::kPush },
  /* 13 */ { OpCode::kAccessVar, 1 },
  /* 14 */ { OpCode::kTailCall },

  /* 15 */ { OpCode::kConstInt, 36 },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kAccessVar, 1 },
  /* 18 */ { OpCode::kTailCall }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(8)));
}

TEST(MachineTest, TailCall9) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 18, 13 },
  /*  1 */ { OpCode::kHandle, 14, 11 },
  /*  2 */ { OpCode::kOp, 0 },
  /*  3 */ { OpCode::kLet},
  /*  4 */ { OpCode::kOp, 2 },
  /*  5 */ { OpCode::kPush},
  /*  6 */ { OpCode::kAccessVar, 0 },
  /*  7 */ { OpCode::kEndLet},
  /*  8 */ { OpCode::kPrim, PrimCode::kSub },
  /*  9 */ { OpCode::kEndHandle },
  /* 10 */ { OpCode::kReturn },
  /* 11 */ { OpCode::kEndHandle },
  /* 12 */ { OpCode::kReturn },
  /* 13 */ { OpCode::kExit },

  /* 14 */ { OpCode::kConstInt, 44 },
  /* 15 */ { OpCode::kPush },
  /* 16 */ { OpCode::kAccessVar, 1 },
  /* 17 */ { OpCode::kTailCall },

  /* 18 */ { OpCode::kConstInt, 36 },
  /* 19 */ { OpCode::kPush },
  /* 20 */ { OpCode::kAccessVar, 1 },
  /* 21 */ { OpCode::kCall },
  /* 22 */ { OpCode::kPush },
  /* 23 */ { OpCode::kConstInt, 36 },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kAccessVar, 1 },
  /* 26 */ { OpCode::kCall },
  /* 27 */ { OpCode::kPrim, PrimCode::kAdd },
  /* 28 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(-16)));
}

TEST(MachineTest, TailCall10) {
  Program program = {
  /*  0 */ { OpCode::kHandle, 33, 28 },
  /*  1 */ { OpCode::kHandle, 29, 26 },
  /*  2 */ { OpCode::kHandle, 0, 24 },
  /*  3 */ { OpCode::kHandle, 0, 22 },
  /*  4 */ { OpCode::kHandle, 0, 20 },
  /*  5 */ { OpCode::kHandle, 0, 18 },
  /*  6 */ { OpCode::kHandle, 0, 16 },
  /*  7 */ { OpCode::kOp, 5 },
  /*  8 */ { OpCode::kLet },
  /*  9 */ { OpCode::kOp, 7 },
  /*  8 */ { OpCode::kPush },
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  8 */ { OpCode::kEndLet },
  /* 10 */ { OpCode::kPrim, PrimCode::kSub },
  /* 11 */ { OpCode::kEndHandle },
  /* 12 */ { OpCode::kReturn },
  /* 13 */ { OpCode::kEndHandle },
  /* 14 */ { OpCode::kReturn },
  /* 15 */ { OpCode::kEndHandle },
  /* 16 */ { OpCode::kReturn },
  /* 17 */ { OpCode::kEndHandle },
  /* 18 */ { OpCode::kReturn },
  /* 19 */ { OpCode::kEndHandle },
  /* 20 */ { OpCode::kReturn },
  /* 21 */ { OpCode::kEndHandle },
  /* 22 */ { OpCode::kReturn },
  /* 23 */ { OpCode::kEndHandle },
  /* 24 */ { OpCode::kReturn },
  /* 25 */ { OpCode::kExit },

  /* 26 */ { OpCode::kConstInt, 44 },
  /* 27 */ { OpCode::kPush },
  /* 28 */ { OpCode::kAccessVar, 1 },
  /* 29 */ { OpCode::kTailCall },

  /* 30 */ { OpCode::kConstInt, 36 },
  /* 31 */ { OpCode::kPush },
  /* 32 */ { OpCode::kAccessVar, 1 },
  /* 33 */ { OpCode::kCall },
  /* 34 */ { OpCode::kPush },
  /* 35 */ { OpCode::kConstInt, 36 },
  /* 36 */ { OpCode::kPush },
  /* 37 */ { OpCode::kAccessVar, 1 },
  /* 38 */ { OpCode::kCall },
  /* 39 */ { OpCode::kPrim, PrimCode::kAdd },
  /* 40 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(-16)));
}

TEST(MachineTest, TailCall11) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 12, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kHandle, 10, 9 },
  /*  3 */ { OpCode::kAccessVar, 0 },
  /*  4 */ { OpCode::kPush },
  /*  5 */ { OpCode::kAccessVar, 1 },
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kEndHandle },
  /*  8 */ { OpCode::kReturn },
  /*  9 */ { OpCode::kExit },

  /* 10 */ { OpCode::kConstInt, 36 },
  /* 11 */ { OpCode::kReturn },

  /* 12 */ { OpCode::kConstInt, 0 },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kMakeClosure, 16, 1 },
  /* 15 */ { OpCode::kTailCall },

  /* 16 */ { OpCode::kOp, 1 },
  /* 17 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, TailCall12) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 14, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kHandle, 10, 9 },
  /*  3 */ { OpCode::kAccessVar, 0 },
  /*  4 */ { OpCode::kPush },
  /*  5 */ { OpCode::kAccessVar, 1 },
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kEndHandle },
  /*  8 */ { OpCode::kReturn },
  /*  9 */ { OpCode::kExit },

  /* 10 */ { OpCode::kConstInt, 36 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kAccessVar, 1 },
  /* 13 */ { OpCode::kTailCall },

  /* 14 */ { OpCode::kConstInt, 0 },
  /* 15 */ { OpCode::kPush },
  /* 16 */ { OpCode::kMakeClosure, 18, 1 },
  /* 17 */ { OpCode::kTailCall },

  /* 18 */ { OpCode::kOp, 1 },
  /* 19 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, TailCall13) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 14, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kHandle, 10, 9 },
  /*  3 */ { OpCode::kAccessVar, 0 },
  /*  4 */ { OpCode::kPush },
  /*  5 */ { OpCode::kAccessVar, 1 },
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kEndHandle },
  /*  8 */ { OpCode::kReturn },
  /*  9 */ { OpCode::kExit },

  /* 10 */ { OpCode::kAccessVar, 0 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kAccessVar, 1 },
  /* 13 */ { OpCode::kTailCall },

  /* 14 */ { OpCode::kConstInt, 0 },
  /* 15 */ { OpCode::kPush },
  /* 16 */ { OpCode::kMakeClosure, 18, 1 },
  /* 17 */ { OpCode::kTailCall },

  /* 18 */ { OpCode::kConstInt, 36 },
  /* 19 */ { OpCode::kOp, 1 },
  /* 20 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, TailCall14) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 32 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kHandle, 9, 8 },
  /*  3 */ { OpCode::kConstInt, 34 },
  /*  4 */ { OpCode::kOp, 0 },
  /*  5 */ { OpCode::kEndHandle },
  /*  6 */ { OpCode::kAccessVar, 0 },
  /*  7 */ { OpCode::kReturn },
  /*  8 */ { OpCode::kExit },

  /*  9 */ { OpCode::kConstInt, 36 },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kAccessVar, 1 },
  /* 12 */ { OpCode::kTailCall },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(32)));
}

TEST(MachineTest, TailCall15) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 0 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kMakeClosure, 20, 1 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kMakeClosure, 17, 1 },
  /*  5 */ { OpCode::kLet },
  /*  6 */ { OpCode::kMakeClosure, 14, 1 },
  /*  7 */ { OpCode::kLet },
  /*  8 */ { OpCode::kMakeClosure, 11, 1 },
  /*  9 */ { OpCode::kCall },
  /* 10 */ { OpCode::kExit },

  /* 11 */ { OpCode::kAccessVar, 1},
  /* 12 */ { OpCode::kPush },
  /* 13 */ { OpCode::kTailCall },

  /* 14 */ { OpCode::kAccessVar, 1},
  /* 15 */ { OpCode::kPush },
  /* 16 */ { OpCode::kTailCall },

  /* 17 */ { OpCode::kAccessVar, 1},
  /* 18 */ { OpCode::kPush },
  /* 19 */ { OpCode::kTailCall },

  /* 20 */ { OpCode::kConstInt, 666},
  /* 21 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(666)));
}

TEST(MachineTest, TailCall16) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 8, 0 },
  /*  1 */ { OpCode::kCall },
  /*  2 */ { OpCode::kExit },

  /*  3 */ { OpCode::kAccessVar, 0 },
  /*  4 */ { OpCode::kPush },
  /*  5 */ { OpCode::kAccessVar, 1 },
  /*  6 */ { OpCode::kPrim, PrimCode::kAdd },
  /*  7 */ { OpCode::kReturn },

  /*  8 */ { OpCode::kConstInt, 14 },
  /*  9 */ { OpCode::kPush },
  /* 10 */ { OpCode::kConstInt, 18 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kMakeClosure, 3, 2 },
  /* 13 */ { OpCode::kTailCall }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(32)));
}

TEST(MachineTest, TailCall17) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 23 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 3 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kMakeRecursiveBinding, 8, 2 },
  /*  5 */ { OpCode::kAccessRecursiveBinding, 0 },
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kExit },

  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kPush },
  /* 10 */ { OpCode::kAccessVar, 1 },
  /* 11 */ { OpCode::kPrim, PrimCode::kLt },
  /* 12 */ { OpCode::kJumpZero, 15 },
  /* 13 */ { OpCode::kAccessVar, 0 },
  /* 14 */ { OpCode::kReturn },
  /* 15 */ { OpCode::kAccessVar, 0 },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kAccessVar, 1 },
  /* 18 */ { OpCode::kPrim, PrimCode::kSub },
  /* 19 */ { OpCode::kPush },
  /* 20 */ { OpCode::kAccessVar, 1 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kAccessVar, 2 },
  /* 23 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 24 */ { OpCode::kTailCall }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(2)));
}

TEST(MachineTest, TailCall18) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 3, 0 },
  /*  1 */ { OpCode::kCall },
  /*  2 */ { OpCode::kExit },

  /*  3 */ { OpCode::kConstInt, 23 },
  /*  4 */ { OpCode::kLet },
  /*  5 */ { OpCode::kConstInt, 3 },
  /*  6 */ { OpCode::kLet },
  /*  7 */ { OpCode::kMakeClosure, 11, 0 },
  /*  8 */ { OpCode::kEndLet },
  /*  9 */ { OpCode::kEndLet },
  /* 10 */ { OpCode::kTailCall },

  /* 11 */ { OpCode::kAccessVar, 0 },
  /* 12 */ { OpCode::kPush },
  /* 13 */ { OpCode::kAccessVar, 1 },
  /* 14 */ { OpCode::kPrim, PrimCode::kAdd },
  /* 15 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(26)));
}

TEST(MachineTest, Global1) {
  Program program = {
    { OpCode::kConstInt, 55 },
    { OpCode::kCreateGlobal },
    { OpCode::kAccessGlobal, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(55)));
}

TEST(MachineTest, Global2) {
  Program program = {
    { OpCode::kConstInt, 1 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 2 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 3 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 4 },
    { OpCode::kCreateGlobal },
    { OpCode::kAccessGlobal, 2 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(3)));
}

TEST(MachineTest, Global3) {
  Program program = {
    { OpCode::kConstInt, 1 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 2 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 3 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 4 },
    { OpCode::kCreateGlobal },
    { OpCode::kAccessGlobal, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Global4) {
  Program program = {
    { OpCode::kConstInt, 1 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 2 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 3 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 4 },
    { OpCode::kCreateGlobal },
    { OpCode::kAccessGlobal, 3 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(4)));
}

TEST(MachineTest, Global5) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kPush },
    { OpCode::kConstInt, 42 },
    { OpCode::kMakeRecord, 2 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 1756 },
    { OpCode::kMakeRecord, 1 },
    { OpCode::kAccessGlobal, 0 },
    { OpCode::kGetField, 0 },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(44)));
}

TEST(MachineTest, Global6) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 276 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kMakeClosure, 9, 1 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kConstInt, 1756 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kAccessGlobal, 0 },
  /*  7 */ { OpCode::kCall },
  /*  8 */ { OpCode::kExit },

  /*  9 */ { OpCode::kAccessVar, 1 },
  /* 10 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(276)));
}

TEST(MachineTest, Global7) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 17, 1 },
  /*  1 */ { OpCode::kCreateGlobal },
  /*  2 */ { OpCode::kConstInt, 276 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kMakeClosure, 19, 1 },
  /*  5 */ { OpCode::kCreateGlobal },
  /*  6 */ { OpCode::kConstInt, 1756 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kAccessGlobal, 2 },
  /*  9 */ { OpCode::kCall },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kAccessGlobal, 0 },
  /* 12 */ { OpCode::kCall },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kAccessGlobal, 2 },
  /* 15 */ { OpCode::kCall },
  /* 16 */ { OpCode::kExit },

  /* 17 */ { OpCode::kConstInt, 22 },
  /* 18 */ { OpCode::kReturn },

  /* 19 */ { OpCode::kAccessGlobal, 1 },
  /* 20 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(276)));
}

TEST(MachineTest, Global8) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 9, 1 },
  /*  1 */ { OpCode::kCreateGlobal },
  /*  2 */ { OpCode::kMakeClosure, 19, 1 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kConstInt, 1756 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kAccessGlobal, 0 }, // Call Even
  /*  7 */ { OpCode::kCall },
  /*  8 */ { OpCode::kExit },

  /* Even */
  /*  9 */ { OpCode::kAccessVar, 0 },
  /* 10 */ { OpCode::kJumpZero, 17 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kConstInt, 1 },
  /* 13 */ { OpCode::kPrim, PrimCode::kSub },
  /* 14 */ { OpCode::kPush },
  /* 15 */ { OpCode::kAccessGlobal, 1 }, // Call Odd
  /* 16 */ { OpCode::kTailCall },
  /* 17 */ { OpCode::kConstInt, 1 },
  /* 18 */ { OpCode::kReturn },

  /* Odd */
  /* 19 */ { OpCode::kAccessVar, 0 },
  /* 20 */ { OpCode::kJumpZero, 27 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kConstInt, 1 },
  /* 23 */ { OpCode::kPrim, PrimCode::kSub },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kAccessGlobal, 0 }, // Call Even
  /* 26 */ { OpCode::kTailCall },
  /* 27 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Global9) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 9, 1 },
  /*  1 */ { OpCode::kCreateGlobal },
  /*  2 */ { OpCode::kMakeClosure, 19, 1 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kConstInt, 67 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kAccessGlobal, 0 }, // Call Even
  /*  7 */ { OpCode::kCall },
  /*  8 */ { OpCode::kExit },

  /* Even */
  /*  9 */ { OpCode::kAccessVar, 0 },
  /* 10 */ { OpCode::kJumpZero, 17 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kConstInt, 1 },
  /* 13 */ { OpCode::kPrim, PrimCode::kSub },
  /* 14 */ { OpCode::kPush },
  /* 15 */ { OpCode::kAccessGlobal, 1 }, // Call Odd
  /* 16 */ { OpCode::kTailCall },
  /* 17 */ { OpCode::kConstInt, 1 },
  /* 18 */ { OpCode::kReturn },

  /* Odd */
  /* 19 */ { OpCode::kAccessVar, 0 },
  /* 20 */ { OpCode::kJumpZero, 27 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kConstInt, 1 },
  /* 23 */ { OpCode::kPrim, PrimCode::kSub },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kAccessGlobal, 0 }, // Call Even
  /* 26 */ { OpCode::kTailCall },
  /* 27 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Global10) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 9, 1 },
  /*  1 */ { OpCode::kCreateGlobal },
  /*  2 */ { OpCode::kMakeClosure, 19, 1 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kConstInt, 44 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kAccessGlobal, 1 }, // Call Odd
  /*  7 */ { OpCode::kCall },
  /*  8 */ { OpCode::kExit },

  /* Even */
  /*  9 */ { OpCode::kAccessVar, 0 },
  /* 10 */ { OpCode::kJumpZero, 17 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kConstInt, 1 },
  /* 13 */ { OpCode::kPrim, PrimCode::kSub },
  /* 14 */ { OpCode::kPush },
  /* 15 */ { OpCode::kAccessGlobal, 1 }, // Call Odd
  /* 16 */ { OpCode::kTailCall },
  /* 17 */ { OpCode::kConstInt, 1 },
  /* 18 */ { OpCode::kReturn },

  /* Odd */
  /* 19 */ { OpCode::kAccessVar, 0 },
  /* 20 */ { OpCode::kJumpZero, 27 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kConstInt, 1 },
  /* 23 */ { OpCode::kPrim, PrimCode::kSub },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kAccessGlobal, 0 }, // Call Even
  /* 26 */ { OpCode::kTailCall },
  /* 27 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, Global11) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 9, 1 },
  /*  1 */ { OpCode::kCreateGlobal },
  /*  2 */ { OpCode::kMakeClosure, 19, 1 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kConstInt, 55 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kAccessGlobal, 1 }, // Call Odd
  /*  7 */ { OpCode::kCall },
  /*  8 */ { OpCode::kExit },

  /* Even */
  /*  9 */ { OpCode::kAccessVar, 0 },
  /* 10 */ { OpCode::kJumpZero, 17 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kConstInt, 1 },
  /* 13 */ { OpCode::kPrim, PrimCode::kSub },
  /* 14 */ { OpCode::kPush },
  /* 15 */ { OpCode::kAccessGlobal, 1 }, // Call Odd
  /* 16 */ { OpCode::kTailCall },
  /* 17 */ { OpCode::kConstInt, 1 },
  /* 18 */ { OpCode::kReturn },

  /* Odd */
  /* 19 */ { OpCode::kAccessVar, 0 },
  /* 20 */ { OpCode::kJumpZero, 27 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kConstInt, 1 },
  /* 23 */ { OpCode::kPrim, PrimCode::kSub },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kAccessGlobal, 0 }, // Call Even
  /* 26 */ { OpCode::kTailCall },
  /* 27 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, Global12) {
  Program program = {
    { OpCode::kMakeClosure, 7, 1 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 19 },
    { OpCode::kPush },
    { OpCode::kAccessGlobal, 0 },
    { OpCode::kCall },
    { OpCode::kExit },
    { OpCode::kAccessVar, 0 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLtConst, 2 },
    { OpCode::kJumpZero, 12 },
    { OpCode::kAccessVar, 0 },
    { OpCode::kReturn },
    { OpCode::kAccessVar, 0 },
    { OpCode::kPrimUnary, PrimUnaryCode::kSubConst, 1 },
    { OpCode::kPush },
    { OpCode::kAccessGlobal, 0 },
    { OpCode::kCall },
    { OpCode::kPush },
    { OpCode::kAccessVar, 0 },
    { OpCode::kPrimUnary, PrimUnaryCode::kSubConst, 2 },
    { OpCode::kPush },
    { OpCode::kAccessGlobal, 0 },
    { OpCode::kCall },
    { OpCode::kPrim, PrimCode::kAdd },
    { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(4181)));
}

TEST(MachineTest, CallGlobal1) {
  Program program = {
  /* 0 */ { OpCode::kMakeClosure, 5, 1 },
  /* 1 */ { OpCode::kCreateGlobal },
  /* 2 */ { OpCode::kConstInt, 5 },
  /* 3 */ { OpCode::kCallGlobal, 0 },
  /* 4 */ { OpCode::kExit },

  /* 5 */ { OpCode::kAccessVar, 0 },
  /* 6 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, CallGlobal2) {
  Program program = {
  /* 0 */ { OpCode::kMakeClosure, 7, 2 },
  /* 1 */ { OpCode::kCreateGlobal },
  /* 2 */ { OpCode::kConstInt, 4 },
  /* 3 */ { OpCode::kPush },
  /* 4 */ { OpCode::kConstInt, 5 },
  /* 5 */ { OpCode::kCallGlobal, 0 },
  /* 6 */ { OpCode::kExit },

  /* 7 */ { OpCode::kAccessVar, 1 },
  /* 8 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, CallGlobal3) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 9, 3 },
  /*  1 */ { OpCode::kCreateGlobal },
  /*  2 */ { OpCode::kConstInt, 3 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 4 },
  /*  5 */ { OpCode::kPush },
  /*  6 */ { OpCode::kConstInt, 5 },
  /*  7 */ { OpCode::kCallGlobal, 0 },
  /*  8 */ { OpCode::kExit },

  /*  9 */ { OpCode::kAccessVar, 2 },
  /* 10 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, CallGlobal4) {
  Program program = {
  /* 0 */ { OpCode::kMakeClosure, 4, 2 },
  /* 1 */ { OpCode::kCreateGlobal },
  /* 2 */ { OpCode::kCallGlobal, 0 },
  /* 3 */ { OpCode::kExit },

  /* 4 */ { OpCode::kConstInt, 5 },
  /* 5 */ { OpCode::kReturn },
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, CallGlobal5) {
  Program program = {
  /* 0 */ { OpCode::kMakeClosure, 4, 0 },
  /* 1 */ { OpCode::kCreateGlobal },
  /* 2 */ { OpCode::kCallGlobal, 0 },
  /* 3 */ { OpCode::kExit },

  /* 4 */ { OpCode::kConstInt, 5 },
  /* 5 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, CallGlobal6) {
  Program program = {
  /* 0 */ { OpCode::kMakeClosure, 4, 1 },
  /* 1 */ { OpCode::kCreateGlobal },
  /* 2 */ { OpCode::kCallGlobal, 0 },
  /* 3 */ { OpCode::kExit },

  /* 4 */ { OpCode::kConstInt, 5 },
  /* 5 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, CallGlobal7) {
  Program program = {
    { OpCode::kMakeClosure, 5, 1 },
    { OpCode::kCreateGlobal },
    { OpCode::kConstInt, 19 },
    { OpCode::kCallGlobal, 0 },
    { OpCode::kExit },
    { OpCode::kAccessVar, 0 },
    { OpCode::kPrimUnary, PrimUnaryCode::kLtConst, 2 },
    { OpCode::kJumpZero, 10 },
    { OpCode::kAccessVar, 0 },
    { OpCode::kReturn },
    { OpCode::kAccessVar, 0 },
    { OpCode::kPrimUnary, PrimUnaryCode::kSubConst, 1 },
    { OpCode::kCallGlobal, 0 },
    { OpCode::kPush },
    { OpCode::kAccessVar, 0 },
    { OpCode::kPrimUnary, PrimUnaryCode::kSubConst, 2 },
    { OpCode::kCallGlobal, 0 },
    { OpCode::kPrim, PrimCode::kAdd },
    { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(4181)));
}

TEST(MachineTest, TailCallGlobal1) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 0 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kMakeClosure, 7, 1 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kMakeClosure, 9, 1 },
  /*  5 */ { OpCode::kCall },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kConstInt, 5 },
  /*  8 */ { OpCode::kReturn },

  /*  9 */ { OpCode::kConstInt, 0 },
  /* 12 */ { OpCode::kTailCallGlobal, 0 },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, TailCallGlobal2) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 0 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kMakeClosure, 7, 1 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kMakeClosure, 9, 1 },
  /*  5 */ { OpCode::kCall },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kConstInt, 5 },
  /*  8 */ { OpCode::kReturn },

  /* 9 */ { OpCode::kTailCallGlobal, 0 },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, TailCallGlobal3) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 0 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kMakeClosure, 7, 2 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kMakeClosure, 9, 1 },
  /*  5 */ { OpCode::kCall },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kAccessVar, 0 },
  /*  8 */ { OpCode::kReturn },

  /*  9 */ { OpCode::kConstInt, 1 },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kConstInt, 2 },
  /* 12 */ { OpCode::kTailCallGlobal, 0 },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, TailCallGlobal4) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 0 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kMakeClosure, 7, 2 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kMakeClosure, 9, 1 },
  /*  5 */ { OpCode::kCall },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kAccessVar, 1 },
  /*  8 */ { OpCode::kReturn },

  /*  9 */ { OpCode::kConstInt, 1 },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kConstInt, 2 },
  /* 12 */ { OpCode::kTailCallGlobal, 0 },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(2)));
}

TEST(MachineTest, TailCallGlobal5) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 0 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kMakeClosure, 7, 2 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kMakeClosure, 9, 1 },
  /*  5 */ { OpCode::kCall },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kConstInt, 5 },
  /*  8 */ { OpCode::kReturn },

  /* 12 */ { OpCode::kTailCallGlobal, 0 },
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, TailCallGlobal6) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 7, 1 },
  /*  1 */ { OpCode::kCreateGlobal },
  /*  2 */ { OpCode::kMakeClosure, 15, 1 },
  /*  3 */ { OpCode::kCreateGlobal },
  /*  4 */ { OpCode::kConstInt, 55 },
  /*  5 */ { OpCode::kCallGlobal, 1 },
  /*  6 */ { OpCode::kExit },

  /* Even */
  /*  7 */ { OpCode::kAccessVar, 0 },
  /*  8 */ { OpCode::kJumpZero, 13 },
  /*  9 */ { OpCode::kPush },
  /* 10 */ { OpCode::kConstInt, 1 },
  /* 11 */ { OpCode::kPrim, PrimCode::kSub },
  /* 12 */ { OpCode::kTailCallGlobal, 1 },  // Call Odd
  /* 13 */ { OpCode::kConstInt, 1 },
  /* 14 */ { OpCode::kReturn },

  /* Odd */
  /* 15 */ { OpCode::kAccessVar, 0 },
  /* 16 */ { OpCode::kJumpZero, 20 },
  /* 17 */ { OpCode::kPush },
  /* 18 */ { OpCode::kConstInt, 1 },
  /* 19 */ { OpCode::kPrim, PrimCode::kSub },
  /* 20 */ { OpCode::kTailCallGlobal, 0 }, // Call Even
  /* 21 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, CallLocal1) {
  Program program = {
  /* 0 */ { OpCode::kMakeClosure, 5, 1 },
  /* 1 */ { OpCode::kLet },
  /* 2 */ { OpCode::kConstInt, 1756 },
  /* 3 */ { OpCode::kCallLocal, 0 },
  /* 4 */ { OpCode::kExit },

  /* 5 */ { OpCode::kAccessVar, 0 },
  /* 6 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1756)));
}

TEST(MachineTest, CallLocal2) {
  Program program = {
  /* 0 */ { OpCode::kMakeClosure, 3, 1 },
  /* 1 */ { OpCode::kCallLocal, 0 },
  /* 2 */ { OpCode::kExit },

  /* 3 */ { OpCode::kConstInt, 5 },
  /* 4 */ { OpCode::kReturn },
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, CallLocal3) {
  Program program = {
  /*  0 */ { OpCode::kMakeClosure, 8, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 44 },
  /*  3 */ { OpCode::kCallLocal, 0 },
  /*  4 */ { OpCode::kPush },
  /*  5 */ { OpCode::kConstInt, 6 },
  /*  6 */ { OpCode::kPrim, PrimCode::kDiv },
  /*  7 */ { OpCode::kExit },

  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kPush },
  /* 10 */ { OpCode::kConstInt, 2 },
  /* 11 */ { OpCode::kPrim, PrimCode::kSub },
  /* 12 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(7)));
}

TEST(MachineTest, CallLocal4) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, 8, 2 },
  /*  1 */ { OpCode::kAccessRecursiveBinding, 0 },
  /*  2 */ { OpCode::kLet },
  /*  3 */ { OpCode::kConstInt, 22 },
  /*  4 */ { OpCode::kPush },
  /*  5 */ { OpCode::kConstInt, 3 },
  /*  6 */ { OpCode::kCallLocal, 0 },
  /*  7 */ { OpCode::kExit },

  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kPush },
  /* 10 */ { OpCode::kAccessVar, 1 },
  /* 11 */ { OpCode::kPrim, PrimCode::kLt },
  /* 12 */ { OpCode::kJumpZero, 15 },
  /* 13 */ { OpCode::kAccessVar, 0 },
  /* 14 */ { OpCode::kReturn },
  /* 15 */ { OpCode::kAccessVar, 0 },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kAccessVar, 1 },
  /* 18 */ { OpCode::kPrim, PrimCode::kSub },
  /* 19 */ { OpCode::kPush },
  /* 20 */ { OpCode::kAccessVar, 1 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kAccessVar, 2 },
  /* 23 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 24 */ { OpCode::kCall },
  /* 25 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, CallLocal5) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, 8, 1 },
  /*  1 */ { OpCode::kAccessRecursiveBinding, 0 },
  /*  2 */ { OpCode::kLet },
  /*  3 */ { OpCode::kConstInt, 3 },
  /*  4 */ { OpCode::kPrimUnary, PrimUnaryCode::kAddConst, 1 },
  /*  5 */ { OpCode::kPrimUnary, PrimUnaryCode::kAddConst, 1 },
  /*  6 */ { OpCode::kCallLocal, 0 },
  /*  7 */ { OpCode::kExit },

  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kJumpNonZero, 12 },
  /* 10 */ { OpCode::kConstInt, 1 },
  /* 11 */ { OpCode::kReturn },
  /* 12 */ { OpCode::kPush },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kConstInt, 1 },
  /* 15 */ { OpCode::kPrim, PrimCode::kSub },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kAccessVar, 1 },
  /* 18 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 19 */ { OpCode::kCall },
  /* 20 */ { OpCode::kPrim, PrimCode::kMult },
  /* 21 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(120)));
}

TEST(MachineTest, TailCallLocal1) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 0 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kMakeClosure, 7, 1 },
  /*  3 */ { OpCode::kLet },
  /*  4 */ { OpCode::kMakeClosure, 9, 1 },
  /*  5 */ { OpCode::kCall },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kConstInt, 5 },
  /*  8 */ { OpCode::kReturn },

  /*  9 */ { OpCode::kConstInt, 0 },
  /* 10 */ { OpCode::kTailCallLocal, 1 },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(5)));
}

TEST(MachineTest, TailCallLocal2) {
  Program program = {
  /* 0 */ { OpCode::kMakeClosure, 3, 1 },
  /* 1 */ { OpCode::kTailCallLocal, 0 },
  /* 2 */ { OpCode::kExit },

  /* 3 */ { OpCode::kConstInt, 5 },
  /* 4 */ { OpCode::kReturn },
  };
  EXPECT_DEATH(hvm::Run(program), ".*");
}

TEST(MachineTest, TailCallLocal3) {
  Program program = {
  /* 0 */ { OpCode::kHandle, 5, 4 },
  /* 1 */ { OpCode::kOp, 0 },
  /* 2 */ { OpCode::kEndHandle },
  /* 3 */ { OpCode::kReturn },
  /* 4 */ { OpCode::kExit },

  /* 5 */ { OpCode::kConstInt, 36 },
  /* 6 */ { OpCode::kTailCallLocal, 1 }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(36)));
}

TEST(MachineTest, TailCallLocal4) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, {8, 1, 19, 1} },
  /*  1 */ { OpCode::kAccessRecursiveBinding, 0 }, // Get Even
  /*  2 */ { OpCode::kLet },
  /*  3 */ { OpCode::kConstInt, 1754 },
  /*  4 */ { OpCode::kPrimUnary, PrimUnaryCode::kAddConst, 1 },
  /*  5 */ { OpCode::kPrimUnary, PrimUnaryCode::kAddConst, 1 },
  /*  6 */ { OpCode::kCallLocal, 0 },
  /*  7 */ { OpCode::kExit },

  /* Even */
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kJumpZero, 17 },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kAccessVar, 1 }, // Get Odd
  /* 12 */ { OpCode::kAccessRecursiveBinding, 1 },
  /* 13 */ { OpCode::kLet },
  /* 14 */ { OpCode::kConstInt, 1 },
  /* 15 */ { OpCode::kPrim, PrimCode::kSub },
  /* 16 */ { OpCode::kTailCallLocal, 0 },
  /* 17 */ { OpCode::kConstInt, 1 },
  /* 18 */ { OpCode::kReturn },

  /* Odd */
  /* 19 */ { OpCode::kAccessVar, 0 },
  /* 20 */ { OpCode::kJumpZero, 28 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kConstInt, 1 },
  /* 23 */ { OpCode::kPrim, PrimCode::kSub },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kAccessVar, 1 }, // Call Even
  /* 26 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 27 */ { OpCode::kTailCall },
  /* 28 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, CallRecursiveBinding1) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, 7, 2 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 22 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 3 },
  /*  5 */ { OpCode::kCallRecursiveBinding, 0, 0 },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kAccessVar, 0 },
  /*  8 */ { OpCode::kPush },
  /*  9 */ { OpCode::kAccessVar, 1 },
  /* 10 */ { OpCode::kPrim, PrimCode::kLt },
  /* 11 */ { OpCode::kJumpZero, 14 },
  /* 12 */ { OpCode::kAccessVar, 0 },
  /* 13 */ { OpCode::kReturn },
  /* 14 */ { OpCode::kAccessVar, 0 },
  /* 15 */ { OpCode::kPush },
  /* 16 */ { OpCode::kAccessVar, 1 },
  /* 17 */ { OpCode::kPrim, PrimCode::kSub },
  /* 18 */ { OpCode::kPush },
  /* 19 */ { OpCode::kAccessVar, 1 },
  /* 20 */ { OpCode::kPush },
  /* 21 */ { OpCode::kAccessVar, 2 },
  /* 22 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 23 */ { OpCode::kCall },
  /* 24 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, CallRecursiveBinding2) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, 7, 2 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 22 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kConstInt, 3 },
  /*  5 */ { OpCode::kCallRecursiveBinding, 0, 0 },
  /*  6 */ { OpCode::kExit },

  /*  7 */ { OpCode::kAccessVar, 0 },
  /*  8 */ { OpCode::kPush },
  /*  9 */ { OpCode::kAccessVar, 1 },
  /* 10 */ { OpCode::kPrim, PrimCode::kLt },
  /* 11 */ { OpCode::kJumpZero, 14 },
  /* 12 */ { OpCode::kAccessVar, 0 },
  /* 13 */ { OpCode::kReturn },
  /* 14 */ { OpCode::kAccessVar, 0 },
  /* 15 */ { OpCode::kPush },
  /* 16 */ { OpCode::kAccessVar, 1 },
  /* 17 */ { OpCode::kPrim, PrimCode::kSub },
  /* 18 */ { OpCode::kPush },
  /* 19 */ { OpCode::kAccessVar, 1 },
  /* 20 */ { OpCode::kCallRecursiveBinding, 2, 0 },
  /* 21 */ { OpCode::kReturn }
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, CallRecursiveBinding3) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, 5, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 5 },
  /*  3 */ { OpCode::kCallRecursiveBinding, 0, 0 },
  /*  4 */ { OpCode::kExit },

  /*  5 */ { OpCode::kAccessVar, 0 },
  /*  6 */ { OpCode::kJumpNonZero, 9 },
  /*  7 */ { OpCode::kConstInt, 1 },
  /*  8 */ { OpCode::kReturn },
  /*  9 */ { OpCode::kPush },
  /* 10 */ { OpCode::kPrimUnary, PrimUnaryCode::kSubConst, 1 },
  /* 11 */ { OpCode::kPush },
  /* 12 */ { OpCode::kAccessVar, 1 },
  /* 13 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 14 */ { OpCode::kCall },
  /* 15 */ { OpCode::kPrim, PrimCode::kMult },
  /* 16 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(120)));
}

TEST(MachineTest, CallRecursiveBinding4) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, 5, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 5 },
  /*  3 */ { OpCode::kCallRecursiveBinding, 0, 0 },
  /*  4 */ { OpCode::kExit },

  /*  5 */ { OpCode::kAccessVar, 0 },
  /*  6 */ { OpCode::kJumpNonZero, 9 },
  /*  7 */ { OpCode::kConstInt, 1 },
  /*  8 */ { OpCode::kReturn },
  /*  9 */ { OpCode::kPush },
  /* 10 */ { OpCode::kPrimUnary, PrimUnaryCode::kSubConst, 1 },
  /* 14 */ { OpCode::kCallRecursiveBinding, 1, 0 },
  /* 15 */ { OpCode::kPrim, PrimCode::kMult },
  /* 16 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(120)));
}

TEST(MachineTest, TailCallRecursiveBinding1) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, {6, 1, 14, 1} },
  /*  1 */ { OpCode::kAccessRecursiveBinding, 0 }, // Get Even
  /*  2 */ { OpCode::kLet },
  /*  3 */ { OpCode::kConstInt, 1756 },
  /*  4 */ { OpCode::kCallLocal, 0 },
  /*  5 */ { OpCode::kExit },

  /* Even */
  /*  6 */ { OpCode::kAccessVar, 0 },
  /*  7 */ { OpCode::kJumpZero, 12 },
  /*  8 */ { OpCode::kPush },
  /*  9 */ { OpCode::kConstInt, 1 },
  /* 10 */ { OpCode::kPrim, PrimCode::kSub },
  /* 11 */ { OpCode::kTailCallRecursiveBinding, 1, 1 },  // Call Odd
  /* 12 */ { OpCode::kConstInt, 1 },
  /* 13 */ { OpCode::kReturn },

  /* Odd */
  /* 14 */ { OpCode::kAccessVar, 0 },
  /* 15 */ { OpCode::kJumpZero, 23 },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kConstInt, 1 },
  /* 18 */ { OpCode::kPrim, PrimCode::kSub },
  /* 19 */ { OpCode::kPush },
  /* 20 */ { OpCode::kAccessVar, 1 }, // Call Even
  /* 21 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 22 */ { OpCode::kTailCall },
  /* 23 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, TailCallRecursiveBinding2) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, {5, 1, 13, 1} },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 1756 },
  /*  3 */ { OpCode::kCallRecursiveBinding, 0, 0 },
  /*  4 */ { OpCode::kExit },

  /* Even */
  /*  5 */ { OpCode::kAccessVar, 0 },
  /*  6 */ { OpCode::kJumpZero, 11 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kConstInt, 1 },
  /*  9 */ { OpCode::kPrim, PrimCode::kSub },
  /* 10 */ { OpCode::kTailCallRecursiveBinding, 1, 1 },  // Call Odd
  /* 11 */ { OpCode::kConstInt, 1 },
  /* 12 */ { OpCode::kReturn },

  /* Odd */
  /* 13 */ { OpCode::kAccessVar, 0 },
  /* 14 */ { OpCode::kJumpZero, 22 },
  /* 15 */ { OpCode::kPush },
  /* 16 */ { OpCode::kConstInt, 1 },
  /* 17 */ { OpCode::kPrim, PrimCode::kSub },
  /* 18 */ { OpCode::kPush },
  /* 19 */ { OpCode::kAccessVar, 1 }, // Call Even
  /* 20 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 21 */ { OpCode::kTailCall },
  /* 22 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, TailCallRecursiveBinding3) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, {5, 1, 13, 1} },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 1756 },
  /*  3 */ { OpCode::kCallRecursiveBinding, 0, 0 },
  /*  4 */ { OpCode::kExit },

  /* Even */
  /*  5 */ { OpCode::kAccessVar, 0 },
  /*  6 */ { OpCode::kJumpZero, 11 },
  /*  7 */ { OpCode::kPush },
  /*  8 */ { OpCode::kConstInt, 1 },
  /*  9 */ { OpCode::kPrim, PrimCode::kSub },
  /* 10 */ { OpCode::kTailCallRecursiveBinding, 1, 1 },  // Call Odd
  /* 11 */ { OpCode::kConstInt, 1 },
  /* 12 */ { OpCode::kReturn },

  /* Odd */
  /* 13 */ { OpCode::kAccessVar, 0 },
  /* 14 */ { OpCode::kJumpZero, 19 },
  /* 15 */ { OpCode::kPush },
  /* 16 */ { OpCode::kConstInt, 1 },
  /* 17 */ { OpCode::kPrim, PrimCode::kSub },
  /* 18 */ { OpCode::kTailCallRecursiveBinding, 1, 0 }, // Call Even
  /* 19 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, RecursiveBinding1) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, 8, 1 },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 5 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kAccessVar, 0 },
  /*  5 */ { OpCode::kAccessRecursiveBinding, 0 },
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kExit },

  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kJumpNonZero, 12 },
  /* 10 */ { OpCode::kConstInt, 1 },
  /* 11 */ { OpCode::kReturn },
  /* 12 */ { OpCode::kPush },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kConstInt, 1 },
  /* 15 */ { OpCode::kPrim, PrimCode::kSub },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kAccessVar, 1 },
  /* 18 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 19 */ { OpCode::kCall },
  /* 20 */ { OpCode::kPrim, PrimCode::kMult },
  /* 21 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(120)));
}

TEST(MachineTest, RecursiveBinding2) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, {8, 1, 19, 1} },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 1756 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kAccessVar, 0 },
  /*  5 */ { OpCode::kAccessRecursiveBinding, 0 }, // Call Even
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kExit },

  /* Even */
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kJumpZero, 17 },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kConstInt, 1 },
  /* 12 */ { OpCode::kPrim, PrimCode::kSub },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kAccessVar, 1 }, // Call Odd
  /* 15 */ { OpCode::kAccessRecursiveBinding, 1 },
  /* 16 */ { OpCode::kTailCall },
  /* 17 */ { OpCode::kConstInt, 1 },
  /* 18 */ { OpCode::kReturn },

  /* Odd */
  /* 19 */ { OpCode::kAccessVar, 0 },
  /* 20 */ { OpCode::kJumpZero, 28 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kConstInt, 1 },
  /* 23 */ { OpCode::kPrim, PrimCode::kSub },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kAccessVar, 1 }, // Call Even
  /* 26 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 27 */ { OpCode::kTailCall },
  /* 28 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, RecursiveBinding3) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, {8, 1, 19, 1} },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 67 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kAccessVar, 0 },
  /*  5 */ { OpCode::kAccessRecursiveBinding, 0 }, // Call Even
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kExit },

  /* Even */
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kJumpZero, 17 },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kConstInt, 1 },
  /* 12 */ { OpCode::kPrim, PrimCode::kSub },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kAccessVar, 1 }, // Call Odd
  /* 15 */ { OpCode::kAccessRecursiveBinding, 1 },
  /* 16 */ { OpCode::kTailCall },
  /* 17 */ { OpCode::kConstInt, 1 },
  /* 18 */ { OpCode::kReturn },

  /* Odd */
  /* 19 */ { OpCode::kAccessVar, 0 },
  /* 20 */ { OpCode::kJumpZero, 28 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kConstInt, 1 },
  /* 23 */ { OpCode::kPrim, PrimCode::kSub },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kAccessVar, 1 }, // Call Even
  /* 26 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 27 */ { OpCode::kTailCall },
  /* 28 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, RecursiveBinding4) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, {8, 1, 19, 1} },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 44 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kAccessVar, 0 },
  /*  5 */ { OpCode::kAccessRecursiveBinding, 1 }, // Call Odd
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kExit },

  /* Even */
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kJumpZero, 17 },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kConstInt, 1 },
  /* 12 */ { OpCode::kPrim, PrimCode::kSub },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kAccessVar, 1 }, // Call Odd
  /* 15 */ { OpCode::kAccessRecursiveBinding, 1 },
  /* 16 */ { OpCode::kTailCall },
  /* 17 */ { OpCode::kConstInt, 1 },
  /* 18 */ { OpCode::kReturn },

  /* Odd */
  /* 19 */ { OpCode::kAccessVar, 0 },
  /* 20 */ { OpCode::kJumpZero, 28 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kConstInt, 1 },
  /* 23 */ { OpCode::kPrim, PrimCode::kSub },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kAccessVar, 1 }, // Call Even
  /* 26 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 27 */ { OpCode::kTailCall },
  /* 28 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(0)));
}

TEST(MachineTest, RecursiveBinding5) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, {8, 1, 19, 1} },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 55 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kAccessVar, 0 },
  /*  5 */ { OpCode::kAccessRecursiveBinding, 1 }, // Call Odd
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kExit },

  /* Even */
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kJumpZero, 17 },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kConstInt, 1 },
  /* 12 */ { OpCode::kPrim, PrimCode::kSub },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kAccessVar, 1 }, // Call Odd
  /* 15 */ { OpCode::kAccessRecursiveBinding, 1 },
  /* 16 */ { OpCode::kTailCall },
  /* 17 */ { OpCode::kConstInt, 1 },
  /* 18 */ { OpCode::kReturn },

  /* Odd */
  /* 19 */ { OpCode::kAccessVar, 0 },
  /* 20 */ { OpCode::kJumpZero, 28 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kConstInt, 1 },
  /* 23 */ { OpCode::kPrim, PrimCode::kSub },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kAccessVar, 1 }, // Call Even
  /* 26 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 27 */ { OpCode::kTailCall },
  /* 28 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, RecursiveBinding6) {
  Program program = {
  /*  0 */ { OpCode::kMakeRecursiveBinding, {8, 1, 19, 1, 29, 1, 35, 1} },
  /*  1 */ { OpCode::kLet },
  /*  2 */ { OpCode::kConstInt, 55 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kAccessVar, 0 },
  /*  5 */ { OpCode::kAccessRecursiveBinding, 1 }, // Call Odd
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kExit },

  /* Even */
  /*  8 */ { OpCode::kAccessVar, 0 },
  /*  9 */ { OpCode::kJumpZero, 17 },
  /* 10 */ { OpCode::kPush },
  /* 11 */ { OpCode::kConstInt, 1 },
  /* 12 */ { OpCode::kPrim, PrimCode::kSub },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kAccessVar, 1 }, // Call Odd
  /* 15 */ { OpCode::kAccessRecursiveBinding, 1 },
  /* 16 */ { OpCode::kTailCall },
  /* 17 */ { OpCode::kConstInt, 1 },
  /* 18 */ { OpCode::kReturn },

  /* Odd */
  /* 19 */ { OpCode::kAccessVar, 0 },
  /* 20 */ { OpCode::kJumpZero, 28 },
  /* 21 */ { OpCode::kPush },
  /* 22 */ { OpCode::kConstInt, 1 },
  /* 23 */ { OpCode::kPrim, PrimCode::kSub },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kAccessVar, 1 }, // Call Wrapper1
  /* 26 */ { OpCode::kAccessRecursiveBinding, 2 },
  /* 27 */ { OpCode::kTailCall },
  /* 28 */ { OpCode::kReturn },

  /* Wrapper1 */
  /* 29 */ { OpCode::kAccessVar, 0 },
  /* 30 */ { OpCode::kPush },
  /* 31 */ { OpCode::kAccessVar, 1 }, // Call Wrapper2
  /* 32 */ { OpCode::kAccessRecursiveBinding, 3 },
  /* 33 */ { OpCode::kTailCall },
  /* 34 */ { OpCode::kReturn },

  /* Wrapper2 */
  /* 36 */ { OpCode::kAccessVar, 0 },
  /* 37 */ { OpCode::kPush },
  /* 38 */ { OpCode::kAccessVar, 1 }, // Call Even
  /* 39 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 40 */ { OpCode::kTailCall },
  /* 41 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, RecursiveBinding7) {
  Program program = {
  /*  0 */ { OpCode::kConstInt, 1756 },
  /*  1 */ { OpCode::kPush },
  /*  2 */ { OpCode::kConstInt, 0 },
  /*  3 */ { OpCode::kPush },
  /*  4 */ { OpCode::kMakeClosure, 8, 1 },
  /*  5 */ { OpCode::kCall },
  /*  6 */ { OpCode::kCall },
  /*  7 */ { OpCode::kExit },

  /*  8 */ { OpCode::kMakeRecursiveBinding, {11, 1, 22, 1} },
  /*  9 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 10 */ { OpCode::kReturn },

  /* Even */
  /* 11 */ { OpCode::kAccessVar, 0 },
  /* 12 */ { OpCode::kJumpZero, 20 },
  /* 13 */ { OpCode::kPush },
  /* 14 */ { OpCode::kConstInt, 1 },
  /* 15 */ { OpCode::kPrim, PrimCode::kSub },
  /* 16 */ { OpCode::kPush },
  /* 17 */ { OpCode::kAccessVar, 1 }, // Call Odd
  /* 18 */ { OpCode::kAccessRecursiveBinding, 1 },
  /* 19 */ { OpCode::kTailCall },
  /* 20 */ { OpCode::kConstInt, 1 },
  /* 21 */ { OpCode::kReturn },

  /* Odd */
  /* 22 */ { OpCode::kAccessVar, 0 },
  /* 23 */ { OpCode::kJumpZero, 31 },
  /* 24 */ { OpCode::kPush },
  /* 25 */ { OpCode::kConstInt, 1 },
  /* 26 */ { OpCode::kPrim, PrimCode::kSub },
  /* 27 */ { OpCode::kPush },
  /* 28 */ { OpCode::kAccessVar, 1 }, // Call Even
  /* 29 */ { OpCode::kAccessRecursiveBinding, 0 },
  /* 30 */ { OpCode::kTailCall },
  /* 31 */ { OpCode::kReturn },
  };
  ASSERT_EQ(hvm::Run(program), Result(Value(1)));
}

TEST(MachineTest, ExitWith1) {
  Program program = {
    { OpCode::kConstInt, 44 },
    { OpCode::kExitWith },
    { OpCode::kExit }
  };
  ASSERT_EQ(hvm::Run(program), Result(44));
}

} // namespace hvm