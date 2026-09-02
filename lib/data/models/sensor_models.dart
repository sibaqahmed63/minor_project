class SensorModel {
  final String environment;
  final String node;
  final double timestamp;
  final Map<String, dynamic> metrics;
  final Map<String, dynamic> aiAnalysis;

  SensorModel({
    required this.environment,
    required this.node,
    required this.timestamp,
    required this.metrics,
    required this.aiAnalysis,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      environment: json['environment'] ?? 'agriculture',
      node: json['node'] ?? 'Unknown',
      timestamp: (json['timestamp'] as num?)?.toDouble() ?? 0.0,
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
      aiAnalysis: Map<String, dynamic>.from(json['ai_analysis'] ?? {}),
    );
  }
}