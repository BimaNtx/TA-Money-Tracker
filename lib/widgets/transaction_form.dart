import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';

/// Form untuk menambah atau mengedit transaksi (ditampilkan sebagai BottomSheet)
class TransactionForm extends StatefulWidget {
  /// Mode: null = create baru, ada value = edit
  final Transaction? existingTransaction;

  /// Callback saat user menekan Simpan — termasuk category
  final void Function(
    TransactionType type,
    int amount,
    String description,
    String category,
  )
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
  late String _selectedCategory;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _keteranganFocusNode = FocusNode();

  bool get isEditMode => widget.existingTransaction != null;

  // Daftar kategori berdasarkan tipe transaksi
  List<String> get _categories => _selectedType == TransactionType.income
      ? incomeCategories
      : expenseCategories;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.existingTransaction?.type ?? TransactionType.expense;
    _amountController = TextEditingController(
      text: widget.existingTransaction?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTransaction?.description ?? '',
    );
    // Inisialisasi kategori: pakai data lama, atau default pertama dari list
    final existingCategory = widget.existingTransaction?.category;
    _selectedCategory =
        (existingCategory != null && _categories.contains(existingCategory))
        ? existingCategory
        : _categories.last; // fallback ke 'Lainnya'
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _keteranganFocusNode.dispose();
    super.dispose();
  }

  void _onTypeChanged(Set<TransactionType> value) {
    setState(() {
      _selectedType = value.first;
      // Reset kategori ke 'Lainnya' saat tipe berubah agar tidak invalid
      _selectedCategory = _categories.last;
    });
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      final amount = int.parse(_amountController.text.replaceAll('.', ''));
      widget.onSave(
        _selectedType,
        amount,
        _descriptionController.text.trim(),
        _selectedCategory,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF009688);
    const incomeColor = Color(0xFF2E7D32);
    const expenseColor = Color(0xFFC62828);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF212121);
    final labelColor = isDark
        ? const Color(0xFFAAAAAA)
        : const Color(0xFF757575);
    final inputTextColor = isDark ? Colors.white : const Color(0xFF212121);
    final fillColor = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50;
    final handleColor = isDark ? const Color(0xFF444444) : Colors.grey.shade300;
    final closeBtnBg = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100;
    final hintColor = isDark ? const Color(0xFF555555) : Colors.grey.shade300;
    final descHintColor = isDark
        ? const Color(0xFF555555)
        : Colors.grey.shade400;
    final segmentUnselectedBg = isDark
        ? const Color(0xFF2A2A2A)
        : Colors.grey.shade50;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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
                    color: handleColor,
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
                      color: titleColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    style: IconButton.styleFrom(backgroundColor: closeBtnBg),
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
                onSelectionChanged: _onTypeChanged,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _selectedType == TransactionType.income
                          ? incomeColor.withValues(alpha: 0.12)
                          : expenseColor.withValues(alpha: 0.12);
                    }
                    return segmentUnselectedBg;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _selectedType == TransactionType.income
                          ? incomeColor
                          : expenseColor;
                    }
                    return labelColor;
                  }),
                  side: WidgetStateProperty.all(BorderSide.none),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Pilihan Kategori (ChoiceChip) ─────────────────────────
              Text(
                'Kategori',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _categories.map((String category) {
                  final bool isSelected = _selectedCategory == category;
                  final accentColor = _selectedType == TransactionType.income
                      ? incomeColor
                      : expenseColor;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoryIcon(category),
                          size: 15,
                          color: isSelected ? accentColor : labelColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          category,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected ? accentColor : labelColor,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: accentColor.withValues(alpha: 0.12),
                    backgroundColor: isDark
                        ? const Color(0xFF2A2A2A)
                        : Colors.grey.shade50,
                    side: BorderSide(
                      color: isSelected
                          ? accentColor.withValues(alpha: 0.5)
                          : (isDark
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey.shade300),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    showCheckmark: false,
                    onSelected: (bool selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Input nominal
              Text(
                'Nominal',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_keteranganFocusNode),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: inputTextColor,
                ),
                decoration: InputDecoration(
                  prefixText: 'Rp  ',
                  prefixStyle: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                  hintText: '0',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: hintColor,
                  ),
                  filled: true,
                  fillColor: fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
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
              const SizedBox(height: 12),
              // ── Tombol Input Nominal Cepat ───────────────────────────────
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [10000, 20000, 50000, 100000].map((nominal) {
                  return ActionChip(
                    label: Text(
                      nominal >= 1000
                          ? '${nominal ~/ 1000}k'
                          : nominal.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFE0E0E0)
                            : const Color(0xFF616161),
                      ),
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF333333)
                        : Colors.grey.shade100,
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF444444)
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        // format angka bisa diatur tapi controller kita minta raw digit
                        // karena filtering formatter atau kalau mau dengan format
                        _amountController.text = nominal.toString();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Input keterangan
              Text(
                'Keterangan',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                focusNode: _keteranganFocusNode,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                style: GoogleFonts.poppins(fontSize: 15, color: inputTextColor),
                decoration: InputDecoration(
                  hintText: 'Contoh: Beli cilok',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 15,
                    color: descHintColor,
                  ),
                  filled: true,
                  fillColor: fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: primaryColor,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
      ),
    );
  }
}

/// Mapping kategori → IconData (dipakai di form & tile)
IconData categoryIcon(String category) {
  switch (category) {
    case 'Makan':
      return Icons.restaurant_rounded;
    case 'Transport':
      return Icons.directions_car_rounded;
    case 'Belanja':
      return Icons.shopping_cart_rounded;
    case 'Hiburan':
      return Icons.movie_rounded;
    case 'Gaji':
      return Icons.payments_rounded;
    case 'Bonus':
      return Icons.redeem_rounded;
    default:
      return Icons.category_rounded;
  }
}
