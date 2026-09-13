import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/models/app_models.dart';
import '../../../core/utils/export_utils.dart';
import '../../../core/utils/prepared_dataset.dart';

class ExportDialog extends StatefulWidget {
  final List<Question> questions;
  final List<QuestionnaireResponse> responses;
  const ExportDialog(
      {super.key, required this.questions, required this.responses});
  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  late final Set<String> selected = widget.questions.map((q) => q.id).toSet();
  bool includeCodes = false, completeOnly = false, busy = false;
  String format = 'Excel', filter = '';
  String? error;
  @override
  Widget build(BuildContext context) {
    final questions =
        widget.questions.where((q) => selected.contains(q.id)).toList();
    final responses = widget.responses
        .where((r) =>
            r.participantId.toLowerCase().contains(filter.toLowerCase()) &&
            (!completeOnly ||
                widget.questions.where((q) => q.isRequired).every((q) =>
                    r.responses[q.id] != null &&
                    r.responses[q.id].toString().isNotEmpty)))
        .toList();
    final dataset =
        PreparedDataset.build(questions, responses, includeCodes: includeCodes);
    return AlertDialog(
      title: const Text('Prepare data for Excel or SPSS'),
      content: SizedBox(
          width: 650,
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text(
                    'One row per response. Categories are coded, multiple selections and matrix rows become separate columns. Excel includes a codebook and validation notes.'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                    initialValue: format,
                    decoration: const InputDecoration(labelText: 'File format'),
                    items: ['Excel', 'SPSS (.sav)', 'CSV']
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged:
                        busy ? null : (f) => setState(() => format = f!)),
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Include participant codes'),
                    subtitle: const Text(
                        'Names and contact details are excluded. Deselect identifying questions below before sharing.'),
                    value: includeCodes,
                    onChanged:
                        busy ? null : (v) => setState(() => includeCodes = v!)),
                CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                        'Only records answering every required question'),
                    subtitle:
                        const Text('May exclude legitimate skipped questions.'),
                    value: completeOnly,
                    onChanged:
                        busy ? null : (v) => setState(() => completeOnly = v!)),
                TextField(
                    decoration: const InputDecoration(
                        labelText: 'Filter participant code (optional)'),
                    onChanged: (v) => setState(() => filter = v)),
                const SizedBox(height: 12),
                Text(
                    '${responses.length} of ${widget.responses.length} records • ${dataset.variables.length} export columns'),
                const Text('Select questions to export',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...widget.questions.map((q) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(q.text),
                    value: selected.contains(q.id),
                    onChanged: busy
                        ? null
                        : (v) => setState(() =>
                            v! ? selected.add(q.id) : selected.remove(q.id)))),
                if (dataset.warnings.isNotEmpty) ...[
                  Text('${dataset.warnings.length} validation notes',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  ...dataset.warnings.take(8).map((w) => Text(w)),
                  const Text(
                      'Invalid values are exported as missing; originals remain unchanged. Full notes are included in Excel.'),
                ],
                if (error != null)
                  Text(error!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
              ]))),
      actions: [
        TextButton(
            onPressed: busy ? null : () => Navigator.pop(context),
            child: const Text('Close')),
        FilledButton(
            onPressed: busy || responses.isEmpty || questions.isEmpty
                ? null
                : () async {
                    setState(() {
                      busy = true;
                      error = null;
                    });
                    try {
                      final bytes = format == 'Excel'
                          ? dataset.excelBytes()
                          : format == 'CSV'
                              ? utf8.encode(dataset.csvData())
                              : dataset.savBytes();
                      final ext = format == 'Excel'
                          ? 'xlsx'
                          : format == 'CSV'
                              ? 'csv'
                              : 'sav';
                      await ExportUtils.exportFile(
                          'research_prepared.$ext', bytes,
                          mimeType: format == 'Excel'
                              ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                              : format == 'CSV'
                                  ? 'text/csv'
                                  : 'application/octet-stream',
                          subject: 'Prepared research dataset');
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Prepared dataset exported. Use Excel export for the matching codebook.')));
                    } catch (e) {
                      if (mounted) setState(() => error = e.toString());
                    } finally {
                      if (mounted) setState(() => busy = false);
                    }
                  },
            child: Text(busy ? 'Preparing…' : 'Export'))
      ],
    );
  }
}
