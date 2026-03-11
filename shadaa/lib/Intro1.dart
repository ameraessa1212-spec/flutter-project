import 'package:flutter/material.dart';
import 'Intro2.dart';
import 'welcome_screen.dart'; // استيراد شاشة الترحيب لتفعيل زر التخطي

class Intro1 extends StatelessWidget {
  const Intro1({super.key});

  @override
  Widget build(BuildContext context) {
    // الحصول على أبعاد الشاشة لجعل التصميم متجاوباً
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // الصورة العلوية مع تحسين العرض
              Hero(
                tag:
                    'intro_image', // لإضافة تأثير انتقال سلس إذا استخدمت الصور في الصفحات التالية
                child: Image.asset(
                  'assets/images/intro1.png',
                  height: size.height * 0.35,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              // النص الترحيبي الكبير
              const Text(
                'مرحباً بك!\nفي وصلة التدريب',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A47D1),
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 20),

              // النص الوصفي الصغير
              const Text(
                'منصة رقمية ذكية تربط بين الطالب، الكلية، والشركات\nلتسهيل التدريب الميداني\nبشكل حديث ومنظم.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: Color(0xFF9BA4B1),
                  height: 1.6,
                ),
              ),

              const Spacer(),

              // مؤشر النقاط (Dots) - تم تحسينه ليكون الأول بشكل مميز
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 20, // عرض أكبر للنقطة النشطة
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF635BFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1D5DB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // الأزرار السفلية
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر تخطي - الآن يوجه إلى WelcomeScreen مباشرة
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F2FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'تخطي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Color(0xFF4A47D1),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // زر التالي
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Intro2()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF635BFF),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 45,
                        vertical: 12,
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
