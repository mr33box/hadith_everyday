import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadith_everyday/presentation/providers/settings_provider.dart';

const _kFavKey = 'favorite_hadith_ids';

class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier(this._prefs) : super({}) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final raw = _prefs.getStringList(_kFavKey) ?? [];
    state = raw.map((s) => int.tryParse(s) ?? -1).where((i) => i != -1).toSet();
  }

  bool isFavorite(int id) => state.contains(id);

  Future<void> toggle(int id) async {
    final next = {...state};
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = next;
    await _prefs.setStringList(_kFavKey, state.map((i) => '$i').toList());
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FavoritesNotifier(prefs);
});
