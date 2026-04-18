import 'package:Waslaa/features/opportunities/models/opportunity.dart';

class Application {
  const Application({
    required this.id,
    required this.status,
    this.fullNameSnapshot,
    this.phoneSnapshot,
    this.emailSnapshot,
    this.universitySnapshot,
    this.majorSnapshot,
    this.levelSnapshot,
    this.cvFileUrl,
    this.notes,
    this.submittedAt,
    this.reviewedAt,
    this.reviewNotes,
    this.company,
    this.opportunity,
  });

  final int id;
  final String status;
  final String? fullNameSnapshot;
  final String? phoneSnapshot;
  final String? emailSnapshot;
  final String? universitySnapshot;
  final String? majorSnapshot;
  final String? levelSnapshot;
  final String? cvFileUrl;
  final String? notes;
  final String? submittedAt;
  final String? reviewedAt;
  final String? reviewNotes;
  final OpportunityCompany? company;
  final Opportunity? opportunity;

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as int,
      status: (json['status'] ?? '') as String,
      fullNameSnapshot: json['full_name_snapshot'] as String?,
      phoneSnapshot: json['phone_snapshot'] as String?,
      emailSnapshot: json['email_snapshot'] as String?,
      universitySnapshot: json['university_snapshot'] as String?,
      majorSnapshot: json['major_snapshot'] as String?,
      levelSnapshot: json['level_snapshot'] as String?,
      cvFileUrl: json['cv_file_url'] as String?,
      notes: json['notes'] as String?,
      submittedAt: json['submitted_at'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      reviewNotes: json['review_notes'] as String?,
      company:
          json['company'] != null
              ? OpportunityCompany.fromJson(
                json['company'] as Map<String, dynamic>,
              )
              : null,
      opportunity:
          json['opportunity'] != null
              ? Opportunity.fromJson(
                json['opportunity'] as Map<String, dynamic>,
              )
              : null,
    );
  }
}
