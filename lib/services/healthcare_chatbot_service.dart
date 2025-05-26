import 'package:dialogflow_flutter/language.dart';

import 'base_chatbot_service.dart';
import 'dialogflow_service.dart';

class HealthCareChatbotService extends BaseChatbotService {
  final DialogflowService _dialogflowService = DialogflowService(
    credentialPath: 'assets/health-care-credentials.json',
    language: Language.vietnamese,
  );

  HealthCareChatbotService({super.sessionId})
    : super(
        baseUrl: 'https://legal-chatbot-gah7.onrender.com',
        endpoint: 'healthcare',
      );

  @override
  Future<Map<String, dynamic>> sendMessage(String message) async {
    final aiResponse = await _dialogflowService.detectIntent(message);
    String botReply = aiResponse?.getMessage() ?? 'Xin lỗi, tôi không hiểu.';
    List<String> suggestions = [];
    Map<String, dynamic>? card;

    final fulfillmentMessages = aiResponse?.queryResult?.fulfillmentMessages;
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

    // Detect if this is a general conversation intent (greeting, thanks, goodbye, etc.)
    final intent = aiResponse?.queryResult?.intent?.displayName ?? '';
    final generalIntents = [
      'greeting',
      'goodbye',
      'thanks',
      'thanks_end'
          'smalltalk',
      'fallback',
    ];
    if (generalIntents.contains(intent)) {
      return {
        'answer': botReply,
        'suggestions': suggestions,
        'card': card,
        'source': 'dialogflow',
      };
    }

    // Otherwise, fallback to specialized service
    final response = await super.sendMessage(message);
    return {
      'answer':
          response['answer'] ?? 'Xin lỗi, tôi không hiểu câu hỏi của bạn.',
      'confidence': response['confidence'] ?? 0.0,
      'source': 'specialized',
      'healthAdvice': response['health_advice'],
      'nutritionInfo': response['nutrition_info'],
      'exerciseInfo': response['exercise_info'],
    };
  }

  @override
  Future<Map<String, dynamic>> sendWebhookMessage(String message) async {
    final response = await super.sendWebhookMessage(message);
    return response;
  }
}
