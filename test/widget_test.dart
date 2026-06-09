import 'package:flutter_test/flutter_test.dart';
import 'package:memozen/models/topic.dart';
import 'package:memozen/models/revision_event.dart';
import 'package:memozen/models/study_log.dart';
import 'package:memozen/models/subject_group.dart';
import 'package:memozen/core/utils/helpers.dart';

void main() {
  group('Topic Model', () {
    test('should create a topic with default values', () {
      final topic = Topic(title: 'Test Topic');
      expect(topic.title, 'Test Topic');
      expect(topic.progress, 0.0);
      expect(topic.revisionCount, 0);
      expect(topic.isComplete, false);
    });

    test('should have default revision cycle days', () {
      final topic = Topic(title: 'Test');
      expect(topic.cycleDays, [1, 7, 30, 90]);
    });

    test('should use custom cycle when set', () {
      final topic = Topic(
        title: 'Test',
        useCustomCycle: true,
        customCycleDays: [1, 3, 7, 14, 30],
      );
      expect(topic.cycleDays, [1, 3, 7, 14, 30]);
      expect(topic.totalRevisionsNeeded, 5);
    });

    test('should be complete when progress is 1.0', () {
      final topic = Topic(title: 'Test', progress: 1.0);
      expect(topic.isComplete, true);
    });

    test('should serialize and deserialize to/from JSON', () {
      final topic = Topic(
        title: 'Test Topic',
        subjectGroup: 'Science',
        tags: ['physics', 'chemistry'],
      );
      final json = topic.toJson();
      final restored = Topic.fromJson(json);
      expect(restored.title, topic.title);
      expect(restored.subjectGroup, topic.subjectGroup);
      expect(restored.tags, topic.tags);
    });
  });

  group('RevisionEvent Model', () {
    test('should create a revision event', () {
      final event = RevisionEvent(
        topicId: 1,
        topicTitle: 'Test Topic',
        dueDate: DateTime.now(),
        cycleDay: 7,
      );
      expect(event.status, RevisionStatus.upcoming);
      expect(event.cycleDay, 7);
    });

    test('should serialize and deserialize to/from JSON', () {
      final event = RevisionEvent(
        topicId: 1,
        topicTitle: 'Test',
        dueDate: DateTime(2025, 1, 15),
        cycleDay: 30,
      );
      final json = event.toJson();
      final restored = RevisionEvent.fromJson(json);
      expect(restored.topicId, event.topicId);
      expect(restored.cycleDay, event.cycleDay);
    });
  });

  group('StudyLog Model', () {
    test('should create a study log', () {
      final now = DateTime.now();
      final log = StudyLog(
        topicTitle: 'Test',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        durationMinutes: 60,
      );
      expect(log.durationMinutes, 60);
    });

    test('should serialize and deserialize to/from JSON', () {
      final now = DateTime.now();
      final log = StudyLog(
        topicTitle: 'Test',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
        durationMinutes: 60,
      );
      final json = log.toJson();
      final restored = StudyLog.fromJson(json);
      expect(restored.durationMinutes, log.durationMinutes);
      expect(restored.topicTitle, log.topicTitle);
    });
  });

  group('SubjectGroup Model', () {
    test('should create a subject group', () {
      final group = SubjectGroup(name: 'Science');
      expect(group.name, 'Science');
      expect(group.isExpanded, true);
    });
  });

  group('Utility Helpers', () {
    test('formatDuration returns correct strings', () {
      expect(formatDuration(15), '15 min');
      expect(formatDuration(60), '1h');
      expect(formatDuration(90), '1h 30m');
      expect(formatDuration(0), '0 min');
    });

    test('greeting returns correct time-based greeting', () {
      final greet = greeting();
      expect(greet.contains('Good'), true);
    });
  });
}
