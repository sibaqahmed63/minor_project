// lib/providers/service_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';

/// Provider for the singleton WebSocket service
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  service.connect();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream provider listening to live telemetry JSON packets from main_bridge.py
final telemetryStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.telemetryStream;
});