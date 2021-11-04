import 'package:lc3_dart_vm/lc3_dart_vm.dart';

void main(List<String> args) {
  var obj = Lc3DartVm();
  obj.start('./temp/2048.obj');
  obj.console.rawMode = false;
}
