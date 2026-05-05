import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../widgets/transaction_form.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

/// Shell utama: BottomNavigationBar + IndexedStack + FAB
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Akses Hive box yang sudah dibuka di main.dart
  Box<Transaction> get _box => Hive.box<Transaction>('transactions');

  // --- CRUD Operations ---

  void _addTransaction(
      TransactionType type, int amount, String description, String category) {
    final newTransaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      amount: amount,
      description: description,
      createdAt: DateTime.now(),
      category: category,
    );
    // put() menggunakan id sebagai key agar mudah di-update/hapus
    _box.put(newTransaction.id, newTransaction);
    setState(() {}); // trigger rebuild untuk update saldo
  }

  void _editTransaction(Transaction old, TransactionType type, int amount,
      String description, String category) {
    final updated = old.copyWith(
      type: type,
      amount: amount,
      description: description,
      category: category,
    );
    _box.put(old.id, updated); // overwrite dengan key yang sama
    setState(() {});
  }

  void _deleteTransaction(Transaction transaction) {
    _box.delete(transaction.id);
    setState(() {});

    // Tampilkan snackbar konfirmasi
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${transaction.description}" berhasil dihapus',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: const Color(0xFF212121),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // --- UI Helpers ---

  void _showTransactionForm({Transaction? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TransactionForm(
        existingTransaction: existing,
        onSave: (type, amount, description, category) {
          if (existing != null) {
            _editTransaction(existing, type, amount, description, category);
          } else {
            _addTransaction(type, amount, description, category);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder agar UI otomatis rebuild
    // setiap kali isi Box berubah — tanpa perlu setState manual
    return ValueListenableBuilder<Box<Transaction>>(
      valueListenable: _box.listenable(),
      builder: (context, box, _) {
        final transactions = box.values.toList();

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              // Tab 0: Beranda
              HomeScreen(
                transactions: transactions,
                onViewAll: () => setState(() => _selectedIndex = 1),
              ),
              // Tab 1: Riwayat
              HistoryScreen(
                transactions: transactions,
                onEdit: (t) => _showTransactionForm(existing: t),
                onDelete: _deleteTransaction,
              ),
              // Tab 2: Profil
              const ProfileScreen(),
            ],
          ),

          // FAB — hanya muncul di tab Beranda & Riwayat
          floatingActionButton: _selectedIndex < 2
              ? FloatingActionButton(
                  onPressed: () => _showTransactionForm(),
                  backgroundColor: const Color(0xFF009688),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.add_rounded, size: 28),
                )
              : null,

          // Bottom Navigation Bar
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 68,
              indicatorColor: const Color(0xFF009688).withValues(alpha: 0.1),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon:
                      Icon(Icons.home_rounded, color: Color(0xFF009688)),
                  label: 'Beranda',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon:
                      Icon(Icons.receipt_long_rounded, color: Color(0xFF009688)),
                  label: 'Riwayat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon:
                      Icon(Icons.person_rounded, color: Color(0xFF009688)),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
