import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/constants.dart';
import '../models/business_model.dart';

abstract class BusinessLocalDataSource {
  Future<List<BusinessModel>> getAllBusinesses();
  Future<BusinessModel> getBusinessById(int id);
  Future<BusinessModel> createBusiness(BusinessModel business);
  Future<BusinessModel> updateBusiness(BusinessModel business);
  Future<void> deleteBusiness(int id);
  Future<int> getBusinessCount();
}

class BusinessLocalDataSourceImpl implements BusinessLocalDataSource {
  final DatabaseHelper databaseHelper;

  BusinessLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<List<BusinessModel>> getAllBusinesses() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableBusinesses,
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => BusinessModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get businesses: $e');
    }
  }

  @override
  Future<BusinessModel> getBusinessById(int id) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableBusinesses,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        throw Exception('Business not found');
      }

      return BusinessModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Failed to get business: $e');
    }
  }

  @override
  Future<BusinessModel> createBusiness(BusinessModel business) async {
    try {
      final db = await databaseHelper.database;
      final id = await db.insert(
        AppConstants.tableBusinesses,
        business.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return await getBusinessById(id);
    } catch (e) {
      throw Exception('Failed to create business: $e');
    }
  }

  @override
  Future<BusinessModel> updateBusiness(BusinessModel business) async {
    try {
      if (business.id == null) {
        throw Exception('Business ID is required for update');
      }

      final db = await databaseHelper.database;
      await db.update(
        AppConstants.tableBusinesses,
        business.toMap(),
        where: 'id = ?',
        whereArgs: [business.id],
      );

      return await getBusinessById(business.id!);
    } catch (e) {
      throw Exception('Failed to update business: $e');
    }
  }

  @override
  Future<void> deleteBusiness(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        AppConstants.tableBusinesses,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete business: $e');
    }
  }

  @override
  Future<int> getBusinessCount() async {
    try {
      final db = await databaseHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${AppConstants.tableBusinesses}',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to get business count: $e');
    }
  }
}
