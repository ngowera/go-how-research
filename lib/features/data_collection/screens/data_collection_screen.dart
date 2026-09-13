import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/app_models.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/providers/participants_provider.dart';
import '../../../core/providers/questionnaire_provider.dart';
import '../../../core/providers/responses_provider.dart';
import '../../../shared/theme/app_theme.dart';

class DataCollectionScreen extends ConsumerStatefulWidget {
  final String questionnaireId;

  const DataCollectionScreen({
    super.key,
    required this.questionnaireId,
  });

  @override
  ConsumerState<DataCollectionScreen> createState() =>
      _DataCollectionScreenState();
}

class _DataCollectionScreenState extends ConsumerState<DataCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _answers = {};
  String _participantId = 'P-001';
  bool _isSubmitting = false;
  bool _consentConfirmed = false;
  bool _draftLoaded = false;
  int _currentQuestion = 0;
  Timer? _draftTimer;

  String get _draftKey => 'response_draft_${widget.questionnaireId}';

  @override
  void initState() {
    super.initState();
    _restoreDraft();
    _draftTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final interval = ref.read(appSettingsProvider).autoSaveSeconds;
      if (_draftLoaded && _answers.isNotEmpty && timer.tick % interval == 0)
        _saveDraft();
    });
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    super.dispose();
  }

  Future<void> _restoreDraft() async {
    final raw = (await SharedPreferences.getInstance()).getString(_draftKey);
    if (raw == null || !mounted) {
      if (mounted) setState(() => _draftLoaded = true);
      return;
    }
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _participantId = data['participantId'] as String? ?? _participantId;
        _consentConfirmed = data['consentConfirmed'] as bool? ?? false;
        _answers
            .addAll((data['answers'] as Map?)?.cast<String, dynamic>() ?? {});
        _draftLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _draftLoaded = true);
    }
  }

  Future<void> _saveDraft() async {
    await (await SharedPreferences.getInstance()).setString(
      _draftKey,
      jsonEncode({
        'participantId': _participantId,
        'consentConfirmed': _consentConfirmed,
        'answers': _answers,
      }),
    );
  }

  void _setAnswer(String questionId, dynamic value) {
    setState(() => _answers[questionId] = value);
    _saveDraft();
  }

  bool _isVisible(Question question) {
    final rule = question.skipLogic;
    if (rule == null || rule['questionId'] == null) return true;
    final actual = _answers[rule['questionId']];
    final expected = rule['value'];
    switch (rule['operator']) {
      case 'notEquals':
        return actual?.toString() != expected?.toString();
      case 'contains':
        return actual is List
            ? actual.map((e) => e.toString()).contains(expected?.toString())
            : actual?.toString().contains(expected?.toString() ?? '') ?? false;
      default:
        return actual?.toString() == expected?.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionnaire =
        ref.watch(questionnaireByIdProvider(widget.questionnaireId));
    final questions =
        ref.watch(questionsByQuestionnaireProvider(widget.questionnaireId));
    final settings = ref.watch(appSettingsProvider);
    final participants = ref
        .watch(participantsProvider)
        .participants
        .where(
            (participant) => participant.projectId == questionnaire?.projectId)
        .toList();
    final visibleQuestions = questions.where(_isVisible).toList();
    final currentIndex = visibleQuestions.isEmpty
        ? 0
        : _currentQuestion.clamp(0, visibleQuestions.length - 1);
    final answeredCount = visibleQuestions.where((q) {
      final value = _answers[q.id];
      return value != null &&
          (value is! String || value.trim().isNotEmpty) &&
          (value is! List || value.isNotEmpty) &&
          (value is! Map || value.isNotEmpty);
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              questionnaire?.title ?? 'Data Collection Form',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            Text(
              'Offline Data Collection • All entries saved locally to SQLite',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              avatar: const Icon(Icons.cloud_queue_rounded,
                  size: 14, color: Color(0xFF00897B)),
              label: const Text('Offline Ready',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFFE0F2F1),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_late_outlined,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'This questionnaire has no questions yet',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.go(
                            '/questionnaires/${widget.questionnaireId}/builder'),
                        child: const Text('Open Questionnaire Builder'),
                      ),
                    ],
                  ),
                )
              : !_draftLoaded
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          // Participant Header Card
                          LinearProgressIndicator(
                            value: visibleQuestions.isEmpty
                                ? 0
                                : answeredCount / visibleQuestions.length,
                            minHeight: 7,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              '$answeredCount of ${visibleQuestions.length} visible questions answered',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: Colors.grey.shade600)),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  const Icon(Icons.person_pin_rounded,
                                      color: AppTheme.kPrimary, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Participant identity',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                          'A code is always stored; names are optional and follow the privacy setting.',
                                          style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.grey.shade600)),
                                    ],
                                  )),
                                ]),
                                if (participants.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    value: participants.any(
                                            (p) => p.code == _participantId)
                                        ? _participantId
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText:
                                          'Select registered participant (optional)',
                                      prefixIcon: Icon(Icons.people_outline),
                                    ),
                                    items: participants.map((participant) {
                                      final showName = settings
                                              .participantIdentityMode ==
                                          ParticipantIdentityMode.nameAndCode;
                                      return DropdownMenuItem(
                                        value: participant.code,
                                        child: Text(showName &&
                                                participant.name.isNotEmpty
                                            ? '${participant.name} — ${participant.code}'
                                            : participant.code),
                                      );
                                    }).toList(),
                                    onChanged: (code) {
                                      if (code != null) {
                                        setState(() => _participantId = code);
                                        _saveDraft();
                                      }
                                    },
                                  ),
                                ],
                                const SizedBox(height: 12),
                                TextFormField(
                                  key: ValueKey('participant-$_participantId'),
                                  initialValue: _participantId,
                                  decoration: const InputDecoration(
                                    labelText: 'Identification code',
                                    helperText:
                                        'You may enter a new code instead of selecting a registered participant.',
                                    isDense: true,
                                  ),
                                  onChanged: (v) {
                                    _participantId = v;
                                    _saveDraft();
                                  },
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? 'Participant code is required'
                                          : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          CheckboxListTile(
                            value: _consentConfirmed,
                            onChanged: (value) {
                              setState(
                                  () => _consentConfirmed = value ?? false);
                              _saveDraft();
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text(
                                'Informed consent or an approved ethics waiver is documented'),
                            subtitle: const Text(
                                'Required before a research response can be submitted.'),
                          ),
                          const SizedBox(height: 12),

                          // Questions Rendered
                          if (settings.formDisplayMode ==
                                  FormDisplayMode.paged &&
                              visibleQuestions.isNotEmpty)
                            Row(children: [
                              TextButton(
                                  onPressed: currentIndex == 0
                                      ? null
                                      : () => setState(() =>
                                          _currentQuestion = currentIndex - 1),
                                  child: const Text('Previous')),
                              Expanded(
                                  child: Text(
                                      'Question ${currentIndex + 1} of ${visibleQuestions.length}',
                                      textAlign: TextAlign.center)),
                              TextButton(
                                  onPressed: currentIndex ==
                                          visibleQuestions.length - 1
                                      ? null
                                      : () => setState(() =>
                                          _currentQuestion = currentIndex + 1),
                                  child: const Text('Next'))
                            ]),
                          ...visibleQuestions
                              .asMap()
                              .entries
                              .where((entry) =>
                                  settings.formDisplayMode ==
                                      FormDisplayMode.singlePage ||
                                  entry.key == currentIndex)
                              .map((entry) {
                            final idx = entry.key + 1;
                            final q = entry.value;
                            return _buildQuestionItem(q, idx);
                          }),
                          const SizedBox(height: 24),

                          // Submit button
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ensure all required fields are answered.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed:
                                      _isSubmitting ? null : _submitResponse,
                                  icon: _isSubmitting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        )
                                      : const Icon(Icons.save_rounded),
                                  label: Text(
                                    _isSubmitting
                                        ? 'Saving...'
                                        : 'Submit Response',
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.kPrimary,
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
        ),
      ),
    );
  }

  Widget _buildQuestionItem(Question q, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$index. ',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.kPrimary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.text,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if (q.helpText != null && q.helpText!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        q.helpText!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (q.isRequired)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Required',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInputForType(q),
        ],
      ),
    );
  }

  Widget _buildInputForType(Question q) {
    switch (q.type) {
      case QuestionType.text:
        return TextFormField(
          decoration: InputDecoration(
            hintText: 'Type answer here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (v) {
            if (q.isRequired && (v == null || v.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          initialValue: _answers[q.id]?.toString(),
          onChanged: (v) => _setAnswer(q.id, v),
        );

      case QuestionType.number:
        return TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter numeric value...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (v) {
            if (q.isRequired && (v == null || v.trim().isEmpty)) {
              return 'This field is required';
            }
            if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
              return 'Must be a valid number';
            }
            final number = double.tryParse(v ?? '');
            if (number != null && q.minValue != null && number < q.minValue!) {
              return 'Value must be at least ${q.minValue}';
            }
            if (number != null && q.maxValue != null && number > q.maxValue!) {
              return 'Value must be at most ${q.maxValue}';
            }
            return null;
          },
          initialValue: _answers[q.id]?.toString(),
          onChanged: (v) => _setAnswer(q.id, v),
        );

      case QuestionType.singleChoice:
        final selectedVal = _answers[q.id] as String?;
        return Column(
          children: q.options.map((opt) {
            return RadioListTile<String>(
              title: Text(opt, style: GoogleFonts.poppins(fontSize: 13)),
              value: opt,
              groupValue: selectedVal,
              activeColor: AppTheme.kPrimary,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) {
                _setAnswer(q.id, v);
              },
            );
          }).toList(),
        );

      case QuestionType.multipleChoice:
        final selectedList = (_answers[q.id] as List<String>?) ?? [];
        return Column(
          children: q.options.map((opt) {
            final isChecked = selectedList.contains(opt);
            return CheckboxListTile(
              title: Text(opt, style: GoogleFonts.poppins(fontSize: 13)),
              value: isChecked,
              activeColor: AppTheme.kPrimary,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (v) {
                setState(() {
                  final list = List<String>.from(selectedList);
                  if (v == true) {
                    list.add(opt);
                  } else {
                    list.remove(opt);
                  }
                  _answers[q.id] = list;
                });
                _saveDraft();
              },
            );
          }).toList(),
        );

      case QuestionType.likertScale:
        final currentVal = _answers[q.id] as int?;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [1, 2, 3, 4, 5].map((val) {
            final isSelected = currentVal == val;
            return InkWell(
              onTap: () => _setAnswer(q.id, val),
              child: Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.kPrimary : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected ? AppTheme.kPrimary : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$val',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );

      case QuestionType.rating:
        final ratingVal = (_answers[q.id] as int?) ?? 0;
        return Row(
          children: List.generate(5, (starIdx) {
            final isFilled = starIdx < ratingVal;
            return IconButton(
              icon: Icon(
                isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFilled ? Colors.amber : Colors.grey.shade400,
                size: 32,
              ),
              onPressed: () => _setAnswer(q.id, starIdx + 1),
            );
          }),
        );

      case QuestionType.yesNo:
        final val = _answers[q.id] as String?;
        return Row(
          children: [
            ElevatedButton(
              onPressed: () => _setAnswer(q.id, 'YES'),
              style: ElevatedButton.styleFrom(
                backgroundColor: val == 'YES'
                    ? const Color(0xFF2E7D32)
                    : Colors.grey.shade200,
                foregroundColor:
                    val == 'YES' ? Colors.white : Colors.grey.shade800,
              ),
              child: const Text('YES'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _setAnswer(q.id, 'NO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: val == 'NO'
                    ? const Color(0xFFC62828)
                    : Colors.grey.shade200,
                foregroundColor:
                    val == 'NO' ? Colors.white : Colors.grey.shade800,
              ),
              child: const Text('NO'),
            ),
          ],
        );

      case QuestionType.date:
        final dateVal = _answers[q.id] as String?;
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                _answers[q.id] = picked.toIso8601String().split('T').first;
              });
              _saveDraft();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 18),
                const SizedBox(width: 10),
                Text(dateVal ?? 'Select Date...'),
              ],
            ),
          ),
        );

      case QuestionType.matrix:
        final matrix = Map<String, String>.from(
          (_answers[q.id] as Map?)?.cast<String, String>() ?? const {},
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: q.rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  Wrap(
                    spacing: 8,
                    children: q.columns.map((column) {
                      return ChoiceChip(
                        label: Text(column),
                        selected: matrix[row] == column,
                        onSelected: (_) {
                          setState(() {
                            final updated = Map<String, String>.from(matrix);
                            updated[row] = column;
                            _answers[q.id] = updated;
                          });
                          _saveDraft();
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _submitResponse() async {
    final settings = ref.read(appSettingsProvider);
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all required questions!'),
          backgroundColor: AppTheme.kWarning,
        ),
      );
      return;
    }

    if (!_consentConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Confirm informed consent or an approved ethics waiver before submitting.'),
        backgroundColor: AppTheme.kWarning,
      ));
      return;
    }

    final questions = ref
        .read(
          questionsByQuestionnaireProvider(widget.questionnaireId),
        )
        .where(_isVisible)
        .toList();
    final missingRequired = questions.where((question) {
      if (!question.isRequired) return false;
      final value = _answers[question.id];
      if (value == null) return true;
      if (value is String) return value.trim().isEmpty;
      if (value is List) return value.isEmpty;
      if (value is Map) {
        return value.isEmpty ||
            (question.type == QuestionType.matrix &&
                value.length < question.rows.length);
      }
      return false;
    }).toList();
    if (missingRequired.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please answer all required questions (${missingRequired.length} remaining).',
          ),
          backgroundColor: AppTheme.kWarning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(responsesProvider(widget.questionnaireId).notifier)
          .saveResponse(
            participantId: _participantId,
            responses: Map<String, dynamic>.fromEntries(
              _answers.entries.where(
                (entry) => questions.any((q) => q.id == entry.key),
              ),
            ),
          );

      if (mounted) {
        await (await SharedPreferences.getInstance()).remove(_draftKey);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF2E7D32)),
                const SizedBox(width: 10),
                Text('Response Saved!',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ],
            ),
            content: Text(
              'The response for participant $_participantId was saved locally to SQLite and queued for cloud sync.',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/questionnaires');
                },
                child: const Text('Back to Questionnaires'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _answers.clear();
                    _currentQuestion = 0;
                    _consentConfirmed = false;
                    // Increment participant ID
                    final numPart = int.tryParse(
                            _participantId.replaceAll(RegExp(r'\D'), '')) ??
                        1;
                    _participantId =
                        '${settings.participantPrefix}${(numPart + 1).toString().padLeft(3, '0')}';
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kPrimary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Collect Next Response'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving response: $e'),
            backgroundColor: AppTheme.kError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
