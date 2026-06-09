import 'package:isar/isar.dart';

part 'topic.g.dart';

@collection
class Topic {
  Id id = Isar.autoIncrement;

  String title;
  String? subjectGroup;
  String? notes;
  List<String> tags = [];
  DateTime createdAt;
  DateTime studiedOn;
  int revisionCycleDay1 = 1;
  int revisionCycleDay2 = 7;
  int revisionCycleDay3 = 30;
  int revisionCycleDay4 = 90;
  bool useCustomCycle = false;
  List<int> customCycleDays = [];
  double progress = 0.0;
  int revisionCount = 0;
  DateTime? lastRevisedAt;
  DateTime? nextRevisionAt;

  Topic({
    required this.title,
    this.subjectGroup,
    this.notes,
    this.tags = const [],
    DateTime? createdAt,
    DateTime? studiedOn,
    this.revisionCycleDay1 = 1,
    this.revisionCycleDay2 = 7,
    this.revisionCycleDay3 = 30,
    this.revisionCycleDay4 = 90,
    this.useCustomCycle = false,
    this.customCycleDays = const [],
    this.progress = 0.0,
    this.revisionCount = 0,
    this.lastRevisedAt,
    this.nextRevisionAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        studiedOn = studiedOn ?? DateTime.now();

  List<int> get cycleDays {
    if (useCustomCycle && customCycleDays.isNotEmpty) {
      return customCycleDays;
    }
    return [revisionCycleDay1, revisionCycleDay2, revisionCycleDay3, revisionCycleDay4];
  }

  int get totalRevisionsNeeded => cycleDays.length;

  bool get isComplete => progress >= 1.0;
}
