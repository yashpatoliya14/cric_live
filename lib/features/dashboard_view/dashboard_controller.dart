import 'package:cric_live/utils/import_exports.dart';

class DashboardController extends GetxController {
  RxString email = "".obs;
  RxString username = "".obs;
  RxString displayName = "".obs;
  Rx<TokenModel?> userToken = Rx<TokenModel?>(null);

  @override
  void onInit() {
    fetchUserInfo();
    super.onInit();
  }

  fetchUserInfo() {
    try {
      AuthService authService = AuthService();
      TokenModel? model = authService.fetchInfoFromToken();
      
      if (model != null) {
        userToken.value = model;
        email.value = model.email ?? "cricket@user.com";
        username.value = model.username ?? "";
        displayName.value = model.displayName;
        
        // Refresh all observables
        email.refresh();
        username.refresh();
        displayName.refresh();
        userToken.refresh();
        
        log('User info loaded: ${model.displayName} (${model.email})');
      } else {
        // Fallback values
        email.value = "cricket@user.com";
        displayName.value = "Cricket User";
        log('No user token found, using fallback values');
      }
    } catch (e) {
      log('Error fetching user info: $e');
      // Safe fallbacks
      email.value = "cricket@user.com";
      displayName.value = "Cricket User";
    }
  }

  @override
  void onClose() {
    // TODO: implement onInit
    super.onClose();
  }
}
