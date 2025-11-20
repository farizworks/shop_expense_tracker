import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/daily_entry.dart';
import '../repositories/daily_entry_repository.dart';

class CreateDailyEntry implements UseCase<DailyEntry, CreateDailyEntryParams> {
  final DailyEntryRepository repository;

  CreateDailyEntry(this.repository);

  @override
  Future<Either<Failure, DailyEntry>> call(CreateDailyEntryParams params) async {
    return await repository.createDailyEntry(params.entry);
  }
}

class CreateDailyEntryParams extends Equatable {
  final DailyEntry entry;

  const CreateDailyEntryParams({required this.entry});

  @override
  List<Object> get props => [entry];
}
