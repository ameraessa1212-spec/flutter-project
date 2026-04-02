class DiscussionSchedule {
  const DiscussionSchedule({
    required this.id,
    required this.title,
    this.description,
    this.academicTerm,
    this.scheduleFilePath,
    this.scheduleImagePath,
    this.publishedAt,
    required this.isActive,
    this.specializationName,
  });

  final int id;
  final String title;
  final String? description;
  final String? academicTerm;
  final String? scheduleFilePath;
  final String? scheduleImagePath;
  final String? publishedAt;
  final bool isActive;
  final String? specializationName;

  factory DiscussionSchedule.fromJson(Map<String, dynamic> json) {
    final spec = json['specialization'] as Map<String, dynamic>?;
    return DiscussionSchedule(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      academicTerm: json['academic_term'] as String?,
      scheduleFilePath: json['schedule_file_path'] as String?,
      scheduleImagePath: json['schedule_image_path'] as String?,
      publishedAt: json['published_at'] as String?,
      isActive: (json['is_active'] ?? false) as bool,
      specializationName: spec?['name'] as String?,
    );
  }
}
