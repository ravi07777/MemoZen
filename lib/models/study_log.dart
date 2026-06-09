class StudyLog {
  final int id;
  final int? topicId;
  final String? topicTitle;
  final String? subjectGroup;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final String? notes;
  final DateTime createdAt;

  StudyLog({
    this.id = 0,
    this.topicId,
    this.topicTitle,
    this.subjectGroup,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  StudyLog copyWith({
    int? id,
    int? topicId,
    String? topicTitle,
    String? subjectGroup,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? notes,
    DateTime? createdAt,
  }) {
    return StudyLog(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      topicTitle: topicTitle ?? this.topicTitle,
      subjectGroup: subjectGroup ?? this.subjectGroup,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'topicTitle': topicTitle,
        'subjectGroup': subjectGroup,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'durationMinutes': durationMinutes,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StudyLog.fromJson(Map<String, dynamic> json) => StudyLog(
        id: json['id'] as int? ?? 0,
        topicId: json['topicId'] as int?,
        topicTitle: json['topicTitle'] as String?,
        subjectGroup: json['subjectGroup'] as String?,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      );
}
