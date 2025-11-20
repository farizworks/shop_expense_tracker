import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../daily_entry/presentation/providers/daily_entry_provider.dart';
import '../../../daily_entry/presentation/pages/daily_entry_form_page.dart';
import '../../../daily_entry/presentation/pages/daily_entries_list_page.dart';
import '../../../employee/presentation/pages/employee_list_page.dart';
import '../providers/business_provider.dart';
import 'business_profile_page.dart';

class BusinessDetailPage extends StatefulWidget {
  final int businessId;

  const BusinessDetailPage({super.key, required this.businessId});

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<State<StatefulWidget>> _entriesPageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _onTabChanged() {
    setState(() {});
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    await context.read<BusinessProvider>().loadBusinessById(widget.businessId);
    if (!mounted) return;
    await context
        .read<DailyEntryProvider>()
        .loadBusinessSummary(widget.businessId);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  // Get the entries page state to call its methods
  dynamic get _entriesPageState => _entriesPageKey.currentState;

  Future<void> _navigateToDailyEntryForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DailyEntryFormPage(businessId: widget.businessId),
      ),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: _buildAppBarActions(),
        bottom: TabBar(
          labelColor: Colors.black,
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Entries'),
            Tab(icon: Icon(Icons.people), text: 'Employees'),
          ],
        ),
      ),
      body: Consumer<BusinessProvider>(
        builder: (context, businessProvider, _) {
          final businessName = businessProvider.selectedBusiness?.name;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(isDarkMode),
              DailyEntriesListPage(
                key: _entriesPageKey,
                businessId: widget.businessId,
                businessName: businessName,
                showAppBar: false,
              ),
              EmployeeListPage(businessId: widget.businessId),
            ],
          );
        },
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _navigateToDailyEntryForm,
              icon: const Icon(Icons.add),
              label: const Text('Add Entry'),
            )
          : null,
    );
  }

  Widget _buildAppBarTitle() {
    // Show search field when on Entries tab and searching
    if (_tabController.index == 1 && _entriesPageState != null && _entriesPageState.isSearching) {
      return TextField(
        controller: _entriesPageState.searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          hintText: 'Search by date...',
          hintStyle: TextStyle(color: Colors.black54),
          border: InputBorder.none,
        ),
        onChanged: (_) {
          // Trigger filter update
          if (_entriesPageState != null) {
            setState(() {});
          }
        },
      );
    }

    // Default title
    return Consumer<BusinessProvider>(
      builder: (context, provider, _) {
        final business = provider.selectedBusiness;
        return Text(business?.name ?? 'Business Details');
      },
    );
  }

  List<Widget> _buildAppBarActions() {
    // Show search, filter, export actions only on Entries tab
    if (_tabController.index == 1 && _entriesPageState != null) {
      final isSearching = _entriesPageState.isSearching;
      final hasFilters = _entriesPageState.hasActiveFilters;

      if (isSearching) {
        // When searching, show close button only
        return [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _entriesPageState.toggleSearch();
              setState(() {});
            },
          ),
        ];
      }

      // Normal state - show all actions
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            _entriesPageState.toggleSearch();
            setState(() {});
          },
          tooltip: 'Search',
        ),
        IconButton(
          icon: Badge(
            isLabelVisible: hasFilters,
            child: const Icon(Icons.filter_list),
          ),
          onPressed: () {
            _entriesPageState.showFilterDialog();
          },
          tooltip: 'Filter',
        ),
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: () {
            _entriesPageState.showExportDialog();
          },
          tooltip: 'Export PDF',
        ),
      ];
    }

    return [];
  }

  Widget _buildOverviewTab(bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBusinessInfo(),
            const SizedBox(height: 24),
            Text(
              'Financial Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSummaryCards(isDarkMode),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessInfo() {
    return Consumer<BusinessProvider>(
      builder: (context, provider, _) {
        final business = provider.selectedBusiness;
        if (business == null) return const SizedBox.shrink();

        return Card(
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusinessProfilePage(business: business),
                ),
              );
              if (result == true && mounted) {
                _loadData();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        business.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            business.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 16,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color),
                              const SizedBox(width: 4),
                              Text(business.place),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.category, 'Category', business.category),
                if (business.vatNumber != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.receipt, 'VAT', business.vatNumber!),
                  if (business.vatExpiryDate != null)
                    Text(
                      '  Expires: ${DateFormatter.formatForDisplay(business.vatExpiryDate!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
                if (business.licenseNumber != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                      Icons.assignment, 'License', business.licenseNumber!),
                  if (business.licenseExpiryDate != null)
                    Text(
                      '  Expires: ${DateFormatter.formatForDisplay(business.licenseExpiryDate!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildSummaryCards(bool isDarkMode) {
    return Consumer<DailyEntryProvider>(
      builder: (context, provider, _) {
        if (provider.state == DailyEntryState.loading) {
          return const LoadingIndicator();
        }

        final summary = provider.summary;
        if (summary == null) {
          return const Center(child: Text('No data available'));
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Sales',
                    'AED ${summary.totalSales.toStringAsFixed(2)}',
                    Icons.trending_up,
                    isDarkMode
                        ? AppColors.salesCardDark
                        : AppColors.salesCardLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Expenses',
                    'AED ${summary.totalExpenses.toStringAsFixed(2)}',
                    Icons.trending_down,
                    isDarkMode
                        ? AppColors.expenseCardDark
                        : AppColors.expenseCardLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Bank Amount',
                    'AED ${summary.totalBankAmount.toStringAsFixed(2)}',
                    Icons.account_balance,
                    isDarkMode
                        ? AppColors.bankCardDark
                        : AppColors.bankCardLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Cash Amount',
                    'AED ${summary.totalCashAmount.toStringAsFixed(2)}',
                    Icons.attach_money,
                    isDarkMode
                        ? AppColors.cashCardDark
                        : AppColors.cashCardLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(
              'Net Profit',
              'AED ${summary.netProfit.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              summary.netProfit >= 0 ? AppColors.success : AppColors.errorLight,
              isFullWidth: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: isFullWidth ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: isFullWidth ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _navigateToDailyEntryForm,
                icon: const Icon(Icons.add),
                label: const Text('Add Entry'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _tabController.animateTo(2);
                },
                icon: const Icon(Icons.people),
                label: const Text('Employees'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
