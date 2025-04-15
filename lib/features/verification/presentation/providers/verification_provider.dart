import 'package:flutter/material.dart';
import '../../domain/usecases/send_verification_code.dart';
import '../../domain/usecases/verify_code.dart';
// Removed User import as it's no longer handled directly here
// import '../../domain/entities/user.dart';

// Manages state related to the email and code verification process.
class VerificationProvider extends ChangeNotifier {
  String? _email; // Store the email being verified
  // User? _user; // Removed - User data is not obtained here anymore
  bool _isSendingCode = false;
  bool _isVerifyingCode = false;
  String? _verificationError;
  bool _isVerified = false; // Flag to indicate successful verification

  // Getters
  String? get email => _email;
  // User? get user => _user; // Removed
  bool get isSendingCode => _isSendingCode;
  bool get isVerifyingCode => _isVerifyingCode;
  String? get verificationError => _verificationError;
  bool get isVerified => _isVerified; // Expose verification status

  final SendVerificationCode sendVerificationCodeUseCase;
  final VerifyCode verifyCodeUseCase;

  VerificationProvider({
    required this.sendVerificationCodeUseCase,
    required this.verifyCodeUseCase,
  });

  // Set email (used internally when moving steps)
  void setEmail(String? email) { // Allow setting null to reset
    _email = email;
    // Reset verification status when email changes or is cleared
    if (_isVerified) {
      _isVerified = false;
      // Optionally notify listeners if UI needs immediate reaction to reset
      // notifyListeners();
    }
  }

  // Clear errors, e.g., when retrying or changing steps
  void clearErrors() {
    if (_verificationError != null) {
      _verificationError = null;
      notifyListeners(); // Notify if an error was cleared
    }
  }

  // Reset verification status (e.g., when going back from code input)
  void resetVerificationStatus() {
     if (_isVerified) { // Only reset and notify if it was previously true
        _isVerified = false;
        notifyListeners();
     }
  }

  // Send verification code to the provided email.
  Future<void> sendVerificationCode(String targetEmail) async {
    _isSendingCode = true;
    _verificationError = null;
    _isVerified = false; // Reset verification status on new send attempt
    notifyListeners();

    final result = await sendVerificationCodeUseCase(targetEmail);

    result.fold(
      (failure) {
        _verificationError = failure.message;
      },
      (_) {
        // Success, email is set internally by the calling screen logic
        _email = targetEmail; // Keep track of the email for verification step
        _verificationError = null;
      },
    );

    _isSendingCode = false;
    notifyListeners();
  }

  // Verify the entered code for the current email.
  Future<void> verifyCode(String targetEmail, String code) async {
    _isVerifyingCode = true;
    _verificationError = null;
    _isVerified = false; // Reset verification status before attempting
    notifyListeners();

    // Ensure email consistency
    final emailToVerify = _email ?? targetEmail;
    if (emailToVerify.isEmpty) {
       _verificationError = "Email is missing.";
       _isVerifyingCode = false;
       notifyListeners();
       return;
    }

    // *** CHANGED: Expects void success from use case ***
    final result = await verifyCodeUseCase(emailToVerify, code);

    result.fold(
      (failure) {
        _verificationError = failure.message;
        _isVerified = false;
      },
      (_) {
        // Verification successful! Set flag, clear error.
        _verificationError = null;
        _isVerified = true; // Set verification success flag
        // The calling screen (OnboardingScreen) will use this flag
        // to determine if it should move to the profile input step.
      },
    );

    _isVerifyingCode = false;
    notifyListeners();
  }
}
