import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/business.dart';
import '../repositories/business_repository.dart';

class CreateBusiness implements UseCase<Business, CreateBusinessParams> {
  final BusinessRepository repository;

  CreateBusiness(this.repository);

  @override
  Future<Either<Failure, Business>> call(CreateBusinessParams params) async {
    return await repository.createBusiness(params.business);
  }
}

class CreateBusinessParams extends Equatable {
  final Business business;

  const CreateBusinessParams({required this.business});

  @override
  List<Object> get props => [business];
}
