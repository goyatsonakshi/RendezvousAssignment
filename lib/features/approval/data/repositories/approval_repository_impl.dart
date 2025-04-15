import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
// *** ADDED: Import for ServerException ***
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/approval_repository.dart';
import '../datasources/approval_remote_data_source.dart';

class ApprovalRepositoryImpl implements ApprovalRepository {
  final ApprovalRemoteDataSource remoteDataSource;

  ApprovalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, bool>> checkAdminApproval(String userId) async {
    try {
      final isApproved =
          await remoteDataSource.checkAdminApproval(userId);
      return Right(isApproved);
      // *** Corrected exception type ***
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) { // Generic catch for other potential issues
       return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}
