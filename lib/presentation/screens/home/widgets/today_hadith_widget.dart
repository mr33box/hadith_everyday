import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hadith_everyday/core/services/image_generator.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';
import 'package:hadith_everyday/presentation/providers/hadith_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadith_everyday/presentation/providers/settings_provider.dart';
import 'package:hadith_everyday/core/services/wallpaper_service.dart';
import 'package:hadith_everyday/core/services/hadith_preview_painter.dart';

/// The hero card shown at the top of the home screen displaying either
/// the current fetch progress or the latest generated hadith image.
class TodayHadithWidget extends StatelessWidget {
  const TodayHadithWidget({
    super.key,
    required this.fetchState,
    required this.onFetch,
    required this.isRtl,
  });

  final FetchState fetchState;
  final VoidCallback onFetch;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: fetchState.isLoading
          ? _LoadingCard(stage: fetchState.stage, key: const ValueKey('loading'))
          : fetchState.hadith != null
              ? _HadithPreviewCard(
                  hadith: fetchState.hadith!,
                  isRtl: isRtl,
                  key: ValueKey(fetchState.hadith!.id),
                )
              : _WelcomeCard(onFetch: onFetch, key: const ValueKey('welcome')),
    );
  }
}

// ── Loading Card ──────────────────────────────────────────────────────────────

class _LoadingCard extends StatefulWidget {
  const _LoadingCard({super.key, required this.stage});
  final FetchStage stage;

  @override
  State<_LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<_LoadingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = {
      FetchStage.fetchingHadith: ('Fetching a new hadith...', Icons.cloud_download_rounded),
      FetchStage.generatingImage: ('Generating wallpaper image...', Icons.image_rounded),
      FetchStage.settingWallpaper: ('Setting wallpaper...', Icons.wallpaper_rounded),
    };
    final (label, icon) = labels[widget.stage] ?? ('Working...', Icons.hourglass_empty);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1 + _pulse.value * 0.05),
              theme.colorScheme.secondary.withOpacity(0.05 + _pulse.value * 0.05),
            ],
          ),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2 + _pulse.value * 0.1),
          ),
        ),
        child: child,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 20),
          SizedBox(
            width: 160,
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(8),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hadith Preview Card ───────────────────────────────────────────────────────

class _HadithPreviewCard extends ConsumerWidget {
  const _HadithPreviewCard({super.key, required this.hadith, required this.isRtl});
  final HadithEntity hadith;
  final bool isRtl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStyle = ref.watch(settingsProvider).imageStyle;

    // Override position to always center for the home preview
    final displayStyle = currentStyle.copyWith(
      textPosX: 0.5,
      textPosY: 0.5,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 260,
            child: CustomPaint(
              painter: HadithPreviewPainter(
                hadith: hadith,
                style: displayStyle,
                titleString: isRtl ? 'قال رسول الله ﷺ' : 'The Messenger of Allah ﷺ said:',
                sourceString: isRtl
                    ? 'رواه ${hadith.getLocalizedBookName(true)}'
                    : 'Narrated by ${hadith.getLocalizedBookName(false)}',
                isRtl: isRtl,
              ),
            ),
          ),

          // Gradient overlay at the bottom
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // Book label
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    hadith.bookName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Welcome Card ──────────────────────────────────────────────────────────────

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({super.key, required this.onFetch});
  final VoidCallback onFetch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.12),
            theme.colorScheme.secondary.withOpacity(0.06),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              'بسم الله الرحمن الرحيم',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to fetch your first Daily Hadith',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onFetch,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Start Now'),
          ),
        ],
      ),
    );
  }
}
