class ChatMessage {
  final String text;
  final bool isUser; // true: Ben, false: AI
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
}