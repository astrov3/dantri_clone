import 'package:dialogflow_flutter/dialogflowFlutter.dart';
import 'package:dialogflow_flutter/googleAuth.dart';
import 'package:uuid/uuid.dart';

abstract class BaseChatbotService {
  final String sessionId;
  DialogFlow? _dialogflow;
  final String credentialPath;
  final String language;

  BaseChatbotService({
    required this.credentialPath,
    required this.language,
    String? sessionId,
  }) : sessionId = sessionId ?? const Uuid().v4();

  Future<void> initialize() async {
    try {
      final authGoogle = await AuthGoogle(fileJson: credentialPath).build();
      _dialogflow = DialogFlow(authGoogle: authGoogle, language: language);
    } catch (e) {
      print('Error initializing Dialogflow: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    if (_dialogflow == null) {
      await initialize();
    }
    try {
      final response = await _dialogflow?.detectIntent(message);
      if (response != null) {
        return processDialogflowResponse(response);
      }
      throw Exception('Failed to get response from Dialogflow');
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Map<String, dynamic> processDialogflowResponse(AIResponse response) {
    String botReply = response.getMessage() ?? 'Xin lỗi, tôi không hiểu.';
    List<String> suggestions = [];
    Map<String, dynamic>? card;

    final fulfillmentMessages = response.queryResult?.fulfillmentMessages;
    if (fulfillmentMessages != null) {
      for (var msg in fulfillmentMessages) {
        if (msg is Map<String, dynamic> && msg.containsKey('payload')) {
          final payload = msg['payload'];
          if (payload != null && payload['richContent'] != null) {
            final richContent = payload['richContent'] as List<dynamic>;
            for (var content in richContent) {
              for (var item in content) {
                if (item['type'] == 'text') {
                  botReply = item['text'] ?? '';
                }
                if (item['type'] == 'chips') {
                  suggestions.addAll(
                    (item['options'] as List)
                        .map((opt) => opt['text'].toString())
                        .toList(),
                  );
                } else if (item['type'] == 'card') {
                  card = item;
                }
              }
            }
          }
        }
      }
    }

    return {
      'answer': botReply,
      'suggestions': suggestions,
      'card': card,
      'source': 'dialogflow',
    };
  }
}
