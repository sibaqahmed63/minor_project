// lib/presentation/views/simulation/simulation_placeholder.dart
import 'package:flutter/material.dart';

class SimulationPlaceholder extends StatelessWidget {
  const SimulationPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulation')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.play_circle_outline, size: 64),
            SizedBox(height: 12),
            Text('Simulation Controls (placeholder)', style: TextStyle(fontSize: 18)),
            SizedBox(height: 6),
            Text('Start/stop simulation, inject failures, change events'),
          ],
        ),
      ),
    );
  }
}
