import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app_state.dart'; // To potentially clear user on error?
import '../../../../theme.dart'; // Import theme for branding
import '../providers/approval_provider.dart';
import '../../../../shared/widgets/custom_dialog.dart';
// Removed duplicate import of approval_provider
// Removed import of app.dart (MainApp) - navigation is handled by AppRoot

class WaitingScreen extends StatefulWidget {
  final String userId; // Receive userId for polling
  const WaitingScreen({super.key, required this.userId});

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> with SingleTickerProviderStateMixin { // Added TickerProvider
  Timer? _timer;
  late AnimationController _animationController; // For subtle animation
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Slow pulse effect
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));


    // Approval check setup
    final approvalProvider = Provider.of<ApprovalProvider>(context, listen: false);
    // Start checking immediately on init
    _checkApprovalStatus(approvalProvider, widget.userId);
    // Start periodic timer
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
       // Check if the widget is still mounted before making the call
       if (mounted) {
         _checkApprovalStatus(approvalProvider, widget.userId);
       } else {
         timer.cancel(); // Cancel timer if widget is disposed
       }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer
    _animationController.dispose(); // Dispose animation controller
    super.dispose();
  }

  // Function to check approval status
  Future<void> _checkApprovalStatus(
      ApprovalProvider approvalProvider, String userId) async {
    // Don't check if already approved (AppState handles navigation)
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.isAdminApproved) {
      _timer?.cancel(); // Stop polling if already approved
      return;
    }

    try {
      approvalProvider.clearErrors(); // Clear previous errors
      await approvalProvider.checkAdminApproval(userId);

      // If approved, update AppState. AppRoot will handle navigation.
      if (mounted && approvalProvider.isAdminApproved) {
         Provider.of<AppState>(context, listen: false).setAdminApprovalStatus(true);
         _timer?.cancel(); // Stop polling
         // No navigation here - AppRoot handles it based on AppState change
      } else if (mounted && approvalProvider.approvalCheckError != null) {
         // Show non-critical error (e.g., temporary network issue)
         // Avoid showing dialog constantly on polling errors unless severe
         print("Polling error: ${approvalProvider.approvalCheckError}");
         // Optionally show a less intrusive error indicator
      }

    } catch (e) {
      // Catch unexpected errors during the check
      if (mounted) {
        print("Critical error during approval check: $e");
        // Consider showing a persistent error message or logging out
        // showCustomDialog(context, 'Error', 'A critical error occurred while checking approval.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider for error display updates
    final approvalProvider = Provider.of<ApprovalProvider>(context);

    return Scaffold(
      body: Container(
        // Apply background gradient from theme
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradientAlt,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo Placeholder (or an engaging graphic)
                ScaleTransition(
                  scale: _animation,
                  child: Icon(
                    Icons.hourglass_top_rounded, // Placeholder icon
                    size: 80,
                    color: AppTheme.fontBlue.withOpacity(0.8),
                  ),
                  // Or use your logo:
                  // child: Image.asset('assets/logo.png', height: 100),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Waiting for Approval',
                  style: AppTheme.headlineStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  'Your profile is under review by our admin team. We appreciate your patience!',
                  style: AppTheme.bodyStyle.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                   valueColor: AlwaysStoppedAnimation<Color>(AppTheme.fontBlue),
                ),
                const SizedBox(height: 20),
                 // Display polling errors subtly
                if (approvalProvider.approvalCheckError != null && !approvalProvider.isAdminApproved) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Temporary issue checking status. Retrying...',
                          style: AppTheme.errorStyle.copyWith(color: Colors.orange[700]),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 50),
                 // Optional: Add a button to contact support or logout
                 TextButton(
                   onPressed: () {
                     // Implement contact support or logout
                     // Example: Logout
                     Provider.of<AppState>(context, listen: false).clearUser();
                     // AppRoot will navigate back to OnboardingScreen
                   },
                   child: const Text('Logout or Contact Support?'),
                 )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
