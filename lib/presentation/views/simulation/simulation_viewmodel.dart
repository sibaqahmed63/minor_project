// lib/presentation/views/simulation/simulation_viewmodel.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/service_providers.dart';

class SimulationState {
  final List<String> terminalLogs;
  final bool isRelayKilled;
  final double pdrPct; // Packet Delivery Ratio
  final int averageLatencyMs;
  final int currentHopCount;

  SimulationState({
    required this.terminalLogs,
    required this.isRelayKilled,
    required this.pdrPct,
    required this.averageLatencyMs,
    required this.currentHopCount,
  });

  SimulationState copyWith({
    List<String>? terminalLogs,
    bool? isRelayKilled,
    double? pdrPct,
    int? averageLatencyMs,
    int? currentHopCount,
  }) {
    return SimulationState(
      terminalLogs: terminalLogs ?? this.terminalLogs,
      isRelayKilled: isRelayKilled ?? this.isRelayKilled,
      pdrPct: pdrPct ?? this.pdrPct,
      averageLatencyMs: averageLatencyMs ?? this.averageLatencyMs,
      currentHopCount: currentHopCount ?? this.currentHopCount,
    );
  }
}

class SimulationNotifier extends AsyncNotifier<SimulationState> {
  @override
  Future<SimulationState> build() async {
    // Listen to live WebSocket stream to generate terminal logs & gauges
    ref.listen<AsyncValue<Map<String, dynamic>>>(
      telemetryStreamProvider,
          (previous, next) {
        next.whenData((data) {
          _processTelemetryPacket(data);
        });
      },
    );

    return SimulationState(
      terminalLogs: ['[SYSTEM INITIALIZED] AODV Mesh Network Listening on Port 8765...'],
      isRelayKilled: false,
      pdrPct: 98.5,
      averageLatencyMs: 14,
      currentHopCount: 2,
    );
  }

  void _processTelemetryPacket(Map<String, dynamic> data) {
    final current = state.value;
    if (current == null) return;

    final node = data['node'] ?? 'Unknown';
    final env = data['environment'] ?? 'general';
    final ts = (data['timestamp'] as num?)?.toDouble() ?? 0.0;

    final isKilled = (ts >= 30.0 && ts <= 60.0);

    final newLog = "[$ts s] [AODV RX] Packet from $node ($env) -> Delivered to Gateway Node 4";
    final logs = List<String>.from(current.terminalLogs)..insert(0, newLog);

    if (logs.length > 50) logs.removeLast(); // Keep console light

    state = AsyncData(current.copyWith(
      terminalLogs: logs,
      isRelayKilled: isKilled,
      pdrPct: isKilled ? 64.2 : 98.5,
      averageLatencyMs: isKilled ? 88 : 14,
      currentHopCount: isKilled ? 3 : 2,
    ));
  }

  void toggleNodeFailure() {
    final current = state.value;
    if (current == null) return;

    final newStatus = !current.isRelayKilled;
    final wsService = ref.read(webSocketServiceProvider);

    wsService.sendCommand({
      'action': newStatus ? 'kill_node' : 'restore_node',
      'target': 'Node_2',
    });

    final actionLog = newStatus
        ? "[COMMAND SENT] Manual Override: Kill Relay Node 2"
        : "[COMMAND SENT] Manual Override: Restore Relay Node 2";

    final updatedLogs = List<String>.from(current.terminalLogs)..insert(0, actionLog);

    state = AsyncData(current.copyWith(
      isRelayKilled: newStatus,
      terminalLogs: updatedLogs,
    ));
  }

  void triggerAnomaly(String anomalyType) {
    final current = state.value;
    if (current == null) return;

    final wsService = ref.read(webSocketServiceProvider);
    wsService.sendCommand({
      'action': 'trigger_anomaly',
      'type': anomalyType,
    });

    final updatedLogs = List<String>.from(current.terminalLogs)
      ..insert(0, "[AI STRESS TEST] Injected $anomalyType condition into telemetry stream");

    state = AsyncData(current.copyWith(terminalLogs: updatedLogs));
  }
}

final simulationViewModelProvider =
AsyncNotifierProvider<SimulationNotifier, SimulationState>(SimulationNotifier.new);