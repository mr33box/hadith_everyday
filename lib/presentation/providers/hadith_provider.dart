import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadith_everyday/core/constants/app_constants.dart';
import 'package:hadith_everyday/core/errors/failures.dart';
import 'package:hadith_everyday/core/services/image_generator.dart';
import 'package:hadith_everyday/core/services/wallpaper_service.dart';
import 'package:hadith_everyday/data/datasources/hadith_local_datasource.dart';
import 'package:hadith_everyday/data/datasources/hadith_remote_datasource.dart';
import 'package:hadith_everyday/data/models/hadith_model.dart';
import 'package:hadith_everyday/data/repositories/hadith_repository_impl.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';
import 'package:hadith_everyday/domain/usecases/fetch_daily_hadith.dart';
import 'package:hadith_everyday/domain/usecases/hadith_history_usecases.dart';
import 'package:hadith_everyday/presentation/providers/settings_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── Infrastructure Providers ──────────────────────────────────────────────────

final hadithRemoteDsProvider = Provider<HadithRemoteDataSource>((_) {
  return HadithRemoteDataSource();
});

final hadithLocalDsProvider = Provider<HadithLocalDataSource>((_) {
  return HadithLocalDataSource();
});

final hadithRepositoryProvider = Provider<HadithRepositoryImpl>((ref) {
  return HadithRepositoryImpl(
    remoteDataSource: ref.watch(hadithRemoteDsProvider),
    localDataSource: ref.watch(hadithLocalDsProvider),
  );
});

// ─── Use Case Providers ────────────────────────────────────────────────────────

final fetchDailyHadithProvider = Provider<FetchDailyHadithUseCase>((ref) {
  return FetchDailyHadithUseCase(ref.watch(hadithRepositoryProvider));
});

final saveHadithProvider = Provider<SaveHadithUseCase>((ref) {
  return SaveHadithUseCase(ref.watch(hadithRepositoryProvider));
});

final deleteHadithProvider = Provider<DeleteHadithUseCase>((ref) {
  return DeleteHadithUseCase(ref.watch(hadithRepositoryProvider));
});

final getHistoryProvider = Provider<GetHadithHistoryUseCase>((ref) {
  return GetHadithHistoryUseCase(ref.watch(hadithRepositoryProvider));
});

// ─── Device Screen Dimensions Provider ────────────────────────────────────────
// Written from HomeScreen.initState once MediaQuery is available.
final deviceScreenSizeProvider = StateProvider<Size>((_) => const Size(1080, 1920));

// ─── Hadith History State ──────────────────────────────────────────────────────

class HadithHistoryNotifier extends StateNotifier<AsyncValue<List<HadithEntity>>> {
  HadithHistoryNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  final Ref _ref;

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    final useCase = _ref.read(getHistoryProvider);
    final (hadiths, failure) = await useCase();
    if (failure != null) {
      state = AsyncValue.error(failure.message, StackTrace.current);
    } else {
      state = AsyncValue.data(hadiths);
    }
  }

  Future<void> deleteHadith(int id) async {
    final useCase = _ref.read(deleteHadithProvider);
    await useCase(id);
    await HadithImageGenerator.deleteImage(id);
    await loadHistory();
  }

  int get totalCount => state.valueOrNull?.length ?? 0;
}

final hadithHistoryProvider = StateNotifierProvider<HadithHistoryNotifier,
    AsyncValue<List<HadithEntity>>>((ref) {
  return HadithHistoryNotifier(ref);
});

// ─── Current Fetch State ───────────────────────────────────────────────────────

enum FetchStage { idle, fetchingHadith, generatingImage, settingWallpaper, done }

class FetchState {
  const FetchState({
    this.stage = FetchStage.idle,
    this.hadith,
    this.failure,
    this.isOffline = false,
  });

  final FetchStage stage;
  final HadithEntity? hadith;
  final Failure? failure;
  final bool isOffline;

  bool get isLoading =>
      stage == FetchStage.fetchingHadith ||
      stage == FetchStage.generatingImage ||
      stage == FetchStage.settingWallpaper;

  bool get hasError => failure != null && stage == FetchStage.done;
  bool get isSuccess => stage == FetchStage.done && failure == null;

  FetchState copyWith({
    FetchStage? stage,
    HadithEntity? hadith,
    Failure? failure,
    bool? isOffline,
  }) =>
      FetchState(
        stage: stage ?? this.stage,
        hadith: hadith ?? this.hadith,
        failure: failure,
        isOffline: isOffline ?? this.isOffline,
      );
}

class HadithFetchNotifier extends StateNotifier<FetchState> {
  HadithFetchNotifier(this._ref) : super(const FetchState()) {
    _restoreLastHadith();
  }

  final Ref _ref;

  // ─── State Persistence ───────────────────────────────────────────────────────

  void _restoreLastHadith() {
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      final jsonStr = prefs.getString(AppConstants.prefKeyLastHadithJson);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final hadith = HadithModel.fromLocalJson(map);
        // Restore the UI state to show the last hadith instantly
        state = FetchState(stage: FetchStage.done, hadith: hadith);
      }
    } catch (_) {
      // Non-fatal — state stays idle
    }
  }

  Future<void> _persistLastHadith(HadithEntity hadith) async {
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      final model = HadithModel.fromEntity(hadith);
      await prefs.setString(
          AppConstants.prefKeyLastHadithJson, model.toLocalJsonString());
    } catch (_) {}
  }

  // ─── Full Pipeline: fetch → generate → set wallpaper ─────────────────────────

  Future<void> fetchAndProcess({bool setWallpaper = true}) async {
    state = const FetchState(stage: FetchStage.fetchingHadith);

    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      final usedIds = _getUsedIds(prefs);
      final settings = _ref.read(settingsProvider);
      final screenSize = _ref.read(deviceScreenSizeProvider);

      // 1. Fetch hadith
      final fetchUseCase = _ref.read(fetchDailyHadithProvider);
      final (hadith, fetchFailure) = await fetchUseCase(
        usedIds: usedIds,
        language: settings.language,
      );
      if (fetchFailure != null || hadith == null) {
        // Check if it's a network failure
        final isNetwork = fetchFailure is NetworkFailure;
        state = FetchState(
          stage: FetchStage.done,
          failure: fetchFailure ?? const UnknownFailure(),
          isOffline: isNetwork,
        );
        return;
      }

      state = FetchState(stage: FetchStage.generatingImage, hadith: hadith);

      // 2. Generate image at device native resolution
      final (imagePath, imgFailure) = await HadithImageGenerator.generateAndSave(
        hadith: hadith,
        bgStyle: settings.bgStyle,
        fontScale: settings.fontScale,
        deviceWidth: screenSize.width,
        deviceHeight: screenSize.height,
        isRtl: settings.language == AppConstants.langAr,
        titleString: settings.language == AppConstants.langAr 
            ? 'قال رسول الله ﷺ' 
            : 'The Messenger of Allah ﷺ said:',
        sourceString: settings.language == AppConstants.langAr
            ? 'رواه ${hadith.getLocalizedBookName(true)}'
            : 'Narrated by ${hadith.getLocalizedBookName(false)}',
        customBgColor1: settings.bgStyleIndex == 3 ? settings.bgColor1 : null,
        customBgColor2: settings.bgStyleIndex == 3 ? settings.bgColor2 : null,
        customTextColor: settings.bgStyleIndex == 3 ? settings.textColor : null,
        customTitleColor: settings.bgStyleIndex == 3 ? settings.titleColor : null,
      );

      if (imgFailure != null || imagePath == null) {
        state = FetchState(
            stage: FetchStage.done,
            hadith: hadith,
            failure: imgFailure ?? const ImageFailure());
        return;
      }

      final savedHadith = hadith.copyWith(
        imagePath: imagePath,
        bgStyleIndex: settings.bgStyleIndex,
        fontScale: settings.fontScale,
        textAlignIndex: settings.textAlignIndex,
      );

      // 3. Save to storage
      final saveUseCase = _ref.read(saveHadithProvider);
      await saveUseCase(savedHadith);
      _recordUsedId(prefs, hadith.id);
      await _persistLastHadith(savedHadith);

      // 4. Optionally set wallpaper
      if (setWallpaper && settings.autoWallpaper) {
        state = FetchState(stage: FetchStage.settingWallpaper, hadith: savedHadith);

        var permStatus = await Permission.storage.status;
        if (!permStatus.isGranted) {
          permStatus = await Permission.storage.request();
        }
        if (permStatus.isPermanentlyDenied) {
          state = FetchState(
            stage: FetchStage.done,
            hadith: savedHadith,
            failure: const UnknownFailure(
                'Storage permission permanently denied. Enable it in Settings.'),
          );
          _ref.read(hadithHistoryProvider.notifier).loadHistory();
          return;
        }

        final wallpaperFailure = await WallpaperService.setWallpaper(imagePath);
        if (wallpaperFailure != null) {
          state = FetchState(
            stage: FetchStage.done,
            hadith: savedHadith,
            failure: wallpaperFailure,
          );
          _ref.read(hadithHistoryProvider.notifier).loadHistory();
          return;
        }
      }

      state = FetchState(stage: FetchStage.done, hadith: savedHadith);
      _ref.read(hadithHistoryProvider.notifier).loadHistory();
    } catch (e) {
      state = FetchState(
          stage: FetchStage.done,
          failure: UnknownFailure(e.toString()));
    }
  }

  // ─── Regenerate: same hadith, new design ─────────────────────────────────────

  Future<void> regenerateCurrentHadith({bool forceWallpaper = false}) async {
    final currentHadith = state.hadith;
    if (currentHadith == null) return;

    state = FetchState(stage: FetchStage.generatingImage, hadith: currentHadith);

    try {
      final settings = _ref.read(settingsProvider);
      final screenSize = _ref.read(deviceScreenSizeProvider);

      final (imagePath, imgFailure) = await HadithImageGenerator.generateAndSave(
        hadith: currentHadith,
        bgStyle: settings.bgStyle,
        fontScale: settings.fontScale,
        deviceWidth: screenSize.width,
        deviceHeight: screenSize.height,
        isRtl: settings.language == AppConstants.langAr,
        titleString: settings.language == AppConstants.langAr 
            ? 'قال رسول الله ﷺ' 
            : 'The Messenger of Allah ﷺ said:',
        sourceString: settings.language == AppConstants.langAr
            ? 'رواه ${currentHadith.getLocalizedBookName(true)}'
            : 'Narrated by ${currentHadith.getLocalizedBookName(false)}',
        customBgColor1: settings.bgStyleIndex == 3 ? settings.bgColor1 : null,
        customBgColor2: settings.bgStyleIndex == 3 ? settings.bgColor2 : null,
        customTextColor: settings.bgStyleIndex == 3 ? settings.textColor : null,
        customTitleColor: settings.bgStyleIndex == 3 ? settings.titleColor : null,
      );

      if (imgFailure != null || imagePath == null) {
        state = FetchState(
            stage: FetchStage.done,
            hadith: currentHadith,
            failure: imgFailure ?? const ImageFailure());
        return;
      }

      final updatedHadith = currentHadith.copyWith(imagePath: imagePath);
      final saveUseCase = _ref.read(saveHadithProvider);
      await saveUseCase(updatedHadith);
      await _persistLastHadith(updatedHadith);

      if (forceWallpaper || settings.autoWallpaper) {
        state = FetchState(stage: FetchStage.settingWallpaper, hadith: updatedHadith);
        await WallpaperService.setWallpaper(imagePath);
      }

      state = FetchState(stage: FetchStage.done, hadith: updatedHadith);
      _ref.read(hadithHistoryProvider.notifier).loadHistory();
    } catch (e) {
      state = FetchState(
          stage: FetchStage.done,
          hadith: currentHadith,
          failure: UnknownFailure(e.toString()));
    }
  }

  void reset() => state = const FetchState();
}

final hadithFetchProvider =
    StateNotifierProvider<HadithFetchNotifier, FetchState>((ref) {
  return HadithFetchNotifier(ref);
});

// ─── Helpers ──────────────────────────────────────────────────────────────────

List<int> _getUsedIds(SharedPreferences prefs) {
  final raw = prefs.getStringList(AppConstants.prefKeyUsedHadithIds) ?? [];
  final cutoff = DateTime.now()
      .subtract(const Duration(days: AppConstants.hadithMemoryDays));
  final valid = raw.where((entry) {
    final parts = entry.split(':');
    if (parts.length < 2) return false;
    final date = DateTime.tryParse(parts.sublist(1).join(':'));
    return date != null && date.isAfter(cutoff);
  }).toList();
  prefs.setStringList(AppConstants.prefKeyUsedHadithIds, valid);
  return valid
      .map((e) => int.tryParse(e.split(':').first) ?? -1)
      .where((id) => id != -1)
      .toList();
}

void _recordUsedId(SharedPreferences prefs, int id) {
  final raw = prefs.getStringList(AppConstants.prefKeyUsedHadithIds) ?? [];
  raw.add('$id:${DateTime.now().toIso8601String()}');
  prefs.setStringList(AppConstants.prefKeyUsedHadithIds, raw);
}
