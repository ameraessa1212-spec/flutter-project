import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Waslaa/const/app_dimensions.dart';
import 'package:Waslaa/const/color.dart';
import 'package:Waslaa/features/dashboard/models/home_dashboard.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageSliderScreen extends StatefulWidget {
  final List<DashboardContentItem> items;

  const ImageSliderScreen({super.key, required this.items});

  @override
  State<ImageSliderScreen> createState() => _ImageSliderScreenState();
}

class _ImageSliderScreenState extends State<ImageSliderScreen> {
  final PageController _pageCtrl = PageController();

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

      final items = widget.items;
      if (items.isEmpty) return;

      currentPage++;

      if (currentPage >= items.length) {
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
    final items = widget.items;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

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
                itemCount: items.length,
                itemBuilder:
                    (_, i) {
                      final item = items[i];
                      final imageAsset = item.imageAsset;
                      final imageUrl = item.imageUrl;
                      return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl != null && imageUrl.isNotEmpty)
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primarycolor, primarycolor.withValues(alpha: 0.72)],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                  ),
                                ),
                              )
                            else if (imageAsset != null && imageAsset.isNotEmpty)
                              Image.asset(
                                imageAsset,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primarycolor, primarycolor.withValues(alpha: 0.72)],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  ),
                                ),
                              ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.72),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 20,
                              left: 20,
                              bottom: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                  ),
                                  if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      item.subtitle!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12.5,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    },
              ),
            ),
          ),
          const SizedBox(height: 10),
          SmoothPageIndicator(
            controller: _pageCtrl,
            count: items.length,
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
