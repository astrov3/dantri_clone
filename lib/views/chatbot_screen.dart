import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chatbot')),
      body: Center(child: Text('Chatbot')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.home),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
