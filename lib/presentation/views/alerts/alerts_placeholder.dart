// lib/presentation/views/alerts/alerts_placeholder.dart
import 'package:flutter/material.dart';

class AlertsPlaceholder extends StatelessWidget {
  const AlertsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.notifications_active_outlined, size: 64),
            SizedBox(height: 12),
            Text('Alerts Feed (placeholder)', style: TextStyle(fontSize: 18)),
            SizedBox(height: 6),
            Text('Will list active and historical alerts with filters'),
          ],
        ),
      ),
    );
  }
}
