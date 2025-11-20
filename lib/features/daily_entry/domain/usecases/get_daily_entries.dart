import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/daily_entry.dart';
import '../repositories/daily_entry_repository.dart';

class GetDailyEntries implements UseCase<List<DailyEntry>, GetDailyEntriesParams> {
  final DailyEntryRepository repository;

  GetDailyEntries(this.repository);

  @override
  Future<Either<Failure, List<DailyEntry>>> call(GetDailyEntriesParams params) async {
    return await repository.getDailyEntries(params.businessId);
  }
}

class GetDailyEntriesParams extends Equatable {
  final int businessId;

  const GetDailyEntriesParams({required this.businessId});

  @override
  List<Object> get props => [businessId];
}
