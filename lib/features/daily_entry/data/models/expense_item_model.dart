import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/expense_item.dart';

class ExpenseItemModel extends ExpenseItem {
  const ExpenseItemModel({
    super.id,
    required super.dailyEntryId,
    required super.name,
    required super.amount,
    super.imagePath,
    required super.type,
    required super.createdAt,
  });

  factory ExpenseItemModel.fromMap(Map<String, dynamic> map) {
    return ExpenseItemModel(
      id: map['id'] as int?,
      dailyEntryId: map['daily_entry_id'] as int,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      imagePath: map['image_path'] as String?,
      type: map['type'] as String,
      createdAt: DateFormatter.parseFromDatabase(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'daily_entry_id': dailyEntryId,
      'name': name,
      'amount': amount,
      'image_path': imagePath,
      'type': type,
      'created_at': DateFormatter.formatForDatabase(createdAt),
    };
  }

  factory ExpenseItemModel.fromEntity(ExpenseItem item) {
    return ExpenseItemModel(
      id: item.id,
      dailyEntryId: item.dailyEntryId,
      name: item.name,
      amount: item.amount,
      imagePath: item.imagePath,
      type: item.type,
      createdAt: item.createdAt,
    );
  }
}
