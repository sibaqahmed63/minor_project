// lib/presentation/views/simulation/simulation_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import 'simulation_viewmodel.dart';

class SimulationView extends ConsumerWidget {
  const SimulationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(simulationViewModelProvider);
    final vm = ref.read(simulationViewModelProvider.notifier);

    return asyncState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('Simulation Lab')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Simulation Stress Lab"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Network Health Metrics Bar
                Row(
                  children: [
                    _buildGaugeCard(context, "PDR", "${state.pdrPct}%", Icons.speed, Colors.green),
                    const SizedBox(width: 8),
                    _buildGaugeCard(context, "Latency", "${state.averageLatencyMs} ms", Icons.timer, AppColors.info),
                    const SizedBox(width: 8),
                    _buildGaugeCard(context, "Hops", "${state.currentHopCount} Hops", Icons.alt_route, AppColors.accentGold),
                  ],
                ),
                const SizedBox(height: 20),

                // Manual Failure Override Button
                Text("Network Topology Controls", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.isRelayKilled ? Colors.green : Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => vm.toggleNodeFailure(),
                    icon: Icon(state.isRelayKilled ? Icons.play_arrow : Icons.flash_off),
                    label: Text(
                      state.isRelayKilled ? "RESTORE RELAY NODE 2" : "KILL RELAY NODE 2 (SIMULATE FAILURE)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // AI Anomaly Stress Injection
                Text("AI Anomaly Stress Injection", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildAnomalyChip(context, "🔥 Wildfire Spike", () => vm.triggerAnomaly("wildfire")),
                    _buildAnomalyChip(context, "🌧️ Flash Flood", () => vm.triggerAnomaly("flood")),
                    _buildAnomalyChip(context, "🌵 Crop Drought", () => vm.triggerAnomaly("drought")),
                  ],
                ),
                const SizedBox(height: 24),

                // Live Terminal Log Console
                Text("AODV Packet & Event Terminal Logs", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 260,
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF090D16),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: ListView.builder(
                    itemCount: state.terminalLogs.length,
                    itemBuilder: (context, index) {
                      final log = state.terminalLogs[index];
                      final isError = log.contains("COMMAND") || log.contains("STRESS");
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: isError ? AppColors.accentGold : Colors.greenAccent,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGaugeCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnomalyChip(BuildContext context, String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      onPressed: onTap,
    );
  }
}