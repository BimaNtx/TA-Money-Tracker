import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Halaman profil (Tab 2) — info siswa, versi aplikasi, dan export CSV
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isExporting = false;

  /// Mengambil semua transaksi dari Hive, membuat file CSV,
  /// lalu membagikannya menggunakan share_plus.
  Future<void> _exportToCSV() async {
    setState(() => _isExporting = true);

    try {
      final box = Hive.box<Transaction>('transactions');
      final transactions = box.values.toList();

      // Tampilkan pesan jika data masih kosong
      if (transactions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Belum ada data transaksi untuk diekspor.',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF5C6BC0),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        return;
      }

      // Urutkan berdasarkan tanggal terlama → terbaru
      transactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Baris header CSV
      final List<List<dynamic>> rows = [
        ['Tanggal', 'Tipe', 'Keterangan', 'Nominal'],
      ];

      // Konversi setiap transaksi ke baris CSV
      final dateFormat = DateFormat('dd-MM-yyyy');
      for (final tx in transactions) {
        rows.add([
          dateFormat.format(tx.createdAt),
          tx.type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran',
          tx.description,
          tx.amount,
        ]);
      }

      // Ubah List ke string format CSV
      final csvString = const ListToCsvConverter().convert(rows);

      // Simpan ke direktori sementara
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/Laporan_Keuangan.csv';
      final file = File(filePath);
      await file.writeAsString(csvString);

      // Bagikan file menggunakan share_plus
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'text/csv')],
        subject: 'Laporan Keuangan - Money Tracker',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Laporan CSV berhasil diekspor!',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF009688),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Gagal mengekspor: ${e.toString()}',
                    style: GoogleFonts.poppins(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settingsBox = Hive.box('settings');
    final isDarkMode =
        settingsBox.get('isDarkMode', defaultValue: false) as bool;

    final titleColor =
        isDark ? Colors.white : const Color(0xFF212121);
    final subtitleColor =
        isDark ? const Color(0xFFAAAAAA) : const Color(0xFF9E9E9E);
    final sectionHeaderColor =
        isDark ? const Color(0xFFEEEEEE) : const Color(0xFF212121);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Avatar — scale + fade dari tengah
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DB6AC), Color(0xFF00796B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF009688).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor:
                    isDark ? const Color(0xFF2A2A2A) : Colors.white,
                child: const Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: Color(0xFF009688),
                ),
              ),
            )
                .animate()
                .fade(duration: 500.ms)
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 16),

            // Nama — fade + slideY
            Text(
              'Bima Ananta',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            )
                .animate()
                .fade(duration: 400.ms, delay: 150.ms)
                .slideY(begin: 0.2, end: 0, delay: 150.ms, curve: Curves.easeOut),
            const SizedBox(height: 4),

            // Keterangan kelas
            Text(
              'Siswa RPL Kelas 11',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: subtitleColor,
              ),
            )
                .animate()
                .fade(duration: 400.ms, delay: 220.ms)
                .slideY(begin: 0.2, end: 0, delay: 220.ms, curve: Curves.easeOut),
            const SizedBox(height: 32),

            // Section header — Tentang Aplikasi
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Tentang Aplikasi',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: sectionHeaderColor,
                  ),
                ),
              ),
            ).animate().fade(duration: 400.ms, delay: 300.ms),

            // Info cards — staggered slideX dari kanan
            ...[
              _buildInfoCard(
                icon: Icons.assignment_outlined,
                iconColor: const Color(0xFF009688),
                title: 'Project Ujian Akhir',
                subtitle: 'Versi 1.0',
              ),
              _buildInfoCard(
                icon: Icons.code_rounded,
                iconColor: const Color(0xFF5C6BC0),
                title: 'Developer',
                subtitle: 'Bima Ananta',
              ),
              _buildInfoCard(
                icon: Icons.school_outlined,
                iconColor: const Color(0xFFFF7043),
                title: 'Sekolah',
                subtitle: 'Jurusan Rekayasa Perangkat Lunak',
              ),
              _buildInfoCard(
                icon: Icons.flutter_dash_rounded,
                iconColor: const Color(0xFF42A5F5),
                title: 'Dibuat dengan',
                subtitle: 'Flutter & Dart',
              ),
            ].asMap().entries.map((entry) {
              final delay = (350 + entry.key * 70).ms;
              return entry.value
                  .animate()
                  .fade(duration: 400.ms, delay: delay)
                  .slideX(
                    begin: 0.15,
                    end: 0,
                    delay: delay,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            }),

            const SizedBox(height: 24),

            // Section header — Fitur
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'Fitur',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: sectionHeaderColor,
                  ),
                ),
              ),
            ).animate().fade(duration: 400.ms, delay: 630.ms),

            // ── Toggle Dark Mode ──────────────────────────────────────────
            _buildDarkModeCard(
              isDark: isDark,
              isDarkMode: isDarkMode,
              settingsBox: settingsBox,
            )
                .animate()
                .fade(duration: 400.ms, delay: 700.ms)
                .slideX(
                  begin: 0.15,
                  end: 0,
                  delay: 700.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),

            // Menu Export CSV
            _buildExportCard(isDark: isDark)
                .animate()
                .fade(duration: 400.ms, delay: 770.ms)
                .slideX(
                  begin: 0.15,
                  end: 0,
                  delay: 770.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),

            const SizedBox(height: 24),

            // Footer badge — fade
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF009688).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: Color(0xFF009688),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Money Tracker v1.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF009688),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fade(duration: 400.ms, delay: 800.ms),
          ],
        ),
      ),
    );
  }

  /// Card toggle Dark Mode
  Widget _buildDarkModeCard({
    required bool isDark,
    required bool isDarkMode,
    required Box settingsBox,
  }) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;
    final titleColor =
        isDark ? Colors.white : const Color(0xFF212121);
    final subtitleColor =
        isDark ? const Color(0xFFAAAAAA) : const Color(0xFF9E9E9E);

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SwitchListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          secondary: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF009688).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: const Color(0xFF009688),
              size: 22,
            ),
          ),
          title: Text(
            'Mode Gelap',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: titleColor,
            ),
          ),
          subtitle: Text(
            isDarkMode ? 'Aktif' : 'Nonaktif',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: subtitleColor,
            ),
          ),
          value: isDarkMode,
          activeThumbColor: const Color(0xFF009688),
          activeTrackColor: const Color(0xFF009688).withValues(alpha: 0.4),
          onChanged: (value) {
            settingsBox.put('isDarkMode', value);
          },
        ),
      ),
    );
  }

  /// Card khusus untuk tombol Export CSV dengan indikator loading
  Widget _buildExportCard({required bool isDark}) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;
    final titleColor =
        isDark ? Colors.white : const Color(0xFF212121);
    final subtitleColor =
        isDark ? const Color(0xFFAAAAAA) : const Color(0xFF9E9E9E);

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: _isExporting ? null : _exportToCSV,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isExporting
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF43A047),
                        ),
                      )
                    : const Icon(
                        Icons.download_rounded,
                        color: Color(0xFF43A047),
                        size: 22,
                      ),
              ),
              const SizedBox(width: 14),
              // Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Laporan (CSV)',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      _isExporting
                          ? 'Sedang memproses...'
                          : 'Bagikan semua transaksi sebagai file CSV',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron
              if (!_isExporting)
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? const Color(0xFF666666)
                      : const Color(0xFFBDBDBD),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card info generik (tidak dapat di-tap)
  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;
    final titleColor =
        isDark ? Colors.white : const Color(0xFF212121);
    final subtitleColor =
        isDark ? const Color(0xFFAAAAAA) : const Color(0xFF9E9E9E);

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: titleColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: subtitleColor,
          ),
        ),
      ),
    );
  }
}
