import 'package:flutter/foundation.dart';
import '../../domain/entities/employee.dart';
import '../../domain/usecases/get_employees.dart';
import '../../domain/usecases/create_employee.dart';
import '../../domain/usecases/update_employee.dart';
import '../../domain/usecases/delete_employee.dart';

enum EmployeeState { initial, loading, loaded, error }

class EmployeeProvider extends ChangeNotifier {
  final GetEmployees getEmployees;
  final CreateEmployee createEmployee;
  final UpdateEmployee updateEmployee;
  final DeleteEmployee deleteEmployee;

  EmployeeProvider({
    required this.getEmployees,
    required this.createEmployee,
    required this.updateEmployee,
    required this.deleteEmployee,
  });

  EmployeeState _state = EmployeeState.initial;
  List<Employee> _employees = [];
  String _errorMessage = '';

  EmployeeState get state => _state;
  List<Employee> get employees => _employees;
  String get errorMessage => _errorMessage;

  Future<void> loadEmployees(int businessId) async {
    _state = EmployeeState.loading;
    notifyListeners();

    final result =
        await getEmployees(GetEmployeesParams(businessId: businessId));
    result.fold(
      (failure) {
        _state = EmployeeState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (employees) {
        _state = EmployeeState.loaded;
        _employees = employees;
        notifyListeners();
      },
    );
  }

  Future<bool> addEmployee(Employee employee) async {
    _state = EmployeeState.loading;
    notifyListeners();

    final result =
        await createEmployee(CreateEmployeeParams(employee: employee));
    return result.fold(
      (failure) {
        _state = EmployeeState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (createdEmployee) {
        _employees.insert(0, createdEmployee);
        _state = EmployeeState.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> editEmployee(Employee employee) async {
    _state = EmployeeState.loading;
    notifyListeners();

    final result =
        await updateEmployee(UpdateEmployeeParams(employee: employee));
    return result.fold(
      (failure) {
        _state = EmployeeState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (updatedEmployee) {
        final index = _employees.indexWhere((e) => e.id == updatedEmployee.id);
        if (index != -1) {
          _employees[index] = updatedEmployee;
        }
        _state = EmployeeState.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeEmployee(int id) async {
    _state = EmployeeState.loading;
    notifyListeners();

    final result = await deleteEmployee(DeleteEmployeeParams(id: id));
    return result.fold(
      (failure) {
        _state = EmployeeState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _employees.removeWhere((e) => e.id == id);
        _state = EmployeeState.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
