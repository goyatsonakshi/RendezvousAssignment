// Full Path: rendezvous_app/lib/features/verification/domain/usecases/verify_code.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
// Removed User import as it's no longer returned by this use case
// import '../entities/user.dart';
import '../repositories/verification_repository.dart';

class VerifyCode {
  final VerificationRepository repository;

  VerifyCode({required this.repository});

  // *** CHANGED: Use case now returns void on success ***
  // It calls the repository's verifyCode method, which also returns void on success.
  // Basic validation for the code format is included here.
  Future<Either<Failure, void>> call(String email, String code) async {
    // Input validation
    if (code.isEmpty) {
      return Left(InvalidInputFailure('Verification code cannot be empty.'));
    }
    if (code.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(code)) {
       return Left(InvalidInputFailure('Verification code must be 6 digits.'));
    }
    // Call the repository to perform the verification via the data source
    return await repository.verifyCode(email, code);
  }
}
