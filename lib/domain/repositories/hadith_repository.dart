import 'package:hadith_everyday/core/errors/failures.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';

/// Abstract contract that defines what the data layer must provide.
/// The domain layer depends only on this interface — never on implementation.
abstract interface class HadithRepository {
  /// Fetch a random, non-repeated hadith from the remote API.
  /// [usedIds] are IDs to skip to avoid repetition.
  /// [language] is 'en' or 'ar' — controls which text field to prioritise.
  Future<(HadithEntity?, Failure?)> fetchRandomHadith({
    required List<int> usedIds,
    String language = 'ar',
  });

  /// Return all locally saved hadiths, newest first.
  Future<(List<HadithEntity>, Failure?)> getHadithHistory();

  /// Persist a hadith (with its generated image path) to local storage.
  Future<Failure?> saveHadith(HadithEntity hadith);

  /// Delete a single hadith from local history.
  Future<Failure?> deleteHadith(int hadithId);

  /// Clear the full history.
  Future<Failure?> clearHistory();
}
