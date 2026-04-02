class ChatAttachment {
  const ChatAttachment({
    this.id,
    this.messageId,
    this.filePath,
    this.fileName,
    this.fileType,
    this.fileSize,
    this.fileUrl,
  });

  final dynamic id;
  final dynamic messageId;
  final String? filePath;
  final String? fileName;
  final String? fileType;
  final int? fileSize;
  final String? fileUrl;

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      id: json['id'],
      messageId: json['message_id'],
      filePath: json['file_path'] as String?,
      fileName: json['file_name'] as String?,
      fileType: json['file_type'] as String?,
      fileSize: json['file_size'] as int?,
      fileUrl: json['file_url'] as String?,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    this.threadId,
    required this.senderId,
    this.fromId,
    this.toId,
    required this.messageType,
    this.body,
    this.sentAt,
    this.readAt,
    this.createdAt,
    this.attachments = const [],
  });

  final dynamic id;
  final int? threadId;
  final int senderId;
  final int? fromId;
  final int? toId;
  final String messageType;
  final String? body;
  final String? sentAt;
  final String? readAt;
  final String? createdAt;
  final List<ChatAttachment> attachments;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final attachmentsRaw = json['attachments'] as List<dynamic>?;
    return ChatMessage(
      id: json['id'],
      threadId: json['thread_id'] as int?,
      senderId: (json['sender_id'] ?? json['from_id'] ?? 0) as int,
      fromId: json['from_id'] as int?,
      toId: json['to_id'] as int?,
      messageType: (json['message_type'] ?? 'text') as String,
      body: json['body'] as String?,
      sentAt: (json['sent_at'] ?? json['created_at']) as String?,
      readAt: (json['read_at'] ?? json['updated_at']) as String?,
      createdAt: json['created_at'] as String?,
      attachments:
          attachmentsRaw
              ?.map((a) => ChatAttachment.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChatThread {
  const ChatThread({
    required this.id,
    required this.internshipId,
    required this.studentId,
    required this.supervisorId,
    required this.status,
    this.lastMessageAt,
    this.supervisorName,
    this.supervisorPhone,
    this.supervisorEmail,
    this.internshipTitle,
    this.companyName,
  });

  final int id;
  final int internshipId;
  final int studentId;
  final int supervisorId;
  final String status;
  final String? lastMessageAt;
  final String? supervisorName;
  final String? supervisorPhone;
  final String? supervisorEmail;
  final String? internshipTitle;
  final String? companyName;

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    final supervisor = json['supervisor'] as Map<String, dynamic>?;
    final internship = json['internship'] as Map<String, dynamic>?;
    final company = internship?['company'] as Map<String, dynamic>?;
    return ChatThread(
      id: json['id'] as int,
      internshipId: json['internship_id'] as int,
      studentId: json['student_id'] as int,
      supervisorId: json['supervisor_id'] as int,
      status: (json['status'] ?? '') as String,
      lastMessageAt: json['last_message_at'] as String?,
      supervisorName: supervisor?['name'] as String?,
      supervisorPhone: supervisor?['phone'] as String?,
      supervisorEmail: supervisor?['email'] as String?,
      internshipTitle: internship?['title'] as String?,
      companyName: company?['name'] as String?,
    );
  }
}
