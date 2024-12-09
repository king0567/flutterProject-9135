import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpHelper {
  static String movieNightBaseUrl = 'https://movie-night-api.onrender.com';

  static startSession(String? deviceId) async {
    var response = await http
        .get(Uri.parse('$movieNightBaseUrl/start-session?device_id=$deviceId'));

    if (response.statusCode == 200) {
      return {
        'success': true,
        'body': jsonDecode(response.body),
      };
    } else {
      return {
        'success': false,
        'message': 'Unexpected error. Please try again later.',
      };
    }
  }

  static joinSession(String? deviceId, String? code) async {
    var response = await http.get(Uri.parse(
        '$movieNightBaseUrl/join-session?device_id=$deviceId&code=$code'));

    if (response.statusCode == 200) {
      return {
        'success': true,
        'body': jsonDecode(response.body),
      };
    } else if (response.statusCode == 400) {
      final errorDetails = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorDetails['message'] ??
            'Invalid code. Please check and try again.',
      };
    } else {
      return {
        'success': false,
        'message': 'Unexpected error. Please try again later.',
      };
    }
  }
}
