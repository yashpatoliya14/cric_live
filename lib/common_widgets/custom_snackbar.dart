import 'package:cric_live/utils/import_exports.dart';

enum AppSnackBarType { info, success, warning, error }

/// Unified app snackbar
void showAppSnackBar({
  required String title,
  required String message,
  AppSnackBarType type = AppSnackBarType.info,
  SnackPosition position = SnackPosition.BOTTOM,
  Duration? duration,
  EdgeInsets? margin,
  IconData? icon,
  Color? backgroundColor,
  Color? colorText,
}) {
  // Defaults per type
  Color baseColor;
  IconData defaultIcon;
  Duration defaultDuration;

  switch (type) {
    case AppSnackBarType.success:
      baseColor = Colors.green;
      defaultIcon = Icons.check_circle;
      defaultDuration = const Duration(seconds: 3);
      break;
    case AppSnackBarType.warning:
      baseColor = Colors.orange.shade700;
      defaultIcon = Icons.warning;
      defaultDuration = const Duration(seconds: 3);
      break;
    case AppSnackBarType.error:
      baseColor = Colors.red;
      defaultIcon = Icons.error;
      defaultDuration = const Duration(seconds: 4);
      break;
    case AppSnackBarType.info:
    default:
      baseColor = Colors.blue;
      defaultIcon = Icons.info_outline;
      defaultDuration = const Duration(seconds: 3);
  }

  Get.snackbar(
    title,
    message,
    snackPosition: position,
    backgroundColor: (backgroundColor ?? baseColor).withOpacity(0.1),
    colorText: colorText ?? baseColor,
    icon: Icon(icon ?? defaultIcon, color: colorText ?? baseColor),
    duration: duration ?? defaultDuration,
    margin: margin ?? const EdgeInsets.all(16),
  );
}

// Backward-compatible helper
dynamic getSnackBar({required String title, required String message}) {
  return showAppSnackBar(title: title, message: message);
}
