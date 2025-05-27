import 'package:flutter/material.dart';

class News24hWidget extends StatelessWidget {
  const News24hWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin tức 24h'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Tin tức mới nhất sẽ được cập nhật tại đây.',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}