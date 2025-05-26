import 'base_chatbot_service.dart';

class TrafficLawChatbotService extends BaseChatbotService {
  TrafficLawChatbotService({super.sessionId})
    : super(
        baseUrl: 'https://legal-chatbot-gah7.onrender.com',
        endpoint: 'traffic-law',
      );

  @override
  Future<Map<String, dynamic>> sendMessage(String message) async {
    final response = await super.sendMessage(message);
    print('Response: $response');
    return {
      'answer':
          response['answer'] ?? 'Xin lỗi, tôi không hiểu câu hỏi của bạn.',
      'confidence': response['confidence'] ?? 0.0,
      'violationsFound': response['violations_found'] ?? 0,
      'entities': response['entities'],
    };
  }

  @override
  Future<Map<String, dynamic>> sendWebhookMessage(String message) async {
    final response = await super.sendWebhookMessage(message);
    print('Webhook Response: $response');
    return {
      'answer':
          response['answer'] ?? 'Xin lỗi, tôi không hiểu câu hỏi của bạn.',
      'confidence': response['confidence'] ?? 0.0,
      'violationsFound': response['violations_found'] ?? 0,
      'entities': response['entities'],
    };
  }
}
