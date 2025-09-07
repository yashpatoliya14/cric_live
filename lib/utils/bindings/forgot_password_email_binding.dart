import 'package:cric_live/utils/import_exports.dart';
class ForgotPasswordEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordEmailController>(
      () => ForgotPasswordEmailController(),
    );
  }
}
