import '../services/healthcare_chatbot_service.dart';
import 'base_chat_provider.dart';

class HealthCareChatProvider extends BaseChatProvider {
  HealthCareChatProvider() : super(chatbotService: HealthCareChatbotService());
}
