import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../widgets/linen_background.dart';
import '../services/api_service.dart';
import '../services/sse_client.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  const ChatMessage({required this.text, required this.isUser});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messages = <ChatMessage>[
    const ChatMessage(
      text: "Namaste! I'm your Virasat guide. Ask me anything about India's monuments, heritage, or history.",
      isUser: false,
    ),
  ];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;
  final _api = ApiService();
  final List<Map<String, String>> _history = [];
  SseClient? _sseClient;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _sseClient?.cancel();
    _api.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _history.add({'role': 'user', 'content': text});
    _controller.clear();
    _scrollToBottom();

    final body = _api.chatRequestBody(text, null, _history);
    final url = _api.chatUrl();

    _sseClient?.cancel();
    _sseClient = SseClient(
      url: url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    String botReply = '';
    _sseClient!.stream().listen(
      (event) {
        try {
          final data = jsonDecode(event.data) as Map<String, dynamic>;
          if (data.containsKey('error')) {
            botReply = 'Error: ${data['error']}';
            return;
          }
          final content = data['content'] as String? ?? '';
          botReply += content;
          setState(() {
            if (_messages.isNotEmpty &&
                !_messages.last.isUser &&
                _messages.last.text != botReply) {
              _messages.removeLast();
            }
            if (_messages.isEmpty || _messages.last.isUser) {
              _messages.add(ChatMessage(text: botReply, isUser: false));
            } else {
              _messages.last = ChatMessage(text: botReply, isUser: false);
            }
          });
          _scrollToBottom();
        } catch (_) {}
      },
      onError: (error) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: 'Sorry, I encountered an error. Please try again.',
            isUser: false,
          ));
        });
        _scrollToBottom();
      },
      onDone: () {
        if (botReply.isNotEmpty) {
          _history.add({'role': 'assistant', 'content': botReply});
        }
        if (mounted) setState(() => _isTyping = false);
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LinenBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildDivider(),
              Expanded(child: _buildMessageList()),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 22,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AI Chatbot', style: AppTypography.screenTitle),
              Text(
                'चैटबॉट',
                style: AppTypography.devanagariSubtitle(size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 3,
      decoration: AppDecorations.tricolorDivider,
      width: double.infinity,
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _TypingIndicator();
        }
        final msg = _messages[index];
        return _ChatBubble(message: msg);
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        boxShadow: [
          BoxShadow(
            color: AppColors.warmShadow,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Ask about India\'s heritage...',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.inter,
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.chat_bubble_outline,
                  size: 22,
                  color: AppColors.gold,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: AppColors.textMuted,
                        onPressed: () => _controller.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _controller.text.trim().isNotEmpty ? _sendMessage : null,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _controller.text.trim().isNotEmpty
                    ? AppColors.gold
                    : AppColors.border,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.send_rounded,
                size: 22,
                color: _controller.text.trim().isNotEmpty
                    ? AppColors.darkBase
                    : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) _botAvatar(),
          if (!message.isUser) const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.gold.withValues(alpha: 0.12)
                    : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(
                  message.isUser ? 20 : 20,
                ),
                border: message.isUser
                    ? null
                    : const Border(
                        left: BorderSide(
                          color: AppColors.gold,
                          width: 3,
                        ),
                      ),
                boxShadow: message.isUser
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.warmShadow,
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                message.text,
                style: AppTypography.body.copyWith(
                  fontSize: 14,
                  height: 1.5,
                  color: message.isUser
                      ? AppColors.darkBase
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 10),
          if (message.isUser) _userAvatar(),
        ],
      ),
    );
  }

  Widget _botAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.smart_toy_outlined,
        size: 18,
        color: AppColors.gold,
      ),
    );
  }

  Widget _userAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.terracotta.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.person_outline,
        size: 18,
        color: AppColors.terracotta,
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 18,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: const Border(
                left: BorderSide(color: AppColors.gold, width: 3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warmShadow,
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final delay = i * 0.15;
                    final t =
                        (_controller.value - delay).clamp(0.0, 1.0);
                    final size = 6 + 4 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        width: size,
                        height: size,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textMuted,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
