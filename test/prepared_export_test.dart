import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:excel/excel.dart';
import 'package:gohow_research/core/models/app_models.dart';
import 'package:gohow_research/core/utils/prepared_dataset.dart';
import 'package:gohow_research/core/utils/interview_audio.dart';

void main() {
  Question question(String id, QuestionType type,
          {List<String> options = const [],
          List<String> rows = const [],
          List<String> columns = const []}) =>
      Question(
          id: id,
          questionnaireId: 'survey',
          order: 0,
          type: type,
          text: id,
          isRequired: false,
          options: options,
          rows: rows,
          columns: columns);
  final questions = [
    question('Age', QuestionType.number),
    question('Sex', QuestionType.singleChoice, options: ['Female', 'Male']),
    question('Problems', QuestionType.multipleChoice,
        options: ['Waiting', 'Privacy']),
    question('Ratings', QuestionType.matrix,
        rows: ['Staff', 'Equipment'], columns: ['Poor', 'Good']),
    question('Comment', QuestionType.text)
  ];
  final responses = [
    QuestionnaireResponse(
        id: 'r1',
        questionnaireId: 'survey',
        participantId: 'P-001',
        responses: const {
          'Age': 22.5,
          'Sex': 'Female',
          'Problems': ['Privacy'],
          'Ratings': {'Staff': 'Good', 'Equipment': 'Poor'},
          'Comment': 'Mwayi — café'
        },
        collectedAt: DateTime.utc(2026, 9, 13),
        syncStatus: SyncStatus.pending),
    QuestionnaireResponse(
        id: 'r2',
        questionnaireId: 'survey',
        participantId: 'P-002',
        responses: const {
          'Age': 'invalid',
          'Sex': 'Male',
          'Problems': [],
          'Ratings': {'Staff': 'Poor'},
          'Comment': '=SUM(A1:A2)'
        },
        collectedAt: DateTime.utc(2026, 9, 13),
        syncStatus: SyncStatus.pending),
  ];
  test(
      'prepared exports preserve types, binary selections, matrix coding and missing values',
      () {
    final dataset = PreparedDataset.build(questions, responses);
    expect(dataset.variables.length, 10);
    expect(dataset.rows.first.sublist(3),
        [22.5, 1, 0.0, 1.0, 2, 1, 'Mwayi — café']);
    expect(dataset.rows.last[3], isNull);
    expect(dataset.rows.last[8], isNull);
    expect(dataset.warnings, isNotEmpty);
    expect(dataset.csvData(), contains("'=SUM"));
    final book = Excel.decodeBytes(dataset.excelBytes());
    expect(
        book.tables.keys, containsAll(['Dataset', 'Codebook', 'Export notes']));
    expect(
        book['Dataset']
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1))
            .value,
        isA<DoubleCellValue>());
    expect(
        PreparedDataset.build(questions, responses, includeCodes: false)
            .variables
            .any((v) => v.name == 'part_id'),
        isFalse);
  });
  test('SPSS fixture for independent reader verification', () {
    final dataset = PreparedDataset.build(questions, responses);
    final bytes = dataset.savBytes();
    expect(String.fromCharCodes(bytes.take(4)), r'$FL2');
    final directory = Directory('/tmp/gohow-export-fixtures')
      ..createSync(recursive: true);
    File('${directory.path}/prepared.sav').writeAsBytesSync(bytes);
    File('${directory.path}/prepared.xlsx')
        .writeAsBytesSync(dataset.excelBytes());
  });
  test('WAV checkpoints contain a valid PCM header and original samples', () {
    final pcm = Uint8List.fromList([0, 0, 255, 127, 0, 128]);
    final bytes = interviewWav(pcm),
        header = ByteData.sublistView(interviewWav(pcm));
    expect(String.fromCharCodes(bytes.take(4)), 'RIFF');
    expect(header.getUint32(24, Endian.little), 16000);
    expect(header.getUint32(40, Endian.little), pcm.length);
    expect(bytes.sublist(44), pcm);
  });
}
