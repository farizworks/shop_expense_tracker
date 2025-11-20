import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class CreateEmployee implements UseCase<Employee, CreateEmployeeParams> {
  final EmployeeRepository repository;

  CreateEmployee(this.repository);

  @override
  Future<Either<Failure, Employee>> call(CreateEmployeeParams params) async {
    return await repository.createEmployee(params.employee);
  }
}

class CreateEmployeeParams extends Equatable {
  final Employee employee;

  const CreateEmployeeParams({required this.employee});

  @override
  List<Object> get props => [employee];
}
