// lib/presentation/views/alerts/alerts_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import 'alerts_viewmodel.dart';

class AlertsView extends ConsumerWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(alertsViewModelProvider);
    final vm = ref.read(alertsViewModelProvider.notifier);

    return asyncState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('Alerts')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (state) {
        final alerts = state.filteredAlerts;

        return Scaffold(
          appBar: AppBar(
            title: const Text("System Alerts Feed"),
            actions: [
              IconButton(
                icon: const Icon(Icons.cleaning_services_rounded, size: 20),
                tooltip: "Clear Acknowledged Alerts",
                onPressed: () => vm.clearAcknowledgedAlerts(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => vm.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Summary Severity Counters Bar
                  Row(
                    children: [
                      _buildSummaryBadge(context, "CRITICAL", "${state.criticalCount}", Colors.red, () {
                        vm.setSeverityFilter(state.selectedSeverityFilter == AlertSeverity.critical ? null : AlertSeverity.critical);
                      }, state.selectedSeverityFilter == AlertSeverity.critical),
                      const SizedBox(width: 8),
                      _buildSummaryBadge(context, "WARNING", "${state.warningCount}", Colors.orange, () {
                        vm.setSeverityFilter(state.selectedSeverityFilter == AlertSeverity.warning ? null : AlertSeverity.warning);
                      }, state.selectedSeverityFilter == AlertSeverity.warning),
                      const SizedBox(width: 8),
                      _buildSummaryBadge(context, "INFO", "${state.infoCount}", Colors.blue, () {
                        vm.setSeverityFilter(state.selectedSeverityFilter == AlertSeverity.info ? null : AlertSeverity.info);
                      }, state.selectedSeverityFilter == AlertSeverity.info),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 2. Subnet Environment Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(context, "All Subnets", "all", state.selectedEnvironmentFilter, (env) => vm.setEnvironmentFilter(env)),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, "Agriculture", "agriculture", state.selectedEnvironmentFilter, (env) => vm.setEnvironmentFilter(env)),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, "Forest Canopy", "forest", state.selectedEnvironmentFilter, (env) => vm.setEnvironmentFilter(env)),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, "Disaster Hazard", "disaster", state.selectedEnvironmentFilter, (env) => vm.setEnvironmentFilter(env)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Alerts Feed List
                  if (alerts.isEmpty) ...[
                    const SizedBox(height: 60),
                    Center(
                      child: Column(
                        children: const [
                          Icon(Icons.check_circle_outline_rounded, size: 60, color: Colors.green),
                          SizedBox(height: 12),
                          Text("No Active Alerts", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text("All mesh subnets are running optimally.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: alerts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return _buildAlertCard(context, alert, () => vm.acknowledgeAlert(alert.id));
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryBadge(BuildContext context, String label, String count, Color color, VoidCallback onTap, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.25) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? color : color.withOpacity(0.3), width: isSelected ? 2.0 : 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color.withOpacity(0.9))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String envId, String selectedEnv, Function(String) onTap) {
    final isSelected = envId == selectedEnv;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: (_) => onTap(envId),
    );
  }

  Widget _buildAlertCard(BuildContext context, AlertItem alert, VoidCallback onAcknowledge) {
    Color borderAccent;
    IconData icon;

    switch (alert.severity) {
      case AlertSeverity.critical:
        borderAccent = Colors.red;
        icon = Icons.error_outline_rounded;
        break;
      case AlertSeverity.warning:
        borderAccent = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case AlertSeverity.info:
        borderAccent = AppColors.info;
        icon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: alert.isAcknowledged ? Theme.of(context).cardColor.withOpacity(0.5) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: alert.isAcknowledged ? Colors.grey.withOpacity(0.2) : borderAccent.withOpacity(0.6), width: 1.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: borderAccent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  alert.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    decoration: alert.isAcknowledged ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: borderAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  alert.environment.toUpperCase(),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: borderAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.message,
            style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.85)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(alert.timestamp),
                style: const TextStyle(fontSize: 10.5, color: Colors.grey),
              ),
              if (!alert.isAcknowledged)
                TextButton.icon(
                  onPressed: onAcknowledge,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  icon: const Icon(Icons.check_circle_outline, size: 14),
                  label: const Text("Acknowledge", style: TextStyle(fontSize: 11)),
                )
              else
                const Text("Acknowledged", style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}