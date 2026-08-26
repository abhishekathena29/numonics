import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../state/app_state.dart';
import '../services/groq_service.dart';

class MathyScreen extends StatefulWidget {
  const MathyScreen({super.key});

  @override
  State<MathyScreen> createState() => _MathyScreenState();
}

class _MathyScreenState extends State<MathyScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _sendPrompt(String prompt) {
    _input.text = prompt;
    _send();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(ChatMessage(role: 'user', text: text));
      _messages.add(ChatMessage(role: 'assistant', text: ''));
      _sending = true;
      _input.clear();
    });
    _scrollToEnd();

    final config = await AppState.instance.groqConfig();
    if (config == null) {
      _finishWith(
        "I'm not connected yet. An admin needs to add the Groq API key and "
        "model to Firestore at config/groq (fields: apiKey, model).",
      );
      return;
    }

    final history = _messages
        .where((m) => m.text.isNotEmpty || m.role == 'user')
        .toList();

    final buffer = StringBuffer();
    try {
      await for (final delta in GroqService.instance
          .streamReply(config: config, history: history)) {
        buffer.write(delta);
        if (!mounted) return;
        setState(() {
          _messages[_messages.length - 1] =
              ChatMessage(role: 'assistant', text: buffer.toString());
        });
        _scrollToEnd();
      }
      if (buffer.isEmpty) {
        _finishWith("I didn't catch that — could you rephrase your question?");
      } else {
        setState(() => _sending = false);
      }
    } catch (e) {
      _finishWith('⚠️ $e');
    }
  }

  void _finishWith(String message) {
    if (!mounted) return;
    setState(() {
      _messages[_messages.length - 1] =
          ChatMessage(role: 'assistant', text: message);
      _sending = false;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Header(),
        Expanded(
          child: _messages.isEmpty
              ? _EmptyState(onPromptTap: _sendPrompt)
              : ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: _messages.length,
                  itemBuilder: (_, i) {
                    final m = _messages[i];
                    final typing = _sending &&
                        i == _messages.length - 1 &&
                        m.text.isEmpty;
                    return _Bubble(message: m, typing: typing);
                  },
                ),
        ),
        _Composer(
          controller: _input,
          sending: _sending,
          onSend: _send,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.stroke)),
      ),
      child: Row(
        children: [
          const MathyAvatar(size: 44),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mathy', style: AppText.h2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.mint, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text('Your AI math tutor',
                      style: AppText.label.copyWith(fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onPromptTap});
  final ValueChanged<String> onPromptTap;

  static const _prompts = [
    'Explain the Pythagorean theorem',
    'How do I add fractions?',
    'What is sin, cos and tan?',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 20),
      children: [
        const Center(child: MathyAvatar(size: 76)),
        const SizedBox(height: 20),
        const Text('Hi, I’m Mathy 👋',
            style: AppText.h1, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'Ask me anything about math and I’ll explain it step by step.',
          style: AppText.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text('Try asking', style: AppText.label),
        const SizedBox(height: 10),
        for (final p in _prompts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              onTap: () => onPromptTap(p),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(p, style: AppText.body.copyWith(color: AppColors.ink))),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.typing});
  final ChatMessage message;
  final bool typing;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.primaryTint,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: typing
            ? const _TypingDots()
            : _FormattedText(
                text: message.text,
                color: isUser ? Colors.white : AppColors.ink,
              ),
      ),
    );
  }
}

/// Renders chat text with lightweight markdown support (**bold** and
/// "- "/"* " bullet lines) since Mathy's replies sometimes include it even
/// though the system prompt asks for plain text.
class _FormattedText extends StatelessWidget {
  const _FormattedText({required this.text, required this.color});
  final String text;
  final Color color;

  static final _bulletPattern = RegExp(r'^\s*[-*]\s+(.*)');
  static final _boldPattern = RegExp(r'\*\*(.+?)\*\*');

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(color: color, fontSize: 15, height: 1.45);
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          _buildLine(lines[i], baseStyle),
        ],
      ],
    );
  }

  Widget _buildLine(String line, TextStyle baseStyle) {
    final bulletMatch = _bulletPattern.firstMatch(line);
    if (bulletMatch != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: baseStyle),
          Expanded(child: _richLine(bulletMatch.group(1)!, baseStyle)),
        ],
      );
    }
    return _richLine(line, baseStyle);
  }

  Widget _richLine(String line, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    var start = 0;
    for (final m in _boldPattern.allMatches(line)) {
      if (m.start > start) {
        spans.add(TextSpan(text: line.substring(start, m.start)));
      }
      spans.add(TextSpan(
        text: m.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      start = m.end;
    }
    if (start < line.length || spans.isEmpty) {
      spans.add(TextSpan(text: line.substring(start)));
    }
    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 16,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = (_c.value + i * 0.2) % 1.0;
              final o = 0.3 + 0.7 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Opacity(
                  opacity: o,
                  child: const CircleAvatar(
                      radius: 4, backgroundColor: AppColors.primary),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer(
      {required this.controller, required this.sending, required this.onSend});
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.stroke)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: const TextStyle(color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Ask Mathy a math question…',
                  hintStyle: const TextStyle(color: AppColors.inkFaint),
                  filled: true,
                  fillColor: AppColors.fill,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: sending ? null : onSend,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: sending ? AppColors.inkFaint : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(sending ? Icons.more_horiz : Icons.arrow_upward,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
