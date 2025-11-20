import 'package:flutter/foundation.dart';
import '../../domain/entities/business.dart';
import '../../domain/usecases/get_all_businesses.dart';
import '../../domain/usecases/get_business_by_id.dart';
import '../../domain/usecases/create_business.dart';
import '../../domain/usecases/update_business.dart';
import '../../domain/usecases/delete_business.dart';
import '../../../../core/usecases/usecase.dart';

enum BusinessState { initial, loading, loaded, error }

class BusinessProvider extends ChangeNotifier {
  final GetAllBusinesses getAllBusinesses;
  final GetBusinessById getBusinessById;
  final CreateBusiness createBusiness;
  final UpdateBusiness updateBusiness;
  final DeleteBusiness deleteBusiness;

  BusinessProvider({
    required this.getAllBusinesses,
    required this.getBusinessById,
    required this.createBusiness,
    required this.updateBusiness,
    required this.deleteBusiness,
  });

  BusinessState _state = BusinessState.initial;
  List<Business> _businesses = [];
  Business? _selectedBusiness;
  String _errorMessage = '';

  BusinessState get state => _state;
  List<Business> get businesses => _businesses;
  Business? get selectedBusiness => _selectedBusiness;
  String get errorMessage => _errorMessage;
  int get businessCount => _businesses.length;

  Future<void> loadBusinesses() async {
    _state = BusinessState.loading;
    notifyListeners();

    final result = await getAllBusinesses(NoParams());
    result.fold(
      (failure) {
        _state = BusinessState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (businesses) {
        _state = BusinessState.loaded;
        _businesses = businesses;
        notifyListeners();
      },
    );
  }

  Future<void> loadBusinessById(int id) async {
    _state = BusinessState.loading;
    notifyListeners();

    final result = await getBusinessById(GetBusinessByIdParams(id: id));
    result.fold(
      (failure) {
        _state = BusinessState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (business) {
        _state = BusinessState.loaded;
        _selectedBusiness = business;
        notifyListeners();
      },
    );
  }

  Future<bool> addBusiness(Business business) async {
    _state = BusinessState.loading;
    notifyListeners();

    final result = await createBusiness(CreateBusinessParams(business: business));
    return result.fold(
      (failure) {
        _state = BusinessState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (createdBusiness) {
        _businesses.insert(0, createdBusiness);
        _state = BusinessState.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> editBusiness(Business business) async {
    _state = BusinessState.loading;
    notifyListeners();

    final result = await updateBusiness(UpdateBusinessParams(business: business));
    return result.fold(
      (failure) {
        _state = BusinessState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (updatedBusiness) {
        final index = _businesses.indexWhere((b) => b.id == updatedBusiness.id);
        if (index != -1) {
          _businesses[index] = updatedBusiness;
        }
        if (_selectedBusiness?.id == updatedBusiness.id) {
          _selectedBusiness = updatedBusiness;
        }
        _state = BusinessState.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> removeBusiness(int id) async {
    _state = BusinessState.loading;
    notifyListeners();

    final result = await deleteBusiness(DeleteBusinessParams(id: id));
    return result.fold(
      (failure) {
        _state = BusinessState.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _businesses.removeWhere((b) => b.id == id);
        if (_selectedBusiness?.id == id) {
          _selectedBusiness = null;
        }
        _state = BusinessState.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  void setSelectedBusiness(Business business) {
    _selectedBusiness = business;
    notifyListeners();
  }

  void clearSelectedBusiness() {
    _selectedBusiness = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
