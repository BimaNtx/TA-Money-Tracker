import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/currency_formatter.dart';

// Palet warna konsisten dengan tema aplikasi
const _kIncomeColor = Color(0xFF26A69A); // Teal — pemasukan
const _kExpenseColor = Color(0xFFEF5350); // Red — pengeluaran
const _kNeutralColor = Color(0xFFE0E0E0); // Abu — state kosong

/// Card visualisasi statistik keuangan bulanan menggunakan Donut Chart.
class MonthlyStatsCard extends StatefulWidget {
  final int monthlyIncome;
  final int monthlyExpense;
  final String monthLabel; // Contoh: "Mei 2026"
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  const MonthlyStatsCard({
    super.key,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthLabel,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  @override
  State<MonthlyStatsCard> createState() => _MonthlyStatsCardState();
}

class _MonthlyStatsCardState extends State<MonthlyStatsCard> {
  int? _touchedIndex;

  bool get _hasData => widget.monthlyIncome > 0 || widget.monthlyExpense > 0;

  List<PieChartSectionData> _buildSections() {
    final total = (widget.monthlyIncome + widget.monthlyExpense).toDouble();

    if (!_hasData) {
      // State kosong — satu section abu-abu
      return [
        PieChartSectionData(
          value: 1,
          color: _kNeutralColor,
          radius: 36,
          showTitle: false,
        ),
      ];
    }

    final incomeRatio = widget.monthlyIncome / total;
    final expenseRatio = widget.monthlyExpense / total;

    return [
      // Section Pemasukan
      PieChartSectionData(
        value: incomeRatio * 100,
        color: _kIncomeColor,
        radius: _touchedIndex == 0 ? 44 : 38,
        showTitle: false,
      ),
      // Section Pengeluaran
      PieChartSectionData(
        value: expenseRatio * 100,
        color: _kExpenseColor,
        radius: _touchedIndex == 1 ? 44 : 38,
        showTitle: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0);
    final titleColor =
        isDark ? Colors.white : const Color(0xFF212121);
    final subColor =
        isDark ? const Color(0xFFAAAAAA) : const Color(0xFF9E9E9E);
    final dividerColor =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);
    final selisihLabelColor =
        isDark ? const Color(0xFFAAAAAA) : const Color(0xFF757575);
    final emptyTextColor =
        isDark ? const Color(0xFF555555) : const Color(0xFFBDBDBD);

    final total = widget.monthlyIncome + widget.monthlyExpense;
    final incomePercent = total > 0
        ? (widget.monthlyIncome / total * 100).toStringAsFixed(0)
        : '0';
    final expensePercent = total > 0
        ? (widget.monthlyExpense / total * 100).toStringAsFixed(0)
        : '0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF009688).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  size: 18,
                  color: Color(0xFF009688),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Bulanan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    // Navigasi bulan: panah kiri — label — panah kanan
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            splashRadius: 16,
                            icon: const Icon(
                              Icons.chevron_left,
                              size: 20,
                              color: Color(0xFF009688),
                            ),
                            onPressed: widget.onPreviousMonth,
                          ),
                        ),
                        Text(
                          widget.monthLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF009688),
                          ),
                        ),
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            splashRadius: 16,
                            icon: const Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: Color(0xFF009688),
                            ),
                            onPressed: widget.onNextMonth,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart + Legend berdampingan
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Donut Chart
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: _buildSections(),
                        centerSpaceRadius: 32,
                        sectionsSpace: _hasData ? 3 : 0,
                        pieTouchData: PieTouchData(
                          enabled: _hasData,
                          touchCallback: (event, response) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  response == null ||
                                  response.touchedSection == null) {
                                _touchedIndex = null;
                                return;
                              }
                              _touchedIndex = response
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                      ),
                    ),
                    // Label di tengah donut
                    if (_hasData)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _touchedIndex == null
                                ? '$incomePercent%'
                                : _touchedIndex == 0
                                    ? '$incomePercent%'
                                    : '$expensePercent%',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _touchedIndex == null
                                  ? titleColor
                                  : _touchedIndex == 0
                                      ? _kIncomeColor
                                      : _kExpenseColor,
                            ),
                          ),
                          Text(
                            _touchedIndex == null
                                ? 'Total'
                                : _touchedIndex == 0
                                    ? 'Masuk'
                                    : 'Keluar',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: subColor,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Kosong',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: emptyTextColor,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Legend nominal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(
                      color: _kIncomeColor,
                      label: 'Pemasukan',
                      amount: widget.monthlyIncome,
                      percent: incomePercent,
                      isEmpty: !_hasData,
                    ),
                    const SizedBox(height: 14),
                    _buildLegendItem(
                      color: _kExpenseColor,
                      label: 'Pengeluaran',
                      amount: widget.monthlyExpense,
                      percent: expensePercent,
                      isEmpty: !_hasData,
                    ),
                    if (_hasData) ...[
                      const SizedBox(height: 14),
                      // Divider tipis
                      Container(
                        height: 1,
                        color: dividerColor,
                      ),
                      const SizedBox(height: 10),
                      // Net balance bulan ini
                      Row(
                        children: [
                          Text(
                            'Selisih',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: selisihLabelColor,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatCurrency(
                                widget.monthlyIncome - widget.monthlyExpense),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.monthlyIncome >= widget.monthlyExpense
                                  ? _kIncomeColor
                                  : _kExpenseColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Pesan kosong di bawah chart jika belum ada data bulan terpilih
          if (!_hasData)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  'Belum ada transaksi bulan ini',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: emptyTextColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int amount,
    required String percent,
    required bool isEmpty,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dot indikator warna
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isEmpty ? _kNeutralColor : color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF757575),
                    ),
                  ),
                  if (!isEmpty) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$percent%',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isEmpty ? 'Rp 0' : formatCurrency(amount),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isEmpty ? _kNeutralColor : const Color(0xFF212121),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
