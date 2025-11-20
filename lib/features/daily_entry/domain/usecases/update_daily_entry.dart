import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/daily_entry.dart';
import '../repositories/daily_entry_repository.dart';

class UpdateDailyEntry implements UseCase<DailyEntry, UpdateDailyEntryParams> {
  final DailyEntryRepository repository;

  UpdateDailyEntry(this.repository);

  @override
  Future<Either<Failure, DailyEntry>> call(UpdateDailyEntryParams params) async {
    return await repository.updateDailyEntry(params.entry);
  }
}

class UpdateDailyEntryParams extends Equatable {
  final DailyEntry entry;

  const UpdateDailyEntryParams({required this.entry});

  @override
  List<Object> get props => [entry];
}
