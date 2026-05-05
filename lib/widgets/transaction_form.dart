import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';

/// Form untuk menambah atau mengedit transaksi (ditampilkan sebagai BottomSheet)
class TransactionForm extends StatefulWidget {
  /// Mode: null = create baru, ada value = edit
  final Transaction? existingTransaction;

  /// Callback saat user menekan Simpan
  final void Function(TransactionType type, int amount, String description)
      onSave;

  const TransactionForm({
    super.key,
    this.existingTransaction,
    required this.onSave,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  late TransactionType _selectedType;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  bool get isEditMode => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();
    _selectedType =
        widget.existingTransaction?.type ?? TransactionType.expense;
    _amountController = TextEditingController(
      text: widget.existingTransaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTransaction?.description ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final amount = int.parse(_amountController.text.replaceAll('.', ''));
      widget.onSave(_selectedType, amount, _descriptionController.text.trim());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF009688);
    const incomeColor = Color(0xFF2E7D32);
    const expenseColor = Color(0xFFC62828);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tipe toggle: Pemasukan / Pengeluaran
            SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment<TransactionType>(
                  value: TransactionType.income,
                  label: Text(
                    'Pemasukan',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                ),
                ButtonSegment<TransactionType>(
                  value: TransactionType.expense,
                  label: Text(
                    'Pengeluaran',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<TransactionType> value) {
                setState(() => _selectedType = value.first);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return _selectedType == TransactionType.income
                        ? incomeColor.withValues(alpha: 0.1)
                        : expenseColor.withValues(alpha: 0.1);
                  }
                  return Colors.grey.shade50;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return _selectedType == TransactionType.income
                        ? incomeColor
                        : expenseColor;
                  }
                  return const Color(0xFF757575);
                }),
                side: WidgetStateProperty.all(BorderSide.none),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input nominal
            Text(
              'Nominal',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF212121),
              ),
              decoration: InputDecoration(
                prefixText: 'Rp  ',
                prefixStyle: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF757575),
                ),
                hintText: '0',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade300,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: primaryColor, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Masukkan nominal';
                final parsed = int.tryParse(value.replaceAll('.', ''));
                if (parsed == null || parsed <= 0) {
                  return 'Nominal harus lebih dari 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Input keterangan
            Text(
              'Keterangan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFF212121),
              ),
              decoration: InputDecoration(
                hintText: 'Contoh: Beli cilok',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: primaryColor, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Masukkan keterangan';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Tombol Simpan
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Simpan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
