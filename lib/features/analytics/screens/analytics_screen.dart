import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/app_models.dart';
import '../../../core/providers/analytics_provider.dart';
import '../../../core/providers/app_settings_provider.dart';
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
  String _correlationMethod = 'Pearson';
  bool _includeMissingInCrossTab = false;
  String _crossTabPercentageMode = 'Row %';
  String? _crossTabReport;
  String _descriptiveQuery = '';
  String _descriptiveSort = 'Question order';

  String _effectStrength(double value) {
    final magnitude = value.abs();
    if (magnitude < .10) return 'negligible';
    if (magnitude < .30) return 'small';
    if (magnitude < .50) return 'moderate';
    return 'large';
  }

  String _formatPValue(double? value) {
    if (value == null || !value.isFinite) return 'p unavailable';
    return value < .001 ? 'p < .001' : 'p = ${value.toStringAsFixed(3)}';
  }

  String _cohensDStrength(double value) {
    final magnitude = value.abs();
    if (magnitude < .2) return 'negligible';
    if (magnitude < .5) return 'small';
    if (magnitude < .8) return 'moderate';
    return 'large';
  }

  String _etaSquaredStrength(double value) {
    if (value < .01) return 'negligible';
    if (value < .06) return 'small';
    if (value < .14) return 'moderate';
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
    final useCompactLayout =
        isPhone || MediaQuery.sizeOf(context).height < 500;
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
    final numericVariableCount = analyticsState.results
        .where((result) => const {
              QuestionType.number,
              QuestionType.rating,
              QuestionType.likertScale,
            }.contains(result.type))
        .length;
    final categoricalVariableCount = analyticsState.results
        .where((result) => const {
              QuestionType.singleChoice,
              QuestionType.multipleChoice,
              QuestionType.yesNo,
              QuestionType.thumbs,
            }.contains(result.type))
        .length;
    final totalAnswerSlots = exportResponses.length * exportQuestions.length;
    final answeredSlots = analyticsState.results
        .fold<int>(0, (total, result) => total + result.answeredCount);
    final answerCoverage = totalAnswerSlots == 0
        ? 0.0
        : (answeredSlots / totalAnswerSlots * 100).clamp(0.0, 100.0);
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
      body: useCompactLayout
          ? _buildPhoneAnalyticsLayout(
              analyticsState: analyticsState,
              projectTitle: project?.title ?? 'Academic Study',
              projects: allProjects,
              activityByProject: activityByProject,
              hasQuestionnaires: questionnaires.isNotEmpty,
              exportQuestions: exportQuestions,
              exportResponses: exportResponses,
              numericVariableCount: numericVariableCount,
              categoricalVariableCount: categoricalVariableCount,
              answerCoverage: answerCoverage,
            )
          : Padding(
              padding: EdgeInsets.all(isPhone ? 16 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (allProjects.isNotEmpty) ...[
                    _buildProjectSelector(allProjects, activityByProject),
                    const SizedBox(height: 18),
                  ],
                  // Top Nav & Title
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
                                      showDialog<void>(
                                        context: context,
                                        builder: (_) => ExportDialog(
                                          questions: exportQuestions,
                                          responses: exportResponses,
                                        ),
                                      );
                                    },
                              icon:
                                  const Icon(Icons.download_rounded, size: 18),
                              label: const Text('Export Excel / SPSS'),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Metrics Row (Data Quality, Completion Rate, Total N)
                  isPhone
                      ? GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 1.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildMetricCard(
                              title: 'Respondents (N)',
                              value: '${exportResponses.length}',
                              icon: Icons.people_alt_rounded,
                              color: const Color(0xFF00897B),
                              bg: const Color(0xFFE0F2F1),
                            ),
                            _buildMetricCard(
                              title: 'Numeric variables',
                              value: '$numericVariableCount',
                              icon: Icons.show_chart_rounded,
                              color: const Color(0xFF1565C0),
                              bg: const Color(0xFFE3F2FD),
                            ),
                            _buildMetricCard(
                              title: 'Categorical variables',
                              value: '$categoricalVariableCount',
                              icon: Icons.category_rounded,
                              color: const Color(0xFF7B1FA2),
                              bg: const Color(0xFFF3E5F5),
                            ),
                            _buildMetricCard(
                              title: 'Answer coverage',
                              value: '${answerCoverage.toStringAsFixed(1)}%',
                              icon: Icons.functions_rounded,
                              color: const Color(0xFFF57C00),
                              bg: const Color(0xFFFFF3E0),
                            ),
                          ],
                        )
                      : Row(children: [
                          Expanded(
                              child: _buildMetricCard(
                                  title: 'Respondents (N)',
                                  value: '${exportResponses.length}',
                                  icon: Icons.people_alt_rounded,
                                  color: const Color(0xFF00897B),
                                  bg: const Color(0xFFE0F2F1))),
                          const SizedBox(width: 14),
                          Expanded(
                              child: _buildMetricCard(
                                  title: 'Numeric variables',
                                  value: '$numericVariableCount',
                                  icon: Icons.show_chart_rounded,
                                  color: const Color(0xFF1565C0),
                                  bg: const Color(0xFFE3F2FD))),
                          const SizedBox(width: 14),
                          Expanded(
                              child: _buildMetricCard(
                                  title: 'Categorical variables',
                                  value: '$categoricalVariableCount',
                                  icon: Icons.category_rounded,
                                  color: const Color(0xFF7B1FA2),
                                  bg: const Color(0xFFF3E5F5))),
                          const SizedBox(width: 14),
                          Expanded(
                              child: _buildMetricCard(
                                  title: 'Answer coverage',
                                  value:
                                      '${answerCoverage.toStringAsFixed(1)}%',
                                  icon: Icons.functions_rounded,
                                  color: const Color(0xFFF57C00),
                                  bg: const Color(0xFFFFF3E0))),
                        ]),
                  const SizedBox(height: 20),

                  // Tab Bar
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border:
                          Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: !isPhone,
                      tabAlignment:
                          isPhone ? TabAlignment.fill : TabAlignment.start,
                      labelColor: AppTheme.kPrimary,
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorColor: AppTheme.kPrimary,
                      indicatorWeight: 3,
                      labelPadding:
                          EdgeInsets.symmetric(horizontal: isPhone ? 4 : 12),
                      labelStyle: GoogleFonts.poppins(
                        fontSize: isPhone ? 9 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: [
                        Tab(
                          icon: Icon(Icons.table_chart_rounded,
                              size: isPhone ? 16 : 22),
                          text: isPhone
                              ? 'Descriptive'
                              : 'Descriptive Statistics',
                        ),
                        Tab(
                          icon: Icon(Icons.bar_chart_rounded,
                              size: isPhone ? 16 : 22),
                          text:
                              isPhone ? 'Charts' : 'Visual Distribution Charts',
                        ),
                        Tab(
                          icon: Icon(Icons.grid_on_rounded,
                              size: isPhone ? 16 : 22),
                          text: isPhone
                              ? 'Chi-square'
                              : 'Cross-Tabulation & Chi-Square',
                        ),
                        Tab(
                          icon: _DefiniteIntegralIcon(size: isPhone ? 16 : 22),
                          text: isPhone ? 'Advanced' : 'Advanced Tests',
                        ),
                      ],
                    ),
                  ),
                  if (analyticsState.isLoading &&
                      analyticsState.results.isNotEmpty)
                    const LinearProgressIndicator(minHeight: 2),
                  const SizedBox(height: 16),

                  // Tab Views
                  Expanded(
                    child: analyticsState.isLoading &&
                            analyticsState.results.isEmpty
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
                                    if (analyticsState
                                            .selectedQuestionnaireId !=
                                        null)
                                      ElevatedButton.icon(
                                        onPressed: () => context.go(
                                            '/data-collection/${analyticsState.selectedQuestionnaireId}'),
                                        icon: const Icon(
                                            Icons.play_circle_outline),
                                        label:
                                            const Text('Collect Responses Now'),
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
                                key: PageStorageKey<String>(
                                    'analytics-tabs-${widget.projectId}'),
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
                ],
              ),
            ),
    );
  }

  Widget _buildPhoneAnalyticsLayout({
    required AnalyticsState analyticsState,
    required String projectTitle,
    required List<ResearchProject> projects,
    required Map<String, DateTime> activityByProject,
    required bool hasQuestionnaires,
    required List<Question> exportQuestions,
    required List<QuestionnaireResponse> exportResponses,
    required int numericVariableCount,
    required int categoricalVariableCount,
    required double answerCoverage,
  }) {
    final accent = Theme.of(context).colorScheme.primary;
    final tabBar = Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        tabAlignment: TabAlignment.fill,
        labelColor: accent,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: accent,
        indicatorWeight: 3,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        labelStyle:
            GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600),
        tabs: [
          const Tab(
              icon: Icon(Icons.table_chart_rounded, size: 16),
              text: 'Descriptive'),
          const Tab(
              icon: Icon(Icons.bar_chart_rounded, size: 16), text: 'Charts'),
          const Tab(
              icon: Icon(Icons.grid_on_rounded, size: 16), text: 'Chi-square'),
          Tab(icon: _DefiniteIntegralIcon(size: 16), text: 'Advanced'),
        ],
      ),
    );

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (projects.isNotEmpty) ...[
                  _buildProjectSelector(projects, activityByProject),
                  const SizedBox(height: 14),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () =>
                          context.go('/projects/${widget.projectId}'),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statistical Analysis & Analytics',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              'Project: $projectTitle • Automated analysis',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasQuestionnaires) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      onPressed:
                          exportQuestions.isEmpty || exportResponses.isEmpty
                              ? null
                              : () => showDialog<void>(
                                    context: context,
                                    builder: (_) => ExportDialog(
                                      questions: exportQuestions,
                                      responses: exportResponses,
                                    ),
                                  ),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Export Excel / SPSS'),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildMetricCard(
                      title: 'Respondents (N)',
                      value: '${exportResponses.length}',
                      icon: Icons.people_alt_rounded,
                      color: const Color(0xFF00897B),
                      bg: const Color(0xFFE0F2F1),
                    ),
                    _buildMetricCard(
                      title: 'Numeric variables',
                      value: '$numericVariableCount',
                      icon: Icons.show_chart_rounded,
                      color: const Color(0xFF1565C0),
                      bg: const Color(0xFFE3F2FD),
                    ),
                    _buildMetricCard(
                      title: 'Categorical variables',
                      value: '$categoricalVariableCount',
                      icon: Icons.category_rounded,
                      color: const Color(0xFF7B1FA2),
                      bg: const Color(0xFFF3E5F5),
                    ),
                    _buildMetricCard(
                      title: 'Answer coverage',
                      value: '${answerCoverage.toStringAsFixed(1)}%',
                      icon: Icons.functions_rounded,
                      color: const Color(0xFFF57C00),
                      bg: const Color(0xFFFFF3E0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _AnalyticsTabBarDelegate(tabBar),
        ),
        if (analyticsState.isLoading && analyticsState.results.isNotEmpty)
          const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2)),
      ],
      body: _buildAnalyticsTabContent(analyticsState),
    );
  }

  Widget _buildAnalyticsTabContent(AnalyticsState analyticsState) {
    if (analyticsState.isLoading && analyticsState.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (analyticsState.results.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insert_chart_outlined_rounded,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 14),
              Text(
                'No responses collected yet for analysis',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              Text(
                'Fill out questionnaire responses to generate automated statistics and charts.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey.shade500),
              ),
              if (analyticsState.selectedQuestionnaireId != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go(
                      '/data-collection/${analyticsState.selectedQuestionnaireId}'),
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Collect Responses Now'),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return TabBarView(
      controller: _tabController,
      key: PageStorageKey<String>('analytics-tabs-${widget.projectId}'),
      children: [
        _buildDescriptiveTab(analyticsState.results),
        _buildChartsTab(analyticsState.results),
        _buildCrossTabTab(
            analyticsState.results, analyticsState.selectedQuestionnaireId),
        _buildAdvancedTestsTab(
            analyticsState.results, analyticsState.selectedQuestionnaireId),
      ],
    );
  }

  Widget _buildProjectSelector(
    List<ResearchProject> projects,
    Map<String, DateTime> activityByProject,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            const Icon(Icons.folder_copy_outlined,
                size: 18, color: Color(0xFF64748B)),
            Text('Research projects',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569))),
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
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 10 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding:
                EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 7 : 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: color,
                size: MediaQuery.sizeOf(context).width < 600 ? 18 : 22),
          ),
          SizedBox(width: MediaQuery.sizeOf(context).width < 600 ? 7 : 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.sizeOf(context).width < 600 ? 17 : 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptiveTab(List<AnalyticsResult> results) {
    final isPhone = MediaQuery.sizeOf(context).width < 600;
    final query = _descriptiveQuery.trim().toLowerCase();
    final filtered = results
        .where((result) =>
            query.isEmpty || result.questionText.toLowerCase().contains(query))
        .toList();
    switch (_descriptiveSort) {
      case 'Most answered':
        filtered.sort((a, b) => b.answeredCount.compareTo(a.answeredCount));
        break;
      case 'Least answered':
        filtered.sort((a, b) => a.answeredCount.compareTo(b.answeredCount));
        break;
      case 'Most missing':
        filtered.sort((a, b) => b.missingCount.compareTo(a.missingCount));
        break;
      case 'Alphabetical':
        filtered.sort((a, b) => a.questionText
            .toLowerCase()
            .compareTo(b.questionText.toLowerCase()));
        break;
    }

    return ListView(
      padding: EdgeInsets.only(bottom: isPhone ? 112 : 20),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _descriptiveQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search questions',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: 'Sort questions',
              initialValue: _descriptiveSort,
              onSelected: (value) => setState(() => _descriptiveSort = value),
              itemBuilder: (_) => [
                for (final option in [
                  'Question order',
                  'Most answered',
                  'Least answered',
                  'Most missing',
                  'Alphabetical',
                ])
                  PopupMenuItem(value: option, child: Text(option)),
              ],
              child: Chip(
                avatar: const Icon(Icons.sort, size: 18),
                label: Text(_descriptiveSort),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(results.isEmpty
                  ? 'No questions to summarize yet.'
                  : 'No questions match your search.'),
            ),
          ),
        for (var idx = 0; idx < filtered.length; idx++) ...[
          _buildDescriptiveCard(filtered[idx], idx),
          if (idx != filtered.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildDescriptiveCard(AnalyticsResult r, int idx) {
    final isNumeric = r.mean != null ||
        r.type == QuestionType.number ||
        r.type == QuestionType.rating ||
        r.type == QuestionType.likertScale;
    final percentDenominator = r.type == QuestionType.multipleChoice
        ? r.respondentCount
        : r.answeredCount;
    final settings = ref.watch(appSettingsProvider);
    final precision = settings.decimalPrecision;

    return Container(
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          const SizedBox(height: 12),
          if (settings.showDescriptiveCompleteness)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _statBadge(
                    'Answered', '${r.answeredCount}', const Color(0xFF00897B)),
                _statBadge(
                    'Missing', '${r.missingCount}', const Color(0xFFD84315)),
                if (r.respondentCount > 0)
                  _statBadge(
                    'Response rate',
                    '${(100 * r.answeredCount / r.respondentCount).toStringAsFixed(1)}%',
                    const Color(0xFF1565C0),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          if (isNumeric) ...[
            // Mean, Median, StdDev, Min, Max
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _statBadge(
                    'Mean (μ)',
                    r.mean?.toStringAsFixed(precision) ?? '-',
                    const Color(0xFF1565C0)),
                _statBadge(
                    'Median (M)',
                    r.median?.toStringAsFixed(precision) ?? '-',
                    const Color(0xFF00897B)),
                _statBadge(
                    'Std Dev (σ)',
                    r.stdDev?.toStringAsFixed(precision) ?? '-',
                    const Color(0xFFF57C00)),
                _statBadge('Min', r.min?.toStringAsFixed(1) ?? '-',
                    Colors.grey.shade700),
                _statBadge('Max', r.max?.toStringAsFixed(1) ?? '-',
                    Colors.grey.shade700),
                _statBadge('Q1', r.q1?.toStringAsFixed(precision) ?? '-',
                    const Color(0xFF455A64)),
                _statBadge('Q3', r.q3?.toStringAsFixed(precision) ?? '-',
                    const Color(0xFF455A64)),
                _statBadge('Count (n)', '${r.count}', const Color(0xFF7B1FA2)),
                _statBadge('Potential outliers', '${r.outlierCount}',
                    const Color(0xFFD84315)),
                if (r.mean != null && r.stdDev != null && r.count > 1)
                  _statBadge(
                    '95% CI for mean',
                    (() {
                      final ci = StatisticsUtils.meanConfidenceInterval95(
                          r.mean!, r.stdDev!, r.count);
                      return '${ci.first.toStringAsFixed(precision)} to ${ci.last.toStringAsFixed(precision)}';
                    })(),
                    const Color(0xFF5D4037),
                  ),
              ],
            ),
          ] else if (r.type == QuestionType.text) ...[
            Text('${r.textResponses.length} written responses',
                style: GoogleFonts.poppins(
                    color: const Color(0xFF475569), fontSize: 13)),
            if (r.textResponses.isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Read responses'),
                children: [
                  for (var responseIndex = 0;
                      responseIndex < r.textResponses.length;
                      responseIndex++)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(r.textResponses[responseIndex]),
                    ),
                ],
              ),
          ] else if (r.type == QuestionType.date) ...[
            Text(
              r.min == null || r.max == null
                  ? 'No valid dates recorded.'
                  : 'Date range: ${DateTime.fromMillisecondsSinceEpoch(r.min!.toInt()).toLocal().toString().split(' ').first} to ${DateTime.fromMillisecondsSinceEpoch(r.max!.toInt()).toLocal().toString().split(' ').first}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 8),
            ...r.frequencies.entries.map((entry) =>
                _frequencyRow(entry.key, entry.value, r.count, r.count)),
          ] else if (r.type == QuestionType.matrix) ...[
            ...r.rowFrequencies.entries.map((row) {
              final total = row.value.values.fold<int>(0, (a, b) => a + b);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.key,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    if (row.value.isEmpty)
                      const Text('No answers for this row')
                    else
                      ...row.value.entries.map((entry) =>
                          _frequencyRow(entry.key, entry.value, total, total)),
                  ],
                ),
              );
            }),
          ] else ...[
            if (r.type == QuestionType.multipleChoice)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                    'Respondents could choose multiple options; percentages may exceed 100%.'),
              ),
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
                  final pct = percentDenominator > 0
                      ? (entry.value / percentDenominator) * 100
                      : 0.0;
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
  }

  Widget _frequencyRow(
      String label, int frequency, int denominator, int count) {
    final percentage = denominator == 0 ? 0.0 : frequency / denominator * 100;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          Text('$frequency / $count  (${percentage.toStringAsFixed(1)}%)'),
        ],
      ),
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
    final showInsights = ref.watch(appSettingsProvider).showAnalyticsInsights;
    return ListView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.sizeOf(context).width < 600 ? 112 : 20),
        children: [
          if (showInsights)
            Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_analysisSummary(results))),
          const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                  'Numeric variables default to histograms and offer box plots. Date variables show monthly response trends. Category charts sort common responses first and group long tails as Other. For multi-select questions, choose whether percentages use participants or all selections.')),
          ...results.map(
              (r) => ChartExplorer(key: ValueKey(r.questionId), result: r)),
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
    final showInsights = ref.watch(appSettingsProvider).showAnalyticsInsights;
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
    final rowTotals = <String, int>{
      for (final row in rowKeys)
        row: crossTable[row]!.values.fold<int>(0, (sum, value) => sum + value),
    };
    final colTotals = <String, int>{
      for (final column in colList)
        column: rowKeys.fold<int>(
            0, (sum, row) => sum + (crossTable[row]?[column] ?? 0)),
    };
    final grandTotal =
        rowTotals.values.fold<int>(0, (sum, value) => sum + value);
    final belowFive = (chiResult['cellsBelowFive'] ?? 0).toInt();
    final totalCells = (chiResult['totalCells'] ?? 0).toInt();
    final sparsePercent = totalCells == 0 ? 0.0 : belowFive / totalCells * 100;
    final testAvailable = chiResult['testAvailable'] == 1;
    final pValue = chiResult['pValue'] ?? double.nan;
    final pText = !pValue.isFinite
        ? 'p unavailable'
        : pValue < .001
            ? 'p < .001'
            : 'p = ${pValue.toStringAsFixed(3)}';
    final report = testAvailable
        ? 'A chi-square test of independence found ${pValue < ref.watch(appSettingsProvider).confidenceLevel ? 'evidence of an association' : 'no statistically significant evidence of an association'} between “${rowQ.questionText}” and “${colQ.questionText}”, χ²(${chiResult['degreesOfFreedom']?.toInt()}) = ${chiResult['chiSquare']?.toStringAsFixed(2)}, $pText, Cramér’s V = ${chiResult['cramerV']?.toStringAsFixed(2)}, N = $grandTotal.${sparsePercent > 20 ? ' ${sparsePercent.toStringAsFixed(1)}% of expected cells were below 5; interpret the approximation cautiously.' : ''}'
        : 'A chi-square test could not be calculated for “${rowQ.questionText}” and “${colQ.questionText}”: the table needs at least two observed categories in each variable and at least one record.';
    final pairwise = <({String first, String second, double p, double v})>[];
    if (testAvailable &&
        pValue < ref.watch(appSettingsProvider).confidenceLevel) {
      final pairs = <(String, String)>[];
      for (var i = 0; i < rowKeys.length; i++) {
        for (var j = i + 1; j < rowKeys.length; j++) {
          pairs.add((rowKeys[i], rowKeys[j]));
        }
      }
      for (final pair in pairs.take(100)) {
        final result = StatisticsUtils.chiSquareTest({
          pair.$1: crossTable[pair.$1]!,
          pair.$2: crossTable[pair.$2]!,
        });
        if (result['testAvailable'] == 1) {
          final rawP = result['pValue'] ?? 1.0;
          pairwise.add((
            first: pair.$1,
            second: pair.$2,
            p: (rawP * pairs.length).clamp(0.0, 1.0).toDouble(),
            v: result['cramerV'] ?? 0.0,
          ));
        }
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
          bottom: MediaQuery.sizeOf(context).width < 600 ? 112 : 20),
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
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _crossTabRowQId = v;
                          if (_crossTabColQId == v) {
                            _crossTabColQId = categorical
                                .firstWhere(
                                    (question) => question.questionId != v)
                                .questionId;
                          }
                        });
                      },
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
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _crossTabColQId = v;
                          if (_crossTabRowQId == v) {
                            _crossTabRowQId = categorical
                                .firstWhere(
                                    (question) => question.questionId != v)
                                .questionId;
                          }
                        });
                      },
                    ),
                  ],
                );
                final options = Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    DropdownButton<String>(
                      value: _crossTabPercentageMode,
                      items: const [
                        DropdownMenuItem(
                            value: 'Counts', child: Text('Counts')),
                        DropdownMenuItem(value: 'Row %', child: Text('Row %')),
                        DropdownMenuItem(
                            value: 'Column %', child: Text('Column %')),
                        DropdownMenuItem(
                            value: 'Overall %', child: Text('Overall %')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _crossTabPercentageMode = value);
                        }
                      },
                    ),
                    FilterChip(
                        label: const Text('Include missing answers'),
                        selected: _includeMissingInCrossTab,
                        onSelected: (value) =>
                            setState(() => _includeMissingInCrossTab = value)),
                    Text(
                        '${rowVals.length} records included${excludedMissing > 0 ? ' • $excludedMissing excluded for missing data' : ''}',
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
                  'Contingency Table',
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
                              label: Text('Total',
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
                                final denominator =
                                    switch (_crossTabPercentageMode) {
                                  'Row %' => rowTotals[r] ?? 0,
                                  'Column %' => colTotals[c] ?? 0,
                                  'Overall %' => grandTotal,
                                  _ => 0,
                                };
                                final percentage = denominator == 0
                                    ? 0.0
                                    : count / denominator * 100;
                                return DataCell(Text(_crossTabPercentageMode ==
                                        'Counts'
                                    ? '$count'
                                    : '$count (${percentage.toStringAsFixed(1)}%)'));
                              }),
                              DataCell(Text('$rowTotal',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                            ],
                          );
                        }).toList()
                          ..add(DataRow(
                            cells: [
                              const DataCell(Text('Column total',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                              ...colList.map((column) => DataCell(Text(
                                  '${colTotals[column] ?? 0}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)))),
                              DataCell(Text('$grandTotal',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                            ],
                          )),
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
                if (!testAvailable)
                  const Text(
                      'Test unavailable: choose variables with at least two observed categories each and include at least one record.')
                else
                  Text(
                    'χ²(${chiResult['degreesOfFreedom']?.toInt()}) = ${chiResult['chiSquare']?.toStringAsFixed(3)} • $pText • N = $grandTotal',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 6),
                if (testAvailable)
                  Text(
                    "Cramer's V = ${chiResult['cramerV']?.toStringAsFixed(3)} • Minimum expected count = ${chiResult['minExpected']?.toStringAsFixed(ref.watch(appSettingsProvider).decimalPrecision)}",
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey.shade700),
                  ),
                const SizedBox(height: 6),
                if (testAvailable && showInsights)
                  Text(
                    'Interpretation: ${_interpretPValue(chiResult['pValue'] ?? 1)}. The association is ${_effectStrength(chiResult['cramerV'] ?? 0)} in magnitude; this does not establish causation.',
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                if (testAvailable && showInsights && belowFive > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Assumption warning: $belowFive of $totalCells cells (${sparsePercent.toStringAsFixed(1)}%) have expected counts below 5. When over 20% are affected, the chi-square approximation may be unreliable. Consider combining categories only when substantively justified or using an exact test.',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.orange.shade900),
                  ),
                ],
                if (testAvailable && showInsights) ...[
                  const SizedBox(height: 12),
                  SelectableText(report,
                      style: GoogleFonts.poppins(fontSize: 12)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: report));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Report sentence copied')),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy report sentence'),
                    ),
                  ),
                ],
                if (pairwise.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Adjusted pairwise comparisons',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(
                      'Row categories compared across column responses; Bonferroni-adjusted p-values. Showing up to 100 comparisons.',
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey.shade700)),
                  const SizedBox(height: 6),
                  ...pairwise.map((comparison) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text(
                          '${comparison.first} vs ${comparison.second}: adjusted p ${comparison.p < .001 ? '< .001' : '= ${comparison.p.toStringAsFixed(3)}'}, Cramér’s V = ${comparison.v.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      )),
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
    final showInsights = ref.watch(appSettingsProvider).showAnalyticsInsights;
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
    final residualScatter = <FlSpot>[];
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
      correlation = _correlationMethod == 'Spearman'
          ? StatisticsUtils.spearmanCorrelationTest(x, y)
          : StatisticsUtils.pearsonCorrelationTest(x, y);
      paired = StatisticsUtils.pairedTTest(x, y);
      regression = StatisticsUtils.simpleLinearRegression(x, y);
      if (regression?['slope']?.isFinite ?? false) {
        final slope = regression!['slope']!;
        final intercept = regression['intercept']!;
        for (var i = 0; i < x.length; i++) {
          final fitted = intercept + slope * x[i];
          residualScatter.add(FlSpot(fitted, y[i] - fitted));
        }
      }
    }

    Map<String, double>? tTest;
    List<String> groupNames = const [];
    final pairwiseGroupTests =
        <({String first, String second, double p, double d})>[];
    var groupSampleSummary = '';
    var groupAssumptionNote = '';
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
      if (grouped.isNotEmpty) {
        final sizes =
            grouped.map((name, values) => MapEntry(name, values.length));
        groupSampleSummary = sizes.entries
            .map((entry) => '${entry.key}: n=${entry.value}')
            .join(' • ');
        final minSize = sizes.values.reduce((a, b) => a < b ? a : b);
        final maxSize = sizes.values.reduce((a, b) => a > b ? a : b);
        final variances = grouped.values
            .where((values) => values.length > 1)
            .map(StatisticsUtils.variance)
            .toList();
        final varianceRatio = variances.isEmpty
            ? 1.0
            : variances.reduce((a, b) => a > b ? a : b) /
                (variances.reduce((a, b) => a < b ? a : b) < 1e-12
                    ? 1e-12
                    : variances.reduce((a, b) => a < b ? a : b));
        var potentialOutliers = 0;
        for (final values
            in grouped.values.where((values) => values.length >= 4)) {
          final q1 = StatisticsUtils.percentile(values, 25);
          final q3 = StatisticsUtils.percentile(values, 75);
          final iqr = q3 - q1;
          potentialOutliers += values
              .where(
                  (value) => value < q1 - 1.5 * iqr || value > q3 + 1.5 * iqr)
              .length;
        }
        if (minSize < 5) {
          groupAssumptionNote =
              'Small group sample(s) (n < 5): estimates and assumption checks are uncertain.';
        } else if (maxSize >= minSize * 3) {
          groupAssumptionNote =
              'Group sizes are substantially unbalanced; inspect residuals and interpret cautiously.';
        }
        if (varianceRatio >= 4) {
          if (groupAssumptionNote.isNotEmpty) groupAssumptionNote += ' ';
          groupAssumptionNote +=
              'Group variances differ substantially (largest/smallest ratio ${varianceRatio.toStringAsFixed(1)}); Welch comparison is preferable for two groups.';
        }
        if (potentialOutliers > 0) {
          if (groupAssumptionNote.isNotEmpty) groupAssumptionNote += ' ';
          groupAssumptionNote +=
              '$potentialOutliers potential IQR outlier(s) detected; inspect the raw values before interpreting.';
        }
      }
      if (grouped.length == 2) {
        groupNames = grouped.keys.toList();
        tTest = StatisticsUtils.welchTTest(
            grouped[groupNames[0]]!, grouped[groupNames[1]]!);
      }
      if (grouped.length > 2 &&
          (anova?['pValue']?.isFinite ?? false) &&
          anova!['pValue']! < ref.watch(appSettingsProvider).confidenceLevel) {
        final names = grouped.keys.toList();
        final comparisons =
            <({String first, String second, Map<String, double> test})>[];
        for (var i = 0; i < names.length; i++) {
          for (var j = i + 1; j < names.length; j++) {
            comparisons.add((
              first: names[i],
              second: names[j],
              test: StatisticsUtils.welchTTest(
                  grouped[names[i]]!, grouped[names[j]]!),
            ));
          }
        }
        for (final comparison in comparisons) {
          final p = comparison.test['pValue'];
          if (p != null && p.isFinite) {
            pairwiseGroupTests.add((
              first: comparison.first,
              second: comparison.second,
              p: (p * comparisons.length).clamp(0.0, 1.0).toDouble(),
              d: comparison.test['cohensD'] ?? double.nan,
            ));
          }
        }
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

    return ListView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.sizeOf(context).width < 600 ? 112 : 20),
        children: [
          _analysisPanel(
            title: 'Pearson Correlation',
            subtitle:
                'Tests the linear relationship between two numeric variables using complete paired records.',
            controls: Column(
              children: [
                Row(children: [
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: DropdownButton<String>(
                    value: _correlationMethod,
                    items: const [
                      DropdownMenuItem(
                          value: 'Pearson', child: Text('Pearson')),
                      DropdownMenuItem(
                          value: 'Spearman', child: Text('Spearman')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _correlationMethod = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            result: numeric.length < 2
                ? 'Add at least two numeric questions.'
                : _correlationXId == _correlationYId
                    ? 'Choose two different numeric questions.'
                    : '${_correlationMethod == 'Spearman' ? 'ρ' : 'r'} = ${correlation?['r']?.toStringAsFixed(3) ?? 'N/A'} • n = ${correlation?['n']?.toInt() ?? 0} • ${_formatPValue(correlation?['pValue'])}${showInsights ? ' • ${_effectStrength(correlation?['r'] ?? 0)} ${_correlationMethod == 'Spearman' ? 'monotonic' : 'linear'} association${(correlation?['n'] ?? 0) < 10 ? '\nVery small paired sample; treat the estimate as exploratory.' : ''}\nInspect the scatter plot for outliers and nonlinearity. Correlation does not imply causation.' : ''}',
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
                : '${groupNames[0]} mean = ${tTest['mean1']?.toStringAsFixed(ref.watch(appSettingsProvider).decimalPrecision)} (n=${tTest['n1']?.toInt()}) • ${groupNames[1]} mean = ${tTest['mean2']?.toStringAsFixed(ref.watch(appSettingsProvider).decimalPrecision)} (n=${tTest['n2']?.toInt()})\nWelch t = ${tTest['t']?.toStringAsFixed(3)} • df = ${tTest['degreesOfFreedom']?.toStringAsFixed(1)} • Cohen’s d = ${tTest['cohensD']?.toStringAsFixed(3)} • ${_formatPValue(tTest['pValue'])}${showInsights ? ' (${_cohensDStrength(tTest['cohensD'] ?? 0)})\n$groupSampleSummary${groupAssumptionNote.isEmpty ? '' : '\n$groupAssumptionNote'}' : ''}',
          ),
          const SizedBox(height: 16),
          if (showInsights)
            Text(
                'Statistical results support research interpretation and do not by themselves establish causation or a medical diagnosis.',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.orange.shade900)),
          const SizedBox(height: 16),
          _analysisPanel(
              title: 'Paired samples (Y − X)',
              subtitle:
                  'Uses the two numeric variables selected above. Use only when each row contains measurements from the same subject, before and after. Differences should be approximately normal.',
              controls: const SizedBox.shrink(),
              result: paired == null || !(paired!['pValue']?.isFinite ?? false)
                  ? 'At least two complete pairs with variation in their differences are required.'
                  : 'n=${paired!['n']!.toInt()} • Mean difference=${paired!['difference']!.toStringAsFixed(3)} • Difference range [${paired!['differenceMin']!.toStringAsFixed(2)}, ${paired!['differenceMax']!.toStringAsFixed(2)}] • t=${paired!['t']!.toStringAsFixed(3)} • df=${paired!['df']!.toInt()} • 95% CI [${paired!['lower']!.toStringAsFixed(3)}, ${paired!['upper']!.toStringAsFixed(3)}] • ${_formatPValue(paired!['pValue'])}${showInsights && paired!['n']! < 5 ? '\nFew paired observations; check the difference distribution and interpret cautiously.' : ''}'),
          const SizedBox(height: 16),
          _analysisPanel(
              title: 'One-way ANOVA',
              subtitle:
                  'Uses the selected grouping variable and numeric outcome above. Assumes independent observations, approximately normal residuals and similar group variances. Significant results include Bonferroni-adjusted pairwise Welch comparisons.',
              controls: const SizedBox.shrink(),
              result: anova == null || !(anova['pValue']?.isFinite ?? false)
                  ? 'Choose two or more groups, each with at least two numeric observations and nonzero within-group variation.'
                  : 'F=${anova['f']!.toStringAsFixed(3)} • df=(${anova['df1']!.toInt()},${anova['df2']!.toInt()}) • N=${anova['n']!.toInt()} • η²=${anova['etaSquared']!.toStringAsFixed(3)} • ${_formatPValue(anova['pValue'])}${showInsights ? ' (${_etaSquaredStrength(anova['etaSquared']!)})\n$groupSampleSummary${groupAssumptionNote.isEmpty ? '' : '\n$groupAssumptionNote'}\nANOVA assumptions: independent observations, approximately normal residuals and similar group variances.' : ''}${pairwiseGroupTests.isNotEmpty ? '\nBonferroni-adjusted pairwise Welch tests:' : ''}${pairwiseGroupTests.map((test) => '\n${test.first} vs ${test.second}: adjusted p ${test.p < .001 ? '< .001' : '= ${test.p.toStringAsFixed(3)}'}, Cohen’s d ${test.d.toStringAsFixed(2)}${showInsights ? ' (${_cohensDStrength(test.d)})' : ''}').join()}'),
          const SizedBox(height: 16),
          _analysisPanel(
              title: 'Simple linear regression',
              subtitle:
                  'Predicts the second numeric variable (Y) from the first (X). Inspect linearity, outliers, independent errors and constant residual variance.',
              controls: const SizedBox.shrink(),
              result: regression == null ||
                      !(regression!['slope']?.isFinite ?? false)
                  ? 'Select two nonconstant numeric variables and at least three complete pairs.'
                  : 'Y = ${regression!['intercept']!.toStringAsFixed(3)} + ${regression!['slope']!.toStringAsFixed(3)} × X • Slope 95% CI [${regression!['slopeLower95']!.toStringAsFixed(3)}, ${regression!['slopeUpper95']!.toStringAsFixed(3)}] • R²=${regression!['rSquared']!.toStringAsFixed(3)} • Residual SE=${regression!['residualStandardError']!.toStringAsFixed(3)} • Max |standardized residual|=${regression!['maxStandardizedResidual']!.toStringAsFixed(2)}${showInsights && regression!['maxStandardizedResidual']! > 3 ? ' (possible outlier)' : ''} • ${_formatPValue(regression!['pValue'])}${showInsights ? '\nR² is the proportion of outcome variation explained by this linear model. Check the residual plot for model problems.' : ''}'),
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
          if (residualScatter.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Regression residuals vs fitted values'),
            const Text(
                'Look for an even cloud around zero; curves or changing spread may signal a poor linear model.'),
            SizedBox(
              height: 230,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ScatterChart(
                  ScatterChartData(
                    scatterSpots: residualScatter
                        .map((point) => ScatterSpot(point.x, point.y))
                        .toList(),
                    titlesData: const FlTitlesData(
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
            ),
          ],
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
          if (ref.watch(appSettingsProvider).showAnalyticsInsights)
            Text(subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          controls,
          const Divider(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(result,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w500)),
              ),
              IconButton(
                tooltip: 'Copy result',
                onPressed: () async {
                  await Clipboard.setData(
                      ClipboardData(text: '$title\n$result'));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Statistical result copied')),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
              ),
            ],
          ),
        ]),
      );
}

class _AnalyticsTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _AnalyticsTabBarDelegate(this.child);

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(color: Colors.white, child: child);
  }

  @override
  bool shouldRebuild(covariant _AnalyticsTabBarDelegate oldDelegate) =>
      oldDelegate.child != child;
}

class _DefiniteIntegralIcon extends StatelessWidget {
  final double size;

  const _DefiniteIntegralIcon({this.size = 22});

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color ?? Colors.grey.shade700;
    final scale = size / 22;
    return SizedBox(
      width: 58 * scale,
      height: 30 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 1 * scale,
            top: -2 * scale,
            child: Text('b',
                style: TextStyle(color: color, fontSize: 9 * scale, height: 1)),
          ),
          Positioned(
            left: 0,
            bottom: -1 * scale,
            child: Text('a',
                style: TextStyle(color: color, fontSize: 9 * scale, height: 1)),
          ),
          Positioned(
            left: 6 * scale,
            top: -5 * scale,
            child: Text('∫',
                style: TextStyle(
                    color: color,
                    fontFamily: 'serif',
                    fontSize: 32 * scale,
                    height: 1)),
          ),
          Positioned(
            left: 23 * scale,
            top: 8 * scale,
            child: Text('f(x) dx',
                style:
                    TextStyle(color: color, fontSize: 11 * scale, height: 1)),
          ),
        ],
      ),
    );
  }
}
