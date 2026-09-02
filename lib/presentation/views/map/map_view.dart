// lib/presentation/views/map/map_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import 'map_viewmodel.dart';

class MapView extends ConsumerWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(mapViewModelProvider);
    final vm = ref.read(mapViewModelProvider.notifier);

    return asyncState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('Mesh Map')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (state) {
        final nodes = state.nodes;
        final selected = state.selectedNodeId == null
            ? null
            : nodes.firstWhere((n) => n.id == state.selectedNodeId, orElse: () => nodes.first);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mesh Topology Map'),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: state.isRelayAlive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: state.isRelayAlive ? Colors.green : Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      state.isRelayAlive ? "MESH HEALTHY" : "RELAY DOWN",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: state.isRelayAlive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => vm.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Interactive Canvas Radar
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: CustomPaint(
                      painter: MeshTopologyPainter(
                        isRelayAlive: state.isRelayAlive,
                        lastActiveNode: state.lastActiveNode,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Horizontal Node List
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
                            width: 170,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).dividerColor,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.hub_rounded, size: 18, color: node.online ? Colors.green : Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        node.label,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('Battery: ${node.batteryPct.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodySmall),
                                Text('Status: ${node.online ? "ONLINE" : "OFFLINE"}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: node.online ? Colors.green : Colors.red,
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Selected Node Details
                  if (selected != null) ...[
                    Text('Node Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(selected.label, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: selected.online ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    selected.online ? 'ONLINE' : 'OFFLINE',
                                    style: TextStyle(
                                      color: selected.online ? Colors.green : Colors.red,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            Text('Environment: ${selected.environment.toUpperCase()}'),
                            Text('Battery: ${selected.batteryPct.toStringAsFixed(0)}%'),
                            Text('Last Signal: ${_formatAgo(selected.lastSeen)}'),
                            if (selected.lastMetrics.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Text('Live Metrics:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: selected.lastMetrics.entries.map((e) {
                                  return Chip(
                                    label: Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 10)),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: () => vm.clearSelection(),
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Close Details'),
                              ),
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
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inMinutes < 1) return '${diff.inSeconds}s ago';
    return '${diff.inMinutes}m ago';
  }
}

// Custom Topology Canvas Painter
class MeshTopologyPainter extends CustomPainter {
  final bool isRelayAlive;
  final String lastActiveNode;

  MeshTopologyPainter({
    required this.isRelayAlive,
    required this.lastActiveNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final Offset n0 = Offset(size.width * 0.18, size.height * 0.30);
    final Offset n1 = Offset(size.width * 0.18, size.height * 0.70);
    final Offset n2 = Offset(size.width * 0.50, size.height * 0.50);
    final Offset n3 = Offset(size.width * 0.82, size.height * 0.30);
    final Offset n4 = Offset(size.width * 0.82, size.height * 0.70);

    // Dynamic Connections
    linePaint.color = isRelayAlive ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.3);
    canvas.drawLine(n0, n2, linePaint);
    canvas.drawLine(n1, n2, linePaint);
    canvas.drawLine(n2, n4, linePaint);

    linePaint.color = Colors.green.withOpacity(0.8);
    canvas.drawLine(n3, n4, linePaint);

    // Nodes
    _drawNode(canvas, n0, "Node 0\n(Agri)", Colors.blue);
    _drawNode(canvas, n1, "Node 1\n(Forest)", Colors.teal);
    _drawNode(canvas, n2, "Node 2\n(Relay)", isRelayAlive ? Colors.green : Colors.red);
    _drawNode(canvas, n3, "Node 3\n(Disaster)", Colors.orange);
    _drawNode(canvas, n4, "Node 4\n(Gateway)", AppColors.accentGold);
  }

  void _drawNode(Canvas canvas, Offset center, String label, Color color) {
    final paint = Paint()..color = color;
    final glowPaint = Paint()..color = color.withOpacity(0.3);

    canvas.drawCircle(center, 20, glowPaint);
    canvas.drawCircle(center, 12, paint);

    const textStyle = TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - (textPainter.width / 2), center.dy + 22));
  }

  @override
  bool shouldRepaint(covariant MeshTopologyPainter oldDelegate) {
    return oldDelegate.isRelayAlive != isRelayAlive || oldDelegate.lastActiveNode != lastActiveNode;
  }
}