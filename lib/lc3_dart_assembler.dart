import 'dart:convert';
import 'dart:io';

import 'dart:math';

class Macros {
  static const String STRINGZ = '.STRINGZ';
  static const String BLKW = '.BLKW';
  static const String ORIG = '.ORIG';
  static const String END = '.END';
  static const String FILL = '.FILL';

  static bool isMacro(String macro) {
    macro = macro.toUpperCase();
    return macro == Macros.STRINGZ ||
        macro == Macros.ORIG ||
        macro == Macros.END ||
        macro == Macros.FILL ||
        macro == Macros.BLKW;
  }
}

class OpCodes {
  static const String ADD = 'ADD';
  static const String AND = 'AND';
  static const String NOT = 'NOT';
  static const String BRN = 'BRN';
  static const String BRP = 'BRP';
  static const String BRZ = 'BRZ';
  static const String BRNP = 'BRNP';
  static const String BRNZ = 'BRNZ';
  static const String BRPZ = 'BRPZ';
  static const String BRNZP = 'BRNZP';
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
      case OpCodes.BRZ:
        return OpCodes.BRb;
      case OpCodes.BRN:
        return OpCodes.BRb;
      case OpCodes.BRP:
        return OpCodes.BRb;
      case OpCodes.BRNP:
        return OpCodes.BRb;
      case OpCodes.BRNZ:
        return OpCodes.BRb;
      case OpCodes.BRPZ:
        return OpCodes.BRb;
      case OpCodes.BRNZP:
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
        return OpCodes.JMPb;
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

class Traps {
  static const String GETC = 'GETC';
  static const String OUT = 'OUT';
  static const String PUTS = 'PUTS';
  static const String IN = 'IN';
  static const String HALT = 'HALT';

  static bool isTrap(String str) {
    str = str.toUpperCase();
    return str == Traps.GETC ||
        str == Traps.OUT ||
        str == Traps.PUTS ||
        str == Traps.IN ||
        str == Traps.HALT;
  }
}

class Lc3DartAssembler {
  List<int> bCommands = [];
  List<String> commands = [];
  int currentLine = 1;
  int memoryOffset = 0;
  Lc3DartSymbols symbols = Lc3DartSymbols();

  void assemble(String path) async {
    await symbols.markSymbols(path);
    symbols.writeSymbolsFile();
    await processOpCodes(path);
    await writeBinaryFile(path);
  }

  Future<void> writeBinaryFile(String path) async {}

  Future<void> processOpCodes(String path) async {
    currentLine = 1;
    await File(path)
        .openRead()
        .map(utf8.decode)
        .transform(LineSplitter())
        .forEach(
      (line) {
        line = preprocessLine(line);
        if (line.isNotEmpty) {
          commands = line.split(RegExp('[ \t]+'));
          routeLineStart(line);
          currentLine++;
        }
      },
    );
  }

  void routeLineStart(String line) {
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
      case OpCodes.JMP:
        writeJmpAndRet();
        break;
      case OpCodes.RET:
        writeJmpAndRet();
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
      case OpCodes.RTI:
        break;
      case OpCodes.ST:
        break;
      case OpCodes.STI:
        break;
      case OpCodes.STR:
        break;
      case OpCodes.BRZ:
        break;
      case OpCodes.BRN:
        break;
      case OpCodes.BRP:
        break;
      case OpCodes.BRNP:
        break;
      case OpCodes.BRNZ:
        break;
      case OpCodes.BRPZ:
        break;
      case OpCodes.BRNZP:
        break;
      case OpCodes.TRAP:
        break;
      case Traps.GETC:
        break;
      case Traps.HALT:
        break;
      case Traps.IN:
        break;
      case Traps.OUT:
        break;
      case Traps.PUTS:
        break;
      case Macros.END:
        break;
      case Macros.ORIG:
        break;
      case Macros.STRINGZ:
        break;
      case Macros.BLKW:
        break;
      case Macros.FILL:
        break;
      default:
        if (!symbols.symbols.containsKey(commands[0])) {
          throw Exception(
            'Invalid instruction ${commands[0]} at line $currentLine.',
          );
        } else {
          // TODO: Implement symbol writing.
        }
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

  void writeJmpAndRet() {
    var baseCommand = OpCodes.JMPb;
    int register;
    if (commands.length <= 1) {
      register = Registers.toBinary(Registers.R7, 6);
    } else {
      register = Registers.toBinary(commands[1], 6);
      if (register == -1) {
        throw Exception(
          'Invalid source register ${commands[1]} on line $currentLine.',
        );
      }
    }

    var finalCommand = baseCommand | register;
    print(finalCommand.toRadixString(2));
    bCommands.add(finalCommand);
  }

  void writeBr(bool n, bool z, bool p) {
    if (commands.length != 3) {
      throw Exception(
        '${commands[0]} opcode requires exactly three arguments at line: $currentLine.',
      );
    }
  }
}

class Lc3DartSymbols {
  Map<String, int> symbols = {};
  int origin = 0x3000;
  int memoryOffset = 0;
  int currentLine = 1;

  final int minimumMemorySpace = 12288;
  final int maximumMemorySpace = 65023;

  void writeSymbolsFile() {
    var outFile = File('./program.sym').openWrite();
    outFile.writeln('//Symbol table');
    outFile.writeln('//     Symbol Name              Page Address');
    outFile.writeln('//     -----------              ------------');
    symbols.forEach((key, value) {
      var symbolName = '//     ' + key;
      var spaces = 26 - key.length > 0 ? 26 - key.length : 1;
      var pageAddress = ''.padRight(spaces, ' ') +
          value.toRadixString(16) +
          ': ' +
          (value - origin).toRadixString(10);

      outFile.writeln(symbolName + pageAddress);
    });
    outFile.done;
    outFile.close();
  }

  Future<void> markSymbols(String path) async {
    var hasMarkedOrigin = false;
    await File(path)
        .openRead()
        .map(utf8.decode)
        .transform(LineSplitter())
        .forEach(
      (line) {
        line = preprocessLine(line);
        if (line.isNotEmpty) {
          if (!hasMarkedOrigin) {
            markOrigin(line);
            hasMarkedOrigin = true;
          } else {
            routeLine(line);
          }
          currentLine++;
          memoryOffset++;
        }
      },
    );
  }

  void routeLine(String line) {
    var spaceCount = RegExp('[ \t]+').allMatches(line).length;
    if (spaceCount == 0) {
      var isOpcode = OpCodes.toBinary(line) != -1;
      var isMacro = Macros.isMacro(line);
      var isTrap = Traps.isTrap(line);
      if (isOpcode || isMacro || isTrap) {
        return;
      } else {
        markStandaloneSymbol(line);
      }
    } else if (spaceCount > 1) {
      var firstWordIndex = line.indexOf(RegExp('[ \t]+'));
      var secondWordIndex = line.indexOf(RegExp('[ \t]+'), firstWordIndex + 1);
      var firstWord = line.substring(0, firstWordIndex);
      var secondWord = line.substring(firstWordIndex + 1, secondWordIndex);
      var isOpcode = OpCodes.toBinary(firstWord) != -1;
      var isMacro = Macros.isMacro(firstWord);
      var isTrap = Traps.isTrap(firstWord);
      if (isOpcode || isMacro || isTrap) {
        return;
      } else if (secondWord.toUpperCase() == Macros.STRINGZ) {
        markStringzSymbol(firstWord, line.substring(secondWordIndex + 1));
      } else if (secondWord.toUpperCase() == Macros.BLKW) {
        markBlkwSymbol(firstWord, line.substring(secondWordIndex + 1));
      } else if (secondWord.toUpperCase() == Macros.FILL) {
        markStandaloneSymbol(firstWord);
      }
    }
  }

  void markOrigin(String line) {
    var commands = line.split(RegExp('[ \t]+'));
    if (commands.length < 2 || commands[0].toUpperCase() != Macros.ORIG) {
      throw Exception(
        'First line of program must be a .ORIG indicating the memory origin.',
      );
    }
    var originParsed = parseInt(commands[1]);
    if (originParsed == null) {
      throw Exception(
        'Unable to parse operand of .ORIG macro on line $currentLine.',
      );
    } else if (originParsed < minimumMemorySpace ||
        originParsed > maximumMemorySpace) {
      throw Exception(
        'LC3 .ORIG must be between 0X3000 and 0XFDFF on line $currentLine.',
      );
    } else {
      origin = originParsed;
    }
  }

  void markStandaloneSymbol(String symbol) {
    if (symbols.containsKey(symbol)) {
      throw Exception(
        'Illegal redefinition of symbol $symbol on line $currentLine.',
      );
    } else {
      symbols[symbol] = origin + memoryOffset;
    }
  }

  void markStringzSymbol(String symbol, String remainingLine) {
    var processedString = processStringLiteral(remainingLine);
    if (processedString == null) {
      throw Exception(
        'Failed to parse string literal on line $currentLine.',
      );
    }

    markStandaloneSymbol(symbol);
    memoryOffset += processedString.length + 1;
  }

  void markBlkwSymbol(String symbol, String remainingLine) {
    var spaceToAllocate = parseInt(remainingLine);
    if (spaceToAllocate == null) {
      throw Exception(
        'Failed to parse operand in .BLKW macro on line $currentLine',
      );
    }

    markStandaloneSymbol(symbol);
    memoryOffset += spaceToAllocate;
  }
}

String? processStringLiteral(String line) {
  if (!(line[0] == '"' && line[line.length - 1] == '"')) {
    return null;
  } else {
    line = line.substring(1, line.length - 1);
  }

  var trimmedString = line
      .replaceAll('\\"', '"')
      .replaceAll('\\r\\n', '\r\n')
      .replaceAll('\\r', '\r')
      .replaceAll('\\n', '\n');

  return trimmedString;
}

String preprocessLine(String line) {
  var hasSemi = line.indexOf(';');
  if (hasSemi != -1) {
    return line.substring(0, hasSemi).trim();
  } else {
    return line.trim();
  }
}

int? parseInt(String num) {
  num = num.toUpperCase();
  if (num.contains('0X') || num.contains('X')) {
    num = num.replaceFirst('0X', '');
    num = num.replaceFirst('X', '');
    return int.tryParse(num, radix: 16);
  } else {
    return int.tryParse(num, radix: 10);
  }
}
