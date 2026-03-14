import 'package:flutter/material.dart';
import 'package:shadaa/const/app_dimensions.dart';
import 'package:shadaa/const/color.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

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
            "عن التطبيق",
            style: TextStyle(color: primarycolor, fontSize: 20),
          ),
          iconTheme: IconThemeData(color: primarycolor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Waslaa",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "منصة تساعد الطلبة على الوصول إلى فرص التدريب الميداني، متابعة الطلبات، التواصل مع المشرفين، ورفع التقارير الأكاديمية بسهولة من مكان واحد.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.5,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              _buildInfoCard(
                icon: Icons.school_outlined,
                title: "هدف التطبيق",
                content:
                    "يهدف التطبيق إلى تسهيل رحلة الطالب في التدريب الميداني، بداية من استعراض الفرص المتاحة، مرورًا بالتقديم والتواصل، وحتى رفع التقارير ومتابعة حالة التدريب.",
              ),
              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.business_center_outlined,
                title: "ماذا يوفر التطبيق؟",
                content:
                    "يوفر التطبيق عرضًا منظمًا لفرص التدريب حسب الشركات، مع إمكانية الاطلاع على التفاصيل، طلب التدريب، رفع الملفات المطلوبة، والتواصل مع المشرف الأكاديمي أو المهني.",
              ),
              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.groups_outlined,
                title: "الفئة المستهدفة",
                content:
                    "التطبيق موجه لطلبة الجامعات والمعاهد الباحثين عن فرص تدريب ميداني تساعدهم في اكتساب الخبرة العملية والاندماج في سوق العمل.",
              ),
              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.update_rounded,
                title: "الإصدار",
                content: "الإصدار الحالي: 1.0.0",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimensions.screenWidth * 0.08,
            height: AppDimensions.screenHeight * 0.050,
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
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.8,
                    color: Colors.black.withValues(alpha: 0.65),
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
