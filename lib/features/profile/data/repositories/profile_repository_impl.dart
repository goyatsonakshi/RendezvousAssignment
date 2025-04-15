import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart'; // Import exceptions
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../../../verification/domain/entities/user.dart'; // Import User entity
import '../../../verification/data/models/user_model.dart'; // Import UserModel for parsing
import 'dart:io';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  // *** Includes required String password parameter to match interface ***
  Future<Either<Failure, User>> submitProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password, // Added parameter
    required String gender,
    required String dateOfBirth,
    required String purpose,
    File? videoFile,
  }) async {
    try {
      // Data source now returns the Map containing user data on success
      // *** Pass the password parameter to the remoteDataSource call ***
      final userDataMap = await remoteDataSource.submitProfile(
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

      // Parse the user data returned from profile submission
      try {
         // UserModel.fromJson needs to handle the actual keys (e.g., userId, fullName)
         // returned by the profile creation API. Ensure user_model.dart is updated.
         final user = UserModel.fromJson(userDataMap);

         // Basic validation after parsing: Ensure the critical ID was actually parsed
         if (user.id.isEmpty) {
           print("Error: Profile submitted but response missing valid user ID. Response: $userDataMap");
           return Left(ServerFailure("Profile submitted but failed to retrieve user ID."));
         }
         print("Profile submitted successfully, received User: ${user.id}, ${user.name}");
         return Right(user); // Return the newly created User object

      } catch (e) {
         // Catch errors during UserModel.fromJson (e.g., type mismatch, missing keys if not handled in model)
         print("Error parsing UserModel from profile submission response: $e. Response: $userDataMap");
         return Left(ServerFailure("Failed to parse user data from server response."));
      }

    } on ServerException catch (e) {
      // Handle errors thrown by the remoteDataSource during the API call
      return Left(ServerFailure(e.message));
    } catch (e) { // Generic catch for other potential issues like file errors before API call
       print("Unexpected error submitting profile: $e");
       return Left(ServerFailure('An unexpected error occurred during profile submission.'));
    }
  }
}
