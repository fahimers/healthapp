import 'package:flutter/foundation.dart';
import '../models/health_model.dart';
import '../services/database_service.dart';

class StepProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<StepData> _stepsList = [];
  bool _isLoading = false;

  List<StepData> get stepsList => _stepsList;
  bool get isLoading => _isLoading;

  StepProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _dbService.initDatabase();
    await loadSteps();
  }

  Future<void> loadSteps() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stepsList = await _dbService.getAllSteps();
      _stepsList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      debugPrint('Error loading steps: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSteps(int steps) async {
    try {
      final stepData = StepData(
        id: DateTime.now().millisecondsSinceEpoch,
        steps: steps,
        timestamp: DateTime.now(),
      );
      await _dbService.addSteps(stepData);
      await loadSteps();
    } catch (e) {
      debugPrint('Error adding steps: $e');
    }
  }

  Future<void> deleteSteps(int id) async {
    try {
      await _dbService.deleteSteps(id);
      await loadSteps();
    } catch (e) {
      debugPrint('Error deleting steps: $e');
    }
  }

  int getTotalStepsToday() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final todaysSteps = _stepsList
        .where((data) =>
            data.timestamp.isAfter(startOfDay) &&
            data.timestamp.isBefore(endOfDay))
        .fold(0, (sum, data) => sum + data.steps);

    return todaysSteps;
  }

  int getTotalSteps() {
    return _stepsList.fold(0, (sum, data) => sum + data.steps);
  }

  /// Get calories burned today
  double getTotalCaloriesToday() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    final todaysCalories = _stepsList
        .where((data) =>
            data.timestamp.isAfter(startOfDay) &&
            data.timestamp.isBefore(endOfDay))
        .fold(0.0, (sum, data) => sum + data.caloriesBurned);

    return todaysCalories;
  }

  /// Get total calories burned for all recorded steps
  double getTotalCalories() {
    return _stepsList.fold(0.0, (sum, data) => sum + data.caloriesBurned);
  }

  /// Get calories formatted as string
  String getTotalCaloriesTodayFormatted() {
    return getTotalCaloriesToday().toStringAsFixed(2);
  }

  /// Get total calories formatted as string
  String getTotalCaloriesFormatted() {
    return getTotalCalories().toStringAsFixed(2);
  }

  /// Reset all data (steps and calories)
  Future<void> resetAllData() async {
    try {
      await _dbService.clearAllData();
      await loadSteps();
    } catch (e) {
      debugPrint('Error resetting data: $e');
    }
  }
}
