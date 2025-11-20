import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/business_repository.dart';

class DeleteBusiness implements UseCase<void, DeleteBusinessParams> {
  final BusinessRepository repository;

  DeleteBusiness(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteBusinessParams params) async {
    return await repository.deleteBusiness(params.id);
  }
}

class DeleteBusinessParams extends Equatable {
  final int id;

  const DeleteBusinessParams({required this.id});

  @override
  List<Object> get props => [id];
}
