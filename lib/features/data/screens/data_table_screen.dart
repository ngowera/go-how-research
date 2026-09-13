import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/app_models.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../core/providers/participants_provider.dart';
import '../../../core/providers/projects_provider.dart';
import '../../../core/providers/questionnaire_provider.dart';
import '../../../core/providers/responses_provider.dart';
import '../../../core/utils/export_utils.dart';
import 'export_dialog.dart';
import '../../../shared/theme/app_theme.dart';

class DataTableScreen extends ConsumerStatefulWidget {
  final String projectId;

  const DataTableScreen({super.key, required this.projectId});

  @override
  ConsumerState<DataTableScreen> createState() => _DataTableScreenState();
}

class _DataTableScreenState extends ConsumerState<DataTableScreen> {
  String? _selectedQuestionnaireId;

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectByIdProvider(widget.projectId));
    final questionnairesState = ref.watch(questionnairesProvider);
    final questionnaires = questionnairesState.questionnaires
        .where((q) => q.projectId == widget.projectId)
        .toList();

    if (questionnaires.isNotEmpty && _selectedQuestionnaireId == null) {
      _selectedQuestionnaireId = questionnaires.first.id;
    }

    final currentQId = _selectedQuestionnaireId ?? '';
    final responsesState =
        currentQId.isNotEmpty ? ref.watch(responsesProvider(currentQId)) : null;
    final questions = currentQId.isNotEmpty
        ? ref.watch(questionsByQuestionnaireProvider(currentQId))
        : <Question>[];

    final responses = responsesState?.responses ?? [];
    final settings = ref.watch(appSettingsProvider);
    final participantNames = {
      for (final participant in ref.watch(participantsProvider).participants)
        if (participant.projectId == widget.projectId &&
            participant.name.isNotEmpty)
          participant.code: participant.name,
    };
    final showNames =
        settings.participantIdentityMode == ParticipantIdentityMode.nameAndCode;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                    onPressed: responses.isEmpty
                        ? null
                        : () => showDialog(
                            context: context,
                            builder: (_) => ExportDialog(
                                questions: questions, responses: responses)),
                    icon: const Icon(Icons.import_export),
                    label: const Text('Prepare Excel / SPSS export'))),
            // Top Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () =>
                          context.go('/projects/${widget.projectId}'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project Dataset: ${project?.title ?? "Research Data"}',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '${responses.length} responses collected • Clean, inspect and export',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: responses.isEmpty
                          ? null
                          : () async {
                              final csvString = ExportUtils.toCSV(
                                  responses, questions,
                                  participantNames:
                                      showNames ? participantNames : const {});
                              await ExportUtils.exportFile(
                                'research_data_${widget.projectId}.csv',
                                csvString.codeUnits,
                                mimeType: 'text/csv',
                                subject: 'Exported Research Data (CSV)',
                              );
                            },
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: const Text('Export CSV'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: responses.isEmpty
                          ? null
                          : () async {
                              final bytes = ExportUtils.toExcel(
                                responses,
                                questions,
                                project?.title ?? 'Dataset',
                                participantNames:
                                    showNames ? participantNames : const {},
                              );
                              if (bytes != null) {
                                await ExportUtils.exportFile(
                                  'research_data_${widget.projectId}.xlsx',
                                  bytes,
                                  mimeType:
                                      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                  subject: 'Exported Research Data (Excel)',
                                );
                              }
                            },
                      icon: const Icon(Icons.table_view_rounded, size: 18),
                      label: const Text('Export Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.go('/analytics/${widget.projectId}'),
                      icon: const Icon(Icons.insights_rounded, size: 18),
                      label: const Text('Open Analytics'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.kPrimary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Questionnaire selector
            if (questionnaires.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Text('Select Instrument: ',
                        style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _selectedQuestionnaireId,
                      items: questionnaires.map((q) {
                        return DropdownMenuItem(
                          value: q.id,
                          child: Text(q.title),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setState(() => _selectedQuestionnaireId = v);
                      },
                    ),
                  ],
                ),
              ),

            // Data Table Content
            Expanded(
              child: responses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.table_rows_outlined,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No responses collected yet',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Collect data in the field or test the questionnaire to see records here.',
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 16),
                          if (currentQId.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.go('/data-collection/$currentQId'),
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text('Start Data Collection'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.kPrimary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                                const Color(0xFFF1F5F9)),
                            dataRowColor:
                                MaterialStateProperty.all(Colors.white),
                            columns: [
                              DataColumn(
                                  label: Text(
                                      showNames
                                          ? 'Participant name & code'
                                          : 'Participant ID',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700))),
                              const DataColumn(
                                  label: Text('Collected At',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700))),
                              ...questions.map((q) => DataColumn(
                                    label: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 180),
                                      child: Text(
                                        q.text,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  )),
                              const DataColumn(label: Text('Actions')),
                            ],
                            rows: responses.map((r) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(
                                      showNames &&
                                              participantNames[
                                                      r.participantId] !=
                                                  null
                                          ? '${participantNames[r.participantId]} — ${r.participantId}'
                                          : r.participantId,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600))),
                                  DataCell(Text(
                                    r.collectedAt
                                        .toIso8601String()
                                        .split('T')
                                        .first,
                                  )),
                                  ...questions.map((q) {
                                    final val = r.responses[q.id];
                                    final displayStr = val is List
                                        ? val.join(', ')
                                        : (val?.toString() ?? '-');
                                    return DataCell(
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 180),
                                        child: Text(
                                          displayStr,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  }),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.red,
                                          size: 18),
                                      onPressed: () {
                                        ref
                                            .read(responsesProvider(currentQId)
                                                .notifier)
                                            .deleteResponse(r.id);
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
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
}
