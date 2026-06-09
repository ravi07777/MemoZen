class AppSettings {
  final int id;
  final bool notificationsEnabled;
  final DateTime? dailyReminderTime;
  final bool dailyReminderEnabled;
  final bool missedReminderEnabled;
  final bool studyReminderEnabled;
  final int themeIndex;
  final String themeMode;
  final String? language;

  AppSettings({
    this.id = 0,
    this.notificationsEnabled = true,
    this.dailyReminderTime,
    this.dailyReminderEnabled = false,
    this.missedReminderEnabled = true,
    this.studyReminderEnabled = true,
    this.themeIndex = 0,
    this.themeMode = 'light',
    this.language,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'notificationsEnabled': notificationsEnabled,
        'dailyReminderTime': dailyReminderTime?.toIso8601String(),
        'dailyReminderEnabled': dailyReminderEnabled,
        'missedReminderEnabled': missedReminderEnabled,
        'studyReminderEnabled': studyReminderEnabled,
        'themeIndex': themeIndex,
        'themeMode': themeMode,
        'language': language,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        id: json['id'] as int? ?? 0,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        dailyReminderTime: json['dailyReminderTime'] != null ? DateTime.parse(json['dailyReminderTime'] as String) : null,
        dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? false,
        missedReminderEnabled: json['missedReminderEnabled'] as bool? ?? true,
        studyReminderEnabled: json['studyReminderEnabled'] as bool? ?? true,
        themeIndex: json['themeIndex'] as int? ?? 0,
        themeMode: json['themeMode'] as String? ?? 'light',
        language: json['language'] as String?,
      );
}
