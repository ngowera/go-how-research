import 'package:flutter_test/flutter_test.dart';
import 'package:gohow_research/core/utils/statistics_utils.dart';

void main() {
  group('StatisticsUtils', () {
    test('calculates descriptive statistics', () {
      final values = <double>[1, 2, 2, 3, 7];
      expect(StatisticsUtils.mean(values), 3);
      expect(StatisticsUtils.median(values), 2);
      expect(StatisticsUtils.mode(values), 2);
      expect(StatisticsUtils.range(values), 6);
    });

    test('calculates completion rate', () {
      final responses = <Map<String, dynamic>>[
        {'name': 'A', 'age': 20},
        {'name': 'B', 'age': null},
      ];
      expect(StatisticsUtils.completionRate(responses, ['name', 'age']), 50);
    });

    test('chi-square significance decreases as association strengthens', () {
      final weak = StatisticsUtils.chiSquareTest({
        'A': {'yes': 5, 'no': 5},
        'B': {'yes': 5, 'no': 5},
      });
      final strong = StatisticsUtils.chiSquareTest({
        'A': {'yes': 10, 'no': 0},
        'B': {'yes': 0, 'no': 10},
      });
      expect(strong['pValue']!, lessThan(weak['pValue']!));
    });
  });

  test('chi-square reports known statistic, p-value and effect size', () {
    final result = StatisticsUtils.chiSquareTest({
      'Treatment': {'Improved': 30, 'Not improved': 10},
      'Control': {'Improved': 15, 'Not improved': 25},
    });
    expect(result['chiSquare'], closeTo(11.4286, 0.001));
    expect(result['pValue'], closeTo(0.00072, 0.0001));
    expect(result['cramerV'], closeTo(0.378, 0.002));
  });

  test('95% confidence interval uses Student t for a small sample', () {
    final interval = StatisticsUtils.meanConfidenceInterval95(10, 2, 10);
    expect(interval.first, closeTo(8.57, 0.02));
    expect(interval.last, closeTo(11.43, 0.02));
  });

  test('diagnostic accuracy returns sensitivity and specificity', () {
    final result = StatisticsUtils.diagnosticAccuracy(
      truePositive: 80,
      falsePositive: 10,
      falseNegative: 20,
      trueNegative: 90,
    );
    expect(result['sensitivity'], 0.8);
    expect(result['specificity'], 0.9);
    expect(result['accuracy'], 0.85);
  });

  test('Pearson correlation test detects a strong linear relationship', () {
    final result = StatisticsUtils.pearsonCorrelationTest(
        [1, 2, 3, 4, 5], [2, 4, 6, 8, 10]);
    expect(result['r'], closeTo(1, 1e-12));
    expect(result['pValue'], 0);
    expect(result['n'], 5);
  });

  test('Welch t-test reports group means and a two-tailed p-value', () {
    final result =
        StatisticsUtils.welchTTest([10, 11, 12, 13, 14], [20, 21, 22, 23, 24]);
    expect(result['mean1'], 12);
    expect(result['mean2'], 22);
    expect(result['pValue']!, lessThan(0.001));
    expect(result['cohensD']!.abs(), greaterThan(5));
  });
}
