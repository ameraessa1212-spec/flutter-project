import 'package:flutter/material.dart';
import 'verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // وحدة التحكم لمراقبة البريد الإلكتروني وتغيير الاتجاه
  final TextEditingController _emailController = TextEditingController();

  // دالة فحص اللغة (ترجع true للعربي أو النص الفارغ)
  bool _isArabic(String text) {
    if (text.isEmpty) return true;
    return RegExp(r'^[\u0600-\u06FF]').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // عرض الصورة التوضيحية
            Image.asset('assets/images/Picture.png', height: 250),
            const SizedBox(height: 30),
            const Text(
              'هل نسيت كلمة المرور؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A5AE0),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'لا تقلق! هذا يحدث. يرجى إدخال البريد الإلكتروني، وسنرسل رمز التحقق إليك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // حقل إدخال البريد الإلكتروني الذكي
            TextField(
              controller: _emailController,
              // يكتشف اللغة ويغير اتجاه الكتابة تلقائياً
              textDirection: _isArabic(_emailController.text)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              textAlign: TextAlign.start,
              onChanged: (value) {
                setState(() {}); // لتحديث الاتجاه فوراً عند كل حرف
              },
              decoration: InputDecoration(
                hintText: 'ادخل البريد الالكتروني',
                // يبقى اسم الحقل على اليمين دائماً
                hintTextDirection: TextDirection.rtl,
                hintStyle: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.grey,
                ),
                filled: true,
                fillColor: const Color(0xFFF1F0F9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // زر استمرار
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VerificationPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5AE0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'استمرار',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
