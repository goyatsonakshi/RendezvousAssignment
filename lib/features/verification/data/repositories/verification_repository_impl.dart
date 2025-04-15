import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart'; // Ensure exceptions are imported
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_data_source.dart';
import '../../domain/entities/user.dart'; // Import User entity for type safety, though not returned directly by verifyCode
import '../models/user_model.dart'; // Import UserModel for parsing in profile submission flow (even if not used directly here)

class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;

  VerificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> sendVerificationCode(String email) async {
    try {
      await remoteDataSource.sendVerificationCode(email);
      return const Right(null); // Return Right(null) for void success
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      // Catch-all for unexpected errors during the send process
      print("Unexpected error sending code: $e");
      return Left(ServerFailure('An unexpected error occurred while sending the code.'));
    }
  }

  @override
  // *** CHANGED: Returns Future<Either<Failure, void>> ***
  Future<Either<Failure, void>> verifyCode(String email, String code) async {
    try {
      // remoteDataSource.verifyCode now returns Future<void> on success (status 200)
      // It will throw a ServerException if the status code is not 200.
      await remoteDataSource.verifyCode(email, code);

      // If no exception was thrown by the data source, verification was successful.
      // We no longer parse user data here in this flow.
      return const Right(null); // Indicate success with Right(null)

    } on ServerException catch (e) {
      // Handle specific errors reported by the server (e.g., invalid code)
      // or errors thrown by the datasource itself (like connection issues).
      return Left(ServerFailure(e.message));
    } catch (e) {
      // Catch-all for other unexpected errors during the verify process
      print("Unexpected error verifying code: $e");
      return Left(ServerFailure('An unexpected error occurred during verification.'));
    }
    // Note: The logic to check for specific keys like 'userId' was moved
    // because this method now only confirms success (status 200) from the datasource.
    // The actual user data retrieval and validation happens after profile submission.
  }
}
