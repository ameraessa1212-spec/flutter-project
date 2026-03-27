import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/about_app_page.dart';
import 'package:Waslaa/const/app_dimensions.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/core/session/app_session_controller.dart';
import 'package:Waslaa/features/profile/models/user_profile.dart';
import 'package:Waslaa/features/profile/repositories/profile_repository.dart';
import 'package:Waslaa/terms_and_conditions_page.dart';
import 'package:Waslaa/discussion_schedule.dart';
import 'package:Waslaa/settings_page.dart';
import 'package:Waslaa/chat_page.dart';
import 'package:Waslaa/sign_in.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onOpenCompanies;

  const ProfileScreen({super.key, required this.onOpenCompanies});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final repo = context.read<ProfileRepository>();
      final p = await repo.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = p;
        _loadingProfile = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  // دالة لإظهار رسالة تأكيد تسجيل الخروج
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "تنبيه",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "هل أنت متأكد من رغبتك في تسجيل الخروج؟",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await context.read<AppSessionController>().signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                  (route) => false,
                );
              },
              child: const Text("خروج", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionUser = context.watch<AppSessionController>().currentUser;
    final displayName = _profile?.name ?? sessionUser?.name ?? 'مستخدم';
    final displayPhone = _profile?.phone ?? sessionUser?.phone ?? '';
    final role = _profile?.role ?? sessionUser?.role ?? '';
    final displayRole = switch (role) {
      'student' => 'طالب تدريب ميداني',
      'examiner' => 'محكّم',
      _ => role,
    };
    final avatarPath = _profile?.studentProfile?.profileImagePath;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),

              /// Header Section
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primarycolor,
                      primarycolor.withValues(alpha: 0.82),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primarycolor.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child:
                          avatarPath != null
                              ? ClipOval(
                                child: Image.network(
                                  avatarPath,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 34,
                                      ),
                                ),
                              )
                              : const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 34,
                              ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            displayPhone,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayRole,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// Quick info cards
              const Row(
                children: [
                  Expanded(
                    child: _ProfileMiniCard(
                      title: "الطلب",
                      value: "1",
                      icon: Icons.description_outlined,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _ProfileMiniCard(
                      title: "التقارير",
                      value: "1",
                      icon: Icons.upload_file_outlined,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _ProfileMiniCard(
                      title: "الرسائل",
                      value: "2",
                      icon: Icons.chat_bubble_outline_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const _SectionTitle(title: "الحساب"),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ProfileMenuTile(
                      title: "الدعم الفني",
                      subtitle: "تواصل مع إدارة النظام للاستفسارات التقنية",
                      icon: Icons.support_agent_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const ChatPage(
                                  receiverId: 1,
                                  receiverName: 'إدارة النظام (الدعم الفني)',
                                ),
                          ),
                        );
                      },
                    ),
                    _tileDivider(),
                    _ProfileMenuTile(
                      title: "مواعيد المناقشات",
                      subtitle: "الاطلاع على جدول مواعيد مناقشة التقارير",
                      icon: Icons.calendar_today_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const DiscussionSchedulePage(),
                          ),
                        );
                      },
                    ),
                    _tileDivider(),
                    _ProfileMenuTile(
                      title: "عن التطبيق",
                      subtitle: "تعرف أكثر على فكرة التطبيق وخدماته",
                      icon: Icons.info_outline,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutAppPage(),
                          ),
                        );
                      },
                    ),
                    _tileDivider(),
                    _ProfileMenuTile(
                      title: "الأحكام والشروط",
                      subtitle: "الاطلاع على السياسات والشروط العامة",
                      icon: Icons.policy_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const TermsAndConditionsPage(),
                          ),
                        );
                      },
                    ),
                    _tileDivider(),
                    _ProfileMenuTile(
                      title: "الإعدادات",
                      subtitle: "التحكم في التنبيهات وإعدادات الحساب",
                      icon: Icons.settings_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const _SectionTitle(title: "إجراءات"),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ProfileMenuTile(
                      title: "تسجيل الخروج",
                      subtitle: "الخروج من الحساب الحالي",
                      icon: Icons.logout_outlined,
                      color: Colors.red,
                      onTap: () => _showLogoutConfirmation(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tileDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: primarycolor.withValues(alpha: 0.08),
      indent: 18,
      endIndent: 18,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

class _ProfileMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _ProfileMiniCard({
    required this.title,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primarycolor.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primarycolor, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: primarycolor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black.withOpacity(0.65),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileMenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? primarycolor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tileColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: tileColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color ?? Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.50),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios_new_rounded, color: tileColor, size: 18),
          ],
        ),
      ),
    );
  }
}
