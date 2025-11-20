import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, List<Employee>>> getEmployees(int businessId);
  Future<Either<Failure, Employee>> createEmployee(Employee employee);
  Future<Either<Failure, Employee>> updateEmployee(Employee employee);
  Future<Either<Failure, void>> deleteEmployee(int id);
}
