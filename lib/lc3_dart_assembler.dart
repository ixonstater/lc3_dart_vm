import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

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
  static const String BR = 'BR';
  static const String JMP = 'JMP';
  static const String JSR = 'JSR';
  static const String JSRR = 'JSRR';
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
  static final int LEAb = 14 << 12;
  static final int RTIb = 8 << 12;
  static final int STb = 3 << 12;
  static final int STIb = 11 << 12;
  static final int STRb = 7 << 12;
  static final int TRAPb = 15 << 12;

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
      case OpCodes.JSRR:
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

  static int toBinary(String register, int lShift, int lineCount) {
    var switchReg = register.toUpperCase();
    switch (switchReg) {
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
        throw Exception(
            'Invalid register or undefined symbol $register found on line $lineCount.');
    }
  }
}

class Traps {
  static const String GETC = 'GETC';
  static const String OUT = 'OUT';
  static const String PUTS = 'PUTS';
  static const String PUTSP = 'PUTSP';
  static const String IN = 'IN';
  static const String HALT = 'HALT';

  static const int GETCb = 32;
  static const int OUTb = 33;
  static const int PUTSb = 34;
  static const int INb = 35;
  static const int PUTSPb = 36;
  static const int HALTb = 37;

  static int toBinary(String trapCode, int currentLine) {
    switch (trapCode) {
      case Traps.GETC:
        return Traps.GETCb;
      case Traps.OUT:
        return Traps.OUTb;
      case Traps.PUTS:
        return Traps.PUTSb;
      case Traps.IN:
        return Traps.INb;
      case Traps.PUTSP:
        return Traps.PUTSPb;
      case Traps.HALT:
        return Traps.HALTb;
      default:
        throw Exception(
          'Failed to parse trap code found on line $currentLine.',
        );
    }
  }

  static bool isTrap(String str) {
    str = str.toUpperCase();
    return str == Traps.GETC ||
        str == Traps.OUT ||
        str == Traps.PUTS ||
        str == Traps.IN ||
        str == Traps.PUTSP ||
        str == Traps.HALT;
  }
}

class Lc3DartAssembler {
  List<int> bCommands = [];
  List<String> commands = [];
  int currentLine = 1;
  int programCounter = 0;
  Lc3DartSymbols symbols = Lc3DartSymbols();

  Future<void> assemble(String path) async {
    await symbols.markSymbols(path);
    await processOpCodes(path);
    // await writeBinaryFile(path);
    // await symbols.writeSymbolsFile(path);
    // await writeBinRep();
  }

  Future<void> writeBinaryFile(String filePath) async {
    var dirName = path.dirname(filePath);
    var fileName = path.basenameWithoutExtension(filePath) + '.obj';
    var file = File(dirName + '/' + fileName);
    var bCommandsSplit = <int>[];
    bCommands.forEach((element) {
      var topByte = element >> 8;
      bCommandsSplit.add(topByte);
      bCommandsSplit.add(element);
    });
    var bCommands8 = Uint8List.fromList(bCommandsSplit);
    await file.writeAsBytes(bCommands8);
  }

  Future<void> processOpCodes(String path) async {
    currentLine = 1;
    programCounter = symbols.origin;
    bCommands.add(symbols.origin);
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
          programCounter++;
        }
        currentLine++;
      },
    );
  }

  void routeLineStart(String line) {
    if (commands.isEmpty) {
      return;
    }
    // Special case for BR opcode which does not fit in the
    // simple matching logic of the switch case.
    else if (commands[0].toUpperCase().substring(0, 2) == OpCodes.BR) {
      writeBr();
      return;
    } else {
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
          writeJsr();
          break;
        case OpCodes.JSRR:
          writeJsr();
          break;
        case OpCodes.LD:
          writeLdLdiLeaStSti(OpCodes.LDb);
          break;
        case OpCodes.LDI:
          writeLdLdiLeaStSti(OpCodes.LDIb);
          break;
        case OpCodes.LEA:
          writeLdLdiLeaStSti(OpCodes.LEAb);
          break;
        case OpCodes.ST:
          writeLdLdiLeaStSti(OpCodes.STb);
          break;
        case OpCodes.STI:
          writeLdLdiLeaStSti(OpCodes.STIb);
          break;
        case OpCodes.LDR:
          writeLdrAndStr(OpCodes.LDRb);
          break;
        case OpCodes.STR:
          writeLdrAndStr(OpCodes.STRb);
          break;
        case OpCodes.TRAP:
          writeTrap();
          break;
        case Traps.GETC:
          writeTrap();
          break;
        case Traps.HALT:
          writeTrap();
          break;
        case Traps.IN:
          writeTrap();
          break;
        case Traps.OUT:
          writeTrap();
          break;
        case Traps.PUTS:
          writeTrap();
          break;
        case Traps.PUTSP:
          writeTrap();
          break;
        case Macros.END:
          print(
            'This assembler does not make use of the .END macro as it serves no real purpose.',
          );
          programCounter--;
          break;
        case Macros.ORIG:
          // Decrement here to avoid counting .ORIG macro in program
          // counter.  No other action is necessary for this macro.
          programCounter--;
          break;
        default:
          if (!symbols.hasSymbol(commands[0])) {
            throw Exception(
              'Invalid instruction ${commands[0]} at line $currentLine.',
            );
          } else {
            // Decrement here to avoid counting symbol as part
            // of overall program counter offset.
            programCounter--;
            writeStringzBlkwAndFill(line);
          }
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
    var destination = Registers.toBinary(commands[1], 9, currentLine);
    var sourceOne = Registers.toBinary(commands[2], 6, currentLine);

    int parsedImmediate;
    int sourceTwo;
    int immediateFlag;
    try {
      immediateFlag = 0;
      sourceTwo = Registers.toBinary(commands[3], 0, currentLine);
    } catch (e) {
      parsedImmediate = parseInt(commands[3], currentLine);
      var immediateLimit = (pow(2, 4) - 1).toInt();
      if (parsedImmediate.abs() > immediateLimit) {
        throw Exception(
          'Integers greater than $immediateLimit (or 5 twos complement bits) cannot be used as immediate values on line $currentLine.',
        );
      }
      immediateFlag = 1 << 5;
      var truncator = (pow(2, 5) - 1).toInt();
      // Immediate value must be truncated down to maximum 5 bits.
      sourceTwo = parsedImmediate & truncator;
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
    var baseCommand = OpCodes.NOTb;
    var destination = Registers.toBinary(commands[1], 9, currentLine);
    var source = Registers.toBinary(commands[2], 6, currentLine);
    var paddedOnes = 63;

    var finalCommand = baseCommand | destination | source | paddedOnes;
    bCommands.add(finalCommand);
  }

  void writeJmpAndRet() {
    var baseCommand = OpCodes.JMPb;
    int register;
    if (commands.length <= 1) {
      register = Registers.toBinary(Registers.R7, 6, currentLine);
    } else {
      register = Registers.toBinary(commands[1], 6, currentLine);
    }

    var finalCommand = baseCommand | register;
    bCommands.add(finalCommand);
  }

  void writeJsr() {
    if (commands.length != 2) {
      throw Exception(
        'JSR and JSRR require exactly one argument on line $currentLine.',
      );
    }

    var baseCommand = OpCodes.JSRb;
    int finalCommand;
    if (symbols.hasSymbol(commands[1])) {
      var pcoffset = labelToPcoffset(commands[1], 11);
      var fillerOne = 1 << 11;
      finalCommand = baseCommand | fillerOne | pcoffset;
    } else {
      var register = Registers.toBinary(commands[1], 6, currentLine);
      finalCommand = baseCommand | register;
    }

    bCommands.add(finalCommand);
  }

  void writeLdLdiLeaStSti(int baseCommand) {
    if (commands.length != 3) {
      throw Exception(
        'LD, LDI, LEA, ST and STI require exactly two arguments on line $currentLine.',
      );
    }

    var register = Registers.toBinary(commands[1], 9, currentLine);
    var pcoffset = labelToPcoffset(commands[2], 9);
    var finalCommand = baseCommand | register | pcoffset;
    bCommands.add(finalCommand);
  }

  void writeLdrAndStr(int baseCommand) {
    if (commands.length != 4) {
      throw Exception(
        'STR and LDR require exactly three arguments on line $currentLine.',
      );
    }

    var destRegister = Registers.toBinary(commands[1], 9, currentLine);
    var baseRegister = Registers.toBinary(commands[2], 6, currentLine);

    var offset = parseInt(commands[3], currentLine);
    var maxOffset = (pow(2, 6) / 2 - 1).toInt();
    if (offset.abs() > maxOffset) {
      throw Exception(
        'STR and LDR cannot accept an offset greater than 6 twos complement bits or $maxOffset on line $currentLine.',
      );
    }
    var truncator = (pow(2, 6) - 1).toInt();
    offset = offset & truncator;

    var finalCommand = baseCommand | destRegister | baseRegister | offset;
    bCommands.add(finalCommand);
  }

  void writeBr() {
    if (commands.length != 2) {
      throw Exception(
        'BR requires exactly one argument at line: $currentLine.',
      );
    }

    var n = commands[0].toUpperCase().contains('N') ? 1 << 11 : 0;
    var z = commands[0].toUpperCase().contains('Z') ? 1 << 10 : 0;
    var p = commands[0].toUpperCase().contains('P') ? 1 << 9 : 0;

    var baseCommand = OpCodes.BRb;
    var offset = labelToPcoffset(commands[1], 9);
    var finalCommand = baseCommand | n | z | p | offset;

    bCommands.add(finalCommand);
  }

  void writeTrap() {
    String trap;
    if (commands.length == 1) {
      trap = commands[0];
    } else if (commands.length == 2) {
      trap = commands[1];
    } else {
      throw Exception(
        'TRAP opcode takes exactly one argument (TRAP opcode may also be ommited) on line $currentLine.',
      );
    }

    var binaryTrap = Traps.toBinary(trap.toUpperCase(), currentLine);
    var baseCommand = OpCodes.TRAPb;
    var finalCommand = baseCommand | binaryTrap;
    bCommands.add(finalCommand);
  }

  void writeStringzBlkwAndFill(String line) {
    if (commands.length == 1) {
      // Standalone symbols need no extra processing.
      return;
    } else if (commands.length < 3) {
      throw Exception(
        '.STRINGZ, .BLKW or .FILL require a value argument at line $currentLine.',
      );
    } else if (commands[1].toUpperCase() == Macros.FILL) {
      var value = parseInt(commands[2], currentLine);
      bCommands.add(value);
      // Increment once for single memory space.
      programCounter++;
    } else if (commands[1].toUpperCase() == Macros.BLKW) {
      var spaces = parseInt(commands[2], currentLine);
      bCommands.addAll(List.generate(spaces, (index) => 0));
      // Increment for each space added.
      programCounter += spaces;
    } else if (commands[1].toUpperCase() == Macros.STRINGZ) {
      var firstWordIndex = line.indexOf(RegExp('[ \t]+'));
      var secondWordIndex = line.indexOf(RegExp('[ \t]+'), firstWordIndex + 1);
      var stringLiteral = processStringLiteral(
        line.substring(secondWordIndex + 1),
      );

      if (stringLiteral == null) {
        throw Exception(
          'Failed to parse string literal on line $currentLine.',
        );
      }

      bCommands.addAll(stringLiteral.codeUnits);
      // Null terminated
      bCommands.add(0);
      // Increment for each character and null terminator.
      programCounter += stringLiteral.length + 1;
    }
  }

  int labelToPcoffset(String label, int offsetBitLength) {
    if (!symbols.hasSymbol(label)) {
      throw Exception(
        'Cannot use undeclared label $label in instruction on line $currentLine.',
      );
    }

    var labelLocation = symbols.symbols[label]!;
    // The minus one here is important because adding
    // the offset to the PC should put it one instruction
    // short of its target.  The when the counter is
    // incremented following the successfully execution
    // of the current instruction it will increment and
    // be ready to execute the next instruction.
    var pcoffset = labelLocation - programCounter - 1;
    // Maximum offset is the maximum twos complement
    // integer representable by offsetBitLength bits
    var maxOffset = (pow(2, offsetBitLength) / 2 - 1).toInt();
    if (pcoffset.abs() > maxOffset) {
      throw Exception(
        'Cannot jump to label $label having memory offset $labelLocation from current memory offset at $programCounter, distance is greater than maximum $maxOffset representable by $offsetBitLength bits.',
      );
    }

    // May need to trucate here because memory offsets
    // can be negative twos complement integers.
    var truncator = (pow(2, offsetBitLength) - 1) as int;
    pcoffset = truncator & pcoffset;
    return pcoffset;
  }

  Future<void> writeBinRep() async {
    var outFile = File('./temp/program_bin.txt').openWrite();
    var bCommands16 = Uint16List.fromList(bCommands);
    bCommands16.forEach((element) {
      var line = element.toRadixString(2);
      line = '0' * (16 - line.length) + line;
      outFile.writeln(line);
    });

    await outFile.done;
    await outFile.close();
  }
}

class Lc3DartSymbols {
  Map<String, int> symbols = {};
  int origin = 0x3000;
  int memoryOffset = 0;
  int currentLine = 1;

  final int minimumMemorySpace = 12288;
  final int maximumMemorySpace = 65023;

  Future<void> writeSymbolsFile(String filePath) async {
    var dirName = path.dirname(filePath);
    var fileName = path.basenameWithoutExtension(filePath) + '.sym';
    var outFile = File(dirName + '/' + fileName).openWrite();
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
    await outFile.done;
    await outFile.close();
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
          memoryOffset++;
        }
        currentLine++;
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
        // Generally the memory offset should not be incremented
        // for a label, however blkw, stringz and fill need incrementing.
        // This is handled here instead of in another function for fill.
        memoryOffset++;
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
    var originParsed = parseInt(commands[1], currentLine);
    if (originParsed < minimumMemorySpace ||
        originParsed > maximumMemorySpace) {
      throw Exception(
        'LC3 .ORIG must be between 0X3000 and 0XFDFF on line $currentLine.',
      );
    } else {
      origin = originParsed;
      // The origin does not count as a memory location.
      memoryOffset--;
    }
  }

  void markStandaloneSymbol(String symbol) {
    symbol = symbol.replaceAll(':', '');
    if (symbols.containsKey(symbol)) {
      throw Exception(
        'Illegal redefinition of symbol $symbol on line $currentLine.',
      );
    } else {
      symbols[symbol] = origin + memoryOffset;
      memoryOffset--;
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
    var spaceToAllocate = parseInt(remainingLine, currentLine);

    markStandaloneSymbol(symbol);
    memoryOffset += spaceToAllocate;
  }

  bool hasSymbol(String symbol) {
    symbol = symbol.replaceAll(':', '');
    return symbols.containsKey(symbol);
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

int parseInt(String num, int currentLine) {
  num = num.toUpperCase();
  int? returnVal;
  if (num.contains('0X') || num.contains('X')) {
    num = num.replaceFirst('0X', '');
    num = num.replaceFirst('X', '');
    returnVal = int.tryParse(num, radix: 16);
  } else {
    returnVal = int.tryParse(num, radix: 10);
  }

  if (returnVal == null) {
    throw Exception('Unparseable integer $num found on line $currentLine.');
  }

  return returnVal;
}
