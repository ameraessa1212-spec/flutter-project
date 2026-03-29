import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/features/profile/repositories/profile_repository.dart';
import 'package:Waslaa/features/profile/models/user_profile.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/settings/repositories/settings_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _personalInfoKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  UserSettings? _settings;
  bool _loadingSettings = true;
  bool _isUpdatingProfile = false;
  bool _isUpdatingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final repo = context.read<SettingsRepository>();
      final s = await repo.getSettings();
      if (!mounted) return;
      setState(() {
        _settings = s;
        _loadingSettings = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingSettings = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_personalInfoKey.currentState!.validate()) return;
    setState(() => _isUpdatingProfile = true);
    try {
      final repo = context.read<ProfileRepository>();
      await repo.updateProfile(
        username:
            _userNameController.text.trim().isEmpty
                ? null
                : _userNameController.text.trim(),
        phone:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
      );
      if (!mounted) return;
      _showSnackBar('تم تحديث المعلومات الشخصية');
    } on DioException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message ?? 'حدث خطأ أثناء التحديث', isError: true);
    } finally {
      if (mounted) setState(() => _isUpdatingProfile = false);
    }
  }

  Future<void> _updatePassword() async {
    if (!_passwordKey.currentState!.validate()) return;
    setState(() => _isUpdatingPassword = true);
    try {
      final repo = context.read<ProfileRepository>();
      await repo.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _passwordController.text,
        newPasswordConfirmation: _confirmPasswordController.text,
      );
      if (!mounted) return;
      _showSnackBar('تم تغيير كلمة المرور بنجاح');
      _currentPasswordController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    } on DioException catch (e) {
      if (!mounted) return;
      _showSnackBar(
        e.message ?? 'حدث خطأ أثناء تغيير كلمة المرور',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isUpdatingPassword = false);
    }
  }

  Future<void> _updateSetting({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? chatNotifications,
  }) async {
    if (_settings == null) return;
    try {
      final repo = context.read<SettingsRepository>();
      final updated = await repo.updateSettings(
        pushNotificationsEnabled: pushNotifications,
        emailNotificationsEnabled: emailNotifications,
        chatNotificationsEnabled: chatNotifications,
      );
      if (!mounted) return;
      setState(() => _settings = updated);
    } on DioException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message ?? 'حدث خطأ', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
        ),
        backgroundColor: isError ? Colors.red : primarycolor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      obscureText: isPassword,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
      validator: validator,
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: Colors.grey,
        ),
        prefixIcon: Icon(icon, color: primarycolor, size: 18),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primarycolor, width: 1.5),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 10,
          color: Colors.red,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    VoidCallback? onPressed, {
    bool isLoading = false,
  }) {
    return SizedBox(
      width: 180,
      height: 42,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primarycolor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Text(
            'الإعدادات',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: primarycolor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: primarycolor, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 30.0,
          left: 25.0,
          right: 25.0,
          bottom: 40.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // المعلومات الشخصية
            Form(
              key: _personalInfoKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'المعلومات الشخصية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: primarycolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    Icons.person_outline,
                    'اسم المستخدم',
                    controller: _userNameController,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    Icons.phone_android,
                    'رقم الهاتف',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildActionButton(
                      'تحديث البيانات',
                      _updateProfile,
                      isLoading: _isUpdatingProfile,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            // تغيير كلمة المرور
            Form(
              key: _passwordKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'تغيير كلمة المرور',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: primarycolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    Icons.lock_open_outlined,
                    'كلمة المرور الحالية',
                    isPassword: true,
                    controller: _currentPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور الحالية';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    Icons.lock_outline,
                    'كلمة المرور الجديدة',
                    isPassword: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      if (value.length < 6) return '6 أحرف على الأقل';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    Icons.lock_reset,
                    'تأكيد كلمة المرور',
                    isPassword: true,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى تأكيد كلمة المرور';
                      }
                      if (value != _passwordController.text) {
                        return 'كلمات المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: _buildActionButton(
                      'تغيير كلمة المرور',
                      _updatePassword,
                      isLoading: _isUpdatingPassword,
                    ),
                  ),
                ],
              ),
            ),

            // إعدادات الإشعارات
            if (!_loadingSettings && _settings != null) ...[
              const SizedBox(height: 35),
              Text(
                'إعدادات الإشعارات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: primarycolor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: 'إشعارات الدفع',
                value: _settings!.pushNotificationsEnabled,
                onChanged: (v) => _updateSetting(pushNotifications: v),
              ),
              _buildSwitchTile(
                title: 'إشعارات البريد الإلكتروني',
                value: _settings!.emailNotificationsEnabled,
                onChanged: (v) => _updateSetting(emailNotifications: v),
              ),
              _buildSwitchTile(
                title: 'إشعارات المحادثة',
                value: _settings!.chatNotificationsEnabled,
                onChanged: (v) => _updateSetting(chatNotifications: v),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(value: value, onChanged: onChanged, activeColor: primarycolor),
          Text(
            title,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
          ),
        ],
      ),
    );
  }
}
