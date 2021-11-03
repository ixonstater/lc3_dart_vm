import 'package:lc3_dart_vm/lc3_dart_vm.dart';
import 'package:test/test.dart';

void testAddVm() {
  test('Add with positive immediate.', () {
    var obj = Lc3DartVm();
    obj.add(int.parse('0001000001100011', radix: 2));
    expect(obj.registers[0], 3);
  });
  test('Add with negative immediate.', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R1] = 2;
    obj.add(int.parse('0001000001111110', radix: 2));
    expect(obj.registers[0], 0);
  });
  test('Add with three registers.', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R1] = 1;
    obj.registers[Registers.R2] = 2;
    obj.add(int.parse('0001000001000010', radix: 2));
    expect(obj.registers[0], 3);
  });
  test('Test wrap around addition at 16 bit int limit.', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R1] = 65535;
    obj.add(int.parse('0001000001100001', radix: 2));
    expect(obj.registers[0], 0);
  });
}

void testAndVm() {
  test('And with positive immediate', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R1] = 7;
    obj.and(int.parse('0101000001100101', radix: 2));
    expect(obj.registers[Registers.R0], 5);
  });

  test('And with negative immediate', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R1] = 7;
    obj.and(int.parse('0101000001111111', radix: 2));
    expect(obj.registers[Registers.R0], 7);
  });

  test('And with three registers', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R1] = 7;
    obj.registers[Registers.R2] = 3;
    obj.and(int.parse('0101000001000010', radix: 2));
    expect(obj.registers[Registers.R0], 3);
  });
}

void testNotVm() {
  test('Successfully execute NOT.', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R1] = 10;
    obj.not(int.parse('1001000001111111', radix: 2));
    expect(obj.registers[Registers.R0], 65525);
  });
}

void testSignExtend() {
  test('Five bits positive.', () {
    var obj = Lc3DartVm();
    var num = obj.signExtend(int.parse('00101', radix: 2), 5);
    expect(num, 5);
  });
  test('Five bits negative.', () {
    var obj = Lc3DartVm();
    var num = obj.signExtend(25, 5);
    expect(num, -7);
  });
  test('Nine bits positive.', () {
    var obj = Lc3DartVm();
    var num = obj.signExtend(int.parse('0100101', radix: 2), 9);
    expect(num, 37);
  });
  test('Nine bits negative.', () {
    var obj = Lc3DartVm();
    var num = obj.signExtend(485, 9);
    expect(num, -27);
  });
  test('Eleven bits positive.', () {
    var obj = Lc3DartVm();
    var num = obj.signExtend(int.parse('01010100101', radix: 2), 11);
    expect(num, 677);
  });
  test('Eleven bits negative.', () {
    var obj = Lc3DartVm();
    var num = obj.signExtend(1701, 10);
    expect(num, -347);
  });
}

void testUpdateFlags() {
  test('Update flags negative.', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R0] = -1;
    obj.updateFlags(Registers.R0);
    expect(obj.registers[Registers.COND], Conditionals.NEG);
  });
  test('Update flags positive.', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R0] = 1;
    obj.updateFlags(Registers.R0);
    expect(obj.registers[Registers.COND], Conditionals.POS);
  });
  test('Update flags zero.', () {
    var obj = Lc3DartVm();
    obj.registers[Registers.R0] = 0;
    obj.updateFlags(Registers.R0);
    expect(obj.registers[Registers.COND], Conditionals.ZERO);
  });
}
