import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_local_datasource.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeLocalDataSource localDataSource;

  EmployeeRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Employee>>> getEmployees(int businessId) async {
    try {
      final employees = await localDataSource.getEmployees(businessId);
      return Right(employees);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Employee>> createEmployee(Employee employee) async {
    try {
      final employeeModel = EmployeeModel.fromEntity(employee);
      final created = await localDataSource.createEmployee(employeeModel);
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Employee>> updateEmployee(Employee employee) async {
    try {
      final employeeModel = EmployeeModel.fromEntity(employee);
      final updated = await localDataSource.updateEmployee(employeeModel);
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEmployee(int id) async {
    try {
      await localDataSource.deleteEmployee(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
