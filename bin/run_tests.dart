import 'package:lc3_dart_vm/test/test_assembler.dart';
import 'package:lc3_dart_vm/test/test_vm.dart';

void testAssembler() {
  // Tests for binary commands generator
  testAdd();
  testAnd();
  testNot();
  testRetAndJmp();
  testJsrAndJsrr();
  testLdLdiLeaStSti();
  testLdrAndStr();
  testBr();
  testAllocationSymbolWriting();
  testTrapWriting();
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

void testVm() {
  testAddOpCode();
  testSignExtend();
}

void main(List<String> args) {
  testAssembler();
  testVm();
}
