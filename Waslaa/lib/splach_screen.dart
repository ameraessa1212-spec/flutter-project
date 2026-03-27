import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Waslaa/core/session/app_session_controller.dart';
import 'package:Waslaa/core/services/fcm_service.dart';
import 'package:Waslaa/core/services/pusher_service.dart';
import 'package:Waslaa/core/api/api_client.dart';
import 'package:Waslaa/home_page.dart';
import 'package:Waslaa/welcome_screen.dart';
import 'package:Waslaa/dev_tool_screen.dart';
import 'Intro1.dart';

class SplachScreen extends StatefulWidget {
  const SplachScreen({super.key});

  @override
  State<SplachScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplachScreen> {
  static const _minimumSplashDuration = Duration(seconds: 3);

  double _opacity = 0;
  double _scale = 0.5;
  AppLaunchDestination? _pendingDestination;
  int _logoTaps = 0;
  Timer? _tapTimer;

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
    _tapTimer?.cancel();
    super.dispose();
  }

  void _handleLogoTap() {
    _logoTaps++;
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(seconds: 1), () {
      _logoTaps = 0;
    });

    if (_logoTaps >= 5) {
      _logoTaps = 0;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const DevToolScreen()));
    }
  }

  Future<void> _bootstrapApp() async {
    final session = context.read<AppSessionController>();
    setState(() {
      _pendingDestination = null;
    });

    final minimumDelay = Future<void>.delayed(_minimumSplashDuration);
    final destination = await session.retryBootstrap();

    await minimumDelay;

    if (!mounted) {
      return;
    }

    if (destination == AppLaunchDestination.error) {
      setState(() {
        _pendingDestination = destination;
      });
      return;
    }

    final page = switch (destination) {
      AppLaunchDestination.home => const HomePage(),
      AppLaunchDestination.welcome => const WelcomeScreen(),
      AppLaunchDestination.onboarding => const Intro1(),
      AppLaunchDestination.error => null,
      _ => null,
    };

    if (destination == AppLaunchDestination.home) {
      try {
        await FCMService().init(context.read<ApiClient>());
        await PusherService().initPusher();
      } catch (e) {
        debugPrint('Services Init error: $e');
      }
    }

    if (page == null) {
      return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSessionController>();

    return Scaffold(
      backgroundColor: const Color(0xFF6A5AE0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: _scale,
                duration: const Duration(seconds: 2),
                curve: Curves.elasticOut,
                child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 2),
                  child: GestureDetector(
                    onTap: _handleLogoTap,
                    child: Image.asset('assets/images/Vector.png', width: 200),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (session.isBootstrapping) ...[
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'جارٍ تهيئة التطبيق...',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ] else if (_pendingDestination == AppLaunchDestination.error) ...[
                Text(
                  session.errorMessage ?? 'تعذر الاتصال بالخادم حالياً.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _bootstrapApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6A5AE0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
