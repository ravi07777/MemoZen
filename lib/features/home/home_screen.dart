import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/summary_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/revision_card.dart';
import '../../repositories/topic_repository.dart';

final homeDataProvider = FutureProvider.autoDispose((ref) async {
  final repo = ref.watch(topicRepositoryProvider);
  final today = await repo.getTodayEvents();
  final missed = await repo.getMissedEvents();
  final upcoming = await repo.getUpcomingEvents();
  final dueCount = await repo.getTodayDueCount();
  final weekCompleted = await repo.getCompletedThisWeek();
  final streak = await repo.getStreak();
  return (today, missed, upcoming, dueCount, weekCompleted, streak);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(theme, appTheme),
              const SizedBox(height: 20),
              _buildSummaryCards(theme, appTheme),
              const SizedBox(height: 20),
              _buildSegmentedTabs(theme),
              const SizedBox(height: 16),
              _buildContent(theme, appTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppColorTheme appTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${greeting()},',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Learner',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _headerIcon(Icons.auto_awesome, theme),
            const SizedBox(width: 8),
            _headerIcon(Icons.share, theme),
            const SizedBox(width: 8),
            _headerIcon(Icons.bar_chart, theme),
            const SizedBox(width: 8),
            _headerIcon(Icons.info_outline, theme),
          ],
        ),
      ],
    );
  }

  Widget _headerIcon(IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: Colors.grey.shade600),
    );
  }

  Widget _buildSummaryCards(ThemeData theme, AppColorTheme appTheme) {
    return ref.watch(homeDataProvider).when(
          data: (data) {
            final (_, _, upcoming, dueCount, weekCompleted, streak) = data;
            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              children: [
                SummaryCard(
                  title: 'Due Today',
                  value: '$dueCount',
                  icon: Icons.today,
                  color: appTheme.primary,
                ),
                SummaryCard(
                  title: 'Study Streak',
                  value: '$streak days',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
                SummaryCard(
                  title: 'Completed',
                  value: '$weekCompleted this week',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                SummaryCard(
                  title: 'Upcoming',
                  value: '${upcoming.length}',
                  icon: Icons.upcoming,
                  color: appTheme.secondary,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        );
  }

  Widget _buildSegmentedTabs(ThemeData theme) {
    final tabs = ['Today', 'Missed', 'Upcoming'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
          (i) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == i ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTab == i
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: _selectedTab == i ? FontWeight.w600 : FontWeight.normal,
                    color: _selectedTab == i
                        ? theme.colorScheme.primary
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AppColorTheme appTheme) {
    return ref.watch(homeDataProvider).when(
          data: (data) {
            final (today, missed, upcoming, _, _, _) = data;
            final list = _selectedTab == 0
                ? today
                : _selectedTab == 1
                    ? missed
                    : upcoming;

            if (list.isEmpty) {
              return EmptyState(
                title: 'No Topics to Revise',
                subtitle:
                    'Add new topics and they will appear here when revisions are due.',
                icon: Icons.celebration,
                color: appTheme.primary,
              );
            }

            return Column(
              children: list.map((event) => RevisionCard(
                event: event,
                onComplete: () async {
                  final repo = ref.read(topicRepositoryProvider);
                  await repo.markCompleted(event.id);
                  await repo.updateTopicProgress(event.topicId);
                  ref.invalidate(homeDataProvider);
                },
                onMissed: () async {
                  final repo = ref.read(topicRepositoryProvider);
                  await repo.markMissed(event.id);
                  ref.invalidate(homeDataProvider);
                },
              )).toList(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
  }
}
