import 'package:flutter/material.dart';
import 'verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  // 1. إضافة مفتاح النموذج (Form Key)
  final _formKey = GlobalKey<FormState>();

  bool _isArabic(String text) {
    if (text.isEmpty) return true;
    return RegExp(r'^[\u0600-\u06FF]').hasMatch(text);
  }

  // 2. دالة التحقق من صحة البريد الإلكتروني
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    // RegExp للتحقق من صيغة الإيميل
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
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
        // 3. تغليف العناصر بـ Form واستخدام المفتاح
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
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

              // 4. تغيير TextField إلى TextFormField
              TextFormField(
                controller: _emailController,
                validator: _validateEmail, // ربط دالة الفالديشن
                keyboardType: TextInputType.emailAddress,
                textDirection:
                    _isArabic(_emailController.text)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'ادخل البريد الالكتروني',
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
                  // تحسين شكل الخطأ
                  errorStyle: const TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.red, width: 0.5),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // 5. التحقق من صحة الفورم قبل الانتقال
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VerificationPage(),
                        ),
                      );
                    }
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
      ),
    );
  }
}
