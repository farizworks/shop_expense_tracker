import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/utils/pdf_generator.dart';
import '../../domain/entities/daily_entry.dart';
import '../providers/daily_entry_provider.dart';
import '../widgets/daily_entry_card.dart';
import 'daily_entry_form_page.dart';
import 'daily_entry_detail_page.dart';

class DailyEntriesListPage extends StatefulWidget {
  final int businessId;
  final String? businessName;
  final bool showAppBar;

  const DailyEntriesListPage({
    super.key,
    required this.businessId,
    this.businessName,
    this.showAppBar = true,
  });

  @override
  State<DailyEntriesListPage> createState() => _DailyEntriesListPageState();
}

class _DailyEntriesListPageState extends State<DailyEntriesListPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  List<DailyEntry> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    if (!mounted) return;
    await context.read<DailyEntryProvider>().loadDailyEntries(widget.businessId);
    if (!mounted) return;
    await context.read<DailyEntryProvider>().loadBusinessSummary(widget.businessId);
    _applyFilters();
  }

  void _applyFilters() {
    final provider = context.read<DailyEntryProvider>();
    var entries = List<DailyEntry>.from(provider.entries);

    // Apply search filter (by date)
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      entries = entries.where((entry) {
        final dateStr = DateFormat('dd MMM yyyy').format(entry.entryDate).toLowerCase();
        return dateStr.contains(searchTerm);
      }).toList();
    }

    // Apply date range filter
    if (_filterStartDate != null || _filterEndDate != null) {
      entries = entries.where((entry) {
        if (_filterStartDate != null && entry.entryDate.isBefore(_filterStartDate!)) {
          return false;
        }
        if (_filterEndDate != null && entry.entryDate.isAfter(_filterEndDate!)) {
          return false;
        }
        return true;
      }).toList();
    }

    setState(() {
      _filteredEntries = entries;
    });
  }

  Future<void> _navigateToForm({DateTime? date}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyEntryFormPage(
          businessId: widget.businessId,
        ),
      ),
    );

    if (result == true && mounted) {
      _loadEntries();
    }
  }

  // Public getters for parent widgets
  bool get isSearching => _isSearching;
  bool get hasActiveFilters => _filterStartDate != null || _filterEndDate != null;
  TextEditingController get searchController => _searchController;

  // Public methods for parent widgets to call
  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _applyFilters();
      }
    });
  }

  void _toggleSearch() => toggleSearch();

  void showFilterDialog() {
    _showFilterBottomSheet();
  }

  void showExportDialog() {
    _showExportDialog();
  }

  Future<void> _showFilterBottomSheet() async {
    DateTime? tempStartDate = _filterStartDate;
    DateTime? tempEndDate = _filterEndDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Date Range',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(
                  tempStartDate != null
                      ? DateFormat('dd MMM yyyy').format(tempStartDate!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: tempStartDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setModalState(() {
                      tempStartDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(
                  tempEndDate != null
                      ? DateFormat('dd MMM yyyy').format(tempEndDate!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: tempEndDate ?? DateTime.now(),
                    firstDate: tempStartDate ?? DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setModalState(() {
                      tempEndDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          tempStartDate = null;
                          tempEndDate = null;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterStartDate = tempStartDate;
                          _filterEndDate = tempEndDate;
                        });
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filter'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExportDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export to PDF'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose what to export:'),
            const SizedBox(height: 16),
            if (_filterStartDate != null || _filterEndDate != null)
              Text(
                'Filtered Data: ${_filteredEntries.length} entries',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                'All Data: ${_filteredEntries.length} entries',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _exportToPdf();
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Generate PDF'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToPdf() async {
    try {
      print('DEBUG: Starting PDF generation...');
      await PdfGenerator.generateEntriesReport(
        entries: _filteredEntries,
        businessName: widget.businessName,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      );
      print('DEBUG: PDF generation completed successfully');
    } catch (e, stackTrace) {
      print('DEBUG: PDF Generation Error: $e');
      print('DEBUG: Stack Trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _filterStartDate = null;
      _filterEndDate = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAppBar) {
      // Standalone mode with AppBar
      return Scaffold(
        appBar: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
        body: _buildBody(),
      );
    } else {
      // Embedded mode without AppBar
      return _buildBody();
    }
  }

  Widget _buildBody() {
    return Consumer<DailyEntryProvider>(
      builder: (context, provider, _) {
        if (provider.state == DailyEntryState.loading) {
          return const LoadingIndicator(message: 'Loading entries...');
        }

        if (provider.entries.isEmpty) {
          return EmptyState(
            icon: Icons.receipt_long,
            title: 'No Entries Yet',
            message: 'Start tracking your daily sales and expenses.',
            actionText: 'Add Entry',
            onActionPressed: _navigateToForm,
          );
        }

        if (_filteredEntries.isEmpty) {
          return Column(
            children: [
              if (_filterStartDate != null || _filterEndDate != null)
                _buildActiveFiltersChip(),
              const Expanded(
                child: EmptyState(
                  icon: Icons.filter_alt_off,
                  title: 'No Results',
                  message: 'No entries match your search or filter criteria.',
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            if (_filterStartDate != null || _filterEndDate != null)
              _buildActiveFiltersChip(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadEntries,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _filteredEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _filteredEntries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: DailyEntryCard(
                        entry: entry,
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DailyEntryDetailPage(
                                entry: entry,
                                businessId: widget.businessId,
                              ),
                            ),
                          );
                          if (result == true && mounted) {
                            _loadEntries();
                          }
                        },
                        onDelete: () => _showDeleteDialog(entry.id!),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: const Text('Daily Entries'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _toggleSearch,
          tooltip: 'Search',
        ),
        IconButton(
          icon: Badge(
            isLabelVisible: _filterStartDate != null || _filterEndDate != null,
            child: const Icon(Icons.filter_list),
          ),
          onPressed: _showFilterBottomSheet,
          tooltip: 'Filter',
        ),
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: _showExportDialog,
          tooltip: 'Export PDF',
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _toggleSearch,
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search by date...',
          border: InputBorder.none,
        ),
        onChanged: (_) => _applyFilters(),
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _applyFilters();
            },
          ),
      ],
    );
  }

  Widget _buildActiveFiltersChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                if (_filterStartDate != null || _filterEndDate != null)
                  Chip(
                    label: Text(
                      _filterStartDate != null && _filterEndDate != null
                          ? '${DateFormat('dd MMM').format(_filterStartDate!)} - ${DateFormat('dd MMM yyyy').format(_filterEndDate!)}'
                          : _filterStartDate != null
                              ? 'From ${DateFormat('dd MMM yyyy').format(_filterStartDate!)}'
                              : 'Until ${DateFormat('dd MMM yyyy').format(_filterEndDate!)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: _clearFilters,
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Clear', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(int entryId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
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
          await context.read<DailyEntryProvider>().removeDailyEntry(entryId);
      if (success && mounted) {
        _loadEntries();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully')),
        );
      }
    }
  }
}
