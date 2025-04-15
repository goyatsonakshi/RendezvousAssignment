import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app_state.dart'; // To access user data or logout

// Placeholder for the main screen after user is approved.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendezvous Home'), // Use App Name
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Call clearUser from AppState to log out
              Provider.of<AppState>(context, listen: false).clearUser();
              // AppRoot will automatically navigate to OnboardingScreen
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${appState.user?.name ?? 'User'}!', // Display user name
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color, // Use themed color
                  ),
            ),
            const SizedBox(height: 20),
            const Text('You are approved and ready to connect!'),
            // TODO: Add your main application content here
          ],
        ),
      ),
    );
  }
}
