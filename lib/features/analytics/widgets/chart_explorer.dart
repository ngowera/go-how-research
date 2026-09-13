import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/app_models.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/utils/export_utils.dart';

class ChartExplorer extends ConsumerStatefulWidget {
  final AnalyticsResult result;
  const ChartExplorer({super.key, required this.result});
  @override
  ConsumerState<ChartExplorer> createState() => _ChartExplorerState();
}

class _ChartExplorerState extends ConsumerState<ChartExplorer> {
  String type = 'Bar';
  bool percent = false;
  final boundary = GlobalKey();
  String? error;
  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final numeric = result.mean != null;
    final settings = ref.watch(appSettingsProvider);
    final colors = settings.chartPalette.contains('Emerald')
        ? [
            const Color(0xFF00695C),
            const Color(0xFF26A69A),
            const Color(0xFF81C784),
            const Color(0xFF33691E)
          ]
        : settings.chartPalette.contains('Sunset')
            ? [
                const Color(0xFFE65100),
                const Color(0xFFF9A825),
                const Color(0xFFBF360C),
                const Color(0xFF8D6E63)
              ]
            : settings.chartPalette.contains('Vibrant')
                ? [
                    const Color(0xFF7B1FA2),
                    const Color(0xFFD81B60),
                    const Color(0xFF0288D1),
                    const Color(0xFF43A047)
                  ]
                : settings.chartPalette.contains('Grayscale')
                    ? [
                        Colors.grey.shade800,
                        Colors.grey.shade600,
                        Colors.grey.shade400
                      ]
                    : settings.chartPalette.contains('Colorblind')
                        ? [
                            const Color(0xFF0072B2),
                            const Color(0xFFE69F00),
                            const Color(0xFF009E73),
                            const Color(0xFFCC79A7)
                          ]
                        : [
                            const Color(0xFF1565C0),
                            const Color(0xFF00897B),
                            const Color(0xFFF57C00),
                            const Color(0xFF7B1FA2)
                          ];
    var labels = result.chartData.map((e) => e['label'].toString()).toList();
    var counts =
        result.chartData.map((e) => (e['value'] as num).toDouble()).toList();
    if (type == 'Histogram' && numeric && labels.isNotEmpty) {
      final values = labels.map(double.tryParse).toList();
      final valid = [
        for (var i = 0; i < values.length; i++)
          if (values[i] != null) (values[i]!, counts[i])
      ];
      if (valid.isNotEmpty) {
        final low = valid.map((v) => v.$1).reduce(math.min),
            high = valid.map((v) => v.$1).reduce(math.max);
        final bins =
            low == high ? 1 : math.sqrt(result.count).ceil().clamp(2, 15);
        final width = low == high ? 1.0 : (high - low) / bins;
        counts = List.filled(bins, 0);
        for (final pair in valid) {
          counts[((pair.$1 - low) / width).floor().clamp(0, bins - 1)] +=
              pair.$2;
        }
        labels = List.generate(
            bins,
            (i) =>
                '${(low + i * width).toStringAsFixed(settings.decimalPrecision)}–${(low + (i + 1) * width).toStringAsFixed(settings.decimalPrecision)}${i == bins - 1 ? ' (inclusive)' : ''}');
      }
    }
    final total = counts.fold<double>(0, (a, b) => a + b);
    final values =
        counts.map((n) => percent && total > 0 ? n * 100 / total : n).toList();
    final axis = percent
        ? 'Percent of recorded selections'
        : 'Frequency (recorded selections)';
    final labelList = labels;
    final countList = counts;
    Widget plot;
    if (total <= 0) {
      plot = const SizedBox(
          height: 180,
          child: Center(child: Text('No valid responses to chart.')));
    } else if (type == 'Pie' || type == 'Donut') {
      plot = SizedBox(
          height: 280,
          child: PieChart(PieChartData(
              centerSpaceRadius: type == 'Donut' ? 48 : 0,
              sections: List.generate(
                  values.length,
                  (i) => PieChartSectionData(
                      value: counts[i],
                      color: colors[i % colors.length],
                      radius: 105,
                      title: counts[i] / total < .03
                          ? ''
                          : '${(counts[i] * 100 / total).toStringAsFixed(1)}%',
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11))))));
    } else if (type == 'Horizontal bar') {
      final maxValue = values.reduce(math.max);
      plot = Column(
          children: List.generate(
              labels.length,
              (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Expanded(flex: 2, child: Text(labels[i])),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                            value: values[i] / maxValue,
                            minHeight: 16,
                            color: colors[i % colors.length],
                            backgroundColor: Colors.grey.shade100)),
                    const SizedBox(width: 8),
                    Text(values[i].toStringAsFixed(percent ? 1 : 0))
                  ]))));
    } else {
      final maxY = values.reduce(math.max) * 1.15;
      final titles = FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              axisNameWidget: Text(axis, style: const TextStyle(fontSize: 11)),
              axisNameSize: 24,
              sideTitles: const SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
              axisNameWidget: const Text(
                  'Response / category number (see labels below)',
                  style: TextStyle(fontSize: 11)),
              axisNameSize: 25,
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 25,
                  interval: 1,
                  getTitlesWidget: (v, m) =>
                      v == v.roundToDouble() && v >= 0 && v < labels.length
                          ? Text('${v.toInt() + 1}',
                              style: const TextStyle(fontSize: 11))
                          : const SizedBox.shrink())));
      final chart = type == 'Line'
          ? LineChart(LineChartData(
              minX: 0,
              maxX: math.max(1, values.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              titlesData: titles,
              lineBarsData: [
                  LineChartBarData(
                      isCurved: false,
                      color: colors.first,
                      spots: List.generate(values.length,
                          (i) => FlSpot(i.toDouble(), values[i])),
                      dotData: const FlDotData(show: true))
                ]))
          : BarChart(BarChartData(
              minY: 0,
              maxY: maxY,
              titlesData: titles,
              barGroups: List.generate(
                  values.length,
                  (i) => BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                            toY: values[i],
                            color: colors[i % colors.length],
                            width: type == 'Histogram' ? 28 : 20,
                            borderRadius: BorderRadius.zero)
                      ]))));
      plot = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
              width: math.max(
                  MediaQuery.sizeOf(context).width > 1000 ? 650 : 300,
                  labels.length * 44.0),
              height: 280,
              child: chart));
    }
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<String>(
                        value: type,
                        items: [
                          'Bar',
                          'Horizontal bar',
                          'Pie',
                          'Donut',
                          if (numeric) 'Line',
                          if (numeric) 'Histogram'
                        ]
                            .map((v) =>
                                DropdownMenuItem(value: v, child: Text(v)))
                            .toList(),
                        onChanged: (v) => setState(() => type = v!)),
                    FilterChip(
                        label: const Text('Percentages'),
                        selected: percent,
                        onSelected: (v) => setState(() => percent = v)),
                    TextButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Save figure'),
                        onPressed: () async {
                          try {
                            final render = boundary.currentContext!
                                .findRenderObject() as RenderRepaintBoundary;
                            final image = await render.toImage(pixelRatio: 2);
                            final bytes = await image.toByteData(
                                format: ui.ImageByteFormat.png);
                            image.dispose();
                            await ExportUtils.exportFile('research_chart.png',
                                bytes!.buffer.asUint8List(),
                                mimeType: 'image/png',
                                subject: result.questionText);
                          } catch (e) {
                            if (mounted)
                              setState(
                                  () => error = 'Could not save chart. $e');
                          }
                        }),
                  ]),
              RepaintBoundary(
                  key: boundary,
                  child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(result.questionText,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            Text('Answered records: ${result.count} • $axis',
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 12)),
                            if (type == 'Line')
                              const Text(
                                  'Numeric values in ascending order; this is a frequency distribution, not a time trend.',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.black54)),
                            if (type == 'Histogram')
                              const Text(
                                  'Equal-width bins; lower boundary inclusive, upper boundary exclusive except last bin.',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.black54)),
                            const SizedBox(height: 16),
                            plot,
                            const SizedBox(height: 12),
                            ...List.generate(
                                labelList.length,
                                (i) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              width: 12,
                                              height: 12,
                                              margin: const EdgeInsets.only(
                                                  top: 3, right: 8),
                                              color: colors[i % colors.length]),
                                          Expanded(
                                              child: Text(
                                                  '${i + 1}. ${labelList[i]}',
                                                  style: const TextStyle(
                                                      color: Colors.black87))),
                                          Text(
                                              '${countList[i].toInt()}  (${total > 0 ? (countList[i] * 100 / total).toStringAsFixed(1) : '0'}%)',
                                              style: const TextStyle(
                                                  color: Colors.black87))
                                        ]))),
                          ]))),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
            ])));
  }
}
