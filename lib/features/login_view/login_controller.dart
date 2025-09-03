import 'package:cric_live/features/login_view/login_model.dart';
import 'package:cric_live/services/auth/auth_service.dart';
import 'package:cric_live/utils/import_exports.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isPasswordHidden = true.obs;

  @override
  void onClose() {
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Loading state observable
  var isLoading = false.obs;

  Future<void> login() async {
    try {
      // Validate the form fields
      if (formKey.currentState!.validate()) {
        isLoading.value = true;

        AuthService authService = AuthService();
        LoginModel model = LoginModel(
          email: emailController.text,
          password: passwordController.text,
        );

        dynamic res = await authService.login(model);
      }
    } catch (e) {
      log('Login error details: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    Get.snackbar(
      "Forgot Password",
      "Forgot password functionality coming soon!",
    );
  }

  /// Test network connectivity
  Future<void> testNetworkConnection() async {
    try {
      isLoading.value = true;
      Get.snackbar(
        "Testing Network",
        "Checking connectivity...",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Test basic connectivity first using our network-based approach
      final syncFeature = SyncFeature();
      final hasConnection = await syncFeature.hasInternetConnection();

      String connectionDescription =
          hasConnection
              ? 'Internet connection available'
              : 'No internet connection';

      String message = '';
      Color backgroundColor = Colors.green;

      if (!hasConnection) {
        message =
            'No internet connection detected. Please check your network settings.';
        backgroundColor = Colors.red;
      } else {
        message = 'Connection issues detected.\n$connectionDescription';
        backgroundColor = Colors.red;
      }

      Get.snackbar(
        "Network Test Results",
        message,
        backgroundColor: backgroundColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        "Network Test Error",
        "Failed to test network: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
