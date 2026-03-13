import 'package:flutter/material.dart';
// 1. تأكد من إزالة التعليق عن السطر التالي (يجب أن يكون الملف موجوداً بنفس الاسم)
import 'welcome_screen.dart';

class Intro2 extends StatelessWidget {
  const Intro2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'assets/images/intro2.png',
                height: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              const Text(
                'تدريبك أصبح أسهل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A47D1),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'قدّم طلبات التدريب،\nوتواصل مع الكلية والشركات من مكان واحد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: Color(0xFF9BA4B1),
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // مؤشر النقاط
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC4C4C4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 2. تعديل زر التالي ليفعل الانتقال
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // أمر الانتقال إلى الصفحة التالية
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF635BFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'التالي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
