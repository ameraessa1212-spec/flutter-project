import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/auth/repositories/auth_repository.dart';
import 'sign_in.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    required this.identifier,
    required this.otp,
  });

  final String identifier;
  final String otp;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = context.read<AuthRepository>();
      await repo.resetPassword(
        identifier: widget.identifier,
        otp: widget.otp,
        password: _passwordController.text,
        passwordConfirmation: _confirmController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تغيير كلمة المرور بنجاح! يمكنك الآن تسجيل الدخول.',
            textAlign: TextAlign.center,
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (route) => false,
      );
    } on DioException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'حدث خطأ أثناء تغيير كلمة المرور.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    required bool obscure,
    required VoidCallback onToggleObscure,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hint,
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
        errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggleObscure,
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
          borderSide: BorderSide(color: primarycolor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
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
              Text(
                'تعيين كلمة مرور جديدة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primarycolor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 50),

              _buildPasswordField(
                controller: _passwordController,
                hint: 'كلمة المرور الجديدة',
                obscure: _obscurePassword,
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'يرجى إدخال كلمة المرور';
                  if (v.length < 8)
                    return 'كلمة المرور يجب أن لا تقل عن 8 أحرف';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildPasswordField(
                controller: _confirmController,
                hint: 'تأكيد كلمة المرور',
                obscure: _obscureConfirm,
                onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'يرجى تأكيد كلمة المرور';
                  if (v != _passwordController.text)
                    return 'كلمتا المرور غير متطابقتين';
                  return null;
                },
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
                            'حفظ كلمة المرور',
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
