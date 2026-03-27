import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/core/session/app_session_controller.dart';
import 'package:Waslaa/discussion_schedule.dart';
import 'package:Waslaa/examiner_reports_page.dart';
import 'package:Waslaa/features/notifications/repositories/notification_repository.dart';
import 'package:Waslaa/features/reports/repositories/report_repository.dart';
import 'package:Waslaa/notifications_screen.dart';
import 'package:Waslaa/sign_in.dart';

class ExaminerHomePage extends StatefulWidget {
  const ExaminerHomePage({super.key});

  @override
  State<ExaminerHomePage> createState() => _ExaminerHomePageState();
}

class _ExaminerHomePageState extends State<ExaminerHomePage> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    _ExaminerDashboard(),
    _ExaminerProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8FC),
        appBar: _selectedIndex == 0 ? _buildAppBar() : null,
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: _ExaminerBottomNav(
          currentIndex: _selectedIndex,
          onTabChange: (i) => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F8FC),
      surfaceTintColor: const Color(0xFFF8F8FC),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text(
        'لوحة المحكّم',
        style: TextStyle(
          fontSize: 22,
          color: Colors.black,
          fontWeight: FontWeight.w400,
          fontFamily: 'Cairo',
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: primarycolor),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
      ],
    );
  }
}

// ── Dashboard body ─────────────────────────────────────────────────────────

class _ExaminerDashboard extends StatefulWidget {
  const _ExaminerDashboard();

  @override
  State<_ExaminerDashboard> createState() => _ExaminerDashboardState();
}

class _ExaminerDashboardState extends State<_ExaminerDashboard> {
  int _unreadNotifications = 0;
  int _pendingReports = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final notifRepo = context.read<NotificationRepository>();
      final reportRepo = context.read<ReportRepository>();

      final notifCount = await notifRepo.getUnreadCount();
      int pendingCount = 0;
      try {
        final pendingReports = await reportRepo.getExaminerReports(status: 'pending');
        pendingCount = pendingReports.length;
      } catch (_) {
        // Pending reports count is non-critical; ignore errors.
      }

      if (!mounted) return;
      setState(() {
        _unreadNotifications = notifCount;
        _pendingReports = pendingCount;
        _isLoadingStats = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingStats = false);
    }
  }

  void _goToReports() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExaminerReportsPage()),
    );
  }

  void _goToSchedules() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DiscussionSchedulePage()),
    );
  }

  void _goToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    ).then((_) => _loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSessionController>();
    final name = session.currentUser?.name ?? 'المحكّم';

    return RefreshIndicator(
      color: primarycolor,
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WelcomeBanner(name: name),
            const SizedBox(height: 20),
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'إشعارات غير مقروءة',
                    value: _isLoadingStats ? '...' : '$_unreadNotifications',
                    icon: Icons.notifications_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'تقارير قيد الانتظار',
                    value: _isLoadingStats ? '...' : '$_pendingReports',
                    icon: Icons.pending_actions_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: 'الإجراءات السريعة'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'الإشعارات',
                    subtitle: 'اطّلع على آخر التنبيهات والأخبار',
                    icon: Icons.notifications_active_outlined,
                    badgeCount: _unreadNotifications,
                    onTap: _goToNotifications,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    title: 'جداول المناقشة',
                    subtitle: 'اعرض جداول مواعيد مناقشات الطلاب',
                    icon: Icons.calendar_today_outlined,
                    onTap: _goToSchedules,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'تقييم التقارير',
              subtitle: 'راجع تقارير الطلاب وقيّمها بقبول أو رفض مع ملاحظات',
              icon: Icons.rate_review_outlined,
              badgeCount: _pendingReports,
              onTap: _goToReports,
              wide: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Examiner profile tab ───────────────────────────────────────────────────

class _ExaminerProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSessionController>();
    final user = session.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F8FC),
          surfaceTintColor: const Color(0xFFF8F8FC),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'الملف الشخصي',
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              // Avatar + name
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primarycolor.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: primarycolor.withOpacity(0.15),
                      child: Icon(
                        Icons.person_outline,
                        size: 36,
                        color: primarycolor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'المحكّم',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: primarycolor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'محكّم',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: primarycolor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => Directionality(
                        textDirection: TextDirection.rtl,
                        child: AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text(
                            'تنبيه',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: const Text(
                            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Cairo'),
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
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'خروج',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text(
                                'إلغاء',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await context.read<AppSessionController>().signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInPage()),
                        (_) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

// ── Reusable widgets ────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  final String name;

  const _WelcomeBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primarycolor, primarycolor.withOpacity(0.80)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primarycolor.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحبًا، $name 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'لوحة تحكم المحكّم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'راجع تقارير الطلاب، اطّلع على جداول المناقشة، وقيّم الأعمال بسهولة.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
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
        fontFamily: 'Cairo',
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primarycolor.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: primarycolor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primarycolor, size: 22),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: primarycolor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.black.withOpacity(0.72),
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final bool wide;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: wide ? 100 : 132,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primarycolor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primarycolor.withOpacity(0.18)),
        ),
        child: wide
            ? Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(icon, color: primarycolor, size: 32),
                      if (badgeCount > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              badgeCount > 9 ? '9+' : '$badgeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: primarycolor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.58),
                            fontSize: 12,
                            fontFamily: 'Cairo',
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_back_ios,
                    color: primarycolor.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              )
            : Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: primarycolor, size: 28),
                      const Spacer(),
                      Text(
                        title,
                        style: TextStyle(
                          color: primarycolor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.58),
                          fontSize: 12,
                          fontFamily: 'Cairo',
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

// ── Bottom navigation ───────────────────────────────────────────────────────

class _ExaminerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChange;

  const _ExaminerBottomNav({
    required this.currentIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'الرئيسية',
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'الملف',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              return GestureDetector(
                onTap: () => onTabChange(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primarycolor.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected ? primarycolor : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: isSelected ? primarycolor : Colors.grey,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
