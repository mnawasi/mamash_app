/// ChatMessage
/// A single message in the Mamash AI conversation — either something
/// the user typed, or something the AI replied with.
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  /// Converts to the {role, content} shape Anthropic's API expects,
  /// so a full conversation can be sent as message history.
  Map<String, String> toApiMessage() {
    return {
      'role': isUser ? 'user' : 'assistant',
      'content': text,
    };
  }
}
