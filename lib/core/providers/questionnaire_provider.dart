import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart' show AppDatabase, databaseProvider;
import '../models/app_models.dart';
import 'sync_provider.dart';

class QuestionnairesState {
  final List<Questionnaire> questionnaires;
  final bool isLoading;
  final String? error;

  const QuestionnairesState({
    this.questionnaires = const [],
    this.isLoading = false,
    this.error,
  });

  QuestionnairesState copyWith({
    List<Questionnaire>? questionnaires,
    bool? isLoading,
    String? error,
  }) {
    return QuestionnairesState(
      questionnaires: questionnaires ?? this.questionnaires,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class QuestionnairesNotifier extends StateNotifier<QuestionnairesState> {
  final AppDatabase _db;
  final Ref _ref;
  static const _uuid = Uuid();

  QuestionnairesNotifier(this._db, this._ref)
      : super(const QuestionnairesState()) {
    loadQuestionnaires();
    _ref.listen<DateTime?>(
      syncProvider.select((sync) => sync.lastAttemptTime),
      (previous, next) {
        if (next != null && next != previous) loadQuestionnaires();
      },
    );
  }

  Future<void> loadQuestionnaires({String? projectId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _db.getQuestionnaires(projectId: projectId);
      state = state.copyWith(questionnaires: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Questionnaire> createQuestionnaire({
    required String projectId,
    required String title,
    required String description,
  }) async {
    final now = DateTime.now();
    final q = Questionnaire(
      id: _uuid.v4(),
      projectId: projectId,
      title: title,
      description: description,
      version: 1,
      isApproved: false,
      isPublished: true,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    await _db.insertQuestionnaire(q);
    await loadQuestionnaires();
    _ref.read(syncProvider.notifier).refreshPendingCount();
    return q;
  }

  Future<Questionnaire> createFromTemplate({
    required String projectId,
    required String template,
    String? title,
  }) async {
    final definitions = _researchTemplates[template];
    if (definitions == null) {
      return createQuestionnaire(
        projectId: projectId,
        title: title ?? 'Research Questionnaire',
        description: '',
      );
    }
    final questionnaire = await createQuestionnaire(
      projectId: projectId,
      title: title ?? definitions.title,
      description: definitions.description,
    );
    for (var index = 0; index < definitions.questions.length; index++) {
      final item = definitions.questions[index];
      await _db.insertQuestion(Question(
        id: _uuid.v4(),
        questionnaireId: questionnaire.id,
        order: index + 1,
        type: item.type,
        text: item.text,
        helpText: item.helpText,
        isRequired: item.required,
        options: item.options,
        minValue: item.min,
        maxValue: item.max,
        rows: item.rows,
        columns: item.columns,
      ));
    }
    await _db.markQuestionnairePending(questionnaire.id);
    _ref.read(syncProvider.notifier).refreshPendingCount();
    return questionnaire;
  }

  Future<void> updateQuestionnaire(Questionnaire questionnaire) async {
    final updated = questionnaire.copyWith(
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
    await _db.updateQuestionnaire(updated);
    await loadQuestionnaires();
    _ref.read(syncProvider.notifier).refreshPendingCount();
  }

  Future<void> deleteQuestionnaire(String id) async {
    await _db.deleteQuestionnaire(id);
    await loadQuestionnaires();
    _ref.read(syncProvider.notifier).refreshPendingCount();
  }

  Future<void> submitForApproval(String id) async {
    final q = await _db.getQuestionnaireById(id);
    if (q != null) {
      await updateQuestionnaire(q.copyWith(syncStatus: SyncStatus.pending));
    }
  }

  Future<void> approveQuestionnaire(String id) async {
    final q = await _db.getQuestionnaireById(id);
    if (q != null) {
      await updateQuestionnaire(q.copyWith(isApproved: true));
    }
  }

  Future<Questionnaire?> duplicateQuestionnaire(String id) async {
    final q = await _db.getQuestionnaireById(id);
    if (q == null) return null;

    final newId = _uuid.v4();
    final now = DateTime.now();
    final dup = q.copyWith(
      id: newId,
      title: '${q.title} (Copy)',
      version: 1,
      isApproved: false,
      createdAt: now,
      updatedAt: now,
      syncStatus: SyncStatus.pending,
    );

    await _db.insertQuestionnaire(dup);

    // duplicate questions
    final questions = await _db.getQuestions(questionnaireId: id);
    for (final question in questions) {
      await _db.insertQuestion(question.copyWith(
        id: _uuid.v4(),
        questionnaireId: newId,
      ));
    }

    await loadQuestionnaires();
    _ref.read(syncProvider.notifier).refreshPendingCount();
    return dup;
  }
}

final questionnairesProvider =
    StateNotifierProvider<QuestionnairesNotifier, QuestionnairesState>((ref) {
  ref.watch(currentUserProvider.select((user) => user?.id));
  final db = ref.watch(databaseProvider);
  return QuestionnairesNotifier(db, ref);
});

final questionnaireByIdProvider =
    Provider.family<Questionnaire?, String>((ref, id) {
  final list = ref.watch(questionnairesProvider).questionnaires;
  try {
    return list.firstWhere((q) => q.id == id);
  } catch (_) {
    return null;
  }
});

class QuestionsNotifier extends StateNotifier<List<Question>> {
  final AppDatabase _db;
  final Ref _ref;
  final String questionnaireId;
  static const _uuid = Uuid();

  QuestionsNotifier(this._db, this._ref, this.questionnaireId) : super([]) {
    loadQuestions();
    _ref.listen<DateTime?>(
      syncProvider.select((sync) => sync.lastAttemptTime),
      (previous, next) {
        if (next != null && next != previous) loadQuestions();
      },
    );
  }

  Future<void> loadQuestions() async {
    final list = await _db.getQuestions(questionnaireId: questionnaireId);
    state = list;
  }

  Future<void> saveQuestion(Question question) async {
    await _db.insertQuestion(question);
    await _markInstrumentPending();
    await loadQuestions();
  }

  Future<void> addQuestion(QuestionType type, {String? text}) async {
    final newQ = Question(
      id: _uuid.v4(),
      questionnaireId: questionnaireId,
      order: state.length + 1,
      type: type,
      text: text ?? 'Untitled Question',
      isRequired: false,
      options: (type == QuestionType.singleChoice ||
              type == QuestionType.multipleChoice)
          ? ['Option 1', 'Option 2', 'Option 3']
          : type == QuestionType.likertScale
              ? [
                  'Strongly disagree',
                  'Disagree',
                  'Neutral',
                  'Agree',
                  'Strongly agree'
                ]
              : [],
      rows: type == QuestionType.matrix ? ['Row 1', 'Row 2'] : [],
      columns: type == QuestionType.matrix ? ['Col 1', 'Col 2', 'Col 3'] : [],
    );
    await _db.insertQuestion(newQ);
    await _markInstrumentPending();
    await loadQuestions();
  }

  Future<void> deleteQuestion(String id) async {
    await _db.deleteQuestion(id);
    await _db.normalizeQuestionOrder(questionnaireId);
    await _markInstrumentPending();
    await loadQuestions();
  }

  Future<void> reorderQuestions(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final items = List<Question>.from(state);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    for (int i = 0; i < items.length; i++) {
      final updated = items[i].copyWith(order: i + 1);
      await _db.insertQuestion(updated);
    }
    await _markInstrumentPending();
    await loadQuestions();
  }

  Future<void> _markInstrumentPending() async {
    await _db.markQuestionnairePending(questionnaireId);
    await _ref.read(syncProvider.notifier).refreshPendingCount();
  }
}

final questionsByQuestionnaireProvider =
    StateNotifierProvider.family<QuestionsNotifier, List<Question>, String>(
        (ref, questionnaireId) {
  ref.watch(currentUserProvider.select((user) => user?.id));
  final db = ref.watch(databaseProvider);
  return QuestionsNotifier(db, ref, questionnaireId);
});

final selectedQuestionIndexProvider = StateProvider<int?>((ref) => null);

class _TemplateDefinition {
  const _TemplateDefinition(this.title, this.description, this.questions);
  final String title;
  final String description;
  final List<_TemplateQuestion> questions;
}

class _TemplateQuestion {
  const _TemplateQuestion(this.text, this.type,
      {this.required = true,
      this.helpText,
      this.options = const [],
      this.min,
      this.max,
      this.rows = const [],
      this.columns = const []});
  final String text;
  final QuestionType type;
  final bool required;
  final String? helpText;
  final List<String> options;
  final double? min;
  final double? max;
  final List<String> rows;
  final List<String> columns;
}

const _researchTemplates = <String, _TemplateDefinition>{
  'laboratory': _TemplateDefinition(
    'Laboratory Results Form',
    'Structured specimen, assay, quality-control, and result capture.',
    [
      _TemplateQuestion('Specimen collection date', QuestionType.date),
      _TemplateQuestion('Specimen type', QuestionType.singleChoice, options: [
        'Blood',
        'Serum',
        'Plasma',
        'Urine',
        'Saliva',
        'Tissue',
        'Other'
      ]),
      _TemplateQuestion('Assay / analyte name', QuestionType.text),
      _TemplateQuestion('Numeric result', QuestionType.number,
          helpText:
              'Enter the value using the unit specified in the study protocol.'),
      _TemplateQuestion('Result classification', QuestionType.singleChoice,
          options: [
            'Below reference range',
            'Within reference range',
            'Above reference range',
            'Not applicable'
          ]),
      _TemplateQuestion('Quality control passed', QuestionType.yesNo),
      _TemplateQuestion('Instrument / method', QuestionType.text),
      _TemplateQuestion('Laboratory notes', QuestionType.text, required: false),
    ],
  ),
  'diagnostic': _TemplateDefinition(
    'Diagnostic Accuracy Study',
    'Paired index-test and reference-standard capture for diagnostic research.',
    [
      _TemplateQuestion('Participant age (years)', QuestionType.number,
          min: 0, max: 120),
      _TemplateQuestion('Participant sex', QuestionType.singleChoice,
          options: ['Female', 'Male', 'Intersex', 'Prefer not to say']),
      _TemplateQuestion('Index test result positive', QuestionType.yesNo),
      _TemplateQuestion(
          'Reference standard result positive', QuestionType.yesNo),
      _TemplateQuestion('Disease severity / stage', QuestionType.text,
          required: false),
      _TemplateQuestion('Adverse event observed', QuestionType.yesNo,
          required: false),
      _TemplateQuestion('Clinical notes', QuestionType.text, required: false),
    ],
  ),
  'agriculture': _TemplateDefinition(
    'Agricultural Field Trial',
    'Plot, treatment, environmental condition, yield, and observation capture.',
    [
      _TemplateQuestion('Plot / field identifier', QuestionType.text),
      _TemplateQuestion('Crop or livestock type', QuestionType.text),
      _TemplateQuestion('Treatment group', QuestionType.singleChoice,
          options: ['Control', 'Treatment A', 'Treatment B', 'Treatment C']),
      _TemplateQuestion('Observation date', QuestionType.date),
      _TemplateQuestion('Yield / measured outcome', QuestionType.number),
      _TemplateQuestion('Pest or disease present', QuestionType.yesNo),
      _TemplateQuestion('Environmental observations', QuestionType.text,
          required: false),
    ],
  ),
  'general': _TemplateDefinition(
    'General Student Research Survey',
    'A general mixed-variable instrument suitable for academic studies.',
    [
      _TemplateQuestion('Age', QuestionType.number, min: 0, max: 120),
      _TemplateQuestion('Study group / category', QuestionType.singleChoice,
          options: ['Group A', 'Group B', 'Group C']),
      _TemplateQuestion('Primary outcome measure', QuestionType.number),
      _TemplateQuestion(
          'Agreement with the study statement', QuestionType.likertScale),
      _TemplateQuestion('Additional comments', QuestionType.text,
          required: false),
    ],
  ),
};
