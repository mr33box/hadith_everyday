import 'package:hadith_everyday/core/errors/failures.dart';
import 'package:hadith_everyday/core/services/hadith_service.dart';
import 'package:hadith_everyday/data/models/hadith_model.dart';

/// Remote data source — now delegates entirely to [HadithService].
///
/// HadithService handles:
///   - Auth (query-param apiKey — the only working method)
///   - Retry with exponential backoff
///   - Debug logging
///   - Automatic fallback to [assets/hadiths.json] on any failure
class HadithRemoteDataSource {
  HadithRemoteDataSource() : _service = HadithService();

  final HadithService _service;

  /// Fetch a random hadith not in [usedIds].
  /// Never throws — falls back to local data on failure.
  Future<HadithModel> fetchRandomHadith({
    required List<int> usedIds,
    int maxAttempts = 3,
  }) async {
    return _service.fetchRandomHadith(
      usedIds: usedIds,
      maxAttempts: maxAttempts,
    );
  }
}
