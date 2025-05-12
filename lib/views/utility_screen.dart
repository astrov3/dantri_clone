import 'package:flutter/material.dart';

class UtilityScreen extends StatelessWidget {
  const UtilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Utility'),
      ),
      body: Center(child: Text('Utility')),
    );
  }
}