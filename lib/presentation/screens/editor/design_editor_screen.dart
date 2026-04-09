import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadith_everyday/core/services/hadith_preview_painter.dart';
import 'package:hadith_everyday/core/services/image_generator.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';
import 'package:hadith_everyday/presentation/providers/hadith_provider.dart';
import 'package:hadith_everyday/presentation/providers/settings_provider.dart';
import 'package:hadith_everyday/l10n/app_localizations.dart';
import 'package:hadith_everyday/core/constants/app_constants.dart';

/// Live design editor — uses CustomPainter for instant preview.
/// No async file I/O on every control change.
class DesignEditorScreen extends ConsumerStatefulWidget {
  const DesignEditorScreen({super.key, required this.hadith});
  final HadithEntity hadith;

  @override
  ConsumerState<DesignEditorScreen> createState() => _DesignEditorScreenState();
}

class _DesignEditorScreenState extends ConsumerState<DesignEditorScreen> {
  // Draggable text position (0.0–1.0, Y fraction of available range)
  double _textYFraction = 0.5; // centered by default

  bool _applying = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    // Build painter from current settings — repaints instantly on setState
    final painter = HadithPreviewPainter(
      hadith: widget.hadith,
      bgStyle: settings.bgStyle,
      fontScale: settings.fontScale,
      textAlign: _resolveTextAlign(settings.textAlignIndex),
      isRtl: settings.language == AppConstants.langAr,
      titleString: settings.language == AppConstants.langAr 
          ? 'قال رسول الله ﷺ' 
          : 'The Messenger of Allah ﷺ said:',
      sourceString: settings.language == AppConstants.langAr
          ? 'رواه ${widget.hadith.getLocalizedBookName(true)}'
          : 'Narrated by ${widget.hadith.getLocalizedBookName(false)}',
      customBgColor1: settings.bgStyleIndex == 3 ? settings.bgColor1 : null,
      customBgColor2: settings.bgStyleIndex == 3 ? settings.bgColor2 : null,
      customTextColor: settings.bgStyleIndex == 3 ? settings.textColor : null,
      customTitleColor: settings.bgStyleIndex == 3 ? settings.titleColor : null,
      textOffsetFraction: Offset(0.5, _textYFraction),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.editorTitle),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(l10n.editorReset),
            onPressed: () {
              notifier.resetDesign();
              setState(() => _textYFraction = 0.5);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Live Preview — device screen aspect ratio ───────────────────────
          Expanded(
            flex: 5,
            child: Builder(builder: (ctx) {
              final mq = MediaQuery.of(ctx);
              final deviceRatio = mq.size.width / mq.size.height;
              
              return Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: deviceRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        color: Colors.black,
                        child: LayoutBuilder(
                          builder: (ctx2, constraints) {
                            return GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  _textYFraction = (_textYFraction +
                                          details.delta.dy / constraints.maxHeight)
                                      .clamp(0.0, 1.0);
                                });
                              },
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CustomPaint(
                                    painter: painter,
                                    size: Size(constraints.maxWidth, constraints.maxHeight),
                                  ),
                                  // Drag hint
                                  Positioned(
                                    bottom: 8, left: 0, right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.open_with_rounded,
                                                size: 13, color: Colors.white70),
                                            const SizedBox(width: 4),
                                            const Text('Drag text to move',
                                                style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // ── Controls ──────────────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // Apply this style button
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FilledButton.icon(
                    icon: _applying
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_rounded),
                    label: Text(_applying
                        ? l10n.generatingImage
                        : l10n.editorApply),
                    onPressed: _applying ? null : () => _applyStyle(l10n),
                  ),
                ),

                // Regenerate (same hadith, new design)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.autorenew_rounded),
                    label: Text(l10n.regenerateStyle),
                    onPressed: _applying
                        ? null
                        : () {
                            ref
                                .read(hadithFetchProvider.notifier)
                                .regenerateCurrentHadith();
                            Navigator.of(context).pop();
                          },
                  ),
                ),

                // Background style
                _Section(
                  title: l10n.editorBackground,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _Chip(l10n.settingsBgWarm,   0, settings.bgStyleIndex, (i) => notifier.setBgStyle(i)),
                      _Chip(l10n.settingsBgDark,   1, settings.bgStyleIndex, (i) => notifier.setBgStyle(i)),
                      _Chip(l10n.settingsBgLight,  2, settings.bgStyleIndex, (i) => notifier.setBgStyle(i)),
                      _Chip(l10n.settingsBgCustom, 3, settings.bgStyleIndex, (i) => notifier.setBgStyle(i)),
                    ],
                  ),
                ),

                // Custom colors
                if (settings.bgStyleIndex == 3) ...[
                  _Section(
                    title: l10n.editorBgColors,
                    child: Wrap(
                      spacing: 10, runSpacing: 8,
                      children: [
                        _ColorBtn(l10n.colorTop,    settings.bgColor1,  (c) => notifier.setBgColor1(c)),
                        _ColorBtn(l10n.colorBottom, settings.bgColor2,  (c) => notifier.setBgColor2(c)),
                      ],
                    ),
                  ),
                  _Section(
                    title: l10n.editorTextColors,
                    child: Wrap(
                      spacing: 10, runSpacing: 8,
                      children: [
                        _ColorBtn(l10n.colorHadithText,   settings.textColor,  (c) => notifier.setTextColor(c)),
                        _ColorBtn(l10n.colorTitleSource,  settings.titleColor, (c) => notifier.setTitleColor(c)),
                      ],
                    ),
                  ),
                ],

                // Font size
                _Section(
                  title: '${l10n.editorFontSize} — ${(settings.fontScale * 100).toInt()}%',
                  child: Slider(
                    value: settings.fontScale,
                    min: 0.6, max: 1.5, divisions: 9,
                    label: '${(settings.fontScale * 100).toInt()}%',
                    onChanged: (v) => notifier.setFontScale(v),
                  ),
                ),

                // Text alignment
                _Section(
                  title: l10n.editorAlignment,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _Chip(l10n.settingsTextAlignCenter, 0, settings.textAlignIndex, (i) => notifier.setTextAlign(i)),
                      _Chip(l10n.settingsTextAlignRight,  1, settings.textAlignIndex, (i) => notifier.setTextAlign(i)),
                      _Chip(l10n.settingsTextAlignLeft,   2, settings.textAlignIndex, (i) => notifier.setTextAlign(i)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextAlign _resolveTextAlign(int index) => switch (index) {
        1 => TextAlign.right,
        2 => TextAlign.left,
        _ => TextAlign.center,
      };

  Future<void> _applyStyle(AppLocalizations l10n) async {
    setState(() => _applying = true);
    await ref.read(hadithFetchProvider.notifier).regenerateCurrentHadith();
    if (mounted) {
      setState(() => _applying = false);
      Navigator.of(context).pop();
    }
  }
}

// ─── Section / Chip / ColorBtn helpers ────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
          const SizedBox(height: 8),
          child,
          const Divider(height: 14),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.index, this.current, this.onTap);
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(index),
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
          color: selected ? Colors.white : null,
          fontWeight: FontWeight.w500),
    );
  }
}

class _ColorBtn extends StatelessWidget {
  const _ColorBtn(this.label, this.color, this.onPick);
  final String label;
  final Color color;
  final void Function(Color) onPick;

  static const _palette = [
    Color(0xFFF5DEB3), Color(0xFFDEB887), Color(0xFFC8965C), Color(0xFF8B5E3C),
    Color(0xFFD4AF37), Color(0xFF8B4513), Color(0xFFF5ECD7), Color(0xFF2C1A0E),
    Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460), Color(0xFF2196F3),
    Colors.white, Colors.black87, Color(0xFF4CAF50), Color(0xFFE91E63),
    Color(0xFF9C27B0), Color(0xFFFF9800), Color(0xFF00BCD4), Color(0xFF607D8B),
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _show(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10, runSpacing: 10,
                children: _palette.map((c) {
                  final sel = c.value == color.value;
                  return GestureDetector(
                    onTap: () { onPick(c); Navigator.pop(context); },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: c, shape: BoxShape.circle,
                        border: Border.all(
                          color: sel ? Colors.blue : Colors.grey.shade300,
                          width: sel ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
