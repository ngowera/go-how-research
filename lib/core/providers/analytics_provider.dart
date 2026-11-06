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
  int _loadGeneration = 0;

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
    final generation = ++_loadGeneration;
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
      if (generation != _loadGeneration) return;

      final results = <AnalyticsResult>[];
      final rawResponseMaps = responses.map((r) => r.responses).toList();
      final requiredQuestionIds =
          questions.where((q) => q.isRequired).map((q) => q.id).toList();

      for (final q in questions) {
        final answerValues = rawResponseMaps
            .map((response) => response[q.id])
            .where(_hasAnswer)
            .toList();
        final answeredCount = answerValues.length;
        final missingCount = responses.length - answeredCount;

        if (q.type == QuestionType.number ||
            q.type == QuestionType.rating ||
            q.type == QuestionType.likertScale) {
          final numericList = <double>[];
          for (final val in answerValues) {
            final numVal = double.tryParse(val.toString());
            if (numVal != null && numVal.isFinite) numericList.add(numVal);
          }
          final meanVal =
              numericList.isEmpty ? null : StatisticsUtils.mean(numericList);
          final medianVal =
              numericList.isEmpty ? null : StatisticsUtils.median(numericList);
          final stdDevVal =
              numericList.isEmpty ? null : StatisticsUtils.stdDev(numericList);
          final minVal =
              numericList.isEmpty ? null : StatisticsUtils.min(numericList);
          final maxVal =
              numericList.isEmpty ? null : StatisticsUtils.max(numericList);
          final q1 = numericList.isEmpty
              ? null
              : StatisticsUtils.percentile(numericList, 25);
          final q3 = numericList.isEmpty
              ? null
              : StatisticsUtils.percentile(numericList, 75);
          final iqr = q1 == null || q3 == null ? null : q3 - q1;
          final lowerFence = iqr == null || q1 == null ? null : q1 - 1.5 * iqr;
          final upperFence = iqr == null || q3 == null ? null : q3 + 1.5 * iqr;
          final outlierCount = lowerFence == null || upperFence == null
              ? 0
              : numericList
                  .where((value) => value < lowerFence || value > upperFence)
                  .length;

          final freqs = <String, int>{};
          for (final n in numericList) {
            final key = n.toString();
            freqs[key] = (freqs[key] ?? 0) + 1;
          }
          final chartData = freqs.entries
              .map((entry) => {
                    'label': entry.key,
                    'value': entry.value.toDouble(),
                  })
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
            respondentCount: responses.length,
            answeredCount: answeredCount,
            missingCount: missingCount,
            q1: q1,
            q3: q3,
            outlierCount: outlierCount,
          ));
        } else if (q.type == QuestionType.multipleChoice) {
          final selections = <String>[
            for (final answer in answerValues)
              if (answer is List)
                ...answer.map((value) => value.toString())
              else
                answer.toString(),
          ];
          final frequencies = StatisticsUtils.categoricalFrequency(selections);
          final chartData = frequencies.entries
              .map((entry) => {
                    'label': entry.key,
                    'value': entry.value.toDouble(),
                  })
              .toList();
          results.add(AnalyticsResult(
            questionId: q.id,
            questionText: q.text,
            type: q.type,
            frequencies: frequencies,
            count: answeredCount,
            chartData: chartData,
            respondentCount: responses.length,
            answeredCount: answeredCount,
            missingCount: missingCount,
          ));
        } else if (q.type == QuestionType.matrix) {
          final rowFrequencies = <String, Map<String, int>>{
            for (final row in q.rows) row: <String, int>{},
          };
          for (final answer in answerValues.whereType<Map>()) {
            for (final entry in answer.entries) {
              if (!_hasAnswer(entry.value)) continue;
              final row = entry.key.toString();
              final value = entry.value.toString().trim();
              final frequencies = rowFrequencies.putIfAbsent(row, () => {});
              frequencies[value] = (frequencies[value] ?? 0) + 1;
            }
          }
          final combined = <String, int>{};
          for (final row in rowFrequencies.values) {
            for (final entry in row.entries) {
              combined[entry.key] = (combined[entry.key] ?? 0) + entry.value;
            }
          }
          results.add(AnalyticsResult(
            questionId: q.id,
            questionText: q.text,
            type: q.type,
            frequencies: combined,
            count: answeredCount,
            chartData: const [],
            respondentCount: responses.length,
            answeredCount: answeredCount,
            missingCount: missingCount,
            rowFrequencies: rowFrequencies,
          ));
        } else if (q.type == QuestionType.date) {
          final dates = answerValues
              .map((answer) => DateTime.tryParse(answer.toString()))
              .whereType<DateTime>()
              .toList();
          final monthCounts = <String, int>{};
          for (final date in dates) {
            final month =
                '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
            monthCounts[month] = (monthCounts[month] ?? 0) + 1;
          }
          if (dates.isNotEmpty) {
            final firstDate = dates.reduce((a, b) => a.isBefore(b) ? a : b);
            final lastDate = dates.reduce((a, b) => a.isAfter(b) ? a : b);
            var cursor = DateTime(firstDate.year, firstDate.month);
            final lastMonth = DateTime(lastDate.year, lastDate.month);
            while (!cursor.isAfter(lastMonth)) {
              final month =
                  '${cursor.year.toString().padLeft(4, '0')}-${cursor.month.toString().padLeft(2, '0')}';
              monthCounts.putIfAbsent(month, () => 0);
              cursor = DateTime(cursor.year, cursor.month + 1);
            }
          }
          final months = monthCounts.keys.toList()..sort();
          final frequencies = {
            for (final month in months) month: monthCounts[month]!,
          };
          results.add(AnalyticsResult(
            questionId: q.id,
            questionText: q.text,
            type: q.type,
            frequencies: frequencies,
            count: dates.length,
            chartData: frequencies.entries
                .map((entry) => {
                      'label': entry.key,
                      'value': entry.value.toDouble(),
                    })
                .toList(),
            respondentCount: responses.length,
            answeredCount: answeredCount,
            missingCount: missingCount,
            min: dates.isEmpty
                ? null
                : dates
                    .map((date) => date.millisecondsSinceEpoch)
                    .reduce((a, b) => a < b ? a : b)
                    .toDouble(),
            max: dates.isEmpty
                ? null
                : dates
                    .map((date) => date.millisecondsSinceEpoch)
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble(),
          ));
        } else if (q.type == QuestionType.text) {
          final textResponses = answerValues
              .whereType<String>()
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList();
          results.add(AnalyticsResult(
            questionId: q.id,
            questionText: q.text,
            type: q.type,
            frequencies: const {},
            count: textResponses.length,
            chartData: const [],
            respondentCount: responses.length,
            answeredCount: answeredCount,
            missingCount: missingCount,
            textResponses: textResponses,
          ));
        } else {
          final values = answerValues.map((value) => value.toString()).toList();
          final frequencies = StatisticsUtils.categoricalFrequency(values);
          final chartData = frequencies.entries
              .map((entry) => {
                    'label': entry.key,
                    'value': entry.value.toDouble(),
                  })
              .toList();
          results.add(AnalyticsResult(
            questionId: q.id,
            questionText: q.text,
            type: q.type,
            frequencies: frequencies,
            count: answeredCount,
            chartData: chartData,
            respondentCount: responses.length,
            answeredCount: answeredCount,
            missingCount: missingCount,
          ));
        }
      }

      final compRate =
          StatisticsUtils.completionRate(rawResponseMaps, requiredQuestionIds);
      final qualScore =
          StatisticsUtils.qualityScore(rawResponseMaps, requiredQuestionIds);

      if (generation != _loadGeneration) return;
      state = state.copyWith(
        results: results,
        isLoading: false,
        completionRate: compRate,
        qualityScore: qualScore,
      );
    } catch (e) {
      if (generation != _loadGeneration) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  bool _hasAnswer(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }
}

final analyticsProvider =
    StateNotifierProvider.family<AnalyticsNotifier, AnalyticsState, String>(
        (ref, projectId) {
  ref.watch(currentUserProvider.select((user) => user?.id));
  final db = ref.watch(databaseProvider);
  return AnalyticsNotifier(db, projectId);
});
