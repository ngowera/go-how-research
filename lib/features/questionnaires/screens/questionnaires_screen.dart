import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/projects_provider.dart';
import '../../../core/providers/questionnaire_provider.dart';
import '../../../shared/theme/app_theme.dart';
import 'questionnaire_share_dialog.dart';

class QuestionnairesScreen extends ConsumerStatefulWidget {
  final bool collectionMode;

  const QuestionnairesScreen({super.key, this.collectionMode = false});

  @override
  ConsumerState<QuestionnairesScreen> createState() =>
      _QuestionnairesScreenState();
}

class _QuestionnairesScreenState extends ConsumerState<QuestionnairesScreen> {
  String _search = '';
  late bool _collectionMode;

  @override
  void initState() {
    super.initState();
    _collectionMode = widget.collectionMode;
  }

  @override
  void didUpdateWidget(covariant QuestionnairesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectionMode != widget.collectionMode) {
      _collectionMode = widget.collectionMode;
    }
  }

  void _selectWorkspace(bool collect) {
    setState(() => _collectionMode = collect);
    if (collect) {
      context.go('/data-collection/default');
    } else {
      context.go('/questionnaires');
    }
  }

  void _showCreateDialog(BuildContext context) {
    final projectsState = ref.read(projectsProvider);
    if (projectsState.projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a research project first!'),
          backgroundColor: AppTheme.kWarning,
        ),
      );
      context.go('/projects');
      return;
    }

    String selectedProjectId = projectsState.projects.first.id;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String template = 'blank';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            'New Questionnaire',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedProjectId,
                decoration: const InputDecoration(labelText: 'Select Project'),
                items: projectsState.projects
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            p.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedProjectId = v);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: template,
                decoration:
                    const InputDecoration(labelText: 'Starting template'),
                items: const [
                  DropdownMenuItem(
                      value: 'blank', child: Text('Blank instrument')),
                  DropdownMenuItem(
                      value: 'laboratory', child: Text('Laboratory results')),
                  DropdownMenuItem(
                      value: 'diagnostic', child: Text('Diagnostic accuracy')),
                  DropdownMenuItem(
                      value: 'agriculture',
                      child: Text('Agricultural field trial')),
                  DropdownMenuItem(
                      value: 'general',
                      child: Text('General student research')),
                ],
                onChanged: (value) =>
                    setDialogState(() => template = value ?? 'blank'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Questionnaire Title *',
                  hintText: 'e.g. Student Health Survey',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Instructions / Description',
                  hintText: 'Guidance for respondents...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isNotEmpty || template != 'blank') {
                  final notifier = ref.read(questionnairesProvider.notifier);
                  final q = template == 'blank'
                      ? await notifier.createQuestionnaire(
                          projectId: selectedProjectId,
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                        )
                      : await notifier.createFromTemplate(
                          projectId: selectedProjectId,
                          template: template,
                          title: titleCtrl.text.trim().isEmpty
                              ? null
                              : titleCtrl.text.trim(),
                        );
                  if (mounted) {
                    Navigator.of(ctx).pop();
                    context.go('/questionnaires/${q.id}/builder');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create & Build'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionnairesProvider);
    final projectsState = ref.watch(projectsProvider);
    final projectsMap = {for (final p in projectsState.projects) p.id: p.title};

    final questionnaires = state.questionnaires.where((q) {
      return q.title.toLowerCase().contains(_search.toLowerCase()) ||
          q.description.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Questionnaires & Data Collection',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _collectionMode
                          ? 'Choose a questionnaire to record participant responses'
                          : 'Build survey instruments, Likert scales, tests, and interview guides',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (!_collectionMode)
                  ElevatedButton.icon(
                    onPressed: () => _showCreateDialog(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('New Questionnaire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _workspaceTab(false, Icons.assignment_outlined,
                      'Questionnaire Builder'),
                  _workspaceTab(true, Icons.edit_note_rounded, 'Collect Data'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search questionnaires...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
            const SizedBox(height: 24),

            // List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? _LoadError(
                          message: state.error!,
                          onRetry: () => ref
                              .read(questionnairesProvider.notifier)
                              .loadQuestionnaires(),
                        )
                      : questionnaires.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assignment_outlined,
                                      size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No questionnaires found',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Design simple or complex questionnaires with drag-and-drop',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey.shade500),
                                  ),
                                  const SizedBox(height: 16),
                                  if (!_collectionMode)
                                    ElevatedButton(
                                      onPressed: () =>
                                          _showCreateDialog(context),
                                      child: const Text('Create Questionnaire'),
                                    ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: questionnaires.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 16),
                              itemBuilder: (context, idx) {
                                final q = questionnaires[idx];
                                final projTitle = projectsMap[q.projectId] ??
                                    'Unassigned Project';

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00897B)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.assignment_rounded,
                                          color: Color(0xFF00897B),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              q.title,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1E293B),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Project: $projTitle • Version ${q.version}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: q.isApproved
                                              ? Colors.green.shade50
                                              : Colors.orange.shade50,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: q.isApproved
                                                ? Colors.green.shade300
                                                : Colors.orange.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          q.isApproved
                                              ? 'APPROVED'
                                              : 'DRAFT / PENDING',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: q.isApproved
                                                ? Colors.green.shade700
                                                : Colors.orange.shade800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      OutlinedButton.icon(
                                        onPressed: () => _collectionMode
                                            ? context
                                                .go('/data-collection/${q.id}')
                                            : showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    QuestionnaireShareDialog(
                                                        questionnaire: q)),
                                        icon: const Icon(
                                            Icons.play_circle_outline_rounded,
                                            size: 16),
                                        label: Text(_collectionMode
                                            ? 'Start Collection'
                                            : 'Collect / Share'),
                                      ),
                                      if (!_collectionMode) ...[
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () => context.go(
                                              '/questionnaires/${q.id}/builder'),
                                          icon: const Icon(Icons.edit_rounded,
                                              size: 16),
                                          label: const Text('Edit Questions'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.kPrimary,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (val) {
                                            if (val == 'dup') {
                                              ref
                                                  .read(questionnairesProvider
                                                      .notifier)
                                                  .duplicateQuestionnaire(q.id);
                                            } else if (val == 'del') {
                                              ref
                                                  .read(questionnairesProvider
                                                      .notifier)
                                                  .deleteQuestionnaire(q.id);
                                            }
                                          },
                                          itemBuilder: (_) => [
                                            const PopupMenuItem(
                                                value: 'dup',
                                                child: Text('Duplicate')),
                                            const PopupMenuItem(
                                                value: 'del',
                                                child: Text('Delete',
                                                    style: TextStyle(
                                                        color: Colors.red))),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _workspaceTab(bool collection, IconData icon, String label) {
    final selected = _collectionMode == collection;
    return InkWell(
      onTap: () => _selectWorkspace(collection),
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x14000000), blurRadius: 8)]
              : null,
        ),
        child: Row(children: [
          Icon(icon,
              size: 19,
              color: selected ? AppTheme.kPrimary : Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.poppins(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppTheme.kPrimary : Colors.grey.shade700)),
        ]),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 52, color: Colors.red),
              const SizedBox(height: 12),
              const Text('Questionnaires could not be loaded',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
}
