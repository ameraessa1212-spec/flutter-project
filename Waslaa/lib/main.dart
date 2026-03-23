import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Waslaa/const/app_dimensions.dart';
import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/core/session/app_session_controller.dart';
import 'package:Waslaa/core/session/session_storage.dart';
import 'package:Waslaa/features/auth/repositories/auth_repository.dart';
import 'package:Waslaa/splach_screen.dart';

void main() {
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
              (context) => ApiClient(
                sessionStorage: context.read<SessionStorage>(),
              ),
        ),
        Provider(
          create:
              (context) => AuthRepository(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider(
          create:
              (context) => AppSessionController(
                sessionStorage: context.read<SessionStorage>(),
                authRepository: context.read<AuthRepository>(),
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
