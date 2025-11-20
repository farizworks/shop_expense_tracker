import 'package:equatable/equatable.dart';

class BusinessSummary extends Equatable {
  final double totalSales;
  final double totalBankAmount;
  final double totalCashAmount;
  final double totalExpenses;
  final double totalShopExpense;
  final double totalMiscExpense;
  final double netProfit;

  const BusinessSummary({
    required this.totalSales,
    required this.totalBankAmount,
    required this.totalCashAmount,
    required this.totalExpenses,
    required this.totalShopExpense,
    required this.totalMiscExpense,
    required this.netProfit,
  });

  @override
  List<Object?> get props => [
        totalSales,
        totalBankAmount,
        totalCashAmount,
        totalExpenses,
        totalShopExpense,
        totalMiscExpense,
        netProfit,
      ];
}
