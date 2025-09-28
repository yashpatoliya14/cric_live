import 'package:cric_live/utils/import_exports.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiServices {
  static ApiServices get to => Get.find();

  static const String baseUrl = "https://cric-live-backend.onrender.com/api";
  // static const String baseUrl = "https://10.159.105.147:5001/api";
  // static const String baseUrl = "https://localhost:5001/api";
  static const Duration _timeout = Duration(seconds: 30);

  // Create HTTP client that bypasses SSL certificate validation
  static http.Client _createHttpClient() {
    return http.Client();
  }

  // For development only - bypasses SSL certificate validation
  static HttpClient _createInsecureHttpClient() {
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    // Add more timeout and connection settings for better reliability
    client.connectionTimeout = _timeout;
    client.idleTimeout = _timeout;
    return client;
  }
  
  // Get appropriate HTTP client based on build mode
  static http.Client _getHttpClient() {
    // In release mode, use regular client; in debug mode, use insecure client
    if (kReleaseMode) {
      return _createHttpClient();
    } else {
      return IOClient(_createInsecureHttpClient());
    }
  }

  // Helper to check if status code indicates success
  bool _isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  // Private helper to handle the HTTP response.
  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
        // Success responses - return parsed JSON
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          // If response body is not JSON, return a wrapper
          return {
            'success': true,
            'statusCode': response.statusCode,
            'data': response.body,
          };
        }

      case 400:
        throw Exception("Bad Request: ${response.body}");

      case 401:
        throw Exception("Unauthorized: ${response.body}");

      case 404:
        throw Exception("Not Found: ${response.body}");

      case 500:
        throw Exception("Server Error: ${response.body}");

      default:
        throw Exception(
          "Unexpected Error [${response.statusCode}]: ${response.body}",
        );
    }
  }

  // Common headers for all requests.
  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    // 'Authorization': 'Bearer YOUR_TOKEN_HERE', // Add token if needed
  };

  // ------------------------- GET Request -------------------------
  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    print('=== API GET Request ===');
    print('URL: $uri');
    print('Endpoint: $endpoint');
    try {
      // Use appropriate client based on build mode
      final client = _getHttpClient();
      final response = await client
          .get(uri, headers: _headers)
          .timeout(_timeout);
      if (client is IOClient) {
        client.close();
      }
      print('Response Status: ${response.statusCode}');
      if (!_isSuccessStatusCode(response.statusCode)) {
        print('Response Body: ${response.body}');
        print('❌ API GET Failed: ${response.statusCode}');
      } else {
        print('✅ API GET Success: ${response.statusCode}');
      }
      return _handleResponse(response);
    } on SocketException {
      throw const SocketException('No Internet connection. Please try again.');
    } on HandshakeException {
      throw const HandshakeException(
        'SSL Handshake failed. Check your certificate.',
      );
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } on FormatException {
      throw const FormatException('Invalid data received from the server.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // ------------------------- POST Request -------------------------
  Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    print('=== API POST Request ===');
    print('URL: $uri');
    print('Data: $data');

    try {
      final client = _getHttpClient();
      final response = await client
          .post(uri, headers: _headers, body: jsonEncode(data))
          .timeout(_timeout);

      if (client is IOClient) {
        client.close();
      }
      return _handleResponse(response);
    } on SocketException {
      throw const SocketException('No Internet connection. Please try again.');
    } on HandshakeException {
      throw const HandshakeException(
        'SSL Handshake failed. Check your certificate.',
      );
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } on FormatException {
      throw const FormatException('Invalid data received from the server.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // ------------------------- PUT Request -------------------------
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    print('=== API PUT Request ===');
    print('URL: $uri');
    print('Data: $data');
    try {
      final client = _getHttpClient();
      final response = await client
          .put(uri, headers: _headers, body: jsonEncode(data))
          .timeout(_timeout);
      if (client is IOClient) {
        client.close();
      }
      print('Response Status: ${response.statusCode}');
      return _handleResponse(response);
    } on SocketException {
      throw const SocketException('No Internet connection. Please try again.');
    } on HandshakeException {
      throw const HandshakeException(
        'SSL Handshake failed. Check your certificate.',
      );
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } on FormatException {
      throw const FormatException('Invalid data received from the server.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // ------------------------- DELETE Request -------------------------
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    print('=== API DELETE Request ===');
    print('URL: $uri');
    try {
      final client = _getHttpClient();
      final response = await client
          .delete(uri, headers: _headers)
          .timeout(_timeout);
      if (client is IOClient) {
        client.close();
      }
      print('Response Status: ${response.statusCode}');
      return _handleResponse(response);
    } on SocketException {
      throw const SocketException('No Internet connection. Please try again.');
    } on HandshakeException {
      throw const HandshakeException(
        'SSL Handshake failed. Check your certificate.',
      );
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } on FormatException {
      throw const FormatException('Invalid data received from the server.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // ------------------------- External API POST Request -------------------------
  /// Makes POST request to external API (not using baseUrl)
  Future<Map<String, dynamic>> postExternal(
    String fullUrl,
    dynamic data,
  ) async {
    final uri = Uri.parse(fullUrl);
    print('=== External API POST Request ===');
    print('URL: $uri');
    print('Data: $data');

    try {
      final client = IOClient(_createInsecureHttpClient());
      final response = await client
          .post(uri, headers: _headers, body: jsonEncode(data))
          .timeout(_timeout);

      client.close();
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (!_isSuccessStatusCode(response.statusCode)) {
        print('❌ External API POST Failed: ${response.statusCode}');
      } else {
        print('✅ External API POST Success: ${response.statusCode}');
      }

      return _handleResponse(response);
    } on SocketException {
      throw const SocketException('No Internet connection. Please try again.');
    } on HandshakeException {
      throw const HandshakeException(
        'SSL Handshake failed. Check your certificate.',
      );
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } on FormatException {
      throw const FormatException('Invalid data received from the server.');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
