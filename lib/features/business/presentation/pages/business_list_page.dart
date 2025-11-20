import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/utils/constants.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../providers/business_provider.dart';
import '../widgets/business_card.dart';
import 'business_form_page.dart';
import 'business_detail_page.dart';

class BusinessListPage extends StatefulWidget {
  const BusinessListPage({super.key});

  @override
  State<BusinessListPage> createState() => _BusinessListPageState();
}

class _BusinessListPageState extends State<BusinessListPage> {
  bool _isGridView = true;
  static const String _viewPreferenceKey = 'business_list_view_preference';

  @override
  void initState() {
    super.initState();
    _loadViewPreference();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessProvider>().loadBusinesses();
    });
  }

  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGridView = prefs.getBool(_viewPreferenceKey) ?? true;
    });
  }

  Future<void> _saveViewPreference(bool isGridView) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_viewPreferenceKey, isGridView);
  }

  Future<void> _navigateToBusinessForm({int? businessId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessFormPage(businessId: businessId),
      ),
    );

    if (result == true && mounted) {
      context.read<BusinessProvider>().loadBusinesses();
    }
  }

  Future<void> _navigateToBusinessDetail(int businessId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDetailPage(businessId: businessId),
      ),
    );

    if (mounted) {
      context.read<BusinessProvider>().loadBusinesses();
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
              _saveViewPreference(_isGridView);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, provider, _) {
          if (provider.state == BusinessState.loading) {
            return const LoadingIndicator(message: 'Loading businesses...');
          }

          if (provider.state == BusinessState.error) {
            return ErrorView(
              message: provider.errorMessage,
              onRetry: () => provider.loadBusinesses(),
            );
          }

          if (provider.businesses.isEmpty) {
            return EmptyState(
              icon: Icons.store,
              title: 'No Businesses Yet',
              message:
                  'Start by adding your first business to track sales and expenses.',
              actionText: 'Add Business',
              onActionPressed: () => _navigateToBusinessForm(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadBusinesses(),
            child: _isGridView
                ? _buildGridView(provider)
                : _buildListView(provider),
          );
        },
      ),
      floatingActionButton: Consumer<BusinessProvider>(
        builder: (context, provider, _) {
          final canAddMore =
              provider.businessCount < AppConstants.maxBusinessCount;

          return FloatingActionButton.extended(
            onPressed: canAddMore
                ? () => _navigateToBusinessForm()
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppConstants.errorMaxBusinessReached),
                      ),
                    );
                  },
            icon: const Icon(Icons.add),
            label: Text(canAddMore
                ? 'Add Business'
                : '${provider.businessCount}/${AppConstants.maxBusinessCount}'),
            backgroundColor:
                canAddMore ? null : Theme.of(context).disabledColor,
          );
        },
      ),
    );
  }

  Widget _buildGridView(BusinessProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: provider.businesses.length,
        itemBuilder: (context, index) {
          final business = provider.businesses[index];
          return BusinessCard(
            business: business,
            onTap: () => _navigateToBusinessDetail(business.id!),
            onEdit: () => _navigateToBusinessForm(businessId: business.id),
            onDelete: () => _showDeleteDialog(business.id!),
          );
        },
      ),
    );
  }

  Widget _buildListView(BusinessProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.businesses.length,
      itemBuilder: (context, index) {
        final business = provider.businesses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: BusinessCard(
            business: business,
            onTap: () => _navigateToBusinessDetail(business.id!),
            onEdit: () => _navigateToBusinessForm(businessId: business.id),
            onDelete: () => _showDeleteDialog(business.id!),
            isListView: true,
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(int businessId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Business'),
        content: const Text(
          'Are you sure you want to delete this business? This will also delete all associated entries and employees.',
        ),
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
          await context.read<BusinessProvider>().removeBusiness(businessId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business deleted successfully')),
        );
      }
    }
  }
}
