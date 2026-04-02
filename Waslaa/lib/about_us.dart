import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70, // تقليل الارتفاع قليلاً ليتناسب مع الخط الصغير
        title: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: const Text(
            "من نحن ؟",
            style: TextStyle(
              fontFamily: 'Cairo',
              color: Color(0xFF6A5AE0),
              fontWeight: FontWeight.bold,
              fontSize: 15, // تصغير عنوان الصفحة الرئيسي
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF6A5AE0),
              size: 18,
            ), // تصغير السهم
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
            _buildSection(
              "الرؤية",
              "تجربة التدريب ميداني رقمية سهلة وموثوقة تربط الطلبة بسوق العمل",
            ),

            const SizedBox(height: 5),

            _buildSection(
              "الرسالة",
              "تسهيل إجراءات التدريب من التقديم إلى التقييم عبر نظام واضح وآمن يدعم التواصل والمتابعة",
            ),

            const SizedBox(height: 5),

            const Text(
              "الأهداف",
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: Color(0xFF6A5AE0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
              "ربط الطلبة بالشركات وتسهيل التقديم على فرص التدريب",
            ),
            _buildBulletPoint(
              "دعم التواصل عبر الشات بين الطالب ومشرف الكلية لتسهيل المتابعة",
            ),
            _buildBulletPoint(
              "إشعارات فورية لحالة الطلب (قبول/رفض) والتنبيهات والمواعيد",
            ),

            const SizedBox(height: 20),

            const Text(
              "القيم",
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: Color(0xFF6A5AE0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint("الأمان"),
            _buildBulletPoint("السهولة"),
            _buildBulletPoint("السرعة"),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Color(0xFF6A5AE0),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Padding(
            padding: EdgeInsets.only(top: 3),
            child: Icon(
              Icons.check_circle,
              color: Color(0xFF6A5AE0),
              size: 15,
            ), // تصغير أيقونة الصح
          ),
        ],
      ),
    );
  }
}
