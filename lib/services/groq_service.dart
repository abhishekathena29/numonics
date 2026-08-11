import 'dart:convert';

import 'package:http/http.dart' as http;

import 'firebase_service.dart';

/// A single chat message in the Groq conversation format.
class ChatMessage {
  ChatMessage({required this.role, required this.text});
  final String role; // 'system' | 'user' | 'assistant'
  final String text;

  Map<String, String> toJson() => {'role': role, 'content': text};
}

class GroqException implements Exception {
  GroqException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Talks to Groq's OpenAI-compatible chat completions endpoint.
///
/// The API key and model name are supplied by [FirebaseService.fetchGroqConfig]
/// (stored in Firestore at `config/groq`) — nothing sensitive is hard-coded.
class GroqService {
  GroqService._();
  static final GroqService instance = GroqService._();

  static const _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static const systemPrompt =
      "You are Mathy, a friendly and encouraging math tutor inside the Numonics "
      "app. Explain math clearly and step by step, keep answers concise, and use "
      "simple language a student can follow. Use plain text (no markdown tables). "
      "When helpful, show the key formula and the working. Stay focused on math "
      "and learning.";

  /// Streams the assistant reply token-by-token. Yields incremental text
  /// deltas (append them to build the full message).
  Stream<String> streamReply({
    required GroqConfig config,
    required List<ChatMessage> history,
  }) async* {
    final request = http.Request('POST', Uri.parse(_endpoint))
      ..headers.addAll({
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
      })
      ..body = jsonEncode({
        'model': config.model,
        'stream': true,
        'temperature': 0.4,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...history.map((m) => m.toJson()),
        ],
      });

    final streamed = await http.Client().send(request);

    if (streamed.statusCode != 200) {
      final body = await streamed.stream.bytesToString();
      throw GroqException(_friendlyError(streamed.statusCode, body));
    }

    // Server-sent events: lines beginning with "data: ".
    await for (final line in streamed.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload.isEmpty) continue;
      if (payload == '[DONE]') break;
      try {
        final json = jsonDecode(payload) as Map<String, dynamic>;
        final choices = json['choices'] as List?;
        if (choices == null || choices.isEmpty) continue;
        final delta = (choices.first as Map)['delta'] as Map?;
        final content = delta?['content'] as String?;
        if (content != null && content.isNotEmpty) yield content;
      } catch (_) {
        // Ignore malformed keep-alive chunks.
      }
    }
  }

  String _friendlyError(int status, String body) {
    if (status == 401) {
      return "Mathy couldn't authenticate with Groq. Check the API key in "
          "Firestore (config/groq).";
    }
    if (status == 404) {
      return "The configured Groq model wasn't found. Check the model name in "
          "Firestore (config/groq).";
    }
    if (status == 429) {
      return "Mathy is being rate-limited by Groq. Try again in a moment.";
    }
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final msg = (json['error'] as Map?)?['message'] as String?;
      if (msg != null) return msg;
    } catch (_) {}
    return 'Groq request failed (HTTP $status).';
  }
}
