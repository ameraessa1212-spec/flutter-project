import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Waslaa/const/app_dimensions.dart';
import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/core/config/app_config.dart';
import 'package:Waslaa/core/session/app_session_controller.dart';
import 'package:Waslaa/core/session/session_storage.dart';
import 'package:Waslaa/features/applications/repositories/application_repository.dart';
import 'package:Waslaa/features/auth/repositories/auth_repository.dart';
import 'package:Waslaa/features/chat/repositories/chat_repository.dart';
import 'package:Waslaa/features/content/repositories/content_repository.dart';
import 'package:Waslaa/features/dashboard/repositories/dashboard_repository.dart';
import 'package:Waslaa/features/discussion_schedules/repositories/discussion_schedule_repository.dart';
import 'package:Waslaa/features/internships/repositories/internship_repository.dart';
import 'package:Waslaa/features/notifications/repositories/notification_repository.dart';
import 'package:Waslaa/features/opportunities/repositories/opportunity_repository.dart';
import 'package:Waslaa/features/profile/repositories/profile_repository.dart';
import 'package:Waslaa/features/reports/repositories/report_repository.dart';
import 'package:Waslaa/features/settings/repositories/settings_repository.dart';
import 'package:Waslaa/splach_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();
  final firebaseEnabled = await FirebaseConfig.initialize();
  if (!firebaseEnabled) {
    debugPrint(
      'Firebase is not configured. The app will start without Firebase-dependent services.',
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    AppDimensions.initialize(context);
    return MultiProvider(
      providers: [
        Provider(create: (_) => SessionStorage()),
        Provider(
          create:
              (context) =>
                  ApiClient(sessionStorage: context.read<SessionStorage>()),
        ),
        Provider(
          create:
              (context) => AuthRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create:
              (context) =>
                  OpportunityRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create:
              (context) =>
                  ApplicationRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create:
              (context) =>
                  InternshipRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create:
              (context) =>
                  ReportRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create:
              (context) => ChatRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create:
              (context) =>
                  NotificationRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create:
              (context) =>
                  ProfileRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create:
              (context) =>
                  SettingsRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create:
              (context) =>
                  DashboardRepository(apiClient: context.read<ApiClient>()),
        ),
        Provider(
          create:
              (context) => DiscussionScheduleRepository(
                apiClient: context.read<ApiClient>(),
              ),
        ),
        Provider(
          create:
              (context) =>
                  ContentRepository(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create:
              (context) => AppSessionController(
                sessionStorage: context.read<SessionStorage>(),
                authRepository: context.read<AuthRepository>(),
                profileRepository: context.read<ProfileRepository>(),
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Waslaa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Cairo'),
        home: const SplachScreen(),
      ),
    );
  }
}
