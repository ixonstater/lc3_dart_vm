import 'package:test/test.dart';
import 'package:lc3_dart_vm/lc3_dart_assembler.dart';

void testAdd() {
  test('Successfully add with three registers.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['ADD', 'R0', 'R1', 'R3'];
    obj.writeAddOrAnd();
    expect(4163, obj.bCommands[0]);
  });

  test('Successfully add with immediate value.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['ADD', 'R7', 'R3', '30'];
    obj.writeAddOrAnd();
    expect(7934, obj.bCommands[0]);
  });

  test('Fail to add with mis-named register.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['ADD', 'R0', 'R1', 'R8'];
    expect(obj.writeAddOrAnd, throwsException);
  });

  test('Fail to add with overflow immediate value.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['ADD', 'R7', 'R3', '32'];
    expect(obj.writeAddOrAnd, throwsException);
  });
}

void testAnd() {
  test('Successfully and with three registers.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['AND', 'R0', 'R1', 'R3'];
    obj.writeAddOrAnd();
    expect(20547, obj.bCommands[0]);
  });

  test('Successfully and with immediate value.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['AND', 'R7', 'R3', '30'];
    obj.writeAddOrAnd();
    expect(24318, obj.bCommands[0]);
  });

  test('Fail to and with mis-named register.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['AND', 'R0', 'R1', 'R8'];
    expect(obj.writeAddOrAnd, throwsException);
  });

  test('Fail to and with overflow immediate value.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['AND', 'R7', 'R3', '32'];
    expect(obj.writeAddOrAnd, throwsException);
  });
}

void testNot() {
  test('Succesfully not with mixed case command.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['Not', 'r1', 'r2'];
    obj.writeNot();
    expect(obj.bCommands[0], 37567);
  });

  test('Fail to not with too many arguments.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['NOT', 'R0', 'R4', 'R5'];
    expect(obj.writeNot, throwsException);
  });
}

void testRetAndJmp() {
  test('Successfully JMP.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['JMP', 'R3'];
    obj.writeJmpAndRet();
    expect(obj.bCommands[0], 49344);
  });

  test('Successfully RET.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['RET'];
    obj.writeJmpAndRet();
    expect(obj.bCommands[0], 49600);
  });

  test('Fail JMP with bad register.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['jMp', 'R11'];
    expect(() => obj.writeJmpAndRet(), throwsException);
  });
}

void testJsrAndJsrr() {
  var obj = Lc3DartAssembler();
  obj.symbols.symbols.addAll({
    'symbolOne': 10,
    'symbolTwo': 15,
    'symbolThree': 16,
  });

  test('Succesfully add JSR command.', () {
    obj.bCommands = [];
    obj.commands = ['JSR', 'symbolOne'];
    obj.writeJsr();
    expect(obj.bCommands[0], 18442);
  });
  test('Succesfully add JSRR command.', () {
    obj.bCommands = [];
    obj.commands = ['JSRr', 'r1'];
    obj.writeJsr();
    expect(obj.bCommands[0], 16448);
  });
  test('Fail on wrong number of args.', () {
    obj.bCommands = [];
    obj.commands = ['JSRr', 'r1', 'r4'];
    expect(() => obj.writeJsr(), throwsException);
  });
  test('Fail on pcoffset too large.', () {
    obj.bCommands = [];
    obj.commands = ['JSRr', 'symbolOne'];
    obj.programCounter = 2058;
    expect(() => obj.writeJsr(), throwsException);
  });
}

void testCommentRemoval() {
  test('Remove standalone comment.', () {
    var line = preprocessLine(';A test comment; comment; comment');
    expect(line, '');
  });

  test('Remove comment from code line.', () {
    var line = preprocessLine('ADD R0 R2 30;A test comment; comment; comment');
    expect(line, 'ADD R0 R2 30');
  });

  test('Remove comment with space from code line', () {
    var line = preprocessLine('ADD R0 R2 30      ;test comment');
    expect(line, 'ADD R0 R2 30');
  });
}

void testParseInt() {
  test('Test parsing base 10 integer.', () {
    var parsed = parseInt('100', 0);
    expect(parsed, 100);
  });

  test('Fail parsing malformed base 10 integer.', () {
    expect(() => parseInt('10f0', 0), throwsException);
  });

  test('Test parsing base 16 integer with 0x marker.', () {
    var parsed = parseInt('0x100', 0);
    expect(parsed, 256);
  });

  test('Test parsing base 16 integer with x marker.', () {
    var parsed = parseInt('x101', 0);
    expect(parsed, 257);
  });

  test('Fail parsing malformed base 16 integer.', () {
    expect(() => parseInt('0x100cvw', 0), throwsException);
  });
}

void testProcessStringLiteral() {
  test('Parse basic string', () {
    var value = processStringLiteral('"Hello world."');
    expect(value, 'Hello world.');
  });

  test('Sucessfully parse string with escaped quotes.', () {
    var value = processStringLiteral('"Hel\\"lo w\\"or\\"ld."');
    expect(value, 'Hel"lo w"or"ld.');
  });

  test('Fail to parse non-terminated string.', () {
    expect(processStringLiteral('"Hello world.'), null);
  });

  test('Change \\r and \\n and \\r\\n to escaped values.', () {
    expect(processStringLiteral('"Hello \\r world \\n. \\r\\n"'),
        'Hello \r world \n. \r\n');
  });
}

void testMarkOrigin() {
  test('Succesfully mark program origin.', () {
    var obj = Lc3DartSymbols();
    obj.markOrigin('.ORIg 0X3000');
    expect(obj.origin, 12288);
  });

  test('Fail with too few arguments.', () {
    var obj = Lc3DartSymbols();
    expect(() => obj.markOrigin('.ORIG'), throwsException);
  });

  test('Fail with malformed orig macro.', () {
    var obj = Lc3DartSymbols();
    expect(() => obj.markOrigin('RIG'), throwsException);
  });

  test('Fail with malformed integer operand.', () {
    var obj = Lc3DartSymbols();
    expect(() => obj.markOrigin('.ORIG 0xfdax'), throwsException);
  });

  test('Fail with origin set above valid constraints.', () {
    var obj = Lc3DartSymbols();
    expect(() => obj.markOrigin('.ORIG 0xfe00'), throwsException);
  });

  test('Fail with origin set below valid constraints.', () {
    var obj = Lc3DartSymbols();
    expect(() => obj.markOrigin('.ORIG 0x2fff'), throwsException);
  });
}

void testMarkStringzSymbol() {
  test('Correctly set memory offset for string.', () {
    var obj = Lc3DartSymbols();
    obj.markStringzSymbol('TEST_SYMBOL', '"A test line."');
    expect(obj.symbols.containsKey('TEST_SYMBOL'), true);
    expect(obj.symbols['TEST_SYMBOL'], obj.minimumMemorySpace);
    expect(obj.memoryOffset, 12);
  });
}

void testMarkBlkwSymbol() {
  test('Correctly set memory offset for blkw.', () {
    var obj = Lc3DartSymbols();
    obj.markBlkwSymbol('TEST_SYMBOL', '20');
    expect(obj.symbols.containsKey('TEST_SYMBOL'), true);
    expect(obj.symbols['TEST_SYMBOL'], obj.minimumMemorySpace);
    expect(obj.memoryOffset, 19);
  });
}
