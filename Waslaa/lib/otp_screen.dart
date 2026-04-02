import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/auth/repositories/auth_repository.dart';
import 'sign_in.dart';
import 'reset_password.dart';

/// يحدد نوع تدفق OTP: تسجيل جديد أم استرجاع كلمة المرور
enum OtpFlow { registration, passwordReset }

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.identifier, required this.flow});

  /// البريد الإلكتروني أو رقم الهاتف المستخدم في عملية التحقق
  final String identifier;

  /// نوع التدفق (تسجيل أو استرجاع كلمة المرور)
  final OtpFlow flow;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) {
          _resendCooldown = 0;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendOtp() async {
    try {
      final repo = context.read<AuthRepository>();
      if (widget.flow == OtpFlow.passwordReset) {
        await repo.forgotPassword(identifier: widget.identifier);
      } else {
        // For registration flow, re-trigger the OTP send
        await repo.forgotPassword(identifier: widget.identifier);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إعادة إرسال رمز التحقق بنجاح', textAlign: TextAlign.center),
          backgroundColor: Colors.green,
        ),
      );
      _startResendTimer();
    } on DioException catch (error) {
      if (!mounted) return;
      String errorMsg = 'حدث خطأ أثناء إعادة الإرسال.';
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
    }
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _submit() async {
    final otp = _otp;
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال رمز التحقق كاملاً (6 أرقام)',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = context.read<AuthRepository>();

      if (widget.flow == OtpFlow.registration) {
        await repo.verifyRegistrationOtp(
          identifier: widget.identifier,
          otp: otp,
        );
        if (!mounted) return;
        // بعد التحقق من التسجيل، انتقل لصفحة تسجيل الدخول
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم التحقق بنجاح! يمكنك الآن تسجيل الدخول.',
              textAlign: TextAlign.center,
            ),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
          (route) => false,
        );
      } else {
        // OTP لاسترجاع كلمة المرور
        await repo.verifyResetOtp(identifier: widget.identifier, otp: otp);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    ResetPasswordPage(identifier: widget.identifier, otp: otp),
          ),
        );
      }
    } on DioException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ??
                'حدث خطأ. يرجى التحقق من الرمز والمحاولة مرة أخرى.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onOtpDigitChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isRegistration = widget.flow == OtpFlow.registration;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Text(
              isRegistration ? 'التحقق من الحساب' : 'التحقق من الهوية',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primarycolor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تم إرسال رمز التحقق إلى\n${widget.identifier}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),

            // حقول OTP
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 46,
                    height: 55,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) => _onOtpDigitChanged(value, index),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primarycolor,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF1F0F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: primarycolor,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 40),

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
                          'تحقق',
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
              onPressed: _resendCooldown > 0 ? null : _resendOtp,
              child: Text(
                _resendCooldown > 0
                    ? 'إعادة الإرسال بعد $_resendCooldown ثانية'
                    : 'إعادة إرسال الرمز',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: _resendCooldown > 0 ? Colors.grey : primarycolor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
