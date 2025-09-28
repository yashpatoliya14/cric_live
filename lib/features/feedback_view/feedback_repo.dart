import 'dart:convert';

import 'package:http/http.dart' as http;

class FeedbackRepository {
  // The API endpoint from the provided document
  final String _apiUrl =
      'https://api.aswdc.in/Api/MST_AppVersions/PostAppFeedback/AppPostFeedback';

  // The API key from the provided document
  final String _apiKey = '1234';

  /// Posts feedback data to the server.
  ///
  /// Takes a map of feedback data and returns true on success, false on failure.
  Future<bool> postFeedback(Map<String, String> feedbackData) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'API_KEY': _apiKey},
        body: feedbackData,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        // Assuming the API returns 'IsResult': 1 for success as per the doc
        if (responseBody['IsResult'] == 1) {
          print('Feedback submitted successfully: ${response.body}');
          return true;
        } else {
          print('API returned failure: ${responseBody['Message']}');
          return false;
        }
      } else {
        print('Server error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('An exception occurred while posting feedback: $e');
      return false;
    }
  }
}
