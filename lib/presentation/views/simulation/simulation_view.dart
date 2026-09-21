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
        final activeEnvNodes = SimulationNotifier.envNodesMap[state.selectedEnvironment] ?? [];
        final deadCount = activeEnvNodes.where((n) => state.isNodeKilled(n.id)).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Simulation Stress Lab"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Network Health Gauges
                Row(
                  children: [
                    _buildGaugeCard(context, "PDR", "${state.pdrPct}%", Icons.speed, state.pdrPct > 70 ? Colors.green : Colors.red),
                    const SizedBox(width: 8),
                    _buildGaugeCard(context, "Latency", "${state.averageLatencyMs} ms", Icons.timer, AppColors.info),
                    const SizedBox(width: 8),
                    _buildGaugeCard(context, "Active Hops", "${state.currentHopCount} Hops", Icons.alt_route, AppColors.accentGold),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Environment Selector Tabs
                Text("Select Target Environment Subnet", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildEnvTab(context, "Agriculture", "agriculture", state.selectedEnvironment, () => vm.selectEnvironment("agriculture")),
                    const SizedBox(width: 8),
                    _buildEnvTab(context, "Forest Canopy", "forest", state.selectedEnvironment, () => vm.selectEnvironment("forest")),
                    const SizedBox(width: 8),
                    _buildEnvTab(context, "Disaster Hazard", "disaster", state.selectedEnvironment, () => vm.selectEnvironment("disaster")),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Interactive Multi-Node Failure Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Subnet Nodes ($deadCount/10 Offline)",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => vm.killAllNodesInEnvironment(),
                          child: const Text("Kill All", style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () => vm.restoreAllNodesInEnvironment(),
                          child: const Text("Restore All", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 10-Node Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: activeEnvNodes.length,
                  itemBuilder: (context, index) {
                    final item = activeEnvNodes[index];
                    final isKilled = state.isNodeKilled(item.id);

                    return InkWell(
                      onTap: () => vm.toggleNodeState(item.id),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isKilled ? Colors.red.withOpacity(0.15) : Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isKilled ? Colors.red : Colors.green,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isKilled ? Icons.flash_off_rounded : Icons.wifi_rounded,
                              size: 18,
                              color: isKilled ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                  Text(
                                    isKilled ? "OFFLINE" : "ONLINE",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isKilled ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 4. AI Anomaly Stress Injection
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

                // 5. Live Terminal Log Console
                Text("AODV Packet & Event Terminal Logs", style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 240,
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
                      final isError = log.contains("COMMAND") || log.contains("BLACKOUT") || log.contains("Killed");
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10.5,
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
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvTab(BuildContext context, String label, String envId, String selectedEnv, VoidCallback onTap) {
    final isSelected = envId == selectedEnv;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
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