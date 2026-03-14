import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Waslla/const/color.dart';
import 'package:Waslla/home_page.dart';
import 'Intro1.dart';

class SplachScreen extends StatefulWidget {
  const SplachScreen({super.key});

  @override
  State<SplachScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplachScreen> {
  double _opacity = 0;
  double _scale = 0.5;

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

    // 2. التعديل الجوهري هنا: الانتقال إلى Intro1 بعد 4 ثوانٍ
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => const Intro1(), // تم التوجيه إلى الصفحة التعريفية الأولى
          ),
        );
      }
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
