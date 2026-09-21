// lib/presentation/views/alerts/alerts_viewmodel.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sensor_models.dart';
import '../../../providers/service_providers.dart';

enum AlertSeverity { critical, warning, info }

class AlertItem {
  final String id;
  final String title;
  final String message;
  final String environment; // 'agriculture', 'forest', 'disaster', 'system'
  final String? nodeId;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isAcknowledged;

  AlertItem({
    required this.id,
    required this.title,
    required this.message,
    required this.environment,
    this.nodeId,
    required this.severity,
    required this.timestamp,
    this.isAcknowledged = false,
  });

  AlertItem copyWith({
    String? id,
    String? title,
    String? message,
    String? environment,
    String? nodeId,
    AlertSeverity? severity,
    DateTime? timestamp,
    bool? isAcknowledged,
  }) {
    return AlertItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      environment: environment ?? this.environment,
      nodeId: nodeId ?? this.nodeId,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
    );
  }
}

class AlertsState {
  final List<AlertItem> alerts;
  final String selectedEnvironmentFilter; // 'all', 'agriculture', 'forest', 'disaster'
  final AlertSeverity? selectedSeverityFilter;

  AlertsState({
    required this.alerts,
    required this.selectedEnvironmentFilter,
    this.selectedSeverityFilter,
  });

  List<AlertItem> get filteredAlerts {
    return alerts.where((a) {
      final matchesEnv = selectedEnvironmentFilter == 'all' ||
          a.environment.toLowerCase() == selectedEnvironmentFilter.toLowerCase();
      final matchesSev = selectedSeverityFilter == null || a.severity == selectedSeverityFilter;
      return matchesEnv && matchesSev;
    }).toList();
  }

  int get criticalCount => alerts.where((a) => a.severity == AlertSeverity.critical && !a.isAcknowledged).length;
  int get warningCount => alerts.where((a) => a.severity == AlertSeverity.warning && !a.isAcknowledged).length;
  int get infoCount => alerts.where((a) => a.severity == AlertSeverity.info && !a.isAcknowledged).length;

  AlertsState copyWith({
    List<AlertItem>? alerts,
    String? selectedEnvironmentFilter,
    AlertSeverity? selectedSeverityFilter,
    bool clearSeverityFilter = false,
  }) {
    return AlertsState(
      alerts: alerts ?? this.alerts,
      selectedEnvironmentFilter: selectedEnvironmentFilter ?? this.selectedEnvironmentFilter,
      selectedSeverityFilter: clearSeverityFilter ? null : (selectedSeverityFilter ?? this.selectedSeverityFilter),
    );
  }
}

class AlertsNotifier extends AsyncNotifier<AlertsState> {
  @override
  Future<AlertsState> build() async {
    // 1. Reactively watch dead node set to generate/resolve network failure alerts
    final killedSet = ref.watch(killedNodesProvider);

    // 2. Listen to live WebSocket telemetry stream for environmental anomalies
    ref.listen<AsyncValue<Map<String, dynamic>>>(
      telemetryStreamProvider,
          (previous, next) {
        next.whenData((data) {
          _evaluateTelemetryAlerts(data);
        });
      },
    );

    final previousAlerts = state.value?.alerts ?? [];
    final updatedAlerts = _syncNetworkNodeAlerts(previousAlerts, killedSet);

    return AlertsState(
      alerts: updatedAlerts,
      selectedEnvironmentFilter: 'all',
      selectedSeverityFilter: null,
    );
  }

  List<AlertItem> _syncNetworkNodeAlerts(List<AlertItem> currentAlerts, Set<String> killedSet) {
    final alertMap = {for (var a in currentAlerts) a.id: a};

    // Process killed nodes
    for (var nodeId in killedSet) {
      final alertId = 'node_dead_$nodeId';
      if (!alertMap.containsKey(alertId)) {
        final env = nodeId.startsWith('Agri')
            ? 'agriculture'
            : nodeId.startsWith('Forest')
            ? 'forest'
            : 'disaster';

        alertMap[alertId] = AlertItem(
          id: alertId,
          title: 'Node Down: $nodeId',
          message: 'Node $nodeId stopped responding. AODV self-healing local rerouting engaged.',
          environment: env,
          nodeId: nodeId,
          severity: AlertSeverity.critical,
          timestamp: DateTime.now(),
        );
      }
    }

    // Remove resolved node failures
    alertMap.removeWhere((id, alert) {
      if (id.startsWith('node_dead_')) {
        final nodeId = alert.nodeId;
        return nodeId != null && !killedSet.contains(nodeId);
      }
      return false;
    });

    final list = alertMap.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  void _evaluateTelemetryAlerts(Map<String, dynamic> rawJson) {
    final current = state.value;
    if (current == null) return;

    final sensor = SensorModel.fromJson(rawJson);
    final env = sensor.environment.toLowerCase();
    final m = sensor.metrics;
    final now = DateTime.now();

    final newAlerts = <AlertItem>[];

    // Agriculture anomaly checks
    if (env == 'agriculture') {
      final moisture = (m['soil_moisture'] as num?)?.toDouble();
      if (moisture != null && moisture < 20.0) {
        newAlerts.add(AlertItem(
          id: 'agri_drought_${sensor.node}',
          title: 'Severe Crop Moisture Deficit',
          message: 'Soil moisture dropped to ${moisture.toStringAsFixed(1)}% on ${sensor.node}. Irrigation recommended.',
          environment: 'agriculture',
          nodeId: sensor.node,
          severity: AlertSeverity.warning,
          timestamp: now,
        ));
      }
    }

    // Forest canopy fire checks
    if (env == 'forest') {
      final flame = m['flame_detected'] == true;
      final temp = (m['temperature'] as num?)?.toDouble() ?? 0.0;
      final co2 = (m['smoke_co2_ppm'] as num?)?.toInt() ?? 0;

      if (flame || temp > 42.0 || co2 > 650) {
        newAlerts.add(AlertItem(
          id: 'forest_fire_${sensor.node}',
          title: 'Wildfire Hazard Spiked',
          message: 'Critical thermal alert on ${sensor.node} (Temp: ${temp.toStringAsFixed(1)}°C, CO2: $co2 PPM).',
          environment: 'forest',
          nodeId: sensor.node,
          severity: AlertSeverity.critical,
          timestamp: now,
        ));
      }
    }

    // Disaster hazard checks
    if (env == 'disaster') {
      final flood = (m['flood_level_cm'] as num?)?.toDouble() ?? 0.0;
      final seismic = (m['seismic_vibration_g'] as num?)?.toDouble() ?? 0.0;

      if (flood > 90.0) {
        newAlerts.add(AlertItem(
          id: 'disaster_flood_${sensor.node}',
          title: 'Flash Flood Hazard Alert',
          message: 'Water level reached ${flood.toStringAsFixed(1)} cm on ${sensor.node}. Evacuation warning active.',
          environment: 'disaster',
          nodeId: sensor.node,
          severity: AlertSeverity.critical,
          timestamp: now,
        ));
      } else if (seismic > 0.15) {
        newAlerts.add(AlertItem(
          id: 'disaster_seismic_${sensor.node}',
          title: 'High Seismic Vibration Spike',
          message: 'Seismic tremor registered ${seismic.toStringAsFixed(3)}g on ${sensor.node}.',
          environment: 'disaster',
          nodeId: sensor.node,
          severity: AlertSeverity.warning,
          timestamp: now,
        ));
      }
    }

    if (newAlerts.isEmpty) return;

    final alertMap = {for (var a in current.alerts) a.id: a};
    for (var a in newAlerts) {
      alertMap[a.id] = a;
    }

    final updatedList = alertMap.values.toList();
    updatedList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    state = AsyncData(current.copyWith(alerts: updatedList));
  }

  void setEnvironmentFilter(String env) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(selectedEnvironmentFilter: env));
  }

  void setSeverityFilter(AlertSeverity? sev) {
    final current = state.value;
    if (current == null) return;
    if (sev == null) {
      state = AsyncData(current.copyWith(clearSeverityFilter: true));
    } else {
      state = AsyncData(current.copyWith(selectedSeverityFilter: sev));
    }
  }

  void acknowledgeAlert(String alertId) {
    final current = state.value;
    if (current == null) return;

    final updated = current.alerts.map((a) {
      if (a.id == alertId) return a.copyWith(isAcknowledged: true);
      return a;
    }).toList();

    state = AsyncData(current.copyWith(alerts: updated));
  }

  void clearAcknowledgedAlerts() {
    final current = state.value;
    if (current == null) return;

    final updated = current.alerts.where((a) => !a.isAcknowledged).toList();
    state = AsyncData(current.copyWith(alerts: updated));
  }

  Future<void> refresh() async {}
}

final alertsViewModelProvider =
AsyncNotifierProvider<AlertsNotifier, AlertsState>(AlertsNotifier.new);