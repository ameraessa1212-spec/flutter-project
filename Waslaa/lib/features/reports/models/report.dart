class Report {
  const Report({
    required this.id,
    required this.reportType,
    required this.title,
    this.filePath,
    this.fileName,
    this.fileExtension,
    this.fileSize,
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.reviewNotes,
  });

  final int id;
  final String reportType;
  final String title;
  final String? filePath;
  final String? fileName;
  final String? fileExtension;
  final int? fileSize;
  final String status;
  final String? submittedAt;
  final String? reviewedAt;
  final String? reviewNotes;

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      reportType: (json['report_type'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      filePath: json['file_path'] as String?,
      fileName: json['file_name'] as String?,
      fileExtension: json['file_extension'] as String?,
      fileSize: json['file_size'] as int?,
      status: (json['status'] ?? '') as String,
      submittedAt: json['submitted_at'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      reviewNotes: json['review_notes'] as String?,
    );
  }
}
