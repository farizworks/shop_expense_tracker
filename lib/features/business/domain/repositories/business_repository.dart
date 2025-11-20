import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/business.dart';

abstract class BusinessRepository {
  Future<Either<Failure, List<Business>>> getAllBusinesses();
  Future<Either<Failure, Business>> getBusinessById(int id);
  Future<Either<Failure, Business>> createBusiness(Business business);
  Future<Either<Failure, Business>> updateBusiness(Business business);
  Future<Either<Failure, void>> deleteBusiness(int id);
  Future<Either<Failure, int>> getBusinessCount();
}
