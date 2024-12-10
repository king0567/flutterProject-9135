import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;

class HttpHelper {
  static String movieNightBaseUrl = 'https://movie-night-api.onrender.com';
  static String tmdbBaseUrl = 'https://api.themoviedb.org';
  static String tmdbKey =
      'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1MzlmZjNhYzY0NDA2Nzg0ZjAyZDM3OWE0YzJiYmU3YyIsIm5iZiI6MTcwODM2MDI0Ni42MTc5OTk4LCJzdWIiOiI2NWQzODIzNmEzMTNiODAxNGE2ZmE4MmIiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.C-Q7mxw6XbMwTzLuSi7hoJH_lI0MUMHirflKBTtvrS8';

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

  static voteMovie(String sessionId, int movieId, bool vote) async {
    var response = await http.get(Uri.parse(
        '$movieNightBaseUrl/vote-movie?session_id=$sessionId&movie_id=$movieId&vote=$vote'));

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

  static fetchMovies(int pageNumber) async {
    var response = await http.get(
        Uri.parse(
            '$tmdbBaseUrl/3/discover/movie?include_adult=false&include_video=false&language=en-US&page=$pageNumber&sort_by=popularity.desc'),
        headers: {
          'Authorization': tmdbKey,
          'Content-Type': 'application/json',
        });

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
}
