import 'dart:math';
import 'dart:typed_data';
import 'dart:io';

import 'package:lc3_dart_vm/lc3_dart_assembler.dart';

class Registers {
  static const int R_R0 = 0;
  static const int R_R1 = 1;
  static const int R_R2 = 2;
  static const int R_R3 = 3;
  static const int R_R4 = 4;
  static const int R_R5 = 5;
  static const int R_R6 = 6;
  static const int R_R7 = 7;
  static const int R_PC = 8;
  static const int R_COND = 9;
  static const int R_COUNT = 10;
}

class OpCodes {
  static const int OP_BR = 0;
  static const int OP_ADD = 1;
  static const int OP_LD = 2;
  static const int OP_ST = 3;
  static const int OP_JSR = 4;
  static const int OP_AND = 5;
  static const int OP_LDR = 6;
  static const int OP_STR = 7;
  static const int OP_RTI = 8;
  static const int OP_NOT = 9;
  static const int OP_LDI = 10;
  static const int OP_STI = 11;
  static const int OP_JMP = 12;
  static const int OP_RES = 13;
  static const int OP_LEA = 14;
  static const int OP_TRAP = 15;
}

class Conditionals {
  static int FL_POS = 1 << 0; /* P */
  static int FL_ZERO = 1 << 1; /* Z */
  static int FL_NEG = 1 << 2; /* N */
}

class Lc3DartVm {
  // Use 2^16 here to avoid using dart numerics package.
  Int16List memory = Int16List(pow(2, 16).toInt());
  Int16List registers = Int16List(Registers.R_COUNT);
  int condition = Conditionals.FL_ZERO;
  bool running = true;

  Future<void> start(String path) async {
    // await loadProgram(path);
    await assembleOnTheFly(path, this);
    while (running) {
      var instruction = readMem(registers[Registers.R_PC]++);
      processInstruction(instruction);
    }
  }

  Future<void> loadProgram(String programPath) async {
    var file = File(programPath);
    var contents = await file.readAsBytes();
    var offset = 0;
    int? pc;
    while (offset < contents.length) {
      var instruction = contents[offset] << 8 | contents[offset + 1];
      if (pc == null) {
        pc = instruction;
        registers[Registers.R_PC] = pc;
      } else {
        memory[pc] = instruction;
        pc++;
      }
      offset += 2;
    }
  }

  void processInstruction(int instruction) {
    var op = instruction >> 12;
    switch (op) {
      case OpCodes.OP_BR:
        break;
      case OpCodes.OP_ADD:
        add(instruction);
        break;
      case OpCodes.OP_LD:
        break;
      case OpCodes.OP_ST:
        break;
      case OpCodes.OP_JSR:
        break;
      case OpCodes.OP_AND:
        break;
      case OpCodes.OP_LDR:
        break;
      case OpCodes.OP_STR:
        break;
      case OpCodes.OP_RTI:
        break;
      case OpCodes.OP_NOT:
        break;
      case OpCodes.OP_LDI:
        break;
      case OpCodes.OP_STI:
        break;
      case OpCodes.OP_JMP:
        break;
      case OpCodes.OP_RES:
        break;
      case OpCodes.OP_LEA:
        break;
      case OpCodes.OP_TRAP:
        break;
    }
  }

  void add(int instruction) {}

  int readMem(int address) {
    return memory[address];
  }
}

void printBin(int num) {
  print(BigInt.from(num).toUnsigned(16).toRadixString(2));
}

Future<void> assembleOnTheFly(String path, Lc3DartVm vm) async {
  var obj = Lc3DartAssembler();
  await obj.assemble(path);
  var contents = Uint16List.fromList(obj.bCommands);
  var offset = 0;
  int? pc;
  while (offset < contents.length) {
    var instruction = contents[offset];
    if (pc == null) {
      pc = instruction;
      vm.registers[Registers.R_PC] = pc;
    } else {
      vm.memory[pc] = instruction;
      pc++;
    }
    offset++;
  }
}
