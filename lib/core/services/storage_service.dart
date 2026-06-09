import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../../models/topic.dart';
import '../../models/revision_event.dart';
import '../../models/study_log.dart';
import '../../models/subject_group.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  late String _baseDir;

  Future<void> init() async {
    _baseDir = '${Platform.environment['HOME'] ?? '/tmp'}/.memozen/data';
    final dir = Directory(_baseDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  String _filePath(String name) => '$_baseDir/$name.json';

  Future<T?> _readJson<T>(String name, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final file = File(_filePath(name));
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<List<T>> _readJsonList<T>(String name, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final file = File(_filePath(name));
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final list = jsonDecode(content) as List<dynamic>;
      return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeJson(String name, dynamic data) async {
    final file = File(_filePath(name));
    await file.writeAsString(jsonEncode(data));
  }

  int _nextId<T>(List<T> items, int Function(T) getId) {
    if (items.isEmpty) return 1;
    return items.map(getId).reduce((a, b) => a > b ? a : b) + 1;
  }

  // User Profile
  Future<UserProfile?> getProfile() => _readJson('profile', UserProfile.fromJson);

  Future<void> saveProfile(UserProfile profile) => _writeJson('profile', profile.toJson());

  // Topics
  Future<List<Topic>> getTopics() => _readJsonList('topics', Topic.fromJson);

  Future<List<Topic>> getTopicsBySubject(String subject) async {
    final topics = await getTopics();
    return topics.where((t) => t.subjectGroup == subject).toList();
  }

  Future<void> saveTopic(Topic topic) async {
    final topics = await getTopics();
    final index = topics.indexWhere((t) => t.id == topic.id);
    if (index >= 0) {
      topics[index] = topic;
    } else {
      final newTopic = topic.copyWith(id: _nextId(topics, (t) => t.id));
      topics.add(newTopic);
    }
    await _writeJson('topics', topics.map((t) => t.toJson()).toList());
  }

  Future<void> deleteTopic(int id) async {
    final topics = await getTopics();
    topics.removeWhere((t) => t.id == id);
    await _writeJson('topics', topics.map((t) => t.toJson()).toList());
    final events = await getRevisionEvents();
    events.removeWhere((e) => e.topicId == id);
    await _writeJson('revisionEvents', events.map((e) => e.toJson()).toList());
  }

  // Revision Events
  Future<List<RevisionEvent>> getRevisionEvents() => _readJsonList('revisionEvents', RevisionEvent.fromJson);

  Future<List<RevisionEvent>> getRevisionEventsForDate(DateTime date) async {
    final events = await getRevisionEvents();
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return events.where((e) => e.dueDate.isAfter(start) && e.dueDate.isBefore(end)).toList();
  }

  Future<List<RevisionEvent>> getUpcomingEvents() async {
    final now = DateTime.now();
    final events = await getRevisionEvents();
    return events.where((e) => e.status == RevisionStatus.upcoming && e.dueDate.isAfter(now)).toList();
  }

  Future<List<RevisionEvent>> getMissedEvents() async {
    final now = DateTime.now();
    final events = await getRevisionEvents();
    return events.where((e) => e.status == RevisionStatus.upcoming && e.dueDate.isBefore(now)).toList();
  }

  Future<List<RevisionEvent>> getTodayEvents() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final events = await getRevisionEvents();
    return events.where((e) =>
        e.status == RevisionStatus.upcoming &&
        e.dueDate.isAfter(start) &&
        e.dueDate.isBefore(end)).toList();
  }

  Future<void> saveRevisionEvent(RevisionEvent event) async {
    final events = await getRevisionEvents();
    final index = events.indexWhere((e) => e.id == event.id);
    if (index >= 0) {
      events[index] = event;
    } else {
      events.add(event.copyWith(id: _nextId(events, (e) => e.id)));
    }
    await _writeJson('revisionEvents', events.map((e) => e.toJson()).toList());
  }

  Future<void> markRevisionCompleted(int eventId) async {
    final events = await getRevisionEvents();
    final index = events.indexWhere((e) => e.id == eventId);
    if (index >= 0) {
      events[index] = events[index].copyWith(
        status: RevisionStatus.completed,
        completedAt: DateTime.now(),
      );
      await _writeJson('revisionEvents', events.map((e) => e.toJson()).toList());
    }
  }

  Future<void> markRevisionMissed(int eventId) async {
    final events = await getRevisionEvents();
    final index = events.indexWhere((e) => e.id == eventId);
    if (index >= 0) {
      events[index] = events[index].copyWith(status: RevisionStatus.missed);
      await _writeJson('revisionEvents', events.map((e) => e.toJson()).toList());
    }
  }

  Future<void> deleteRevisionEventsForTopic(int topicId) async {
    final events = await getRevisionEvents();
    events.removeWhere((e) => e.topicId == topicId);
    await _writeJson('revisionEvents', events.map((e) => e.toJson()).toList());
  }

  // Study Logs
  Future<List<StudyLog>> getStudyLogs() => _readJsonList('studyLogs', StudyLog.fromJson);

  Future<List<StudyLog>> getStudyLogsForDate(DateTime date) async {
    final logs = await getStudyLogs();
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return logs.where((l) => l.startTime.isAfter(start) && l.startTime.isBefore(end)).toList();
  }

  Future<List<StudyLog>> getStudyLogsForRange(DateTime start, DateTime end) async {
    final logs = await getStudyLogs();
    return logs.where((l) => l.startTime.isAfter(start) && l.startTime.isBefore(end)).toList();
  }

  Future<void> saveStudyLog(StudyLog log) async {
    final logs = await getStudyLogs();
    final index = logs.indexWhere((l) => l.id == log.id);
    if (index >= 0) {
      logs[index] = log;
    } else {
      logs.add(log.copyWith(id: _nextId(logs, (l) => l.id)));
    }
    await _writeJson('studyLogs', logs.map((l) => l.toJson()).toList());
  }

  Future<void> deleteStudyLog(int id) async {
    final logs = await getStudyLogs();
    logs.removeWhere((l) => l.id == id);
    await _writeJson('studyLogs', logs.map((l) => l.toJson()).toList());
  }

  // Subject Groups
  Future<List<SubjectGroup>> getSubjectGroups() => _readJsonList('subjectGroups', SubjectGroup.fromJson);

  Future<void> saveSubjectGroup(SubjectGroup group) async {
    final groups = await getSubjectGroups();
    groups.add(SubjectGroup(id: _nextId(groups, (g) => g.id), name: group.name, iconName: group.iconName, createdAt: group.createdAt, isExpanded: group.isExpanded));
    await _writeJson('subjectGroups', groups.map((g) => g.toJson()).toList());
  }

  // Revision event generation
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
