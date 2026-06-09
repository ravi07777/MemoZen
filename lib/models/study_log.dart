import 'package:isar/isar.dart';

part 'study_log.g.dart';

@collection
class StudyLog {
  Id id = Isar.autoIncrement;

  int? topicId;
  String? topicTitle;
  String? subjectGroup;
  DateTime startTime;
  DateTime endTime;
  int durationMinutes;
  String? notes;
  DateTime createdAt;

  StudyLog({
    this.topicId,
    this.topicTitle,
    this.subjectGroup,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
