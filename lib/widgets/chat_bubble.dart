import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

class MessageBubble extends StatelessWidget {
  final GraminChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen width to calculate the max width.
    final screenWidth = MediaQuery.of(context).size.width;

    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser ? Colors.green[100] : Colors.grey[200];
    final txtColor = Colors.black87;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Set the max width to 75% of the screen width.
          maxWidth: screenWidth * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            message.text,
            style: TextStyle(fontSize: 16, color: txtColor),
          ),
        ),
      ),
    );
  }
}
