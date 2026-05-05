import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../widgets/balance_card.dart';
import '../widgets/monthly_stats_card.dart';
import '../widgets/transaction_tile.dart';

/// Halaman utama (Tab 0) — saldo, statistik bulanan, dan 5 transaksi terakhir
class HomeScreen extends StatelessWidget {
  final List<Transaction> transactions;
  final VoidCallback? onViewAll;

  const HomeScreen({
    super.key,
    required this.transactions,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // ── Total keseluruhan (untuk BalanceCard) ──────────────────────────────
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final totalBalance = totalIncome - totalExpense;

    // ── Filter bulan berjalan (untuk MonthlyStatsCard) ─────────────────────
    final thisMonthTx = transactions.where(
      (t) => t.createdAt.year == now.year && t.createdAt.month == now.month,
    );
    final monthlyIncome = thisMonthTx
        .where((t) => t.type == TransactionType.income)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final monthlyExpense = thisMonthTx
        .where((t) => t.type == TransactionType.expense)
        .fold<int>(0, (sum, t) => sum + t.amount);

    // Label bulan dalam Bahasa Indonesia (menggunakan intl)
    final monthLabel = DateFormat('MMMM yyyy', 'id_ID').format(now);

    // ── 5 transaksi terakhir ───────────────────────────────────────────────
    final recentTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final displayList = recentTransactions.take(5).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // ── Header + Cards ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  Text(
                    'Halo, Bima 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF212121),
                    ),
                  )
                      .animate()
                      .fade(duration: 400.ms)
                      .slideY(begin: -0.15, end: 0, curve: Curves.easeOut),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola keuanganmu hari ini',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  )
                      .animate()
                      .fade(duration: 400.ms, delay: 80.ms)
                      .slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
                  const SizedBox(height: 20),

                  // Balance Card
                  BalanceCard(
                    totalBalance: totalBalance,
                    totalIncome: totalIncome,
                    totalExpense: totalExpense,
                  )
                      .animate()
                      .fade(duration: 500.ms, delay: 150.ms)
                      .slideY(
                        begin: 0.12,
                        end: 0,
                        delay: 150.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 16),

                  // ── Monthly Stats Card (BARU) ─────────────────────────
                  MonthlyStatsCard(
                    monthlyIncome: monthlyIncome,
                    monthlyExpense: monthlyExpense,
                    monthLabel: monthLabel,
                  )
                      .animate()
                      .fade(duration: 500.ms, delay: 250.ms)
                      .slideY(
                        begin: 0.12,
                        end: 0,
                        delay: 250.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 28),

                  // Section header transaksi terakhir
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaksi Terakhir',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212121),
                        ),
                      ),
                      if (transactions.length > 5)
                        TextButton(
                          onPressed: onViewAll,
                          child: Text(
                            'Lihat Semua',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF009688),
                            ),
                          ),
                        ),
                    ],
                  )
                      .animate()
                      .fade(duration: 400.ms, delay: 350.ms),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── List transaksi terakhir — staggered per item ───────────────
          if (displayList.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada transaksi',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tekan + untuk menambah transaksi pertamamu',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final delay = (400 + index * 60).ms;
                    return TransactionTile(
                      transaction: displayList[index],
                    )
                        .animate()
                        .fade(duration: 350.ms, delay: delay)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          delay: delay,
                          duration: 350.ms,
                          curve: Curves.easeOutCubic,
                        );
                  },
                  childCount: displayList.length,
                ),
              ),
            ),

          // Bottom padding agar tidak tertutup FAB
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}
