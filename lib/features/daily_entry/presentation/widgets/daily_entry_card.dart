import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/daily_entry.dart';

class DailyEntryCard extends StatelessWidget {
  final DailyEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DailyEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.getRelativeDateString(entry.entryDate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    context,
                    'Total Sale',
                    'AED ${entry.totalSale.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                  _buildInfoColumn(
                    context,
                    'Expenses',
                    'AED ${entry.totalExpense.toStringAsFixed(2)}',
                    Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn(
                    context,
                    'Bank',
                    'AED ${entry.bankAmount.toStringAsFixed(2)}',
                    Colors.blue,
                  ),
                  _buildInfoColumn(
                    context,
                    'Cash',
                    'AED ${entry.cashAmount.toStringAsFixed(2)}',
                    Colors.orange,
                  ),
                ],
              ),
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
              if (entry.shopExpenseItems.isNotEmpty || entry.miscExpenseItems.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                _buildExpenseItemsIndicator(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
      BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildExpenseItemsIndicator(BuildContext context) {
    final totalItems = entry.shopExpenseItems.length + entry.miscExpenseItems.length;
    final hasImages = entry.shopExpenseItems.any((item) => item.imagePath != null) ||
        entry.miscExpenseItems.any((item) => item.imagePath != null);

    return Row(
      children: [
        Icon(
          Icons.receipt_long,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '$totalItems expense ${totalItems == 1 ? 'item' : 'items'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
        ),
        if (hasImages) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.image,
            size: 16,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            'With bills',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ],
    );
  }
}
