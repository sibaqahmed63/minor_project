// lib/presentation/views/home/home_viewmodel.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sensor_models.dart';
import '../../../providers/service_providers.dart';

/// Enhanced DTO holding environment telemetry & AI insights
class EnvironmentSummary {
  final String id; // 'agriculture', 'forest', 'disaster'
  final String name;
  final String metric1Label;
  final String metric1Value;
  final String metric1Unit;
  final String metric2Label;
  final String metric2Value;
  final String metric2Unit;
  final int activeAlerts;
  final Map<String, dynamic> aiAnalysis;
  final SensorModel? latestSensor;
  final DateTime lastUpdated;

  EnvironmentSummary({
    required this.id,
    required this.name,
    required this.metric1Label,
    required this.metric1Value,
    required this.metric1Unit,
    required this.metric2Label,
    required this.metric2Value,
    required this.metric2Unit,
    required this.activeAlerts,
    required this.aiAnalysis,
    this.latestSensor,
    required this.lastUpdated,
  });

  // FIX: Removed Future and async from copyWith
  EnvironmentSummary copyWith({
    String? id,
    String? name,
    String? metric1Label,
    String? metric1Value,
    String? metric1Unit,
    String? metric2Label,
    String? metric2Value,
    String? metric2Unit,
    int? activeAlerts,
    Map<String, dynamic>? aiAnalysis,
    SensorModel? latestSensor,
    DateTime? lastUpdated,
  }) {
    return EnvironmentSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      metric1Label: metric1Label ?? this.metric1Label,
      metric1Value: metric1Value ?? this.metric1Value,
      metric1Unit: metric1Unit ?? this.metric1Unit,
      metric2Label: metric2Label ?? this.metric2Label,
      metric2Value: metric2Value ?? this.metric2Value,
      metric2Unit: metric2Unit ?? this.metric2Unit,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      latestSensor: latestSensor ?? this.latestSensor,
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

/// AsyncNotifier ViewModel for Home screen wired to live WebSocket telemetry
class HomeNotifier extends AsyncNotifier<HomeState> {
  @override
  Future<HomeState> build() async {
    // Listen to live WebSocket telemetry stream
    ref.listen<AsyncValue<Map<String, dynamic>>>(
      telemetryStreamProvider,
          (previous, next) {
        next.whenData((data) {
          _handleIncomingTelemetry(data);
        });
      },
    );

    return HomeState(
      environments: _initialEnvironments(),
      selectedEnvironmentId: 'agriculture',
      loading: false,
    );
  }

  static List<EnvironmentSummary> _initialEnvironments() {
    final now = DateTime.now();
    return [
      EnvironmentSummary(
        id: 'agriculture',
        name: 'Agriculture Field A',
        metric1Label: 'Temperature',
        metric1Value: '29.8',
        metric1Unit: 'C',
        metric2Label: 'Soil moisture',
        metric2Value: '42.0',
        metric2Unit: '%',
        activeAlerts: 0,
        aiAnalysis: {},
        lastUpdated: now,
      ),
      EnvironmentSummary(
        id: 'forest',
        name: 'Forest Zone 3',
        metric1Label: 'Temperature',
        metric1Value: '24.3',
        metric1Unit: 'C',
        metric2Label: 'Smoke CO2',
        metric2Value: '410',
        metric2Unit: 'PPM',
        activeAlerts: 0,
        aiAnalysis: {},
        lastUpdated: now,
      ),
      EnvironmentSummary(
        id: 'disaster',
        name: 'Disaster Test Area',
        metric1Label: 'Flood Level',
        metric1Value: '0.0',
        metric1Unit: 'cm',
        metric2Label: 'Seismic',
        metric2Value: '0.02',
        metric2Unit: 'g',
        activeAlerts: 0,
        aiAnalysis: {},
        lastUpdated: now,
      ),
    ];
  }

  void _handleIncomingTelemetry(Map<String, dynamic> rawJson) {
    final current = state.value;
    if (current == null) return;

    final sensor = SensorModel.fromJson(rawJson);
    final envId = sensor.environment.toLowerCase();

    final updatedEnvironments = current.environments.map((env) {
      if (env.id == envId) {
        String m1Val = env.metric1Value;
        String m2Val = env.metric2Value;
        int alerts = 0;

        if (envId == 'agriculture') {
          m1Val = "${sensor.metrics['temperature'] ?? env.metric1Value}";
          m2Val = "${sensor.metrics['soil_moisture'] ?? env.metric2Value}";
          if ((sensor.metrics['soil_moisture'] as num? ?? 30) < 25) alerts++;
        } else if (envId == 'forest') {
          m1Val = "${sensor.metrics['temperature'] ?? env.metric1Value}";
          m2Val = "${sensor.metrics['smoke_co2_ppm'] ?? env.metric2Value}";
          if (sensor.metrics['flame_detected'] == true) alerts++;
        } else if (envId == 'disaster') {
          m1Val = "${sensor.metrics['flood_level_cm'] ?? env.metric1Value}";
          m2Val = "${sensor.metrics['seismic_vibration_g'] ?? env.metric2Value}";
          if ((sensor.metrics['flood_level_cm'] as num? ?? 0) > 100) alerts++;
        }

        return env.copyWith(
          metric1Value: m1Val,
          metric2Value: m2Val,
          activeAlerts: alerts,
          aiAnalysis: sensor.aiAnalysis,
          latestSensor: sensor,
          lastUpdated: DateTime.now(),
        );
      }
      return env;
    }).toList();

    state = AsyncData(current.copyWith(environments: updatedEnvironments));
  }

  void selectEnvironment(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedEnvironmentId: id));
  }

  Future<void> refresh() async {
    // Manual pull refresh trigger if required
  }
}

/// Main ViewModel provider
final homeViewModelProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);