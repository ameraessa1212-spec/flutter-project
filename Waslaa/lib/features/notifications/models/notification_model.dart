class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.referenceType,
    this.referenceId,
    required this.isRead,
    this.readAt,
    this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String? type;
  final String? referenceType;
  final int? referenceId;
  final bool isRead;
  final String? readAt;
  final String? createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      body: (json['body'] ?? '') as String,
      type: json['type'] as String?,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as int?,
      isRead: (json['is_read'] ?? false) as bool,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  AppNotification copyWith({bool? isRead, String? readAt}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      referenceType: referenceType,
      referenceId: referenceId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }
}
