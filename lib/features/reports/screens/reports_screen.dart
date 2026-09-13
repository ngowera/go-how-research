import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/analytics_provider.dart';
import '../../../core/providers/projects_provider.dart';
import '../../../core/providers/questionnaire_provider.dart';
import '../../../core/utils/export_utils.dart';
import '../../../shared/theme/app_theme.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String? _selectedProjectId;

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider).projects;
    if (projects.isNotEmpty && _selectedProjectId == null) {
      _selectedProjectId = projects.first.id;
    }

    final currentProj = projects.isEmpty
        ? null
        : projects.firstWhere(
            (p) => p.id == _selectedProjectId,
            orElse: () => projects.first,
          );

    final analyticsState = _selectedProjectId != null
        ? ref.watch(analyticsProvider(_selectedProjectId!))
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Research Reports & Dissemination',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Automated executive summaries, methodology synthesis, and publication-ready tables',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (projects.isNotEmpty)
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: _selectedProjectId,
                        items: projects.map((p) {
                          return DropdownMenuItem(
                            value: p.id,
                            child: Text(p.title),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedProjectId = v),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton.icon(
                        onPressed: currentProj == null
                            ? null
                            : () async {
                                try {
                                  final bytes =
                                      await ExportUtils.researchReportPdf(
                                    currentProj,
                                    analyticsState?.results ?? const [],
                                    qualityScore:
                                        analyticsState?.qualityScore ?? 0,
                                    completionRate:
                                        analyticsState?.completionRate ?? 0,
                                  );
                                  final safeTitle = currentProj.title
                                      .replaceAll(
                                          RegExp(r'[^A-Za-z0-9_-]+'), '_');
                                  await ExportUtils.exportFile(
                                    '${safeTitle}_research_report.pdf',
                                    bytes,
                                    mimeType: 'application/pdf',
                                    subject:
                                        '${currentProj.title} Research Report',
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('PDF report created.'),
                                      backgroundColor: AppTheme.kSuccess,
                                    ),
                                  );
                                } catch (error) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Export failed: $error')),
                                  );
                                }
                              },
                        icon: const Icon(Icons.print_rounded, size: 18),
                        label: const Text('Export Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.kPrimary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Report Preview Document
            Expanded(
              child: currentProj == null
                  ? Center(
                      child: Text(
                        'No research projects found. Create a project to view reports.',
                        style: GoogleFonts.poppins(color: Colors.grey.shade600),
                      ),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 850),
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Document Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'GOHOW RESEARCH REPORT',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.kPrimary,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          currentProj.title,
                                          style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color:
                                            AppTheme.kPrimary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.school_rounded,
                                          color: AppTheme.kPrimary, size: 28),
                                    ),
                                  ],
                                ),
                                const Divider(height: 32),

                                // Executive Summary
                                Text(
                                  '1. Executive Summary',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentProj.description.isEmpty
                                      ? 'This report outlines preliminary field findings, descriptive statistics, and questionnaire response distributions conducted under the research project framework.'
                                      : currentProj.description,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    height: 1.6,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Methodology & Study Design
                                Text(
                                  '2. Methodology & Study Design',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Table(
                                  border: TableBorder.all(
                                      color: Colors.grey.shade200),
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFF8FAFC)),
                                      children: [
                                        _cell('Parameter', isBold: true),
                                        _cell('Study Specification',
                                            isBold: true),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        _cell('Methodology'),
                                        _cell(currentProj.methodology),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        _cell('Target Population'),
                                        _cell(currentProj.population),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        _cell('Target Sample Size (N)'),
                                        _cell(
                                            '${currentProj.sampleSize} subjects'),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        _cell('Sites / Locations'),
                                        _cell(currentProj.sites.join(', ')),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        _cell('Data Quality Rating'),
                                        _cell(
                                            '${analyticsState?.qualityScore.toStringAsFixed(1) ?? "0.0"}% compliance'),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Key Variables & Summary
                                Text(
                                  '3. Summary of Analysed Variables',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (analyticsState == null ||
                                    analyticsState.results.isEmpty)
                                  Text(
                                    'No completed responses logged yet to generate numerical distribution tables.',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey.shade600),
                                  )
                                else
                                  ...analyticsState.results.map((r) {
                                    final statSummary = r.mean != null
                                        ? 'Mean: ${r.mean?.toStringAsFixed(2)} • Median: ${r.median?.toStringAsFixed(2)} • SD: ${r.stdDev?.toStringAsFixed(2)} (n=${r.count})'
                                        : 'Mode: ${r.frequencies.keys.isNotEmpty ? r.frequencies.keys.first : "N/A"} • Total responses: ${r.count}';
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(r.questionText,
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13)),
                                            const SizedBox(height: 4),
                                            Text(statSummary,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: AppTheme.kPrimary)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                const SizedBox(height: 24),

                                // Ethics and Governance
                                Text(
                                  '4. Ethics & Data Governance',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'All participant records maintain cryptographic and local storage integrity in accordance with university institutional review board (IRB) ethics protocols.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    height: 1.6,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
