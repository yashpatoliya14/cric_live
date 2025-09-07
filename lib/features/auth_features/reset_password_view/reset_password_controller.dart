
import 'package:cric_live/utils/import_exports.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isNewPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;

  late String email;

  @override
  void onInit() {
    super.onInit();
    // Get email from arguments passed from OTP verification
    final args = Get.arguments as Map<String, dynamic>;
    email = args['email'];
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.value = !isNewPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<void> resetPassword() async {
    try {
      if (formKey.currentState!.validate()) {
        isLoading.value = true;
        AuthService authService = AuthService();
        // TODO: Implement API call to reset password
        LoginModel model = LoginModel(
          email: email,
          password: confirmPasswordController.text,
        );
        await authService.forgotPassword(model);

        // Show success message
        Get.snackbar(
          "Password Reset Successful",
          "Your password has been reset successfully. Please login with your new password.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        // Navigate back to login screen
        Get.offAllNamed(NAV_LOGIN);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to reset password. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
