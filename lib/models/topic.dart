class Topic {
  final int id;
  final String title;
  final String? subjectGroup;
  final String? notes;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime studiedOn;
  final int revisionCycleDay1;
  final int revisionCycleDay2;
  final int revisionCycleDay3;
  final int revisionCycleDay4;
  final bool useCustomCycle;
  final List<int> customCycleDays;
  final double progress;
  final int revisionCount;
  final DateTime? lastRevisedAt;
  final DateTime? nextRevisionAt;

  Topic({
    this.id = 0,
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

  Topic copyWith({
    int? id,
    String? title,
    String? subjectGroup,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? studiedOn,
    int? revisionCycleDay1,
    int? revisionCycleDay2,
    int? revisionCycleDay3,
    int? revisionCycleDay4,
    bool? useCustomCycle,
    List<int>? customCycleDays,
    double? progress,
    int? revisionCount,
    DateTime? lastRevisedAt,
    DateTime? nextRevisionAt,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectGroup: subjectGroup ?? this.subjectGroup,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      studiedOn: studiedOn ?? this.studiedOn,
      revisionCycleDay1: revisionCycleDay1 ?? this.revisionCycleDay1,
      revisionCycleDay2: revisionCycleDay2 ?? this.revisionCycleDay2,
      revisionCycleDay3: revisionCycleDay3 ?? this.revisionCycleDay3,
      revisionCycleDay4: revisionCycleDay4 ?? this.revisionCycleDay4,
      useCustomCycle: useCustomCycle ?? this.useCustomCycle,
      customCycleDays: customCycleDays ?? this.customCycleDays,
      progress: progress ?? this.progress,
      revisionCount: revisionCount ?? this.revisionCount,
      lastRevisedAt: lastRevisedAt ?? this.lastRevisedAt,
      nextRevisionAt: nextRevisionAt ?? this.nextRevisionAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subjectGroup': subjectGroup,
        'notes': notes,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'studiedOn': studiedOn.toIso8601String(),
        'revisionCycleDay1': revisionCycleDay1,
        'revisionCycleDay2': revisionCycleDay2,
        'revisionCycleDay3': revisionCycleDay3,
        'revisionCycleDay4': revisionCycleDay4,
        'useCustomCycle': useCustomCycle,
        'customCycleDays': customCycleDays,
        'progress': progress,
        'revisionCount': revisionCount,
        'lastRevisedAt': lastRevisedAt?.toIso8601String(),
        'nextRevisionAt': nextRevisionAt?.toIso8601String(),
      };

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        subjectGroup: json['subjectGroup'] as String?,
        notes: json['notes'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        studiedOn: json['studiedOn'] != null ? DateTime.parse(json['studiedOn'] as String) : DateTime.now(),
        revisionCycleDay1: json['revisionCycleDay1'] as int? ?? 1,
        revisionCycleDay2: json['revisionCycleDay2'] as int? ?? 7,
        revisionCycleDay3: json['revisionCycleDay3'] as int? ?? 30,
        revisionCycleDay4: json['revisionCycleDay4'] as int? ?? 90,
        useCustomCycle: json['useCustomCycle'] as bool? ?? false,
        customCycleDays: (json['customCycleDays'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
        progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
        revisionCount: json['revisionCount'] as int? ?? 0,
        lastRevisedAt: json['lastRevisedAt'] != null ? DateTime.parse(json['lastRevisedAt'] as String) : null,
        nextRevisionAt: json['nextRevisionAt'] != null ? DateTime.parse(json['nextRevisionAt'] as String) : null,
      );
}
