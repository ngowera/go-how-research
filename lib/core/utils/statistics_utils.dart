import 'dart:math' as math;

class StatisticsUtils {
  // ── Descriptive Statistics ────────────────────────────────────────────────

  static double mean(List<double> values) {
    if (values.isEmpty) return 0.0;
    final sum = values.reduce((a, b) => a + b);
    return sum / values.length;
  }

  static double median(List<double> values) {
    if (values.isEmpty) return 0.0;
    final sorted = List<double>.from(values)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length % 2 == 1) {
      return sorted[mid];
    } else {
      return (sorted[mid - 1] + sorted[mid]) / 2.0;
    }
  }

  static double mode(List<double> values) {
    if (values.isEmpty) return 0.0;
    final freqs = <double, int>{};
    for (final v in values) {
      freqs[v] = (freqs[v] ?? 0) + 1;
    }
    double maxVal = values.first;
    int maxCount = 0;
    for (final entry in freqs.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        maxVal = entry.key;
      }
    }
    return maxVal;
  }

  static double variance(List<double> values) {
    if (values.length <= 1) return 0.0;
    final m = mean(values);
    final sumSquares =
        values.fold<double>(0.0, (sum, val) => sum + math.pow(val - m, 2));
    return sumSquares / (values.length - 1);
  }

  static double stdDev(List<double> values) {
    return math.sqrt(variance(values));
  }

  static double min(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce(math.min);
  }

  static double max(List<double> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce(math.max);
  }

  static double range(List<double> values) {
    if (values.isEmpty) return 0.0;
    return max(values) - min(values);
  }

  static double percentile(List<double> values, double p) {
    if (values.isEmpty) return 0.0;
    final sorted = List<double>.from(values)..sort();
    if (p <= 0) return sorted.first;
    if (p >= 100) return sorted.last;

    final index = (p / 100.0) * (sorted.length - 1);
    final lower = index.floor();
    final upper = index.ceil();
    final weight = index - lower;

    if (lower == upper) return sorted[lower];
    return sorted[lower] * (1.0 - weight) + sorted[upper] * weight;
  }

  // ── Categorical Statistics ────────────────────────────────────────────────

  static Map<String, int> categoricalFrequency(List<String> values) {
    final freqs = <String, int>{};
    for (final v in values) {
      final key = v.trim().isEmpty ? '(Empty)' : v.trim();
      freqs[key] = (freqs[key] ?? 0) + 1;
    }
    return freqs;
  }

  static Map<String, double> categoricalPercentage(List<String> values) {
    if (values.isEmpty) return {};
    final freqs = categoricalFrequency(values);
    final total = values.length;
    return freqs.map((key, count) => MapEntry(key, (count / total) * 100.0));
  }

  // ── Cross-Tabulation ──────────────────────────────────────────────────────

  static Map<String, Map<String, int>> crossTabulate(
    List<String> rowValues,
    List<String> colValues,
  ) {
    final result = <String, Map<String, int>>{};
    final len = math.min(rowValues.length, colValues.length);

    for (int i = 0; i < len; i++) {
      final r = rowValues[i].trim().isEmpty ? '(Empty)' : rowValues[i].trim();
      final c = colValues[i].trim().isEmpty ? '(Empty)' : colValues[i].trim();

      result.putIfAbsent(r, () => <String, int>{});
      result[r]![c] = (result[r]![c] ?? 0) + 1;
    }
    return result;
  }

  // ── Chi-Square Test of Independence ───────────────────────────────────────

  static Map<String, double> chiSquareTest(
    Map<String, Map<String, int>> contingencyTable,
  ) {
    final rowKeys = contingencyTable.keys.toList();
    final colKeys = <String>{};
    for (final r in rowKeys) {
      colKeys.addAll(contingencyTable[r]!.keys);
    }
    final colList = colKeys.toList();

    if (rowKeys.length < 2 || colList.length < 2) {
      return {'chiSquare': 0.0, 'degreesOfFreedom': 0.0, 'pValue': 1.0};
    }

    final rowTotals = <String, int>{};
    final colTotals = <String, int>{};
    int grandTotal = 0;

    for (final r in rowKeys) {
      rowTotals[r] = 0;
      for (final c in colList) {
        final observed = contingencyTable[r]?[c] ?? 0;
        rowTotals[r] = rowTotals[r]! + observed;
        colTotals[c] = (colTotals[c] ?? 0) + observed;
        grandTotal += observed;
      }
    }

    if (grandTotal == 0) {
      return {'chiSquare': 0.0, 'degreesOfFreedom': 0.0, 'pValue': 1.0};
    }

    double chiSquare = 0.0;
    double minExpected = double.infinity;
    var cellsBelowFive = 0;
    for (final r in rowKeys) {
      for (final c in colList) {
        final observed = contingencyTable[r]?[c] ?? 0;
        final expected = (rowTotals[r]! * colTotals[c]!) / grandTotal;
        minExpected = math.min(minExpected, expected);
        if (expected < 5) cellsBelowFive++;
        if (expected > 0) {
          chiSquare += math.pow(observed - expected, 2) / expected;
        }
      }
    }

    final df = (rowKeys.length - 1) * (colList.length - 1);
    final pValue = _regularizedGammaQ(df / 2, chiSquare / 2);
    final denominator =
        grandTotal * math.min(rowKeys.length - 1, colList.length - 1);
    final cramerV = denominator > 0 ? math.sqrt(chiSquare / denominator) : 0.0;

    return {
      'chiSquare': chiSquare,
      'degreesOfFreedom': df.toDouble(),
      'pValue': pValue,
      'cramerV': cramerV,
      'minExpected': minExpected.isFinite ? minExpected : 0,
      'cellsBelowFive': cellsBelowFive.toDouble(),
      'totalCells': (rowKeys.length * colList.length).toDouble(),
    };
  }

  /// Upper regularized incomplete gamma Q(a, x), used for chi-square p-values.
  static double _regularizedGammaQ(double a, double x) {
    if (a <= 0 || x < 0) return double.nan;
    if (x == 0) return 1;
    const eps = 1e-14;
    const maxIterations = 10000;
    if (x < a + 1) {
      var sum = 1 / a;
      var term = sum;
      var ap = a;
      for (var i = 1; i <= maxIterations; i++) {
        ap += 1;
        term *= x / ap;
        sum += term;
        if (term.abs() < sum.abs() * eps) break;
      }
      final p = sum * math.exp(-x + a * math.log(x) - _logGamma(a));
      return (1 - p).clamp(0.0, 1.0);
    }
    var b = x + 1 - a;
    var c = 1 / 1e-300;
    var d = 1 / b;
    var h = d;
    for (var i = 1; i <= maxIterations; i++) {
      final an = -i * (i - a);
      b += 2;
      d = an * d + b;
      if (d.abs() < 1e-300) d = 1e-300;
      c = b + an / c;
      if (c.abs() < 1e-300) c = 1e-300;
      d = 1 / d;
      final delta = d * c;
      h *= delta;
      if ((delta - 1).abs() < eps) break;
    }
    return (math.exp(-x + a * math.log(x) - _logGamma(a)) * h).clamp(0.0, 1.0);
  }

  static double _logGamma(double z) {
    const coefficients = [
      676.5203681218851,
      -1259.1392167224028,
      771.3234287776531,
      -176.6150291621406,
      12.507343278686905,
      -0.13857109526572012,
      9.984369578019572e-6,
      1.5056327351493116e-7,
    ];
    if (z < 0.5) {
      return math.log(math.pi) -
          math.log(math.sin(math.pi * z)) -
          _logGamma(1 - z);
    }
    var x = 0.9999999999998099;
    final shifted = z - 1;
    for (var i = 0; i < coefficients.length; i++) {
      x += coefficients[i] / (shifted + i + 1);
    }
    final t = shifted + coefficients.length - 0.5;
    return 0.5 * math.log(2 * math.pi) +
        (shifted + 0.5) * math.log(t) -
        t +
        math.log(x);
  }

  /// Approximate 95% confidence interval for a sample mean.
  static List<double> meanConfidenceInterval95(
      double sampleMean, double sampleStdDev, int n) {
    if (n < 2) return [sampleMean, sampleMean];
    // Student-t critical values are materially important for small samples.
    const critical = <int, double>{
      1: 12.706,
      2: 4.303,
      3: 3.182,
      4: 2.776,
      5: 2.571,
      6: 2.447,
      7: 2.365,
      8: 2.306,
      9: 2.262,
      10: 2.228,
      11: 2.201,
      12: 2.179,
      13: 2.160,
      14: 2.145,
      15: 2.131,
      16: 2.120,
      17: 2.110,
      18: 2.101,
      19: 2.093,
      20: 2.086,
      21: 2.080,
      22: 2.074,
      23: 2.069,
      24: 2.064,
      25: 2.060,
      26: 2.056,
      27: 2.052,
      28: 2.048,
      29: 2.045,
      30: 2.042,
    };
    final df = n - 1;
    final t = critical[df] ?? (df < 60 ? 2.0 : 1.96);
    final margin = t * sampleStdDev / math.sqrt(n);
    return [sampleMean - margin, sampleMean + margin];
  }

  // ── Pearson Correlation ───────────────────────────────────────────────────

  static double pearsonCorrelation(List<double> x, List<double> y) {
    final n = math.min(x.length, y.length);
    if (n <= 1) return 0.0;

    final meanX = mean(x.sublist(0, n));
    final meanY = mean(y.sublist(0, n));

    double num = 0.0;
    double denomX = 0.0;
    double denomY = 0.0;

    for (int i = 0; i < n; i++) {
      final dx = x[i] - meanX;
      final dy = y[i] - meanY;
      num += dx * dy;
      denomX += dx * dx;
      denomY += dy * dy;
    }

    final denom = math.sqrt(denomX * denomY);
    if (denom == 0.0) return 0.0;
    return (num / denom).clamp(-1.0, 1.0);
  }

  static Map<String, double> pearsonCorrelationTest(
      List<double> x, List<double> y) {
    final n = math.min(x.length, y.length);
    final r = pearsonCorrelation(x, y);
    if (n < 3 || r.abs() >= 1) {
      return {'r': r, 'pValue': r.abs() >= 1 ? 0 : 1, 'n': n.toDouble()};
    }
    final t = r * math.sqrt((n - 2) / (1 - r * r));
    return {
      'r': r,
      'pValue': _studentTTwoTailedP(t.abs(), n - 2),
      'n': n.toDouble(),
    };
  }

  /// Welch independent-samples t-test; equal variances are not assumed.
  static Map<String, double> welchTTest(
      List<double> first, List<double> second) {
    if (first.length < 2 || second.length < 2) {
      return {
        't': double.nan,
        'degreesOfFreedom': double.nan,
        'pValue': double.nan,
        'cohensD': double.nan,
      };
    }
    final m1 = mean(first), m2 = mean(second);
    final v1 = variance(first), v2 = variance(second);
    final a = v1 / first.length, b = v2 / second.length;
    final standardError = math.sqrt(a + b);
    if (standardError == 0) {
      return {
        't': 0,
        'degreesOfFreedom': (first.length + second.length - 2).toDouble(),
        'pValue': 1,
        'cohensD': 0,
      };
    }
    final t = (m1 - m2) / standardError;
    final df = math.pow(a + b, 2) /
        (math.pow(a, 2) / (first.length - 1) +
            math.pow(b, 2) / (second.length - 1));
    final pooledVariance =
        ((first.length - 1) * v1 + (second.length - 1) * v2) /
            (first.length + second.length - 2);
    final d = pooledVariance > 0 ? (m1 - m2) / math.sqrt(pooledVariance) : 0.0;
    return {
      't': t,
      'degreesOfFreedom': df,
      'pValue': _studentTTwoTailedP(t.abs(), df),
      'cohensD': d,
      'mean1': m1,
      'mean2': m2,
      'n1': first.length.toDouble(),
      'n2': second.length.toDouble(),
    };
  }

  static double _studentTTwoTailedP(double absoluteT, double df) {
    if (!absoluteT.isFinite || df <= 0) return double.nan;
    final x = df / (df + absoluteT * absoluteT);
    return _regularizedBeta(x, df / 2, 0.5).clamp(0.0, 1.0);
  }

  static Map<String, double> pairedTTest(
      List<double> before, List<double> after) {
    if (before.length != after.length ||
        before.length < 2 ||
        [...before, ...after].any((v) => !v.isFinite))
      return {'pValue': double.nan};
    final differences =
        List.generate(before.length, (i) => after[i] - before[i]);
    final average = mean(differences),
        sd = stdDev(differences),
        n = differences.length;
    if (sd == 0)
      return {'pValue': double.nan, 'n': n.toDouble(), 'difference': average};
    final t = average / (sd / math.sqrt(n));
    final ci = meanConfidenceInterval95(average, sd, n);
    return {
      'n': n.toDouble(),
      'difference': average,
      't': t,
      'df': n - 1.0,
      'pValue': _studentTTwoTailedP(t.abs(), n - 1.0),
      'lower': ci[0],
      'upper': ci[1],
      'dz': average / sd
    };
  }

  static Map<String, double> oneWayAnova(List<List<double>> groups) {
    if (groups.length < 2 ||
        groups.any((g) => g.length < 2 || g.any((v) => !v.isFinite)))
      return {'pValue': double.nan};
    final values = groups.expand((g) => g).toList(),
        average = mean(groups.expand((g) => g).toList());
    final between = groups.fold<double>(
        0, (s, g) => s + g.length * math.pow(mean(g) - average, 2));
    final within =
        groups.fold<double>(0, (s, g) => s + (g.length - 1) * variance(g));
    final df1 = groups.length - 1.0,
        df2 = values.length - groups.length.toDouble();
    if (within == 0) return {'pValue': double.nan};
    final f = (between / df1) / (within / df2);
    final p = _regularizedBeta(df2 / (df2 + df1 * f), df2 / 2, df1 / 2);
    return {
      'f': f,
      'df1': df1,
      'df2': df2,
      'pValue': p,
      'etaSquared': between / (between + within),
      'n': values.length.toDouble()
    };
  }

  static Map<String, double> simpleLinearRegression(
      List<double> x, List<double> y) {
    if (x.length != y.length ||
        x.length < 3 ||
        variance(x) == 0 ||
        variance(y) == 0) return {'slope': double.nan};
    final correlation = pearsonCorrelationTest(x, y), r = correlation['r']!;
    final slope = r * stdDev(y) / stdDev(x);
    return {
      'slope': slope,
      'intercept': mean(y) - slope * mean(x),
      'rSquared': r * r,
      'pValue': correlation['pValue']!,
      'n': x.length.toDouble()
    };
  }

  static double _regularizedBeta(double x, double a, double b) {
    if (x <= 0) return 0;
    if (x >= 1) return 1;
    final front = math.exp(_logGamma(a + b) -
        _logGamma(a) -
        _logGamma(b) +
        a * math.log(x) +
        b * math.log(1 - x));
    if (x < (a + 1) / (a + b + 2)) {
      return front * _betaContinuedFraction(x, a, b) / a;
    }
    return 1 - front * _betaContinuedFraction(1 - x, b, a) / b;
  }

  static double _betaContinuedFraction(double x, double a, double b) {
    const maxIterations = 500;
    const eps = 3e-14;
    const tiny = 1e-300;
    var qab = a + b, qap = a + 1, qam = a - 1;
    var c = 1.0;
    var d = 1 - qab * x / qap;
    if (d.abs() < tiny) d = tiny;
    d = 1 / d;
    var h = d;
    for (var m = 1; m <= maxIterations; m++) {
      final m2 = 2 * m;
      var aa = m * (b - m) * x / ((qam + m2) * (a + m2));
      d = 1 + aa * d;
      if (d.abs() < tiny) d = tiny;
      c = 1 + aa / c;
      if (c.abs() < tiny) c = tiny;
      d = 1 / d;
      h *= d * c;
      aa = -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2));
      d = 1 + aa * d;
      if (d.abs() < tiny) d = tiny;
      c = 1 + aa / c;
      if (c.abs() < tiny) c = tiny;
      d = 1 / d;
      final delta = d * c;
      h *= delta;
      if ((delta - 1).abs() < eps) break;
    }
    return h;
  }

  /// Diagnostic accuracy from a 2×2 table against a reference standard.
  static Map<String, double> diagnosticAccuracy({
    required int truePositive,
    required int falsePositive,
    required int falseNegative,
    required int trueNegative,
  }) {
    double ratio(int numerator, int denominator) =>
        denominator == 0 ? double.nan : numerator / denominator;
    final total = truePositive + falsePositive + falseNegative + trueNegative;
    return {
      'sensitivity': ratio(truePositive, truePositive + falseNegative),
      'specificity': ratio(trueNegative, trueNegative + falsePositive),
      'positivePredictiveValue':
          ratio(truePositive, truePositive + falsePositive),
      'negativePredictiveValue':
          ratio(trueNegative, trueNegative + falseNegative),
      'accuracy': ratio(truePositive + trueNegative, total),
    };
  }

  // ── Data Quality & Cleaning ───────────────────────────────────────────────

  static double completionRate(
    List<Map<String, dynamic>> responses,
    List<String> requiredFields,
  ) {
    if (responses.isEmpty || requiredFields.isEmpty) return 100.0;
    int completeCount = 0;

    for (final resp in responses) {
      final isComplete = requiredFields.every((field) {
        final val = resp[field];
        return val != null && val.toString().trim().isNotEmpty;
      });
      if (isComplete) completeCount++;
    }

    return (completeCount / responses.length) * 100.0;
  }

  static List<int> detectOutliers(List<double> values) {
    if (values.length < 4) return [];
    final q1 = percentile(values, 25);
    final q3 = percentile(values, 75);
    final iqr = q3 - q1;
    final lowerBound = q1 - 1.5 * iqr;
    final upperBound = q3 + 1.5 * iqr;

    final outlierIndices = <int>[];
    for (int i = 0; i < values.length; i++) {
      if (values[i] < lowerBound || values[i] > upperBound) {
        outlierIndices.add(i);
      }
    }
    return outlierIndices;
  }

  static double qualityScore(
    List<Map<String, dynamic>> responses,
    List<String> requiredFields,
  ) {
    if (responses.isEmpty) return 100.0;
    final compRate = completionRate(responses, requiredFields);
    // Quality based on completeness and data volume
    final volumeBonus = math.min(responses.length / 50.0, 1.0) * 10.0;
    return (compRate * 0.9 + volumeBonus).clamp(0.0, 100.0);
  }

  static String formatNumber(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }

  static String interpretPValue(double p, {double alpha = .05}) {
    if (!p.isFinite || p < 0 || p > 1) return 'Test unavailable for these data';
    final value =
        p < .001 ? 'p < 0.001' : 'p = ${formatNumber(p, decimals: 3)}';
    return '$value (${p < alpha ? 'Significant' : 'Not significant'} at α=$alpha)';
  }
}
