// ignore_for_file: camel_case_types

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class authService {
  static String serverBaseAdress = dotenv.env["SERVER_BASE_ADDRESS"] ?? "";
  static Future<void> login(String username, String password) async {
    try {
      final response = await http
          .get(Uri.parse(
              '$serverBaseAdress/api/authService/login?username=${username}&password=${password}'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString("access_token", response.body);
      } else {
        throw Exception('Error');
      }
    } on Exception catch (_) {
      print(_);
      throw Exception('Error');
    }
  }
}
