import 'package:flutter/material.dart';

class NotificationItem {
  final String date;
  final String title;
  final String body;

  NotificationItem({
    required this.date,
    required this.title,
    required this.body,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const Color primary = Color(0xFF6B4EFF);

  // 🔹 بيانات وهمية (Front-end فقط)
  List<NotificationItem> items = [];

  @override
  void initState() {
    super.initState();

    // 🔁 للتجربة:
    // الحالة 1: لا توجد إشعارات
    // items = [];

    // الحالة 2: يوجد إشعار (مثل فيقما)
    items = [
      NotificationItem(
        date: "2025/12/12",
        title: "مرحباً،",
        body:
            "تم إضافة إشعار جديد — يرجى التحقق من بريدك أو طلباتك لمعرفة التفاصيل.",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = items.isEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        // 🔹 AppBar
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "الإشعارات",
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),

        // 🔹 Body
        body: SafeArea(
          child:
              isEmpty
                  ? const _EmptyNotifications()
                  : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder:
                        (context, i) => _NotificationRow(item: items[i]),
                  ),
        ),
      ),
    );
  }
}

/// 🟣 عنصر الإشعار (الأيقونة يمين – التاريخ يسار)
class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item});

  final NotificationItem item;
  static const Color primary = Color(0xFF6B4EFF);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAE6FF)),
          ),
          child: Row(
            textDirection: TextDirection.rtl, // ✅ مهم جدًا
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✉️ الأيقونة (يمين)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mail_outline, color: primary, size: 18),
              ),

              const SizedBox(width: 10),

              // 📝 النص (الوسط)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // 📅 التاريخ (يسار)
              Text(
                item.date,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // الخط البنفسجي أسفل الإشعار
        Container(
          margin: const EdgeInsets.only(top: 6),
          height: 2,
          width: double.infinity,
          color: primary.withOpacity(0.35),
        ),
      ],
    );
  }
}

/// 🟣 واجهة "لا توجد إشعارات"
class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  static const Color primary = Color(0xFF6B4EFF);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topGap = (size.height * 0.10).clamp(24.0, 80.0);
    final iconSize = (size.width * 0.38).clamp(110.0, 170.0);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              SizedBox(height: topGap),

              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6FF),
                      borderRadius: BorderRadius.circular(iconSize / 2),
                    ),
                  ),
                  Icon(
                    Icons.notifications_none_rounded,
                    size: iconSize * 0.55,
                    color: const Color(0xFF7AA7FF),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Container(
                width: 70,
                height: 4,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "لا توجد إشعارات حالياً",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "سنقوم بإبلاغك هنا عندما تتوفر",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
