import 'package:cric_live/utils/import_exports.dart';

class CreateMatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CreateMatchController());
  }
}
