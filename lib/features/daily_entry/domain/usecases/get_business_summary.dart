import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/business_summary.dart';
import '../repositories/daily_entry_repository.dart';

class GetBusinessSummary implements UseCase<BusinessSummary, GetBusinessSummaryParams> {
  final DailyEntryRepository repository;

  GetBusinessSummary(this.repository);

  @override
  Future<Either<Failure, BusinessSummary>> call(GetBusinessSummaryParams params) async {
    return await repository.getBusinessSummary(params.businessId);
  }
}

class GetBusinessSummaryParams extends Equatable {
  final int businessId;

  const GetBusinessSummaryParams({required this.businessId});

  @override
  List<Object> get props => [businessId];
}
