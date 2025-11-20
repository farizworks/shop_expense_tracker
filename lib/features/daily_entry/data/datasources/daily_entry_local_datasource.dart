import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/business_summary.dart';
import '../../domain/entities/expense_item.dart';
import '../models/daily_entry_model.dart';
import '../models/expense_item_model.dart';

abstract class DailyEntryLocalDataSource {
  Future<List<DailyEntryModel>> getDailyEntries(int businessId);
  Future<DailyEntryModel?> getDailyEntryByDate(int businessId, DateTime date);
  Future<DailyEntryModel> createDailyEntry(DailyEntryModel entry);
  Future<DailyEntryModel> updateDailyEntry(DailyEntryModel entry);
  Future<void> deleteDailyEntry(int id);
  Future<BusinessSummary> getBusinessSummary(int businessId);
  Future<List<DailyEntryModel>> getDailyEntriesByDateRange(
      int businessId, DateTime startDate, DateTime endDate);
}

class DailyEntryLocalDataSourceImpl implements DailyEntryLocalDataSource {
  final DatabaseHelper databaseHelper;

  DailyEntryLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<List<DailyEntryModel>> getDailyEntries(int businessId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableDailyEntries,
        where: 'business_id = ?',
        whereArgs: [businessId],
        orderBy: 'entry_date DESC',
      );

      final entries = <DailyEntryModel>[];
      for (final map in maps) {
        final expenseItems = await _getExpenseItemsForEntry(db, map['id'] as int);
        final shopItems = expenseItems.where((item) => item.type == 'shop').toList();
        final miscItems = expenseItems.where((item) => item.type == 'misc').toList();

        entries.add(DailyEntryModel.fromMap(
          map,
          shopExpenseItems: shopItems,
          miscExpenseItems: miscItems,
        ));
      }
      return entries;
    } catch (e) {
      throw Exception('Failed to get daily entries: $e');
    }
  }

  Future<List<ExpenseItem>> _getExpenseItemsForEntry(Database db, int entryId) async {
    final maps = await db.query(
      AppConstants.tableExpenseItems,
      where: 'daily_entry_id = ?',
      whereArgs: [entryId],
    );
    return maps.map((map) => ExpenseItemModel.fromMap(map)).toList();
  }

  @override
  Future<DailyEntryModel?> getDailyEntryByDate(
      int businessId, DateTime date) async {
    try {
      final db = await databaseHelper.database;
      final dateStr = DateFormatter.formatForDatabase(date);
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableDailyEntries,
        where: 'business_id = ? AND entry_date = ?',
        whereArgs: [businessId, dateStr],
      );

      if (maps.isEmpty) {
        return null;
      }

      final map = maps.first;
      final expenseItems = await _getExpenseItemsForEntry(db, map['id'] as int);
      final shopItems = expenseItems.where((item) => item.type == 'shop').toList();
      final miscItems = expenseItems.where((item) => item.type == 'misc').toList();

      return DailyEntryModel.fromMap(
        map,
        shopExpenseItems: shopItems,
        miscExpenseItems: miscItems,
      );
    } catch (e) {
      throw Exception('Failed to get daily entry by date: $e');
    }
  }

  @override
  Future<DailyEntryModel> createDailyEntry(DailyEntryModel entry) async {
    try {
      final db = await databaseHelper.database;

      // Start transaction
      return await db.transaction((txn) async {
        // Insert daily entry
        final id = await txn.insert(
          AppConstants.tableDailyEntries,
          entry.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Insert expense items
        for (final item in entry.shopExpenseItems) {
          final itemModel = ExpenseItemModel.fromEntity(item.copyWith(dailyEntryId: id));
          await txn.insert(
            AppConstants.tableExpenseItems,
            itemModel.toMap(),
          );
        }

        for (final item in entry.miscExpenseItems) {
          final itemModel = ExpenseItemModel.fromEntity(item.copyWith(dailyEntryId: id));
          await txn.insert(
            AppConstants.tableExpenseItems,
            itemModel.toMap(),
          );
        }

        // Fetch created entry with items
        final created = await txn.query(
          AppConstants.tableDailyEntries,
          where: 'id = ?',
          whereArgs: [id],
        );

        final expenseItems = await _getExpenseItemsForEntryInTransaction(txn, id);
        final shopItems = expenseItems.where((item) => item.type == 'shop').toList();
        final miscItems = expenseItems.where((item) => item.type == 'misc').toList();

        return DailyEntryModel.fromMap(
          created.first,
          shopExpenseItems: shopItems,
          miscExpenseItems: miscItems,
        );
      });
    } catch (e) {
      throw Exception('Failed to create daily entry: $e');
    }
  }

  Future<List<ExpenseItem>> _getExpenseItemsForEntryInTransaction(
      Transaction txn, int entryId) async {
    final maps = await txn.query(
      AppConstants.tableExpenseItems,
      where: 'daily_entry_id = ?',
      whereArgs: [entryId],
    );
    return maps.map((map) => ExpenseItemModel.fromMap(map)).toList();
  }

  @override
  Future<DailyEntryModel> updateDailyEntry(DailyEntryModel entry) async {
    try {
      if (entry.id == null) {
        throw Exception('Daily entry ID is required for update');
      }

      final db = await databaseHelper.database;

      return await db.transaction((txn) async {
        // Update daily entry
        await txn.update(
          AppConstants.tableDailyEntries,
          entry.toMap(),
          where: 'id = ?',
          whereArgs: [entry.id],
        );

        // Delete old expense items
        await txn.delete(
          AppConstants.tableExpenseItems,
          where: 'daily_entry_id = ?',
          whereArgs: [entry.id],
        );

        // Insert new expense items
        for (final item in entry.shopExpenseItems) {
          final itemModel = ExpenseItemModel.fromEntity(item.copyWith(dailyEntryId: entry.id!));
          await txn.insert(
            AppConstants.tableExpenseItems,
            itemModel.toMap(),
          );
        }

        for (final item in entry.miscExpenseItems) {
          final itemModel = ExpenseItemModel.fromEntity(item.copyWith(dailyEntryId: entry.id!));
          await txn.insert(
            AppConstants.tableExpenseItems,
            itemModel.toMap(),
          );
        }

        // Fetch updated entry with items
        final updated = await txn.query(
          AppConstants.tableDailyEntries,
          where: 'id = ?',
          whereArgs: [entry.id],
        );

        final expenseItems = await _getExpenseItemsForEntryInTransaction(txn, entry.id!);
        final shopItems = expenseItems.where((item) => item.type == 'shop').toList();
        final miscItems = expenseItems.where((item) => item.type == 'misc').toList();

        return DailyEntryModel.fromMap(
          updated.first,
          shopExpenseItems: shopItems,
          miscExpenseItems: miscItems,
        );
      });
    } catch (e) {
      throw Exception('Failed to update daily entry: $e');
    }
  }

  @override
  Future<void> deleteDailyEntry(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        AppConstants.tableDailyEntries,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete daily entry: $e');
    }
  }

  @override
  Future<BusinessSummary> getBusinessSummary(int businessId) async {
    try {
      final db = await databaseHelper.database;

      // Get sales and payment totals from daily_entries
      final salesResult = await db.rawQuery('''
        SELECT
          COALESCE(SUM(total_sale), 0) as total_sales,
          COALESCE(SUM(bank_amount), 0) as total_bank,
          COALESCE(SUM(cash_amount), 0) as total_cash
        FROM ${AppConstants.tableDailyEntries}
        WHERE business_id = ?
      ''', [businessId]);

      // Get expense totals from expense_items table
      final expenseResult = await db.rawQuery('''
        SELECT
          COALESCE(SUM(CASE WHEN ei.type = 'shop' THEN ei.amount ELSE 0 END), 0) as total_shop_expense,
          COALESCE(SUM(CASE WHEN ei.type = 'misc' THEN ei.amount ELSE 0 END), 0) as total_misc_expense
        FROM ${AppConstants.tableExpenseItems} ei
        INNER JOIN ${AppConstants.tableDailyEntries} de ON ei.daily_entry_id = de.id
        WHERE de.business_id = ?
      ''', [businessId]);

      if (salesResult.isEmpty) {
        return const BusinessSummary(
          totalSales: 0,
          totalBankAmount: 0,
          totalCashAmount: 0,
          totalExpenses: 0,
          totalShopExpense: 0,
          totalMiscExpense: 0,
          netProfit: 0,
        );
      }

      final salesData = salesResult.first;
      final expenseData = expenseResult.isNotEmpty ? expenseResult.first : {};

      final totalSales = (salesData['total_sales'] as num).toDouble();
      final totalBank = (salesData['total_bank'] as num).toDouble();
      final totalCash = (salesData['total_cash'] as num).toDouble();
      final totalShopExpense = (expenseData['total_shop_expense'] as num?)?.toDouble() ?? 0.0;
      final totalMiscExpense = (expenseData['total_misc_expense'] as num?)?.toDouble() ?? 0.0;
      final totalExpenses = totalShopExpense + totalMiscExpense;
      final netProfit = totalSales - totalExpenses;

      return BusinessSummary(
        totalSales: totalSales,
        totalBankAmount: totalBank,
        totalCashAmount: totalCash,
        totalExpenses: totalExpenses,
        totalShopExpense: totalShopExpense,
        totalMiscExpense: totalMiscExpense,
        netProfit: netProfit,
      );
    } catch (e) {
      throw Exception('Failed to get business summary: $e');
    }
  }

  @override
  Future<List<DailyEntryModel>> getDailyEntriesByDateRange(
      int businessId, DateTime startDate, DateTime endDate) async {
    try {
      final db = await databaseHelper.database;
      final startDateStr = DateFormatter.formatForDatabase(startDate);
      final endDateStr = DateFormatter.formatForDatabase(endDate);

      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableDailyEntries,
        where: 'business_id = ? AND entry_date >= ? AND entry_date <= ?',
        whereArgs: [businessId, startDateStr, endDateStr],
        orderBy: 'entry_date DESC',
      );

      return maps.map((map) => DailyEntryModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get daily entries by date range: $e');
    }
  }
}
