import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shadaa/const/app_dimensions.dart';
import 'package:shadaa/const/color.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageSliderScreen extends StatefulWidget {
  const ImageSliderScreen({super.key});

  @override
  State<ImageSliderScreen> createState() => _ImageSliderScreenState();
}

class _ImageSliderScreenState extends State<ImageSliderScreen> {
  final PageController _pageCtrl = PageController();

  final List<String> images = [
    'assets/images/madar.JPG',
    'assets/images/libyana.JPG',
  ];

  Timer? _timer;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    startAutoSlide();
  }

  void startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_pageCtrl.hasClients) return;

      currentPage++;

      if (currentPage >= images.length) {
        currentPage = 0;
      }

      _pageCtrl.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: AppDimensions.screenHeight * 0.40,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: images.length,
                itemBuilder:
                    (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          images[i],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SmoothPageIndicator(
            controller: _pageCtrl,
            count: images.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: primarycolor,
              dotColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
