import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';

/// Widget kartu Smart Insight — menampilkan analisis keuangan bulanan.
///
/// Menerima daftar [transactions] (sudah difilter per bulan) dan
/// menghasilkan insight teks secara mandiri tanpa state eksternal.
class SmartInsightCard extends StatelessWidget {
  /// Transaksi bulan yang sedang ditampilkan (sudah difilter dari luar).
  final List<Transaction> transactions;

  const SmartInsightCard({super.key, required this.transactions});

  // ── Logika analisis ─────────────────────────────────────────────────────
  List<String> _generateInsights() {
    if (transactions.isEmpty) {
      return ['Belum ada cukup data untuk dianalisis bulan ini.'];
    }

    final incomeList = transactions
        .where((t) => t.type == TransactionType.income)
        .toList();
    final expenseList = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final totalIncome = incomeList.fold<int>(0, (sum, t) => sum + t.amount);
    final totalExpense = expenseList.fold<int>(0, (sum, t) => sum + t.amount);

    final insights = <String>[];

    // Insight 1: Kesehatan finansial
    if (totalExpense > totalIncome) {
      insights.add('Awas, pengeluaranmu bulan ini sudah melebihi pemasukan!');
    } else if (totalIncome > 0) {
      insights.add(
        'Kondisi keuanganmu sehat. Pemasukan lebih besar dari pengeluaran!',
      );
    }

    // Insight 2: Kategori pengeluaran terbesar
    if (expenseList.isNotEmpty) {
      final categoryTotals = <String, int>{};
      for (final t in expenseList) {
        categoryTotals[t.category] =
            (categoryTotals[t.category] ?? 0) + t.amount;
      }
      final biggestCategory = categoryTotals.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      insights.add(
        'Pengeluaran terbesarmu bocor di kategori $biggestCategory.',
      );
    }

    // Insight 3: Kategori paling sering ditambahkan
    if (transactions.isNotEmpty) {
      final frequencyMap = <String, int>{};
      for (final t in transactions) {
        frequencyMap[t.category] = (frequencyMap[t.category] ?? 0) + 1;
      }
      final mostFrequent = frequencyMap.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      insights.add(
        'Kamu paling sering bertransaksi untuk keperluan $mostFrequent.',
      );
    }

    return insights;
  }

  // ── UI premium card ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark
        ? const Color(0xFF003D36).withValues(alpha: 0.45)
        : const Color(0xFFE0F7F4).withValues(alpha: 0.80);
    final cardBorder = isDark
        ? const Color(0xFF26A69A).withValues(alpha: 0.25)
        : const Color(0xFF80CBC4).withValues(alpha: 0.50);
    final headerColor = isDark ? Colors.white : const Color(0xFF1A237E);
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontFamily: GoogleFonts.poppins().fontFamily,
      fontSize: 13,
      height: 1.5,
    );

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF009688,
            ).withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFFD740), Color(0xFFFFA000)],
                ).createShader(bounds),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Smart Insight',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: headerColor,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF009688), Color(0xFF26A69A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'AI',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Subtle divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF009688).withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Insight items
          ...insights.asMap().entries.map((entry) {
            final isWarning = entry.value.startsWith('Awas');
            final bulletColor = isWarning
                ? const Color(0xFFEF5350)
                : const Color(0xFF26A69A);
            final bulletIcon = isWarning
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded;

            return Padding(
              padding: EdgeInsets.only(top: entry.key == 0 ? 2 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(bulletIcon, size: 15, color: bulletColor),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: bodyStyle?.copyWith(
                        color: isDark
                            ? const Color(0xFFCCCCCC)
                            : const Color(0xFF424242),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
