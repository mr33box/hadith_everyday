import 'package:hadith_everyday/core/errors/failures.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';
import 'package:hadith_everyday/domain/repositories/hadith_repository.dart';

/// Use-case: Fetch a fresh random hadith, avoiding recently used ones.
/// Encapsulates the business rule of non-repetition and authentic sources.
class FetchDailyHadithUseCase {
  const FetchDailyHadithUseCase(this._repository);

  final HadithRepository _repository;

  /// [usedIds]  — list of already-shown hadith IDs to skip
  /// [language] — 'ar' or 'en', determines which text field to prefer
  Future<(HadithEntity?, Failure?)> call({
    required List<int> usedIds,
    String language = 'ar',
  }) {
    return _repository.fetchRandomHadith(
      usedIds: usedIds,
      language: language,
    );
  }
}
