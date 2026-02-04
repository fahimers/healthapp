class StepData {
  final int id;
  final int steps;
  final DateTime timestamp;

  StepData({
    required this.id,
    required this.steps,
    required this.timestamp,
  });

  /// Converts steps to calories burned
  /// Average: 1 step = 0.04 calories (varies by weight, pace, etc.)
  double get caloriesBurned => steps * 0.04;

  /// Returns calories with 2 decimal places
  String get caloriesFormated => caloriesBurned.toStringAsFixed(2);

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
