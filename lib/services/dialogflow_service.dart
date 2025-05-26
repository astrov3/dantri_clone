import 'package:dialogflow_flutter/dialogflowFlutter.dart';
import 'package:dialogflow_flutter/googleAuth.dart';

class DialogflowService {
  DialogFlow? _dialogflow;
  final String credentialPath;
  final String language;

  DialogflowService({
    required this.credentialPath,
    required this.language,
  });

  Future<void> initialize() async {
    try {
      final authGoogle = await AuthGoogle(fileJson: credentialPath).build();
      _dialogflow = DialogFlow(authGoogle: authGoogle, language: language);
    } catch (e) {
      print('Error initializing Dialogflow: $e');
    }
  }

  Future<AIResponse?> detectIntent(String text) async {
    if (_dialogflow == null) {
      await initialize();
    }
    try {
      return await _dialogflow?.detectIntent(text);
    } catch (e) {
      print('Error detecting intent: $e');
      return null;
    }
  }
}
