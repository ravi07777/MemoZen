import 'package:flutter/material.dart';
import '../../models/revision_event.dart';
import '../utils/helpers.dart';

class RevisionCard extends StatelessWidget {
  final RevisionEvent event;
  final VoidCallback? onComplete;
  final VoidCallback? onMissed;

  const RevisionCard({
    super.key,
    required this.event,
    this.onComplete,
    this.onMissed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = event.status == RevisionStatus.upcoming &&
        event.dueDate.isBefore(DateTime.now());
    final isCompleted = event.status == RevisionStatus.completed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withOpacity(0.2)
              : isCompleted
                  ? Colors.green.withOpacity(0.2)
                  : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : isOverdue
                      ? Colors.red.withOpacity(0.1)
                      : theme.colorScheme.primary.withOpacity(0.1),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle
                  : isOverdue
                      ? Icons.warning_amber
                      : Icons.menu_book,
              color: isCompleted
                  ? Colors.green
                  : isOverdue
                      ? Colors.red
                      : theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.topicTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${isCompleted ? 'Completed' : isOverdue ? 'Overdue' : 'Due'} - ${formatDate(event.dueDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverdue
                        ? Colors.red.shade400
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (!isCompleted) ...[
            if (onComplete != null)
              IconButton(
                onPressed: onComplete,
                icon: Icon(Icons.check_circle_outline,
                    color: theme.colorScheme.primary),
                tooltip: 'Mark completed',
              ),
            if (onMissed != null)
              IconButton(
                onPressed: onMissed,
                icon: Icon(Icons.not_interested, color: Colors.grey.shade400),
                tooltip: 'Mark missed',
              ),
          ],
        ],
      ),
    );
  }
}
