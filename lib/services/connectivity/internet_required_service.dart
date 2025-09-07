import 'package:cric_live/utils/import_exports.dart';

/// Service to manage internet requirements for different app features
class InternetRequiredService {
  static const String _createMatchMessage =
      "Creating a match requires internet connection to sync with the server and ensure data consistency.";

  static const String _createTournamentMessage =
      "Creating a tournament requires internet connection to set up the tournament on the server.";

  static const String _loginMessage =
      "Login requires internet connection to authenticate with the server.";

  static const String _signupMessage =
      "Creating an account requires internet connection to register with the server.";

  static const String _otpMessage =
      "OTP verification requires internet connection to validate your code with the server.";

  static const String _syncMessage =
      "Syncing data requires internet connection to update information with the server.";

  /// Check internet for match creation
  static Future<bool> checkForMatchCreation() async {
    return await ConnectivityService.instance.checkInternetWithDialog(
      customTitle: "Internet Required - Create Match",
      customMessage: _createMatchMessage,
      customAction: "Try Again",
    );
  }

  /// Check internet for tournament creation
  static Future<bool> checkForTournamentCreation() async {
    return await ConnectivityService.instance.checkInternetWithDialog(
      customTitle: "Internet Required - Create Tournament",
      customMessage: _createTournamentMessage,
      customAction: "Try Again",
    );
  }

  /// Check internet for login
  static Future<bool> checkForLogin() async {
    return await ConnectivityService.instance.checkInternetWithDialog(
      customTitle: "Internet Required - Login",
      customMessage: _loginMessage,
      customAction: "Retry Login",
    );
  }

  /// Check internet for signup
  static Future<bool> checkForSignup() async {
    return await ConnectivityService.instance.checkInternetWithDialog(
      customTitle: "Internet Required - Create Account",
      customMessage: _signupMessage,
      customAction: "Retry Signup",
    );
  }

  /// Check internet for OTP verification
  static Future<bool> checkForOtpVerification() async {
    return await ConnectivityService.instance.checkInternetWithDialog(
      customTitle: "Internet Required - OTP Verification",
      customMessage: _otpMessage,
      customAction: "Retry Verification",
    );
  }

  /// Check internet for data sync
  static Future<bool> checkForSync() async {
    return await ConnectivityService.instance.checkInternetWithDialog(
      customTitle: "Internet Required - Sync Data",
      customMessage: _syncMessage,
      customAction: "Retry Sync",
    );
  }

  /// Check internet for forgot password
  static Future<bool> checkForForgotPassword() async {
    return await ConnectivityService.instance.checkInternetWithDialog(
      customTitle: "Internet Required - Reset Password",
      customMessage:
          "Resetting your password requires internet connection to send reset instructions.",
      customAction: "Try Again",
    );
  }

  /// Check internet for team creation
  static Future<bool> checkForTeamCreation() async {
    return await ConnectivityService.instance.checkInternetWithDialog(
      customTitle: "Internet Required - Create Team",
      customMessage:
          "Creating a team requires internet connection to save team information to the server.",
      customAction: "Try Again",
    );
  }

  /// Generic internet check with custom message
  static Future<bool> checkGeneric({
    required String feature,
    String? customMessage,
  }) async {
    return await ConnectivityService.instance.checkInternetWithDialog(
      customTitle: "Internet Required - $feature",
      customMessage:
          customMessage ??
          "This feature requires internet connection to work properly.",
      customAction: "Try Again",
    );
  }
}
