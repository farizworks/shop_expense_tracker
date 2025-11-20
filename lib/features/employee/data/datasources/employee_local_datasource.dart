import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/constants.dart';
import '../models/employee_model.dart';

abstract class EmployeeLocalDataSource {
  Future<List<EmployeeModel>> getEmployees(int businessId);
  Future<EmployeeModel> createEmployee(EmployeeModel employee);
  Future<EmployeeModel> updateEmployee(EmployeeModel employee);
  Future<void> deleteEmployee(int id);
}

class EmployeeLocalDataSourceImpl implements EmployeeLocalDataSource {
  final DatabaseHelper databaseHelper;

  EmployeeLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<List<EmployeeModel>> getEmployees(int businessId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableEmployees,
        where: 'business_id = ?',
        whereArgs: [businessId],
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => EmployeeModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to get employees: $e');
    }
  }

  @override
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    try {
      final db = await databaseHelper.database;
      final id = await db.insert(
        AppConstants.tableEmployees,
        employee.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final created = await db.query(
        AppConstants.tableEmployees,
        where: 'id = ?',
        whereArgs: [id],
      );

      return EmployeeModel.fromMap(created.first);
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  @override
  Future<EmployeeModel> updateEmployee(EmployeeModel employee) async {
    try {
      if (employee.id == null) {
        throw Exception('Employee ID is required for update');
      }

      final db = await databaseHelper.database;
      await db.update(
        AppConstants.tableEmployees,
        employee.toMap(),
        where: 'id = ?',
        whereArgs: [employee.id],
      );

      final updated = await db.query(
        AppConstants.tableEmployees,
        where: 'id = ?',
        whereArgs: [employee.id],
      );

      return EmployeeModel.fromMap(updated.first);
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  @override
  Future<void> deleteEmployee(int id) async {
    try {
      final db = await databaseHelper.database;
      await db.delete(
        AppConstants.tableEmployees,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }
}
