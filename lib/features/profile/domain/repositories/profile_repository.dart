import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../verification/domain/entities/user.dart';
import 'dart:io';

abstract class ProfileRepository {
  // *** Interface includes the password parameter ***
  Future<Either<Failure, User>> submitProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password, // Added
    required String gender,
    required String dateOfBirth,
    required String purpose,
    File? videoFile,
  });
}