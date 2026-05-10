import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'main_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _isAuthenticating = false;
  String? _errorMessage;

  // Animasi controller untuk ikon gembok (pulse saat gagal)
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup shake animation untuk feedback visual saat gagal
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -14), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -14, end: 14), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 14, end: -10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    // Panggil otentikasi otomatis dengan sedikit delay agar UI sudah ter-render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), _authenticate);
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    bool authenticated = false;

    try {
      // Cek apakah perangkat mendukung biometrik atau keamanan lain
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      if (!canCheckBiometrics && !isDeviceSupported) {
        // Perangkat tidak punya keamanan — langsung masuk
        if (mounted) _goToMainScreen();
        return;
      }

      authenticated = await _auth.authenticate(
        localizedReason:
            'Gunakan sidik jari atau PIN untuk membuka Money Tracker',
      );
    } on PlatformException catch (e) {
      // Tangani error spesifik (e.g., biometrik tidak terdaftar)
      setState(() {
        _errorMessage = _getFriendlyError(e.code);
      });
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }

    if (authenticated && mounted) {
      HapticFeedback.lightImpact();
      _goToMainScreen();
    } else if (!authenticated && mounted && _errorMessage == null) {
      // Pengguna membatalkan — tetap di lock screen
      setState(() {
        _errorMessage =
            'Otentikasi dibatalkan. Tekan tombol untuk mencoba lagi.';
      });
    }
  }

  void _goToMainScreen() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  /// Mengubah kode error PlatformException menjadi pesan ramah pengguna
  String _getFriendlyError(String code) {
    switch (code) {
      case 'NotEnrolled':
        return 'Belum ada biometrik yang terdaftar. Gunakan PIN perangkat.';
      case 'LockedOut':
        return 'Terlalu banyak percobaan gagal. Coba lagi nanti.';
      case 'PermanentlyLockedOut':
        return 'Biometrik dikunci permanen. Buka kunci via pengaturan perangkat.';
      default:
        return 'Terjadi kesalahan otentikasi. Silakan coba lagi.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // Latar belakang gradient gelap premium
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0E1A), Color(0xFF0D1B2A), Color(0xFF0A1628)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative background blobs ──────────────────────────
              Positioned(
                top: -size.height * 0.1,
                right: -size.width * 0.2,
                child: _buildBlob(
                  size: size.width * 0.7,
                  color: const Color(0xFF009688).withValues(alpha: 0.12),
                ),
              ),
              Positioned(
                bottom: -size.height * 0.1,
                left: -size.width * 0.25,
                child: _buildBlob(
                  size: size.width * 0.8,
                  color: const Color(0xFF004D40).withValues(alpha: 0.18),
                ),
              ),

              // ── Konten utama ─────────────────────────────────────────
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),

                        // ── Logo / App branding ───────────────────────
                        _buildAppBadge(),

                        const SizedBox(height: 40),

                        // ── Ikon Gembok (dengan shake animation) ─────
                        AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: child,
                          ),
                          child: _buildLockIcon(),
                        ),

                        const SizedBox(height: 32),

                        // ── Teks judul ────────────────────────────────
                        Text(
                          'Money Tracker\nTerkunci',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.25,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Verifikasi identitasmu untuk\nmengakses data keuanganmu',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.55),
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // ── Tombol Buka Kunci ─────────────────────────
                        _buildUnlockButton(),

                        const SizedBox(height: 20),

                        // ── Pesan error (jika ada) ────────────────────
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _errorMessage != null
                              ? _buildErrorChip(_errorMessage!)
                              : const SizedBox(height: 20),
                        ),

                        const Spacer(flex: 3),

                        // ── Footer ────────────────────────────────────
                        _buildFooter(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widget Builders ──────────────────────────────────────────────────────

  Widget _buildBlob({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildAppBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF009688), Color(0xFF00BFA5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF009688).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Money Tracker',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLockIcon() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF1A3A35).withValues(alpha: 0.9),
            const Color(0xFF0D2320).withValues(alpha: 0.95),
          ],
          radius: 0.85,
        ),
        border: Border.all(
          color: const Color(0xFF009688).withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009688).withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        _isAuthenticating ? Icons.fingerprint : Icons.lock_outline_rounded,
        size: 50,
        color: _isAuthenticating
            ? const Color(0xFF26A69A)
            : const Color(0xFF80CBC4),
      ),
    );
  }

  Widget _buildUnlockButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isAuthenticating ? null : _authenticate,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.transparent,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ).copyWith(
              // Gunakan overlay gradient menggunakan Ink
              overlayColor: WidgetStateProperty.all(
                Colors.white.withValues(alpha: 0.08),
              ),
            ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: _isAuthenticating
                ? LinearGradient(
                    colors: [
                      const Color(0xFF009688).withValues(alpha: 0.5),
                      const Color(0xFF00BFA5).withValues(alpha: 0.5),
                    ],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF009688), Color(0xFF00BFA5)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isAuthenticating
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF009688).withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isAuthenticating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Memverifikasi...',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fingerprint, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Buka Kunci',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorChip(String message) {
    return Container(
      key: ValueKey(message),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEF5350).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF5350).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFEF5350),
            size: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFFEF9090),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Data keuanganmu aman & terenkripsi',
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.white.withValues(alpha: 0.3),
        letterSpacing: 0.2,
      ),
    );
  }
}
