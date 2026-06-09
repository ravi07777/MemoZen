import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/topic_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/topic.dart';
import '../../repositories/topic_repository.dart';

final topicsListProvider = FutureProvider.autoDispose<List<Topic>>((ref) {
  return ref.watch(topicRepositoryProvider).getAllTopics();
});

final subjectGroupsProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(topicRepositoryProvider).getSubjectGroups();
});

class TopicsScreen extends ConsumerStatefulWidget {
  const TopicsScreen({super.key});

  @override
  ConsumerState<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends ConsumerState<TopicsScreen> {
  String _searchQuery = '';
  bool _isGridView = false;
  String _sortBy = 'All';
  final Set<String> _expandedGroups = {};

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Topics',
                    style: theme.textTheme.headlineMedium,
                  ),
                  ref.watch(topicsListProvider).when(
                    data: (topics) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: appTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${topics.length} topics',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: appTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search topics...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _iconButton(Icons.grid_view, _isGridView, () => setState(() => _isGridView = true)),
                  const SizedBox(width: 4),
                  _iconButton(Icons.list, !_isGridView, () => setState(() => _isGridView = false)),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    onSelected: (v) => setState(() => _sortBy = v),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'All', child: Text('All topics')),
                      const PopupMenuItem(value: 'Recent', child: Text('Most recent')),
                      const PopupMenuItem(value: 'Progress', child: Text('By progress')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.sort, size: 20, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildTopicsList(theme, appTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildTopicsList(ThemeData theme, AppColorTheme appTheme) {
    return ref.watch(topicsListProvider).when(
      data: (topics) {
        var filtered = topics.where((t) {
          if (_searchQuery.isEmpty) return true;
          return t.title.toLowerCase().contains(_searchQuery) ||
              (t.subjectGroup?.toLowerCase().contains(_searchQuery) ?? false);
        }).toList();

        if (_sortBy == 'Recent') {
          filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else if (_sortBy == 'Progress') {
          filtered.sort((a, b) => a.progress.compareTo(b.progress));
        }

        if (filtered.isEmpty) {
          return EmptyState(
            title: 'No Topics Yet',
            subtitle: 'Tap + to add your first topic and start learning.',
            icon: Icons.menu_book,
            color: appTheme.primary,
            action: ElevatedButton.icon(
              onPressed: () => context.push('/add-topic'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Topic'),
            ),
          );
        }

        final grouped = <String, List<Topic>>{};
        for (final t in filtered) {
          final key = t.subjectGroup ?? 'General';
          grouped.putIfAbsent(key, () => []).add(t);
          _expandedGroups.add(key);
        }

        final sortedKeys = grouped.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: sortedKeys.length,
          itemBuilder: (_, i) {
            final key = sortedKeys[i];
            final groupTopics = grouped[key]!;
            final isExpanded = _expandedGroups.contains(key);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        key,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${groupTopics.length}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedGroups.remove(key);
                            } else {
                              _expandedGroups.add(key);
                            }
                          });
                        },
                        child: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isExpanded)
                  ...groupTopics.map(
                    (t) => TopicCard(
                      topic: t,
                      onComplete: () async {
                        final repo = ref.read(topicRepositoryProvider);
                        final events = await repo.getAllEvents();
                        final topicEvents = events.where((e) => e.topicId == t.id && e.status.name == 'upcoming').toList();
                        if (topicEvents.isNotEmpty) {
                          await repo.markCompleted(topicEvents.first.id);
                          await repo.updateTopicProgress(t.id);
                          ref.invalidate(topicsListProvider);
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
