import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/verification/domain/entities/user.dart'; // Assuming User entity path

// Manages the core application state like user session and approval status.
class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  User? _user;
  String? _email;
  bool _isAdminApproved = false;
  bool _isLoading = true; // Indicates if loading initial state

  User? get user => _user;
  String? get email => _email;
  bool get isAdminApproved => _isAdminApproved;
  bool get isLoading => _isLoading;

  AppState() {
    _initPrefs();
  }

  // Initialize SharedPreferences and load initial data.
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await loadUserData();
    _isLoading = false;
    notifyListeners(); // Notify listeners after loading is complete
  }

  // Load user data and approval status from local storage.
  Future<void> loadUserData() async {
    if (_prefs == null) await _initPrefs(); // Ensure prefs are initialized

    final userId = _prefs?.getString('userId');
    final userName = _prefs?.getString('userName');
    final userEmail = _prefs?.getString('userEmail');
    final approved = _prefs?.getBool('isAdminApproved');

    if (userId != null && userName != null) {
      _user = User(id: userId, name: userName);
    } else {
      _user = null;
    }

    _email = userEmail; // Load email regardless of user object
    _isAdminApproved = approved ?? false;

    // No need to notify here, _initPrefs or specific setters will notify.
  }

  // Save user data upon successful verification/login.
  Future<void> setUser(User newUser, String userEmail) async {
    if (_prefs == null) await _initPrefs();
    _user = newUser;
    _email = userEmail;
    await _prefs?.setString('userId', newUser.id);
    await _prefs?.setString('userName', newUser.name);
    await _prefs?.setString('userEmail', userEmail);
    // Reset approval status when a new user is set (or handle as needed)
    await setAdminApprovalStatus(false);
    notifyListeners();
  }

  // Update and save the admin approval status.
  Future<void> setAdminApprovalStatus(bool isApproved) async {
    if (_prefs == null) await _initPrefs();
    _isAdminApproved = isApproved;
    await _prefs?.setBool('isAdminApproved', isApproved);
    notifyListeners();
  }

  // Clear user data on logout or error.
  Future<void> clearUser() async {
    if (_prefs == null) await _initPrefs();
    _user = null;
    _email = null;
    _isAdminApproved = false;
    await _prefs?.remove('userId');
    await _prefs?.remove('userName');
    await _prefs?.remove('userEmail');
    await _prefs?.remove('isAdminApproved');
    notifyListeners();
  }
}
