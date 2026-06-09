import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../core/services/isar_service.dart';
import '../models/topic.dart';
import '../models/revision_event.dart';
import '../core/utils/helpers.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return TopicRepository(isarService);
});

class TopicRepository {
  final IsarService _isar;

  TopicRepository(this._isar);

  Future<List<Topic>> getAllTopics() => _isar.getTopics();

  Future<List<Topic>> getTopicsBySubject(String subject) =>
      _isar.getTopicsBySubject(subject);

  Future<List<String>> getSubjectGroups() async {
    final topics = await _isar.getTopics();
    final subjects = topics.map((t) => t.subjectGroup ?? 'Uncategorized').toSet();
    final groups = await _isar.getSubjectGroups();
    for (final g in groups) {
      subjects.add(g.name);
    }
    return subjects.sorted();
  }

  Future<void> addTopic(Topic topic) async {
    await _isar.saveTopic(topic);
    await _isar.generateRevisionEvents(topic);
  }

  Future<void> updateTopic(Topic topic) async {
    await _isar.saveTopic(topic);
    await _isar.generateRevisionEvents(topic);
  }

  Future<void> deleteTopic(int id) async {
    await _isar.deleteTopic(id);
  }

  Future<List<RevisionEvent>> getTodayEvents() => _isar.getTodayEvents();
  Future<List<RevisionEvent>> getUpcomingEvents() => _isar.getUpcomingEvents();
  Future<List<RevisionEvent>> getMissedEvents() => _isar.getMissedEvents();

  Future<List<RevisionEvent>> getAllEvents() => _isar.getRevisionEvents();

  Future<void> markCompleted(int eventId) =>
      _isar.markRevisionCompleted(eventId);

  Future<void> markMissed(int eventId) =>
      _isar.markRevisionMissed(eventId);

  Future<int> getTodayDueCount() async {
    final events = await _isar.getTodayEvents();
    return events.length;
  }

  Future<int> getCompletedThisWeek() async {
    final weekStart = startOfWeek(DateTime.now());
    final weekEnd = endOfWeek(DateTime.now());
    final events = await _isar.getRevisionEvents();
    return events
        .where((e) =>
            e.status == RevisionStatus.completed &&
            e.completedAt != null &&
            e.completedAt!.isAfter(weekStart) &&
            e.completedAt!.isBefore(weekEnd))
        .length;
  }

  Future<int> getStreak() async {
    final profile = await _isar.getProfile();
    return profile?.studyStreak ?? 0;
  }

  Future<void> updateTopicProgress(int topicId) async {
    final events = await _isar.getRevisionEvents();
    final topicEvents = events.where((e) => e.topicId == topicId).toList();
    if (topicEvents.isEmpty) return;

    final completed = topicEvents.where((e) => e.status == RevisionStatus.completed).length;
    final total = topicEvents.length;
    final progress = completed / total;

    final topics = await _isar.getTopics();
    final topic = topics.firstWhereOrNull((t) => t.id == topicId);
    if (topic != null) {
      topic.progress = progress;
      topic.revisionCount = completed;
      topic.lastRevisedAt = DateTime.now();
      final nextEvent = topicEvents.firstWhereOrNull(
        (e) => e.status == RevisionStatus.upcoming,
      );
      topic.nextRevisionAt = nextEvent?.dueDate;
      await _isar.saveTopic(topic);
    }
  }
}
