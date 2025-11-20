import 'package:equatable/equatable.dart';

class ExpenseItem extends Equatable {
  final int? id;
  final int dailyEntryId;
  final String name;
  final double amount;
  final String? imagePath;
  final String type; // 'shop' or 'misc'
  final DateTime createdAt;

  const ExpenseItem({
    this.id,
    required this.dailyEntryId,
    required this.name,
    required this.amount,
    this.imagePath,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        dailyEntryId,
        name,
        amount,
        imagePath,
        type,
        createdAt,
      ];

  ExpenseItem copyWith({
    int? id,
    int? dailyEntryId,
    String? name,
    double? amount,
    String? imagePath,
    String? type,
    DateTime? createdAt,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      dailyEntryId: dailyEntryId ?? this.dailyEntryId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      imagePath: imagePath ?? this.imagePath,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
