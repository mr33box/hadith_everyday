import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadith_everyday/domain/entities/hadith_entity.dart';
import 'package:hadith_everyday/presentation/providers/hadith_provider.dart';
import 'package:hadith_everyday/l10n/app_localizations.dart';

/// Full-screen gallery of all generated hadith wallpaper images.
class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(hadithHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.gallery)),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (hadiths) {
          final withImages = hadiths
              .where((h) =>
                  h.imagePath != null && File(h.imagePath!).existsSync())
              .toList();

          if (withImages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library_outlined,
                        size: 72,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(l10n.galleryEmpty,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5))),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 9 / 16,
            ),
            itemCount: withImages.length,
            itemBuilder: (context, index) =>
                _GalleryTile(hadith: withImages[index]),
          );
        },
      ),
    );
  }
}

// ─── Grid Tile ─────────────────────────────────────────────────────────────────

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.hadith});
  final HadithEntity hadith;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _FullScreenImage(hadith: hadith)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(hadith.imagePath!), fit: BoxFit.cover),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Text(hadith.bookName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Full-Screen Image View ────────────────────────────────────────────────────

class _FullScreenImage extends ConsumerStatefulWidget {
  const _FullScreenImage({required this.hadith});
  final HadithEntity hadith;

  @override
  ConsumerState<_FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends ConsumerState<_FullScreenImage> {
  static const _channel = MethodChannel('com.haditheveryday/wallpaper');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.hadith.bookName,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          // Download button
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: 'Save to gallery',
            onPressed: () => _saveToGallery(context),
          ),
        ],
      ),
      body: InteractiveViewer(
        panEnabled: true,
        scaleEnabled: true,
        child: Center(child: Image.file(File(widget.hadith.imagePath!))),
      ),
    );
  }

  Future<void> _saveToGallery(BuildContext context) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'saveToGallery',
        {'imagePath': widget.hadith.imagePath!},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            Icon(
              result == true
                  ? Icons.check_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(result == true ? 'Saved to gallery' : 'Save failed'),
          ]),
          backgroundColor:
              result == true ? Colors.green.shade700 : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ));
      }
    } on PlatformException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}
