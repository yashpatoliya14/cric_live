import 'package:cric_live/utils/import_exports.dart';

class DashboardController extends GetxController {
  RxString email = "".obs;
  @override
  void onInit() {
    fetchEmail();
    // TODO: implement onInit
    super.onInit();
  }

  fetchEmail() {
    try {
      AuthService authService = AuthService();
      TokenModel? model = authService.fetchInfoFromToken();
      email.value = model?.email ?? "cricket@user.com"; // Better fallback
      email.refresh();
    } catch (e) {
      log('Error fetching email: $e');
      email.value = "cricket@user.com"; // Safe fallback
    }
  }

  @override
  void onClose() {
    // TODO: implement onInit
    super.onClose();
  }
}
