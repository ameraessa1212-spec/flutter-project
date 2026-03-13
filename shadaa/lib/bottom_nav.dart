import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shadaa/const/color.dart';

class GlassyBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChange;

  const GlassyBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.fromLTRB(5, 0, 5, 25),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: primarycolor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: primarycolor.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: GNav(
                  rippleColor: primarycolor.withValues(alpha: 0.2),
                  hoverColor: primarycolor.withValues(alpha: 0.1),
                  gap: 8,
                  activeColor: Colors.white,
                  iconSize: 24,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  duration: const Duration(milliseconds: 400),
                  tabBackgroundColor: primarycolor,
                  color: primarycolor.withValues(alpha: 0.7),
                  selectedIndex: currentIndex,
                  onTabChange: onTabChange,
                  tabs: const [
                    GButton(
                      icon: Icons.home_rounded,
                      iconSize: 22,
                      text: 'الرئيسية',
                      padding: EdgeInsets.all(8),
                    ),
                    GButton(
                      icon: Icons.business_center_rounded,
                      iconSize: 22,

                      text: 'الشركات',
                      padding: EdgeInsets.all(8),
                    ),
                    GButton(
                      icon: Icons.cast_for_education_outlined,
                      iconSize: 22,
                      text: 'تدريباتي',
                      padding: EdgeInsets.all(8),
                    ),
                    GButton(
                      icon: Icons.person_rounded,
                      iconSize: 22,
                      text: 'حسابي',
                      padding: EdgeInsets.all(8),
                    ),
                  ],
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
