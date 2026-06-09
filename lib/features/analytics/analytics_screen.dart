import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../repositories/time_log_repository.dart';
import '../../repositories/topic_repository.dart';

final analyticsProvider = FutureProvider.autoDispose((ref) async {
  final timeRepo = ref.watch(timeLogRepositoryProvider);
  final topicRepo = ref.watch(topicRepositoryProvider);

  return (
    dailyData: await timeRepo.getDailyData(14),
    subjectDist: await timeRepo.getSubjectDistribution(),
    topTopics: await timeRepo.getTopTopics(),
    lifetime: await timeRepo.getLifetimeTotal(),
    weekData: await timeRepo.getWeekData(),
    topics: await topicRepo.getAllTopics(),
    events: await topicRepo.getAllEvents(),
  );
});

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 20),
              ref.watch(analyticsProvider).when(
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLifetimeCard(theme, appTheme, data.lifetime),
                    const SizedBox(height: 16),
                    _buildDailyChart(theme, appTheme, data.dailyData),
                    const SizedBox(height: 16),
                    _buildSubjectChart(theme, appTheme, data.subjectDist),
                    const SizedBox(height: 16),
                    _buildTopTopics(theme, data.topTopics),
                    const SizedBox(height: 16),
                    _buildCompletionStats(theme, appTheme, data.topics, data.events),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLifetimeCard(ThemeData theme, AppColorTheme appTheme, int minutes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appTheme.primary, appTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: appTheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Study Time',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            formatDuration(minutes),
            style: theme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lifetime',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChart(ThemeData theme, AppColorTheme appTheme, List<MapEntry<DateTime, int>> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Study Time (14 days)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: data.isEmpty
                ? Center(child: Text('No data yet', style: TextStyle(color: Colors.grey.shade400)))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (v, meta) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                              return Text(
                                DateFormat('d').format(data[idx].key),
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value.toDouble())).toList(),
                          isCurved: true,
                          color: appTheme.primary,
                          barWidth: 3,
                          dotData: FlDotData(show: true, getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(radius: 4, color: appTheme.primary, strokeWidth: 0)),
                          belowBarData: BarAreaData(show: true, color: appTheme.primary.withOpacity(0.1)),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectChart(ThemeData theme, AppColorTheme appTheme, Map<String, int> data) {
    final colors = [appTheme.primary, appTheme.secondary, Colors.orange, Colors.green, Colors.purple, Colors.teal];
    final total = data.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subject Distribution', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: data.isEmpty
                ? Center(child: Text('No data yet', style: TextStyle(color: Colors.grey.shade400)))
                : PieChart(
                    PieChartData(
                      sections: data.entries.toList().asMap().entries.map((e) {
                        final pct = (e.value.value / total * 100).toStringAsFixed(0);
                        return PieChartSectionData(
                          color: colors[e.key % colors.length],
                          value: e.value.value.toDouble(),
                          title: '$pct%',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          ...data.entries.toList().asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: colors[e.key % colors.length])),
                    const SizedBox(width: 8),
                    Text(e.value.key, style: theme.textTheme.bodySmall),
                    const Spacer(),
                    Text('${formatDuration(e.value.value)}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTopTopics(ThemeData theme, List<MapEntry<String, int>> topics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Topics by Time', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...topics.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.menu_book, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t.key, style: theme.textTheme.bodyMedium)),
                    Text(formatDuration(t.value), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCompletionStats(ThemeData theme, AppColorTheme appTheme, List<dynamic> topics, List<dynamic> events) {
    final totalTopics = topics.length;
    final completedTopics = topics.where((t) => (t as dynamic).isComplete == true).length;
    final totalEvents = events.length;
    final completedEvents = events.where((e) => (e as dynamic).status.name == 'completed').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revision Progress', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem(theme, 'Topics', '$completedTopics/$totalTopics'),
              const SizedBox(width: 16),
              _statItem(theme, 'Revisions', '$completedEvents/$totalEvents'),
              const SizedBox(width: 16),
              _statItem(theme, 'Rate', totalEvents > 0 ? '${(completedEvents / totalEvents * 100).toInt()}%' : '0%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(ThemeData theme, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
