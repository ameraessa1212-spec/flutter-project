import 'package:flutter/material.dart';
import '../settings_page.dart';
import '../about_us.dart';
import '../privacy_policy.dart';
import '../discussion_schedule.dart';
import '../sign_in.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.70,
      backgroundColor: const Color(0xFFF8F7FF),
      child: Column(
        children: [
          const SizedBox(height: 70),
          Image.asset('assets/images/logo.png', width: 60),
          const SizedBox(height: 60),

          // عناصر القائمة
          _drawerItem(Icons.settings_outlined, 'الإعدادات', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          }),

          _drawerItem(Icons.info_outline, 'من نحن ؟', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            );
          }),

          _drawerItem(Icons.account_balance_outlined, 'سياسات الاستخدام', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyPage(),
              ),
            );
          }),

          _drawerItem(
            Icons.calendar_month_outlined,
            'جدول مواعيد المناقشات',
            () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiscussionSchedulePage(),
                ),
              );
            },
          ),

          const Spacer(),

          // زر تسجيل الخروج
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: SizedBox(
              width: 140,
              height: 40,
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5AE0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'تسجيل خروج',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // الويدجت المعدل لجعل الأيقونة بجانب النص مباشرة
  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end, // محاذاة العناصر لليمين
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(width: 12), // المسافة الصغيرة بين النص والأيقونة
            Icon(icon, color: const Color(0xFF6A5AE0), size: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // ... (نفس كود الديالوج السابق بدون تغيير)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'تسجيل الخروج',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد مغادرة التطبيق؟',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                  (route) => false,
                );
              },
              child: const Text(
                'خروج',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
