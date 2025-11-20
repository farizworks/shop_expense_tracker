import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
import '../../domain/entities/daily_entry.dart';
import '../providers/daily_entry_provider.dart';
import 'daily_entry_form_page.dart';

class DailyEntryDetailPage extends StatelessWidget {
  final DailyEntry entry;
  final int businessId;

  const DailyEntryDetailPage({
    super.key,
    required this.entry,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormatter.formatForDisplay(entry.entryDate)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Set the selected entry in the provider before navigating
              // This ensures the entry is available when the form loads
              context.read<DailyEntryProvider>().setSelectedEntry(entry);

              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DailyEntryFormPage(
                    businessId: businessId,
                    entryId: entry.id,
                  ),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sales Section
            _buildSectionTitle(context, 'Sales Information'),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              'Total Sale',
              'AED ${entry.totalSale.toStringAsFixed(2)}',
              Icons.attach_money,
              isDarkMode ? AppColors.salesCardDark : AppColors.salesCardLight,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Bank',
                    'AED ${entry.bankAmount.toStringAsFixed(2)}',
                    Icons.account_balance,
                    isDarkMode ? AppColors.bankCardDark : AppColors.bankCardLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Cash',
                    'AED ${entry.cashAmount.toStringAsFixed(2)}',
                    Icons.money,
                    isDarkMode ? AppColors.cashCardDark : AppColors.cashCardLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Expenses Section
            _buildSectionTitle(context, 'Expenses'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Shop Expense',
                    'AED ${entry.shopExpense.toStringAsFixed(2)}',
                    Icons.store,
                    isDarkMode ? AppColors.expenseCardDark : AppColors.expenseCardLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    'Misc Expense',
                    'AED ${entry.miscExpense.toStringAsFixed(2)}',
                    Icons.more_horiz,
                    isDarkMode ? AppColors.expenseCardDark : AppColors.expenseCardLight,
                  ),
                ),
              ],
            ),

            // Shop Expense Items
            if (entry.shopExpenseItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildExpenseItemsSection(
                context,
                'Shop Expense Items',
                entry.shopExpenseItems,
                isDarkMode,
              ),
            ],

            // Misc Expense Items
            if (entry.miscExpenseItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildExpenseItemsSection(
                context,
                'Miscellaneous Expense Items',
                entry.miscExpenseItems,
                isDarkMode,
              ),
            ],

            const SizedBox(height: 24),

            // Balance Check
            _buildSectionTitle(context, 'Balance Summary'),
            const SizedBox(height: 12),
            _buildBalanceCard(context, isDarkMode),

            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Notes'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(entry.notes!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, bool isDarkMode) {
    final totalReceived = entry.bankAmount + entry.cashAmount;
    final balance = entry.totalSale - totalReceived - entry.totalExpense;
    final isBalanced = balance.abs() < 0.01; // Account for floating point errors
    final hasShortage = balance < -0.01;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isBalanced) {
      statusColor = AppColors.success;
      statusText = 'Balanced';
      statusIcon = Icons.check_circle;
    } else if (hasShortage) {
      statusColor = AppColors.errorLight;
      statusText = 'Shortage: AED ${balance.abs().toStringAsFixed(2)}';
      statusIcon = Icons.error;
    } else {
      statusColor = AppColors.warning;
      statusText = 'Excess: AED ${balance.toStringAsFixed(2)}';
      statusIcon = Icons.warning;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildBalanceRow('Total Sale', entry.totalSale),
            const SizedBox(height: 8),
            _buildBalanceRow('Total Received', totalReceived),
            const SizedBox(height: 8),
            _buildBalanceRow('  • Bank', entry.bankAmount, isIndented: true),
            const SizedBox(height: 4),
            _buildBalanceRow('  • Cash', entry.cashAmount, isIndented: true),
            const SizedBox(height: 8),
            _buildBalanceRow('Total Expenses', entry.totalExpense),
            const SizedBox(height: 8),
            _buildBalanceRow('  • Shop', entry.shopExpense, isIndented: true),
            const SizedBox(height: 4),
            _buildBalanceRow('  • Misc', entry.miscExpense, isIndented: true),
            const Divider(height: 24),
            _buildBalanceRow(
              'Balance',
              balance,
              isBold: true,
              color: statusColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow(
    String label,
    double amount, {
    bool isBold = false,
    bool isIndented = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isIndented ? 14 : 16,
          ),
        ),
        Text(
          'AED ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isIndented ? 14 : 16,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseItemsSection(
    BuildContext context,
    String title,
    List items,
    bool isDarkMode,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildExpenseItemCard(context, item, isDarkMode),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItemCard(BuildContext context, dynamic item, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                'AED ${item.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          if (item.imagePath != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(
                      imagePath: item.imagePath!,
                      title: item.name,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(item.imagePath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
