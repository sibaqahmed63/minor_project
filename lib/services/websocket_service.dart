import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final _streamController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get telemetryStream => _streamController.stream;

  void connect() {
    try {
      final host = kIsWeb || defaultTargetPlatform == TargetPlatform.windows
          ? 'localhost'
          : '10.0.2.2';
      final uri = Uri.parse('ws://$host:8765');

      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
            (data) {
          final decoded = jsonDecode(data as String) as Map<String, dynamic>;
          _streamController.add(decoded);
        },
        onError: (error) {
          debugPrint('[WS ERROR]: $error');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('[WS CLOSED]: Connection lost. Retrying...');
          _scheduleReconnect();
        },
      );
    } catch (e) {
      debugPrint('[WS EXCEPTION]: $e');
      _scheduleReconnect();
    }
  }

  void sendCommand(Map<String, dynamic> command) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(command));
    }
  }

  void _scheduleReconnect() {
    Future.delayed(const Duration(seconds: 3), () => connect());
  }

  void dispose() {
    _channel?.sink.close();
    _streamController.close();
  }
}

// --- RIVERPOD PROVIDERS ---

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  service.connect();
  ref.onDispose(() => service.dispose());
  return service;
});

final rawTelemetryStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.telemetryStream;
});