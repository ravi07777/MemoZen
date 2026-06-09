import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = Isar.autoIncrement;

  bool notificationsEnabled = true;
  DateTime? dailyReminderTime;
  bool dailyReminderEnabled = false;
  bool missedReminderEnabled = true;
  bool studyReminderEnabled = true;
  int themeIndex = 0;
  String themeMode = 'light';
  String? language;

  AppSettings();
}
