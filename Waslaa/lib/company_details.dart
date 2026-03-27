import 'package:flutter/material.dart';
import 'package:Waslaa/apply_internship_page.dart';
import 'package:Waslaa/const/app_dimensions.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/opportunities/models/opportunity.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDetailsPage extends StatelessWidget {
  final Opportunity opportunity;

  const CompanyDetailsPage({super.key, required this.opportunity});

  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('لا يمكن فتح الرابط: $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = opportunity.company;
    final companyName = company?.name ?? '';
    final imagePath = opportunity.imagePath;
    final location = opportunity.locationText ?? opportunity.city ?? '';
    final duration = opportunity.durationText ?? '';
    final spec = opportunity.specialization?.name ?? '';
    final description = opportunity.description ?? '';
    final companyDescription = company?.description ?? '';
    final mapUrl = company?.mapUrl ?? '';
    final websiteUrl = company?.websiteUrl ?? '';
    final companyCity = company?.city ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F8FC),
          surfaceTintColor: const Color(0xFFF8F8FC),
          elevation: 0,
          centerTitle: true,
          title: Text(
            'تفاصيل الفرصة',
            style: TextStyle(color: primarycolor, fontSize: 20),
          ),
          iconTheme: IconThemeData(color: primarycolor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),

              // صورة الفرصة
              Stack(
                children: [
                  Container(
                    height: AppDimensions.screenHeight * 0.30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: primarycolor.withOpacity(0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child:
                          imagePath != null
                              ? Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder:
                                    (_, __, ___) => Icon(
                                      Icons.business,
                                      size: 60,
                                      color: primarycolor,
                                    ),
                              )
                              : Icon(
                                Icons.business,
                                size: 60,
                                color: primarycolor,
                              ),
                    ),
                  ),
                  Container(
                    height: AppDimensions.screenHeight * 0.30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.82),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            opportunity.isAvailable
                                ? Colors.green.withOpacity(0.85)
                                : Colors.red.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        opportunity.isAvailable ? 'متاح الآن' : 'مغلق حالياً',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    left: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opportunity.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // معلومات سريعة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (spec.isNotEmpty)
                          Expanded(
                            child: _MiniInfoCard(
                              icon: Icons.school_outlined,
                              title: 'التخصص',
                              value: spec,
                            ),
                          ),
                        if (spec.isNotEmpty && location.isNotEmpty)
                          const SizedBox(width: 10),
                        if (location.isNotEmpty)
                          Expanded(
                            child: _MiniInfoCard(
                              icon: Icons.location_on_outlined,
                              title: 'الموقع',
                              value:
                                  location.isNotEmpty ? location : companyCity,
                            ),
                          ),
                      ],
                    ),
                    if (duration.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _MiniInfoCard(
                        icon: Icons.access_time_rounded,
                        title: 'مدة التدريب',
                        value: duration,
                        fullWidth: true,
                      ),
                    ],
                    if (opportunity.applicationDeadline != null) ...[
                      const SizedBox(height: 10),
                      _MiniInfoCard(
                        icon: Icons.calendar_today_outlined,
                        title: 'آخر موعد للتقديم',
                        value: opportunity.applicationDeadline!,
                        fullWidth: true,
                      ),
                    ],
                  ],
                ),
              ),

              // أزرار الخريطة والموقع
              if (websiteUrl.isNotEmpty || mapUrl.isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (websiteUrl.isNotEmpty)
                        Expanded(
                          child: _ActionInfoCard(
                            title: 'الموقع الإلكتروني',
                            icon: Icons.language_rounded,
                            onTap: () => _launchURL(websiteUrl),
                          ),
                        ),
                      if (websiteUrl.isNotEmpty && mapUrl.isNotEmpty)
                        const SizedBox(width: 12),
                      if (mapUrl.isNotEmpty)
                        Expanded(
                          child: _ActionInfoCard(
                            title: 'عرض الخريطة',
                            icon: Icons.location_on_outlined,
                            onTap: () => _launchURL(mapUrl),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // وصف الفرصة
              if (description.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: primarycolor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'وصف فرصة التدريب',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        description,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                          color: textMuted,
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),

              // نبذة عن الشركة
              if (companyName.isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.business_outlined,
                            color: primarycolor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'نبذة عن الشركة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        companyDescription.isNotEmpty
                            ? companyDescription
                            : '$companyName توفر فرص تدريب للطلاب في عدد من التخصصات، وتهدف إلى منحهم تجربة عملية حقيقية داخل بيئة العمل.',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14, color: textMuted),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: AppDimensions.screenHeight * 0.04),

              // زر التقديم
              ElevatedButton(
                onPressed:
                    opportunity.isAvailable
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ApplyInternshipPage(
                                    opportunity: opportunity,
                                  ),
                            ),
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primarycolor,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  minimumSize: Size(AppDimensions.screenWidth * 0.8, 54),
                ),
                child: Text(
                  opportunity.isAvailable
                      ? 'طلب تدريب'
                      : 'التدريب غير متاح حالياً',
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool fullWidth;

  const _MiniInfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primarycolor.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: primarycolor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.45),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: CompanyDetailsPage.textDark,
                    fontSize: 13,
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

class _ActionInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionInfoCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primarycolor.withOpacity(0.10)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
