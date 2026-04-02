import 'package:flutter/material.dart';

class AppDimensions {
  static late double screenWidth;
  static late double screenHeight;

  static void initialize(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
  }

  // Border radius
  static const double radiusSmall = 14.0;
  static const double radiusMedium = 18.0;
  static const double radiusLarge = 22.0;
  static const double radiusXL = 24.0;

  // Padding / Spacing
  static const double paddingSmallX = 5.0;
  static const double paddingSmall = 8.0;
  static const double paddingMediumX = 12.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Margin
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  // Components
  static const double buttonHeight = 52.0;
  static const double buttonRadius = 18.0;
  static const double inputHeight = 52.0;
  static const double cardPadding = 16.0;
  static const double pagePadding = 16.0;
}
