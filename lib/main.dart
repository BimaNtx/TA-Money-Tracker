import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/transaction.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive & daftarkan adapter
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>('transactions');

  // Box pengaturan aplikasi (dark mode, dll.)
  await Hive.openBox('settings');

  // Inisialisasi locale Indonesia untuk format tanggal
  await initializeDateFormatting('id_ID', null);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get _lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF009688),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF212121),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF212121)),
        ),
        cardColor: Colors.white,
        dividerColor: const Color(0xFFF0F0F0),
      );

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get _darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF009688),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: const Color(0xFF2C2C2C),
      );

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(),
      builder: (context, box, _) {
        final isDark = box.get('isDarkMode', defaultValue: false) as bool;
        final hasSeenOnboarding =
            box.get('hasSeenOnboarding', defaultValue: false) as bool;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Money Tracker',
          theme: _lightTheme,
          darkTheme: _darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home:
              hasSeenOnboarding ? const MainScreen() : const OnboardingScreen(),
        );
      },
    );
  }
}