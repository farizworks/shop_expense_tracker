import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class GetEmployees implements UseCase<List<Employee>, GetEmployeesParams> {
  final EmployeeRepository repository;

  GetEmployees(this.repository);

  @override
  Future<Either<Failure, List<Employee>>> call(GetEmployeesParams params) async {
    return await repository.getEmployees(params.businessId);
  }
}

class GetEmployeesParams extends Equatable {
  final int businessId;

  const GetEmployeesParams({required this.businessId});

  @override
  List<Object> get props => [businessId];
}
