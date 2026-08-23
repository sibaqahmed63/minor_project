// lib/presentation/views/map/map_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'map_viewmodel.dart';

class MapView extends ConsumerWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(mapViewModelProvider);
    final vm = ref.read(mapViewModelProvider.notifier);

    return asyncState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(appBar: AppBar(title: const Text('Map')), body: Center(child: Text('Error: $e'))),
      data: (state) {
        final nodes = state.nodes;
        final selected = state.selectedNodeId == null ? null : nodes.firstWhere((n) => n.id == state.selectedNodeId, orElse: () => nodes.first);

        return Scaffold(
          appBar: AppBar(title: const Text('Map')),
          body: RefreshIndicator(
            onRefresh: () => vm.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder map area (replace with real map widget later)
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Center(
                      child: Text('Map placeholder\n(Integrate Google Maps / flutter_map here)', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Node summary strip
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: nodes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final node = nodes[i];
                        final isSelected = node.id == state.selectedNodeId;
                        return GestureDetector(
                          onTap: () => vm.selectNode(node.id),
                          child: Container(
                            width: 180,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.device_hub, size: 18, color: node.online ? Colors.green : Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(node.label, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Battery: ${node.batteryPct.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodySmall),
                                Text('Last: ${_formatAgo(node.lastSeen)}', style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Selected node details
                  if (selected != null) ...[
                    Text('Selected node', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selected.label, style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 6),
                            Text('Coordinates: ${selected.lat.toStringAsFixed(5)}, ${selected.lng.toStringAsFixed(5)}'),
                            Text('Battery: ${selected.batteryPct.toStringAsFixed(0)}%'),
                            Text('Status: ${selected.online ? 'Online' : 'Offline'}'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.info_outline), label: const Text('Details')),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(onPressed: () => vm.clearSelection(), icon: const Icon(Icons.close), label: const Text('Clear')),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  static String _formatAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
