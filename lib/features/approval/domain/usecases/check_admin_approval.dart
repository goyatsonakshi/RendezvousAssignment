        import 'package:dartz/dartz.dart';
        import '../../../../core/error/failures.dart';
        import '../repositories/approval_repository.dart';

        class CheckAdminApproval {
          final ApprovalRepository repository;

          CheckAdminApproval({required this.repository});

          Future<Either<Failure, bool>> call(String userId) async {
            return await repository.checkAdminApproval(userId);
          }
        }
        