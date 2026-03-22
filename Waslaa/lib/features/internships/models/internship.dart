import 'package:Waslaa/features/opportunities/models/opportunity.dart';

class InternshipSupervisor {
  const InternshipSupervisor({
    required this.id,
    required this.name,
    this.phone,
    this.email,
  });

  final int id;
  final String name;
  final String? phone;
  final String? email;

  factory InternshipSupervisor.fromJson(Map<String, dynamic> json) {
    return InternshipSupervisor(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }
}

class TimelineItem {
  const TimelineItem({
    required this.key,
    required this.status,
    this.date,
  });

  final String key;
  final String status;
  final String? date;

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      key: (json['key'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      date: json['date'] as String?,
    );
  }
}

class Internship {
  const Internship({
    required this.id,
    required this.title,
    required this.status,
    this.startDate,
    this.endDate,
    this.reportDueDate,
    this.notes,
    this.company,
    this.opportunity,
    this.supervisor,
  });

  final int id;
  final String title;
  final String status;
  final String? startDate;
  final String? endDate;
  final String? reportDueDate;
  final String? notes;
  final OpportunityCompany? company;
  final Opportunity? opportunity;
  final InternshipSupervisor? supervisor;

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      reportDueDate: json['report_due_date'] as String?,
      notes: json['notes'] as String?,
      company: json['company'] != null
          ? OpportunityCompany.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      opportunity: json['opportunity'] != null
          ? Opportunity.fromJson(json['opportunity'] as Map<String, dynamic>)
          : null,
      supervisor: json['supervisor'] != null
          ? InternshipSupervisor.fromJson(json['supervisor'] as Map<String, dynamic>)
          : null,
    );
  }
}
