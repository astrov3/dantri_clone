import '../services/traffic_law_chatbot_service.dart';
import 'base_chat_provider.dart';

class TrafficLawChatProvider extends BaseChatProvider {
  TrafficLawChatProvider() : super(chatbotService: TrafficLawChatbotService());
}
