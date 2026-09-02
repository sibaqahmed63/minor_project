// lib/presentation/views/map/map_viewmodel.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sensor_models.dart';
import '../../../providers/service_providers.dart';

class MapNode {
  final String id;
  final String label;
  final double batteryPct;
  final bool online;
  final String environment;
  final DateTime lastSeen;
  final Map<String, dynamic> lastMetrics;

  MapNode({
    required this.id,
    required this.label,
    required this.batteryPct,
    required this.online,
    required this.environment,
    required this.lastSeen,
    required this.lastMetrics,
  });

  MapNode copyWith({
    String? id,
    String? label,
    double? batteryPct,
    bool? online,
    String? environment,
    DateTime? lastSeen,
    Map<String, dynamic>? lastMetrics,
  }) {
    return MapNode(
      id: id ?? this.id,
      label: label ?? this.label,
      batteryPct: batteryPct ?? this.batteryPct,
      online: online ?? this.online,
      environment: environment ?? this.environment,
      lastSeen: lastSeen ?? this.lastSeen,
      lastMetrics: lastMetrics ?? this.lastMetrics,
    );
  }
}

class MapState {
  final List<MapNode> nodes;
  final bool isRelayAlive;
  final String lastActiveNode;
  final double currentTimestamp;
  final String? selectedNodeId;

  MapState({
    required this.nodes,
    required this.isRelayAlive,
    required this.lastActiveNode,
    required this.currentTimestamp,
    this.selectedNodeId,
  });

  MapState copyWith({
    List<MapNode>? nodes,
    bool? isRelayAlive,
    String? lastActiveNode,
    double? currentTimestamp,
    String? selectedNodeId,
  }) {
    return MapState(
      nodes: nodes ?? this.nodes,
      isRelayAlive: isRelayAlive ?? this.isRelayAlive,
      lastActiveNode: lastActiveNode ?? this.lastActiveNode,
      currentTimestamp: currentTimestamp ?? this.currentTimestamp,
      selectedNodeId: selectedNodeId ?? this.selectedNodeId,
    );
  }
}

class MapNotifier extends AsyncNotifier<MapState> {
  @override
  Future<MapState> build() async {
    // Listen to live WebSocket stream
    ref.listen<AsyncValue<Map<String, dynamic>>>(
      telemetryStreamProvider,
          (previous, next) {
        next.whenData((data) {
          _handleTelemetry(data);
        });
      },
    );

    return MapState(
      nodes: _initialNodes(),
      isRelayAlive: true,
      lastActiveNode: 'Agri_Node0',
      currentTimestamp: 0.0,
      selectedNodeId: null,
    );
  }

  static List<MapNode> _initialNodes() {
    final now = DateTime.now();
    return [
      MapNode(id: 'node_0', label: 'Node 0 (Agri)', batteryPct: 92.0, online: true, environment: 'agriculture', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'node_1', label: 'Node 1 (Forest)', batteryPct: 88.0, online: true, environment: 'forest', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'node_2', label: 'Node 2 (Relay)', batteryPct: 95.0, online: true, environment: 'relay', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'node_3', label: 'Node 3 (Disaster)', batteryPct: 84.0, online: true, environment: 'disaster', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'node_4', label: 'Node 4 (Gateway)', batteryPct: 99.0, online: true, environment: 'gateway', lastSeen: now, lastMetrics: {}),
    ];
  }

  void _handleTelemetry(Map<String, dynamic> rawJson) {
    final current = state.value;
    if (current == null) return;

    final sensor = SensorModel.fromJson(rawJson);
    final ts = sensor.timestamp;

    // Relay Node 2 is killed between 30.0s and 60.0s in NS-3
    final isRelayOnline = !(ts >= 30.0 && ts <= 60.0);

    final updatedNodes = current.nodes.map((n) {
      if (n.id == 'node_2') {
        return n.copyWith(online: isRelayOnline, lastSeen: DateTime.now());
      }
      if (n.environment.toLowerCase() == sensor.environment.toLowerCase()) {
        return n.copyWith(
          online: true,
          lastSeen: DateTime.now(),
          lastMetrics: sensor.metrics,
        );
      }
      return n;
    }).toList();

    state = AsyncData(current.copyWith(
      nodes: updatedNodes,
      isRelayAlive: isRelayOnline,
      lastActiveNode: sensor.node,
      currentTimestamp: ts,
    ));
  }

  void selectNode(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedNodeId: id));
  }

  void clearSelection() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedNodeId: null));
  }

  Future<void> refresh() async {
    // Stream refreshes automatically over WebSocket
  }
}

final mapViewModelProvider = AsyncNotifierProvider<MapNotifier, MapState>(MapNotifier.new);