import 'package:hive_flutter/hive_flutter.dart';
import 'package:hadith_everyday/core/constants/app_constants.dart';
import 'package:hadith_everyday/core/errors/failures.dart';
import 'package:hadith_everyday/data/models/hadith_model.dart';

/// Local data source — reads/writes hadith history to Hive.
/// Hadiths are stored as JSON strings keyed by their numeric ID.
class HadithLocalDataSource {
  Box<String> get _box => Hive.box<String>(AppConstants.hadithBoxName);

  // ─── Read ──────────────────────────────────────────────────────────────────

  /// Returns all saved hadiths, sorted newest-first.
  List<HadithModel> getAllHadiths() {
    try {
      return _box.values
          .map((jsonStr) => HadithModel.fromLocalJsonString(jsonStr))
          .toList()
        ..sort((a, b) => b.fetchedAt.compareTo(a.fetchedAt));
    } catch (e) {
      throw CacheFailure('Failed to read hadiths: $e');
    }
  }

  /// Returns the hadith with [id], or null if not found.
  HadithModel? getHadithById(int id) {
    try {
      final jsonStr = _box.get(id.toString());
      if (jsonStr == null) return null;
      return HadithModel.fromLocalJsonString(jsonStr);
    } catch (_) {
      return null;
    }
  }

  // ─── Write ─────────────────────────────────────────────────────────────────

  /// Save or update a hadith (upsert by ID).
  Future<void> saveHadith(HadithModel model) async {
    try {
      await _box.put(model.id.toString(), model.toLocalJsonString());
    } catch (e) {
      throw CacheFailure('Failed to save hadith: $e');
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteHadith(int id) async {
    try {
      await _box.delete(id.toString());
    } catch (e) {
      throw CacheFailure('Failed to delete hadith: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (e) {
      throw CacheFailure('Failed to clear history: $e');
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Whether a hadith with [id] is already saved locally.
  bool contains(int id) => _box.containsKey(id.toString());

  /// Total number of stored hadiths.
  int get count => _box.length;
}
