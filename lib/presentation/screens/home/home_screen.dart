import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hadith_everyday/app/router.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';
import 'package:hadith_everyday/presentation/providers/favorites_provider.dart';
import 'package:hadith_everyday/presentation/providers/hadith_provider.dart';
import 'package:hadith_everyday/presentation/providers/settings_provider.dart';
import 'package:hadith_everyday/presentation/screens/home/widgets/hadith_card.dart';
import 'package:hadith_everyday/presentation/screens/home/widgets/today_hadith_widget.dart';
import 'package:hadith_everyday/presentation/widgets/app_error_widget.dart';
import 'package:hadith_everyday/presentation/widgets/app_loading_widget.dart';
import 'package:hadith_everyday/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fabController;
  late final Animation<double> _fabAnimation;
  bool _showAll = false;
  bool _showFavOnly = false; // filter: All vs Favorites

  static const int _initialHistoryCount = 5;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fabAnimation =
        CurvedAnimation(parent: _fabController, curve: Curves.elasticOut);

    // Inject native screen dimensions after first frame so image generation
    // uses full device resolution (e.g. 1080×2400 on a real phone).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mq = MediaQuery.of(context);
      final physicalSize = Size(
        mq.size.width * mq.devicePixelRatio,
        mq.size.height * mq.devicePixelRatio,
      );
      ref.read(deviceScreenSizeProvider.notifier).state = physicalSize;
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final historyAsync = ref.watch(hadithHistoryProvider);
    final fetchState = ref.watch(hadithFetchProvider);
    final theme = Theme.of(context);
    final isRtl = settings.language == 'ar';

    // ── Snackbar feedback ────────────────────────────────────────────────────
    ref.listen(hadithFetchProvider, (prev, next) {
      if (next.stage == FetchStage.done) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();

        if (next.isOffline) {
          messenger.showSnackBar(SnackBar(
            content: const Row(children: [
              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('No internet. Using local hadith.'),
            ]),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        } else if (next.failure != null) {
          messenger.showSnackBar(SnackBar(
            content: Text(next.failure!.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () =>
                  ref.read(hadithFetchProvider.notifier).fetchAndProcess(),
            ),
          ));
        } else {
          messenger.showSnackBar(SnackBar(
            content: Text(l10n.successWallpaper),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      }
    });

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        // ── AppBar ────────────────────────────────────────────────────────
        appBar: AppBar(
          title: Text(l10n.appName),
          actions: [
            // Gallery
            IconButton(
              icon: const Icon(Icons.photo_library_rounded),
              tooltip: l10n.gallery,
              onPressed: () => context.pushNamed('gallery'),
            ),
            // Dark mode toggle
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  settings.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  key: ValueKey(settings.isDarkMode),
                ),
              ),
              onPressed: () => ref
                  .read(settingsProvider.notifier)
                  .setDarkMode(!settings.isDarkMode),
              tooltip: l10n.settingsDarkMode,
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => context.pushNamed('settings'),
              tooltip: l10n.settingsTitle,
            ),
            const SizedBox(width: 4),
          ],
        ),

        body: RefreshIndicator(
          onRefresh: () =>
              ref.read(hadithFetchProvider.notifier).fetchAndProcess(),
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Offline banner ──────────────────────────────────────────
              if (fetchState.isOffline)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade700.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off_rounded, color: Colors.orange.shade700, size: 18),
                        const SizedBox(width: 8),
                        Text('No internet — showing local hadith',
                            style: TextStyle(color: Colors.orange.shade700, fontSize: 13)),
                      ],
                    ),
                  ),
                ),

              // ── Today's Hadith Widget ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TodayHadithWidget(
                    fetchState: fetchState,
                    onFetch: () => ref
                        .read(hadithFetchProvider.notifier)
                        .fetchAndProcess(),
                    isRtl: isRtl,
                  ),
                ),
              ),

              // ── History header + stats ────────────────────────────────────
              historyAsync.maybeWhen(
                data: (hadiths) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.history,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        // Stats badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Total: ${hadiths.length}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                orElse: () => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Text(l10n.history,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),

              // ── Filter tabs: All / Favorites ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: Row(
                    children: [
                      _FilterTab(
                        label: 'All',
                        icon: Icons.list_rounded,
                        active: !_showFavOnly,
                        onTap: () => setState(() {
                          _showFavOnly = false;
                          _showAll = false;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Favourites',
                        icon: Icons.favorite_rounded,
                        active: _showFavOnly,
                        onTap: () => setState(() {
                          _showFavOnly = true;
                          _showAll = false;
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // ── History List ─────────────────────────────────────────────
              historyAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.all(40), child: AppLoadingWidget()),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppErrorWidget(
                      message: e.toString(),
                      onRetry: () => ref
                          .read(hadithHistoryProvider.notifier)
                          .loadHistory(),
                    ),
                  ),
                ),
                data: (hadiths) {
                  // Apply favorites filter
                  final favIds = ref.watch(favoritesProvider);
                  final filtered = _showFavOnly
                      ? hadiths.where((h) => favIds.contains(h.id)).toList()
                      : hadiths;

                  if (filtered.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _EmptyState(
                        message: _showFavOnly
                            ? 'No favourites yet. Tap ♥ on a hadith to save it.'
                            : l10n.noHadiths,
                        onFetch: () => ref
                            .read(hadithFetchProvider.notifier)
                            .fetchAndProcess(),
                        fetchLabel: l10n.fetchNow,
                      ),
                    );
                  }

                  // Group hadiths by day
                  final groups = _groupByDay(filtered, l10n);
                  final displayedGroups = _showAll
                      ? groups
                      : _trimGroups(groups, _initialHistoryCount);
                  final totalDisplayed =
                      displayedGroups.values.fold(0, (a, b) => a + b.length);
                  final hasMore = hadiths.length > totalDisplayed;

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, sectionIndex) {
                          // Build sections: header + items
                          final entries = displayedGroups.entries.toList();
                          int itemsRendered = 0;
                          for (int g = 0; g < entries.length; g++) {
                            final group = entries[g];
                            // section header
                            if (sectionIndex == itemsRendered) {
                              return _DayHeader(label: group.key);
                            }
                            itemsRendered++;
                            // hadith cards in group
                            for (int i = 0; i < group.value.length; i++) {
                              if (sectionIndex == itemsRendered) {
                                return HadithCard(
                                  hadith: group.value[i],
                                  isRtl: isRtl,
                                  onDelete: () => _confirmDelete(
                                      context, group.value[i], l10n, isRtl),
                                );
                              }
                              itemsRendered++;
                            }
                          }
                          // Show more / show less button
                          if (sectionIndex == itemsRendered) {
                            return _ShowMoreButton(
                              showAll: _showAll,
                              hasMore: hasMore,
                              showMoreLabel: l10n.showMore,
                              showLessLabel: l10n.showLess,
                              onToggle: () =>
                                  setState(() => _showAll = !_showAll),
                            );
                          }
                          return null;
                        },
                        childCount: () {
                          int count = 0;
                          for (final e in displayedGroups.entries) {
                            count += 1 + e.value.length; // header + items
                          }
                          count += 1; // show more button
                          return count;
                        }(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // ── FAB: New Hadith ──────────────────────────────────────────────────
        floatingActionButton: ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.extended(
            onPressed: fetchState.isLoading
                ? null
                : () =>
                    ref.read(hadithFetchProvider.notifier).fetchAndProcess(),
            backgroundColor: fetchState.isLoading
                ? theme.colorScheme.primary.withOpacity(0.5)
                : theme.colorScheme.primary,
            icon: fetchState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.add_circle_rounded, color: Colors.white),
            label: Text(
              fetchState.isLoading
                  ? _stageLabel(fetchState.stage, l10n)
                  : l10n.fetchNow,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  String _stageLabel(FetchStage stage, AppLocalizations l10n) {
    return switch (stage) {
      FetchStage.fetchingHadith  => l10n.loadingHadith,
      FetchStage.generatingImage => l10n.generatingImage,
      FetchStage.settingWallpaper => l10n.settingWallpaper,
      _ => 'New Hadith',
    };
  }

  // Groups hadiths by Today / Yesterday / Earlier using l10n labels
  Map<String, List<HadithEntity>> _groupByDay(
      List<HadithEntity> hadiths, AppLocalizations l10n) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final groups = <String, List<HadithEntity>>{};
    for (final h in hadiths) {
      final d = h.fetchedAt;
      String key;
      if (d.isAfter(todayStart)) {
        key = l10n.today;
      } else if (d.isAfter(yesterdayStart)) {
        key = l10n.yesterday;
      } else {
        key = l10n.earlier;
      }
      groups.putIfAbsent(key, () => []).add(h);
    }
    // canonical order
    final ordered = <String, List<HadithEntity>>{};
    for (final key in [l10n.today, l10n.yesterday, l10n.earlier]) {
      if (groups.containsKey(key)) ordered[key] = groups[key]!;
    }
    return ordered;
  }

  // Trim grouped map to show at most [max] total items
  Map<String, List<HadithEntity>> _trimGroups(
      Map<String, List<HadithEntity>> groups, int max) {
    final result = <String, List<HadithEntity>>{};
    int remaining = max;
    for (final entry in groups.entries) {
      if (remaining <= 0) break;
      final items = entry.value.take(remaining).toList();
      if (items.isNotEmpty) result[entry.key] = items;
      remaining -= items.length;
    }
    return result;
  }

  Future<void> _confirmDelete(BuildContext context, HadithEntity hadith,
      AppLocalizations l10n, bool isRtl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          title: Text(l10n.delete),
          content: Text(l10n.confirmDelete),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.confirm,
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) {
      ref.read(hadithHistoryProvider.notifier).deleteHadith(hadith.id);
    }
  }
}

// ─── Day Section Header ────────────────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Row(
        children: [
          Expanded(
              child: Divider(color: theme.dividerColor.withOpacity(0.5))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
              child: Divider(color: theme.dividerColor.withOpacity(0.5))),
        ],
      ),
    );
  }
}

// ─── Show More / Less Button ───────────────────────────────────────────────────

class _ShowMoreButton extends StatelessWidget {
  const _ShowMoreButton({
    required this.showAll,
    required this.hasMore,
    required this.onToggle,
    required this.showMoreLabel,
    required this.showLessLabel,
  });
  final bool showAll;
  final bool hasMore;
  final VoidCallback onToggle;
  final String showMoreLabel;
  final String showLessLabel;

  @override
  Widget build(BuildContext context) {
    if (!showAll && !hasMore) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: OutlinedButton.icon(
          icon: Icon(showAll
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded),
          label: Text(showAll ? showLessLabel : showMoreLabel),
          onPressed: onToggle,
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState(
      {required this.message,
      required this.onFetch,
      required this.fetchLabel});

  final String message;
  final VoidCallback onFetch;
  final String fetchLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_rounded,
              size: 72,
              color:
                  Theme.of(context).colorScheme.primary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onFetch,
            icon: const Icon(Icons.download_rounded),
            label: Text(fetchLabel),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Tab ────────────────────────────────────────────────────────────────

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: active
                    ? Colors.white
                    : theme.colorScheme.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

