import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/app_models.dart';
import '../../../core/providers/analytics_provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/providers/billing_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/providers/projects_provider.dart';
import '../../../core/providers/questionnaire_provider.dart';
import '../../../core/providers/responses_provider.dart';
import '../../../core/utils/statistics_utils.dart';
import '../../../shared/theme/app_theme.dart';
import '../../data/screens/export_dialog.dart';
import '../widgets/chart_explorer.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  final String projectId;

  const AnalyticsScreen({super.key, required this.projectId});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _interpretPValue(double p) => StatisticsUtils.interpretPValue(p,
      alpha: ref.watch(appSettingsProvider).confidenceLevel);
  String? _crossTabRowQId;
  String? _crossTabColQId;
  String? _correlationXId;
  String? _correlationYId;
  String? _groupVariableId;
  String? _outcomeVariableId;
  bool _includeMissingInCrossTab = false;
  bool _showRowPercentages = true;
  bool _compactPhoneHeader = false;

  String _effectStrength(double value) {
    final magnitude = value.abs();
    if (magnitude < .10) return 'negligible';
    if (magnitude < .30) return 'small';
    if (magnitude < .50) return 'moderate';
    return 'large';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 600;
    final billing = ref.watch(billingProvider);
    if (billing.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!billing.hasAnalytics) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 56, color: AppTheme.kPrimary),
                const SizedBox(height: 16),
                Text('Analytics is available on Plus',
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text(
                    'Upgrade to Plus for MWK 10,000 per 30 days, or Pro for full exports.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton(
                    onPressed: () => context.go('/settings'),
                    child: const Text('View plans in Settings')),
              ]),
            ),
          ),
        ),
      );
    }
    final project = ref.watch(projectByIdProvider(widget.projectId));
    final analyticsState = ref.watch(analyticsProvider(widget.projectId));
    final questionnairesState = ref.watch(questionnairesProvider);
    final questionnaires = questionnairesState.questionnaires
        .where((q) => q.projectId == widget.projectId)
        .toList();
    final selectedQuestionnaireId = analyticsState.selectedQuestionnaireId ??
        (questionnaires.isEmpty ? null : questionnaires.first.id);
    final exportQuestions = selectedQuestionnaireId == null
        ? const <Question>[]
        : ref.watch(
            questionsByQuestionnaireProvider(selectedQuestionnaireId),
          );
    final exportResponses = selectedQuestionnaireId == null
        ? const <QuestionnaireResponse>[]
        : ref.watch(responsesProvider(selectedQuestionnaireId)).responses;
    final allProjects = [...ref.watch(projectsProvider).projects];
    final allQuestionnaires = questionnairesState.questionnaires;
    final activityByProject = <String, DateTime>{
      for (final p in allProjects) p.id: p.updatedAt,
    };
    for (final questionnaire in allQuestionnaires) {
      final current = activityByProject[questionnaire.projectId];
      if (current == null || questionnaire.updatedAt.isAfter(current)) {
        activityByProject[questionnaire.projectId] = questionnaire.updatedAt;
      }
      for (final response
          in ref.watch(responsesProvider(questionnaire.id)).responses) {
        final latest = activityByProject[questionnaire.projectId];
        if (latest == null || response.collectedAt.isAfter(latest)) {
          activityByProject[questionnaire.projectId] = response.collectedAt;
        }
      }
    }
    allProjects.sort((a, b) => (activityByProject[b.id] ?? b.updatedAt)
        .compareTo(activityByProject[a.id] ?? a.updatedAt));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: EdgeInsets.all(isPhone ? 16 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((!isPhone || !_compactPhoneHeader) &&
                allProjects.isNotEmpty) ...[
              _buildProjectSelector(allProjects, activityByProject),
              const SizedBox(height: 18),
            ],
            // Top Nav & Title
            if (!isPhone || !_compactPhoneHeader)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: isPhone ? double.infinity : null,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () =>
                              context.go('/projects/${widget.projectId}'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Statistical Analysis & Analytics',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                'Project: ${project?.title ?? "Academic Study"} • Automated descriptive & inferential analysis',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (questionnaires.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: exportQuestions.isEmpty ||
                                  exportResponses.isEmpty
                              ? null
                              : () {
                                  if (!billing.hasExports) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Excel and SPSS exports require the Pro plan.')),
                                    );
                                    return;
                                  }
                                  showDialog<void>(
                                    context: context,
                                    builder: (_) => ExportDialog(
                                      questions: exportQuestions,
                                      responses: exportResponses,
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Export Excel / SPSS'),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: isPhone,
                              value: analyticsState.selectedQuestionnaireId ??
                                  questionnaires.first.id,
                              items: questionnaires.map((q) {
                                return DropdownMenuItem(
                                  value: q.id,
                                  child: Text(q.title,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  ref
                                      .read(analyticsProvider(widget.projectId)
                                          .notifier)
                                      .loadAnalyticsForQuestionnaire(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            if (!isPhone || !_compactPhoneHeader) const SizedBox(height: 20),

            // Metrics Row (Data Quality, Completion Rate, Total N)
            if (!isPhone || !_compactPhoneHeader)
              isPhone
                  ? GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.35,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMetricCard(
                          title: 'Data Quality Score',
                          value:
                              '${analyticsState.qualityScore.toStringAsFixed(1)}%',
                          icon: Icons.verified_rounded,
                          color: const Color(0xFF00897B),
                          bg: const Color(0xFFE0F2F1),
                        ),
                        _buildMetricCard(
                          title: 'Form Completion Rate',
                          value:
                              '${analyticsState.completionRate.toStringAsFixed(1)}%',
                          icon: Icons.task_alt_rounded,
                          color: const Color(0xFF1565C0),
                          bg: const Color(0xFFE3F2FD),
                        ),
                        _buildMetricCard(
                          title: 'Analysed Questions',
                          value: '${analyticsState.results.length}',
                          icon: Icons.analytics_rounded,
                          color: const Color(0xFF7B1FA2),
                          bg: const Color(0xFFF3E5F5),
                        ),
                        _buildMetricCard(
                          title: 'Inference Tools',
                          value: '95% CI • χ²',
                          icon: Icons.functions_rounded,
                          color: const Color(0xFFF57C00),
                          bg: const Color(0xFFFFF3E0),
                        ),
                      ],
                    )
                  : Row(children: [
                      Expanded(
                          child: _buildMetricCard(
                              title: 'Data Quality Score',
                              value:
                                  '${analyticsState.qualityScore.toStringAsFixed(1)}%',
                              icon: Icons.verified_rounded,
                              color: const Color(0xFF00897B),
                              bg: const Color(0xFFE0F2F1))),
                      const SizedBox(width: 14),
                      Expanded(
                          child: _buildMetricCard(
                              title: 'Form Completion Rate',
                              value:
                                  '${analyticsState.completionRate.toStringAsFixed(1)}%',
                              icon: Icons.task_alt_rounded,
                              color: const Color(0xFF1565C0),
                              bg: const Color(0xFFE3F2FD))),
                      const SizedBox(width: 14),
                      Expanded(
                          child: _buildMetricCard(
                              title: 'Analysed Questions',
                              value: '${analyticsState.results.length}',
                              icon: Icons.analytics_rounded,
                              color: const Color(0xFF7B1FA2),
                              bg: const Color(0xFFF3E5F5))),
                      const SizedBox(width: 14),
                      Expanded(
                          child: _buildMetricCard(
                              title: 'Inference Tools',
                              value: '95% CI • χ²',
                              icon: Icons.functions_rounded,
                              color: const Color(0xFFF57C00),
                              bg: const Color(0xFFFFF3E0))),
                    ]),
            if (!isPhone || !_compactPhoneHeader) const SizedBox(height: 20),

            // Tab Bar
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppTheme.kPrimary,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: AppTheme.kPrimary,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(
                      icon: Icon(Icons.table_chart_rounded),
                      text: 'Descriptive Statistics'),
                  Tab(
                      icon: Icon(Icons.bar_chart_rounded),
                      text: 'Visual Distribution Charts'),
                  Tab(
                      icon: Icon(Icons.grid_on_rounded),
                      text: 'Cross-Tabulation & Chi-Square'),
                  Tab(
                      icon: Icon(Icons.science_rounded),
                      text: 'Advanced Tests'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Views
            Expanded(
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (!isPhone ||
                      notification.direction == ScrollDirection.idle) {
                    return false;
                  }
                  final compact =
                      notification.direction == ScrollDirection.reverse;
                  if (compact != _compactPhoneHeader) {
                    setState(() => _compactPhoneHeader = compact);
                  }
                  return false;
                },
                child: analyticsState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : analyticsState.results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.insert_chart_outlined_rounded,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 14),
                                Text(
                                  'No responses collected yet for analysis',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Fill out questionnaire responses to generate automated statistics and charts.',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500),
                                ),
                                const SizedBox(height: 16),
                                if (analyticsState.selectedQuestionnaireId !=
                                    null)
                                  ElevatedButton.icon(
                                    onPressed: () => context.go(
                                        '/data-collection/${analyticsState.selectedQuestionnaireId}'),
                                    icon: const Icon(Icons.play_circle_outline),
                                    label: const Text('Collect Responses Now'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.kPrimary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              // 1. Descriptive statistics list
                              _buildDescriptiveTab(analyticsState.results),

                              // 2. Charts view
                              _buildChartsTab(analyticsState.results),

                              // 3. Cross-Tabulation
                              _buildCrossTabTab(analyticsState.results,
                                  analyticsState.selectedQuestionnaireId),

                              // 4. Correlation and group comparisons
                              _buildAdvancedTestsTab(analyticsState.results,
                                  analyticsState.selectedQuestionnaireId),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSelector(
    List<ResearchProject> projects,
    Map<String, DateTime> activityByProject,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.folder_copy_outlined,
                size: 18, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text('Research projects',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569))),
            const SizedBox(width: 8),
            Text('Most recently active first',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: const Color(0xFF94A3B8))),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final project = projects[index];
              final selected = project.id == widget.projectId;
              final activity =
                  activityByProject[project.id] ?? project.updatedAt;
              final age = DateTime.now().difference(activity);
              final activityText = age.inMinutes < 2
                  ? 'Active now'
                  : age.inHours < 24
                      ? '${age.inHours}h ago'
                      : age.inDays < 30
                          ? '${age.inDays}d ago'
                          : '${activity.day}/${activity.month}/${activity.year}';
              return Material(
                color: selected ? const Color(0xFFE0F2F1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: selected
                      ? null
                      : () => context.go('/analytics/${project.id}'),
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected
                              ? AppTheme.kPrimary
                              : const Color(0xFFE2E8F0),
                          width: selected ? 1.5 : 1),
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: selected
                            ? AppTheme.kPrimary
                            : const Color(0xFFF1F5F9),
                        child: Icon(Icons.analytics_outlined,
                            size: 20,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(project.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B))),
                            Text(activityText,
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: selected
                                        ? const Color(0xFF00796B)
                                        : const Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptiveTab(List<AnalyticsResult> results) {
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, idx) {
        final r = results[idx];
        final isNumeric = r.mean != null;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Q${idx + 1}. ${r.questionText}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      r.type.name.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (isNumeric) ...[
                // Mean, Median, StdDev, Min, Max
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _statBadge(
                        'Mean (μ)',
                        r.mean?.toStringAsFixed(ref
                                .watch(appSettingsProvider)
                                .decimalPrecision) ??
                            '-',
                        const Color(0xFF1565C0)),
                    _statBadge(
                        'Median (M)',
                        r.median?.toStringAsFixed(ref
                                .watch(appSettingsProvider)
                                .decimalPrecision) ??
                            '-',
                        const Color(0xFF00897B)),
                    _statBadge(
                        'Std Dev (σ)',
                        r.stdDev?.toStringAsFixed(ref
                                .watch(appSettingsProvider)
                                .decimalPrecision) ??
                            '-',
                        const Color(0xFFF57C00)),
                    _statBadge('Min', r.min?.toStringAsFixed(1) ?? '-',
                        Colors.grey.shade700),
                    _statBadge('Max', r.max?.toStringAsFixed(1) ?? '-',
                        Colors.grey.shade700),
                    _statBadge(
                        'Count (n)', '${r.count}', const Color(0xFF7B1FA2)),
                    if (r.mean != null && r.stdDev != null && r.count > 1)
                      _statBadge(
                        '95% CI for mean',
                        (() {
                          final ci = StatisticsUtils.meanConfidenceInterval95(
                              r.mean!, r.stdDev!, r.count);
                          return '${ci.first.toStringAsFixed(ref.watch(appSettingsProvider).decimalPrecision)} to ${ci.last.toStringAsFixed(ref.watch(appSettingsProvider).decimalPrecision)}';
                        })(),
                        const Color(0xFF5D4037),
                      ),
                  ],
                ),
              ] else ...[
                // Frequency table
                Table(
                  border: TableBorder.all(color: Colors.grey.shade200),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                      children: [
                        _tableCell('Response Value', isHeader: true),
                        _tableCell('Frequency (f)', isHeader: true),
                        _tableCell('Percentage (%)', isHeader: true),
                      ],
                    ),
                    ...r.frequencies.entries.map((entry) {
                      final pct =
                          r.count > 0 ? (entry.value / r.count) * 100 : 0.0;
                      return TableRow(
                        children: [
                          _tableCell(entry.key),
                          _tableCell('${entry.value}'),
                          _tableCell('${pct.toStringAsFixed(1)}%'),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _statBadge(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 2),
          Text(val,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
          color: isHeader ? const Color(0xFF1E293B) : const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildChartsTab(List<AnalyticsResult> results) {
    return ListView(children: [
      Padding(
          padding: const EdgeInsets.all(12),
          child: Text(_analysisSummary(results))),
      const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
              'Choose a presentation for each variable. Every chart includes full labels, counts and percentages. Multi-select percentages use total selections.')),
      ...results
          .map((r) => ChartExplorer(key: ValueKey(r.questionId), result: r)),
      const SizedBox(height: 110),
    ]);
  }

  String _analysisSummary(List<AnalyticsResult> results) {
    final numeric = results.where((result) => result.mean != null).toList();
    final categorical = results.where((result) => result.mean == null).toList();
    final parts = <String>[
      '${results.length} variables are available for visual analysis.',
    ];
    if (numeric.isNotEmpty) {
      final widest = numeric.reduce((a, b) =>
          ((a.max ?? 0) - (a.min ?? 0)) >= ((b.max ?? 0) - (b.min ?? 0))
              ? a
              : b);
      parts.add(
          '“${widest.questionText}” has the widest observed numeric range (${widest.min?.toStringAsFixed(ref.watch(appSettingsProvider).decimalPrecision)} to ${widest.max?.toStringAsFixed(ref.watch(appSettingsProvider).decimalPrecision)}).');
    }
    if (categorical.isNotEmpty) {
      final first = categorical.first;
      if (first.frequencies.isNotEmpty) {
        final leading = first.frequencies.entries
            .reduce((a, b) => a.value >= b.value ? a : b);
        parts.add(
            'For “${first.questionText}”, the most frequent response is “${leading.key}” (${leading.value} records).');
      }
    }
    return parts.join(' ');
  }

  Widget _buildCrossTabTab(
      List<AnalyticsResult> results, String? questionnaireId) {
    final categorical = results
        .where((result) => const {
              QuestionType.singleChoice,
              QuestionType.yesNo,
              QuestionType.thumbs,
              QuestionType.likertScale,
              QuestionType.rating,
            }.contains(result.type))
        .toList();
    if (categorical.length < 2) {
      return Center(
        child: Text(
          'Add at least two categorical, Likert, rating, yes/no or like/dislike questions to run a cross-tabulation.',
          style: GoogleFonts.poppins(color: Colors.grey.shade600),
        ),
      );
    }

    if (!categorical.any((r) => r.questionId == _crossTabRowQId)) {
      _crossTabRowQId = categorical.first.questionId;
    }
    if (!categorical.any((r) => r.questionId == _crossTabColQId) ||
        _crossTabColQId == _crossTabRowQId) {
      _crossTabColQId = categorical[1].questionId;
    }

    final rowQ = categorical.firstWhere((r) => r.questionId == _crossTabRowQId,
        orElse: () => categorical.first);
    final colQ = categorical.firstWhere((r) => r.questionId == _crossTabColQId,
        orElse: () => categorical[1]);

    final responsesState = questionnaireId != null
        ? ref.watch(responsesProvider(questionnaireId))
        : null;
    final allResponses = responsesState?.responses ?? [];

    final rowVals = <String>[];
    final colVals = <String>[];
    var excludedMissing = 0;
    for (final response in allResponses) {
      final row = response.responses[rowQ.questionId]?.toString().trim();
      final column = response.responses[colQ.questionId]?.toString().trim();
      final missing =
          row == null || row.isEmpty || column == null || column.isEmpty;
      if (missing && !_includeMissingInCrossTab) {
        excludedMissing++;
        continue;
      }
      rowVals.add(row == null || row.isEmpty ? '(Missing)' : row);
      colVals.add(column == null || column.isEmpty ? '(Missing)' : column);
    }

    final crossTable = StatisticsUtils.crossTabulate(rowVals, colVals);
    final chiResult = StatisticsUtils.chiSquareTest(crossTable);
    Map<String, double>? diagnostic;
    final yesRow = crossTable.keys.where((key) => key.toUpperCase() == 'YES');
    final noRow = crossTable.keys.where((key) => key.toUpperCase() == 'NO');
    if (yesRow.isNotEmpty && noRow.isNotEmpty) {
      final yesColumns = crossTable.values
          .expand((row) => row.keys)
          .where((key) => key.toUpperCase() == 'YES');
      final noColumns = crossTable.values
          .expand((row) => row.keys)
          .where((key) => key.toUpperCase() == 'NO');
      if (yesColumns.isNotEmpty && noColumns.isNotEmpty) {
        diagnostic = StatisticsUtils.diagnosticAccuracy(
          truePositive: crossTable[yesRow.first]?[yesColumns.first] ?? 0,
          falsePositive: crossTable[yesRow.first]?[noColumns.first] ?? 0,
          falseNegative: crossTable[noRow.first]?[yesColumns.first] ?? 0,
          trueNegative: crossTable[noRow.first]?[noColumns.first] ?? 0,
        );
      }
    }

    final rowKeys = crossTable.keys.toList();
    final colKeys = <String>{};
    for (final r in rowKeys) {
      colKeys.addAll(crossTable[r]!.keys);
    }
    final colList = colKeys.toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selectors
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isPhone = constraints.maxWidth < 600;
                final selector = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Row Variable (X)',
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _crossTabRowQId,
                      items: categorical
                          .map((r) => DropdownMenuItem(
                                value: r.questionId,
                                child: Text(r.questionText,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _crossTabRowQId = v),
                    ),
                  ],
                );
                final columnSelector = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Column Variable (Y)',
                        style: GoogleFonts.poppins(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _crossTabColQId,
                      items: categorical
                          .map((r) => DropdownMenuItem(
                                value: r.questionId,
                                child: Text(r.questionText,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _crossTabColQId = v),
                    ),
                  ],
                );
                final options = Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    FilterChip(
                        label: const Text('Show row percentages'),
                        selected: _showRowPercentages,
                        onSelected: (value) =>
                            setState(() => _showRowPercentages = value)),
                    FilterChip(
                        label: const Text('Include missing answers'),
                        selected: _includeMissingInCrossTab,
                        onSelected: (value) =>
                            setState(() => _includeMissingInCrossTab = value)),
                    Text(
                        '${rowVals.length} complete records${excludedMissing > 0 ? ' • $excludedMissing excluded for missing data' : ''}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey.shade700)),
                  ],
                );
                if (isPhone) {
                  return Column(children: [
                    selector,
                    const SizedBox(height: 12),
                    columnSelector,
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerLeft, child: options)
                  ]);
                }
                return Row(
                  children: [
                    Expanded(
                      child: selector,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: columnSelector,
                    ),
                    const SizedBox(height: 10),
                    options,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 18),

          // Cross Tab Table
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contingency Table (Frequencies)',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 700),
                      child: DataTable(
                        border: TableBorder.all(color: Colors.grey.shade200),
                        headingRowColor:
                            MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                        columns: [
                          DataColumn(
                              label: Text(
                                  '${rowQ.questionText.split(' ').first} \\ ${colQ.questionText.split(' ').first}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700))),
                          ...colList.map((c) => DataColumn(
                              label: Text(c,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)))),
                          const DataColumn(
                              label: Text('Row Total',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700))),
                        ],
                        rows: rowKeys.map((r) {
                          int rowTotal = 0;
                          return DataRow(
                            cells: [
                              DataCell(Text(r,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600))),
                              ...colList.map((c) {
                                final count = crossTable[r]?[c] ?? 0;
                                rowTotal += count;
                                final total = crossTable[r]?.values.fold<int>(
                                        0, (sum, value) => sum + value) ??
                                    0;
                                final percentage =
                                    total == 0 ? 0.0 : (count / total) * 100;
                                return DataCell(Text(_showRowPercentages
                                    ? '$count (${percentage.toStringAsFixed(1)}%)'
                                    : '$count'));
                              }),
                              DataCell(Text('$rowTotal',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                            ],
                          );
                        }).toList(),
                      )),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Chi-Square Test Results
                Row(
                  children: [
                    const Icon(Icons.psychology_rounded,
                        color: AppTheme.kPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'Chi-Square Test of Independence',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Chi² = ${chiResult['chiSquare']?.toStringAsFixed(3)} • df = ${chiResult['degreesOfFreedom']?.toInt()} • ${_interpretPValue(chiResult['pValue'] ?? 1.0)}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Cramer's V = ${chiResult['cramerV']?.toStringAsFixed(3)} • Minimum expected count = ${chiResult['minExpected']?.toStringAsFixed(ref.watch(appSettingsProvider).decimalPrecision)}",
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Interpretation: ${_interpretPValue(chiResult['pValue'] ?? 1)}. The association is ${_effectStrength(chiResult['cramerV'] ?? 0)} in magnitude; this does not establish causation.',
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                if ((chiResult['cellsBelowFive'] ?? 0) > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Assumption warning: ${chiResult['cellsBelowFive']?.toInt()} of ${chiResult['totalCells']?.toInt()} cells have expected counts below 5. If more than 20% of cells are affected, combine defensible categories or report that chi-square may be unreliable. For a 2×2 table with small counts, use Fisher’s exact test in specialist software.',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.orange.shade900),
                  ),
                ],
                if (diagnostic != null) ...[
                  const SizedBox(height: 14),
                  Text(
                      'Diagnostic accuracy (column variable as reference standard)',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 12, runSpacing: 8, children: [
                    _statBadge('Sensitivity',
                        _percent(diagnostic['sensitivity']), AppTheme.kPrimary),
                    _statBadge(
                        'Specificity',
                        _percent(diagnostic['specificity']),
                        const Color(0xFF1565C0)),
                    _statBadge(
                        'PPV',
                        _percent(diagnostic['positivePredictiveValue']),
                        const Color(0xFF7B1FA2)),
                    _statBadge(
                        'NPV',
                        _percent(diagnostic['negativePredictiveValue']),
                        const Color(0xFFF57C00)),
                    _statBadge('Accuracy', _percent(diagnostic['accuracy']),
                        const Color(0xFF00897B)),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _percent(double? value) => value == null || value.isNaN
      ? 'N/A'
      : '${(value * 100).toStringAsFixed(1)}%';

  Widget _buildAdvancedTestsTab(
      List<AnalyticsResult> results, String? questionnaireId) {
    final numeric = results
        .where((r) =>
            r.type == QuestionType.number ||
            r.type == QuestionType.rating ||
            r.type == QuestionType.likertScale)
        .toList();
    final categorical = results
        .where((r) =>
            r.type == QuestionType.singleChoice ||
            r.type == QuestionType.yesNo ||
            r.type == QuestionType.thumbs)
        .toList();
    if (questionnaireId == null) return const SizedBox.shrink();
    final responses = ref.watch(responsesProvider(questionnaireId)).responses;

    if (numeric.isNotEmpty) {
      _correlationXId ??= numeric.first.questionId;
      _outcomeVariableId ??= numeric.first.questionId;
    }
    if (numeric.length > 1) _correlationYId ??= numeric[1].questionId;
    if (categorical.isNotEmpty)
      _groupVariableId ??= categorical.first.questionId;

    Map<String, double>? correlation, paired, regression, anova;
    final scatter = <FlSpot>[];
    if (_correlationXId != null && _correlationYId != null) {
      final x = <double>[], y = <double>[];
      for (final response in responses) {
        final xv =
            double.tryParse(response.responses[_correlationXId].toString());
        final yv =
            double.tryParse(response.responses[_correlationYId].toString());
        if (xv != null && yv != null && xv.isFinite && yv.isFinite) {
          x.add(xv);
          y.add(yv);
          scatter.add(FlSpot(xv, yv));
        }
      }
      correlation = StatisticsUtils.pearsonCorrelationTest(x, y);
      paired = StatisticsUtils.pairedTTest(x, y);
      regression = StatisticsUtils.simpleLinearRegression(x, y);
    }

    Map<String, double>? tTest;
    List<String> groupNames = const [];
    if (_groupVariableId != null && _outcomeVariableId != null) {
      final grouped = <String, List<double>>{};
      for (final response in responses) {
        final group = response.responses[_groupVariableId]?.toString();
        final value =
            double.tryParse(response.responses[_outcomeVariableId].toString());
        if (group != null && value != null && value.isFinite) {
          grouped.putIfAbsent(group, () => []).add(value);
        }
      }
      anova = StatisticsUtils.oneWayAnova(grouped.values.toList());
      if (grouped.length == 2) {
        groupNames = grouped.keys.toList();
        tTest = StatisticsUtils.welchTTest(
            grouped[groupNames[0]]!, grouped[groupNames[1]]!);
      }
    }

    DropdownButton<String> selector(String? value,
            List<AnalyticsResult> choices, ValueChanged<String?> changed) =>
        DropdownButton<String>(
          value: choices.any((r) => r.questionId == value) ? value : null,
          isExpanded: true,
          items: choices
              .map((r) => DropdownMenuItem(
                  value: r.questionId,
                  child: Text(r.questionText, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: changed,
        );

    return ListView(children: [
      _analysisPanel(
        title: 'Pearson Correlation',
        subtitle:
            'Tests the linear relationship between two numeric variables using complete paired records.',
        controls: Row(children: [
          Expanded(
              child: selector(_correlationXId, numeric,
                  (v) => setState(() => _correlationXId = v))),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('versus')),
          Expanded(
              child: selector(_correlationYId, numeric,
                  (v) => setState(() => _correlationYId = v))),
        ]),
        result: numeric.length < 2
            ? 'Add at least two numeric questions.'
            : 'r = ${correlation?['r']?.toStringAsFixed(3) ?? 'N/A'} • n = ${correlation?['n']?.toInt() ?? 0} • ${_interpretPValue(correlation?['pValue'] ?? 1)} • ${_effectStrength(correlation?['r'] ?? 0)} linear relationship\nCheck the scatter plot for outliers and curvature. Correlation does not imply causation.',
      ),
      const SizedBox(height: 16),
      _analysisPanel(
        title: 'Welch Independent-Samples t-Test',
        subtitle:
            'Compares the numeric outcome mean across exactly two groups without assuming equal variances.',
        controls: Row(children: [
          Expanded(
              child: selector(_groupVariableId, categorical,
                  (v) => setState(() => _groupVariableId = v))),
          const SizedBox(width: 16),
          Expanded(
              child: selector(_outcomeVariableId, numeric,
                  (v) => setState(() => _outcomeVariableId = v))),
        ]),
        result: tTest == null || (tTest['pValue']?.isNaN ?? true)
            ? 'Select a categorical variable containing exactly two groups and a numeric outcome; each group needs at least two observations.'
            : '${groupNames[0]} mean = ${tTest['mean1']?.toStringAsFixed(ref.watch(appSettingsProvider).decimalPrecision)} (n=${tTest['n1']?.toInt()}) • ${groupNames[1]} mean = ${tTest['mean2']?.toStringAsFixed(ref.watch(appSettingsProvider).decimalPrecision)} (n=${tTest['n2']?.toInt()})\nWelch t = ${tTest['t']?.toStringAsFixed(3)} • df = ${tTest['degreesOfFreedom']?.toStringAsFixed(1)} • Cohen’s d = ${tTest['cohensD']?.toStringAsFixed(3)} (${_effectStrength(tTest['cohensD'] ?? 0)}) • ${_interpretPValue(tTest['pValue']!)}',
      ),
      const SizedBox(height: 16),
      Text(
          'Statistical results support research interpretation and do not by themselves establish causation or a medical diagnosis.',
          style:
              GoogleFonts.poppins(fontSize: 12, color: Colors.orange.shade900)),
      const SizedBox(height: 16),
      _analysisPanel(
          title: 'Paired samples (Y − X)',
          subtitle:
              'Uses the two numeric variables selected above. Use only when each row contains measurements from the same subject, before and after. Differences should be approximately normal.',
          controls: const SizedBox.shrink(),
          result: paired == null || !(paired!['pValue']?.isFinite ?? false)
              ? 'At least two complete pairs with variation in their differences are required.'
              : 'n=${paired!['n']!.toInt()} • Mean difference=${paired!['difference']!.toStringAsFixed(3)} • t=${paired!['t']!.toStringAsFixed(3)} • df=${paired!['df']!.toInt()} • 95% CI [${paired!['lower']!.toStringAsFixed(3)}, ${paired!['upper']!.toStringAsFixed(3)}] • ${_interpretPValue(paired!['pValue']!)}'),
      const SizedBox(height: 16),
      _analysisPanel(
          title: 'One-way ANOVA',
          subtitle:
              'Uses the selected grouping variable and outcome above. Assumes independent observations, approximately normal residuals and similar group variances. This is an overall test, not a post-hoc comparison.',
          controls: const SizedBox.shrink(),
          result: anova == null || !(anova!['pValue']?.isFinite ?? false)
              ? 'Choose two or more groups, each with at least two numeric observations and nonzero within-group variation.'
              : 'F=${anova!['f']!.toStringAsFixed(3)} • df=(${anova!['df1']!.toInt()},${anova!['df2']!.toInt()}) • η²=${anova!['etaSquared']!.toStringAsFixed(3)} (${_effectStrength(anova!['etaSquared']!)}) • ${_interpretPValue(anova!['pValue']!)}\nA significant overall result means at least one group differs; use a justified post-hoc procedure in specialist software to identify which groups.'),
      const SizedBox(height: 16),
      _analysisPanel(
          title: 'Simple linear regression',
          subtitle:
              'Predicts the second numeric variable (Y) from the first (X). Inspect linearity, outliers, independent errors and constant residual variance.',
          controls: const SizedBox.shrink(),
          result: regression == null ||
                  !(regression!['slope']?.isFinite ?? false)
              ? 'Select two nonconstant numeric variables and at least three complete pairs.'
              : 'Y = ${regression!['intercept']!.toStringAsFixed(3)} + ${regression!['slope']!.toStringAsFixed(3)} × X • R²=${regression!['rSquared']!.toStringAsFixed(3)} (${(regression!['rSquared']! * 100).toStringAsFixed(1)}% of variance explained) • ${_interpretPValue(regression!['pValue']!)}'),
      if (scatter.isNotEmpty) ...[
        const SizedBox(height: 16),
        Text(
            'Scatter plot: X = ${numeric.where((r) => r.questionId == _correlationXId).map((r) => r.questionText).join()}\nY = ${numeric.where((r) => r.questionId == _correlationYId).map((r) => r.questionText).join()}'),
        SizedBox(
            height: 280,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: ScatterChart(ScatterChartData(
                    scatterSpots:
                        scatter.map((p) => ScatterSpot(p.x, p.y)).toList(),
                    titlesData: const FlTitlesData(
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false))))))),
      ],
      const SizedBox(height: 110),
    ]);
  }

  Widget _analysisPanel({
    required String title,
    required String subtitle,
    required Widget controls,
    required String result,
  }) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          controls,
          const Divider(height: 28),
          Text(result,
              style: GoogleFonts.poppins(
                  fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
        ]),
      );
}
