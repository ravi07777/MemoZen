import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  String? name;
  String? email;
  String? avatarUrl;
  DateTime? createdAt;
  DateTime? lastLoginAt;
  int studyStreak = 0;
  DateTime? lastStudyDate;
  int totalStudyMinutes = 0;

  UserProfile({
    this.name,
    this.email,
    this.avatarUrl,
    this.createdAt,
    this.lastLoginAt,
    this.studyStreak = 0,
    this.lastStudyDate,
    this.totalStudyMinutes = 0,
  });
}
