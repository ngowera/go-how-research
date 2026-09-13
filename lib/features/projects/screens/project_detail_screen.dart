import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/projects_provider.dart';
import '../../../core/providers/questionnaire_provider.dart';
import '../../../shared/theme/app_theme.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showNewQuestionnaireDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Questionnaire',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Questionnaire Title *',
                hintText: 'e.g. Clinic Staff Survey 2026',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description / Instructions',
                hintText: 'Purpose of this instrument...',
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
              if (titleController.text.trim().isNotEmpty) {
                final q = await ref
                    .read(questionnairesProvider.notifier)
                    .createQuestionnaire(
                      projectId: widget.projectId,
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
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
            child: const Text('Create & Open Builder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectByIdProvider(widget.projectId));
    final questionnairesState = ref.watch(questionnairesProvider);
    final questionnaires = questionnairesState.questionnaires
        .where((q) => q.projectId == widget.projectId)
        .toList();

    if (project == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Project Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Project not found or deleted'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/projects'),
                child: const Text('Back to Projects'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Nav & Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/projects'),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '${project.methodology} • Sample Size: ${project.sampleSize} • Status: ${project.status.name.toUpperCase()}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => context.go('/analytics/${project.id}'),
                      icon: const Icon(Icons.bar_chart_rounded, size: 18),
                      label: const Text('Analytics'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _showNewQuestionnaireDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Questionnaire'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.kPrimary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppTheme.kPrimary,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: AppTheme.kPrimary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(icon: Icon(Icons.info_outline), text: 'Study Overview'),
                Tab(
                    icon: Icon(Icons.assignment_outlined),
                    text: 'Questionnaires'),
                Tab(
                    icon: Icon(Icons.table_chart_outlined),
                    text: 'Responses & Data'),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 20),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. Overview
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionCard(
                          title: 'Description & Abstract',
                          content: Text(
                            project.description.isEmpty
                                ? 'No description entered.'
                                : project.description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              height: 1.5,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          title: 'Research Objectives',
                          content: Text(
                            project.objectives.isEmpty
                                ? 'No objectives defined.'
                                : project.objectives,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              height: 1.5,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSectionCard(
                          title: 'Research Questions',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: project.researchQuestions
                                .map((q) => Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.help_outline_rounded,
                                              size: 16,
                                              color: AppTheme.kPrimary),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              q,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSectionCard(
                                title: 'Target Population',
                                content: Text(
                                  project.population,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSectionCard(
                                title: 'Study Sites',
                                content: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: project.sites
                                      .map((s) => Chip(
                                            label: Text(s,
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 2. Questionnaires Tab
                  questionnaires.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_outlined,
                                  size: 56, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No questionnaires for this project yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showNewQuestionnaireDialog(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Create Questionnaire'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.kPrimary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: questionnaires.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, idx) {
                            final q = questionnaires[idx];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.kPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.assignment_rounded,
                                    color: AppTheme.kPrimary),
                              ),
                              title: Text(q.title,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                  'Version ${q.version} • ${q.isApproved ? "Approved by supervisor" : "Draft / Pending approval"}',
                                  style: GoogleFonts.poppins(fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        context.go('/data-collection/${q.id}'),
                                    icon: const Icon(Icons.edit_note_rounded,
                                        size: 16),
                                    label: const Text('Collect Data'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => context
                                        .go('/questionnaires/${q.id}/builder'),
                                    icon: const Icon(Icons.tune_rounded,
                                        size: 16),
                                    label: const Text('Open Builder'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.kPrimary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                  // 3. Responses & Data
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.table_chart_rounded,
                            size: 64, color: AppTheme.kSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'View & Export Project Data',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inspect responses in spreadsheet view, clean datasets, or export to CSV / Excel.',
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/data/${project.id}'),
                          icon: const Icon(Icons.launch_rounded),
                          label: const Text('Open Data Table'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.kSecondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }
}
