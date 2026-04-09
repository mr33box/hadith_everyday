import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hadith_everyday/core/constants/api_constants.dart';
import 'package:hadith_everyday/core/errors/failures.dart';
import 'package:hadith_everyday/data/models/hadith_model.dart';

/// HadithService — single entry point for fetching hadiths.
///
/// Strategy:
///   1. Try the live API (with query-param auth, the only method that works).
///   2. If ANY error occurs (401, no internet, timeout, etc.) — silently fall
///      back to the bundled [assets/hadiths.json] file.
///
/// The app NEVER crashes due to API failures.
class HadithService {
  HadithService() : _dio = _buildDio();

  final Dio _dio;
  final _rand = Random();

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Returns a random hadith not in [usedIds].
  /// Falls back to local data if the API is unavailable.
  Future<HadithModel> fetchRandomHadith({
    required List<int> usedIds,
    int maxAttempts = ApiConstants.maxRetries,
  }) async {
    // Try the live API first
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final hadith = await _fetchFromApi(usedIds: usedIds);
        dev.log('[HadithService] ✅ API success: ${hadith.bookName} #${hadith.hadithNumber}');
        return hadith;
      } catch (e) {
        dev.log('[HadithService] ⚠️ API attempt ${attempt + 1}/$maxAttempts failed: $e');
        if (attempt < maxAttempts - 1) {
          await Future.delayed(Duration(seconds: attempt + 1)); // backoff
        }
      }
    }

    // All API attempts exhausted — fall back to local JSON
    dev.log('[HadithService] 🔄 Falling back to local hadiths.json');
    return _fetchFromLocal(usedIds: usedIds);
  }

  // ─── API Fetch ──────────────────────────────────────────────────────────────

  Future<HadithModel> _fetchFromApi({required List<int> usedIds}) async {
    final apiKey = _resolveApiKey();
    final book = ApiConstants.authenticBooks[_rand.nextInt(ApiConstants.authenticBooks.length)];
    final page = _rand.nextInt(50) + 1;

    final queryParams = {
      'apiKey': apiKey,
      'book': book,
      'page': page,
      'perPage': ApiConstants.perPage,
      'status': 'Sahih',
    };

    final fullUrl = '${ApiConstants.baseUrl}${ApiConstants.hadithsEndpoint}';

    dev.log('[HadithService] 📡 GET $fullUrl');
    dev.log('[HadithService] 📦 Params: book=$book, page=$page, perPage=${ApiConstants.perPage}');

    final response = await _dio.get(
      fullUrl,
      queryParameters: queryParams,
    );

    dev.log('[HadithService] 📥 Status: ${response.statusCode}');

    final data = response.data as Map<String, dynamic>;
    final status = data['status'];

    if (status == 401 || status == 403) {
      final msg = data['message'] ?? 'Unauthorized';
      dev.log('[HadithService] ❌ Auth error: $msg');
      throw ServerFailure('Auth error $status: $msg');
    }

    final hadithsMap = data['hadiths'] as Map<String, dynamic>?;
    final dataList = (hadithsMap?['data'] as List<dynamic>?) ?? [];
    dev.log('[HadithService] 📋 Received ${dataList.length} hadiths');

    if (dataList.isEmpty) throw const EmptyResponseFailure();

    // Convert to models
    final models = dataList
        .map((e) => HadithModel.fromApiJson(e as Map<String, dynamic>))
        .toList();

    models.shuffle(_rand);

    // Try to find one not already used with valid lengths
    final candidate = models.firstWhere(
      (h) =>
          !usedIds.contains(h.id) &&
          h.arabicText.length >= ApiConstants.minHadithLength &&
          h.arabicText.length <= ApiConstants.maxHadithLength,
      orElse: () => models.first,
    );

    return candidate;
  }

  // ─── Local Fallback ─────────────────────────────────────────────────────────

  Future<HadithModel> _fetchFromLocal({required List<int> usedIds}) async {
    dev.log('[HadithService] 📂 Loading assets/hadiths.json');
    final jsonStr = await rootBundle.loadString('assets/hadiths.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;

    final models = list
        .map((e) => HadithModel.fromLocalFallbackJson(e as Map<String, dynamic>))
        .toList();

    dev.log('[HadithService] 📂 Loaded ${models.length} local hadiths');

    if (models.isEmpty) throw const EmptyResponseFailure();

    models.shuffle(_rand);

    // Prefer an unused hadith, but allow reuse if all are used
    final unused = models.where((h) => !usedIds.contains(h.id)).toList();
    return unused.isNotEmpty ? unused.first : models.first;
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _resolveApiKey() {
    // flutter_dotenv strips quotes; we also guard against $ sign corruption
    final raw = dotenv.env['HADITH_API_KEY'] ?? '';
    // Remove any surrounding quotes that the OS shell might have left in
    final key = raw.replaceAll('"', '').replaceAll("'", '').trim();
    if (key.isEmpty || key == 'YOUR_API_KEY_HERE') {
      throw const ServerFailure('HADITH_API_KEY not set in .env');
    }
    dev.log('[HadithService] 🔑 Using API key: ${key.substring(0, 8)}...');
    return key;
  }

  static Dio _buildDio() {
    return Dio(BaseOptions(
      connectTimeout: const Duration(seconds: ApiConstants.connectTimeoutSeconds),
      receiveTimeout: const Duration(seconds: ApiConstants.receiveTimeoutSeconds),
      headers: {'Accept': 'application/json'},
    ));
  }
}
