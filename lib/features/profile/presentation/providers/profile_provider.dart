import 'package:flutter/material.dart';
import '../../domain/usecases/submit_profile.dart';
import '../../../verification/domain/entities/user.dart'; // Import User entity
import 'dart:io';

// Manages state related to profile form submission.
class ProfileProvider extends ChangeNotifier {
  bool _isSubmitting = false;
  bool _isUploadingVideo = false; // Track video upload separately
  String? _submissionError;
  User? _submittedUser; // Store the user returned after successful submission

  // Getters
  bool get isSubmitting => _isSubmitting;
  bool get isUploadingVideo => _isUploadingVideo;
  String? get submissionError => _submissionError;
  User? get submittedUser => _submittedUser; // Expose the created user

  final SubmitProfile submitProfileUseCase;

  ProfileProvider({required this.submitProfileUseCase});

  // Clear errors and submitted user, e.g., before a new submission attempt
  void clearState() {
    bool changed = false;
    if (_submissionError != null) {
      _submissionError = null;
      changed = true;
    }
    if (_submittedUser != null) {
       _submittedUser = null;
       changed = true;
    }
    // Reset flags as well
    if (_isSubmitting || _isUploadingVideo) {
       _isSubmitting = false;
       _isUploadingVideo = false;
       changed = true;
    }

    if (changed) {
       notifyListeners();
    }
  }

  // Submit the completed profile data.
  // *** ADDED: password parameter ***
  Future<void> submitProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password, // Added
    required String gender,
    required String dateOfBirth,
    required String purpose,
    File? videoFile,
  }) async {
    _isSubmitting = true;
    _isUploadingVideo = videoFile != null;
    _submissionError = null;
    _submittedUser = null; // Clear previous user on new attempt
    notifyListeners();

    // Use case now expects password and returns Either<Failure, User>
    final result = await submitProfileUseCase(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email,
      password: password, // Pass password
      gender: gender,
      dateOfBirth: dateOfBirth,
      purpose: purpose,
      videoFile: videoFile,
    );

    // Update state after submission attempt completes
    _isUploadingVideo = false; // Upload attempt finished
    result.fold(
      (failure) {
        _submissionError = failure.message;
        _submittedUser = null;
      },
      (newUser) {
        // Success! Store the new user data. Error remains null.
        _submissionError = null;
        _submittedUser = newUser; // Store the returned user
        // The calling screen (Onboarding) will use this to update AppState.
      },
    );

    _isSubmitting = false;
    notifyListeners();
  }
}
