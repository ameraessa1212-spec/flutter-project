import 'package:flutter/material.dart';
import 'otp_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  String? selectedMajor;

  // دالة فحص اللغة: ترجع true إذا كان النص فارغاً أو عربياً
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'إنشاء حساب',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A5AE0),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'أنشئ حساباً لتتمكن من استعراض الوظائف',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),

              _buildTextFormField(
                controller: _firstNameController,
                hint: 'الاسم الأول',
                validator:
                    (v) =>
                        (v == null || v.isEmpty)
                            ? 'يرجى إدخال الاسم الأول'
                            : null,
              ),
              const SizedBox(height: 15),

              _buildTextFormField(
                controller: _lastNameController,
                hint: 'اللقب',
                validator:
                    (v) => (v == null || v.isEmpty) ? 'يرجى إدخال اللقب' : null,
              ),
              const SizedBox(height: 15),

              _buildTextFormField(
                controller: _emailController,
                hint: 'البريد الالكتروني',
                keyboardType: TextInputType.emailAddress,
                validator:
                    (v) =>
                        (v == null || !v.contains('@'))
                            ? 'بريد غير صحيح'
                            : null,
              ),
              const SizedBox(height: 15),

              _buildTextFormField(
                controller: _phoneController,
                hint: 'رقم الهاتف',
                keyboardType: TextInputType.phone,
                validator:
                    (v) => (v == null || v.length < 10) ? 'رقم غير صحيح' : null,
              ),
              const SizedBox(height: 15),

              _buildTextFormField(
                controller: _userController,
                hint: 'اسم المستخدم',
                validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 15),

              _buildTextFormField(
                controller: _idController,
                hint: 'رقم القيد',
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        (v == null ||
                                v.length != 6 ||
                                !RegExp(r'^[0-9]+$').hasMatch(v))
                            ? 'يجب 6 أرقام فقط'
                            : null,
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                // initialValue: _selectedMajor,
                isExpanded: true,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.black,
                  fontSize: 14,
                ),
                decoration: _dropdownDecoration('اختر التخصص'),
                items: const [
                  DropdownMenuItem(
                    value: 'حاسب الي',
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'حاسب آلي',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'اتصالات',
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'اتصالات',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'تحكم الي',
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'تحكم آلي',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => selectedMajor = value),
                validator: (value) => (value == null) ? 'يرجى الاختيار' : null,
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const OTPScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A5AE0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تسجيل حسابي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      // التحكم في اتجاه النص المكتوب بناءً على لغته
      textDirection:
          _isArabic(controller.text) ? TextDirection.rtl : TextDirection.ltr,
      // جعل المؤشر يبدأ من "البداية" حسب اتجاه النص المختار أعلاه
      textAlign: TextAlign.start,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (value) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        // التعديل الأساسي هنا: جعل التلميح (Hint) دائماً جهة اليمين
        hintTextDirection: TextDirection.rtl,
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF1F0F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
        // لضمان محاذاة رسائل الخطأ أيضاً لليمين
        errorMaxLines: 1,
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintTextDirection: TextDirection.rtl,
      hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF1F0F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
    );
  }
}
