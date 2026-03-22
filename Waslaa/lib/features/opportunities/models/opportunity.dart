import 'package:Waslaa/features/auth/models/specialization.dart';

class OpportunityCompany {
  const OpportunityCompany({
    required this.id,
    required this.name,
    this.logoPath,
    this.websiteUrl,
    this.mapUrl,
    this.city,
    this.description,
    this.phone,
    this.email,
  });

  final int id;
  final String name;
  final String? logoPath;
  final String? websiteUrl;
  final String? mapUrl;
  final String? city;
  final String? description;
  final String? phone;
  final String? email;

  factory OpportunityCompany.fromJson(Map<String, dynamic> json) {
    return OpportunityCompany(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      logoPath: json['logo_path'] as String?,
      websiteUrl: json['website_url'] as String?,
      mapUrl: json['map_url'] as String?,
      city: json['city'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }
}

class Opportunity {
  const Opportunity({
    required this.id,
    required this.title,
    this.description,
    this.city,
    this.locationText,
    this.durationText,
    this.durationDays,
    this.seatsCount,
    required this.isAvailable,
    required this.status,
    this.startDate,
    this.endDate,
    this.applicationDeadline,
    this.imagePath,
    this.company,
    this.specialization,
  });

  final int id;
  final String title;
  final String? description;
  final String? city;
  final String? locationText;
  final String? durationText;
  final int? durationDays;
  final int? seatsCount;
  final bool isAvailable;
  final String status;
  final String? startDate;
  final String? endDate;
  final String? applicationDeadline;
  final String? imagePath;
  final OpportunityCompany? company;
  final Specialization? specialization;

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      city: json['city'] as String?,
      locationText: json['location_text'] as String?,
      durationText: json['duration_text'] as String?,
      durationDays: json['duration_days'] as int?,
      seatsCount: json['seats_count'] as int?,
      isAvailable: (json['is_available'] ?? false) as bool,
      status: (json['status'] ?? '') as String,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      applicationDeadline: json['application_deadline'] as String?,
      imagePath: json['image_path'] as String?,
      company: json['company'] != null
          ? OpportunityCompany.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      specialization: json['specialization'] != null
          ? Specialization.fromJson(json['specialization'] as Map<String, dynamic>)
          : null,
    );
  }
}
