import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
// Removed User import as verifyCode no longer returns it

abstract class VerificationRepository {
  Future<Either<Failure, void>> sendVerificationCode(String email);
  // *** CHANGED: verifyCode now returns void on success ***
  Future<Either<Failure, void>> verifyCode(String email, String code);
}
