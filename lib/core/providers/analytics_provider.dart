import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

import '../database/app_database.dart' show AppDatabase, databaseProvider;
import '../models/app_models.dart';
import '../utils/statistics_utils.dart';

class AnalyticsState {
  final List<AnalyticsResult> results;
  final bool isLoading;
  final String? error;
  final String? selectedQuestionnaireId;
  final double completionRate;
  final double qualityScore;

  const AnalyticsState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.selectedQuestionnaireId,
    this.completionRate = 0.0,
    this.qualityScore = 0.0,
  });

  AnalyticsState copyWith({
    List<AnalyticsResult>? results,
    bool? isLoading,
    String? error,
    String? selectedQuestionnaireId,
    double? completionRate,
    double? qualityScore,
  }) {
    return AnalyticsState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedQuestionnaireId:
          selectedQuestionnaireId ?? this.selectedQuestionnaireId,
      completionRate: completionRate ?? this.completionRate,
      qualityScore: qualityScore ?? this.qualityScore,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AppDatabase _db;
  final String projectId;

  AnalyticsNotifier(this._db, this.projectId) : super(const AnalyticsState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final questionnaires = await _db.getQuestionnaires(projectId: projectId);
      if (questionnaires.isNotEmpty) {
        await loadAnalyticsForQuestionnaire(questionnaires.first.id);
      } else {
        state = state.copyWith(isLoading: false, results: []);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAnalyticsForQuestionnaire(String questionnaireId) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedQuestionnaireId: questionnaireId,
    );

    try {
      final questions =
          await _db.getQuestions(questionnaireId: questionnaireId);
      final responses =
          await _db.getResponses(questionnaireId: questionnaireId);

      if (responses.isEmpty) {
        state = state.copyWith(
          results: const [],
          isLoading: false,
          completionRate: 0,
          qualityScore: 0,
        );
        return;
      }

      final results = <AnalyticsResult>[];
      final rawResponseMaps = responses.map((r) => r.responses).toList();
      final requiredQuestionIds =
          questions.where((q) => q.isRequired).map((q) => q.id).toList();

      for (final q in questions) {
        final answerValues = <dynamic>[];
        for (final resp in rawResponseMaps) {
          if (resp.containsKey(q.id) && resp[q.id] != null) {
            answerValues.add(resp[q.id]);
          }
        }

        if (q.type == QuestionType.number ||
            q.type == QuestionType.rating ||
            q.type == QuestionType.likertScale) {
          final numericList = <double>[];
          for (final val in answerValues) {
            final numVal = double.tryParse(val.toString());
            if (numVal != null && numVal.isFinite) numericList.add(numVal);
          }

          final meanVal = StatisticsUtils.mean(numericList);
          final medianVal = StatisticsUtils.median(numericList);
          final stdDevVal = StatisticsUtils.stdDev(numericList);
          final minVal = StatisticsUtils.min(numericList);
          final maxVal = StatisticsUtils.max(numericList);

          // Histogram or freq
          final freqs = <String, int>{};
          for (final n in numericList) {
            final k = n.toString();
            freqs[k] = (freqs[k] ?? 0) + 1;
          }

          final chartData = freqs.entries
              .map((e) => {'label': e.key, 'value': e.value.toDouble()})
              .toList()
            ..sort((a, b) => (double.tryParse(a['label'] as String) ?? 0)
                .compareTo(double.tryParse(b['label'] as String) ?? 0));

          results.add(AnalyticsResult(
            questionId: q.id,
            questionText: q.text,
            type: q.type,
            frequencies: freqs,
            mean: meanVal,
            median: medianVal,
            stdDev: stdDevVal,
            min: minVal,
            max: maxVal,
            count: numericList.length,
            chartData: chartData,
          ));
        } else {
          // Categorical or text
          final stringList = <String>[];
          for (final value in answerValues) {
            if (value is List) {
              stringList.addAll(value.map((item) => item.toString()));
            } else if (value is Map) {
              for (final entry in value.entries) {
                stringList.add('${entry.key}: ${entry.value}');
              }
            } else {
              stringList.add(value.toString());
            }
          }
          final freqs = StatisticsUtils.categoricalFrequency(stringList);

          final chartData = freqs.entries
              .map((e) => {'label': e.key, 'value': e.value.toDouble()})
              .toList();

          results.add(AnalyticsResult(
            questionId: q.id,
            questionText: q.text,
            type: q.type,
            frequencies: freqs,
            count: answerValues.length,
            chartData: chartData,
          ));
        }
      }

      final compRate =
          StatisticsUtils.completionRate(rawResponseMaps, requiredQuestionIds);
      final qualScore =
          StatisticsUtils.qualityScore(rawResponseMaps, requiredQuestionIds);

      state = state.copyWith(
        results: results,
        isLoading: false,
        completionRate: compRate,
        qualityScore: qualScore,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final analyticsProvider =
    StateNotifierProvider.family<AnalyticsNotifier, AnalyticsState, String>(
        (ref, projectId) {
  ref.watch(currentUserProvider.select((user) => user?.id));
  final db = ref.watch(databaseProvider);
  return AnalyticsNotifier(db, projectId);
});
