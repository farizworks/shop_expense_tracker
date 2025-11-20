import 'package:equatable/equatable.dart';
import 'expense_item.dart';

class DailyEntry extends Equatable {
  final int? id;
  final int businessId;
  final DateTime entryDate;
  final double totalSale;
  final double bankAmount;
  final double cashAmount;
  final List<ExpenseItem> shopExpenseItems;
  final List<ExpenseItem> miscExpenseItems;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyEntry({
    this.id,
    required this.businessId,
    required this.entryDate,
    required this.totalSale,
    required this.bankAmount,
    required this.cashAmount,
    this.shopExpenseItems = const [],
    this.miscExpenseItems = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  double get shopExpense => shopExpenseItems.fold(0, (sum, item) => sum + item.amount);
  double get miscExpense => miscExpenseItems.fold(0, (sum, item) => sum + item.amount);
  double get totalExpense => shopExpense + miscExpense;
  double get netProfit => totalSale - totalExpense;
  double get totalReceived => bankAmount + cashAmount;
  double get balance => totalSale - totalReceived - totalExpense;
  bool get hasShortage => balance < 0;
  bool get hasExcess => balance > 0;

  @override
  List<Object?> get props => [
        id,
        businessId,
        entryDate,
        totalSale,
        bankAmount,
        cashAmount,
        shopExpenseItems,
        miscExpenseItems,
        notes,
        createdAt,
        updatedAt,
      ];

  DailyEntry copyWith({
    int? id,
    int? businessId,
    DateTime? entryDate,
    double? totalSale,
    double? bankAmount,
    double? cashAmount,
    List<ExpenseItem>? shopExpenseItems,
    List<ExpenseItem>? miscExpenseItems,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyEntry(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      entryDate: entryDate ?? this.entryDate,
      totalSale: totalSale ?? this.totalSale,
      bankAmount: bankAmount ?? this.bankAmount,
      cashAmount: cashAmount ?? this.cashAmount,
      shopExpenseItems: shopExpenseItems ?? this.shopExpenseItems,
      miscExpenseItems: miscExpenseItems ?? this.miscExpenseItems,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
