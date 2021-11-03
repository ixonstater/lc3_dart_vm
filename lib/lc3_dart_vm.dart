import 'dart:math';
import 'dart:typed_data';
import 'dart:io';

import 'package:lc3_dart_vm/lc3_dart_assembler.dart';

class Registers {
  static const int R0 = 0;
  static const int R1 = 1;
  static const int R2 = 2;
  static const int R3 = 3;
  static const int R4 = 4;
  static const int R5 = 5;
  static const int R6 = 6;
  static const int R7 = 7;
  static const int PC = 8;
  static const int COND = 9;
  static const int COUNT = 10;
}

class OpCodes {
  static const int BR = 0;
  static const int ADD = 1;
  static const int LD = 2;
  static const int ST = 3;
  static const int JSR = 4;
  static const int AND = 5;
  static const int LDR = 6;
  static const int STR = 7;
  static const int RTI = 8;
  static const int NOT = 9;
  static const int LDI = 10;
  static const int STI = 11;
  static const int JMP = 12;
  static const int RES = 13;
  static const int LEA = 14;
  static const int TRAP = 15;
}

class Conditionals {
  static int POS = 1 << 0; /* P */
  static int ZERO = 1 << 1; /* Z */
  static int NEG = 1 << 2; /* N */
}

class Lc3DartVm {
  // Use 2^16 here to avoid using dart numerics package.
  Uint16List memory = Uint16List(pow(2, 16).toInt());
  Uint16List registers = Uint16List(Registers.COUNT);
  int condition = Conditionals.ZERO;
  bool running = true;

  Future<void> start(String path) async {
    // await loadProgram(path);
    await assembleOnTheFly(path, this);
    while (running) {
      var instruction = readMem(registers[Registers.PC]++);
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
        registers[Registers.PC] = pc;
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
      case OpCodes.BR:
        break;
      case OpCodes.ADD:
        add(instruction);
        break;
      case OpCodes.LD:
        break;
      case OpCodes.ST:
        break;
      case OpCodes.JSR:
        break;
      case OpCodes.AND:
        and(instruction);
        break;
      case OpCodes.LDR:
        break;
      case OpCodes.STR:
        break;
      case OpCodes.RTI:
        break;
      case OpCodes.NOT:
        not(instruction);
        break;
      case OpCodes.LDI:
        break;
      case OpCodes.STI:
        break;
      case OpCodes.JMP:
        break;
      case OpCodes.RES:
        break;
      case OpCodes.LEA:
        break;
      case OpCodes.TRAP:
        break;
    }
  }

  void add(int inst) {
    var destReg = (inst >> 9) & 7;
    var sourceReg = (inst >> 6) & 7;
    var immediateFlag = (inst >> 5) & 1;
    if (immediateFlag == 1) {
      var immediate = signExtend(inst & 31, 5);
      registers[destReg] = registers[sourceReg] + immediate;
    } else {
      var sourceTwoReg = inst & 7;
      registers[destReg] = registers[sourceReg] + registers[sourceTwoReg];
    }
  }

  void and(int inst) {
    var destReg = (inst >> 9) & 7;
    var sourceReg = (inst >> 6) & 7;
    var immediateFlag = (inst >> 5) & 1;
    if (immediateFlag == 1) {
      var immediate = signExtend(inst & 31, 5);
      registers[destReg] = registers[sourceReg] & immediate;
    } else {
      var sourceTwoReg = inst & 7;
      registers[destReg] = registers[sourceReg] & registers[sourceTwoReg];
    }
  }

  void not(int inst) {
    var destReg = (inst >> 9) & 7;
    var sourceReg = (inst >> 6) & 7;
    registers[destReg] = ~registers[sourceReg];
  }

  int signExtend(int number, int bitCount) {
    // Truncate number to low 16 bits,
    // this gets around needing to use
    // actual 16 bit ints which are only
    // partially implemented in dart.
    number = number & 0xFFFF;
    var highBitSet = (number >> (bitCount - 1)) & 1 == 1;
    if (highBitSet) {
      number = number | (0xFFFF << bitCount);
    }
    return number.toSigned(16);
  }

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
      vm.registers[Registers.PC] = pc;
    } else {
      vm.memory[pc] = instruction;
      pc++;
    }
    offset++;
  }
}
