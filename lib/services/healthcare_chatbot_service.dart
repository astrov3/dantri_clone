import 'base_chatbot_service.dart';

class HealthCareChatbotService extends BaseChatbotService {
  HealthCareChatbotService({super.sessionId})
    : super(
        baseUrl: 'https://legal-chatbot-gah7.onrender.com',
        endpoint: 'healthcare',
      );

  @override
  Future<Map<String, dynamic>> sendMessage(String message) async {
    final response = await super.sendMessage(message);
    print('Response: $response');
    return {
      'answer':
          response['answer'] ?? 'Xin lỗi, tôi không hiểu câu hỏi của bạn.',
      'confidence': response['confidence'] ?? 0.0,
      'healthAdvice': response['health_advice'],
      'nutritionInfo': response['nutrition_info'],
      'exerciseInfo': response['exercise_info'],
    };
  }
}
