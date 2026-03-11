import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _personalInfoKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  
  // تم تغيير اسم الكنترولر هنا ليكون أكثر وضوحاً
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            "الإعدادات",
            style: TextStyle(fontFamily: 'Cairo', color: Color(0xFF6A5AE0), fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6A5AE0), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30.0, left: 25.0, right: 25.0, bottom: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // القسم الأول: المعلومات الشخصية
            Form(
              key: _personalInfoKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "المعلومات الشخصية", 
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF6A5AE0), fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 15),
                  
                  // الحقل المعدل: اسم المستخدم مع أيقونة شخص
                  _buildTextField(
                    Icons.person_outline, 
                    "اسم المستخدم", 
                    controller: _userNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'يرجى إدخال اسم المستخدم';
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 12),
                  _buildTextField(
                    Icons.phone_android, 
                    "رقم الهاتف", 
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'يرجى إدخال الرقم';
                      if (value.length != 10) return 'يجب أن يكون الرقم 10 خانات';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(child: _buildActionButton("تحديث البيانات", () {
                    if (_personalInfoKey.currentState!.validate()) {
                      _showSnackBar('تم تحديث المعلومات الشخصية');
                    }
                  })),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // القسم الثاني: تغيير كلمة المرور
            Form(
              key: _passwordKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "تغيير كلمة المرور", 
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Color(0xFF6A5AE0), fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    Icons.lock_outline, 
                    "كلمة المرور الجديدة", 
                    isPassword: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
                      if (value.length < 6) return '6 أحرف على الأقل';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    Icons.lock_reset, 
                    "تأكيد كلمة المرور", 
                    isPassword: true,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'يرجى تأكيد كلمة المرور';
                      if (value != _passwordController.text) return 'كلمات المرور غير متطابقة';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(child: _buildActionButton("تغيير كلمة المرور", () {
                    if (_passwordKey.currentState!.validate()) {
                      _showSnackBar('تم تغيير كلمة المرور بنجاح');
                    }
                  })),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
        backgroundColor: const Color(0xFF6A5AE0),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hint, {bool isPassword = false, TextEditingController? controller, String? Function(String?)? validator, TextInputType keyboardType = TextInputType.text, int? maxLength}) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      obscureText: isPassword,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
      validator: validator,
      decoration: InputDecoration(
        counterText: "",
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF6A5AE0), size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6A5AE0), width: 1.5)),
        errorStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.red),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 160,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A5AE0),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(text, style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
