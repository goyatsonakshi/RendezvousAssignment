        import 'package:flutter/material.dart';
        import 'package:provider/provider.dart';
        import 'package:image_picker/image_picker.dart';
        import 'package:intl/intl.dart';
        import '../providers/profile_provider.dart';
        import '../../../shared/widgets/custom_dialog.dart';

        class ProfileFormScreen extends StatefulWidget {
          const ProfileFormScreen({super.key});

          @override
          _ProfileFormScreenState createState() => _ProfileFormScreenState();
        }

        class _ProfileFormScreenState extends State<ProfileFormScreen> {
          final _formKey = GlobalKey<FormState>();
          final _firstNameController = TextEditingController();
          final _lastNameController = TextEditingController();
          final _phoneNumberController = TextEditingController();
          final _genderController =
              TextEditingController(); // Use a controller for the dropdown
          final _dateOfBirthController = TextEditingController();
          final _purposeController =
              TextEditingController(); // Use a controller for the dropdown
          File? _videoFile;

          // Gender options
          final List<String> _genderOptions = ['Male', 'Female', 'Other'];
          // Purpose options
          final List<String> _purposeOptions = ['Spark', 'Linkup'];

          @override
          void dispose() {
            _firstNameController.dispose();
            _lastNameController.dispose();
            _phoneNumberController.dispose();
            _genderController.dispose();
            _dateOfBirthController.dispose();
            _purposeController.dispose();
            super.dispose();
          }

          // Function to select video
          Future<void> _pickVideo() async {
            final picker = ImagePicker();
            final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

            if (pickedFile != null) {
              setState(() {
                _videoFile = File(pickedFile.path);
              });
            }
          }

          // Function to show date picker
          Future<void> _selectDate(BuildContext context) async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _dateOfBirthController.text =
                    DateFormat('yyyy-MM-dd').format(picked);
              });
            }
          }

          @override
          Widget build(BuildContext context) {
            final profileProvider = Provider.of<ProfileProvider>(context);
            final appState = Provider.of<AppState>(context); //for the email
            return Scaffold(
              appBar: AppBar(title: const Text('Profile Form')),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // First Name
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Last Name
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Phone Number
                        TextFormField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            // Basic phone number validation (10 digits, can start with +)
                            if (!RegExp(r'^[+0-9]{10,}$').hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Email (Pre-filled and Disabled)
                        TextFormField(
                          initialValue: appState.email,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Gender Dropdown
                        DropdownButtonFormField<String>(
                          value: _genderController.text.isEmpty
                              ? null
                              : _genderController.text,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              _genderController.text =
                                  newValue; // Update the controller's value
                            }
                          },
                          items: _genderOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your gender';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Date of Birth
                        TextFormField(
                          controller: _dateOfBirthController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your date of birth';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Purpose Dropdown
                        DropdownButtonFormField<String>(
                          value: _purposeController.text.isEmpty
                              ? null
                              : _purposeController.text,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              _purposeController.text =
                                  newValue; //update controller
                            }
                          },
                          items: _purposeOptions
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Purpose of the App',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select the purpose of the app';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Video Upload
                        ElevatedButton(
                          onPressed: _pickVideo,
                          child: const Text('Upload Video (20 seconds)'),
                        ),
                        if (_videoFile != null) ...[
                          const SizedBox(height: 10),
                          Text('Selected Video: ${_videoFile!.path}'),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: profileProvider.isSubmitting
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      profileProvider.clearErrors();
                                      await profileProvider.submitProfile(
                                        userId: appState.user!.id, // Access user id from appState
                                        firstName:
                                            _firstNameController.text.trim(),
                                        lastName:
                                            _lastNameController.text.trim(),
                                        phoneNumber:
                                            _phoneNumberController.text.trim(),
                                        gender: _genderController.text.trim(),
                                        dateOfBirth:
                                            _dateOfBirthController.text.trim(),
                                        purpose: _purposeController.text.trim(),
                                        videoFile: _videoFile,
                                      );
                                    } catch (e) {
                                      showCustomDialog(
                                          context,
                                          'Error',
                                          profileProvider.submissionError ??
                                              'An error occurred.');
                                    }
                                  }
                                },
                          child: profileProvider.isSubmitting
                              ? const CircularProgressIndicator()
                              : const Text('Submit Profile'),
                        ),
                        if (profileProvider.submissionError != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            profileProvider.submissionError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }

        