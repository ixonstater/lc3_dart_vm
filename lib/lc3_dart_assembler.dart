import 'dart:convert';
import 'dart:io';

import 'dart:math';

class Macros {
  static const String STRINGZ = '.STRINGZ';
  static const String ORIG = '.ORIG';
  static const String END = '.END';
}

class OpCodes {
  static const String ADD = 'ADD';
  static const String AND = 'AND';
  static const String NOT = 'NOT';
  static const String BR = 'BR';
  static const String JMP = 'JMP';
  static const String JSR = 'JSR';
  static const String LD = 'LD';
  static const String LDI = 'LDI';
  static const String LDR = 'LDR';
  static const String LEA = 'LEA';
  static const String RET = 'RET';
  static const String RTI = 'RTI';
  static const String ST = 'ST';
  static const String STI = 'STI';
  static const String STR = 'STR';
  static const String TRAP = 'TRAP';

  static final int ADDb = 1 << 12;
  static final int ANDb = 5 << 12;
  static final int NOTb = 9 << 12;
  static final int BRb = 0 << 12;
  static final int JMPb = 12 << 12;
  static final int JSRb = 4 << 12;
  static final int LDb = 2 << 12;
  static final int LDIb = 10 << 12;
  static final int LDRb = 6 << 12;
  static final int LEAb = 15 << 12;
  static final int RETb = 12 << 12;
  static final int RTIb = 8 << 12;
  static final int STb = 3 << 12;
  static final int STIb = 11 << 12;
  static final int STRb = 7 << 12;
  static final int TRAPb = 16 << 12;

  static int toBinary(String opCode) {
    opCode = opCode.toUpperCase();
    switch (opCode) {
      case OpCodes.ADD:
        return OpCodes.ADDb;
      case OpCodes.AND:
        return OpCodes.ANDb;
      case OpCodes.NOT:
        return OpCodes.NOTb;
      case OpCodes.BR:
        return OpCodes.BRb;
      case OpCodes.JMP:
        return OpCodes.JMPb;
      case OpCodes.JSR:
        return OpCodes.JSRb;
      case OpCodes.LD:
        return OpCodes.LDb;
      case OpCodes.LDI:
        return OpCodes.LDIb;
      case OpCodes.LDR:
        return OpCodes.LDRb;
      case OpCodes.LEA:
        return OpCodes.LEAb;
      case OpCodes.RET:
        return OpCodes.RETb;
      case OpCodes.RTI:
        return OpCodes.RTIb;
      case OpCodes.ST:
        return OpCodes.STb;
      case OpCodes.STI:
        return OpCodes.STIb;
      case OpCodes.STR:
        return OpCodes.STRb;
      case OpCodes.TRAP:
        return OpCodes.TRAPb;
      default:
        return -1;
    }
  }
}

class Registers {
  static const String R0 = 'R0';
  static const String R1 = 'R1';
  static const String R2 = 'R2';
  static const String R3 = 'R3';
  static const String R4 = 'R4';
  static const String R5 = 'R5';
  static const String R6 = 'R6';
  static const String R7 = 'R7';

  static const int R0b = 0;
  static const int R1b = 1;
  static const int R2b = 2;
  static const int R3b = 3;
  static const int R4b = 4;
  static const int R5b = 5;
  static const int R6b = 6;
  static const int R7b = 7;
  static const int ERROR = -1;

  static int toBinary(String register, int lShift) {
    register = register.toUpperCase();
    switch (register) {
      case Registers.R0:
        return Registers.R0b << lShift;
      case Registers.R1:
        return Registers.R1b << lShift;
      case Registers.R2:
        return Registers.R2b << lShift;
      case Registers.R3:
        return Registers.R3b << lShift;
      case Registers.R4:
        return Registers.R4b << lShift;
      case Registers.R5:
        return Registers.R5b << lShift;
      case Registers.R6:
        return Registers.R6b << lShift;
      case Registers.R7:
        return Registers.R7b << lShift;
      default:
        return Registers.ERROR;
    }
  }
}

class Lc3DartAssembler {
  List<int> bCommands = [];
  List<String> commands = [];
  int currentLine = 1;

  void assemble(String path) {
    File(path).openRead().map(utf8.decode).transform(LineSplitter()).forEach(
      (line) {
        line = removeCommentFromLine(line);
        if (line.isNotEmpty) {
          commands = line.split(RegExp('[ \t]+'));
          routeOpCode();
        }

        currentLine++;
      },
    );

    writeBinaryFile(path);
  }

  void writeBinaryFile(String path) {}

  String removeCommentFromLine(String line) {
    var hasSemi = line.indexOf(';');
    if (hasSemi != -1) {
      return line.substring(0, hasSemi);
    } else {
      return line;
    }
  }

  void routeOpCode() {
    if (commands.isEmpty) {
      return;
    }
    switch (commands[0].toUpperCase()) {
      case OpCodes.ADD:
        writeAddOrAnd();
        break;
      case OpCodes.AND:
        writeAddOrAnd();
        break;
      case OpCodes.NOT:
        writeNot();
        break;
      case OpCodes.BR:
        break;
      case OpCodes.JMP:
        break;
      case OpCodes.JSR:
        break;
      case OpCodes.LD:
        break;
      case OpCodes.LDI:
        break;
      case OpCodes.LDR:
        break;
      case OpCodes.LEA:
        break;
      case OpCodes.RET:
        break;
      case OpCodes.RTI:
        break;
      case OpCodes.ST:
        break;
      case OpCodes.STI:
        break;
      case OpCodes.STR:
        break;
      case OpCodes.TRAP:
        break;
      case Macros.END:
        break;
      case Macros.ORIG:
        break;
      case Macros.STRINGZ:
        break;
      default:
        throw Exception(
          'Invalid instruction ${commands[0]} at line $currentLine.',
        );
    }
  }

  void writeAddOrAnd() {
    if (commands.length != 4) {
      throw Exception(
        '${commands[0]} opcode requires exactly three arguments at line: $currentLine.',
      );
    }
    var baseCommand = OpCodes.toBinary(commands[0]);
    var destination = Registers.toBinary(commands[1], 9);
    if (destination == Registers.ERROR) {
      throw Exception(
        'Invalid destination register ${commands[1]} on line $currentLine.',
      );
    }
    var sourceOne = Registers.toBinary(commands[2], 6);
    if (sourceOne == Registers.ERROR) {
      throw Exception(
        'Invalid source one register ${commands[2]} on line $currentLine.',
      );
    }

    var parsedImmediate = int.tryParse(commands[3]);
    var sourceTwo;
    var immediateFlag;
    if (parsedImmediate != null) {
      var immediateLimit = pow(2, 5) - 1;
      if (parsedImmediate > (immediateLimit)) {
        throw Exception(
          'Integers greater than $immediateLimit (5 bits) cannot be used as immediate values on line $currentLine.',
        );
      } else {
        immediateFlag = 1 << 5;
        sourceTwo = parsedImmediate;
      }
    } else {
      immediateFlag = 0;
      sourceTwo = Registers.toBinary(commands[3], 0);
      if (sourceTwo == Registers.ERROR) {
        throw Exception(
          'Invalid source two register ${commands[3]} on line $currentLine.',
        );
      }
    }

    var finalCommand =
        baseCommand | destination | sourceOne | immediateFlag | sourceTwo;
    bCommands.add(finalCommand);
  }

  void writeNot() {
    if (commands.length != 3) {
      throw Exception(
        '${commands[0]} opcode requires exactly three arguments at line: $currentLine.',
      );
    }
    var baseCommand = OpCodes.toBinary(commands[0]);
    var destination = Registers.toBinary(commands[1], 9);
    if (destination == Registers.ERROR) {
      throw Exception(
        'Invalid destination register ${commands[1]} on line $currentLine.',
      );
    }
    var source = Registers.toBinary(commands[2], 6);
    if (source == Registers.ERROR) {
      throw Exception(
        'Invalid source register ${commands[2]} on line $currentLine.',
      );
    }
    var paddedOnes = 63;

    var finalCommand = baseCommand | destination | source | paddedOnes;
    bCommands.add(finalCommand);
  }
}
