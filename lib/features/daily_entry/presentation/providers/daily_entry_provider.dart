import 'package:flutter/foundation.dart';
import '../../domain/entities/business_summary.dart';
import '../../domain/entities/daily_entry.dart';
import '../../domain/usecases/get_daily_entries.dart';
import '../../domain/usecases/get_daily_entry_by_date.dart';
import '../../domain/usecases/create_daily_entry.dart';
import '../../domain/usecases/update_daily_entry.dart';
import '../../domain/usecases/delete_daily_entry.dart';
import '../../domain/usecases/get_business_summary.dart';

enum DailyEntryState { initial, loading, loaded, error }

class DailyEntryProvider extends ChangeNotifier {
  final GetDailyEntries getDailyEntries;
  final GetDailyEntryByDate getDailyEntryByDate;
  final CreateDailyEntry createDailyEntry;
  final UpdateDailyEntry updateDailyEntry;
  final DeleteDailyEntry deleteDailyEntry;
  final GetBusinessSummary getBusinessSummary;

  DailyEntryProvider({
    required this.getDailyEntries,
    required this.getDailyEntryByDate,
    required this.createDailyEntry,
    required this.updateDailyEntry,
    required this.deleteDailyEntry,
    required this.getBusinessSummary,
  });

  DailyEntryState _state = DailyEntryState.initial;
  List<DailyEntry> _entries = [];
  DailyEntry? _selectedEntry;
  BusinessSummary? _summary;
  String _errorMessage = '';

  DailyEntryState get state => _state;
  List<DailyEntry> get entries => _entries;
  DailyEntry? get selectedEntry => _selectedEntry;
  BusinessSummary? get summary => _summary;
  String get errorMessage => _errorMessage;

  Future<void> loadDailyEntries(int businessId) async {
    _state = DailyEntryState.loading;
    notifyListeners();

    final result =
        await getDailyEntries(GetDailyEntriesParams(businessId: businessId));
    result.fold(
      (failure) {
        _state = DailyEntryState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (entries) {
        _state = DailyEntryState.loaded;
        _entries = entries;
        notifyListeners();
      },
    );
  }

  Future<void> loadDailyEntryByDate(int businessId, DateTime date) async {
    final result = await getDailyEntryByDate(
        GetDailyEntryByDateParams(businessId: businessId, date: date));
    result.fold(
      (failure) {
        _selectedEntry = null;
        notifyListeners();
      },
      (entry) {
        _selectedEntry = entry;
        notifyListeners();
      },
    );
  }

  Future<void> loadBusinessSummary(int businessId) async {
    final result = await getBusinessSummary(
        GetBusinessSummaryParams(businessId: businessId));
    result.fold(
      (failure) {
        _summary = null;
        notifyListeners();
      },
      (summary) {
        _summary = summary;
        notifyListeners();
      },
    );
  }

  Future<bool> addDailyEntry(DailyEntry entry) async {
    _state = DailyEntryState.loading;
    notifyListeners();

    final result = await createDailyEntry(CreateDailyEntryParams(entry: entry));
    return result.fold(
      (failure) {
        _state = DailyEntryState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (createdEntry) {
        _entries.insert(0, createdEntry);
        _state = DailyEntryState.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> editDailyEntry(DailyEntry entry) async {
    _state = DailyEntryState.loading;
    notifyListeners();

    final result = await updateDailyEntry(UpdateDailyEntryParams(entry: entry));
    return result.fold(
      (failure) {
        _state = DailyEntryState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (updatedEntry) {
        final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
        if (index != -1) {
          _entries[index] = updatedEntry;
        }
        if (_selectedEntry?.id == updatedEntry.id) {
          _selectedEntry = updatedEntry;
        }
        _state = DailyEntryState.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeDailyEntry(int id) async {
    _state = DailyEntryState.loading;
    notifyListeners();

    final result = await deleteDailyEntry(DeleteDailyEntryParams(id: id));
    return result.fold(
      (failure) {
        _state = DailyEntryState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _entries.removeWhere((e) => e.id == id);
        if (_selectedEntry?.id == id) {
          _selectedEntry = null;
        }
        _state = DailyEntryState.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void clearSelectedEntry() {
    _selectedEntry = null;
    notifyListeners();
  }

  void setSelectedEntry(DailyEntry entry) {
    _selectedEntry = entry;
    // Also ensure it's in the entries list
    if (!_entries.any((e) => e.id == entry.id)) {
      _entries.insert(0, entry);
    }
    notifyListeners();
  }

  Future<void> loadDailyEntryById(int entryId) async {

    // First, try to find in already loaded entries
    try {
      final entry = _entries.firstWhere((e) => e.id == entryId);
      _selectedEntry = entry;
      notifyListeners();
    } catch (e) {
      // Entry not found in loaded entries - check if it's already the selected entry
      if (_selectedEntry?.id == entryId) {
        // Entry is already selected, keep it
      } else {
        _selectedEntry = null;
      }
      notifyListeners();
    }
  }
}
