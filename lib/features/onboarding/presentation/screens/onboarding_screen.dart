import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../../../app_state.dart';
import '../../../../theme.dart';
import '../../../verification/presentation/providers/verification_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../../../verification/domain/entities/user.dart';

// Enum to manage the state of the onboarding screen
enum OnboardingStep { emailInput, codeInput, profileInput }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  // *** ADDED: Password Controllers ***
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedGender;
  final _dateOfBirthController = TextEditingController();
  String? _selectedPurpose;
  File? _videoFile;
  VideoPlayerController? _videoPlayerController;
  bool _isVideoValid = false;
  bool _isCheckingVideo = false;
  // *** ADDED: Password Visibility State ***
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;


  OnboardingStep _currentStep = OnboardingStep.emailInput;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _purposeOptions = ['Spark', 'Linkup'];

  @override
  void initState() {
    super.initState();
    // Pre-fill email if returning to this screen after logout (AppState might have it)
    // Or get it from verification provider if it was set there previously in the session
    final verificationProvider = Provider.of<VerificationProvider>(context, listen: false);
    _emailController.text = verificationProvider.email ?? Provider.of<AppState>(context, listen: false).email ?? '';
  }


  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _dateOfBirthController.dispose();
    _videoPlayerController?.dispose();
    // *** ADDED: Dispose password controllers ***
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Step Navigation ---
  void _moveToCodeInput(String email) {
    // Store email in the provider for the next step
    Provider.of<VerificationProvider>(context, listen: false).setEmail(email);
    setState(() {
      _currentStep = OnboardingStep.codeInput;
    });
  }

  // *** CHANGED: No longer needs User parameter ***
  void _moveToProfileInput(BuildContext context) {
    // Just change the step, user ID is not available yet
    setState(() {
      _currentStep = OnboardingStep.profileInput;
    });
  }

  // --- Email Verification ---
  Future<void> _sendCode() async {
    // *** Logging Added Previously ***
    print("[OnboardingScreen] _sendCode: Attempting to send code...");
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // *** Logging Added Previously ***
    print("[OnboardingScreen] _sendCode: Validating form...");
    // Reset form validation state if moving from profile back to email
    // _formKey.currentState?.reset(); // Resetting here might clear the email field too soon
    if (_formKey.currentState?.validate() ?? false) {
      // *** Logging Added Previously ***
      print("[OnboardingScreen] _sendCode: Form is valid.");
      final verificationProvider =
          Provider.of<VerificationProvider>(context, listen: false);
      verificationProvider.clearErrors();
      final email = _emailController.text.trim();
      // *** Logging Added Previously ***
      print("[OnboardingScreen] _sendCode: Email entered: $email");
      print("[OnboardingScreen] _sendCode: Calling verificationProvider.sendVerificationCode...");

      await verificationProvider.sendVerificationCode(email);

      // *** Logging Added Previously ***
      print("[OnboardingScreen] _sendCode: verificationProvider.sendVerificationCode finished.");
      print("[OnboardingScreen] _sendCode: Error state: ${verificationProvider.verificationError}");

      if (mounted) {
        if (verificationProvider.verificationError == null) {
          print("[OnboardingScreen] _sendCode: Success! Moving to code input.");
          _moveToCodeInput(email);
          showCustomDialog(context, 'Code Sent',
              'A verification code has been sent to $email.');
        } else {
           print("[OnboardingScreen] _sendCode: Error occurred: ${verificationProvider.verificationError}");
          showCustomDialog(context, 'Error',
              verificationProvider.verificationError ?? 'Failed to send code.');
        }
      }
    } else {
       // *** Logging Added Previously ***
       print("[OnboardingScreen] _sendCode: Form is INVALID.");
    }
  }

  // --- Code Verification ---
  Future<void> _verifyCode() async {
    print("[OnboardingScreen] _verifyCode: Attempting to verify code...");
    FocusScope.of(context).unfocus();

    print("[OnboardingScreen] _verifyCode: Validating form...");
     // Resetting here might clear the code field too soon
    // _formKey.currentState?.reset();
    if (_formKey.currentState?.validate() ?? false) {
      print("[OnboardingScreen] _verifyCode: Form is valid.");
      final verificationProvider =
          Provider.of<VerificationProvider>(context, listen: false);
      verificationProvider.clearErrors();
      final email = verificationProvider.email!;
      final code = _codeController.text.trim();
      print("[OnboardingScreen] _verifyCode: Email: $email, Code: $code");
      print("[OnboardingScreen] _verifyCode: Calling verificationProvider.verifyCode...");


      await verificationProvider.verifyCode(email, code);

      print("[OnboardingScreen] _verifyCode: verificationProvider.verifyCode finished.");
      print("[OnboardingScreen] _verifyCode: Error state: ${verificationProvider.verificationError}");
      print("[OnboardingScreen] _verifyCode: Is verified: ${verificationProvider.isVerified}");


      if (mounted) {
        // *** Check provider's isVerified flag ***
        if (verificationProvider.verificationError == null && verificationProvider.isVerified) {
          print("[OnboardingScreen] _verifyCode: Success! Moving to profile input.");
          _moveToProfileInput(context); // No user data passed
        } else {
           print("[OnboardingScreen] _verifyCode: Error occurred: ${verificationProvider.verificationError}");
          showCustomDialog(
              context,
              'Error',
              verificationProvider.verificationError ??
                  'Verification failed. Please check the code.');
        }
      }
    } else {
       print("[OnboardingScreen] _verifyCode: Form is INVALID.");
    }
  }

  // --- Profile Submission ---
  Future<void> _submitProfile() async {
    print("[OnboardingScreen] _submitProfile: Attempting to submit profile...");
    FocusScope.of(context).unfocus();

    print("[OnboardingScreen] _submitProfile: Validating form...");
    // Resetting here might clear fields too soon if validation fails below
    // _formKey.currentState?.reset();
    if (_formKey.currentState?.validate() ?? false) { // This now validates password fields too
      print("[OnboardingScreen] _submitProfile: Form is valid.");
      if (_videoFile == null) {
         print("[OnboardingScreen] _submitProfile: Video file is missing.");
        showCustomDialog(context, 'Missing Video', 'Please upload a video.');
        return;
      }
      if (!_isVideoValid) {
         print("[OnboardingScreen] _submitProfile: Video is invalid (duration > 20s).");
         showCustomDialog(context, 'Invalid Video', 'Video must be 20 seconds or less.');
         return;
      }

      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      // Get email from VerificationProvider as it was confirmed in the previous step
      final email = Provider.of<VerificationProvider>(context, listen: false).email;

      if (email == null || email.isEmpty) {
         print("[OnboardingScreen] _submitProfile: Email is null or empty.");
         showCustomDialog(context, 'Error', 'User email not found. Please restart onboarding.');
         return;
      }

      profileProvider.clearState(); // Clear previous errors and submitted user
      // *** Get password from controller ***
      final password = _passwordController.text; // No trim needed usually
      print("[OnboardingScreen] _submitProfile: Calling profileProvider.submitProfile...");

      // *** Pass password to provider ***
      await profileProvider.submitProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        email: email,
        password: password, // Pass password
        gender: _selectedGender!,
        dateOfBirth: _dateOfBirthController.text.trim(),
        purpose: _selectedPurpose!,
        videoFile: _videoFile,
      );

       print("[OnboardingScreen] _submitProfile: profileProvider.submitProfile finished.");
       print("[OnboardingScreen] _submitProfile: Error state: ${profileProvider.submissionError}");
       print("[OnboardingScreen] _submitProfile: Submitted user: ${profileProvider.submittedUser?.id}");


      if (mounted) {
        // Check for submission errors OR success (indicated by submittedUser being non-null)
        if (profileProvider.submissionError == null && profileProvider.submittedUser != null) {
          // *** Set user in AppState AFTER successful profile submission ***
          final newUser = profileProvider.submittedUser!;
          print("[OnboardingScreen] _submitProfile: Success! Setting user in AppState.");
          // Use the email confirmed during verification
          await Provider.of<AppState>(context, listen: false).setUser(newUser, email);

          showCustomDialog(context, 'Profile Submitted',
              'Your profile is submitted and awaiting admin approval.');
          // Navigation handled by AppRoot reacting to AppState change

        } else {
           print("[OnboardingScreen] _submitProfile: Error occurred: ${profileProvider.submissionError}");
          showCustomDialog(context, 'Error',
              profileProvider.submissionError ?? 'Failed to submit profile.');
        }
      }
    } else {
       print("[OnboardingScreen] _submitProfile: Form is INVALID.");
    }
  }

  // --- Video Handling ---
  Future<void> _pickVideo() async {
     final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      // Dispose previous controller before assigning new file
      await _videoPlayerController?.dispose();
      _videoPlayerController = null;

      setState(() {
        _videoFile = file;
        _isVideoValid = false;
        _isCheckingVideo = true;
      });
      await _validateVideoDuration(file);
    }
  }

  Future<void> _validateVideoDuration(File videoFile) async {
     VideoPlayerController? tempController;
    try {
      tempController = VideoPlayerController.file(videoFile);
      await tempController.initialize();
      final duration = tempController.value.duration;

      if (mounted) {
        setState(() {
          _videoPlayerController = tempController; // Keep controller for potential preview
          _isVideoValid = duration <= const Duration(seconds: 20);
          _isCheckingVideo = false; // Done checking
          if (!_isVideoValid) {
            showCustomDialog(context, 'Video Too Long', 'Video must be 20 seconds or less. Duration: ${duration.inSeconds}s');
          }
        });
      } else {
         // If not mounted by the time initialization finishes, dispose controller
         await tempController.dispose();
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isVideoValid = false;
          _isCheckingVideo = false;
        });
        showCustomDialog(context, 'Video Error', 'Could not read video duration.');
      }
      print("Error validating video: $e");
      // Dispose controller if error occurred
      await tempController?.dispose();
    }
     // Don't dispose the main _videoPlayerController here if validation was successful
     // It's disposed in the main dispose() method or when a new video is picked.
  }


  // --- Date Picker ---
  Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Ensure user is at least 18
      helpText: 'Select Date of Birth',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
      builder: (context, child) {
        // Apply theme to DatePicker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.fontBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.fontBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.fontBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // --- Build Methods ---
  @override
  Widget build(BuildContext context) {
    // Use a Consumer for VerificationProvider to react to email changes for pre-filling
    return Consumer<VerificationProvider>(
      builder: (context, verificationProvider, child) {
        // Pre-fill email controller if provider has email and controller is empty
        // This helps if user goes back and forth
        if (_currentStep == OnboardingStep.emailInput &&
            verificationProvider.email != null &&
            _emailController.text.isEmpty) {
          _emailController.text = verificationProvider.email!;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Rendezvous Onboarding'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            // Add back button conditionally for code/profile steps
            leading: _currentStep != OnboardingStep.emailInput
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppTheme.fontBlue),
                    onPressed: () {
                      // Reset form validation when going back
                      _formKey.currentState?.reset(); // Reset validation state
                      // Clear controllers specific to the step we are leaving
                      if (_currentStep == OnboardingStep.codeInput) {
                         _codeController.clear();
                        verificationProvider.clearErrors();
                        // Keep email in provider, just change step
                        // verificationProvider.setEmail(null); // Don't clear email here
                        verificationProvider.resetVerificationStatus();
                        setState(() { _currentStep = OnboardingStep.emailInput; });
                      } else if (_currentStep == OnboardingStep.profileInput) {
                         // Clear profile form fields when going back? Optional.
                         // _firstNameController.clear(); ... etc.
                         // _videoFile = null; ... etc.
                         verificationProvider.clearErrors(); // Clear potential verification errors if any lingered
                         verificationProvider.resetVerificationStatus(); // Ensure verified flag is false
                         setState(() { _currentStep = OnboardingStep.codeInput; });
                      }
                    },
                  )
                : null, // No back button on email input step
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradientAlt,
            ),
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  // AutovalidateMode can be useful for instant feedback
                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: _buildCurrentStepWidgets(), // Use helper to build step UI
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Builds the UI widgets for the current onboarding step
  Widget _buildCurrentStepWidgets() {
    switch (_currentStep) {
      case OnboardingStep.emailInput:
        // Use Consumer for loading/error state from VerificationProvider
        return Consumer<VerificationProvider>(
           builder: (context, verificationProvider, _) => _buildEmailInputUI(verificationProvider)
        );
      case OnboardingStep.codeInput:
         // Use Consumer for loading/error state from VerificationProvider
        return Consumer<VerificationProvider>(
           builder: (context, verificationProvider, _) => _buildCodeInputUI(verificationProvider)
        );
      case OnboardingStep.profileInput:
         // Use Consumer for loading/error state from ProfileProvider
         // Also need VerificationProvider to get the email
         return Consumer2<ProfileProvider, VerificationProvider>(
           builder: (context, profileProvider, verificationProvider, _) => _buildProfileInputUI(profileProvider, verificationProvider)
         );
    }
  }

  // --- UI Widget Builders for Each Step ---

  // UI for Email Input Step
  Widget _buildEmailInputUI(VerificationProvider verificationProvider) {
      return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.connect_without_contact, size: 80, color: AppTheme.fontBlue.withOpacity(0.7)),
        const SizedBox(height: 30),
        const Text( 'Enter Your Email', style: AppTheme.headlineStyle, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        const Text( 'We\'ll send a verification code to get started.', style: AppTheme.bodyStyle, textAlign: TextAlign.center),
        const SizedBox(height: 30),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter your email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email address';
            return null;
          },
        ),
        const SizedBox(height: 20),
        if (verificationProvider.verificationError != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text( verificationProvider.verificationError!, style: AppTheme.errorStyle, textAlign: TextAlign.center),
          ),
        ],
        ElevatedButton(
          onPressed: verificationProvider.isSendingCode ? null : _sendCode,
          child: verificationProvider.isSendingCode
              ? const SizedBox( height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Send Code'),
        ),
      ],
    );
  }

  // UI for Code Input Step
  Widget _buildCodeInputUI(VerificationProvider verificationProvider) {
      return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
         const Text( 'Enter Verification Code', style: AppTheme.headlineStyle, textAlign: TextAlign.center),
         const SizedBox(height: 10),
         Text( 'Sent to ${verificationProvider.email ?? 'your email'}.', style: AppTheme.bodyStyle, textAlign: TextAlign.center),
        const SizedBox(height: 30),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(letterSpacing: 8.0, fontSize: 18),
          decoration: const InputDecoration( labelText: 'Verification Code', counterText: ""),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter the verification code';
            if (value.length < 6) return 'Code must be 6 digits';
            if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) return 'Code must contain only digits';
            return null;
          },
        ),
        const SizedBox(height: 20),
        if (verificationProvider.verificationError != null) ...[
           Padding(
             padding: const EdgeInsets.only(bottom: 10.0),
             child: Text( verificationProvider.verificationError!, style: AppTheme.errorStyle, textAlign: TextAlign.center),
           ),
        ],
        ElevatedButton(
          onPressed: verificationProvider.isVerifyingCode ? null : _verifyCode,
          child: verificationProvider.isVerifyingCode
              ? const SizedBox( height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Verify Code'),
        ),
         const SizedBox(height: 15),
         TextButton(
           onPressed: verificationProvider.isSendingCode ? null : _sendCode, // Resend uses same email
           child: verificationProvider.isSendingCode ? const Text("Resending...") : const Text('Resend Code'),
         ),
         // Use AppBar back button instead of "Change Email" here
      ],
    );
  }

  // UI for Profile Input Step
  Widget _buildProfileInputUI(ProfileProvider profileProvider, VerificationProvider verificationProvider) {
    final email = verificationProvider.email; // Get confirmed email

      return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
         const Text( 'Complete Your Profile', style: AppTheme.headlineStyle, textAlign: TextAlign.center),
        const SizedBox(height: 30),

        TextFormField( controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name'), textCapitalization: TextCapitalization.words, validator: (v) => v!.isEmpty ? 'Enter first name' : null),
        const SizedBox(height: 15),
        TextFormField( controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name'), textCapitalization: TextCapitalization.words, validator: (v) => v!.isEmpty ? 'Enter last name' : null),
        const SizedBox(height: 15),
        TextFormField( controller: _phoneNumberController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number'), validator: (v) { if (v!.isEmpty) return 'Enter phone number'; if (!RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(v)) return 'Enter a valid phone number'; return null;}),
        const SizedBox(height: 15),
        TextFormField( initialValue: email ?? 'Error: Email not found', enabled: false, decoration: const InputDecoration( labelText: 'Email', fillColor: Colors.black12, filled: true)),
        const SizedBox(height: 15),

        // *** ADDED: Password Field ***
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.fontBlue.withOpacity(0.7)),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter a password';
            if (value.length < 6) return 'Password must be at least 6 characters'; // Example length validation
            return null;
          },
        ),
        const SizedBox(height: 15),

        // *** ADDED: Confirm Password Field ***
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
             suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.fontBlue.withOpacity(0.7)),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please confirm your password';
            if (value != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 15),

        DropdownButtonFormField<String>( value: _selectedGender, onChanged: (v) => setState(() => _selectedGender = v), items: _genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), decoration: const InputDecoration(labelText: 'Gender'), validator: (v) => v == null ? 'Select gender' : null),
        const SizedBox(height: 15),
        TextFormField( controller: _dateOfBirthController, readOnly: true, onTap: () => _selectDate(context), decoration: const InputDecoration( labelText: 'Date of Birth', suffixIcon: Icon(Icons.calendar_today, color: AppTheme.fontBlue)), validator: (v) => v!.isEmpty ? 'Select date of birth' : null),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>( value: _selectedPurpose, onChanged: (v) => setState(() => _selectedPurpose = v), items: _purposeOptions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(), decoration: const InputDecoration(labelText: 'Purpose of the App'), validator: (v) => v == null ? 'Select purpose' : null),
        const SizedBox(height: 20),

        Text('Upload Introduction Video (max 20s)', style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        OutlinedButton.icon( icon: const Icon(Icons.video_library), label: Text(_videoFile == null ? 'Select Video' : 'Change Video'), onPressed: _pickVideo, style: OutlinedButton.styleFrom( foregroundColor: AppTheme.fontBlue, side: const BorderSide(color: AppTheme.strokeBlue), padding: const EdgeInsets.symmetric(vertical: 12))),
        if (_isCheckingVideo) ...[
           const SizedBox(height: 10),
           const Row( mainAxisAlignment: MainAxisAlignment.center, children: [ SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 10), Text('Checking video duration...', style: AppTheme.bodyStyle)])]
        else if (_videoFile != null) ...[
          const SizedBox(height: 10),
          Row( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon( _isVideoValid ? Icons.check_circle : Icons.error, color: _isVideoValid ? Colors.green : Colors.red, size: 20), const SizedBox(width: 8), Expanded( child: Text( _isVideoValid ? 'Video OK (${_videoPlayerController?.value.duration.inSeconds ?? 0}s)' : 'Video invalid (max 20s)', style: AppTheme.bodyStyle.copyWith( color: _isVideoValid ? Colors.green : Colors.red), overflow: TextOverflow.ellipsis))])],
        const SizedBox(height: 30),

        if (profileProvider.submissionError != null) ...[
          Padding( padding: const EdgeInsets.only(bottom: 10.0), child: Text( profileProvider.submissionError!, style: AppTheme.errorStyle, textAlign: TextAlign.center))],

        ElevatedButton(
          onPressed: profileProvider.isSubmitting ? null : _submitProfile,
          child: profileProvider.isSubmitting
              ? const SizedBox( height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Submit Profile'),
        ),
        if (profileProvider.isUploadingVideo) ...[
          const SizedBox(height: 15),
          const Row( mainAxisAlignment: MainAxisAlignment.center, children: [ SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 10), Text('Uploading video...', style: AppTheme.bodyStyle)])]
      ],
    );
  }
}

