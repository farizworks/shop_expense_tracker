import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/business.dart';
import '../repositories/business_repository.dart';

class GetBusinessById implements UseCase<Business, GetBusinessByIdParams> {
  final BusinessRepository repository;

  GetBusinessById(this.repository);

  @override
  Future<Either<Failure, Business>> call(GetBusinessByIdParams params) async {
    return await repository.getBusinessById(params.id);
  }
}

class GetBusinessByIdParams extends Equatable {
  final int id;

  const GetBusinessByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}
