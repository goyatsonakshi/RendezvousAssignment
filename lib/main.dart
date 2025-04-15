import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import 'app.dart'; // Your main App widget structure
import 'app_state.dart'; // Central app state management
import 'theme.dart'; // App branding and theme

// Import Providers
import 'features/verification/presentation/providers/verification_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/approval/presentation/providers/approval_provider.dart';

// Import Use Cases
import 'features/verification/domain/usecases/send_verification_code.dart';
import 'features/verification/domain/usecases/verify_code.dart';
import 'features/profile/domain/usecases/submit_profile.dart';
import 'features/approval/domain/usecases/check_admin_approval.dart';

// Import Repositories
import 'features/verification/domain/repositories/verification_repository.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/approval/domain/repositories/approval_repository.dart';
import 'features/verification/data/repositories/verification_repository_impl.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/approval/data/repositories/approval_repository_impl.dart';

// Import Data Sources
import 'features/verification/data/datasources/verification_remote_data_source.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/approval/data/datasources/approval_remote_data_source.dart';

// Import Core components
import 'core/network/network_info.dart';
// import 'core/utils/input_converter.dart'; // If needed globally

// --- UPDATED API Base URL ---
// TODO: Verify if trailing slash is needed based on backend/Postman (e.g., "http://15.207.23.3/api/")
const String API_BASE_URL = "http://15.207.23.3/api";

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Create instances of dependencies
  final httpClient = http.Client();
  final connectivity = Connectivity();
  final networkInfo = NetworkInfoImpl(connectivity);

  // Data Sources
  final verificationRemoteDataSource = VerificationRemoteDataSourceImpl(
      client: httpClient, baseUrl: API_BASE_URL);
  final profileRemoteDataSource =
      ProfileRemoteDataSourceImpl(client: httpClient, baseUrl: API_BASE_URL);
  final approvalRemoteDataSource =
      ApprovalRemoteDataSourceImpl(client: httpClient, baseUrl: API_BASE_URL);

  // Repositories
  final verificationRepository = VerificationRepositoryImpl(
      remoteDataSource: verificationRemoteDataSource); // Removed networkInfo dependency here, handle in datasource or repo if needed
  final profileRepository =
      ProfileRepositoryImpl(remoteDataSource: profileRemoteDataSource);
  final approvalRepository =
      ApprovalRepositoryImpl(remoteDataSource: approvalRemoteDataSource);

  // Use Cases
  final sendVerificationCodeUseCase =
      SendVerificationCode(repository: verificationRepository);
  final verifyCodeUseCase = VerifyCode(repository: verificationRepository);
  final submitProfileUseCase = SubmitProfile(repository: profileRepository);
  final checkAdminApprovalUseCase =
      CheckAdminApproval(repository: approvalRepository);

  runApp(
    MultiProvider(
      providers: [
        // App State - Central state management
        ChangeNotifierProvider(create: (_) => AppState()),

        // Feature Providers - Depend on Use Cases
        ChangeNotifierProvider(
          create: (_) => VerificationProvider(
            sendVerificationCodeUseCase: sendVerificationCodeUseCase,
            verifyCodeUseCase: verifyCodeUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            submitProfileUseCase: submitProfileUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ApprovalProvider(
            checkAdminApprovalUseCase: checkAdminApprovalUseCase,
          ),
        ),

        // Provide other dependencies if needed globally (e.g., NetworkInfo)
        Provider<NetworkInfo>.value(value: networkInfo),
      ],
      child: const MyApp(), // Your main application widget
    ),
  );
}
