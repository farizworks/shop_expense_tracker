import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/employee.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isVisaExpiringSoon = _isVisaExpiringSoon();
    final bool isVisaExpired = _isVisaExpired();

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
                children: [
                  CircleAvatar(
                    backgroundColor: employee.isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    child: Text(
                      employee.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                employee.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (!employee.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Inactive',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                        if (employee.phone != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                employee.phone!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.event, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Joined: ${DateFormatter.formatForDisplay(employee.joiningDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (employee.visaExpiryDate != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isVisaExpired
                        ? Colors.red.withOpacity(0.1)
                        : isVisaExpiringSoon
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isVisaExpired
                          ? Colors.red
                          : isVisaExpiringSoon
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isVisaExpired
                            ? Icons.error
                            : isVisaExpiringSoon
                                ? Icons.warning
                                : Icons.credit_card,
                        size: 16,
                        color: isVisaExpired
                            ? Colors.red
                            : isVisaExpiringSoon
                                ? Colors.orange
                                : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Visa: ${DateFormatter.formatForDisplay(employee.visaExpiryDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isVisaExpired
                                ? Colors.red
                                : isVisaExpiringSoon
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ),
                      if (isVisaExpired || isVisaExpiringSoon)
                        Text(
                          isVisaExpired
                              ? 'EXPIRED'
                              : '${_daysUntilExpiry()} days',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isVisaExpired ? Colors.red : Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (employee.notes != null && employee.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        employee.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isVisaExpiringSoon() {
    if (employee.visaExpiryDate == null) return false;
    final daysUntilExpiry = employee.visaExpiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  bool _isVisaExpired() {
    if (employee.visaExpiryDate == null) return false;
    return employee.visaExpiryDate!.isBefore(DateTime.now());
  }

  int _daysUntilExpiry() {
    if (employee.visaExpiryDate == null) return 0;
    return employee.visaExpiryDate!.difference(DateTime.now()).inDays;
  }
}
