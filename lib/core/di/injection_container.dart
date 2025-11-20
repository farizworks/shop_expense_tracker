import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../theme/theme_provider.dart';
import '../../features/business/data/datasources/business_local_datasource.dart';
import '../../features/business/data/repositories/business_repository_impl.dart';
import '../../features/business/domain/repositories/business_repository.dart';
import '../../features/business/domain/usecases/get_all_businesses.dart';
import '../../features/business/domain/usecases/get_business_by_id.dart';
import '../../features/business/domain/usecases/create_business.dart';
import '../../features/business/domain/usecases/update_business.dart';
import '../../features/business/domain/usecases/delete_business.dart';
import '../../features/business/presentation/providers/business_provider.dart';
import '../../features/daily_entry/data/datasources/daily_entry_local_datasource.dart';
import '../../features/daily_entry/data/repositories/daily_entry_repository_impl.dart';
import '../../features/daily_entry/domain/repositories/daily_entry_repository.dart';
import '../../features/daily_entry/domain/usecases/get_daily_entries.dart';
import '../../features/daily_entry/domain/usecases/get_daily_entry_by_date.dart';
import '../../features/daily_entry/domain/usecases/create_daily_entry.dart';
import '../../features/daily_entry/domain/usecases/update_daily_entry.dart';
import '../../features/daily_entry/domain/usecases/delete_daily_entry.dart';
import '../../features/daily_entry/domain/usecases/get_business_summary.dart';
import '../../features/daily_entry/presentation/providers/daily_entry_provider.dart';
import '../../features/employee/data/datasources/employee_local_datasource.dart';
import '../../features/employee/data/repositories/employee_repository_impl.dart';
import '../../features/employee/domain/repositories/employee_repository.dart';
import '../../features/employee/domain/usecases/get_employees.dart';
import '../../features/employee/domain/usecases/create_employee.dart';
import '../../features/employee/domain/usecases/update_employee.dart';
import '../../features/employee/domain/usecases/delete_employee.dart';
import '../../features/employee/presentation/providers/employee_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============ External ============
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => DatabaseHelper.instance);

  // ============ Core ============
  sl.registerLazySingleton(() => ThemeProvider(sl()));

  // ============ Business Feature ============
  // Providers
  sl.registerFactory(() => BusinessProvider(
        getAllBusinesses: sl(),
        getBusinessById: sl(),
        createBusiness: sl(),
        updateBusiness: sl(),
        deleteBusiness: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetAllBusinesses(sl()));
  sl.registerLazySingleton(() => GetBusinessById(sl()));
  sl.registerLazySingleton(() => CreateBusiness(sl()));
  sl.registerLazySingleton(() => UpdateBusiness(sl()));
  sl.registerLazySingleton(() => DeleteBusiness(sl()));

  // Repository
  sl.registerLazySingleton<BusinessRepository>(
    () => BusinessRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<BusinessLocalDataSource>(
    () => BusinessLocalDataSourceImpl(sl()),
  );

  // ============ Daily Entry Feature ============
  // Providers
  sl.registerFactory(() => DailyEntryProvider(
        getDailyEntries: sl(),
        getDailyEntryByDate: sl(),
        createDailyEntry: sl(),
        updateDailyEntry: sl(),
        deleteDailyEntry: sl(),
        getBusinessSummary: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetDailyEntries(sl()));
  sl.registerLazySingleton(() => GetDailyEntryByDate(sl()));
  sl.registerLazySingleton(() => CreateDailyEntry(sl()));
  sl.registerLazySingleton(() => UpdateDailyEntry(sl()));
  sl.registerLazySingleton(() => DeleteDailyEntry(sl()));
  sl.registerLazySingleton(() => GetBusinessSummary(sl()));

  // Repository
  sl.registerLazySingleton<DailyEntryRepository>(
    () => DailyEntryRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<DailyEntryLocalDataSource>(
    () => DailyEntryLocalDataSourceImpl(sl()),
  );

  // ============ Employee Feature ============
  // Providers
  sl.registerFactory(() => EmployeeProvider(
        getEmployees: sl(),
        createEmployee: sl(),
        updateEmployee: sl(),
        deleteEmployee: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetEmployees(sl()));
  sl.registerLazySingleton(() => CreateEmployee(sl()));
  sl.registerLazySingleton(() => UpdateEmployee(sl()));
  sl.registerLazySingleton(() => DeleteEmployee(sl()));

  // Repository
  sl.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<EmployeeLocalDataSource>(
    () => EmployeeLocalDataSourceImpl(sl()),
  );
}
