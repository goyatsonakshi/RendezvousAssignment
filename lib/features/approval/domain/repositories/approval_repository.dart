        import 'package:dartz/dartz.dart';
        import '../../../../core/error/failures.dart';

        abstract class ApprovalRepository {
          Future<Either<Failure, bool>> checkAdminApproval(String userId);
        }
        