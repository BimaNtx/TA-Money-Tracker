import 'package:hive/hive.dart';

part 'transaction.g.dart';

/// Enum untuk jenis transaksi
/// Disimpan di Hive sebagai int: 0 = income, 1 = expense
enum TransactionType { income, expense }

/// Model data untuk setiap transaksi keuangan
@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int typeIndex; // 0 = income, 1 = expense

  @HiveField(2)
  final int amount;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final DateTime createdAt;

  Transaction({
    required this.id,
    required TransactionType type,
    required this.amount,
    required this.description,
    required this.createdAt,
  }) : typeIndex = type.index;

  /// Getter untuk mendapatkan enum dari typeIndex
  TransactionType get type => TransactionType.values[typeIndex];

  /// Buat salinan Transaction dengan field yang diubah
  Transaction copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    String? description,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
