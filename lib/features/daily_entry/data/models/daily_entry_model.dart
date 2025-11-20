import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/daily_entry.dart';
import '../../domain/entities/expense_item.dart';

class DailyEntryModel extends DailyEntry {
  const DailyEntryModel({
    super.id,
    required super.businessId,
    required super.entryDate,
    required super.totalSale,
    required super.bankAmount,
    required super.cashAmount,
    super.shopExpenseItems = const [],
    super.miscExpenseItems = const [],
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DailyEntryModel.fromMap(
    Map<String, dynamic> map, {
    List<ExpenseItem> shopExpenseItems = const [],
    List<ExpenseItem> miscExpenseItems = const [],
  }) {
    return DailyEntryModel(
      id: map['id'] as int?,
      businessId: map['business_id'] as int,
      entryDate: DateFormatter.parseFromDatabase(map['entry_date'] as String),
      totalSale: (map['total_sale'] as num).toDouble(),
      bankAmount: (map['bank_amount'] as num).toDouble(),
      cashAmount: (map['cash_amount'] as num).toDouble(),
      shopExpenseItems: shopExpenseItems,
      miscExpenseItems: miscExpenseItems,
      notes: map['notes'] as String?,
      createdAt: DateFormatter.parseFromDatabase(map['created_at'] as String),
      updatedAt: DateFormatter.parseFromDatabase(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'business_id': businessId,
      'entry_date': DateFormatter.formatForDatabase(entryDate),
      'total_sale': totalSale,
      'bank_amount': bankAmount,
      'cash_amount': cashAmount,
      'shop_expense': shopExpense,
      'misc_expense': miscExpense,
      'notes': notes,
      'created_at': DateFormatter.formatForDatabase(createdAt),
      'updated_at': DateFormatter.formatForDatabase(updatedAt),
    };
  }

  // Note: expense items are stored in separate table

  factory DailyEntryModel.fromEntity(DailyEntry entry) {
    return DailyEntryModel(
      id: entry.id,
      businessId: entry.businessId,
      entryDate: entry.entryDate,
      totalSale: entry.totalSale,
      bankAmount: entry.bankAmount,
      cashAmount: entry.cashAmount,
      shopExpenseItems: entry.shopExpenseItems,
      miscExpenseItems: entry.miscExpenseItems,
      notes: entry.notes,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }
}
