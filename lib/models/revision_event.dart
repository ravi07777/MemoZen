import 'package:isar/isar.dart';

part 'revision_event.g.dart';

@collection
class RevisionEvent {
  Id id = Isar.autoIncrement;

  int topicId;
  String topicTitle;
  String? subjectGroup;
  DateTime dueDate;
  DateTime? completedAt;
  RevisionStatus status = RevisionStatus.upcoming;
  int cycleDay;

  RevisionEvent({
    required this.topicId,
    required this.topicTitle,
    this.subjectGroup,
    required this.dueDate,
    this.completedAt,
    this.status = RevisionStatus.upcoming,
    required this.cycleDay,
  });
}

enum RevisionStatus {
  upcoming,
  completed,
  missed,
}
