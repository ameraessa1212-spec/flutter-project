import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:Waslaa/features/auth/models/specialization.dart';
import 'package:Waslaa/features/auth/repositories/auth_repository.dart';
import 'otp_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  List<Specialization> _specializations = [];
  int? _selectedSpecializationId;
  bool _isLoading = false;
  bool _isLoadingSpecializations = false;

  @override
  void initState() {
    super.initState();
    _loadSpecializations();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentNumberController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _loadSpecializations() async {
    setState(() => _isLoadingSpecializations = true);
    try {
      final repo = context.read<AuthRepository>();
      final specs = await repo.getSpecializations();
      if (mounted) {
        setState(() => _specializations = specs);
      }
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر تحميل التخصصات. يمكنك المتابعة بدون اختيار تخصص.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingSpecializations = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = context.read<AuthRepository>();
      await repo.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
        studentNumber: _studentNumberController.text.trim(),
        specializationId: _selectedSpecializationId,
      );

      if (!mounted) return;

      // الانتقال لشاشة التحقق من OTP بعد التسجيل
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => OtpScreen(
                identifier: _emailController.text.trim(),
                flow: OtpFlow.registration,
              ),
        ),
      );
    } on DioException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'حدث خطأ أثناء التسجيل. يرجى المحاولة مرة أخرى.',
            textAlign: TextAlign.center,
          ),
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
              const SizedBox(height: 20),
              const Text(
                'إنشاء حساب جديد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A5AE0),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'سجّل وانطلق نحو مستقبلك المهني',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),

              // الاسم الأول
              _buildTextField(
                controller: _firstNameController,
                hint: 'الاسم الأول',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'يرجى إدخال الاسم الأول';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // اسم العائلة
              _buildTextField(
                controller: _lastNameController,
                hint: 'اسم العائلة',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'يرجى إدخال اسم العائلة';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // اسم المستخدم
              _buildTextField(
                controller: _usernameController,
                hint: 'اسم المستخدم',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'يرجى إدخال اسم المستخدم';
                  if (v.trim().length < 3) return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // البريد الإلكتروني
              _buildTextField(
                controller: _emailController,
                hint: 'البريد الإلكتروني',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'يرجى إدخال البريد الإلكتروني';
                  if (!v.contains('@')) return 'يرجى إدخال بريد إلكتروني صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // رقم الهاتف
              _buildTextField(
                controller: _phoneController,
                hint: 'رقم الهاتف',
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'يرجى إدخال رقم الهاتف';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // الرقم الجامعي / رقم القيد (إلزامي)
              _buildTextField(
                controller: _studentNumberController,
                hint: 'الرقم الجامعي / رقم القيد',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'يرجى إدخال رقم القيد للتحقق';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // التخصص
              _buildSpecializationDropdown(),
              const SizedBox(height: 14),

              // كلمة المرور
              _buildTextField(
                controller: _passwordController,
                hint: 'كلمة المرور',
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'يرجى إدخال كلمة المرور';
                  if (v.length < 6) return 'كلمة المرور يجب أن لا تقل عن 6 أحرف';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // تأكيد كلمة المرور
              _buildTextField(
                controller: _passwordConfirmController,
                hint: 'تأكيد كلمة المرور',
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'يرجى تأكيد كلمة المرور';
                  if (v != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // زر التسجيل
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A5AE0),
                    elevation: 5,
                    shadowColor: const Color(0xFF6A5AE0).withOpacity(0.4),
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
                            'إنشاء الحساب',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecializationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F0F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          _isLoadingSpecializations
              ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'جارٍ تحميل التخصصات...',
                      style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                    ),
                  ],
                ),
              )
              : DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text(
                    'التخصص (اختياري)',
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 14),
                  ),
                  value: _selectedSpecializationId,
                  items: _specializations
                      .map(
                        (s) => DropdownMenuItem<int>(
                          value: s.id,
                          child: Text(
                            s.name,
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSpecializationId = val),
                ),
              ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword,
      keyboardType: keyboardType,
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
          borderSide: const BorderSide(color: Color(0xFF6A5AE0), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}
