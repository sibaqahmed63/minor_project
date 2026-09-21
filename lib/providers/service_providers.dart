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

/// Modern Notifier replacing legacy StateProvider for global relay override state
class RelayKilledOverrideNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setKilled(bool killed) => state = killed;
  void toggle() => state = !state;
}

final relayKilledOverrideProvider =
NotifierProvider<RelayKilledOverrideNotifier, bool>(RelayKilledOverrideNotifier.new);

/// Synchronized Notifier managing dead node IDs across Map and Simulation Lab views
class KilledNodesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void toggleNode(String nodeId) {
    if (state.contains(nodeId)) {
      state = Set.from(state)..remove(nodeId);
    } else {
      state = Set.from(state)..add(nodeId);
    }
  }

  void killNodes(Iterable<String> nodeIds) {
    state = Set.from(state)..addAll(nodeIds);
  }

  void restoreNodes(Iterable<String> nodeIds) {
    state = Set.from(state)..removeAll(nodeIds);
  }

  void clearAll() {
    state = {};
  }
}

final killedNodesProvider =
NotifierProvider<KilledNodesNotifier, Set<String>>(KilledNodesNotifier.new);