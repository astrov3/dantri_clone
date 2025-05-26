import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../providers/healthcare_chat_provider.dart';
import '../utils/text_formatter.dart';

class HeathCareChatbotWidget extends StatefulWidget {
  const HeathCareChatbotWidget({super.key});

  @override
  State<HeathCareChatbotWidget> createState() => _HeathCareChatbotWidgetState();
}

class _HeathCareChatbotWidgetState extends State<HeathCareChatbotWidget> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _suggestedQuestions = [
    'Tôi bị đau đầu và sốt, có thể là bệnh gì?',
    'Cách phòng tránh bệnh cúm mùa?',
    'Chế độ ăn cho người tiểu đường?',
    'Các bài tập tốt cho tim mạch?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dantri AI Chat',
          style: TextStyle(
            color: Color(0xFF4CAF50),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF4CAF50)),
            onPressed: () {},
          ),
        ],
        iconTheme: const IconThemeData(color: Color(0xFF4CAF50)),
      ),
      body: Consumer<HealthCareChatProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      provider.messages.length +
                      (provider.messages.isEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (provider.messages.isEmpty) {
                      return _buildWelcomeMessage();
                    }
                    final message = provider.messages[index];
                    return _buildMessageBubble(message);
                  },
                ),
              ),
              if (provider.isLoading)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF4CAF50),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Đang tìm kiếm thông tin...',
                        style: TextStyle(color: Color(0xFF4CAF50)),
                      ),
                    ],
                  ),
                ),
              _buildInputArea(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tôi là Dantri AI Chat - trợ lý AI của báo Dân trí. Tôi có thể hỗ trợ bạn tra cứu thông tin bệnh.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF333333),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bạn có thể hỏi tôi về:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                ..._suggestedQuestions.map(
                  (question) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        _textController.text = question;
                        _sendMessage();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFF4CAF50)),
                        ),
                        child: Text(
                          question,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(14),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFE8F5E9) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isUser
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF4CAF50),
                  width: isUser ? 1 : 1.2,
                ),
                boxShadow: [
                  if (!isUser)
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: TextFormatter.parseFormattedText(message.text),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF333333),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(HealthCareChatProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFF4CAF50), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFF4CAF50)),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Nhập câu hỏi tại đây...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(
                    color: Color(0xFF4CAF50),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
              enabled: !provider.isLoading,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF4CAF50)),
            onPressed: provider.isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    _textController.clear();
    await context.read<HealthCareChatProvider>().sendMessage(message);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
