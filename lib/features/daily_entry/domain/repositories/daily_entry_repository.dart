import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/daily_entry.dart';
import '../entities/business_summary.dart';

abstract class DailyEntryRepository {
  Future<Either<Failure, List<DailyEntry>>> getDailyEntries(int businessId);
  Future<Either<Failure, DailyEntry?>> getDailyEntryByDate(
      int businessId, DateTime date);
  Future<Either<Failure, DailyEntry>> createDailyEntry(DailyEntry entry);
  Future<Either<Failure, DailyEntry>> updateDailyEntry(DailyEntry entry);
  Future<Either<Failure, void>> deleteDailyEntry(int id);
  Future<Either<Failure, BusinessSummary>> getBusinessSummary(int businessId);
  Future<Either<Failure, List<DailyEntry>>> getDailyEntriesByDateRange(
      int businessId, DateTime startDate, DateTime endDate);
}
