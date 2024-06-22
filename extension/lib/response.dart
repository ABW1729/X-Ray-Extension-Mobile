import 'package:flutter/material.dart';

class Responsepage extends StatelessWidget {
  final String response;

  const Responsepage({Key? key, required this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Response Page'),
      ),
      body: Center(
        child: Text(response),
      ),
    );
  }
}
