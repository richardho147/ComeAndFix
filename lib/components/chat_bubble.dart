import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool owner;
  const ChatBubble({super.key, required this.message, required this.owner});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: (owner)
            ? Color.fromARGB(255, 212, 190, 169)
            : Color.fromARGB(255, 124, 102, 89),
      ),
      child: Text(message,
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }
}
