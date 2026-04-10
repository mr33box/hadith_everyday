import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';
import 'package:hadith_everyday/presentation/providers/favorites_provider.dart';

/// Expandable text-only history card: tap to show full hadith text.
class HadithCard extends ConsumerStatefulWidget {
  const HadithCard({
    super.key,
    required this.hadith,
    required this.isRtl,
    required this.onDelete,
  });

  final HadithEntity hadith;
  final bool isRtl;
  final VoidCallback onDelete;

  @override
  ConsumerState<HadithCard> createState() => _HadithCardState();
}

class _HadithCardState extends ConsumerState<HadithCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnim = CurvedAnimation(
        parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFav = ref.watch(favoritesProvider).contains(widget.hadith.id);
    final isRtl = widget.isRtl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _toggle,
          onLongPress: widget.onDelete,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
            child: Column(
              crossAxisAlignment: isRtl
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // ── Header row: tags + actions ───────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: [
                          _Tag(label: widget.hadith.bookName, theme: theme),
                          _Tag(
                            label: '#${widget.hadith.hadithNumber}',
                            theme: theme,
                            secondary: true,
                          ),
                        ],
                      ),
                    ),
                    // Favorite
                    _Btn(
                      icon: isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav
                          ? Colors.red.shade400
                          : theme.colorScheme.onSurface.withOpacity(0.3),
                      onTap: () => ref
                          .read(favoritesProvider.notifier)
                          .toggle(widget.hadith.id),
                    ),
                    // Copy
                    _Btn(
                      icon: Icons.copy_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      onTap: _copyText,
                    ),
                    // Delete
                    _Btn(
                      icon: Icons.delete_outline_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.22),
                      onTap: widget.onDelete,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Hadith text (expandable) ───────────────────────
                Directionality(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    // Collapsed: 3 lines max
                    firstChild: Text(
                      widget.hadith.getLocalizedText(isRtl),
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.7,
                        fontSize: 14,
                      ),
                    ),
                    // Expanded: full text
                    secondChild: Text(
                      widget.hadith.getLocalizedText(isRtl),
                      textAlign: isRtl ? TextAlign.right : TextAlign.left,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.7,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // Expand/collapse hint
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: theme.colorScheme.primary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),

                // ── Date ─────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 11,
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.35)),
                    const SizedBox(width: 3),
                    Text(
                      DateFormat('MMM d, yyyy · HH:mm')
                          .format(widget.hadith.fetchedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.35),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: widget.hadith.getLocalizedText(widget.isRtl)));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_rounded, color: Colors.white, size: 16),
        SizedBox(width: 8),
        Text('Hadith copied'),
      ]),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}

// ─── Helper Widgets ────────────────────────────────────────────────────────────

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.theme, this.secondary = false});
  final String label;
  final ThemeData theme;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: secondary
            ? theme.colorScheme.secondary.withOpacity(0.12)
            : theme.colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: secondary
              ? theme.colorScheme.secondary
              : theme.colorScheme.primary,
        ),
      ),
    );
  }
}
