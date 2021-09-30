import 'package:test/test.dart';
import 'package:lc3_dart_vm/lc3_dart_assembler.dart';

void testAdd() {
  test('Successfully add with three registers.', () {
    var obj = Lc3DartAssembler();
    obj.commands = ['ADD', 'R0', 'R1', 'R3'];
    obj.writeAdd();
    expect(4163, obj.bCommands[0]);
  });
}
