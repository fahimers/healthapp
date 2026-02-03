class StepData {
  final int id;
  final int steps;
  final DateTime timestamp;

  StepData({
    required this.id,
    required this.steps,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'steps': steps,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory StepData.fromMap(Map<String, dynamic> map) {
    return StepData(
      id: map['id'] as int,
      steps: map['steps'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
