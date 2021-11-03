import 'package:lc3_dart_vm/lc3_dart_vm.dart';
import 'package:test/test.dart';

void testAddOpCode() {
  test('Add with positive immediate.', () {
    var obj = Lc3DartVm();
    obj.add(int.parse('0001000001100011', radix: 2));
    expect(obj.registers[0], 3);
  });
  test('Add with negative immediate.', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R_R1] = 2;
    obj.add(int.parse('0001000001111110', radix: 2));
    expect(obj.registers[0], 0);
  });
  test('Add with three registers.', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R_R1] = 1;
    obj.registers[Registers.R_R2] = 2;
    obj.add(int.parse('0001000001000010', radix: 2));
    expect(obj.registers[0], 3);
  });
  test('Test wrap around addition at 16 bit int limit.', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R_R1] = 65535;
    obj.add(int.parse('0001000001100001', radix: 2));
    expect(obj.registers[0], 0);
  });
}
