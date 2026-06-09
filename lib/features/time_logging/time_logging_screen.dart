import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/helpers.dart';
import '../../models/study_log.dart';
import '../../repositories/time_log_repository.dart';

final timeLogProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(timeLogRepositoryProvider);
  return (
    today: await repo.getTodayTotal(),
    week: await repo.getWeekTotal(),
    month: await repo.getMonthTotal(),
    logs: await repo.getAllLogs(),
    weekData: await repo.getWeekData(),
  );
});

class TimeLoggingScreen extends ConsumerStatefulWidget {
  const TimeLoggingScreen({super.key});

  @override
  ConsumerState<TimeLoggingScreen> createState() => _TimeLoggingScreenState();
}

class _TimeLoggingScreenState extends ConsumerState<TimeLoggingScreen> {
  bool _showAllLogs = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = ref.watch(appThemeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time Logging', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 20),
            _buildQuickLogButtons(theme, appTheme),
            const SizedBox(height: 20),
            _buildSummaryCards(theme, appTheme),
            const SizedBox(height: 20),
            _buildRecentLogs(theme, appTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLogButtons(ThemeData theme, AppColorTheme appTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Log', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              _quickButton(theme, appTheme, '15m', 15),
              const SizedBox(width: 8),
              _quickButton(theme, appTheme, '30m', 30),
              const SizedBox(width: 8),
              _quickButton(theme, appTheme, '1h', 60),
              const SizedBox(width: 8),
              _quickButton(theme, appTheme, '2h', 120),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickButton(ThemeData theme, AppColorTheme appTheme, String label, int minutes) {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final repo = ref.read(timeLogRepositoryProvider);
          final now = DateTime.now();
          await repo.addLog(StudyLog(
            startTime: now.subtract(Duration(minutes: minutes)),
            endTime: now,
            durationMinutes: minutes,
            topicTitle: 'Quick Study',
          ));
          ref.invalidate(timeLogProvider);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: appTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: appTheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme, AppColorTheme appTheme) {
    return ref.watch(timeLogProvider).when(
      data: (data) => Row(
        children: [
          Expanded(child: _summaryCard(theme, 'Today', formatDuration(data.today), appTheme.primary, Icons.today)),
          const SizedBox(width: 8),
          Expanded(child: _summaryCard(theme, 'This Week', formatDuration(data.week), appTheme.secondary, Icons.calendar_view_week)),
          const SizedBox(width: 8),
          Expanded(child: _summaryCard(theme, 'This Month', formatDuration(data.month), Colors.green, Icons.calendar_month)),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _summaryCard(ThemeData theme, String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildRecentLogs(ThemeData theme, AppColorTheme appTheme) {
    return ref.watch(timeLogProvider).when(
      data: (data) {
        if (data.logs.isEmpty) {
          return EmptyState(
            title: 'No Study Time Logged',
            subtitle: 'Start logging your study sessions to see analytics.',
            icon: Icons.timer,
            color: appTheme.primary,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Logs', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => setState(() => _showAllLogs = !_showAllLogs),
                  child: Text(_showAllLogs ? 'Show Less' : 'Show All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...data.logs.reversed.take(_showAllLogs ? 50 : 5).map((log) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: appTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.timer, color: appTheme.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.topicTitle ?? 'Study Session',
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                            Text(
                              '${formatDate(log.startTime)} - ${formatDuration(log.durationMinutes)}',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: Colors.red.shade300,
                        onPressed: () async {
                          await ref.read(timeLogRepositoryProvider).deleteLog(log.id);
                          ref.invalidate(timeLogProvider);
                        },
                      ),
                    ],
                  ),
                )),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
