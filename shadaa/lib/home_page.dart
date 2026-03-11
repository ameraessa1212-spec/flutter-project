import 'package:flutter/material.dart';
import 'package:shadaa/bottom_nav.dart';
import 'package:shadaa/const/app_dimensions.dart';
import 'package:shadaa/const/color.dart';
import 'package:shadaa/my_internships_page.dart';
import 'package:shadaa/profile_screen.dart';
import 'package:shadaa/widgets/image_slider.dart';
import 'notifications_screen.dart';
import 'Company.dart';

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
      onOpenChat: () {
        setState(() => _selectedIndex = 2);
      },
      onOpenReports: () {
        setState(() => _selectedIndex = 3);
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

class _HomeContentBody extends StatelessWidget {
  final VoidCallback onOpenCompanies;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenReports;

  const _HomeContentBody({
    required this.onOpenCompanies,
    required this.onOpenChat,
    required this.onOpenReports,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(),
          const SizedBox(height: 14),
          const _WelcomeCard(),
          const SizedBox(height: 16),
          const ImageSliderScreen(),
          const SizedBox(height: 18),
          const _SectionTitle(title: "نظرة سريعة"),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _QuickStatCard(
                  title: "فرص متاحة",
                  value: "12",
                  icon: Icons.work_outline_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _QuickStatCard(
                  title: "طلباتي",
                  value: "3",
                  icon: Icons.description_outlined,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _QuickStatCard(
                  title: "تقاريري",
                  value: "1",
                  icon: Icons.upload_file_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionTitle(title: "أبرز الشركات"),
              InkWell(
                onTap: onOpenCompanies,
                child: Text(
                  "عرض الكل",
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _FeaturedCompanyCard(
                  title: "شركة ليبيانا",
                  imagePath: 'assets/images/libyana.JPG',
                ),
                SizedBox(width: 12),
                _FeaturedCompanyCard(
                  title: "شركة المدار الجديد",
                  imagePath: 'assets/images/madar.JPG',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: "خطوات سريعة"),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  title: "التواصل مع المشرف",
                  subtitle: "افتح المحادثات الحالية",
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: onOpenChat,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  title: "رفع التقرير",
                  subtitle: "أرسل التقرير بسهولة",
                  icon: Icons.upload_file_rounded,
                  onTap: onOpenReports,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _SectionTitle(title: "نصائح مهمة"),
          const SizedBox(height: 12),
          const _InfoTipCard(
            title: "جهز سيرتك الذاتية",
            subtitle: "احرص على تحديث الـ CV قبل التقديم على أي فرصة تدريب.",
            icon: Icons.article_outlined,
          ),
          const SizedBox(height: 10),
          const _InfoTipCard(
            title: "تابع حالة طلبك",
            subtitle: "تحقق باستمرار من الطلبات المرسلة وحالة القبول أو الرفض.",
            icon: Icons.track_changes_outlined,
          ),
          const SizedBox(height: 10),
          const _InfoTipCard(
            title: "التزم بمواعيد التقرير",
            subtitle:
                "رفع التقرير في الوقت المحدد يساعدك على إنهاء التدريب بنجاح.",
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: "ابحث عن شركة أو فرصة تدريب...",
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 15,
        ),
        prefixIcon: Icon(Icons.search, color: primarycolor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primarycolor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primarycolor.withValues(alpha: 0.30)),
        ),
      ),
      cursorColor: primarycolor,
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

class _FeaturedCompanyCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const _FeaturedCompanyCard({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: AppDimensions.screenWidth * 0.72,
          height: AppDimensions.screenHeight * 0.17,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        Container(
          width: AppDimensions.screenWidth * 0.72,
          height: AppDimensions.screenHeight * 0.17,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.72),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 14,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 132,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primarycolor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primarycolor.withValues(alpha: 0.18)),
        ),
        child: Column(
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
      ),
    );
  }
}

class _InfoTipCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoTipCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

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
            child: Icon(icon, color: primarycolor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
