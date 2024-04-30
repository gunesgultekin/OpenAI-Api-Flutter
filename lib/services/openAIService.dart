// ignore_for_file: unused_local_variable, unnecessary_brace_in_string_interps, prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class openAIService {
  static Future<String> speechToText(String filePath) async {
    try {
      OpenAI.apiKey = dotenv.env["API_KEY"] ?? "";
      OpenAIAudioModel transcription = await OpenAI.instance.audio
          .createTranscription(
              file: File(filePath),
              model: "whisper-1",
              responseFormat: OpenAIAudioResponseFormat.text);
      return transcription.text;
    } on Exception catch (_) {
      throw Exception(_);
    }
  }

  static Future<http.Response> chatbot_response(String prompt) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? access_token = preferences.getString("access_token");
      String? formatted_token = access_token?.replaceAll('"', '');

      var url =
          "${dotenv.env["SERVER_BASE_ADDRESS"] ?? ""}/api/openAiServices/chat?prompt=${prompt}";

      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${formatted_token}'
      }).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Error');
      }
    } on Exception catch (_) {
      throw Exception('Error');
    }
  }

  static Future<http.Response> imageGen_response(String prompt) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? access_token = preferences.getString("access_token");
      String? formatted_token = access_token?.replaceAll('"', '');

      var url =
          "${dotenv.env["SERVER_BASE_ADDRESS"] ?? ""}/api/openAiServices/image?prompt=${prompt}";

      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ${formatted_token}'
      }).timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Error');
      }
    } on Exception catch (_) {
      throw Exception('Error');
    }
  }
}
