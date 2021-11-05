import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:dart_console/dart_console.dart';
import 'package:lc3_dart_vm/lc3_dart_assembler.dart' show Lc3DartAssembler;

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
  static int POS = 1 << 0;
  static int ZERO = 1 << 1;
  static int NEG = 1 << 2;
}

class Traps {
  static const int GETC = 32;
  static const int OUT = 33;
  static const int PUTS = 34;
  static const int IN = 35;
  static const int PUTSP = 36;
  static const int HALT = 37;
}

class MemoryRegisters {
  static const int MR_KBSR = 0xFE00; /* keyboard status */
  static const int MR_KBDR = 0xFE02; /* keyboard data */
}

class Lc3DartVm {
  // Use 2^16 here to avoid using dart numerics package.
  Uint16List memory = Uint16List(pow(2, 16).toInt());
  Uint16List registers = Uint16List(Registers.COUNT);
  bool running = true;
  Console console = Console();

  Lc3DartVm() {
    console.rawMode = true;
  }

  Future<void> start(String path) async {
    await loadProgram(path);
    while (running) {
      var instruction = readMem(registers[Registers.PC]++);
      await processInstruction(instruction);
    }
  }

  Future<void> loadProgram(String programPath) async {
    try {
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
    } on FileSystemException {
      print('Could not locate file: $programPath, exiting.');
      console.rawMode = false;
      exit(1);
    }
  }

  Future<void> processInstruction(int instruction) async {
    var op = instruction >> 12;
    switch (op) {
      case OpCodes.BR:
        br(instruction);
        break;
      case OpCodes.ADD:
        add(instruction);
        break;
      case OpCodes.LD:
        ld(instruction);
        break;
      case OpCodes.ST:
        st(instruction);
        break;
      case OpCodes.JSR:
        jsr(instruction);
        break;
      case OpCodes.AND:
        and(instruction);
        break;
      case OpCodes.LDR:
        ldr(instruction);
        break;
      case OpCodes.STR:
        str(instruction);
        break;
      case OpCodes.RTI:
        throw Exception('Unimplemented opcode RTI encountered.');
      case OpCodes.NOT:
        not(instruction);
        break;
      case OpCodes.LDI:
        ldi(instruction);
        break;
      case OpCodes.STI:
        sti(instruction);
        break;
      case OpCodes.JMP:
        jmp(instruction);
        break;
      case OpCodes.RES:
        throw Exception('Unimplemented opcode RES encountered.');
      case OpCodes.LEA:
        lea(instruction);
        break;
      case OpCodes.TRAP:
        await trap(instruction);
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

    updateFlags(destReg);
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

    updateFlags(destReg);
  }

  void not(int inst) {
    var destReg = (inst >> 9) & 7;
    var sourceReg = (inst >> 6) & 7;
    registers[destReg] = ~registers[sourceReg];
    updateFlags(destReg);
  }

  void ld(int inst) {
    var destReg = (inst >> 9) & 7;
    var offset9 = inst & 511;
    registers[destReg] =
        readMem(signExtend(offset9, 9) + registers[Registers.PC]);
    updateFlags(destReg);
  }

  void ldi(int inst) {
    var destReg = (inst >> 9) & 7;
    var offset9 = inst & 511;
    registers[destReg] =
        readMem(readMem(signExtend(offset9, 9) + registers[Registers.PC]));
    updateFlags(destReg);
  }

  void lea(int inst) {
    var destReg = (inst >> 9) & 7;
    var offset9 = inst & 511;
    registers[destReg] = registers[Registers.PC] + signExtend(offset9, 9);
    updateFlags(destReg);
  }

  void ldr(int inst) {
    var destReg = (inst >> 9) & 7;
    var baseReg = (inst >> 6) & 7;
    var offset6 = signExtend(inst & 63, 6);
    var address = registers[baseReg] + offset6;
    registers[destReg] = readMem(address);
    updateFlags(destReg);
  }

  void st(int inst) {
    var sourceReg = (inst >> 9) & 7;
    var address = signExtend(inst & 511, 9) + registers[Registers.PC];
    writeMem(address, registers[sourceReg]);
  }

  void str(int inst) {
    var sourceReg = (inst >> 9) & 7;
    var baseReg = (inst >> 6) & 7;
    var offset6 = signExtend(inst & 63, 6);
    var address = registers[baseReg] + offset6;
    writeMem(address, registers[sourceReg]);
  }

  void sti(int inst) {
    var sourceReg = (inst >> 9) & 7;
    var offset9 = signExtend(inst & 511, 9) + registers[Registers.PC];
    var address = readMem(offset9);
    writeMem(address, registers[sourceReg]);
  }

  void jsr(int inst) {
    registers[Registers.R7] = registers[Registers.PC];
    var useReg = (inst >> 11) & 1 == 0;
    if (useReg) {
      var reg = (inst >> 6) & 7;
      registers[Registers.PC] = registers[reg];
    } else {
      var address = signExtend(inst & 2047, 11) + registers[Registers.PC];
      registers[Registers.PC] = address;
    }
  }

  void jmp(int inst) {
    var baseReg = (inst >> 6) & 7;
    var address = registers[baseReg];
    registers[Registers.PC] = address;
  }

  void br(int inst) {
    var n = (inst >> 11) & 1 == 1;
    var z = (inst >> 10) & 1 == 1;
    var p = (inst >> 9) & 1 == 1;
    var shouldBranch = false;
    shouldBranch |= n & (registers[Registers.COND] == Conditionals.NEG);
    shouldBranch |= z & (registers[Registers.COND] == Conditionals.ZERO);
    shouldBranch |= p & (registers[Registers.COND] == Conditionals.POS);
    if (shouldBranch) {
      var address = signExtend(inst & 511, 9) + registers[Registers.PC];
      registers[Registers.PC] = address;
    }
  }

  Future<void> trap(int inst) async {
    var trapCode = signExtend(inst & 255, 8);
    switch (trapCode) {
      case Traps.GETC:
        registers[Registers.R0] = getKey();
        break;
      case Traps.OUT:
        var char = String.fromCharCode(registers[Registers.R0]);
        stdout.write(char);
        await stdout.flush();
        break;
      case Traps.PUTSP:
        var start = registers[Registers.R0];
        var char = readMem(start);
        while (char != 0) {
          var c1 = char >> 8;
          var c2 = char & 255;
          stdout.write(String.fromCharCode(c1));
          stdout.write(String.fromCharCode(c2));
          start++;
          char = readMem(start);
        }
        await stdout.flush();
        break;
      case Traps.PUTS:
        var start = registers[Registers.R0];
        var char = readMem(start);
        while (char != 0) {
          stdout.write(String.fromCharCode(char));
          start++;
          char = readMem(start);
          await stdout.flush();
        }
        await stdout.flush();
        break;
      case Traps.IN:
        stdout.write('Enter a character: ');
        var char = getKey();
        stdout.write(String.fromCharCode(char));
        await stdout.flush();
        registers[Registers.R0] = char;
        break;
      case Traps.HALT:
        running = false;
    }
  }

  void updateFlags(int reg) {
    if (registers[reg] == 0) {
      registers[Registers.COND] = Conditionals.ZERO;
    } else if (registers[reg] >> 15 == 1) {
      registers[Registers.COND] = Conditionals.NEG;
    } else {
      registers[Registers.COND] = Conditionals.POS;
    }
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

  void writeMem(int address, int value) {
    memory[address] = value;
  }

  int readMem(int address) {
    if (address == MemoryRegisters.MR_KBSR) {
      var codeUnit = stdin.readByteSync();
      if (codeUnit > 0) {
        memory[MemoryRegisters.MR_KBSR] = (1 << 15);
        memory[MemoryRegisters.MR_KBDR] = codeUnit;
      } else {
        memory[MemoryRegisters.MR_KBSR] = 0;
      }
    }
    return memory[address];
  }

  int getKey() {
    var codeUnit = 0;
    while (codeUnit <= 0) {
      codeUnit = stdin.readByteSync();
    }
    return codeUnit;
  }
}

void printBin(int num) {
  var str = BigInt.from(num).toUnsigned(16).toRadixString(2);
  str = '0' * (16 - str.length) + str;
  print(str);
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
