import 'package:dialogflow_flutter/dialogflowFlutter.dart';
import 'package:dialogflow_flutter/language.dart';

import 'base_chatbot_service.dart';

class TrafficLawChatbotService extends BaseChatbotService {
  TrafficLawChatbotService({super.sessionId})
    : super(
        credentialPath: 'assets/traffic-law-credentials.json',
        language: Language.vietnamese.toString(),
      );

  @override
  Map<String, dynamic> processDialogflowResponse(AIResponse response) {
    final baseResponse = super.processDialogflowResponse(response);

    // Extract additional traffic law specific information
    final parameters = response.queryResult?.parameters;
    final intent = response.queryResult?.intent?.displayName ?? '';

    return {
      ...baseResponse,
      'confidence': 1.0, // Dialogflow Flutter doesn't provide confidence score
      'violationsFound': parameters?['violations']?.length ?? 0,
      'entities': parameters,
      'intent': intent,
    };
  }
}
