import 'package:cric_live/utils/import_exports.dart';

class AuthService {
  late ApiServices _apiServices;
  AuthService() {
    _apiServices = ApiServices();
  }
  Future<void> signup(SignupModel data) async {
    try {
      Map<String, dynamic> result = await _apiServices.post(
        "/CL_Users/CreateUser",
        data.toJson(),
      );

      // API service already returns Map<String, dynamic>, no need to decode
      await sendOtp(data.email.toString());
      Get.toNamed(NAV_OTP_SCREEN, arguments: {"email": data.email});
    } catch (e) {
      // Handle different types of errors
      String errorMessage = e.toString();
      if (errorMessage.contains("Bad Request")) {
        getSnackBar(title: "Sign up Failed", message: "Invalid data provided");
      } else if (errorMessage.contains("Server Error")) {
        getSnackBar(title: "Server Error", message: "Please try again later");
      } else {
        getSnackBar(
          title: "Error",
          message: "Sign up failed. Please try again",
        );
      }
      rethrow;
    }
  }

  Future<void> sendOtp(String email) async {
    try {
      Map<String, dynamic> resultOfOtp = await _apiServices.post(
        "/CL_Users/SendOtp",
        email,
      );

      getSnackBar(
        title: "Check Your Email For Verification",
        message: resultOfOtp["message"] ?? "OTP sent successfully",
      );
    } catch (e) {
      // Handle different types of errors
      String errorMessage = e.toString();
      if (errorMessage.contains("Server Error")) {
        getSnackBar(
          title: "Failed To Send Otp",
          message: "Server error. Please try again",
        );
      } else {
        getSnackBar(
          title: "Error",
          message: "Failed to send OTP. Please try again",
        );
      }
      rethrow;
    }
  }

  Future<bool> checkUser(String email) async {
    try {
      Map<String, dynamic> result = await _apiServices.get(
        "/CL_Users/GetUserByEmail/$email",
      );

      // If we get here, user exists (no exception thrown)
      return true;
    } catch (e) {
      // Check if it's a 404 (user not found)
      if (e.toString().contains("Not Found")) {
        return false;
      }
      // For other errors, rethrow
      rethrow;
    }
  }

  Future<dynamic> login(LoginModel data) async {
    try {
      Map<String, dynamic> result = await _apiServices.post(
        "/CL_Users/Login",
        data.toJson(),
      );

      final prefs = Get.find<SharedPreferences>();
      prefs.setString("token", result["token"]);
      getSnackBar(
        title: "Login Successful",
        message: result["message"] ?? "Welcome back!",
      );
    } catch (e) {
      // Handle different types of errors
      String errorMessage = e.toString();
      if (errorMessage.contains("Bad Request")) {
        getSnackBar(title: "Login Failed", message: "Invalid credentials");
      } else if (errorMessage.contains("Server Error")) {
        getSnackBar(title: "Server Error", message: "Please try again later");
      } else {
        getSnackBar(title: "Error", message: "Login failed. Please try again");
      }
      rethrow;
    }
  }

  Future<void> forgotPassword(LoginModel data) async {
    try {
      Map<String, dynamic> result = await _apiServices.post(
        "/CL_Users/ForgotPassword",
        data.toJson(),
      );

      getSnackBar(
        title: "Change Successful",
        message: result["message"] ?? "Password updated successfully",
      );
      Get.toNamed(NAV_DASHBOARD_PAGE);
    } catch (e) {
      log("Forgot Password");
      log(e.toString());

      // Handle different types of errors
      String errorMessage = e.toString();
      if (errorMessage.contains("Bad Request")) {
        getSnackBar(title: "Change Failed", message: "Invalid request");
      } else if (errorMessage.contains("Server Error")) {
        getSnackBar(title: "Server Error", message: "Please try again later");
      } else {
        getSnackBar(title: "Error", message: "Password change failed");
      }
    }
  }

  Future<void> verifyOtp(OtpModel model) async {
    try {
      Map<String, dynamic> result = await _apiServices.post(
        "/CL_Users/VerifyOtp",
        model.toJson(),
      );

      getSnackBar(
        title: "Otp Verification Success",
        message: result["message"] ?? "OTP verified successfully",
      );
    } catch (e) {
      // Handle different types of errors
      String errorMessage = e.toString();
      if (errorMessage.contains("Bad Request")) {
        getSnackBar(title: "Otp Verification Failed", message: "Invalid OTP");
      } else if (errorMessage.contains("Server Error")) {
        getSnackBar(title: "Server Error", message: "Please try again later");
      } else {
        getSnackBar(title: "Error", message: "OTP verification failed");
      }
      rethrow;
    }
  }

  bool jwtTokenValid(String token) {
    // Check if token expired
    return JwtDecoder.isExpired(token);
  }

  TokenModel? fetchInfoFromToken() {
    try {
      final prefs = Get.find<SharedPreferences>();
      String? token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token not found");
      }

      if (JwtDecoder.isExpired(token)) {
        logout();
      } else {
        Map<String, dynamic> data = JwtDecoder.decode(token);
        return TokenModel.fromJson(data);
      }
    } catch (e) {
      log('''::::fetchInfoFromToken:::::$e''');
    }
    return null;
  }

  void logout() {
    final SharedPreferences prefs = Get.find<SharedPreferences>();
    prefs.remove("token");
    Get.toNamed(NAV_LOGIN);
  }
}
