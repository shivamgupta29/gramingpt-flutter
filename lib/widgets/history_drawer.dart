import 'package:flutter/material.dart';

class ConversationSummary {
  final String id;
  final String title;

  ConversationSummary({required this.id, required this.title});
}

class HistoryDrawer extends StatelessWidget {
  // A list of past conversations to display.
  final List<ConversationSummary> history;
  // Callback function to load a selected conversation.
  final Function(String conversationId) onLoadConversation;
  // Callback function to start a new chat.
  final VoidCallback onNewConversation;

  const HistoryDrawer({
    super.key,
    required this.history,
    required this.onLoadConversation,
    required this.onNewConversation,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green[700],
            ),
            child: const Text(
              'ग्रामीण GPT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Colors.green),
            title: const Text(
              'नई बातचीत शुरू करें', 
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Call the new chat callback.
              onNewConversation();
              Navigator.pop(context);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'पिछली बातचीत',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...history.map((summary) => ListTile(
                leading: const Icon(Icons.chat_bubble_outline_sharp),
                title: Text(summary.title),
                onTap: () {
                  // When tapped, call the callback function with the conversation's ID.
                  onLoadConversation(summary.id);
                  Navigator.pop(context); 
                },
              )),
        ],
      ),
    );
  }
}
