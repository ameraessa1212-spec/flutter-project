import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70, // متناسق مع باقي الصفحات
        title: const Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Text(
            "سياسات الاستخدام",
            style: TextStyle(
              fontFamily: 'Cairo', 
              color: Color(0xFF6A5AE0), 
              fontWeight: FontWeight.bold,
              fontSize: 15, // الحجم الذي طلبته لعنوان الصفحة
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6A5AE0), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30.0, left: 25.0, right: 25.0, bottom: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildSectionTitle("أهدافنا"),
            _buildParagraph("تجربة التدريب ميداني رقمية سهلة وموثوقة تربط الطلبة بسوق العمل"),
            
            const SizedBox(height: 10),
            _buildSectionTitle("استخدام المنصة"),
            _buildBulletItem("الحسابات المعتمدة: يُسمح باستخدام المنصة للطلبة"),
            _buildBulletItem("دقة البيانات: يجب إدخال بيانات صحيحة لتفادي رفض الطلب"),
            _buildBulletItem("الغرض من الاستخدام: المنصة مخصصة لأعمال التدريب الميداني فقط"),
            
            const SizedBox(height: 20),
            _buildSectionTitle("المحتوى والملفات"),
            _buildBulletItem("رفع الملفات: يتيح النظام للطالب رفع تقرير التدريب والبحث العلمي بصيغ معتمدة"),
            _buildBulletItem("مسؤولية المحتوى: الطالب مسؤول عن صحة الملفات ومحتواها"),
            _buildBulletItem("المراجعة: تخضع الملفات للمراجعة من الممتحنين وفق إجراءات الكلية"),
            
            const SizedBox(height: 20),
            _buildSectionTitle("التزامنا"),
            _buildParagraph("نلتزم بتقديم تجربة استخدام واضحة وآمنة، ونسعى لتحسين المنصة باستمرار من خلال الاستماع لملاحظات الطلبة"),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Cairo', 
        fontSize: 13, // حجم العناوين الجانبية
        color: Color(0xFF6A5AE0), 
        fontWeight: FontWeight.bold
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 15),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'Cairo', 
          fontSize: 12, // حجم نصوص الفقرات
          color: Colors.black87, 
          height: 1.6
        ),
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start, // لموازنة الأيقونة مع النصوص الطويلة
        children: [
          Expanded(
            child: Text(
              text, 
              textAlign: TextAlign.right, 
              style: const TextStyle(
                fontFamily: 'Cairo', 
                fontSize: 12 // حجم نصوص القائمة
              )
            )
          ),
          const SizedBox(width: 10),
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, color: Color(0xFF6A5AE0), size: 16), // تصغير الأيقونة لتناسب الخط
          ),
        ],
      ),
    );
  }
}