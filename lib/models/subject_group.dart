import 'package:isar/isar.dart';

part 'subject_group.g.dart';

@collection
class SubjectGroup {
  Id id = Isar.autoIncrement;

  String name;
  String? iconName;
  DateTime createdAt;
  bool isExpanded = true;

  SubjectGroup({
    required this.name,
    this.iconName,
    DateTime? createdAt,
    this.isExpanded = true,
  }) : createdAt = createdAt ?? DateTime.now();
}
