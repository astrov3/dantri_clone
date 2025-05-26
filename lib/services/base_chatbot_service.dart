import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

abstract class BaseChatbotService {
  final String sessionId;
  final String baseUrl;
  final String endpoint;

  BaseChatbotService({
    required this.baseUrl,
    required this.endpoint,
    String? sessionId,
  }) : sessionId = sessionId ?? const Uuid().v4();

  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<Map<String, dynamic>> sendWebhookMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint/webhook'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId, 'message': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to send webhook message: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error sending webhook message: $e');
    }
  }
}
