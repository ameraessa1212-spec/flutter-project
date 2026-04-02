import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/auth/repositories/auth_repository.dart';
import 'otp_screen.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = context.read<AuthRepository>();
      await repo.forgotPassword(identifier: _identifierController.text.trim());

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => OtpScreen(
                identifier: _identifierController.text.trim(),
                flow: OtpFlow.passwordReset,
              ),
        ),
      );
    } on DioException catch (error) {
      if (!mounted) return;
      String errorMsg = 'حدث خطأ. يرجى المحاولة مرة أخرى.';
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        errorMsg = responseData['message'] as String? ?? errorMsg;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg, textAlign: TextAlign.center),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primarycolor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock_outline_rounded, size: 40, color: primarycolor),
              ),
              const SizedBox(height: 20),
              Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primarycolor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'أدخل بريدك الإلكتروني أو رقم هاتفك\nوسنرسل لك رمز التحقق',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 50),

              TextFormField(
                controller: _identifierController,
                textDirection: TextDirection.rtl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني أو رقم الهاتف';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'البريد الإلكتروني أو رقم الهاتف',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF1F0F9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  errorStyle: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: primarycolor,
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primarycolor,
                    elevation: 5,
                    shadowColor: primarycolor.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'إرسال رمز التحقق',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'العودة لتسجيل الدخول',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: primarycolor,
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
