import 'package:cric_live/utils/import_exports.dart';

class OtpScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpScreenController>(() => OtpScreenController());
  }
}
