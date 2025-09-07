import 'package:cric_live/utils/import_exports.dart';

class ConnectivityService {
  static ConnectivityService? _instance;
  ConnectivityService._internal();

  static ConnectivityService get instance {
    _instance ??= ConnectivityService._internal();
    return _instance!;
  }

  /// Check if device has active internet connection
  Future<bool> hasInternetConnection() async {
    try {
      // Method 1: Try DNS lookup to Google
      final List<InternetAddress> result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (e) {
      log('DNS lookup failed: $e');
    }

    try {
      // Method 2: Try connecting to a reliable server
      final socket = await Socket.connect(
        '8.8.8.8',
        53,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      return true;
    } catch (e) {
      log('Socket connection failed: $e');
    }

    return false;
  }

  /// Show internet required dialog
  Future<bool> showInternetRequiredDialog({
    String title = "Internet Connection Required",
    String message =
        "This action requires an active internet connection. Please check your connection and try again.",
    String? customAction,
  }) async {
    bool? result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Check your Wi-Fi or mobile data connection",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              "Cancel",
              style: GoogleFonts.nunito(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Get.back(result: true),
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(
              customAction ?? "Retry",
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }

  /// Check internet and show dialog if no connection
  /// Returns true if internet is available or user chooses to retry
  Future<bool> checkInternetWithDialog({
    String? customTitle,
    String? customMessage,
    String? customAction,
  }) async {
    if (await hasInternetConnection()) {
      return true;
    }

    return await showInternetRequiredDialog(
      title: customTitle ?? "Internet Connection Required",
      message:
          customMessage ??
          "This action requires an active internet connection. Please check your connection and try again.",
      customAction: customAction,
    );
  }

  /// Show a snackbar for internet connection status
  void showConnectionStatus({required bool isConnected}) {
    Get.snackbar(
      isConnected ? "Connection Restored" : "No Internet Connection",
      isConnected
          ? "You're back online!"
          : "Please check your internet connection",
      backgroundColor: isConnected ? Colors.green : Colors.red,
      colorText: Colors.white,
      icon: Icon(
        isConnected ? Icons.wifi : Icons.wifi_off,
        color: Colors.white,
      ),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: isConnected ? 2 : 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}
