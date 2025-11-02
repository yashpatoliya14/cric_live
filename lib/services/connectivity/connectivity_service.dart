import 'package:cric_live/utils/import_exports.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  static ConnectivityService? _instance;
  ConnectivityService._internal();

  static ConnectivityService get instance {
    _instance ??= ConnectivityService._internal();
    return _instance!;
  }

  /// Temporary bypass flag for testing - set to true to skip connectivity checks
  static const bool _bypassConnectivityCheck = false;

  /// Check if device has active internet connection
  Future<bool> hasInternetConnection() async {
    // Temporary bypass for testing
    if (_bypassConnectivityCheck) {
      log('BYPASSING connectivity check for testing');
      return true;
    }
    // Method 1: Quick connectivity check
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      // If no connectivity at all, return false immediately
      if (connectivityResult == ConnectivityResult.none) {
        log('No network connectivity detected');
        return false;
      }

      log('Network connectivity detected: $connectivityResult');
    } catch (e) {
      log('Connectivity check error: $e');
      // Don't return false here, continue with other methods
    }

    // Method 2: Try multiple HTTP endpoints with shorter timeout
    final List<String> testUrls = [
      'https://www.google.com',
      'https://httpbin.org/status/200',
      'https://jsonplaceholder.typicode.com/posts/1',
    ];

    for (String url in testUrls) {
      try {
        final response = await http
            .get(
              Uri.parse(url),
              headers: {
                'User-Agent': 'CricLive/1.0',
                'Accept': 'text/html,application/json',
              },
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          log('HTTP request successful: $url - Status: ${response.statusCode}');
          return true;
        }
      } catch (e) {
        log('HTTP request failed for $url: $e');
        continue; // Try next URL
      }
    }

    // Method 3: Try DNS lookup as fallback
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 4));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        log('DNS lookup successful');
        return true;
      }
    } catch (e) {
      log('DNS lookup failed: $e');
    }

    // Method 4: Try socket connection with multiple servers
    final List<Map<String, dynamic>> socketTests = [
      {'host': '8.8.8.8', 'port': 53}, // Google DNS
      {'host': '1.1.1.1', 'port': 53}, // Cloudflare DNS
      {'host': 'google.com', 'port': 80}, // HTTP port
    ];

    for (var test in socketTests) {
      try {
        final socket = await Socket.connect(
          test['host'] as String,
          test['port'] as int,
          timeout: const Duration(seconds: 4),
        );
        socket.destroy();
        log('Socket connection successful: ${test['host']}:${test['port']}');
        return true;
      } catch (e) {
        log('Socket connection failed for ${test['host']}:${test['port']}: $e');
        continue; // Try next socket test
      }
    }

    log('All connectivity tests failed');
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
            onPressed: () => Get.back(result: false,closeOverlays: false),
            child: Text(
              "Cancel",
              style: GoogleFonts.nunito(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Get.back(result: true,closeOverlays: false),
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
    bool enableDebug = false,
  }) async {
    // Run debug if requested
    if (enableDebug) {
      await debugConnectivity();
    }

    bool hasConnection = await hasInternetConnection();

    if (hasConnection) {
      log('Internet connection confirmed');
      return true;
    }

    log('No internet connection detected, showing dialog');
    return await showInternetRequiredDialog(
      title: customTitle ?? "Internet Connection Required",
      message:
          customMessage ??
          "This action requires an active internet connection. Please check your connection and try again.",
      customAction: customAction,
    );
  }

  /// Debug function to test connectivity step by step
  Future<void> debugConnectivity() async {
    log('=== CONNECTIVITY DEBUG START ===');

    // Test 1: Basic connectivity check
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      log('Connectivity results: $connectivityResults');
    } catch (e) {
      log('Connectivity check error: $e');
    }

    // Test 2: HTTP requests
    final testUrls = [
      'https://www.google.com',
      'https://httpbin.org/status/200',
    ];
    for (String url in testUrls) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 3));
        log('HTTP $url: ${response.statusCode}');
      } catch (e) {
        log('HTTP $url failed: $e');
      }
    }

    // Test 3: DNS lookup
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 3));
      log('DNS lookup result: ${result.length} addresses');
    } catch (e) {
      log('DNS lookup error: $e');
    }

    // Test 4: Socket connections
    final socketTests = [
      {'host': '8.8.8.8', 'port': 53},
      {'host': '1.1.1.1', 'port': 53},
    ];
    for (var test in socketTests) {
      try {
        final socket = await Socket.connect(
          test['host'] as String,
          test['port'] as int,
          timeout: const Duration(seconds: 3),
        );
        socket.destroy();
        log('Socket ${test['host']}:${test['port']}: SUCCESS');
      } catch (e) {
        log('Socket ${test['host']}:${test['port']}: $e');
      }
    }

    log('=== CONNECTIVITY DEBUG END ===');
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
