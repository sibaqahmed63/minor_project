// lib/presentation/views/simulation/simulation_viewmodel.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/service_providers.dart';

class SimNodeItem {
  final String id;
  final String label;
  final String environment;

  SimNodeItem({
    required this.id,
    required this.label,
    required this.environment,
  });
}

class SimulationState {
  final List<String> terminalLogs;
  final Set<String> killedNodeIds;
  final String selectedEnvironment;
  final double pdrPct;
  final int averageLatencyMs;
  final int currentHopCount;

  SimulationState({
    required this.terminalLogs,
    required this.killedNodeIds,
    required this.selectedEnvironment,
    required this.pdrPct,
    required this.averageLatencyMs,
    required this.currentHopCount,
  });

  bool isNodeKilled(String nodeId) => killedNodeIds.contains(nodeId);

  SimulationState copyWith({
    List<String>? terminalLogs,
    Set<String>? killedNodeIds,
    String? selectedEnvironment,
    double? pdrPct,
    int? averageLatencyMs,
    int? currentHopCount,
  }) {
    return SimulationState(
      terminalLogs: terminalLogs ?? this.terminalLogs,
      killedNodeIds: killedNodeIds ?? this.killedNodeIds,
      selectedEnvironment: selectedEnvironment ?? this.selectedEnvironment,
      pdrPct: pdrPct ?? this.pdrPct,
      averageLatencyMs: averageLatencyMs ?? this.averageLatencyMs,
      currentHopCount: currentHopCount ?? this.currentHopCount,
    );
  }
}

class SimulationNotifier extends AsyncNotifier<SimulationState> {
  static final Map<String, List<SimNodeItem>> envNodesMap = {
    'agriculture': [
      SimNodeItem(id: 'Agri_Node0', label: 'A0 (Source)', environment: 'agriculture'),
      SimNodeItem(id: 'Agri_Node1', label: 'A1 (North R1)', environment: 'agriculture'),
      SimNodeItem(id: 'Agri_Node2', label: 'A2 (Center R1)', environment: 'agriculture'),
      SimNodeItem(id: 'Agri_Node3', label: 'A3 (South R1)', environment: 'agriculture'),
      SimNodeItem(id: 'Agri_Node4', label: 'A4 (North R2)', environment: 'agriculture'),
      SimNodeItem(id: 'Agri_Node5', label: 'A5 (Center R2)', environment: 'agriculture'),
      SimNodeItem(id: 'Agri_Node6', label: 'A6 (South R2)', environment: 'agriculture'),
      SimNodeItem(id: 'Agri_Node7', label: 'A7 (Egress N)', environment: 'agriculture'),
      SimNodeItem(id: 'Agri_Node8', label: 'A8 (Egress S)', environment: 'agriculture'),
      SimNodeItem(id: 'Agri_GW',    label: 'AGW (Gateway)', environment: 'agriculture'),
    ],
    'forest': [
      SimNodeItem(id: 'Forest_Node10', label: 'F10 (Source)', environment: 'forest'),
      SimNodeItem(id: 'Forest_Node11', label: 'F11 (North R1)', environment: 'forest'),
      SimNodeItem(id: 'Forest_Node12', label: 'F12 (Center R1)', environment: 'forest'),
      SimNodeItem(id: 'Forest_Node13', label: 'F13 (South R1)', environment: 'forest'),
      SimNodeItem(id: 'Forest_Node14', label: 'F14 (North R2)', environment: 'forest'),
      SimNodeItem(id: 'Forest_Node15', label: 'F15 (Center R2)', environment: 'forest'),
      SimNodeItem(id: 'Forest_Node16', label: 'Forest Node 16 (South R2)', environment: 'forest'),
      SimNodeItem(id: 'Forest_Node17', label: 'Forest Node 17 (Egress N)', environment: 'forest'),
      SimNodeItem(id: 'Forest_Node18', label: 'Forest Node 18 (Egress S)', environment: 'forest'),
      SimNodeItem(id: 'Forest_GW',     label: 'Forest Gateway (Sink)', environment: 'forest'),
    ],
    'disaster': [
      SimNodeItem(id: 'Disaster_Node20', label: 'D20 (Source)', environment: 'disaster'),
      SimNodeItem(id: 'Disaster_Node21', label: 'D21 (North R1)', environment: 'disaster'),
      SimNodeItem(id: 'Disaster_Node22', label: 'D22 (Center R1)', environment: 'disaster'),
      SimNodeItem(id: 'Disaster_Node23', label: 'D23 (South R1)', environment: 'disaster'),
      SimNodeItem(id: 'Disaster_Node24', label: 'D24 (North R2)', environment: 'disaster'),
      SimNodeItem(id: 'Disaster_Node25', label: 'D25 (Center R2)', environment: 'disaster'),
      SimNodeItem(id: 'Disaster_Node26', label: 'D26 (South R2)', environment: 'disaster'),
      SimNodeItem(id: 'Disaster_Node27', label: 'D27 (Egress N)', environment: 'disaster'),
      SimNodeItem(id: 'Disaster_Node28', label: 'D28 (Egress S)', environment: 'disaster'),
      SimNodeItem(id: 'Disaster_GW',     label: 'DGW (Gateway)', environment: 'disaster'),
    ],
  };

  @override
  Future<SimulationState> build() async {
    final killedSet = ref.watch(killedNodesProvider);

    ref.listen<AsyncValue<Map<String, dynamic>>>(
      telemetryStreamProvider,
          (previous, next) {
        next.whenData((data) {
          _processTelemetryPacket(data);
        });
      },
    );

    final previousState = state.value;

    final stateCandidate = SimulationState(
      terminalLogs: previousState?.terminalLogs ?? [
        '[SYSTEM INITIALIZED] Synchronized Multi-Subnet AODV Stress Lab Active...'
      ],
      killedNodeIds: killedSet,
      selectedEnvironment: previousState?.selectedEnvironment ?? 'agriculture',
      pdrPct: 98.5,
      averageLatencyMs: 14,
      currentHopCount: 4,
    );

    return _recalculateMetrics(stateCandidate);
  }

  void selectEnvironment(String envId) {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(selectedEnvironment: envId);
    state = AsyncData(_recalculateMetrics(updated));
  }

  void toggleNodeState(String nodeId) {
    final current = state.value;
    if (current == null) return;

    final isKilling = !current.killedNodeIds.contains(nodeId);

    // Toggle in global shared Riverpod notifier
    ref.read(killedNodesProvider.notifier).toggleNode(nodeId);

    // Send WebSocket command to Python Bridge
    final wsService = ref.read(webSocketServiceProvider);
    wsService.sendCommand({
      'action': isKilling ? 'kill_node' : 'restore_node',
      'target': nodeId,
    });

    final actionLog = isKilling
        ? "[COMMAND SENT] Manual Failure Injected: Killed $nodeId"
        : "[COMMAND SENT] Manual Recovery Triggered: Restored $nodeId";

    final updatedLogs = List<String>.from(current.terminalLogs)..insert(0, actionLog);
    if (updatedLogs.length > 50) updatedLogs.removeLast();

    state = AsyncData(current.copyWith(terminalLogs: updatedLogs));
  }

  void killAllNodesInEnvironment() {
    final current = state.value;
    if (current == null) return;

    final nodes = envNodesMap[current.selectedEnvironment] ?? [];
    final targetIds = nodes.map((n) => n.id).toList();

    ref.read(killedNodesProvider.notifier).killNodes(targetIds);

    final wsService = ref.read(webSocketServiceProvider);
    for (var id in targetIds) {
      wsService.sendCommand({'action': 'kill_node', 'target': id});
    }

    final actionLog = "[BLACKOUT COMMAND] Killed all 10 nodes in ${current.selectedEnvironment.toUpperCase()} subnet";
    final updatedLogs = List<String>.from(current.terminalLogs)..insert(0, actionLog);

    state = AsyncData(current.copyWith(terminalLogs: updatedLogs));
  }

  void restoreAllNodesInEnvironment() {
    final current = state.value;
    if (current == null) return;

    final nodes = envNodesMap[current.selectedEnvironment] ?? [];
    final targetIds = nodes.map((n) => n.id).toList();

    ref.read(killedNodesProvider.notifier).restoreNodes(targetIds);

    final wsService = ref.read(webSocketServiceProvider);
    for (var id in targetIds) {
      wsService.sendCommand({'action': 'restore_node', 'target': id});
    }

    final actionLog = "[RECOVERY COMMAND] Restored all 10 nodes in ${current.selectedEnvironment.toUpperCase()} subnet";
    final updatedLogs = List<String>.from(current.terminalLogs)..insert(0, actionLog);

    state = AsyncData(current.copyWith(terminalLogs: updatedLogs));
  }

  void triggerAnomaly(String anomalyType) {
    final current = state.value;
    if (current == null) return;

    final wsService = ref.read(webSocketServiceProvider);
    wsService.sendCommand({
      'action': 'trigger_anomaly',
      'type': anomalyType,
      'environment': current.selectedEnvironment,
    });

    final updatedLogs = List<String>.from(current.terminalLogs)
      ..insert(0, "[AI STRESS TEST] Injected $anomalyType spike into ${current.selectedEnvironment.toUpperCase()} stream");

    state = AsyncData(current.copyWith(terminalLogs: updatedLogs));
  }

  void _processTelemetryPacket(Map<String, dynamic> data) {
    final current = state.value;
    if (current == null) return;

    final node = data['node'] ?? 'Unknown';
    final env = data['environment'] ?? 'general';
    final ts = (data['timestamp'] as num?)?.toDouble() ?? 0.0;

    final newLog = "[$ts s] [AODV RX] Telemetry packet from $node ($env) -> Delivered to Gateway";
    final logs = List<String>.from(current.terminalLogs)..insert(0, newLog);
    if (logs.length > 50) logs.removeLast();

    state = AsyncData(current.copyWith(terminalLogs: logs));
  }

  SimulationState _recalculateMetrics(SimulationState s) {
    final nodes = envNodesMap[s.selectedEnvironment] ?? [];
    final deadInEnv = nodes.where((n) => s.killedNodeIds.contains(n.id)).length;

    final gatewayId = nodes.last.id;
    final sourceId = nodes.first.id;

    final isGatewayDead = s.killedNodeIds.contains(gatewayId);
    final isSourceDead = s.killedNodeIds.contains(sourceId);

    if (isGatewayDead || isSourceDead || deadInEnv >= 8) {
      return s.copyWith(
        pdrPct: 0.0,
        averageLatencyMs: 0,
        currentHopCount: 0,
      );
    }

    final pdr = (98.5 - (deadInEnv * 11.2)).clamp(15.0, 98.5);
    final latency = 14 + (deadInEnv * 18);
    final hops = deadInEnv > 0 ? 5 : 4;

    return s.copyWith(
      pdrPct: double.parse(pdr.toStringAsFixed(1)),
      averageLatencyMs: latency,
      currentHopCount: hops,
    );
  }
}

final simulationViewModelProvider =
AsyncNotifierProvider<SimulationNotifier, SimulationState>(
    SimulationNotifier.new);