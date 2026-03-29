import 'package:flutter/material.dart';
import 'package:Waslaa/const/color.dart';
import 'sign_in.dart'; // للانتقال لصفحة تسجيل الدخول
import 'sign_up.dart'; // للانتقال لصفحة إنشاء حساب

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // عرض الصورة المطلوبة Group.png
              Image.asset(
                'assets/images/Group.png',
                height: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              // العنوان بخط Cairo كما في التصميم
              Text(
                'انطلق نحو مستقبلك مع\nوصلة تدريب .. جسرك للنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 24, // مقاس متناسق مع طول الجملة
                  fontWeight: FontWeight.bold,
                  color: primarycolor,
                  height: 1.4, // مساحة إضافية لجمالية الخط العربي
                ),
              ),
              const Spacer(flex: 2),
              // صف الأزرار (تسجيل و سجل الآن)
              Row(
                children: [
                  // زر تسجيل (يفتح صفحة تسجيل الدخول)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primarycolor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'تسجيل',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // زر سجل الآن (يفتح صفحة إنشاء حساب)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD1D1D1)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'سجل الآن',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          color: primarycolor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
