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
    expect(4163, obj.bCommands[0]);
  });

  test('Successfully and with immediate value.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['AND', 'R7', 'R3', '30'];
    obj.writeAddOrAnd();
    expect(7934, obj.bCommands[0]);
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
