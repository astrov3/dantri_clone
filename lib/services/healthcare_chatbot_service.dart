import 'package:dialogflow_flutter/dialogflowFlutter.dart';
import 'package:dialogflow_flutter/language.dart';

import 'base_chatbot_service.dart';

class HealthCareChatbotService extends BaseChatbotService {
  HealthCareChatbotService({super.sessionId})
    : super(
        credentialPath: 'assets/health-care-credentials.json',
        language: Language.vietnamese.toString(),
      );

  @override
  Map<String, dynamic> processDialogflowResponse(AIResponse response) {
    final baseResponse = super.processDialogflowResponse(response);

    // Extract additional healthcare specific information
    final parameters = response.queryResult?.parameters;
    final intent = response.queryResult?.intent?.displayName ?? '';

    return {
      ...baseResponse,
      'confidence': 1.0, // Dialogflow Flutter doesn't provide confidence score
      'healthAdvice': parameters?['health_advice'],
      'nutritionInfo': parameters?['nutrition_info'],
      'exerciseInfo': parameters?['exercise_info'],
      'intent': intent,
    };
  }
}
