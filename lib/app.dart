import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'theme.dart'; // Import the theme
import 'features/onboarding/presentation/screens/onboarding_screen.dart'; // Import the new onboarding screen
import 'features/approval/presentation/screens/waiting_screen.dart';
import 'features/home/presentation/screens/home_screen.dart'; // Placeholder for your main app screen

// Main Application Widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rendezvous', // App Name from requirements
      theme: AppTheme.lightTheme, // Apply the custom theme
      debugShowCheckedModeBanner: false,
      home: const AppRoot(),
    );
  }
}

// Root widget that decides which screen to show based on AppState
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to react to changes in AppState
    return Consumer<AppState>(
      builder: (context, appState, _) {
        // Show loading indicator while initializing
        if (appState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Decision logic based on user state
        if (appState.user == null) {
          // No user logged in -> Show Onboarding
          return const OnboardingScreen();
        } else {
          // User is logged in (verified)
          if (appState.isAdminApproved) {
            // User is approved -> Show Main App Home Screen
            return const HomeScreen(); // Navigate to your main app screen
          } else {
            // User is verified but not approved -> Show Waiting Screen
            // Pass user ID to WaitingScreen if needed for polling
            return WaitingScreen(userId: appState.user!.id);
          }
        }
      },
    );
  }
}
