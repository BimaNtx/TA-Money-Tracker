import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'main_screen.dart';

// ── Data model untuk setiap halaman onboarding ────────────────────────────────
class _OnboardingPage {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
  });
}

const _pages = [
  _OnboardingPage(
    icon: Icons.account_balance_wallet_rounded,
    gradientColors: [Color(0xFF4DB6AC), Color(0xFF00796B)],
    title: 'Catat Keuangan',
    subtitle:
        'Rekam setiap pemasukan dan pengeluaranmu dengan mudah, kapan saja dan di mana saja.',
  ),
  _OnboardingPage(
    icon: Icons.pie_chart_rounded,
    gradientColors: [Color(0xFF7986CB), Color(0xFF3F51B5)],
    title: 'Analisis Pengeluaran',
    subtitle:
        'Lihat distribusi keuanganmu melalui grafik yang jelas dan laporan bulanan yang informatif.',
  ),
  _OnboardingPage(
    icon: Icons.security_rounded,
    gradientColors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    title: 'Data Aman',
    subtitle:
        'Seluruh datamu tersimpan langsung di perangkatmu — privat, aman, dan tidak butuh internet.',
  ),
];

// ── Widget utama ──────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _finish() {
    Hive.box('settings').put('hasSeenOnboarding', true);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, secondary) => const MainScreen(),
        transitionsBuilder: (ctx, animation, secondary, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Tombol Skip (pojok kanan atas) ───────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: AnimatedOpacity(
                  opacity: isLastPage ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: TextButton(
                    onPressed: isLastPage ? null : _finish,
                    child: Text(
                      'Lewati',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF009688),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── PageView ─────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageView(
                    page: _pages[index],
                    isDark: isDark,
                    isActive: index == _currentPage,
                  );
                },
              ),
            ),

            // ── Dot indicator ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _DotIndicator(
                        isActive: index == _currentPage,
                        color: _pages[_currentPage].gradientColors.last,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── CTA Button ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isLastPage
                          ? _FinishButton(
                              key: const ValueKey('finish'),
                              onPressed: _finish,
                            )
                          : _NextButton(
                              key: const ValueKey('next'),
                              onPressed: _nextPage,
                              gradientColors:
                                  _pages[_currentPage].gradientColors,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Konten satu halaman ───────────────────────────────────────────────────────
class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  final bool isDark;
  final bool isActive;

  const _OnboardingPageView({
    required this.page,
    required this.isDark,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final subtitleColor = isDark
        ? const Color(0xFFAAAAAA)
        : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ikon dengan gradient + glow
          Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: page.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: page.gradientColors.last.withValues(alpha: 0.35),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(page.icon, size: 68, color: Colors.white),
              )
              .animate(target: isActive ? 1 : 0)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fade(duration: 400.ms),

          const SizedBox(height: 48),

          // Judul
          Text(
                page.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  height: 1.2,
                ),
              )
              .animate(target: isActive ? 1 : 0)
              .fade(duration: 400.ms, delay: 100.ms)
              .slideY(
                begin: 0.2,
                end: 0,
                delay: 100.ms,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),

          const SizedBox(height: 16),

          // Subjudul
          Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: subtitleColor,
                  height: 1.6,
                ),
              )
              .animate(target: isActive ? 1 : 0)
              .fade(duration: 400.ms, delay: 180.ms)
              .slideY(
                begin: 0.15,
                end: 0,
                delay: 180.ms,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
        ],
      ),
    );
  }
}

// ── Dot indikator ─────────────────────────────────────────────────────────────
class _DotIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;

  const _DotIndicator({required this.isActive, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? color : color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ── Tombol Lanjut ─────────────────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final List<Color> gradientColors;

  const _NextButton({
    super.key,
    required this.onPressed,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lanjut',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tombol Mulai Sekarang ─────────────────────────────────────────────────────
class _FinishButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _FinishButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
          height: 56,
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4DB6AC), Color(0xFF00796B)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF009688).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Mulai Sekarang',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        )
        .fade(duration: 300.ms);
  }
}
