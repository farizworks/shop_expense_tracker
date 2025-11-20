import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/employee.dart';
import '../providers/employee_provider.dart';

class EmployeeFormPage extends StatefulWidget {
  final int businessId;
  final int? employeeId;

  const EmployeeFormPage({
    super.key,
    required this.businessId,
    this.employeeId,
  });

  @override
  State<EmployeeFormPage> createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _joiningDate = DateTime.now();
  DateTime? _visaExpiryDate;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.employeeId != null) {
      _isEditMode = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadEmployee();
      });
    }
  }

  Future<void> _loadEmployee() async {
    setState(() => _isLoading = true);
    await context.read<EmployeeProvider>().loadEmployees(widget.businessId);

    final employees = context.read<EmployeeProvider>().employees;
    final employee = employees.firstWhere((e) => e.id == widget.employeeId);

    _nameController.text = employee.name;
    _phoneController.text = employee.phone ?? '';
    _notesController.text = employee.notes ?? '';
    _joiningDate = employee.joiningDate;
    _visaExpiryDate = employee.visaExpiryDate;
    _isActive = employee.isActive;

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isJoiningDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isJoiningDate
          ? _joiningDate
          : (_visaExpiryDate ?? DateTime.now()),
      firstDate: isJoiningDate ? DateTime(2000) : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        if (isJoiningDate) {
          _joiningDate = picked;
        } else {
          _visaExpiryDate = picked;
        }
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final employee = Employee(
      id: widget.employeeId,
      businessId: widget.businessId,
      name: _nameController.text.trim(),
      joiningDate: _joiningDate,
      visaExpiryDate: _visaExpiryDate,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isActive: _isActive,
      createdAt: _isEditMode
          ? context
              .read<EmployeeProvider>()
              .employees
              .firstWhere((e) => e.id == widget.employeeId)
              .createdAt
          : now,
      updatedAt: now,
    );

    final provider = context.read<EmployeeProvider>();
    final success = _isEditMode
        ? await provider.editEmployee(employee)
        : await provider.addEmployee(employee);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Employee' : 'Add Employee'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildVisaSection(),
                    const SizedBox(height: 24),
                    _buildAdditionalInfoSection(),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: _isEditMode ? 'Update Employee' : 'Add Employee',
                      onPressed: _saveEmployee,
                      isLoading: _isLoading,
                      icon: _isEditMode ? Icons.update : Icons.person_add,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              labelText: 'Employee Name',
              prefixIcon: Icons.person,
              validator: (value) =>
                  Validators.validateRequired(value, 'Employee name'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              labelText: 'Phone Number (Optional)',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: TextEditingController(
                text: DateFormatter.formatForDisplay(_joiningDate),
              ),
              labelText: 'Joining Date',
              prefixIcon: Icons.calendar_today,
              readOnly: true,
              onTap: () => _selectDate(true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visa Information (Optional)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: TextEditingController(
                text: _visaExpiryDate != null
                    ? DateFormatter.formatForDisplay(_visaExpiryDate!)
                    : '',
              ),
              labelText: 'Visa Expiry Date',
              prefixIcon: Icons.credit_card,
              readOnly: true,
              onTap: () => _selectDate(false),
              suffixIcon: _visaExpiryDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _visaExpiryDate = null),
                    )
                  : null,
            ),
            if (_visaExpiryDate != null) ...[
              const SizedBox(height: 8),
              _buildVisaWarning(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisaWarning() {
    final daysUntilExpiry =
        _visaExpiryDate!.difference(DateTime.now()).inDays;

    if (daysUntilExpiry < 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Visa expired ${daysUntilExpiry.abs()} days ago!',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } else if (daysUntilExpiry <= 30) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Visa expires in $daysUntilExpiry days',
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active Employee'),
              subtitle: Text(_isActive ? 'Currently active' : 'Inactive'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _notesController,
              labelText: 'Notes (Optional)',
              prefixIcon: Icons.note,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
