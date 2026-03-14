import 'package:flutter/material.dart';
import 'package:shadaa/const/color.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

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
            "الأحكام والشروط",
            style: TextStyle(color: primarycolor, fontSize: 20),
          ),
          iconTheme: IconThemeData(color: primarycolor),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSection(
                title: "1. استخدام التطبيق",
                content:
                    "يُستخدم التطبيق لغرض استعراض فرص التدريب الميداني والتقديم عليها ورفع الملفات والتواصل المرتبط بالتدريب فقط، ويمنع استخدامه لأي أغراض غير قانونية أو غير تعليمية.",
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: "2. صحة البيانات",
                content:
                    "يتعهد المستخدم بإدخال بيانات صحيحة ومحدثة عند إنشاء الحساب أو عند إرسال طلب تدريب أو رفع الملفات المطلوبة.",
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: "3. الملفات المرفوعة",
                content:
                    "يتحمل المستخدم مسؤولية الملفات التي يقوم برفعها، بما في ذلك السيرة الذاتية والتقارير والأبحاث، ويجب أن تكون الملفات مناسبة وخالية من أي محتوى مخالف.",
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: "4. التواصل مع الشركات أو المشرفين",
                content:
                    "يجب استخدام خاصية التواصل بشكل مهني ومحترم، ويمنع إرسال أي رسائل مسيئة أو غير مرتبطة بالتدريب.",
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: "5. قبول أو رفض الطلبات",
                content:
                    "لا يضمن التطبيق قبول طلب التدريب، إذ تخضع جميع الطلبات لمراجعة الجهة أو الشركة المعلنة للفرصة وفق شروطها الخاصة.",
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: "6. الخصوصية",
                content:
                    "يتم التعامل مع بيانات المستخدمين بسرية ووفق الغرض المرتبط بالخدمات التعليمية والتدريبية داخل التطبيق.",
              ),
              const SizedBox(height: 12),
              _buildSection(
                title: "7. تحديث الشروط",
                content:
                    "يحق لإدارة التطبيق تعديل هذه الأحكام والشروط عند الحاجة، ويعد استمرار المستخدم في استخدام التطبيق موافقة على التحديثات الجديدة.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: primarycolor)),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.black.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}
