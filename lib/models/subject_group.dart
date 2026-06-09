class SubjectGroup {
  final int id;
  final String name;
  final String? iconName;
  final DateTime createdAt;
  final bool isExpanded;

  SubjectGroup({
    this.id = 0,
    required this.name,
    this.iconName,
    DateTime? createdAt,
    this.isExpanded = true,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'createdAt': createdAt.toIso8601String(),
        'isExpanded': isExpanded,
      };

  factory SubjectGroup.fromJson(Map<String, dynamic> json) => SubjectGroup(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        iconName: json['iconName'] as String?,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
        isExpanded: json['isExpanded'] as bool? ?? true,
      );
}
