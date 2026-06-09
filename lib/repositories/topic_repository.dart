import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../core/services/storage_service.dart';
import '../models/topic.dart';
import '../models/revision_event.dart';
import '../core/utils/helpers.dart';

final topicRepositoryProvider = Provider<TopicRepository>((ref) {
  return TopicRepository(ref.watch(storageServiceProvider));
});

class TopicRepository {
  final StorageService _storage;

  TopicRepository(this._storage);

  Future<List<Topic>> getAllTopics() => _storage.getTopics();

  Future<List<Topic>> getTopicsBySubject(String subject) =>
      _storage.getTopicsBySubject(subject);

  Future<List<String>> getSubjectGroups() async {
    final topics = await _storage.getTopics();
    final subjects = topics.map((t) => t.subjectGroup ?? 'Uncategorized').toSet();
    final groups = await _storage.getSubjectGroups();
    for (final g in groups) {
      subjects.add(g.name);
    }
    return subjects.sorted();
  }

  Future<void> addTopic(Topic topic) async {
    await _storage.saveTopic(topic);
    await _storage.generateRevisionEvents(topic);
  }

  Future<void> updateTopic(Topic topic) async {
    await _storage.saveTopic(topic);
    await _storage.generateRevisionEvents(topic);
  }

  Future<void> deleteTopic(int id) async {
    await _storage.deleteTopic(id);
  }

  Future<List<RevisionEvent>> getTodayEvents() => _storage.getTodayEvents();
  Future<List<RevisionEvent>> getUpcomingEvents() => _storage.getUpcomingEvents();
  Future<List<RevisionEvent>> getMissedEvents() => _storage.getMissedEvents();
  Future<List<RevisionEvent>> getAllEvents() => _storage.getRevisionEvents();

  Future<void> markCompleted(int eventId) =>
      _storage.markRevisionCompleted(eventId);

  Future<void> markMissed(int eventId) =>
      _storage.markRevisionMissed(eventId);

  Future<int> getTodayDueCount() async {
    final events = await _storage.getTodayEvents();
    return events.length;
  }

  Future<int> getCompletedThisWeek() async {
    final weekStart = startOfWeek(DateTime.now());
    final weekEnd = endOfWeek(DateTime.now());
    final events = await _storage.getRevisionEvents();
    return events
        .where((e) =>
            e.status == RevisionStatus.completed &&
            e.completedAt != null &&
            e.completedAt!.isAfter(weekStart) &&
            e.completedAt!.isBefore(weekEnd))
        .length;
  }

  Future<int> getStreak() async {
    final profile = await _storage.getProfile();
    return profile?.studyStreak ?? 0;
  }

  Future<void> updateTopicProgress(int topicId) async {
    final events = await _storage.getRevisionEvents();
    final topicEvents = events.where((e) => e.topicId == topicId).toList();
    if (topicEvents.isEmpty) return;

    final completed = topicEvents.where((e) => e.status == RevisionStatus.completed).length;
    final total = topicEvents.length;
    final progress = completed / total;

    final topics = await _storage.getTopics();
    final index = topics.indexWhere((t) => t.id == topicId);
    if (index >= 0) {
      final topic = topics[index];
      final nextEvent = topicEvents.firstWhereOrNull(
        (e) => e.status == RevisionStatus.upcoming,
      );
      final updated = topic.copyWith(
        progress: progress,
        revisionCount: completed,
        lastRevisedAt: DateTime.now(),
        nextRevisionAt: nextEvent?.dueDate,
      );
      await _storage.saveTopic(updated);
    }
  }
}
