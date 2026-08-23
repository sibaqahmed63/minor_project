// lib/presentation/views/map/map_viewmodel.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapNode {
  final String id;
  final String label;
  final double lat;
  final double lng;
  final double batteryPct;
  final bool online;
  final DateTime lastSeen;

  MapNode({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
    required this.batteryPct,
    required this.online,
    required this.lastSeen,
  });

  MapNode copyWith({
    String? id,
    String? label,
    double? lat,
    double? lng,
    double? batteryPct,
    bool? online,
    DateTime? lastSeen,
  }) {
    return MapNode(
      id: id ?? this.id,
      label: label ?? this.label,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      batteryPct: batteryPct ?? this.batteryPct,
      online: online ?? this.online,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

class MapState {
  final List<MapNode> nodes;
  final bool loading;
  final String? selectedNodeId;

  MapState({
    required this.nodes,
    required this.loading,
    this.selectedNodeId,
  });

  MapState copyWith({
    List<MapNode>? nodes,
    bool? loading,
    String? selectedNodeId,
  }) {
    return MapState(
      nodes: nodes ?? this.nodes,
      loading: loading ?? this.loading,
      selectedNodeId: selectedNodeId ?? this.selectedNodeId,
    );
  }
}

/// AsyncNotifier-based ViewModel for the Map screen
class MapNotifier extends AsyncNotifier<MapState> {
  @override
  Future<MapState> build() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return MapState(nodes: _generateMockNodes(), loading: false, selectedNodeId: null);
  }

  static List<MapNode> _generateMockNodes() {
    final now = DateTime.now();
    final rnd = Random(42);
    // generate 8 mock nodes around a center
    const baseLat = 26.2;
    const baseLng = 78.2;
    return List.generate(8, (i) {
      final lat = baseLat + (rnd.nextDouble() - 0.5) * 0.02;
      final lng = baseLng + (rnd.nextDouble() - 0.5) * 0.02;
      return MapNode(
        id: 'node_${i + 1}',
        label: 'Node ${i + 1}',
        lat: lat,
        lng: lng,
        batteryPct: 40 + rnd.nextDouble() * 60,
        online: rnd.nextBool(),
        lastSeen: now.subtract(Duration(minutes: rnd.nextInt(10))),
      );
    });
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(loading: true));
    await Future.delayed(const Duration(milliseconds: 700));
    final rnd = Random();
    final updated = current.nodes.map((n) {
      final batteryNoise = (rnd.nextDouble() - 0.5) * 6.0;
      return n.copyWith(
        batteryPct: (n.batteryPct + batteryNoise).clamp(0.0, 100.0),
        online: rnd.nextBool(),
        lastSeen: DateTime.now(),
      );
    }).toList();
    state = AsyncData(current.copyWith(nodes: updated, loading: false));
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
}

final mapViewModelProvider = AsyncNotifierProvider<MapNotifier, MapState>(MapNotifier.new);
