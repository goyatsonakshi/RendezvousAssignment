        import 'package:flutter/material.dart';
        import '../../domain/usecases/check_admin_approval.dart';

        class ApprovalProvider extends ChangeNotifier {
          bool _isAdminApproved = false;
          String? _approvalCheckError;

          bool get isAdminApproved => _isAdminApproved;
          String? get approvalCheckError => _approvalCheckError;

          final CheckAdminApproval checkAdminApprovalUseCase;

          ApprovalProvider({required this.checkAdminApprovalUseCase});

          void setIsAdminApproved(bool value) {
            _isAdminApproved = value;
            notifyListeners();
          }

          void setApprovalCheckError(String? error) {
            _approvalCheckError = error;
            notifyListeners();
          }

          void clearErrors() {
            _approvalCheckError = null;
            notifyListeners();
          }

          Future<void> checkAdminApproval(String userId) async {
            _approvalCheckError = null;
            final result = await checkAdminApprovalUseCase(userId);
            result.fold(
              (failure) {
                _approvalCheckError = failure.message;
                notifyListeners();
              },
              (isApproved) {
                _isAdminApproved = isApproved;
                notifyListeners();
              },
            );
          }
        }
        