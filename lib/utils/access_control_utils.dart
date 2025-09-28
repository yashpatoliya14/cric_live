import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/tournament_view/user_role.dart';

/// Utility class for handling access control throughout the app
class AccessControlUtils {
  
  /// Show a standardized access denied message
  static void showAccessDeniedMessage({
    required String action,
    String? customMessage,
    UserRole? currentRole,
  }) {
    String message = customMessage ?? 
      "Your current role${currentRole != null ? ' (${currentRole.displayText})' : ''} doesn't allow this action.";
    
    Get.snackbar(
      "Access Denied - $action",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      icon: Icon(Icons.block, color: Colors.red),
      duration: Duration(seconds: 4),
      margin: EdgeInsets.all(16),
    );
  }

  /// Show a standardized success message
  static void showSuccessMessage({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
      icon: Icon(Icons.check_circle, color: Colors.green),
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(16),
    );
  }

  /// Show a standardized error message
  static void showErrorMessage({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      icon: Icon(Icons.error, color: Colors.red),
      duration: Duration(seconds: 4),
      margin: EdgeInsets.all(16),
    );
  }

  /// Show a standardized warning message
  static void showWarningMessage({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withOpacity(0.1),
      colorText: Colors.orange.shade700,
      icon: Icon(Icons.warning, color: Colors.orange.shade700),
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(16),
    );
  }

  /// Check access and show message if denied
  static bool checkAccessWithMessage({
    required String action,
    required bool hasAccess,
    String? deniedMessage,
    UserRole? currentRole,
  }) {
    if (!hasAccess) {
      showAccessDeniedMessage(
        action: action,
        customMessage: deniedMessage,
        currentRole: currentRole,
      );
    }
    return hasAccess;
  }

  /// Get appropriate color for user role
  static Color getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.host:
        return Colors.deepOrange;
      case UserRole.scorer:
        return Colors.green;
      case UserRole.viewer:
        return Colors.grey.shade600;
    }
  }

  /// Get appropriate icon for user role
  static IconData getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.host:
        return Icons.admin_panel_settings;
      case UserRole.scorer:
        return Icons.edit;
      case UserRole.viewer:
        return Icons.visibility;
    }
  }

  /// Get user-friendly description of what each role can do
  static String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.host:
        return "Can create, edit, delete, and control all matches in this tournament";
      case UserRole.scorer:
        return "Can create, edit, delete, and score matches in this tournament";
      case UserRole.viewer:
        return "Can view tournament details and match results";
    }
  }

  /// Show role information dialog
  static void showRoleInfoDialog({
    required UserRole currentRole,
    required String tournamentName,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              getRoleIcon(currentRole),
              color: getRoleColor(currentRole),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Your Role',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: getRoleColor(currentRole).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: getRoleColor(currentRole).withOpacity(0.3),
                ),
              ),
              child: Text(
                currentRole.displayText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: getRoleColor(currentRole),
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'In "$tournamentName":',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              getRoleDescription(currentRole),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}