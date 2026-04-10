import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadith_everyday/core/constants/app_constants.dart';
import 'package:hadith_everyday/presentation/providers/settings_provider.dart';
import 'package:hadith_everyday/l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyIsFirstLaunch, false);
    if (mounted) context.goNamed('home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRtl = ref.watch(settingsProvider).language == AppConstants.langAr;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF0F1020), const Color(0xFF1A1A2E)]
                  : [const Color(0xFFFFF8EE), const Color(0xFFF5DEB3)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    children: [
                      _buildLanguageSelection(theme, l10n),
                      _buildPage(
                        icon: Icons.auto_awesome_rounded,
                        title: l10n.onboardingWelcome,
                        description: l10n.aboutAppDesc,
                        theme: theme,
                      ),
                      _buildPage(
                        icon: Icons.wallpaper_rounded,
                        title: l10n.featureWallpaper,
                        description: l10n.onboardingUpdate,
                        theme: theme,
                      ),
                      _buildPage(
                        icon: Icons.color_lens_rounded,
                        title: l10n.featureCustom,
                        description: l10n.onboardingCustom,
                        theme: theme,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                // Dots indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelection(ThemeData theme, AppLocalizations l10n) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentLang = ref.watch(settingsProvider).language;
    final isRtl = currentLang == AppConstants.langAr;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language_rounded, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            isRtl ? 'اختر لغتك' : 'Choose your language',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 48),
          
          _LangCard(
            title: 'English',
            subtitle: 'English',
            isSelected: currentLang == AppConstants.langEn,
            onTap: () {
              settingsNotifier.setLanguage(AppConstants.langEn);
            },
          ),
          const SizedBox(height: 16),
          _LangCard(
            title: 'العربية',
            subtitle: 'Arabic',
            isSelected: currentLang == AppConstants.langAr,
            onTap: () {
              settingsNotifier.setLanguage(AppConstants.langAr);
            },
          ),
          const SizedBox(height: 64),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: Text(isRtl ? 'التالي' : 'Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String description,
    required ThemeData theme,
    bool isLast = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = ref.watch(settingsProvider).language == AppConstants.langAr;
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.15),
            ),
            child: Icon(icon, size: 80, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              height: 1.5,
              color: theme.textTheme.titleMedium?.color?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 64),
          if (isLast)
            ElevatedButton(
              onPressed: _finishOnboarding,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Text(l10n.startButton),
            )
          else
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Icon(isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded),
            ),
        ],
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  const _LangCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
