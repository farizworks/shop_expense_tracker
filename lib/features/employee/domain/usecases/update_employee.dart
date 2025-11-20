import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

class UpdateEmployee implements UseCase<Employee, UpdateEmployeeParams> {
  final EmployeeRepository repository;

  UpdateEmployee(this.repository);

  @override
  Future<Either<Failure, Employee>> call(UpdateEmployeeParams params) async {
    return await repository.updateEmployee(params.employee);
  }
}

class UpdateEmployeeParams extends Equatable {
  final Employee employee;

  const UpdateEmployeeParams({required this.employee});

  @override
  List<Object> get props => [employee];
}
