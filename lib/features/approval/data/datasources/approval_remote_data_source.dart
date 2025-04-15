import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart'; // Adjusted path relative to this file
import 'dart:convert';

abstract class ApprovalRemoteDataSource {
  /// Checks the admin approval status for the given user ID.
  /// Returns true if approved, false otherwise.
  Future<bool> checkAdminApproval(String userId);
}

class ApprovalRemoteDataSourceImpl implements ApprovalRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ApprovalRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<bool> checkAdminApproval(String userId) async {
    // --- UPDATED Endpoint Path ---
    // Using the path from the PATCH URL provided by the user.
    // Assumes this endpoint is used for *checking* status via PATCH. Please verify.
    // Note: Using PATCH method as specified in requirements/user info.
    final endpointPath = '/users/approveUser/$userId'; // Construct path with userId
    final response = await client.patch(
      Uri.parse('$baseUrl$endpointPath'),
      // TODO: Add body or headers if required by the PATCH endpoint for checking status
      // body: json.encode({'some_parameter': 'value'}), // Example body
      // headers: {'Content-Type': 'application/json'}, // Example header
    );

    // TODO: Confirm expected success status code (e.g., 200)
    if (response.statusCode != 200) {
      throw ServerException(
          'Failed to check admin approval: ${response.body}');
    }
    // Decode the response and extract the approval status
    // TODO: Confirm the exact field name in the response ('is_approved' or similar)
    final responseData = json.decode(response.body);
    // Assuming the response contains a boolean field like 'is_approved' or similar
    // Defaulting to 'is_approved' based on original code, adjust if needed.
    final isApproved = responseData['is_approved'] as bool? ?? false;
    return isApproved;
  }
}
