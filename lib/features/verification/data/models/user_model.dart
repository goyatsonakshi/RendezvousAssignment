// Ensure this path correctly points to your User entity definition
import '../../domain/entities/user.dart';

class UserModel extends User {
  // Constructor uses 'id' and 'name' as defined in the base User entity
  const UserModel({required String id, required String name}) : super(id: id, name: name);

  // *** UPDATED Factory: Tries common keys for ID and Name ***
  // This should parse the JSON response from the PROFILE CREATION API.
  // ** Verify the keys ('userId', 'id', 'user_id', 'fullName', 'name', 'user_name')
  // ** against the actual response of the profile creation API. **
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Try common keys for the user ID, prioritizing 'userId', then 'id', then 'user_id'
    String userId = '';
    if (json.containsKey('userId') && json['userId'] is String && (json['userId'] as String).isNotEmpty) {
      userId = json['userId'];
    } else if (json.containsKey('id') && json['id'] is String && (json['id'] as String).isNotEmpty) {
      userId = json['id'];
    } else if (json.containsKey('user_id') && json['user_id'] is String && (json['user_id'] as String).isNotEmpty) {
      userId = json['user_id'];
    }
    // Add more checks here if other key names are possible (e.g., '_id')

    // Try common keys for the user name, provide default if none found
    String userName = 'User'; // Default name if no name field is found
     if (json.containsKey('fullName') && json['fullName'] is String && (json['fullName'] as String).isNotEmpty) {
      userName = json['fullName'];
    } else if (json.containsKey('name') && json['name'] is String && (json['name'] as String).isNotEmpty) {
      userName = json['name'];
    } else if (json.containsKey('user_name') && json['user_name'] is String && (json['user_name'] as String).isNotEmpty) {
      userName = json['user_name'];
    }
    // Add more checks here if other key names are possible

    // Log a warning if ID couldn't be found, as it's critical for the app flow
    if (userId.isEmpty) {
       print("Warning: Could not find a valid user ID key ('userId', 'id', 'user_id') in JSON. Creating User with empty ID. JSON: $json");
       // Depending on requirements, you might want to throw an error here instead
       // throw FormatException("Required user ID field ('userId', 'id', 'user_id') not found in JSON response.");
    }

    // Create the UserModel instance using the found (or default) values
    return UserModel(
      id: userId,
      name: userName,
    );
  }

  // Optional: Add a toJson method if you need to serialize UserModel
  // Make sure the keys here match what your backend expects if you ever send this model *to* the backend
  Map<String, dynamic> toJson() {
    // Using 'userId' and 'fullName' as examples, adjust if needed based on backend expectations
    return {
      'userId': id,
      'fullName': name,
    };
  }
}
