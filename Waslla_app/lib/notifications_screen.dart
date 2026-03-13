import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        'date': '2025/12/12',
        'content':
            'لقد تم قبولك في شركة النور للتدريب الميداني. يرجى التواصل على الرقم 0912345678 لاستكمال الإجراءات.',
      },
      {
        'date': '2025/12/10',
        'content': 'تم تحديث جدول مواعيد المناقشات لدفعة خريف 2025.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80, // زيادة ارتفاع التولبار لإنزال العنوان لأسفل
        title: Padding(
          padding: const EdgeInsets.only(top: 20), // إزاحة العنوان للأسفل
          child: const Text(
            'الإشعارات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15, // حجم الخط المطلوب 15
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A5AE0),
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20), // موازنة زر الرجوع مع العنوان
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF6A5AE0), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationsList(notifications),
    );
  }

Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // عرض الصورة المطلوبة من مجلد assets/images
            Image.asset(
              'assets/images/notifications.png',
              width: 140, // حجم مناسب للصورة في المنتصف
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            const Text(
              'لا توجد إشعارات حاليًا',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14, // حجم خط متناسق مع طلبك السابق
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ستظهر إشعاراتك هنا عند توفرها',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12, // خط أصغر قليلاً للوصف
                color: Colors.grey,
              ),
            ),
            // مساحة تعويضية أسفل العناصر لضمان توسطها الحقيقي
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<Map<String, String>> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => Divider(
        color: const Color(0xFF6A5AE0).withOpacity(0.1),
        thickness: 1,
        height: 30,
      ),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // التاريخ بخط صغير جداً
            Text(
              notifications[index]['date']!,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
                fontFamily: 'Cairo',
              ),
            ),
            
            const SizedBox(width: 12),

            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // محتوى الإشعار بحجم خط أصغر (11)
                  Expanded(
                    child: Text(
                      notifications[index]['content']!,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11, // تصغير حجم محتوى الإشعار
                        height: 1.5,
                        color: Color(0xFF4A4A4A),
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 10),

                  // الأيقونة الدائرية المصغرة
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A5AE0).withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mail_outline,
                          color: Color(0xFF6A5AE0),
                          size: 16,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0019B7),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
} 