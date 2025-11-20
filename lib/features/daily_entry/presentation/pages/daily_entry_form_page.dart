import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/daily_entry.dart';
import '../../domain/entities/expense_item.dart';
import '../providers/daily_entry_provider.dart';
import '../widgets/expense_item_input.dart';

class DailyEntryFormPage extends StatefulWidget {
  final int businessId;
  final int? entryId;

  const DailyEntryFormPage({
    super.key,
    required this.businessId,
    this.entryId,
  });

  @override
  State<DailyEntryFormPage> createState() => _DailyEntryFormPageState();
}

class _DailyEntryFormPageState extends State<DailyEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _totalSaleController = TextEditingController();
  final _bankAmountController = TextEditingController();
  final _cashAmountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateFormatter.getToday();
  bool _isLoading = false;
  bool _isEditMode = false;

  List<ExpenseItem> _shopExpenseItems = [];
  List<ExpenseItem> _miscExpenseItems = [];

  // For real-time balance calculation
  double _currentBalance = 0.0;

  @override
  void initState() {
    super.initState();

    // Add listeners for real-time balance calculation
    _totalSaleController.addListener(_calculateBalance);
    _bankAmountController.addListener(_calculateBalance);
    _cashAmountController.addListener(_calculateBalance);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Clear any previously selected entry
    context.read<DailyEntryProvider>().clearSelectedEntry();

    // If entryId is provided, we're editing an existing entry
    if (widget.entryId != null) {
      await _loadEntryById(widget.entryId!);
    } else {
      // New entry - check if there's already an entry for the selected date
      await _checkExistingEntry();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadEntryById(int entryId) async {
    // Load the specific entry by ID
    await context.read<DailyEntryProvider>().loadDailyEntryById(entryId);

    final entry = context.read<DailyEntryProvider>().selectedEntry;

    if (entry != null) {

      _isEditMode = true;
      _selectedDate = entry.entryDate;
      _totalSaleController.text = entry.totalSale.toString();
      _bankAmountController.text = entry.bankAmount.toString();
      _cashAmountController.text = entry.cashAmount.toString();
      _notesController.text = entry.notes ?? '';
      _shopExpenseItems = List.from(entry.shopExpenseItems);
      _miscExpenseItems = List.from(entry.miscExpenseItems);


      // Calculate initial balance for edit mode
      _calculateBalance();
    } else {
    }
  }

  Future<void> _checkExistingEntry() async {
    // For new entries, just initialize with empty values
    // Don't load existing entries to avoid confusion
    _isEditMode = false;
    _totalSaleController.text = '0';
    _bankAmountController.text = '0';
    _cashAmountController.text = '0';
    _shopExpenseItems = [];
    _miscExpenseItems = [];
  }

  void _calculateBalance() {
    setState(() {
      final totalSale = double.tryParse(_totalSaleController.text) ?? 0.0;
      final bankAmount = double.tryParse(_bankAmountController.text) ?? 0.0;
      final cashAmount = double.tryParse(_cashAmountController.text) ?? 0.0;

      final shopExpense = _shopExpenseItems.fold<double>(
        0.0,
        (sum, item) => sum + item.amount,
      );
      final miscExpense = _miscExpenseItems.fold<double>(
        0.0,
        (sum, item) => sum + item.amount,
      );
      final totalExpense = shopExpense + miscExpense;

      // Balance = Total Sale - Bank - Cash - Expenses
      _currentBalance = totalSale - bankAmount - cashAmount - totalExpense;
    });
  }

  @override
  void dispose() {
    _totalSaleController.dispose();
    _bankAmountController.dispose();
    _cashAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Don't check for existing entry when date changes
      // User can manually adjust the date for their entry
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();

    final entry = DailyEntry(
      id: _isEditMode
          ? context.read<DailyEntryProvider>().selectedEntry?.id
          : null,
      businessId: widget.businessId,
      entryDate: _selectedDate,
      totalSale: double.parse(_totalSaleController.text),
      bankAmount: double.parse(_bankAmountController.text),
      cashAmount: double.parse(_cashAmountController.text),
      shopExpenseItems: _shopExpenseItems,
      miscExpenseItems: _miscExpenseItems,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: _isEditMode
          ? context.read<DailyEntryProvider>().selectedEntry!.createdAt
          : now,
      updatedAt: now,
    );

    final provider = context.read<DailyEntryProvider>();
    final success = _isEditMode
        ? await provider.editDailyEntry(entry)
        : await provider.addDailyEntry(entry);

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
        title: Text(_isEditMode ? 'Edit Daily Entry' : 'Add Daily Entry'),
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
                    _buildDateSection(),
                    const SizedBox(height: 24),
                    _buildSalesSection(),
                    const SizedBox(height: 24),
                    _buildExpenseSection(),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: _isEditMode ? 'Update Entry' : 'Add Entry',
                      onPressed: _saveEntry,
                      isLoading: _isLoading,
                      icon: _isEditMode ? Icons.update : Icons.add,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Entry Date'),
        subtitle: Text(DateFormatter.formatForDisplay(_selectedDate)),
        trailing: const Icon(Icons.edit),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildSalesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _totalSaleController,
              labelText: 'Total Sale',
              prefixIcon: Icons.attach_money,
              keyboardType: TextInputType.number,
              validator: Validators.validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _bankAmountController,
              labelText: 'Bank Amount',
              prefixIcon: Icons.account_balance,
              keyboardType: TextInputType.number,
              validator: Validators.validatePositiveNumber,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _cashAmountController,
              labelText: 'Cash Amount',
              prefixIcon: Icons.money,
              keyboardType: TextInputType.number,
              validator: Validators.validatePositiveNumber,
            ),
            const SizedBox(height: 24),
            _buildBalanceIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceIndicator() {
    final isBalanced = _currentBalance.abs() < 0.01;
    final hasShortage = _currentBalance < -0.01;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isBalanced) {
      statusColor = AppColors.success;
      statusText = 'Balanced';
      statusIcon = Icons.check_circle;
    } else if (hasShortage) {
      statusColor = AppColors.errorLight;
      statusText = 'Shortage';
      statusIcon = Icons.error;
    } else {
      statusColor = AppColors.warning;
      statusText = 'Excess';
      statusIcon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'AED ${_currentBalance.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current Balance',
            style: TextStyle(
              fontSize: 12,
              color: statusColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ExpenseItemInput(
              key: ValueKey('shop_${widget.entryId ?? 'new'}'),
              type: 'shop',
              initialItems: _shopExpenseItems,
              onItemsChanged: (items) {
                setState(() {
                  _shopExpenseItems = items;
                });
                _calculateBalance();
              },
            ),
            const SizedBox(height: 24),
            ExpenseItemInput(
              key: ValueKey('misc_${widget.entryId ?? 'new'}'),
              type: 'misc',
              initialItems: _miscExpenseItems,
              onItemsChanged: (items) {
                setState(() {
                  _miscExpenseItems = items;
                });
                _calculateBalance();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes (Optional)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _notesController,
              labelText: 'Notes',
              prefixIcon: Icons.note,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
