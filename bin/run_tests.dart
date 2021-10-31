import 'package:lc3_dart_vm/test/test_assembler.dart';

void testAssembler() {
  // Tests for binary commands generator
  testAdd();
  testAnd();
  testNot();
  testRetAndJmp();
  testJsrAndJsrr();
  testLdLdiLeaStSti();
  testLabelToPcoffset();
  // Tests for global functions
  testCommentRemoval();
  testParseInt();
  testProcessStringLiteral();
  // Tests for symbol marker
  testMarkOrigin();
  testMarkStringzSymbol();
  testMarkBlkwSymbol();
}

void main(List<String> args) {
  testAssembler();
}
