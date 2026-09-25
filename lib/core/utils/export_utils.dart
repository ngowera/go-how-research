import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/app_models.dart';
import 'file_export_stub.dart'
    if (dart.library.io) 'file_export_native.dart'
    if (dart.library.html) 'file_export_web.dart' as platform;

class ExportUtils {
  static Future<List<int>> researchReportPdf(
    ResearchProject project,
    List<AnalyticsResult> results, {
    required double qualityScore,
    required double completionRate,
  }) async {
    final document = pw.Document(
      title: '${project.title} — Research Report',
      author: 'Go-How RS',
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (_) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('GO-HOW RS REPORT',
                style: pw.TextStyle(
                    color: PdfColors.teal700, fontWeight: pw.FontWeight.bold)),
            pw.Text(DateTime.now().toIso8601String().split('T').first),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}'),
        ),
        build: (_) => [
          pw.SizedBox(height: 20),
          pw.Text(project.title,
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 18),
          _pdfHeading('1. Executive Summary'),
          pw.Text(project.description.isEmpty
              ? 'No executive summary has been entered for this project.'
              : project.description),
          pw.SizedBox(height: 16),
          _pdfHeading('2. Study Design'),
          pw.TableHelper.fromTextArray(
            headers: const ['Parameter', 'Study specification'],
            data: [
              ['Methodology', project.methodology],
              ['Target population', project.population],
              ['Target sample size', project.sampleSize.toString()],
              ['Sites / locations', project.sites.join(', ')],
              ['Completion rate', '${completionRate.toStringAsFixed(1)}%'],
              ['Data quality score', '${qualityScore.toStringAsFixed(1)}%'],
            ],
            headerDecoration: const pw.BoxDecoration(color: PdfColors.teal700),
            headerStyle: pw.TextStyle(
                color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 16),
          _pdfHeading('3. Analysed Variables'),
          if (results.isEmpty)
            pw.Text('No completed responses are available.')
          else
            ...results.map((result) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(result.questionText,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(result.mean == null
                          ? 'Responses: ${result.count} • ${result.frequencies.entries.take(8).map((e) => '${e.key}: ${e.value}').join(' • ')}'
                          : 'n=${result.count} • Mean=${result.mean?.toStringAsFixed(2)} • Median=${result.median?.toStringAsFixed(2)} • SD=${result.stdDev?.toStringAsFixed(2)} • Range=${result.min?.toStringAsFixed(2)}–${result.max?.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
          pw.SizedBox(height: 16),
          _pdfHeading('4. Ethics & Data Governance'),
          pw.Text(
            'Participant information is access-controlled and synchronized under project ownership and supervisor permissions. Researchers remain responsible for institutional ethics approval, informed consent, and applicable data-protection requirements.',
          ),
        ],
      ),
    );
    return document.save();
  }

  static pw.Widget _pdfHeading(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(text,
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
      );

  static String toCSV(
    List<QuestionnaireResponse> responses,
    List<Question> questions, {
    Map<String, String> participantNames = const {},
  }) {
    final rows = <List<dynamic>>[];

    // Headers
    final headers = <dynamic>[
      'Response_ID',
      'Participant_ID',
      if (participantNames.isNotEmpty) 'Participant_Name',
      'Collected_At',
      'Latitude',
      'Longitude',
    ];
    for (final q in questions) {
      headers.add(q.text.replaceAll('\n', ' '));
    }
    rows.add(headers);

    // Rows
    for (final r in responses) {
      final row = <dynamic>[
        r.id,
        r.participantId,
        if (participantNames.isNotEmpty)
          participantNames[r.participantId] ?? '',
        r.collectedAt.toIso8601String(),
        r.latitude ?? '',
        r.longitude ?? '',
      ];
      for (final q in questions) {
        final answer = r.responses[q.id];
        if (answer is List) {
          row.add(answer.join(', '));
        } else {
          row.add(answer ?? '');
        }
      }
      rows.add(row);
    }

    return csv.encode(rows);
  }

  static List<int>? toExcel(
    List<QuestionnaireResponse> responses,
    List<Question> questions,
    String sheetTitle, {
    Map<String, String> participantNames = const {},
  }) {
    final excel = Excel.createExcel();
    final sheetName = sheetTitle.replaceAll(RegExp(r'[\\/*?:\[\]]'), '_');
    final sheet =
        excel[sheetName.length > 30 ? sheetName.substring(0, 30) : sheetName];

    // Header styling
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.blue400,
      fontColorHex: ExcelColor.white,
    );

    // Headers
    final headers = [
      'Response ID',
      'Participant ID',
      if (participantNames.isNotEmpty) 'Participant Name',
      'Date & Time',
      'Latitude',
      'Longitude',
      ...questions.map((q) => q.text),
    ];

    for (var col = 0; col < headers.length; col++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = headerStyle;
    }

    // Rows
    for (var rowIdx = 0; rowIdx < responses.length; rowIdx++) {
      final r = responses[rowIdx];
      final rowData = <String>[
        r.id,
        r.participantId,
        if (participantNames.isNotEmpty)
          participantNames[r.participantId] ?? '',
        r.collectedAt.toIso8601String(),
        r.latitude?.toString() ?? '',
        r.longitude?.toString() ?? '',
      ];
      for (final q in questions) {
        final val = r.responses[q.id];
        rowData.add(val is List ? val.join(', ') : (val?.toString() ?? ''));
      }

      for (var col = 0; col < rowData.length; col++) {
        final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIdx + 1));
        cell.value = TextCellValue(rowData[col]);
      }
    }

    // Remove default sheet if present
    if (excel.sheets.containsKey('Sheet1') && sheetName != 'Sheet1') {
      excel.delete('Sheet1');
    }

    return excel.encode();
  }

  static Future<void> exportFile(
    String filename,
    List<int> bytes, {
    required String mimeType,
    required String subject,
  }) =>
      platform.exportFile(filename, bytes, mimeType, subject);
}
