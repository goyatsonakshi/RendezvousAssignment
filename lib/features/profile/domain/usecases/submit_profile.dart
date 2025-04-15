// Full Path: rendezvous_app/lib/features/profile/domain/usecases/submit_profile.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../verification/domain/entities/user.dart'; // Need User entity for return type
import '../repositories/profile_repository.dart';
import 'dart:io'; // Needed for File type

class SubmitProfile {
  final ProfileRepository repository;

  SubmitProfile({required this.repository});

  // *** CHANGED: Removed userId, expects User return, added email and password ***
  // This use case now takes the necessary profile data (including the verified email and password)
  // and expects the repository to return the created User object upon success.
  Future<Either<Failure, User>> call({
    // required String userId, // Removed
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email, // Added email
    required String password, // Added password
    required String gender,
    required String dateOfBirth,
    required String purpose,
    File? videoFile,
  }) async {
    // Basic validation for required fields
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || phoneNumber.isEmpty) {
        return Left(InvalidInputFailure('Required profile fields cannot be empty.'));
    }
    // *** ADDED: Password Validation ***
    if (password.isEmpty) {
       return Left(InvalidInputFailure('Password cannot be empty.'));
    }
     if (password.length < 6) { // Example minimum length validation
       return Left(InvalidInputFailure('Password must be at least 6 characters.'));
    }
    // Add more specific validation as needed (e.g., phone format, password complexity)

    // Call the repository to submit the profile
    return await repository.submitProfile(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      email: email, // Pass email
      password: password, // Pass password
      gender: gender,
      dateOfBirth: dateOfBirth,
      purpose: purpose,
      videoFile: videoFile,
    );
  }
}
