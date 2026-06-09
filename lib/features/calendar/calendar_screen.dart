import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/revision_card.dart';
import '../../core/utils/helpers.dart';
import '../../models/revision_event.dart';
import '../../repositories/topic_repository.dart';

final calendarEventsProvider = FutureProvider.autoDispose.family<List<RevisionEvent>, DateTime>((ref, date) {
  return ref.watch(topicRepositoryProvider).getAllEvents().then((events) {
    return events.where((e) {
      final d = DateTime(date.year, date.month, date.day);
      final ed = DateTime(e.dueDate.year, e.dueDate.month, e.dueDate.day);
      return d == ed;
    }).toList();
  });
});

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Calendar',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            _buildMonthHeader(theme, appTheme),
            const SizedBox(height: 8),
            _buildWeekdayHeader(theme),
            _buildCalendarGrid(theme, appTheme),
            const Divider(height: 32),
            _buildSelectedDateEvents(theme, appTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(ThemeData theme, AppColorTheme appTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.chevron_left, color: appTheme.primary),
            ),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.chevron_right, color: appTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(ThemeData theme) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((d) {
          return SizedBox(
            width: 36,
            child: Text(
              d,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme, AppColorTheme appTheme) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = lastDay.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          for (var row = 0; row < ((startWeekday + daysInMonth + 6) ~/ 7); row++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (col) {
                  final dayNum = row * 7 + col - startWeekday + 1;
                  if (dayNum < 1 || dayNum > daysInMonth) {
                    return const SizedBox(width: 36, height: 36);
                  }
                  final date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                  final isSelected = date == DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                  final isToday = date == DateTime.now();

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? appTheme.primary
                            : isToday
                                ? appTheme.primary.withOpacity(0.1)
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNum',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? appTheme.primary
                                    : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateEvents(ThemeData theme, AppColorTheme appTheme) {
    return Expanded(
      child: ref.watch(calendarEventsProvider(_selectedDate)).when(
        data: (events) {
          if (events.isEmpty) {
            return EmptyState(
              title: 'Nothing to Revise',
              subtitle: 'No revision events on this day. Add a topic to get started.',
              icon: Icons.event_busy,
              color: appTheme.primary,
              action: ElevatedButton.icon(
                onPressed: () => context.push('/add-topic'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Topic'),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${events.length} revision${events.length > 1 ? 's' : ''}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: events.map((e) => RevisionCard(event: e)).toList(),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}
