import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/daily_entry.dart';
import '../repositories/daily_entry_repository.dart';

class GetDailyEntryByDate implements UseCase<DailyEntry?, GetDailyEntryByDateParams> {
  final DailyEntryRepository repository;

  GetDailyEntryByDate(this.repository);

  @override
  Future<Either<Failure, DailyEntry?>> call(GetDailyEntryByDateParams params) async {
    return await repository.getDailyEntryByDate(params.businessId, params.date);
  }
}

class GetDailyEntryByDateParams extends Equatable {
  final int businessId;
  final DateTime date;

  const GetDailyEntryByDateParams({
    required this.businessId,
    required this.date,
  });

  @override
  List<Object> get props => [businessId, date];
}
