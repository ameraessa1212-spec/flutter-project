import 'package:flutter/material.dart';
import 'package:shadaa/chat_page.dart';
import 'package:shadaa/const/color.dart';
import 'package:shadaa/reports_page.dart';

class MyInternshipsPage extends StatelessWidget {
  const MyInternshipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FC),
        surfaceTintColor: const Color(0xFFF8F8FC),
        elevation: 0,
        centerTitle: true,
        // هذا السطر هو المسؤول عن إلغاء زر الرجوع
        automaticallyImplyLeading: false,
        title: Text(
          "تدريباتي",
          style: TextStyle(
            color: primarycolor,
            fontSize: 22,
            fontWeight: FontWeight.bold, // أضفت بولد ليتناسب مع التصميم
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _InternshipSummaryCard(),
            const SizedBox(height: 18),

            const _SectionTitle(title: "التدريب الحالي"),
            const SizedBox(height: 10),
            const _CurrentInternshipCard(),

            const SizedBox(height: 22),
            const _SectionTitle(title: "إجراءات سريعة"),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: "رفع التقرير",
                    subtitle: "إرسال التقرير الأسبوعي",
                    icon: Icons.upload_file_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReportsPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    title: "التواصل مع المشرف",
                    subtitle: "فتح المحادثة الحالية",
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),
            const _SectionTitle(title: "طلباتي"),
            const SizedBox(height: 10),

            const _ApplicationStatusCard(
              companyName: "ليبيانا",
              opportunityTitle: "تدريب في الدعم الفني والشبكات",
              status: "مقبول",
              statusColor: Colors.green,
              dateText: "تم التقديم منذ 3 أيام",
            ),
          ],
        ),
      ),
    );
  }
}

class _InternshipSummaryCard extends StatelessWidget {
  const _InternshipSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primarycolor, primarycolor.withValues(alpha: 0.82)],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "متابعة رحلتك التدريبية",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "اطلع على طلبك، حالة تدريبك الحالي، والتقارير المرفوعة من مكان واحد.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _SummaryMiniBox(
                  title: "الطلب",
                  value: "1",
                  icon: Icons.description_outlined,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _SummaryMiniBox(
                  title: "التقارير",
                  value: "1",
                  icon: Icons.upload_file_outlined,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _SummaryMiniBox(
                  title: "الرسائل",
                  value: "2",
                  icon: Icons.chat_bubble_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMiniBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryMiniBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 19),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _CurrentInternshipCard extends StatelessWidget {
  const _CurrentInternshipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "نشط الآن",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                "ليبيانا",
                style: TextStyle(
                  color: primarycolor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "تدريب في الدعم الفني والشبكات",
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _SmallInfoChip(
                  icon: Icons.location_on_outlined,
                  text: "طرابلس",
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _SmallInfoChip(
                  icon: Icons.access_time_rounded,
                  text: "شهرين",
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "المشرف: نبيل كمال",
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.65),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "آخر موعد لرفع التقرير: 15 مارس",
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.65),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallInfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primarycolor.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primarycolor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 122,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: primarycolor.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primarycolor, size: 26),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.55),
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

class _ApplicationStatusCard extends StatelessWidget {
  final String companyName;
  final String opportunityTitle;
  final String status;
  final Color statusColor;
  final String dateText;

  const _ApplicationStatusCard({
    required this.companyName,
    required this.opportunityTitle,
    required this.status,
    required this.statusColor,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: TextStyle(
                    color: primarycolor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  opportunityTitle,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateText,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.50),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
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
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
