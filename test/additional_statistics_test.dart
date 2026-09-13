import 'package:flutter_test/flutter_test.dart';
import 'package:gohow_research/core/utils/statistics_utils.dart';

void main() {
  test('paired t-test operates on within-record differences', () {
    final result =
        StatisticsUtils.pairedTTest([1, 2, 3, 4, 5], [2, 4, 4, 7, 7]);
    expect(result['difference'], closeTo(1.8, 1e-10));
    expect(result['t'], closeTo(4.810702354, 1e-8));
    expect(result['df'], 4);
    expect(StatisticsUtils.pairedTTest([1], [2])['pValue']!.isNaN, isTrue);
  });
  test('ANOVA and linear regression agree with known examples', () {
    final anova = StatisticsUtils.oneWayAnova([
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]);
    expect(anova['f'], 27);
    expect(anova['etaSquared'], .9);
    expect(anova['pValue'], closeTo(.001, 1e-10));
    final model =
        StatisticsUtils.simpleLinearRegression([1, 2, 3, 4], [3, 5, 7, 9]);
    expect(model['slope'], closeTo(2, 1e-10));
    expect(model['intercept'], closeTo(1, 1e-10));
    expect(model['rSquared'], closeTo(1, 1e-10));
  });
  test('significance uses the configured alpha and handles unavailable results',
      () {
    expect(StatisticsUtils.interpretPValue(.03, alpha: .01),
        contains('Not significant'));
    expect(
        StatisticsUtils.interpretPValue(double.nan), contains('unavailable'));
  });
}
