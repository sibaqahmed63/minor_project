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
  final Set<String> killedNodeIds;
  final String lastActiveNode;
  final double currentTimestamp;
  final String? selectedNodeId;

  MapState({
    required this.nodes,
    required this.killedNodeIds,
    required this.lastActiveNode,
    required this.currentTimestamp,
    this.selectedNodeId,
  });

  MapState copyWith({
    List<MapNode>? nodes,
    Set<String>? killedNodeIds,
    String? lastActiveNode,
    double? currentTimestamp,
    String? selectedNodeId,
  }) {
    return MapState(
      nodes: nodes ?? this.nodes,
      killedNodeIds: killedNodeIds ?? this.killedNodeIds,
      lastActiveNode: lastActiveNode ?? this.lastActiveNode,
      currentTimestamp: currentTimestamp ?? this.currentTimestamp,
      selectedNodeId: selectedNodeId ?? this.selectedNodeId,
    );
  }
}

class MapNotifier extends AsyncNotifier<MapState> {
  @override
  Future<MapState> build() async {
    // 1. Reactively watch shared killed nodes state
    final killedSet = ref.watch(killedNodesProvider);

    // 2. Listen to live WebSocket telemetry stream
    ref.listen<AsyncValue<Map<String, dynamic>>>(
      telemetryStreamProvider,
          (previous, next) {
        next.whenData((data) {
          _handleTelemetry(data);
        });
      },
    );

    final previousState = state.value;

    return MapState(
      nodes: _buildNodeList(killedSet),
      killedNodeIds: killedSet,
      lastActiveNode: previousState?.lastActiveNode ?? 'Agri_Node0',
      currentTimestamp: previousState?.currentTimestamp ?? 0.0,
      selectedNodeId: previousState?.selectedNodeId,
    );
  }

  static List<MapNode> _buildNodeList(Set<String> killedSet) {
    final now = DateTime.now();
    return [
      // --- AGRICULTURE 2D MESH ---
      MapNode(id: 'Agri_Node0', label: 'Agri Node 0 (Deep Source)', batteryPct: 95.0, online: !killedSet.contains('Agri_Node0'), environment: 'agriculture', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Agri_Node1', label: 'Agri Node 1 (North R1)', batteryPct: 91.0, online: !killedSet.contains('Agri_Node1'), environment: 'agriculture', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Agri_Node2', label: 'Agri Node 2 (Center R1)', batteryPct: 93.0, online: !killedSet.contains('Agri_Node2'), environment: 'agriculture', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Agri_Node3', label: 'Agri Node 3 (South R1)', batteryPct: 90.0, online: !killedSet.contains('Agri_Node3'), environment: 'agriculture', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Agri_Node4', label: 'Agri Node 4 (North R2)', batteryPct: 88.0, online: !killedSet.contains('Agri_Node4'), environment: 'agriculture', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Agri_Node5', label: 'Agri Node 5 (Center R2)', batteryPct: 92.0, online: !killedSet.contains('Agri_Node5'), environment: 'agriculture', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Agri_Node6', label: 'Agri Node 6 (South R2)', batteryPct: 89.0, online: !killedSet.contains('Agri_Node6'), environment: 'agriculture', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Agri_Node7', label: 'Agri Node 7 (Egress N)', batteryPct: 94.0, online: !killedSet.contains('Agri_Node7'), environment: 'agriculture', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Agri_Node8', label: 'Agri Node 8 (Egress S)', batteryPct: 87.0, online: !killedSet.contains('Agri_Node8'), environment: 'agriculture', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Agri_GW',    label: 'Agri Gateway (Sink)', batteryPct: 99.0, online: !killedSet.contains('Agri_GW'), environment: 'agriculture', lastSeen: now, lastMetrics: {}),

      // --- FOREST CANOPY 2D MESH ---
      MapNode(id: 'Forest_Node10', label: 'Forest Node 10 (Deep Source)', batteryPct: 89.0, online: !killedSet.contains('Forest_Node10'), environment: 'forest', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Forest_Node11', label: 'Forest Node 11 (North R1)', batteryPct: 92.0, online: !killedSet.contains('Forest_Node11'), environment: 'forest', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Forest_Node12', label: 'Forest Node 12 (Center R1)', batteryPct: 86.0, online: !killedSet.contains('Forest_Node12'), environment: 'forest', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Forest_Node13', label: 'Forest Node 13 (South R1)', batteryPct: 91.0, online: !killedSet.contains('Forest_Node13'), environment: 'forest', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Forest_Node14', label: 'Forest Node 14 (North R2)', batteryPct: 88.0, online: !killedSet.contains('Forest_Node14'), environment: 'forest', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Forest_Node15', label: 'Forest Node 15 (Center R2)', batteryPct: 90.0, online: !killedSet.contains('Forest_Node15'), environment: 'forest', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Forest_Node16', label: 'Forest Node 16 (South R2)', batteryPct: 85.0, online: !killedSet.contains('Forest_Node16'), environment: 'forest', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Forest_Node17', label: 'Forest Node 17 (Egress N)', batteryPct: 93.0, online: !killedSet.contains('Forest_Node17'), environment: 'forest', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Forest_Node18', label: 'Forest Node 18 (Egress S)', batteryPct: 87.0, online: !killedSet.contains('Forest_Node18'), environment: 'forest', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Forest_GW',     label: 'Forest Gateway (Sink)', batteryPct: 98.0, online: !killedSet.contains('Forest_GW'), environment: 'forest', lastSeen: now, lastMetrics: {}),

      // --- DISASTER HAZARD 2D MESH ---
      MapNode(id: 'Disaster_Node20', label: 'Disaster Node 20 (Deep Source)', batteryPct: 82.0, online: !killedSet.contains('Disaster_Node20'), environment: 'disaster', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Disaster_Node21', label: 'Disaster Node 21 (North R1)', batteryPct: 88.0, online: !killedSet.contains('Disaster_Node21'), environment: 'disaster', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Disaster_Node22', label: 'Disaster Node 22 (Center R1)', batteryPct: 84.0, online: !killedSet.contains('Disaster_Node22'), environment: 'disaster', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Disaster_Node23', label: 'Disaster Node 23 (South R1)', batteryPct: 86.0, online: !killedSet.contains('Disaster_Node23'), environment: 'disaster', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Disaster_Node24', label: 'Disaster Node 24 (North R2)', batteryPct: 81.0, online: !killedSet.contains('Disaster_Node24'), environment: 'disaster', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Disaster_Node25', label: 'Disaster Node 25 (Center R2)', batteryPct: 89.0, online: !killedSet.contains('Disaster_Node25'), environment: 'disaster', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Disaster_Node26', label: 'Disaster Node 26 (South R2)', batteryPct: 83.0, online: !killedSet.contains('Disaster_Node26'), environment: 'disaster', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Disaster_Node27', label: 'Disaster Node 27 (Egress N)', batteryPct: 91.0, online: !killedSet.contains('Disaster_Node27'), environment: 'disaster', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Disaster_Node28', label: 'Disaster Node 28 (Egress S)', batteryPct: 85.0, online: !killedSet.contains('Disaster_Node28'), environment: 'disaster', lastSeen: now, lastMetrics: {}),
      MapNode(id: 'Disaster_GW',     label: 'Disaster Gateway (Sink)', batteryPct: 97.0, online: !killedSet.contains('Disaster_GW'), environment: 'disaster', lastSeen: now, lastMetrics: {}),
    ];
  }

  void _handleTelemetry(Map<String, dynamic> rawJson) {
    final current = state.value;
    if (current == null) return;

    final sensor = SensorModel.fromJson(rawJson);
    final killedSet = ref.read(killedNodesProvider);

    final updatedNodes = current.nodes.map((n) {
      if (n.id == sensor.node) {
        return n.copyWith(
          online: !killedSet.contains(n.id),
          lastSeen: DateTime.now(),
          lastMetrics: sensor.metrics,
        );
      }
      return n;
    }).toList();

    state = AsyncData(current.copyWith(
      nodes: updatedNodes,
      lastActiveNode: sensor.node,
      currentTimestamp: sensor.timestamp,
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

  Future<void> refresh() async {}
}

final mapViewModelProvider =
AsyncNotifierProvider<MapNotifier, MapState>(MapNotifier.new);