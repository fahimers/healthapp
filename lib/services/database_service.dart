import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/health_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static SharedPreferences? _prefs;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initDatabase() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> addSteps(StepData stepData) async {
    await initDatabase();
    final key = 'steps_${stepData.id}';
    final jsonString = jsonEncode(stepData.toMap());
    await _prefs!.setString(key, jsonString);
  }

  Future<List<StepData>> getAllSteps() async {
    await initDatabase();
    final keys = _prefs!.getKeys();
    final stepsList = <StepData>[];

    for (String key in keys) {
      if (key.startsWith('steps_')) {
        try {
          final jsonString = _prefs!.getString(key);
          if (jsonString != null) {
            final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
            stepsList.add(StepData.fromMap(jsonMap));
          }
        } catch (e) {
          // Skip malformed data
        }
      }
    }

    return stepsList;
  }

  Future<void> deleteSteps(int id) async {
    await initDatabase();
    final key = 'steps_$id';
    await _prefs!.remove(key);
  }

  Future<void> clearAllData() async {
    await initDatabase();
    final keys = _prefs!.getKeys();
    for (String key in keys) {
      if (key.startsWith('steps_')) {
        await _prefs!.remove(key);
      }
    }
  }
}

