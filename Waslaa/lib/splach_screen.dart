import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Waslaa/core/session/app_session_controller.dart';
import 'package:Waslaa/home_page.dart';
import 'package:Waslaa/welcome_screen.dart';
import 'Intro1.dart';

class SplachScreen extends StatefulWidget {
  const SplachScreen({super.key});

  @override
  State<SplachScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplachScreen> {
  double _opacity = 0;
  double _scale = 0.5;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // بدء تأثير الظهور (Animation)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapApp();
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrapApp() async {
    final session = context.read<AppSessionController>();
    final destination = await session.bootstrap();

    if (!mounted) {
      return;
    }

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }

      final page = switch (destination) {
        AppLaunchDestination.home => const HomePage(),
        AppLaunchDestination.welcome => const WelcomeScreen(),
        AppLaunchDestination.onboarding => const Intro1(),
      };

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => page),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A5AE0),
      body: Center(
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(seconds: 2),
          curve: Curves.elasticOut,
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 2),
            child: Image.asset('assets/images/Vector.png', width: 200),
          ),
        ),
      ),
    );
  }
}
