import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Waslaa/bottom_nav.dart';
import 'package:Waslaa/chat_page.dart';
import 'package:Waslaa/company_details.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/dashboard/models/home_dashboard.dart';
import 'package:Waslaa/features/dashboard/repositories/dashboard_repository.dart';
import 'package:Waslaa/features/internships/models/internship.dart';
import 'package:Waslaa/features/opportunities/models/opportunity.dart';
import 'package:Waslaa/my_internships_page.dart';
import 'package:Waslaa/profile_screen.dart';
import 'package:Waslaa/reports_page.dart';
import 'package:Waslaa/widgets/image_slider.dart';
import 'notifications_screen.dart';
import 'company_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Widget> get _pages => [
    _HomeContentBody(
      onOpenCompanies: () {
        setState(() => _selectedIndex = 1);
      },
      onOpenInternships: () {
        setState(() => _selectedIndex = 2);
      },
    ),
    CompanyPage(scaffoldKey: _scaffoldKey),
    MyInternshipsPage(),
    ProfileScreen(
      onOpenCompanies: () {
        setState(() => _selectedIndex = 1);
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8F8FC),
        appBar: _selectedIndex == 0 ? _buildModernAppBar() : null,
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: GlassyBottomNavBar(
          currentIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F8FC),
      surfaceTintColor: const Color(0xFFF8F8FC),
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text(
        "الصفحة الرئيسية",
        style: TextStyle(
          fontSize: 22,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: primarycolor),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              ),
        ),
      ],
    );
  }
}

class _HomeContentBody extends StatefulWidget {
  final VoidCallback onOpenCompanies;
  final VoidCallback onOpenInternships;

  const _HomeContentBody({
    required this.onOpenCompanies,
    required this.onOpenInternships,
  });

  @override
  State<_HomeContentBody> createState() => _HomeContentBodyState();
}

class _HomeContentBodyState extends State<_HomeContentBody> {
  HomeDashboard? _dashboard;
  bool _isLoadingHomeData = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final dashboardRepo = context.read<DashboardRepository>();
      final dashboard = await dashboardRepo.getHomeDashboard();

      if (!mounted) return;
      setState(() {
        _dashboard = dashboard;
        _isLoadingHomeData = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingHomeData = false;
      });
    }
  }

  Future<void> _openReports() async {
    final internshipId = _dashboard?.currentInternship?.id;
    if (internshipId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد تدريب نشط لرفع تقرير مرتبط به.')),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportsPage(internshipId: internshipId),
      ),
    );
  }

  Future<void> _openChat() async {
    final supervisor = _dashboard?.currentInternship?.supervisor;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatPage(
              internshipId: _dashboard?.currentInternship?.id,
              receiverId: supervisor?.userId,
              receiverName: supervisor?.name,
            ),
      ),
    );
  }

  Future<void> _openOpportunity(Opportunity opportunity) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyDetailsPage(opportunity: opportunity),
      ),
    );
  }

  String _reportSubtitle() =>
      _dashboard?.currentInternship == null
          ? 'يتطلب وجود تدريب نشط'
          : 'أرسل التقرير المرتبط بتدريبك';
  String _chatSubtitle() =>
      _dashboard?.currentInternship?.supervisor?.name ??
      'افتح المحادثات الحالية';

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadHomeData,
      color: primarycolor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // تم حذف _buildSearchField() من هنا
            const _WelcomeCard(),
            if (_dashboard != null && _dashboard!.sliderItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              ImageSliderScreen(items: _dashboard!.sliderItems),
              const SizedBox(height: 18),
            ],
            const _SectionTitle(title: 'نظرة سريعة'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickStatCard(
                    title: 'إشعارات',
                    value:
                        _dashboard != null
                            ? _dashboard!.unreadNotificationsCount.toString()
                            : '–',
                    icon: Icons.notifications_none_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickStatCard(
                    title: 'طلباتي',
                    value:
                        _dashboard != null
                            ? _dashboard!.applicationsCount.toString()
                            : '–',
                    icon: Icons.description_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const _SectionTitle(title: 'تدريبك الحالي'),
            const SizedBox(height: 12),
            _CurrentInternshipCard(
              internship: _dashboard?.currentInternship,
              onOpenInternships: widget.onOpenInternships,
              onOpenCompanies: widget.onOpenCompanies,
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionTitle(title: 'فرص تدريب متاحة'),
                InkWell(
                  onTap: widget.onOpenCompanies,
                  child: Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontSize: 13,
                      color: primarycolor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingHomeData)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_dashboard == null ||
                _dashboard!.featuredOpportunities.isEmpty)
              _EmptyFeaturedOpportunitiesCard(onTap: widget.onOpenCompanies)
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      _dashboard!.featuredOpportunities
                          .map(
                            (opportunity) => Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: _FeaturedOpportunityCard(
                                opportunity: opportunity,
                                onTap: () => _openOpportunity(opportunity),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            const SizedBox(height: 22),
            const _SectionTitle(title: 'خطوات سريعة'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    title: 'رفع التقرير',
                    subtitle: _reportSubtitle(),
                    icon: Icons.upload_file_rounded,
                    enabled: _dashboard?.currentInternship != null,
                    onTap: _openReports,
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primarycolor, primarycolor.withValues(alpha: 0.80)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primarycolor.withValues(alpha: 0.22),
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
              children: const [
                Text(
                  "مرحبًا بك 👋",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "ابدأ رحلتك التدريبية بثقة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "استعرض الشركات المتاحة، تواصل مع المشرف، وارفع تقاريرك بسهولة من مكان واحد.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
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
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school_outlined,
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
        fontSize: 18,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _QuickStatCard({
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
        border: Border.all(color: primarycolor.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: primarycolor.withValues(alpha: 0.06),
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
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.72),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedOpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback onTap;

  const _FeaturedOpportunityCard({
    required this.opportunity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = opportunity.imagePath;
    final companyName = opportunity.company?.name ?? 'فرصة تدريب';
    final title = opportunity.title;
    final location = opportunity.locationText ?? opportunity.city ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: SizedBox(
        width: 250,
        height: 158,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child:
                    imagePath != null
                        ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                color: primarycolor.withValues(alpha: 0.10),
                                child: Icon(
                                  Icons.business_center_rounded,
                                  size: 42,
                                  color: primarycolor,
                                ),
                              ),
                        )
                        : Container(
                          color: primarycolor.withValues(alpha: 0.10),
                          child: Icon(
                            Icons.business_center_rounded,
                            size: 42,
                            color: primarycolor,
                          ),
                        ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.80),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      opportunity.isAvailable
                          ? Colors.green.withValues(alpha: 0.18)
                          : Colors.red.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  opportunity.isAvailable ? 'متاح' : 'مغلق',
                  style: TextStyle(
                    color:
                        opportunity.isAvailable
                            ? Colors.greenAccent
                            : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 14,
              left: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final int badgeCount;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = enabled ? primarycolor : Colors.grey;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: enabled ? onTap : null,
      child: Container(
        height: 132,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: accentColor, size: 28),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.58),
                    fontSize: 12,
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
                    badgeCount > 9 ? '9+' : badgeCount.toString(),
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

class _CurrentInternshipCard extends StatelessWidget {
  final Internship? internship;
  final VoidCallback onOpenInternships;
  final VoidCallback onOpenCompanies;

  const _CurrentInternshipCard({
    required this.internship,
    required this.onOpenInternships,
    required this.onOpenCompanies,
  });

  @override
  Widget build(BuildContext context) {
    final activeInternship = internship;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primarycolor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          activeInternship == null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'لا يوجد تدريب نشط حالياً',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ابدأ بالتقديم على فرص التدريب المتاحة ليظهر تدريبك الحالي هنا.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.6,
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onOpenCompanies,
                      child: Text(
                        'استعرض الفرص',
                        style: TextStyle(color: primarycolor),
                      ),
                    ),
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeInternship.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activeInternship.company?.name ?? 'شركة غير محددة',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InternshipMetaChip(
                        icon: Icons.badge_outlined,
                        label:
                            activeInternship.supervisor?.name ??
                            'المشرف غير محدد',
                      ),
                      _InternshipMetaChip(
                        icon: Icons.event_note_rounded,
                        label:
                            activeInternship.reportDueDate != null
                                ? 'التقرير: ${activeInternship.reportDueDate}'
                                : 'لا يوجد موعد تقرير بعد',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onOpenInternships,
                      child: Text(
                        'عرض تفاصيل التدريب',
                        style: TextStyle(color: primarycolor),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _InternshipMetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InternshipMetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primarycolor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primarycolor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeaturedOpportunitiesCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyFeaturedOpportunitiesCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primarycolor.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'لا توجد فرص متاحة حالياً',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنك الانتقال إلى صفحة الشركات لمراجعة الفرص فور توفرها أو تحديث القائمة لاحقاً.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onTap,
              child: Text(
                'فتح صفحة الشركات',
                style: TextStyle(color: primarycolor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTipCard extends StatelessWidget {
  final DashboardContentItem item;

  const _InfoTipCard({required this.item});

  IconData _iconForKey(String? key) {
    switch (key) {
      case 'article':
        return Icons.article_outlined;
      case 'track_changes':
        return Icons.track_changes_outlined;
      case 'schedule':
        return Icons.access_time_rounded;
      case 'campaign':
        return Icons.campaign_outlined;
      case 'notifications':
        return Icons.notifications_active_outlined;
      default:
        return Icons.lightbulb_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconForKey(item.iconKey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primarycolor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primarycolor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primarycolor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle ?? '',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.6,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final DashboardContentItem item;

  const _AnnouncementCard({required this.item});

  IconData _iconForKey(String? key) {
    switch (key) {
      case 'campaign':
        return Icons.campaign_outlined;
      case 'notifications':
        return Icons.notifications_active_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primarycolor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primarycolor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_iconForKey(item.iconKey), color: primarycolor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (item.badge != null && item.badge!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primarycolor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.badge!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primarycolor,
                          ),
                        ),
                      ),
                  ],
                ),
                if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle!,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.6,
                      color: Colors.black.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
