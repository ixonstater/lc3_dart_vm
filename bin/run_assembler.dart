import 'package:lc3_dart_vm/lc3_dart_assembler.dart';

void main(List<String> args) {
  var obj = Lc3DartAssembler();
  obj.assemble('./temp/test_copy.asm');
}
