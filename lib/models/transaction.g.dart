// GENERATED SOURCE — TypeAdapter untuk class Transaction
// Ditulis manual (tanpa build_runner) agar sederhana dan langsung jalan.
// typeId harus cocok dengan @HiveType(typeId: 0) di transaction.dart

part of 'transaction.dart';

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 0;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      type: TransactionType.values[fields[1] as int],
      amount: fields[2] as int,
      description: fields[3] as String,
      createdAt: fields[4] as DateTime,
      // Field 5 (category) mungkin tidak ada pada data lama → fallback 'Lainnya'
      category: fields[5] as String? ?? 'Lainnya',
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(6) // jumlah field (0–5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.typeIndex)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
