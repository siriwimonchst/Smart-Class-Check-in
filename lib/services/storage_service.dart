// =============================================================================
// services/storage_service.dart
// Handles saving and loading Check-in and Finish-Class records using
// shared_preferences (local key-value storage — suitable for MVP).
// =============================================================================

import 'package:shared_preferences/shared_preferences.dart';
import '../models/checkin_model.dart';

/// Key constants for shared_preferences storage
const String _kCheckinListKey = 'checkin_records';
const String _kFinishListKey = 'finish_class_records';

/// Provides static methods to persist and retrieve records locally.
class StorageService {
  // ---------------------------------------------------------------------------
  // CHECK-IN RECORDS
  // ---------------------------------------------------------------------------

  /// Save a new [CheckinRecord] to the local list.
  /// We store a JSON-encoded List<String> where each element is one record JSON.
  static Future<void> saveCheckinRecord(CheckinRecord record) async {
    final prefs = await SharedPreferences.getInstance();

    // Load previous list (or empty if first time)
    final List<String> existing = prefs.getStringList(_kCheckinListKey) ?? [];

    // Append the new record (serialized)
    existing.add(record.toJson());

    // Persist back
    await prefs.setStringList(_kCheckinListKey, existing);
  }

  /// Load all saved [CheckinRecord]s from local storage.
  static Future<List<CheckinRecord>> loadCheckinRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_kCheckinListKey) ?? [];
    return raw.map((e) => CheckinRecord.fromJson(e)).toList();
  }

  // ---------------------------------------------------------------------------
  // FINISH-CLASS RECORDS
  // ---------------------------------------------------------------------------

  /// Save a new [FinishClassRecord] to the local list.
  static Future<void> saveFinishClassRecord(FinishClassRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_kFinishListKey) ?? [];
    existing.add(record.toJson());
    await prefs.setStringList(_kFinishListKey, existing);
  }

  /// Load all saved [FinishClassRecord]s from local storage.
  static Future<List<FinishClassRecord>> loadFinishClassRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_kFinishListKey) ?? [];
    return raw.map((e) => FinishClassRecord.fromJson(e)).toList();
  }
}
