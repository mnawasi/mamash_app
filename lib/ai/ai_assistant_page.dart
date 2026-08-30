import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_message.dart';
import 'offline_ai_service.dart';

class AIAssistantPage extends StatefulWidget {
  const AIAssistantPage({super.key});

  @override
  State<AIAssistantPage> createState() => _AIAssistantPageState();
}

class _AIAssistantPageState extends State<AIAssistantPage> {
  static const String _backendUrl =
      'https://muhammadnawasi--683d6c0aa3f211f19a96160.web.val.run';

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hi! I'm Mamash AI. Ask me about your transactions, "
          "bill payments, or how to use any feature in the app.",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isSending = true;
    });

    _messageController.clear();
    _scrollToBottom();

    String reply;
    try {
      reply = await _getAIReply();
    } catch (e) {
      reply = OfflineAIService.getResponse(text);
    }

    if (!mounted) return;

    setState(() {
      _messages.add(ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()));
      _isSending = false;
    });

    _scrollToBottom();
  }

  Future<String> _getAIReply() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Not signed in');
    }
    final idToken = await user.getIdToken();

    final recentHistory = _messages
        .sublist(_messages.length > 10 ? _messages.length - 10 : 0)
        .map((m) => m.toApiMessage())
        .toList();

    final response = await http
        .post(
          Uri.parse(_backendUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'idToken': idToken,
            'history': recentHistory,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Backend error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final reply = data['reply'] as String?;
    if (reply == null || reply.isEmpty) {
      throw Exception('Empty reply from backend');
    }
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Mamash AI"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isSending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: "Ask Mamash AI...",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
