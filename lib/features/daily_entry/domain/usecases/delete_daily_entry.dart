import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/daily_entry_repository.dart';

class DeleteDailyEntry implements UseCase<void, DeleteDailyEntryParams> {
  final DailyEntryRepository repository;

  DeleteDailyEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteDailyEntryParams params) async {
    return await repository.deleteDailyEntry(params.id);
  }
}

class DeleteDailyEntryParams extends Equatable {
  final int id;

  const DeleteDailyEntryParams({required this.id});

  @override
  List<Object> get props => [id];
}
