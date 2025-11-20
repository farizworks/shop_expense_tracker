import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/business.dart';
import '../repositories/business_repository.dart';

class GetAllBusinesses implements UseCase<List<Business>, NoParams> {
  final BusinessRepository repository;

  GetAllBusinesses(this.repository);

  @override
  Future<Either<Failure, List<Business>>> call(NoParams params) async {
    return await repository.getAllBusinesses();
  }
}
