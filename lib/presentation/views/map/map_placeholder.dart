// lib/presentation/views/map/map_placeholder.dart
import 'package:flutter/material.dart';
import '../../widgets/premium_appbar.dart'; // optional; safe if not present remove import

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.map_outlined, size: 72),
            SizedBox(height: 12),
            Text('Map View (placeholder)', style: TextStyle(fontSize: 18)),
            SizedBox(height: 6),
            Text('Will show node topology and clustered markers'),
          ],
        ),
      ),
    );
  }
}
