import 'package:flutter/material.dart';
import 'home_page.dart'; 

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6A5AE0), size: 18), // تغيير الأيقونة لتناسب النمط
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  'assets/images/Message_alt_fill.png', 
                  height: 100, // تصغير الصورة قليلاً
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'أدخل رمز التحقق',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15, // حجم خط عنوان الصفحة الموحد
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A5AE0),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey), // تصغير النص الفرعي
              ),
              const Text(
                'student@email.com',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 35),
              
              // حقول الرمز (تم تصغير المربعات)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _otpBox(context),
                  _otpBox(context),
                  _otpBox(context),
                  _otpBox(context),
                ],
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: 160, // توحيد عرض الزر مع باقي الصفحات
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()), 
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A5AE0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text(
                    'تأكيد الرمز',
                    style: TextStyle(
                      fontFamily: 'Cairo', 
                      fontSize: 12, // حجم خط الزر الموحد
                      color: Colors.white, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'لم يصلك الرمز؟ إعادة الإرسال',
                  style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF6A5AE0), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(BuildContext context) {
    return Container(
      width: 50, // تصغير عرض المربع
      height: 55, // تصغير ارتفاع المربع
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6A5AE0).withOpacity(0.3), width: 1),
      ),
      child: TextField(
        onChanged: (value) {
          if (value.length == 1) FocusScope.of(context).nextFocus();
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A5AE0)),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
      ),
    );
  }
}