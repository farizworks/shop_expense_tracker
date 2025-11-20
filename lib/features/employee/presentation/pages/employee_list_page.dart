import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/employee_provider.dart';
import '../widgets/employee_card.dart';
import 'employee_form_page.dart';

class EmployeeListPage extends StatefulWidget {
  final int businessId;

  const EmployeeListPage({super.key, required this.businessId});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEmployees();
    });
  }

  Future<void> _loadEmployees() async {
    await context.read<EmployeeProvider>().loadEmployees(widget.businessId);
  }

  Future<void> _navigateToForm({int? employeeId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeFormPage(
          businessId: widget.businessId,
          employeeId: employeeId,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          if (provider.state == EmployeeState.loading) {
            return const LoadingIndicator(message: 'Loading employees...');
          }

          if (provider.employees.isEmpty) {
            return EmptyState(
              icon: Icons.people,
              title: 'No Employees Yet',
              message: 'Add employees to track their information and visa expiry dates.',
              actionText: 'Add Employee',
              onActionPressed: _navigateToForm,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadEmployees,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: provider.employees.length,
              itemBuilder: (context, index) {
                final employee = provider.employees[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: EmployeeCard(
                    employee: employee,
                    onTap: () => _navigateToForm(employeeId: employee.id),
                    onDelete: () => _showDeleteDialog(employee.id!),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToForm,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Employee'),
      ),
    );
  }

  Future<void> _showDeleteDialog(int employeeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await context.read<EmployeeProvider>().removeEmployee(employeeId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee deleted successfully')),
        );
      }
    }
  }
}
