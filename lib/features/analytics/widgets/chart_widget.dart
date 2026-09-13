import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ChartType { bar, pie, line }

class ChartDataPoint {
  final String label;
  final double value;
  final Color color;

  const ChartDataPoint({
    required this.label,
    required this.value,
    required this.color,
  });
}

class ResearchChartWidget extends StatelessWidget {
  final String title;
  final ChartType type;
  final List<ChartDataPoint> data;
  final String? subtitle;

  const ResearchChartWidget({
    super.key,
    required this.title,
    required this.type,
    required this.data,
    this.subtitle,
  });

  static const List<Color> chartColors = [
    Color(0xFF1565C0), // Blue
    Color(0xFF00897B), // Teal
    Color(0xFFF57C00), // Orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFF2E7D32), // Green
    Color(0xFFD81B60), // Pink
    Color(0xFF0288D1), // Light Blue
    Color(0xFFE64A19), // Deep Orange
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 260,
        alignment: Alignment.center,
        child: Text(
          'No data points to chart',
          style: GoogleFonts.poppins(color: Colors.grey.shade500),
        ),
      );
    }

    return Container(
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
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: data.isEmpty
                ? const Center(child: Text('No data available'))
                : switch (type) {
                    ChartType.bar => _buildBarChart(),
                    ChartType.pie => _buildPieChart(),
                    ChartType.line => _buildLineChart(),
                  },
          ),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxY * 1.2).ceilToDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E293B),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = data[groupIndex];
              return BarTooltipItem(
                '${item.label}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: '${item.value.toInt()}',
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                final label = data[idx].label;
                final shortLabel =
                    label.length > 8 ? '${label.substring(0, 6)}..' : label;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    shortLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (val, meta) => Text(
                val.toInt().toString(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (val) => FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: item.value,
                color: item.color,
                width: 28,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart() {
    final total = data.fold<double>(0.0, (sum, item) => sum + item.value);

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 40,
        sections: data.map((item) {
          final pct = total > 0 ? (item.value / total) * 100 : 0.0;
          return PieChartSectionData(
            color: item.color,
            value: item.value,
            title: '${pct.toStringAsFixed(0)}%',
            radius: 50,
            titleStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart() {
    final maxY = data.map((e) => e.value).reduce(mathMax);
    return LineChart(LineChartData(
      minY: 0,
      maxY: maxY == 0 ? 1 : maxY * 1.2,
      gridData: FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length)
              return const SizedBox.shrink();
            final label = data[index].label;
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                  label.length > 8 ? '${label.substring(0, 6)}…' : label,
                  style: const TextStyle(fontSize: 9)),
            );
          },
        )),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
              .toList(),
          color: const Color(0xFF1565C0),
          barWidth: 3,
          isCurved: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF1565C0).withValues(alpha: 0.12)),
        )
      ],
    ));
  }

  static double mathMax(double a, double b) => a > b ? a : b;

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: data.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${item.label} (${item.value.toInt()})',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
