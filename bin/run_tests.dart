import 'package:lc3_dart_vm/test/test_assembler.dart';

void testAssembler() {
  testAdd();
  testAnd();
  testNot();
  testCommentRemoval();
  testParseInt();
  testProcessStringLiteral();
  testMarkOrigin();
}

void main(List<String> args) {
  testAssembler();
}
