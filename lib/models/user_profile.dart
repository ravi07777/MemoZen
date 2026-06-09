class UserProfile {
  final int id;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final int studyStreak;
  final DateTime? lastStudyDate;
  final int totalStudyMinutes;

  UserProfile({
    this.id = 0,
    this.name,
    this.email,
    this.avatarUrl,
    this.createdAt,
    this.lastLoginAt,
    this.studyStreak = 0,
    this.lastStudyDate,
    this.totalStudyMinutes = 0,
  });

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? studyStreak,
    DateTime? lastStudyDate,
    int? totalStudyMinutes,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      studyStreak: studyStreak ?? this.studyStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt?.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
        'studyStreak': studyStreak,
        'lastStudyDate': lastStudyDate?.toIso8601String(),
        'totalStudyMinutes': totalStudyMinutes,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String?,
        email: json['email'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt'] as String) : null,
        studyStreak: json['studyStreak'] as int? ?? 0,
        lastStudyDate: json['lastStudyDate'] != null ? DateTime.parse(json['lastStudyDate'] as String) : null,
        totalStudyMinutes: json['totalStudyMinutes'] as int? ?? 0,
      );
}
