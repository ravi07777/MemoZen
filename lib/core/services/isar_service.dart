import 'dart:io';
import 'package:isar/isar.dart';
import '../../models/user_profile.dart';
import '../../models/topic.dart';
import '../../models/revision_event.dart';
import '../../models/study_log.dart';
import '../../models/subject_group.dart';
import '../../models/app_settings.dart';

class IsarService {
  late Isar isar;

  Future<void> init() async {
    final dir = Directory('${Platform.environment['HOME'] ?? '/tmp'}/.memozen');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    isar = await Isar.open(
      [
        UserProfileSchema,
        TopicSchema,
        RevisionEventSchema,
        StudyLogSchema,
        SubjectGroupSchema,
        AppSettingsSchema,
      ],
      directory: dir.path,
    );
  }

  Future<UserProfile?> getProfile() async {
    final profiles = await isar.userProfiles.where().findAll();
    return profiles.isNotEmpty ? profiles.first : null;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await isar.writeTxn(() async {
      final existing = await isar.userProfiles.where().findAll();
      if (existing.isNotEmpty) {
        profile.id = existing.first.id;
      }
      await isar.userProfiles.put(profile);
    });
  }

  Future<List<Topic>> getTopics() async {
    return isar.topics.where().findAll();
  }

  Future<List<Topic>> getTopicsBySubject(String subject) async {
    return isar.topics.where().subjectGroupEqualTo(subject).findAll();
  }

  Future<void> saveTopic(Topic topic) async {
    await isar.writeTxn(() async {
      await isar.topics.put(topic);
    });
  }

  Future<void> deleteTopic(int id) async {
    await isar.writeTxn(() async {
      await isar.revisionEvents.where().topicIdEqualTo(id).deleteAll();
      await isar.topics.delete(id);
    });
  }

  Future<List<RevisionEvent>> getRevisionEvents() async {
    return isar.revisionEvents.where().findAll();
  }

  Future<List<RevisionEvent>> getRevisionEventsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return isar.revisionEvents
        .where()
        .dueDateBetween(start, end)
        .findAll();
  }

  Future<List<RevisionEvent>> getUpcomingEvents() async {
    final now = DateTime.now();
    return isar.revisionEvents
        .where()
        .filter()
        .statusEqualTo(RevisionStatus.upcoming)
        .dueDateGreaterThan(now)
        .findAll();
  }

  Future<List<RevisionEvent>> getMissedEvents() async {
    final now = DateTime.now();
    return isar.revisionEvents
        .where()
        .filter()
        .statusEqualTo(RevisionStatus.upcoming)
        .dueDateLessThan(now)
        .findAll();
  }

  Future<List<RevisionEvent>> getTodayEvents() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return isar.revisionEvents
        .where()
        .filter()
        .statusEqualTo(RevisionStatus.upcoming)
        .dueDateBetween(start, end)
        .findAll();
  }

  Future<void> saveRevisionEvent(RevisionEvent event) async {
    await isar.writeTxn(() async {
      await isar.revisionEvents.put(event);
    });
  }

  Future<void> markRevisionCompleted(int eventId) async {
    await isar.writeTxn(() async {
      final event = await isar.revisionEvents.get(eventId);
      if (event != null) {
        event.status = RevisionStatus.completed;
        event.completedAt = DateTime.now();
        await isar.revisionEvents.put(event);
      }
    });
  }

  Future<void> markRevisionMissed(int eventId) async {
    await isar.writeTxn(() async {
      final event = await isar.revisionEvents.get(eventId);
      if (event != null) {
        event.status = RevisionStatus.missed;
        await isar.revisionEvents.put(event);
      }
    });
  }

  Future<void> deleteRevisionEventsForTopic(int topicId) async {
    await isar.writeTxn(() async {
      await isar.revisionEvents.where().topicIdEqualTo(topicId).deleteAll();
    });
  }

  Future<List<StudyLog>> getStudyLogs() async {
    return isar.studyLogs.where().findAll();
  }

  Future<List<StudyLog>> getStudyLogsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return isar.studyLogs
        .where()
        .startTimeBetween(start, end)
        .findAll();
  }

  Future<List<StudyLog>> getStudyLogsForRange(DateTime start, DateTime end) async {
    return isar.studyLogs
        .where()
        .startTimeBetween(start, end)
        .findAll();
  }

  Future<void> saveStudyLog(StudyLog log) async {
    await isar.writeTxn(() async {
      await isar.studyLogs.put(log);
    });
  }

  Future<void> deleteStudyLog(int id) async {
    await isar.writeTxn(() async {
      await isar.studyLogs.delete(id);
    });
  }

  Future<List<SubjectGroup>> getSubjectGroups() async {
    return isar.subjectGroups.where().findAll();
  }

  Future<void> saveSubjectGroup(SubjectGroup group) async {
    await isar.writeTxn(() async {
      await isar.subjectGroups.put(group);
    });
  }

  Future<AppSettings?> getSettings() async {
    final settings = await isar.appSettings.where().findAll();
    return settings.isNotEmpty ? settings.first : null;
  }

  Future<void> saveSettings(AppSettings settings) async {
    await isar.writeTxn(() async {
      final existing = await isar.appSettings.where().findAll();
      if (existing.isNotEmpty) {
        settings.id = existing.first.id;
      }
      await isar.appSettings.put(settings);
    });
  }

  Future<String> exportBackup() async {
    final topics = await getTopics();
    final events = await getRevisionEvents();
    final logs = await getStudyLogs();
    final backup = {
      'topics': topics.map((t) => t.toJson()).toList(),
      'events': events.map((e) => e.toJson()).toList(),
      'logs': logs.map((l) => l.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    return backup.toString();
  }

  Future<void> importBackup(String data) async {
    // Implementation would parse JSON and restore data
  }

  Future<void> generateRevisionEvents(Topic topic) async {
    final days = topic.cycleDays;
    await deleteRevisionEventsForTopic(topic.id);
    for (var i = 0; i < days.length; i++) {
      final dueDate = topic.studiedOn.add(Duration(days: days[i]));
      final event = RevisionEvent(
        topicId: topic.id,
        topicTitle: topic.title,
        subjectGroup: topic.subjectGroup,
        dueDate: dueDate,
        cycleDay: days[i],
        status: dueDate.isBefore(DateTime.now())
            ? RevisionStatus.missed
            : RevisionStatus.upcoming,
      );
      await saveRevisionEvent(event);
    }
  }
}
