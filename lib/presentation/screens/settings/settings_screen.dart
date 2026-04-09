import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hadith_everyday/core/constants/app_constants.dart';
import 'package:hadith_everyday/presentation/providers/hadith_provider.dart';
import 'package:hadith_everyday/presentation/providers/settings_provider.dart';
import 'package:hadith_everyday/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final isRtl = settings.language == 'ar';
    final fetchState = ref.watch(hadithFetchProvider);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.settingsTitle)),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ── General ─────────────────────────────────────────────────────
            _SectionHeader(label: l10n.settingsGeneral),

            _SettingsTile(
              icon: Icons.dark_mode_rounded,
              title: l10n.settingsDarkMode,
              trailing: Switch(
                value: settings.isDarkMode,
                onChanged: notifier.setDarkMode,
              ),
            ),

            _SettingsTile(
              icon: Icons.language_rounded,
              title: l10n.settingsLanguage,
              trailing: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: AppConstants.langEn,
                    label: Text(l10n.settingsLanguageEn,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  ButtonSegment(
                    value: AppConstants.langAr,
                    label: Text(l10n.settingsLanguageAr,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ],
                selected: {settings.language},
                onSelectionChanged: (s) => notifier.setLanguage(s.first),
              ),
            ),

            const SizedBox(height: 4),

            // ── Wallpaper ────────────────────────────────────────────────────
            _SectionHeader(label: l10n.settingsWallpaper),

            _SettingsTile(
              icon: Icons.wallpaper_rounded,
              title: l10n.settingsAutoWallpaper,
              subtitle: l10n.settingsAutoWallpaperDesc,
              trailing: Switch(
                value: settings.autoWallpaper,
                onChanged: notifier.setAutoWallpaper,
              ),
            ),

            AnimatedOpacity(
              opacity: settings.autoWallpaper ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 250),
              child: _IntervalSelector(
                current: settings.intervalMinutes,
                onChanged:
                    settings.autoWallpaper ? notifier.setInterval : null,
                l10n: l10n,
              ),
            ),

            const SizedBox(height: 4),

            // ── Image Customization ──────────────────────────────────────────
            _SectionHeader(label: l10n.settingsImageCustom),

            // Open Editor button
            _SettingsTile(
              icon: Icons.palette_rounded,
              title: l10n.settingsOpenEditor,
              subtitle: l10n.settingsOpenEditorDesc,
              trailing: Icon(
                isRtl
                    ? Icons.arrow_back_ios_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              onTap: fetchState.hadith != null
                  ? () => context.pushNamed('editor',
                      extra: fetchState.hadith!)
                  : null,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 11,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// ─── Generic Settings Tile ────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12))
            : null,
        trailing: trailing,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

// ─── Interval Selector ────────────────────────────────────────────────────────

class _IntervalSelector extends StatelessWidget {
  const _IntervalSelector({
    required this.current,
    required this.onChanged,
    required this.l10n,
  });

  final int current;
  final ValueChanged<int>? onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = [
      (AppConstants.intervalOneHour, l10n.intervalHour),
      (AppConstants.intervalSixHours, l10n.intervalSixHours),
      (AppConstants.intervalTwelveHours, l10n.intervalTwelveHours),
      (AppConstants.intervalOneDay, l10n.intervalDay),
      (AppConstants.intervalThreeDays, l10n.intervalThreeDays),
      (AppConstants.intervalOneWeek, l10n.intervalWeek),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.timer_rounded,
                      size: 20, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Text(l10n.settingsInterval,
                    style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: options.map((opt) {
                final (minutes, label) = opt;
                final selected = minutes == current;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected:
                      onChanged != null ? (_) => onChanged!(minutes) : null,
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
