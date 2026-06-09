import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/topic.dart';
import '../../repositories/topic_repository.dart';

class AddTopicScreen extends ConsumerStatefulWidget {
  final Topic? existingTopic;

  const AddTopicScreen({super.key, this.existingTopic});

  @override
  ConsumerState<AddTopicScreen> createState() => _AddTopicScreenState();
}

class _AddTopicScreenState extends ConsumerState<AddTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  DateTime _studiedOn = DateTime.now();
  String _subjectGroup = 'General';
  bool _useCustomCycle = false;
  final List<int> _customCycleDays = [1, 7, 30, 90];

  bool get _isEditing => widget.existingTopic != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTopic;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _notesCtrl = TextEditingController(text: t?.notes ?? '');
    _tagsCtrl = TextEditingController(text: t?.tags.join(', ') ?? '');
    if (t != null) {
      _studiedOn = t.studiedOn;
      _subjectGroup = t.subjectGroup ?? 'General';
      _useCustomCycle = t.useCustomCycle;
      if (t.customCycleDays.isNotEmpty) {
        _customCycleDays.clear();
        _customCycleDays.addAll(t.customCycleDays);
      } else {
        _customCycleDays.clear();
        _customCycleDays.addAll([t.revisionCycleDay1, t.revisionCycleDay2, t.revisionCycleDay3, t.revisionCycleDay4]);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Topic' : 'Add Topic'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(theme, 'Topic Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: const InputDecoration(
                  hintText: 'Enter topic name...',
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(theme, 'Subject Group'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _subjectGroup,
                items: [
                  'General',
                  'History',
                  'Science',
                  'Mathematics',
                  'Languages',
                  'Personal Notes',
                  'Exam Prep',
                ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _subjectGroup = v ?? 'General'),
                decoration: const InputDecoration(
                  hintText: 'Select a subject',
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(theme, 'Studied On'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _studiedOn,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _studiedOn = date);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: appTheme.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        '${_studiedOn.day}/${_studiedOn.month}/${_studiedOn.year}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Icon(Icons.edit, color: Colors.grey.shade400, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(theme, 'Revision Cycle'),
              const SizedBox(height: 8),
              _buildCycleSelector(theme, appTheme),
              const SizedBox(height: 20),
              _buildSectionTitle(theme, 'Tags'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter tags separated by commas...',
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(theme, 'Notes (Optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Add notes...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _saveTopic,
              child: Text(_isEditing ? 'Update Topic' : 'Create Topic'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCycleSelector(ThemeData theme, AppColorTheme appTheme) {
    return Column(
      children: [
        if (!_useCustomCycle)
          ..._customCycleDays.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: appTheme.primary),
                    const SizedBox(width: 12),
                    Text('Day ${entry.value}'),
                  ],
                ),
              ),
            ),
          ),
        if (!_useCustomCycle)
          TextButton.icon(
            onPressed: () => setState(() => _useCustomCycle = true),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Custom Cycle'),
          ),
        if (_useCustomCycle) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _customCycleDays.asMap().entries.map((entry) {
              return Chip(
                label: Text('Day ${entry.value}'),
                onDeleted: () {
                  if (_customCycleDays.length > 1) {
                    setState(() => _customCycleDays.removeAt(entry.key));
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              showDialog<int>(
                context: context,
                builder: (ctx) {
                  final ctrl = TextEditingController();
                  return AlertDialog(
                    title: const Text('Add Day'),
                    content: TextField(
                      controller: ctrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Enter day number'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          final day = int.tryParse(ctrl.text);
                          if (day != null && day > 0) {
                            Navigator.pop(ctx, day);
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  );
                },
              ).then((day) {
                if (day != null) setState(() => _customCycleDays.add(day));
              });
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Day'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: appTheme.primary,
              elevation: 0,
              side: BorderSide(color: appTheme.primary.withOpacity(0.3)),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _useCustomCycle = false;
              _customCycleDays
                ..clear()
                ..addAll([1, 7, 30, 90]);
            }),
            child: const Text('Use Default Cycle'),
          ),
        ],
      ],
    );
  }

  Future<void> _saveTopic() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(topicRepositoryProvider);

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final topic = widget.existingTopic ?? Topic(
      title: _titleCtrl.text.trim(),
      subjectGroup: _subjectGroup,
      studiedOn: _studiedOn,
      notes: _notesCtrl.text.trim(),
      tags: tags,
    );

    if (_isEditing) {
      final updated = topic.copyWith(
        title: _titleCtrl.text.trim(),
        subjectGroup: _subjectGroup,
        studiedOn: _studiedOn,
        notes: _notesCtrl.text.trim(),
        tags: tags,
        useCustomCycle: _useCustomCycle,
        customCycleDays: List.from(_customCycleDays),
      );
      await repo.updateTopic(updated);
    } else {
      final newTopic = topic.copyWith(
        useCustomCycle: _useCustomCycle,
        customCycleDays: List.from(_customCycleDays),
      );
      await repo.addTopic(newTopic);
    }

    if (mounted) context.pop();
  }
}
