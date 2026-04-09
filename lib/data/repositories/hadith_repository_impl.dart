import 'package:hadith_everyday/core/errors/failures.dart';
import 'package:hadith_everyday/data/datasources/hadith_local_datasource.dart';
import 'package:hadith_everyday/data/datasources/hadith_remote_datasource.dart';
import 'package:hadith_everyday/data/models/hadith_model.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';
import 'package:hadith_everyday/domain/repositories/hadith_repository.dart';

/// Implements the repository contract by coordinating the remote and local
/// data sources. All failures are caught and returned via the result tuple.
class HadithRepositoryImpl implements HadithRepository {
  HadithRepositoryImpl({
    required HadithRemoteDataSource remoteDataSource,
    required HadithLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final HadithRemoteDataSource _remote;
  final HadithLocalDataSource _local;

  @override
  Future<(HadithEntity?, Failure?)> fetchRandomHadith({
    required List<int> usedIds,
    String language = 'ar',
  }) async {
    try {
      // HadithRemoteDataSource never throws — it auto-falls back to local data.
      // So this always returns a valid model (either from API or local JSON).
      final model = await _remote.fetchRandomHadith(usedIds: usedIds);
      return (model as HadithEntity, null);
    } on NetworkFailure catch (f) {
      return (null, f);
    } on ServerFailure catch (f) {
      return (null, f);
    } on EmptyResponseFailure catch (f) {
      return (null, f);
    } catch (e) {
      return (null, UnknownFailure('Unexpected error fetching hadith: $e'));
    }
  }

  @override
  Future<(List<HadithEntity>, Failure?)> getHadithHistory() async {
    try {
      final models = _local.getAllHadiths();
      return (models.cast<HadithEntity>(), null);
    } on CacheFailure catch (f) {
      return (<HadithEntity>[], f);
    } catch (e) {
      return (<HadithEntity>[], UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Failure?> saveHadith(HadithEntity hadith) async {
    try {
      final model = HadithModel.fromEntity(hadith);
      await _local.saveHadith(model);
      return null;
    } on CacheFailure catch (f) {
      return f;
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<Failure?> deleteHadith(int hadithId) async {
    try {
      await _local.deleteHadith(hadithId);
      return null;
    } on CacheFailure catch (f) {
      return f;
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }

  @override
  Future<Failure?> clearHistory() async {
    try {
      await _local.clearAll();
      return null;
    } on CacheFailure catch (f) {
      return f;
    } catch (e) {
      return UnknownFailure(e.toString());
    }
  }
}
