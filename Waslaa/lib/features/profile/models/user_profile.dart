class UserProfile {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.studentProfile,
    this.settings,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String role;
  final String status;
  final StudentProfile? studentProfile;
  final UserSettings? settings;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      firstName: (json['first_name'] ?? '') as String,
      lastName: (json['last_name'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      role: (json['role'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      studentProfile:
          json['student_profile'] != null
              ? StudentProfile.fromJson(
                json['student_profile'] as Map<String, dynamic>,
              )
              : null,
      settings:
          json['settings'] != null
              ? UserSettings.fromJson(json['settings'] as Map<String, dynamic>)
              : null,
    );
  }
}

class StudentProfile {
  const StudentProfile({
    required this.id,
    this.universityName,
    this.studentNumber,
    this.studyLevel,
    this.bio,
    this.profileImagePath,
    this.cvFilePath,
    this.expectedGraduationAt,
    this.specializationName,
  });

  final int id;
  final String? universityName;
  final String? studentNumber;
  final String? studyLevel;
  final String? bio;
  final String? profileImagePath;
  final String? cvFilePath;
  final String? expectedGraduationAt;
  final String? specializationName;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    final spec = json['specialization'] as Map<String, dynamic>?;
    return StudentProfile(
      id: json['id'] as int,
      universityName: json['university_name'] as String?,
      studentNumber: json['student_number'] as String?,
      studyLevel: json['study_level'] as String?,
      bio: json['bio'] as String?,
      profileImagePath: json['profile_image_path'] as String?,
      cvFilePath: json['cv_file_path'] as String?,
      expectedGraduationAt: json['expected_graduation_at'] as String?,
      specializationName: spec?['name'] as String?,
    );
  }
}

class UserSettings {
  const UserSettings({
    required this.id,
    required this.language,
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.chatNotificationsEnabled,
    required this.theme,
  });

  final int id;
  final String language;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool chatNotificationsEnabled;
  final String theme;

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      id: json['id'] as int,
      language: (json['language'] ?? 'ar') as String,
      pushNotificationsEnabled:
          (json['push_notifications_enabled'] ?? true) as bool,
      emailNotificationsEnabled:
          (json['email_notifications_enabled'] ?? true) as bool,
      chatNotificationsEnabled:
          (json['chat_notifications_enabled'] ?? true) as bool,
      theme: (json['theme'] ?? 'light') as String,
    );
  }
}
