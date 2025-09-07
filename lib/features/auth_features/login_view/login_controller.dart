import 'package:cric_live/utils/import_exports.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Loading state observable
  var isLoading = false.obs;

  Future<void> login() async {
    try {
      // Validate the form fields
      if (formKey.currentState!.validate()) {
        // Check internet connection first
        bool hasInternet = await InternetRequiredService.checkForLogin();
        if (!hasInternet) {
          return; // User cancelled or still no internet
        }

        isLoading.value = true;

        AuthService authService = AuthService();
        LoginModel model = LoginModel(
          email: emailController.text,
          password: passwordController.text,
        );

        dynamic res = await authService.login(model);
        Get.offAllNamed(NAV_DASHBOARD_PAGE);
      }
    } catch (e) {
      log('Login error details: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    Get.toNamed(NAV_FORGOT_PASSWORD_EMAIL);
  }
}
