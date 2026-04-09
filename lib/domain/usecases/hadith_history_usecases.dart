import 'package:hadith_everyday/core/errors/failures.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';
import 'package:hadith_everyday/domain/repositories/hadith_repository.dart';

/// Use-case: Retrieve the locally stored hadith history.
class GetHadithHistoryUseCase {
  const GetHadithHistoryUseCase(this._repository);

  final HadithRepository _repository;

  Future<(List<HadithEntity>, Failure?)> call() {
    return _repository.getHadithHistory();
  }
}

/// Use-case: Persist a hadith (with its image path) to local storage.
class SaveHadithUseCase {
  const SaveHadithUseCase(this._repository);

  final HadithRepository _repository;

  Future<Failure?> call(HadithEntity hadith) {
    return _repository.saveHadith(hadith);
  }
}

/// Use-case: Remove a single hadith from history.
class DeleteHadithUseCase {
  const DeleteHadithUseCase(this._repository);

  final HadithRepository _repository;

  Future<Failure?> call(int hadithId) {
    return _repository.deleteHadith(hadithId);
  }
}
