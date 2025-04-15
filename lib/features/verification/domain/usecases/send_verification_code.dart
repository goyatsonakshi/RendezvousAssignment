        import 'package:dartz/dartz.dart';
        import '../../../../core/error/failures.dart';
        import '../repositories/verification_repository.dart';

        class SendVerificationCode {
          final VerificationRepository repository;

          SendVerificationCode({required this.repository});

          Future<Either<Failure, void>> call(String email) async {
            return await repository.sendVerificationCode(email);
          }
        }
        