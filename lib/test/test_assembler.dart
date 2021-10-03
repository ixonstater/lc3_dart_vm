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

void testCommentRemoval() {
  test('Remove standalone comment.', () {
    var line = Lc3DartAssembler()
        .removeCommentFromLine(';A test comment; comment; comment');
    expect(line, '');
  });

  test('Remove comment from code line.', () {
    var line = Lc3DartAssembler()
        .removeCommentFromLine('ADD R0 R2 30;A test comment; comment; comment');
    expect(line, 'ADD R0 R2 30');
  });
}

void testParseInt() {
  test('Test parsing base 10 integer.', () {
    var obj = Lc3DartAssembler();
    var parsed = obj.parseInt('100');
    expect(parsed, 100);
  });

  test('Fail parsing malformed base 10 integer.', () {
    var obj = Lc3DartAssembler();
    var parsed = obj.parseInt('10f0');
    expect(parsed, null);
  });

  test('Test parsing base 16 integer with 0x marker.', () {
    var obj = Lc3DartAssembler();
    var parsed = obj.parseInt('0x100');
    expect(parsed, 256);
  });

  test('Test parsing base 16 integer with x marker.', () {
    var obj = Lc3DartAssembler();
    var parsed = obj.parseInt('x101');
    expect(parsed, 257);
  });

  test('Fail parsing malformed base 16 integer.', () {
    var obj = Lc3DartAssembler();
    var parsed = obj.parseInt('0x100cvw');
    expect(parsed, null);
  });
}

void testMarkOrigin() {
  test('Succesfully mark program origin.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['.ORIG', '0X3000'];
    obj.markOrigin();
    expect(obj.origin, 12288);
  });

  test('Fail with too few arguments.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['.ORIG'];
    expect(obj.markOrigin, throwsException);
  });

  test('Fail with malformed orig macro.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['RIG'];
    expect(obj.markOrigin, throwsException);
  });

  test('Fail with malformed integer operand.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['.ORIG', '0xfdax'];
    expect(obj.markOrigin, throwsException);
  });

  test('Fail with origin set above valid constraints.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['.ORIG', '0xfe00'];
    expect(obj.markOrigin, throwsException);
  });

  test('Fail with origin set below valid constraints.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['.ORIG', '0x2fff'];
    expect(obj.markOrigin, throwsException);
  });
}

void testTryMarkLabel() {
  var obj = Lc3DartAssembler();
  obj.origin = 20000;

  test('Ignore opcode line.', () {
    obj.tryMarkLabel('ADd');
    expect(obj.labels.containsKey('ADd'), false);
  });

  test('Ignore macro line.', () {
    obj.tryMarkLabel('ADd');
    expect(obj.labels.containsKey('.stringZ'), false);
  });

  test('Add label.', () {
    obj.tryMarkLabel('testL');
    expect(obj.labels.containsKey('testL'), true);
  });
}
