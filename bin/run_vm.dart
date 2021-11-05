import 'package:lc3_dart_vm/lc3_dart_vm.dart';

Future<void> main(List<String> args) async {
  var obj = Lc3DartVm();
  await obj.start('./temp/test.obj');
  obj.console.rawMode = false;
}
