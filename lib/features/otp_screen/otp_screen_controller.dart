import 'dart:async';

import 'package:cric_live/services/api_services/api_services.dart';
import 'package:cric_live/services/auth/auth_service.dart';
import 'package:cric_live/utils/import_exports.dart';

import 'otp_screen_model.dart';

class OtpScreenController extends GetxController {
  // Email received from arguments
  late final String email;

  // OTP input controllers for 6 digits
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // Focus nodes for OTP fields
  final List<FocusNode> otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  // Observable variables
  var isLoading = false.obs;
  var canResend = false.obs;
  var timerSeconds = 60.obs;
  var currentOtp = ''.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    // Get email from route arguments
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['email'] != null) {
      email = arguments['email'] as String;
    } else {
      // Handle error - email not provided
      Get.back();
      Get.snackbar(
        "Error",
        "Email is required for OTP verification",

        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Start the countdown timer
    startTimer();

    // Add listeners to OTP controllers
    for (int i = 0; i < 6; i++) {
      otpControllers[i].addListener(() => _updateCurrentOtp());
    }
  }

  @override
  void onClose() {
    // Dispose controllers and focus nodes
    for (int i = 0; i < 6; i++) {
      otpControllers[i].dispose();
      otpFocusNodes[i].dispose();
    }
    _timer?.cancel();
    super.onClose();
  }

  void _updateCurrentOtp() {
    String otp = '';
    for (final controller in otpControllers) {
      otp += controller.text;
    }
    currentOtp.value = otp;
  }

  void startTimer() {
    canResend.value = false;
    timerSeconds.value = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty && value.length == 1) {
      // Move to next field if current field is filled
      if (index < 5) {
        otpFocusNodes[index + 1].requestFocus();
      } else {
        // Last field - remove focus
        otpFocusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      // Move to previous field if current field is empty
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  void onBackspacePressed(int index) {
    if (otpControllers[index].text.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
      otpControllers[index - 1].clear();
    }
  }

  String get maskedEmail {
    if (email.contains('@')) {
      final parts = email.split('@');
      final username = parts[0];
      final domain = parts[1];

      if (username.length <= 2) {
        return '${username[0]}***@$domain';
      }

      final firstTwo = username.substring(0, 2);
      final lastOne = username.substring(username.length - 1);
      return '$firstTwo***$lastOne@$domain';
    }
    return email;
  }

  bool get isOtpComplete {
    return currentOtp.value.length == 6;
  }

  bool get isOtpValid {
    return RegExp(r'^[0-9]{6}$').hasMatch(currentOtp.value);
  }

  void clearOtp() {
    for (final controller in otpControllers) {
      controller.clear();
    }
    otpFocusNodes[0].requestFocus();
  }

  void pasteOtp(String pastedText) {
    // Remove any non-numeric characters and limit to 6 digits
    final cleanedText = pastedText.replaceAll(RegExp(r'[^0-9]'), '');
    final otpText =
        cleanedText.length > 6 ? cleanedText.substring(0, 6) : cleanedText;

    // Fill the OTP fields
    for (int i = 0; i < 6; i++) {
      if (i < otpText.length) {
        otpControllers[i].text = otpText[i];
      } else {
        otpControllers[i].clear();
      }
    }

    // Focus on the next empty field or last field if all are filled
    if (otpText.length < 6) {
      otpFocusNodes[otpText.length].requestFocus();
    } else {
      otpFocusNodes[5].unfocus();
    }
  }

  Future<void> verifyOtp() async {
    if (!isOtpComplete) {
      Get.snackbar(
        "Incomplete OTP",
        "Please enter the complete 6-digit OTP",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (!isOtpValid) {
      Get.snackbar(
        "Invalid OTP",
        "Please enter a valid 6-digit OTP",

        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      AuthService service = AuthService();
      OtpModel model = OtpModel(email: email, otp: currentOtp.value);
      await service.verifyOtp(model);
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResend.value) {
      return;
    }

    isLoading.value = true;

    try {
      // Use the singleton instance
      ApiServices services = ApiServices.to;

      // Create resend request data
      final requestData = {"email": email};

      print('Resending OTP for email: $email');

      // Call the actual resend OTP API endpoint
      dynamic res = await services.post("/CL_Users/ResendOtp", requestData);

      print('Resend OTP response: $res');

      String message = "A new OTP has been sent to your email";
      if (res != null &&
          res is Map<String, dynamic> &&
          res["message"] != null) {
        message = res["message"];
      }

      Get.snackbar(
        "OTP Sent",
        message,

        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear current OTP and restart timer
      clearOtp();
      startTimer();
    } catch (e) {
      print('Resend OTP error: $e');

      String errorMessage = "Failed to resend OTP. Please try again.";

      if (e.toString().contains('SocketException')) {
        errorMessage = "No internet connection. Please check your network.";
      } else if (e.toString().contains('HttpException')) {
        errorMessage = e.toString().replaceAll('HttpException: ', '');
      } else if (e.toString().contains('HTTP Error')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar(
        "Error",
        errorMessage,

        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String get timerText {
    final minutes = (timerSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (timerSeconds.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
