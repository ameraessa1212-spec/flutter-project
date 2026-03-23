import 'package:flutter/material.dart';
import 'package:Waslaa/apply_internship_page.dart';
import 'package:Waslaa/const/app_dimensions.dart';
import 'package:Waslaa/const/color.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDetailsPage extends StatelessWidget {
  final String opportunityTitle;
  final String companyName;
  final String description;
  final String logoPath;
  final bool isAvailable;
  final String specialization;
  final String location;
  final String duration;

  const CompanyDetailsPage({
    super.key,
    required this.opportunityTitle,
    required this.companyName,
    required this.description,
    required this.logoPath,
    required this.isAvailable,
    required this.specialization,
    required this.location,
    required this.duration,
  });

  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);

  String _getMapUrl() {
    if (companyName.contains("ليبيانا")) {
      return "https://maps.google.com/?q=Libyana+Mobile+Phone";
    }
    if (companyName.contains("هاتف ليبيا")) {
      return "https://maps.google.com/?q=Hatif+Libya";
    }
    if (companyName.contains("المدار")) {
      return "https://maps.google.com/?q=Al-Madar+Al-Jadeed";
    }
    if (companyName.contains("الواحة")) {
      return "https://maps.google.com/?q=Waha+Oil+Company";
    }
    if (companyName.contains("مصرف الجمهورية")) {
      return "https://maps.google.com/?q=Jumhouria+Bank";
    }
    if (companyName.contains("مليته للنفط")) {
      return "https://maps.google.com/?q=Mellitah+Oil+and+Gas";
    }
    return "https://maps.google.com";
  }

  String _getWebsiteUrl() {
    if (companyName.contains("ليبيانا")) return "https://libyana.ly";
    if (companyName.contains("هاتف ليبيا")) return "https://hl.ly";
    if (companyName.contains("المدار")) return "https://almadar.ly";
    if (companyName.contains("الواحة")) return "https://wahaoil.ly";
    if (companyName.contains("مصرف الجمهورية")) return "https://jbank.ly";
    if (companyName.contains("مليته للنفط")) return "https://mellitahog.ly";
    return "https://google.com";
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("لا يمكن فتح الرابط: $urlString");
    }
  }

  @override
  Widget build(BuildContext context) {
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
            "تفاصيل الفرصة",
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

              /// صورة الفرصة / الشركة
              Stack(
                children: [
                  Container(
                    height: AppDimensions.screenHeight * 0.30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: DecorationImage(
                        image: AssetImage(logoPath),
                        fit: BoxFit.cover,
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
                          Colors.black.withValues(alpha: 0.82),
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
                            isAvailable
                                ? Colors.green.withValues(alpha: 0.85)
                                : Colors.red.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAvailable ? "متاح الآن" : "مغلق حالياً",
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
                          opportunityTitle,
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

              /// معلومات سريعة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _MiniInfoCard(
                            icon: Icons.school_outlined,
                            title: "التخصص",
                            value: specialization,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniInfoCard(
                            icon: Icons.location_on_outlined,
                            title: "الموقع",
                            value: location,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _MiniInfoCard(
                      icon: Icons.access_time_rounded,
                      title: "مدة التدريب",
                      value: duration,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// أزرار الخريطة والموقع
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionInfoCard(
                        title: "الموقع الإلكتروني",
                        icon: Icons.language_rounded,
                        onTap: () => _launchURL(_getWebsiteUrl()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionInfoCard(
                        title: "عرض الخريطة",
                        icon: Icons.location_on_outlined,
                        onTap: () => _launchURL(_getMapUrl()),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// وصف الفرصة
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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
                        SizedBox(width: 8),
                        Text(
                          "وصف فرصة التدريب",
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

              const SizedBox(height: 18),

              SizedBox(height: AppDimensions.screenHeight * 0.04),

              /// زر التقديم
              ElevatedButton(
                onPressed:
                    isAvailable
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ApplyInternshipPage(
                                    opportunityTitle: opportunityTitle,
                                    companyName: companyName,
                                    specialization: specialization,
                                    location: location,
                                    duration: duration,
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
                  isAvailable ? "طلب تدريب" : "التدريب غير متاح حالياً",
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
        border: Border.all(color: primarycolor.withValues(alpha: 0.10)),
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
                    color: Colors.black.withValues(alpha: 0.45),
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
          border: Border.all(color: primarycolor.withValues(alpha: 0.10)),
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
