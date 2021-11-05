import 'package:lc3_dart_vm/lc3_dart_vm.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Useage:');
    print('dart run_vm.dart {filename.obj}');
  } else {
    var obj = Lc3DartVm();
    await obj.start(args[0]);
    obj.console.rawMode = false;
  }
}
