import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart'; // Adjusted path relative to this file
import 'dart:convert'; // Needed for jsonEncode

abstract class VerificationRemoteDataSource {
  Future<void> sendVerificationCode(String email);
  // *** CHANGED: verifyCode now returns void on success ***
  Future<void> verifyCode(String email, String code);
}

class VerificationRemoteDataSourceImpl implements VerificationRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  VerificationRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<void> sendVerificationCode(String email) async {
    final endpointPath = '/users/request-email-code';
    final url = Uri.parse('$baseUrl$endpointPath');
    print('[API Request] >>> Sending verification code request to: $url');
    print('[API Request] >>> Request body: ${jsonEncode({'email': email})}');

    try {
       final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email}),
      );

      print('[API Response] <<< Send code response status: ${response.statusCode}');
      print('[API Response] <<< Send code response body: ${response.body}');

      if (response.statusCode != 200) { // Assuming 200 is success
        throw ServerException('Failed to send verification code: ${response.body}');
      }
      // No return needed on success
    } catch (e) {
       print('*** Error sending verification code: $e');
       // Provide a more user-friendly generic message for network/server issues
       throw ServerException('Could not send verification code. Please check your connection or try again later.');
    }
  }

  @override
  // *** CHANGED: Returns Future<void> ***
  Future<void> verifyCode(String email, String code) async {
    final endpointPath = '/users/verify-email-code/'; // Keep trailing slash if needed
    final url = Uri.parse('$baseUrl$endpointPath');
    // Use the field name confirmed by user/API docs ('code' based on last confirmation)
    final requestBody = {'email': email, 'code': code};

    print('[API Request] >>> Verifying code request to: $url');
    print('[API Request] >>> Request body: ${jsonEncode(requestBody)}');

    try {
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      print('[API Response] <<< Verify code response status: ${response.statusCode}');
      // Log the body regardless of status for debugging
      print('[API Response] <<< Verify code response body: ${response.body}');

      if (response.statusCode != 200) { // Assuming 200 is success
        String errorMessage = response.body;
        try {
           final errorJson = jsonDecode(response.body);
           errorMessage = errorJson['message'] ?? errorJson['detail'] ?? errorJson['Error'] ?? response.body;
        } catch (_) { /* Ignore decoding error */ }
        throw ServerException('Failed to verify code (Status ${response.statusCode}): $errorMessage');
      }

      // *** No need to decode or return anything on success, just ensure status 200 ***
      print('<<< Code verified successfully (Status 200)');
      // Return void implicitly

    } catch (e) {
       print('*** Error verifying code: $e');
       if (e is ServerException) rethrow;
       // Provide a more user-friendly generic message
       throw ServerException('Could not verify code. Please check your connection or try again later.');
    }
  }
}
