import 'package:cric_live/utils/import_exports.dart';

class ForgotPasswordEmailController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  var isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendVerificationCode() async {
    try {
      if (formKey.currentState!.validate()) {
        isLoading.value = true;
        AuthService authService = AuthService();
        bool isUserExist = await authService.checkUser(emailController.text);
        if (!isUserExist) {
          Get.snackbar("User Not Found", "Please Try On Valid Email");
          return;
        }
        await authService.sendOtp(emailController.text);
        // Navigate to OTP verification screen
        Get.toNamed(
          NAV_OTP_SCREEN,
          arguments: {'email': emailController.text, 'isResetPassword': true},
        );

        Get.snackbar(
          "Verification Code Sent",
          "Please check your email for the verification code",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
