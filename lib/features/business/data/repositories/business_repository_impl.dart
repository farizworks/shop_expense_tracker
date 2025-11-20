import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';
import '../datasources/business_local_datasource.dart';
import '../models/business_model.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessLocalDataSource localDataSource;

  BusinessRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<Business>>> getAllBusinesses() async {
    try {
      final businesses = await localDataSource.getAllBusinesses();
      return Right(businesses);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Business>> getBusinessById(int id) async {
    try {
      final business = await localDataSource.getBusinessById(id);
      return Right(business);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Business>> createBusiness(Business business) async {
    try {
      final businessModel = BusinessModel.fromEntity(business);
      final createdBusiness = await localDataSource.createBusiness(businessModel);
      return Right(createdBusiness);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Business>> updateBusiness(Business business) async {
    try {
      final businessModel = BusinessModel.fromEntity(business);
      final updatedBusiness = await localDataSource.updateBusiness(businessModel);
      return Right(updatedBusiness);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBusiness(int id) async {
    try {
      await localDataSource.deleteBusiness(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getBusinessCount() async {
    try {
      final count = await localDataSource.getBusinessCount();
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
