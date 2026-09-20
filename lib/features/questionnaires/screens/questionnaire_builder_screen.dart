import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/app_models.dart';
import '../../../core/providers/questionnaire_provider.dart';
import '../../../shared/theme/app_theme.dart';

class QuestionnaireBuilderScreen extends ConsumerStatefulWidget {
  final String questionnaireId;

  const QuestionnaireBuilderScreen({
    super.key,
    required this.questionnaireId,
  });

  @override
  ConsumerState<QuestionnaireBuilderScreen> createState() =>
      _QuestionnaireBuilderScreenState();
}

class _QuestionnaireBuilderScreenState
    extends ConsumerState<QuestionnaireBuilderScreen> {
  int? _selectedQuestionIdx;
  final Map<String, Timer> _saveTimers = {};

  void _scheduleUpdate(String questionId, Question Function(Question) update) {
    _saveTimers[questionId]?.cancel();
    _saveTimers[questionId] = Timer(const Duration(milliseconds: 450), () {
      final matches = ref
          .read(questionsByQuestionnaireProvider(widget.questionnaireId))
          .where((question) => question.id == questionId)
          .toList();
      if (matches.isNotEmpty) {
        final current = matches.first;
        ref
            .read(questionsByQuestionnaireProvider(widget.questionnaireId)
                .notifier)
            .saveQuestion(update(current));
      }
    });
  }

  @override
  void dispose() {
    for (final timer in _saveTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _addQuestion(QuestionType type) {
    ref
        .read(questionsByQuestionnaireProvider(widget.questionnaireId).notifier)
        .addQuestion(type);
  }

  @override
  Widget build(BuildContext context) {
    final questionnaire =
        ref.watch(questionnaireByIdProvider(widget.questionnaireId));
    final questions =
        ref.watch(questionsByQuestionnaireProvider(widget.questionnaireId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ── Top Header Toolbar ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/questionnaires'),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          questionnaire?.title ?? 'Questionnaire Builder',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '${questions.length} questions • Version ${questionnaire?.version ?? 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
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
                      onPressed: () {
                        context
                            .go('/data-collection/${widget.questionnaireId}');
                      },
                      icon: const Icon(Icons.play_circle_outline, size: 16),
                      label: const Text('Test / Collect Data'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(questionnairesProvider.notifier)
                            .submitForApproval(widget.questionnaireId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Questionnaire saved and submitted for review!'),
                            backgroundColor: AppTheme.kSuccess,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Save & Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.kPrimary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Main Workspace ─────────────────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                // Left: Question Types Palette
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(right: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'ADD QUESTION',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPaletteButton(
                        'Text Response',
                        Icons.text_fields_rounded,
                        const Color(0xFF1565C0),
                        () => _addQuestion(QuestionType.text),
                      ),
                      _buildPaletteButton(
                        'Number / Value',
                        Icons.numbers_rounded,
                        const Color(0xFF00897B),
                        () => _addQuestion(QuestionType.number),
                      ),
                      _buildPaletteButton(
                        'Single Choice',
                        Icons.radio_button_checked_rounded,
                        const Color(0xFFF57C00),
                        () => _addQuestion(QuestionType.singleChoice),
                      ),
                      _buildPaletteButton(
                        'Multiple Choice',
                        Icons.check_box_rounded,
                        const Color(0xFF7B1FA2),
                        () => _addQuestion(QuestionType.multipleChoice),
                      ),
                      _buildPaletteButton(
                        'Likert Scale (1-5)',
                        Icons.linear_scale_rounded,
                        const Color(0xFF2E7D32),
                        () => _addQuestion(QuestionType.likertScale),
                      ),
                      _buildPaletteButton(
                        'Star Rating',
                        Icons.star_rounded,
                        Colors.amber.shade700,
                        () => _addQuestion(QuestionType.rating),
                      ),
                      _buildPaletteButton(
                        'Yes / No',
                        Icons.toggle_on_rounded,
                        const Color(0xFFD81B60),
                        () => _addQuestion(QuestionType.yesNo),
                      ),
                      _buildPaletteButton(
                        'Thumbs Up / Down',
                        Icons.thumb_up_alt_rounded,
                        const Color(0xFF6D4C41),
                        () => _addQuestion(QuestionType.thumbs),
                      ),
                      _buildPaletteButton(
                        'Date Picker',
                        Icons.calendar_today_rounded,
                        const Color(0xFF0288D1),
                        () => _addQuestion(QuestionType.date),
                      ),
                      _buildPaletteButton(
                        'Matrix / Grid',
                        Icons.grid_on_rounded,
                        const Color(0xFF5E35B1),
                        () => _addQuestion(QuestionType.matrix),
                      ),
                    ],
                  ),
                ),

                // Center: Questions Editor List
                Expanded(
                  flex: 3,
                  child: questions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.post_add_rounded,
                                  size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No questions yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Click any question type on the left panel to add your first question',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _addQuestion(QuestionType.text),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Short Text Question'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.kPrimary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: questions.length,
                          itemBuilder: (context, idx) {
                            return _buildQuestionCard(
                              questions[idx],
                              idx + 1,
                              isFirst: idx == 0,
                              isLast: idx == questions.length - 1,
                            );
                          },
                        ),
                ),

                // Right: Quick Live Preview & Guide
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(left: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Survey Tips',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildTip(
                          'Keep questions concise',
                          'Direct questions yield higher completion rates and fewer skipped items.',
                        ),
                        const SizedBox(height: 10),
                        _buildTip(
                          'Use standard Likert scales',
                          '5-point scales (Strongly Disagree to Strongly Agree) make descriptive statistics easy to compute.',
                        ),
                        const SizedBox(height: 10),
                        _buildTip(
                          'Required fields',
                          'Mark key variables as required so data quality scores remain high during automated analysis.',
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.kPrimary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.kPrimary.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ready to test?',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppTheme.kPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Open the data collection form to test responses immediately.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.go(
                                        '/data-collection/${widget.questionnaireId}');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.kPrimary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Open Collection Form'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String title, String body) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(body,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.grey.shade600, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildPaletteButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              Icon(Icons.add, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    Question q,
    int index, {
    required bool isFirst,
    required bool isLast,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.kPrimary.withOpacity(0.1),
                  child: Text(
                    '$index',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.kPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    q.type.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                // Required Switch
                Row(
                  children: [
                    Text(
                      'Required',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 4),
                    Switch.adaptive(
                      value: q.isRequired,
                      activeColor: AppTheme.kPrimary,
                      onChanged: (v) {
                        ref
                            .read(questionsByQuestionnaireProvider(
                                    widget.questionnaireId)
                                .notifier)
                            .saveQuestion(q.copyWith(isRequired: v));
                      },
                    ),
                  ],
                ),
                // Reorder controls
                IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  onPressed: isFirst
                      ? null
                      : () {
                          ref
                              .read(questionsByQuestionnaireProvider(
                                      widget.questionnaireId)
                                  .notifier)
                              .reorderQuestions(index - 1, index - 2);
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, size: 18),
                  onPressed: isLast
                      ? null
                      : () {
                          ref
                              .read(questionsByQuestionnaireProvider(
                                      widget.questionnaireId)
                                  .notifier)
                              .reorderQuestions(index - 1, index + 1);
                        },
                ),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red, size: 20),
                  onPressed: () {
                    ref
                        .read(questionsByQuestionnaireProvider(
                                widget.questionnaireId)
                            .notifier)
                        .deleteQuestion(q.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Question Text Input
            TextFormField(
              initialValue: q.text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              decoration: const InputDecoration(
                hintText: 'Enter question statement here...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                _scheduleUpdate(q.id, (current) => current.copyWith(text: v));
              },
            ),
            const SizedBox(height: 8),

            // Help text input
            TextFormField(
              initialValue: q.helpText ?? '',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              decoration: const InputDecoration(
                hintText:
                    'Optional help text or instructions for respondent...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) {
                _scheduleUpdate(
                    q.id,
                    (current) =>
                        current.copyWith(helpText: v.isEmpty ? null : v));
              },
            ),
            const SizedBox(height: 12),

            // Specific options editors for choices
            if (q.type == QuestionType.singleChoice ||
                q.type == QuestionType.multipleChoice)
              _buildOptionsEditor(q),

            if (q.type == QuestionType.number)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: q.minValue?.toString() ?? '',
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Minimum value'),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null) {
                          ref
                              .read(questionsByQuestionnaireProvider(
                                      widget.questionnaireId)
                                  .notifier)
                              .saveQuestion(q.copyWith(minValue: parsed));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: q.maxValue?.toString() ?? '',
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Maximum value'),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null) {
                          ref
                              .read(questionsByQuestionnaireProvider(
                                      widget.questionnaireId)
                                  .notifier)
                              .saveQuestion(q.copyWith(maxValue: parsed));
                        }
                      },
                    ),
                  ),
                ],
              ),

            if (q.type == QuestionType.matrix) _buildMatrixEditor(q),

            if (q.type == QuestionType.likertScale)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    const defaults = [
                      'Strongly disagree',
                      'Disagree',
                      'Neutral',
                      'Agree',
                      'Strongly agree'
                    ];
                    final label = q.options.length == 5
                        ? q.options[index]
                        : defaults[index];
                    return Text('${index + 1} = $label',
                        style: const TextStyle(fontSize: 11));
                  }),
                ),
              ),

            if (q.type == QuestionType.yesNo)
              Row(
                children: [
                  OutlinedButton(onPressed: null, child: const Text('YES')),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: null, child: const Text('NO')),
                ],
              ),

            if (q.type == QuestionType.thumbs)
              const Row(
                children: [
                  Icon(Icons.thumb_up_alt_rounded, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Text('Like'),
                  SizedBox(width: 24),
                  Icon(Icons.thumb_down_alt_rounded, color: Color(0xFFC62828)),
                  SizedBox(width: 8),
                  Text('Dislike'),
                ],
              ),

            _buildSkipLogicEditor(q),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsEditor(Question q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 16),
        ...q.options.asMap().entries.map((entry) {
          final optIdx = entry.key;
          final optVal = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(
                  q.type == QuestionType.singleChoice
                      ? Icons.radio_button_unchecked
                      : Icons.check_box_outline_blank,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: optVal,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onChanged: (newVal) {
                      final updated = List<String>.from(q.options);
                      updated[optIdx] = newVal;
                      ref
                          .read(questionsByQuestionnaireProvider(
                                  widget.questionnaireId)
                              .notifier)
                          .saveQuestion(q.copyWith(options: updated));
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                  onPressed: () {
                    final updated = List<String>.from(q.options)
                      ..removeAt(optIdx);
                    ref
                        .read(questionsByQuestionnaireProvider(
                                widget.questionnaireId)
                            .notifier)
                        .saveQuestion(q.copyWith(options: updated));
                  },
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () {
            final updated = List<String>.from(q.options)
              ..add('Option ${q.options.length + 1}');
            ref
                .read(questionsByQuestionnaireProvider(widget.questionnaireId)
                    .notifier)
                .saveQuestion(q.copyWith(options: updated));
          },
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Option'),
        ),
      ],
    );
  }

  Widget _buildMatrixEditor(Question q) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Matrix rows',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 12)),
          _editableStringList(q, q.rows, isRows: true),
          const SizedBox(height: 8),
          Text('Matrix columns',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 12)),
          _editableStringList(q, q.columns, isRows: false),
        ]),
      );

  Widget _editableStringList(Question q, List<String> values,
      {required bool isRows}) {
    return Column(children: [
      ...values.asMap().entries.map((entry) => Row(children: [
            Expanded(
              child: TextFormField(
                initialValue: entry.value,
                decoration: const InputDecoration(isDense: true),
                onChanged: (value) => _scheduleUpdate(q.id, (current) {
                  final updated = List<String>.from(
                      isRows ? current.rows : current.columns);
                  if (entry.key < updated.length) updated[entry.key] = value;
                  return isRows
                      ? current.copyWith(rows: updated)
                      : current.copyWith(columns: updated);
                }),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: values.length <= 1
                  ? null
                  : () {
                      final updated = List<String>.from(values)
                        ..removeAt(entry.key);
                      ref
                          .read(questionsByQuestionnaireProvider(
                                  widget.questionnaireId)
                              .notifier)
                          .saveQuestion(isRows
                              ? q.copyWith(rows: updated)
                              : q.copyWith(columns: updated));
                    },
            ),
          ])),
      TextButton.icon(
        onPressed: () {
          final updated = List<String>.from(values)
            ..add('${isRows ? 'Row' : 'Column'} ${values.length + 1}');
          ref
              .read(questionsByQuestionnaireProvider(widget.questionnaireId)
                  .notifier)
              .saveQuestion(isRows
                  ? q.copyWith(rows: updated)
                  : q.copyWith(columns: updated));
        },
        icon: const Icon(Icons.add, size: 16),
        label: Text('Add ${isRows ? 'row' : 'column'}'),
      ),
    ]);
  }

  Widget _buildSkipLogicEditor(Question q) {
    final earlier = ref
        .watch(questionsByQuestionnaireProvider(widget.questionnaireId))
        .where((candidate) => candidate.order < q.order)
        .toList();
    final rule = q.skipLogic;
    final enabled = rule?['questionId'] != null;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text('Conditional display / skip logic',
          style:
              GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
      subtitle: Text(
          enabled
              ? 'Shown only when the configured condition is met'
              : 'Always shown',
          style: GoogleFonts.poppins(fontSize: 11)),
      children: [
        if (earlier.isEmpty)
          const Align(
              alignment: Alignment.centerLeft,
              child:
                  Text('Add an earlier question before creating a condition.'))
        else ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable conditional display'),
            value: enabled,
            onChanged: (value) {
              final next = value
                  ? {
                      'questionId': earlier.first.id,
                      'operator': 'equals',
                      'value': ''
                    }
                  : <String, dynamic>{};
              ref
                  .read(questionsByQuestionnaireProvider(widget.questionnaireId)
                      .notifier)
                  .saveQuestion(q.copyWith(skipLogic: next));
            },
          ),
          if (enabled)
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue:
                      earlier.any((item) => item.id == rule?['questionId'])
                          ? rule!['questionId'] as String
                          : earlier.first.id,
                  decoration:
                      const InputDecoration(labelText: 'Earlier question'),
                  items: earlier
                      .map((item) => DropdownMenuItem(
                          value: item.id,
                          child:
                              Text(item.text, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (value) => ref
                      .read(questionsByQuestionnaireProvider(
                              widget.questionnaireId)
                          .notifier)
                      .saveQuestion(q.copyWith(
                          skipLogic: {...?rule, 'questionId': value})),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 135,
                child: DropdownButtonFormField<String>(
                  initialValue: rule?['operator'] as String? ?? 'equals',
                  decoration: const InputDecoration(labelText: 'Condition'),
                  items: const [
                    DropdownMenuItem(value: 'equals', child: Text('Equals')),
                    DropdownMenuItem(
                        value: 'notEquals', child: Text('Not equal')),
                    DropdownMenuItem(
                        value: 'contains', child: Text('Contains')),
                  ],
                  onChanged: (value) => ref
                      .read(questionsByQuestionnaireProvider(
                              widget.questionnaireId)
                          .notifier)
                      .saveQuestion(
                          q.copyWith(skipLogic: {...?rule, 'operator': value})),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: rule?['value']?.toString() ?? '',
                  decoration:
                      const InputDecoration(labelText: 'Expected answer'),
                  onChanged: (value) => _scheduleUpdate(
                      q.id,
                      (current) => current.copyWith(
                          skipLogic: {...?current.skipLogic, 'value': value})),
                ),
              ),
            ]),
        ],
      ],
    );
  }
}
