import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/business.dart';
import '../repositories/business_repository.dart';

class UpdateBusiness implements UseCase<Business, UpdateBusinessParams> {
  final BusinessRepository repository;

  UpdateBusiness(this.repository);

  @override
  Future<Either<Failure, Business>> call(UpdateBusinessParams params) async {
    return await repository.updateBusiness(params.business);
  }
}

class UpdateBusinessParams extends Equatable {
  final Business business;

  const UpdateBusinessParams({required this.business});

  @override
  List<Object> get props => [business];
}
