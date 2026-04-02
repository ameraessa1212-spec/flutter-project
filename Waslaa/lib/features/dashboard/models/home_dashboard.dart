import 'package:Waslaa/features/internships/models/internship.dart';
import 'package:Waslaa/features/opportunities/models/opportunity.dart';

class DashboardContentItem {
  const DashboardContentItem({
    required this.title,
    this.subtitle,
    this.imageAsset,
    this.imageUrl,
    this.iconKey,
    this.badge,
  });

  final String title;
  final String? subtitle;
  final String? imageAsset;
  final String? imageUrl;
  final String? iconKey;
  final String? badge;

  factory DashboardContentItem.fromJson(Map<String, dynamic> json) {
    return DashboardContentItem(
      title: (json['title'] ?? '') as String,
      subtitle: json['subtitle'] as String?,
      imageAsset: json['image_asset'] as String?,
      imageUrl: json['image_url'] as String?,
      iconKey: json['icon_key'] as String?,
      badge: json['badge'] as String?,
    );
  }
}

class HomeDashboard {
  const HomeDashboard({
    required this.applicationsCount,
    required this.unreadNotificationsCount,
    required this.unreadMessagesCount,
    this.currentInternship,
    this.featuredOpportunities = const [],
    this.sliderItems = const [],
    this.tipCards = const [],
    this.announcements = const [],
  });

  final int applicationsCount;
  final int unreadNotificationsCount;
  final int unreadMessagesCount;
  final Internship? currentInternship;
  final List<Opportunity> featuredOpportunities;
  final List<DashboardContentItem> sliderItems;
  final List<DashboardContentItem> tipCards;
  final List<DashboardContentItem> announcements;

  factory HomeDashboard.fromJson(Map<String, dynamic> json) {
    final featuredRaw = json['featured_opportunities'] as List<dynamic>?;
    final sliderRaw = json['slider_items'] as List<dynamic>?;
    final tipsRaw = json['tip_cards'] as List<dynamic>?;
    final announcementsRaw = json['announcements'] as List<dynamic>?;
    return HomeDashboard(
      applicationsCount: (json['applications_count'] ?? 0) as int,
      unreadNotificationsCount:
          (json['unread_notifications_count'] ?? 0) as int,
      unreadMessagesCount: (json['unread_messages_count'] ?? 0) as int,
      currentInternship:
          json['current_internship'] != null
              ? Internship.fromJson(
                json['current_internship'] as Map<String, dynamic>,
              )
              : null,
      featuredOpportunities:
          featuredRaw
              ?.map(
                (item) => Opportunity.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      sliderItems:
          sliderRaw
              ?.map(
                (item) =>
                    DashboardContentItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      tipCards:
          tipsRaw
              ?.map(
                (item) =>
                    DashboardContentItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      announcements:
          announcementsRaw
              ?.map(
                (item) =>
                    DashboardContentItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }
}
