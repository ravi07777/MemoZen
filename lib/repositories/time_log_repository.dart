import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/services/storage_service.dart';
import '../core/utils/helpers.dart';
import '../models/study_log.dart';

final timeLogRepositoryProvider = Provider<TimeLogRepository>((ref) {
  return TimeLogRepository(ref.watch(storageServiceProvider));
});

class TimeLogRepository {
  final StorageService _storage;

  TimeLogRepository(this._storage);

  Future<List<StudyLog>> getAllLogs() => _storage.getStudyLogs();

  Future<void> addLog(StudyLog log) => _storage.saveStudyLog(log);

  Future<void> deleteLog(int id) => _storage.deleteStudyLog(id);

  Future<int> getTodayTotal() async {
    final logs = await _storage.getStudyLogsForDate(DateTime.now());
    int total = 0;
    for (final l in logs) { total += l.durationMinutes; }
    return total;
  }

  Future<int> getWeekTotal() async {
    final start = startOfWeek(DateTime.now());
    final end = endOfWeek(DateTime.now());
    final logs = await _storage.getStudyLogsForRange(start, end);
    int total = 0;
    for (final l in logs) { total += l.durationMinutes; }
    return total;
  }

  Future<int> getMonthTotal() async {
    final start = startOfMonth(DateTime.now());
    final end = endOfMonth(DateTime.now());
    final logs = await _storage.getStudyLogsForRange(start, end);
    int total = 0;
    for (final l in logs) { total += l.durationMinutes; }
    return total;
  }

  Future<Map<String, int>> getWeekData() async {
    final start = startOfWeek(DateTime.now());
    final end = endOfWeek(DateTime.now());
    final logs = await _storage.getStudyLogsForRange(start, end);
    final data = <String, int>{};
    for (final log in logs) {
      final key = DateFormat('EEE').format(log.startTime);
      data[key] = (data[key] ?? 0) + log.durationMinutes;
    }
    return data;
  }

  Future<Map<String, int>> getSubjectDistribution() async {
    final logs = await _storage.getStudyLogs();
    final data = <String, int>{};
    for (final log in logs) {
      final key = log.subjectGroup ?? 'General';
      data[key] = (data[key] ?? 0) + log.durationMinutes;
    }
    return data;
  }

  Future<List<MapEntry<String, int>>> getTopTopics({int limit = 5}) async {
    final logs = await _storage.getStudyLogs();
    final data = <String, int>{};
    for (final log in logs) {
      final key = log.topicTitle ?? 'General';
      data[key] = (data[key] ?? 0) + log.durationMinutes;
    }
    final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  Future<List<MapEntry<DateTime, int>>> getDailyData(int days) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    final logs = await _storage.getStudyLogsForRange(start, end);
    final data = <DateTime, int>{};
    for (final log in logs) {
      final key = DateTime(log.startTime.year, log.startTime.month, log.startTime.day);
      data[key] = (data[key] ?? 0) + log.durationMinutes;
    }
    final sorted = data.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return sorted;
  }

  Future<int> getLifetimeTotal() async {
    final logs = await _storage.getStudyLogs();
    int total = 0;
    for (final l in logs) { total += l.durationMinutes; }
    return total;
  }
}
