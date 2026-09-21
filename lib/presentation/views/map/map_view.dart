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

        final agriDeadCount = state.killedNodeIds.where((id) => id.startsWith('Agri_')).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mesh Topology Map'),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: agriDeadCount == 0 ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: agriDeadCount == 0 ? Colors.green : Colors.red),
                    const SizedBox(width: 6),
                    Text(
                      agriDeadCount == 0
                          ? "AGRI MESH OPTIMAL"
                          : "AODV REROUTING ($agriDeadCount NODES DOWN)",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: agriDeadCount == 0 ? Colors.green : Colors.red,
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
                  // Dynamic 2D Diamond Canvas Visualizer
                  Container(
                    height: 380,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: CustomPaint(
                      painter: MeshTopologyPainter(
                        killedNodeIds: state.killedNodeIds,
                        lastActiveNode: state.lastActiveNode,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Horizontal Node List (30 Nodes)
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

// Custom Painter Drawing Dynamic Dead Nodes & AODV Reroute Link Highlights
class MeshTopologyPainter extends CustomPainter {
  final Set<String> killedNodeIds;
  final String lastActiveNode;

  MeshTopologyPainter({
    required this.killedNodeIds,
    required this.lastActiveNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final double agriY = h * 0.18;
    final double forestY = h * 0.50;
    final double disasterY = h * 0.82;

    _drawDynamic2DSubnet(
      canvas, w, agriY, "AGRICULTURE 2D MESH SUBNET",
      Colors.lightBlueAccent, Colors.blue, "Agri_Node", "Agri_GW", 0,
    );

    _drawDynamic2DSubnet(
      canvas, w, forestY, "FOREST CANOPY 2D MESH SUBNET",
      Colors.tealAccent, Colors.teal, "Forest_Node", "Forest_GW", 10,
    );

    _drawDynamic2DSubnet(
      canvas, w, disasterY, "DISASTER HAZARD 2D MESH SUBNET",
      Colors.orangeAccent, Colors.orange, "Disaster_Node", "Disaster_GW", 20,
    );
  }

  void _drawDynamic2DSubnet(
      Canvas canvas,
      double width,
      double centerY,
      String title,
      Color headerColor,
      Color themeColor,
      String nodePrefix,
      String gatewayId,
      int baseIdx,
      ) {
    final double x0 = width * 0.08;
    final double x1 = width * 0.28;
    final double x2 = width * 0.50;
    final double x3 = width * 0.72;
    final double x4 = width * 0.92;
    final double dy = 28.0;

    // Node Map IDs
    final String id0 = "${nodePrefix}${baseIdx}";
    final String id1 = "${nodePrefix}${baseIdx + 1}";
    final String id2 = "${nodePrefix}${baseIdx + 2}";
    final String id3 = "${nodePrefix}${baseIdx + 3}";
    final String id4 = "${nodePrefix}${baseIdx + 4}";
    final String id5 = "${nodePrefix}${baseIdx + 5}";
    final String id6 = "${nodePrefix}${baseIdx + 6}";
    final String id7 = "${nodePrefix}${baseIdx + 7}";
    final String id8 = "${nodePrefix}${baseIdx + 8}";
    final String idGW = gatewayId;

    // Coordinates
    final Offset n0  = Offset(x0, centerY);
    final Offset n1  = Offset(x1, centerY - dy);
    final Offset n2  = Offset(x1, centerY);
    final Offset n3  = Offset(x1, centerY + dy);
    final Offset n4  = Offset(x2, centerY - dy);
    final Offset n5  = Offset(x2, centerY);
    final Offset n6  = Offset(x2, centerY + dy);
    final Offset n7  = Offset(x3, centerY - (dy * 0.6));
    final Offset n8  = Offset(x3, centerY + (dy * 0.6));
    final Offset nGW = Offset(x4, centerY);

    // Subnet Header
    _drawHeader(canvas, Offset(x0, centerY - dy - 18), title, headerColor);

    // Draw Links with Dynamic AODV Color Logic
    _drawLink(canvas, n0, n1, id0, id1, themeColor);
    _drawLink(canvas, n0, n2, id0, id2, themeColor);
    _drawLink(canvas, n0, n3, id0, id3, themeColor);

    _drawLink(canvas, n1, n4, id1, id4, themeColor);
    _drawLink(canvas, n2, n5, id2, id5, themeColor);
    _drawLink(canvas, n3, n6, id3, id6, themeColor);

    // Dynamic AODV Reroute Mesh Diagonals
    _drawLink(canvas, n2, n4, id2, id4, themeColor);
    _drawLink(canvas, n2, n6, id2, id6, themeColor);

    _drawLink(canvas, n4, n7, id4, id7, themeColor);
    _drawLink(canvas, n5, n7, id5, id7, themeColor);
    _drawLink(canvas, n5, n8, id5, id8, themeColor);
    _drawLink(canvas, n6, n8, id6, id8, themeColor);

    _drawLink(canvas, n7, nGW, id7, idGW, themeColor);
    _drawLink(canvas, n8, nGW, id8, idGW, themeColor);

    // Draw Nodes (Red if in killedNodeIds, ThemeColor if Online)
    _drawNode(canvas, n0,  "${nodePrefix.contains('Agri') ? 'A' : nodePrefix.contains('Forest') ? 'F' : 'D'}${baseIdx}",     killedNodeIds.contains(id0),  themeColor);
    _drawNode(canvas, n1,  "${nodePrefix.contains('Agri') ? 'A' : nodePrefix.contains('Forest') ? 'F' : 'D'}${baseIdx + 1}", killedNodeIds.contains(id1),  themeColor);
    _drawNode(canvas, n2,  "${nodePrefix.contains('Agri') ? 'A' : nodePrefix.contains('Forest') ? 'F' : 'D'}${baseIdx + 2}", killedNodeIds.contains(id2),  themeColor);
    _drawNode(canvas, n3,  "${nodePrefix.contains('Agri') ? 'A' : nodePrefix.contains('Forest') ? 'F' : 'D'}${baseIdx + 3}", killedNodeIds.contains(id3),  themeColor);
    _drawNode(canvas, n4,  "${nodePrefix.contains('Agri') ? 'A' : nodePrefix.contains('Forest') ? 'F' : 'D'}${baseIdx + 4}", killedNodeIds.contains(id4),  themeColor);
    _drawNode(canvas, n5,  "${nodePrefix.contains('Agri') ? 'A' : nodePrefix.contains('Forest') ? 'F' : 'D'}${baseIdx + 5}", killedNodeIds.contains(id5),  themeColor);
    _drawNode(canvas, n6,  "${nodePrefix.contains('Agri') ? 'A' : nodePrefix.contains('Forest') ? 'F' : 'D'}${baseIdx + 6}", killedNodeIds.contains(id6),  themeColor);
    _drawNode(canvas, n7,  "${nodePrefix.contains('Agri') ? 'A' : nodePrefix.contains('Forest') ? 'F' : 'D'}${baseIdx + 7}", killedNodeIds.contains(id7),  themeColor);
    _drawNode(canvas, n8,  "${nodePrefix.contains('Agri') ? 'A' : nodePrefix.contains('Forest') ? 'F' : 'D'}${baseIdx + 8}", killedNodeIds.contains(id8),  themeColor);
    _drawNode(canvas, nGW, "${nodePrefix.contains('Agri') ? 'A' : nodePrefix.contains('Forest') ? 'F' : 'D'}GW",            killedNodeIds.contains(idGW), AppColors.accentGold);
  }

  void _drawLink(Canvas canvas, Offset p1, Offset p2, String idA, String idB, Color themeColor) {
    final bool isDead = killedNodeIds.contains(idA) || killedNodeIds.contains(idB);
    final paint = Paint()
      ..strokeWidth = isDead ? 1.0 : 2.2
      ..style = PaintingStyle.stroke
      ..color = isDead ? Colors.red.withOpacity(0.25) : Colors.greenAccent.withOpacity(0.85);

    canvas.drawLine(p1, p2, paint);
  }

  void _drawHeader(Canvas canvas, Offset offset, String title, Color color) {
    final textStyle = TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.6);
    final textPainter = TextPainter(
      text: TextSpan(text: title, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  void _drawNode(Canvas canvas, Offset center, String label, bool isKilled, Color themeColor) {
    final Color nodeColor = isKilled ? Colors.red : themeColor;
    final paint = Paint()..color = nodeColor;
    final glowPaint = Paint()..color = nodeColor.withOpacity(isKilled ? 0.15 : 0.35);

    canvas.drawCircle(center, 12, glowPaint);
    canvas.drawCircle(center, 7, paint);

    const textStyle = TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold);
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: textStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - (textPainter.width / 2), center.dy + 9));
  }

  @override
  bool shouldRepaint(covariant MeshTopologyPainter oldDelegate) {
    return oldDelegate.killedNodeIds != killedNodeIds || oldDelegate.lastActiveNode != lastActiveNode;
  }
}