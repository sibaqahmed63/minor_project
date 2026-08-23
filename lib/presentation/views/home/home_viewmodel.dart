// lib/presentation/views/home/home_viewmodel.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple DTO for environment summary shown on Home
class EnvironmentSummary {
  final String id;
  final String name;
  final double avgTempC;
  final double avgSoilMoisturePct;
  final int activeAlerts;
  final DateTime lastUpdated;

  EnvironmentSummary({
    required this.id,
    required this.name,
    required this.avgTempC,
    required this.avgSoilMoisturePct,
    required this.activeAlerts,
    required this.lastUpdated,
  });

  EnvironmentSummary copyWith({
    String? id,
    String? name,
    double? avgTempC,
    double? avgSoilMoisturePct,
    int? activeAlerts,
    DateTime? lastUpdated,
  }) {
    return EnvironmentSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      avgTempC: avgTempC ?? this.avgTempC,
      avgSoilMoisturePct: avgSoilMoisturePct ?? this.avgSoilMoisturePct,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Home screen state container
class HomeState {
  final List<EnvironmentSummary> environments;
  final String selectedEnvironmentId;
  final bool loading;

  HomeState({
    required this.environments,
    required this.selectedEnvironmentId,
    required this.loading,
  });

  HomeState copyWith({
    List<EnvironmentSummary>? environments,
    String? selectedEnvironmentId,
    bool? loading,
  }) {
    return HomeState(
      environments: environments ?? this.environments,
      selectedEnvironmentId: selectedEnvironmentId ?? this.selectedEnvironmentId,
      loading: loading ?? this.loading,
    );
  }
}

/// AsyncNotifier-based ViewModel for Home screen
class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    // initial load (simulate small delay)
    await Future.delayed(const Duration(milliseconds: 120));
    final initial = HomeState(
      environments: _generateMockEnvironments(),
      selectedEnvironmentId: 'env_1',
      loading: false,
    );
    return initial;
  }

  static List<EnvironmentSummary> _generateMockEnvironments() {
    final now = DateTime.now();
    return [
      EnvironmentSummary(
        id: 'env_1',
        name: 'Agriculture Field A',
        avgTempC: 29.8,
        avgSoilMoisturePct: 42.0,
        activeAlerts: 1,
        lastUpdated: now.subtract(const Duration(minutes: 2)),
      ),
      EnvironmentSummary(
        id: 'env_2',
        name: 'Forest Zone 3',
        avgTempC: 24.3,
        avgSoilMoisturePct: 58.5,
        activeAlerts: 0,
        lastUpdated: now.subtract(const Duration(minutes: 5)),
      ),
      EnvironmentSummary(
        id: 'env_3',
        name: 'Disaster Test Area',
        avgTempC: 35.1,
        avgSoilMoisturePct: 18.2,
        activeAlerts: 3,
        lastUpdated: now.subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  /// Simulate refresh: update values with small random noise
  Future<void> refresh() async {
    // optimistic UI: set loading flag
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(loading: true));

    await Future.delayed(const Duration(milliseconds: 700));
    final rnd = Random();
    final updated = current.environments.map((e) {
      final tempNoise = (rnd.nextDouble() - 0.5) * 1.8;
      final moistureNoise = (rnd.nextDouble() - 0.5) * 4.0;
      final alertsNoise = rnd.nextInt(2); // 0 or 1
      return e.copyWith(
        avgTempC: double.parse((e.avgTempC + tempNoise).toStringAsFixed(1)),
        avgSoilMoisturePct: double.parse((e.avgSoilMoisturePct + moistureNoise).toStringAsFixed(1)),
        activeAlerts: (e.activeAlerts + alertsNoise).clamp(0, 9),
        lastUpdated: DateTime.now(),
      );
    }).toList();

    state = AsyncData(current.copyWith(environments: updated, loading: false));
  }

  void selectEnvironment(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedEnvironmentId: id));
  }

  EnvironmentSummary? get selectedEnvironment {
    final current = state.value;
    if (current == null) return null;
    return current.environments.firstWhere((e) => e.id == current.selectedEnvironmentId, orElse: () => current.environments.first);
  }
}

/// Provider for HomeNotifier using AsyncNotifier pattern
final homeViewModelProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
