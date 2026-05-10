import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../widgets/transaction_tile.dart';

/// Halaman riwayat (Tab 1) — menampilkan semua transaksi dengan pencarian,
/// filter tipe, swipe-to-delete, dan tap-to-edit.
class HistoryScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final void Function(Transaction transaction) onEdit;
  final void Function(Transaction transaction) onDelete;

  const HistoryScreen({
    super.key,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // State pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // State filter tipe: 'Semua' | 'Pemasukan' | 'Pengeluaran'
  String _selectedFilter = 'Semua';

  static const _primaryColor = Color(0xFF009688);
  static const _filters = ['Semua', 'Pemasukan', 'Pengeluaran'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Terapkan filter pencarian + tipe ke list transaksi
  List<Transaction> _applyFilters(List<Transaction> source) {
    // 1. Sort terbaru dulu
    final sorted = List<Transaction>.from(source)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 2. Filter tipe
    final byType = sorted.where((t) {
      if (_selectedFilter == 'Pemasukan') {
        return t.type == TransactionType.income;
      } else if (_selectedFilter == 'Pengeluaran') {
        return t.type == TransactionType.expense;
      }
      return true;
    });

    // 3. Filter pencarian
    if (_searchQuery.isEmpty) return byType.toList();
    return byType
        .where(
          (t) =>
              t.description.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF212121);
    final subtitleColor = isDark
        ? const Color(0xFFAAAAAA)
        : const Color(0xFF9E9E9E);
    final searchFill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final searchBorder = isDark
        ? const Color(0xFF2C2C2C)
        : Colors.grey.shade200;
    final chipBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final chipBorder = isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade200;

    final filtered = _applyFilters(widget.transactions);
    final totalCount = widget.transactions.length;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 2),
            child: Text(
              'Riwayat Transaksi',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              '$totalCount transaksi tercatat',
              style: GoogleFonts.poppins(fontSize: 13, color: subtitleColor),
            ),
          ),

          // ── Search Bar ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: GoogleFonts.poppins(fontSize: 14, color: titleColor),
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF555555)
                      : const Color(0xFFBDBDBD),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark
                      ? const Color(0xFF777777)
                      : const Color(0xFF9E9E9E),
                  size: 22,
                ),
                // Tombol clear muncul saat ada teks
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark
                              ? const Color(0xFF777777)
                              : const Color(0xFF9E9E9E),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: searchFill,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: searchBorder, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: searchBorder, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: _primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // ── Filter Chips ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: _filters.map((filter) {
                final isActive = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : (isDark
                                  ? const Color(0xFFAAAAAA)
                                  : const Color(0xFF757575)),
                      ),
                    ),
                    selected: isActive,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    selectedColor: _primaryColor,
                    backgroundColor: chipBg,
                    side: BorderSide(
                      color: isActive ? _primaryColor : chipBorder,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── List Transaksi ──────────────────────────────────
          Expanded(child: _buildList(filtered)),
        ],
      ),
    );
  }

  Widget _buildList(List<Transaction> filtered) {
    // Tidak ada transaksi sama sekali
    if (widget.transactions.isEmpty) {
      return _emptyState(
        icon: Icons.inbox_outlined,
        title: 'Belum ada transaksi',
        subtitle: 'Riwayat transaksimu akan muncul di sini',
      );
    }

    // Ada transaksi tapi tidak cocok filter/pencarian
    if (filtered.isEmpty) {
      return _emptyState(
        icon: Icons.search_off_rounded,
        title: 'Transaksi tidak ditemukan',
        subtitle: 'Coba ubah kata kunci atau filter yang dipilih',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final transaction = filtered[index];
        // Staggered: setiap item delay bertambah 50ms, max 400ms
        final delay = (index * 50).clamp(0, 400).ms;
        return Dismissible(
          key: ValueKey(transaction.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFC62828),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          confirmDismiss: (_) async {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final dialogBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final titleColor = isDark ? Colors.white : const Color(0xFF212121);
            final contentColor = isDark
                ? const Color(0xFFAAAAAA)
                : const Color(0xFF5A5A5A);

            return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: dialogBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // Ikon peringatan di atas judul
                    icon: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC62828).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFC62828),
                        size: 28,
                      ),
                    ),
                    title: Text(
                      'Hapus Transaksi?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    content: Text(
                      'Apakah kamu yakin ingin menghapus transaksi ini?\nData yang dihapus tidak dapat dikembalikan.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.5,
                        color: contentColor,
                      ),
                    ),
                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                    actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    actions: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: isDark
                                  ? const Color(0xFF3A3A3A)
                                  : Colors.grey.shade300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? const Color(0xFFAAAAAA)
                                  : const Color(0xFF757575),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(ctx, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC62828),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Hapus',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) => widget.onDelete(transaction),
          child:
              TransactionTile(
                    transaction: transaction,
                    onTap: () => widget.onEdit(transaction),
                  )
                  .animate()
                  .fade(duration: 350.ms, delay: delay)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: delay,
                    duration: 350.ms,
                    curve: Curves.easeOutCubic,
                  ),
        );
      },
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? const Color(0xFF444444) : Colors.grey.shade300;
    final textColor = isDark ? const Color(0xFF666666) : Colors.grey.shade400;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: iconColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: textColor),
          ),
        ],
      ),
    );
  }
}
