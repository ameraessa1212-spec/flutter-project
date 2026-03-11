import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCenterTap;

  final String centerLabel;
  final Color barColor;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCenterTap,
    this.centerLabel = "الرئسية",
    this.barColor = const Color(0xFF6159E8),
  });

  @override
  Widget build(BuildContext context) {
    Color iconColor(bool active) =>
        active ? Colors.white : Colors.white.withOpacity(0.75);

    Widget navItem({
      required int index,
      required IconData icon,
      required String label,
    }) {
      final active = currentIndex == index;
      return Expanded(
        child: InkWell(
          onTap: () => onTap(index),
          child: Padding(
            // ✅ خففنا الارتفاع باش ما يصيرش overflow
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor(active), size: 20),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10, // ✅ نقصناها شوي
                    fontWeight: FontWeight.w700,
                    color: iconColor(active),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ SafeArea + Padding تحت يحل مشكلة الـ overflow في الأجهزة اللي فيها bottom inset كبير
    return SafeArea(
      top: false,
      child: BottomAppBar(
        color: barColor,
        height: 86, // ✅ زدناها شوي
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Row(
            children: [
              navItem(
                index: 0,
                icon: Icons.description_rounded,
                label: "الطلبات",
              ),
              navItem(
                index: 1,
                icon: Icons.chat_bubble_rounded,
                label: "المحادثة",
              ),
              const SizedBox(width: 86),
              navItem(index: 3, icon: Icons.apartment, label: "الشركات"),
              navItem(index: 4, icon: Icons.person_rounded, label: "حسابي"),
            ],
          ),
        ),
      ),
    );
  }
}

class AppCenterFab extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final Color color;

  const AppCenterFab({
    super.key,
    required this.onTap,
    required this.label,
    this.color = const Color(0xFF6159E8),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      width: 86,
      child: Column(
        children: [
          Material(
            elevation: 10,
            shadowColor: color.withOpacity(0.40),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
