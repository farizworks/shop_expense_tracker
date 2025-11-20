import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/business_summary.dart';
import '../../domain/entities/daily_entry.dart';
import '../../domain/repositories/daily_entry_repository.dart';
import '../datasources/daily_entry_local_datasource.dart';
import '../models/daily_entry_model.dart';

class DailyEntryRepositoryImpl implements DailyEntryRepository {
  final DailyEntryLocalDataSource localDataSource;

  DailyEntryRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<DailyEntry>>> getDailyEntries(
      int businessId) async {
    try {
      final entries = await localDataSource.getDailyEntries(businessId);
      return Right(entries);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DailyEntry?>> getDailyEntryByDate(
      int businessId, DateTime date) async {
    try {
      final entry = await localDataSource.getDailyEntryByDate(businessId, date);
      return Right(entry);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DailyEntry>> createDailyEntry(DailyEntry entry) async {
    try {
      final entryModel = DailyEntryModel.fromEntity(entry);
      final created = await localDataSource.createDailyEntry(entryModel);
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DailyEntry>> updateDailyEntry(DailyEntry entry) async {
    try {
      final entryModel = DailyEntryModel.fromEntity(entry);
      final updated = await localDataSource.updateDailyEntry(entryModel);
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDailyEntry(int id) async {
    try {
      await localDataSource.deleteDailyEntry(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BusinessSummary>> getBusinessSummary(
      int businessId) async {
    try {
      final summary = await localDataSource.getBusinessSummary(businessId);
      return Right(summary);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyEntry>>> getDailyEntriesByDateRange(
      int businessId, DateTime startDate, DateTime endDate) async {
    try {
      final entries = await localDataSource.getDailyEntriesByDateRange(
          businessId, startDate, endDate);
      return Right(entries);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
