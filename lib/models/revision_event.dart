enum RevisionStatus { upcoming, completed, missed }

class RevisionEvent {
  final int id;
  final int topicId;
  final String topicTitle;
  final String? subjectGroup;
  final DateTime dueDate;
  final DateTime? completedAt;
  final RevisionStatus status;
  final int cycleDay;

  RevisionEvent({
    this.id = 0,
    required this.topicId,
    required this.topicTitle,
    this.subjectGroup,
    required this.dueDate,
    this.completedAt,
    this.status = RevisionStatus.upcoming,
    required this.cycleDay,
  });

  RevisionEvent copyWith({
    int? id,
    int? topicId,
    String? topicTitle,
    String? subjectGroup,
    DateTime? dueDate,
    DateTime? completedAt,
    RevisionStatus? status,
    int? cycleDay,
  }) {
    return RevisionEvent(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      topicTitle: topicTitle ?? this.topicTitle,
      subjectGroup: subjectGroup ?? this.subjectGroup,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      cycleDay: cycleDay ?? this.cycleDay,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'topicTitle': topicTitle,
        'subjectGroup': subjectGroup,
        'dueDate': dueDate.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'status': status.name,
        'cycleDay': cycleDay,
      };

  factory RevisionEvent.fromJson(Map<String, dynamic> json) => RevisionEvent(
        id: json['id'] as int? ?? 0,
        topicId: json['topicId'] as int? ?? 0,
        topicTitle: json['topicTitle'] as String? ?? '',
        subjectGroup: json['subjectGroup'] as String?,
        dueDate: DateTime.parse(json['dueDate'] as String),
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
        status: RevisionStatus.values.firstWhere((s) => s.name == json['status'] as String? ?? 'upcoming'),
        cycleDay: json['cycleDay'] as int? ?? 1,
      );
}
