import 'dart:typed_data';

class Registers {
  static int R_R0 = 0;
  static int R_R1 = 1;
  static int R_R2 = 2;
  static int R_R3 = 3;
  static int R_R4 = 4;
  static int R_R5 = 5;
  static int R_R6 = 6;
  static int R_R7 = 7;
  static int R_PC = 8;
  static int R_COND = 9;
  static int R_COUNT = 10;
}

class OpCodes {
  static int OP_BR = 0;
  static int OP_ADD = 1;
  static int OP_LD = 2;
  static int OP_ST = 3;
  static int OP_JSR = 4;
  static int OP_AND = 5;
  static int OP_LDR = 6;
  static int OP_STR = 7;
  static int OP_RTI = 8;
  static int OP_NOT = 9;
  static int OP_LDI = 10;
  static int OP_STI = 11;
  static int OP_JMP = 12;
  static int OP_RES = 13;
  static int OP_LEA = 14;
  static int OP_TRAP = 15;
}

class Conditionals {
  static int FL_POS = 1 << 0; /* P */
  static int FL_ZRO = 1 << 1; /* Z */
  static int FL_NEG = 1 << 2; /* N */
}

class Lc3DartVm {
  // Use 2^16 here to avoid using dart numerics package.
  Int16List memory = Int16List(2 ^ 16);
  Int16List registers = Int16List(Registers.R_COUNT);

  void loadProgram(String programPath) {}
}

void main(List<String> arguments) {}
