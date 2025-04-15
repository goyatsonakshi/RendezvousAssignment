        import 'package:flutter/material.dart';
        import 'package:provider/provider.dart';
        import '../providers/verification_provider.dart';
        import '../../../shared/widgets/custom_dialog.dart';

        class VerificationScreen extends StatefulWidget {
          const VerificationScreen({super.key});

          @override
          _VerificationScreenState createState() => _VerificationScreenState();
        }

        class _VerificationScreenState extends State<VerificationScreen> {
          final _emailController = TextEditingController();
          final _codeController = TextEditingController();
          final _formKey = GlobalKey<FormState>();

          @override
          void dispose() {
            _emailController.dispose();
            _codeController.dispose();
            super.dispose();
          }

          @override
          Widget build(BuildContext context) {
            final verificationProvider = Provider.of<VerificationProvider>(context);
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (verificationProvider.email == null) ...[
                        // Email Input
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: verificationProvider.isVerifying
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      verificationProvider.clearErrors(); // Clear errors before
                                      await verificationProvider
                                          .sendVerificationCode(
                                              _emailController.text.trim());
                                    } catch (e) {
                                      // Error is already handled in the provider.
                                      showCustomDialog(
                                          context,
                                          'Error',
                                          verificationProvider.verificationError ??
                                              'An error occurred.');
                                    }
                                  }
                                },
                          child: verificationProvider.isVerifying
                              ? const CircularProgressIndicator()
                              : const Text('Send Code'),
                        ),
                      ] else ...[
                        // Verification Code Input
                        TextFormField(
                          controller: _codeController,
                          keyboardType: TextInputType.numberWithOptions(),
                          decoration: const InputDecoration(
                            labelText: 'Verification Code',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the verification code';
                            }
                            if (value.length < 6) {
                              return 'Verification code must be at least 6 digits'; // Example validation
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: verificationProvider.isVerifying
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      verificationProvider.clearErrors(); // Clear errors
                                      await verificationProvider.verifyCode(
                                          verificationProvider.email!,
                                          _codeController.text.trim());
                                    } catch (e) {
                                      showCustomDialog(
                                          context,
                                          'Error',
                                          verificationProvider.verificationError ??
                                              'An error occurred.');
                                    }
                                  }
                                },
                          child: verificationProvider.isVerifying
                              ? const CircularProgressIndicator()
                              : const Text('Verify Code'),
                        ),
                      ],
                      if (verificationProvider.verificationError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          verificationProvider.verificationError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }
        }

        