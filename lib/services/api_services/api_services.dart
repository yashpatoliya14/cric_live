import 'package:cric_live/utils/import_exports.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  static ApiServices get to => Get.find();

  static const String baseUrl = "https://192.168.85.147:5001/api";
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
    return client;
  }

  // Private helper to handle the HTTP response.
  Response _handleResponse(http.Response response) {
    return response;
  }

  // Common headers for all requests.
  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    // 'Authorization': 'Bearer YOUR_TOKEN_HERE', // Add token if needed
  };

  // ------------------------- GET Request -------------------------
  Future<Response> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    print('=== API GET Request ===');
    print('URL: $uri');
    print('Endpoint: $endpoint');
    try {
      // Use insecure client for development
      final client = IOClient(_createInsecureHttpClient());
      final response = await client.get(uri, headers: _headers);
      client.close();
      print('Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
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
  Future<Response> post(String endpoint, dynamic data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    print('=== API POST Request ===');
    print('URL: $uri');
    print('Data: $data');

    try {
      final client = IOClient(_createInsecureHttpClient());
      final response = await client
          .post(uri, headers: _headers, body: jsonEncode(data))
          .timeout(_timeout);

      client.close();
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
  Future<Response> put(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final client = IOClient(_createInsecureHttpClient());
      final response = await client.put(
        uri,
        headers: _headers,
        body: jsonEncode(data),
      );
      client.close();
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
  Future<Response> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final client = IOClient(_createInsecureHttpClient());
      final response = await client.delete(uri, headers: _headers);
      client.close();
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
