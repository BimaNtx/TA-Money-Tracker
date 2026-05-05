import 'package:flutter/material.dart';
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
      if (_selectedFilter == 'Pemasukan') return t.type == TransactionType.income;
      if (_selectedFilter == 'Pengeluaran') return t.type == TransactionType.expense;
      return true; // 'Semua'
    });

    // 3. Filter pencarian
    if (_searchQuery.isEmpty) return byType.toList();
    return byType
        .where((t) =>
            t.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
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
                color: const Color(0xFF212121),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              '$totalCount transaksi tercatat',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),

          // ── Search Bar ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF212121),
              ),
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFFBDBDBD),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF9E9E9E),
                  size: 22,
                ),
                // Tombol clear muncul saat ada teks
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: Color(0xFF9E9E9E)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: _primaryColor, width: 1.5),
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
                        color: isActive ? Colors.white : const Color(0xFF757575),
                      ),
                    ),
                    selected: isActive,
                    onSelected: (_) =>
                        setState(() => _selectedFilter = filter),
                    selectedColor: _primaryColor,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isActive ? _primaryColor : Colors.grey.shade200,
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
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
          Expanded(
            child: _buildList(filtered),
          ),
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
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text(
                  'Hapus Transaksi?',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Text(
                  'Yakin ingin menghapus transaksi ini?',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF757575),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(
                      'Hapus',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFC62828),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ) ??
                false;
          },
          onDismissed: (_) => widget.onDelete(transaction),
          child: TransactionTile(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
