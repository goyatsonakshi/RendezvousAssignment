import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart'; // Ensure correct path
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'dart:convert'; // For jsonDecode
import 'package:path/path.dart' as path;

// Abstract definition for profile data source operations.
abstract class ProfileRemoteDataSource {
  // Method signature includes password
  Future<Map<String, dynamic>> submitProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password, // Added password
    required String gender,
    required String dateOfBirth,
    required String purpose,
    File? videoFile,
  });
}

// Implementation using the http package.
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ProfileRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  // Method implementation includes password
  Future<Map<String, dynamic>> submitProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password, // Added password
    required String gender,
    required String dateOfBirth,
    required String purpose,
    File? videoFile,
  }) async {
    final endpointPath = '/users/createUserNoReferral/';
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl$endpointPath'),
    );

    // *** Using corrected field names based on previous backend error response ***
    request.fields['firstName'] = firstName;
    request.fields['lastName'] = lastName;
    request.fields['phone'] = phoneNumber;
    request.fields['email'] = email;
    request.fields['password'] = password; // Added password field for backend
    request.fields['gender'] = gender.toLowerCase(); // Ensure lowercase
    // request.fields['date_of_birth'] = dateOfBirth; // Commented out - backend reported as unrecognized
    request.fields['purposeOfUsingApp'] = purpose;
    // **********************************************************************

    // Add video file if provided
    if (videoFile != null) {
      try {
        var stream = http.ByteStream(videoFile.openRead());
        var length = await videoFile.length();
        var multipartFile = http.MultipartFile(
          'nonReferralVerificationVideo', // Field name confirmed by user
          stream,
          length,
          filename: path.basename(videoFile.path),
          contentType: MediaType('video', 'mp4'),
        );
        request.files.add(multipartFile);
      } catch (e) {
         print("Error attaching video file: $e");
         throw ServerException('Failed to read or attach video file.');
      }
    } else {
       print("Warning: Submitting profile without a video file.");
    }

    try {
      print('[API Request] >>> Submitting profile request to: ${request.url}');
      print('[API Request] >>> Profile fields: ${request.fields}'); // Will now include password
      print('[API Request] >>> Has video file: ${videoFile != null}');
      if (videoFile != null) {
          print('[API Request] >>> Video field name used: ${request.files.isNotEmpty ? request.files.first.field : 'N/A'}');
      }

      final response = await client.send(request);
      final responseBody = await response.stream.bytesToString();

      print('[API Response] <<< Profile submission response status: ${response.statusCode}');
      print('[API Response] <<< Profile submission response body: $responseBody');

      // Check response status code
      if (response.statusCode != 200 && response.statusCode != 201) {
        print("Profile submission failed: ${response.statusCode} - $responseBody");
        String errorMessage = responseBody;
         try {
           // Try to parse the specific JSON error format seen previously
           final errorJson = jsonDecode(responseBody);
           if (errorJson is Map && errorJson.containsKey('errors') && errorJson['errors'] is List) {
              errorMessage = (errorJson['errors'] as List).map((err) {
                 if (err is Map && err.containsKey('path') && err.containsKey('message')) {
                    return "${err['path']}: ${err['message']}";
                 } return err.toString();
              }).join('; ');
           } else {
              errorMessage = errorJson['message'] ?? errorJson['detail'] ?? errorJson['Error'] ?? responseBody;
           }
         } catch (_) { /* Ignore decoding error if response isn't JSON */ }
         // Handle potential HTML error pages
         if (responseBody.trim().startsWith('<!DOCTYPE html>')) {
           errorMessage = "Server returned an HTML error page (check server logs).";
         }
        throw ServerException(
            'Failed to submit profile (Status ${response.statusCode}): $errorMessage');
      }

      // Parse successful response (assuming it contains user data like userId, fullName)
      try {
        final decodedBody = json.decode(responseBody);
        if (decodedBody is Map<String, dynamic>) {
          print("<<< Profile submission successful, decoded response: $decodedBody");
          // This map should contain the data needed by UserModel.fromJson
          return decodedBody;
        } else {
          // Handle cases where response is success but not a JSON map
          throw ServerException('Invalid response format after profile submission (expected JSON Map).');
        }
      } on FormatException catch(e) {
         // Handle cases where response is success but body is not valid JSON
         print("*** Error decoding profile submission response: $e");
         throw ServerException('Failed to decode profile submission response.');
      }

    } on SocketException {
        // Handle network connection errors
        print("*** SocketException: Could not connect to server during profile submission.");
        throw ServerException('Network error: Could not connect to the server.');
    } on http.ClientException catch (e) {
        // Handle other HTTP client errors
        print("*** ClientException during profile submission: ${e.message}");
        throw ServerException('Network error: ${e.message}');
    } catch (e) {
        // Catch-all for other unexpected errors
        print("Error sending profile request: $e");
        if (e is ServerException) rethrow; // Don't wrap existing ServerExceptions
        throw ServerException('An unexpected error occurred during profile submission.');
    }
  }
}
