import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hadith_everyday/app/router.dart';
import 'package:hadith_everyday/app/theme.dart';
import 'package:hadith_everyday/l10n/app_localizations.dart';
import 'package:hadith_everyday/presentation/providers/settings_provider.dart';

class HadithApp extends ConsumerWidget {
  const HadithApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      // ── Identity ──────────────────────────────────────────────────────────
      title: 'Daily Hadith',
      debugShowCheckedModeBanner: false,

      // ── Router ────────────────────────────────────────────────────────────
      routerConfig: appRouter,

      // ── Theme ─────────────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ── Localization ──────────────────────────────────────────────────────
      locale: Locale(settings.language),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
