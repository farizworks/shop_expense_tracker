import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/full_screen_image_viewer.dart';
import '../../domain/entities/business.dart';
import 'business_form_page.dart';

class BusinessProfilePage extends StatelessWidget {
  final Business business;

  const BusinessProfilePage({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusinessFormPage(businessId: business.id),
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
            // Business Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      business.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 40,
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    business.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color),
                      const SizedBox(width: 4),
                      Text(
                        business.place,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Basic Information
            _buildSectionTitle(context, 'Basic Information'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(context, Icons.category, 'Category', business.category),
                    const Divider(height: 24),
                    _buildInfoRow(
                      context,
                      Icons.calendar_today,
                      'Created',
                      DateFormatter.formatForDisplay(business.createdAt),
                    ),
                  ],
                ),
              ),
            ),

            // VAT Information
            if (business.vatNumber != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'VAT Information'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        Icons.receipt,
                        'VAT Number',
                        business.vatNumber!,
                      ),
                      if (business.vatExpiryDate != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          context,
                          Icons.event,
                          'Expiry Date',
                          DateFormatter.formatForDisplay(business.vatExpiryDate!),
                        ),
                      ],
                      if (business.vatImagePath != null) ...[
                        const Divider(height: 24),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageViewer(
                                  imagePath: business.vatImagePath!,
                                  title: 'VAT Certificate',
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(business.vatImagePath!),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // License Information
            if (business.licenseNumber != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'License Information'),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        Icons.assignment,
                        'License Number',
                        business.licenseNumber!,
                      ),
                      if (business.licenseExpiryDate != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          context,
                          Icons.event,
                          'Expiry Date',
                          DateFormatter.formatForDisplay(business.licenseExpiryDate!),
                        ),
                      ],
                      if (business.licenseImagePath != null) ...[
                        const Divider(height: 24),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenImageViewer(
                                  imagePath: business.licenseImagePath!,
                                  title: 'License Certificate',
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(business.licenseImagePath!),
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            // Statistics (Optional - can add later)
            const SizedBox(height: 32),
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

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
