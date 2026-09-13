import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import '../models/app_models.dart';

class ExportVariable {
  final String name, label, questionId, measure;
  final bool numeric;
  final Map<int, String> codes;
  final dynamic Function(QuestionnaireResponse) read;
  ExportVariable(this.name, this.label, this.questionId, this.measure,
      this.numeric, this.codes, this.read);
}

/// A single transformation shared by Excel, CSV and SPSS. Raw records are never edited.
class PreparedDataset {
  final List<ExportVariable> variables;
  final List<List<dynamic>> rows;
  final List<String> warnings;
  PreparedDataset(this.variables, this.rows, this.warnings);

  factory PreparedDataset.build(
      List<Question> questions, List<QuestionnaireResponse> responses,
      {bool includeCodes = true}) {
    final vars = <ExportVariable>[
      ExportVariable('case_id', 'Export case number', '', 'nominal', true, {},
          (_) => null),
      if (includeCodes)
        ExportVariable('part_id', 'Participant identification code', '',
            'nominal', false, {}, (r) => r.participantId),
      ExportVariable('date', 'Collection date (ISO 8601)', '', 'nominal', false,
          {}, (r) => r.collectedAt.toIso8601String()),
    ];
    final warnings = <String>[];
    void add(Question q, String label, bool numeric, String measure,
        List<String> labels, dynamic Function(QuestionnaireResponse) read,
        {bool binary = false}) {
      final name = 'v${(vars.length + 1).toString().padLeft(6, '0')}';
      final codes = {for (var i = 0; i < labels.length; i++) i + 1: labels[i]};
      vars.add(ExportVariable(name, label, q.id, measure, numeric,
          binary ? {0: 'Not selected', 1: 'Selected'} : codes, (r) {
        final value = read(r);
        if (value == null || value.toString().trim().isEmpty) return null;
        if (codes.isNotEmpty) {
          final index = labels.indexWhere(
              (s) => s.toLowerCase() == value.toString().toLowerCase());
          if (index >= 0) return index + 1;
          warnings.add(
              '$name: unrecognised category in response ${r.id}; exported as missing.');
          return null;
        }
        if (!numeric) return value.toString();
        final number = double.tryParse(value.toString());
        if (number == null ||
            !number.isFinite ||
            (!binary && q.minValue != null && number < q.minValue!) ||
            (!binary && q.maxValue != null && number > q.maxValue!)) {
          warnings.add(
              '$name: invalid or out-of-range number in response ${r.id}; exported as missing.');
          return null;
        }
        return number;
      }));
    }

    for (final q in questions) {
      if (q.type == QuestionType.multipleChoice) {
        for (final option in q.options) {
          add(q, '${q.text} — $option (0=no, 1=yes)', true, 'nominal', [], (r) {
            final value = r.responses[q.id];
            return value is List ? (value.contains(option) ? 1 : 0) : null;
          }, binary: true);
        }
      } else if (q.type == QuestionType.matrix) {
        for (final row in q.rows) {
          add(q, '${q.text} — $row', true, 'ordinal', q.columns,
              (r) => r.responses[q.id] is Map ? r.responses[q.id][row] : null);
        }
      } else {
        final categorical =
            q.type == QuestionType.singleChoice || q.type == QuestionType.yesNo;
        final numeric = categorical ||
            [QuestionType.number, QuestionType.rating, QuestionType.likertScale]
                .contains(q.type);
        add(
            q,
            q.text,
            numeric,
            q.type == QuestionType.number
                ? 'scale'
                : [QuestionType.rating, QuestionType.likertScale]
                        .contains(q.type)
                    ? 'ordinal'
                    : 'nominal',
            q.type == QuestionType.yesNo
                ? ['NO', 'YES']
                : categorical
                    ? q.options
                    : [],
            (r) => r.responses[q.id]);
      }
    }
    final rows = <List<dynamic>>[];
    for (var i = 0; i < responses.length; i++) {
      rows.add([i + 1, ...vars.skip(1).map((v) => v.read(responses[i]))]);
    }
    for (var c = 1; c < vars.length; c++) {
      final missing = rows.where((r) => r[c] == null).length;
      if (missing > 0)
        warnings
            .add('${vars[c].name}: $missing missing of ${rows.length} cases.');
    }
    return PreparedDataset(vars, rows, warnings);
  }

  String csvData() => csv.encode([
        variables.map((v) => v.name).toList(),
        ...rows.map((r) => r
            .map((v) =>
                v is String && RegExp(r'^[=+@\-\t\r]').hasMatch(v) ? "'$v" : v)
            .toList()),
      ]);

  List<int> excelBytes() {
    final book = Excel.createExcel();
    void row(String sheet, List<dynamic> values) => book[sheet].appendRow(values
        .map<CellValue?>((v) => v == null
            ? null
            : v is num
                ? DoubleCellValue(v.toDouble())
                : TextCellValue(v.toString()))
        .toList());
    row('Dataset', variables.map((v) => v.name).toList());
    for (final data in rows) {
      row('Dataset', data);
    }
    row('Codebook', [
      'Variable',
      'Label',
      'Source question ID',
      'Type',
      'Measurement',
      'Value labels',
      'Missing'
    ]);
    for (final v in variables) {
      row('Codebook', [
        v.name,
        v.label,
        v.questionId,
        v.numeric ? 'Numeric' : 'String',
        v.measure,
        v.codes.entries.map((e) => '${e.key}=${e.value}').join('; '),
        'Blank / system missing'
      ]);
    }
    row('Export notes', ['Created', DateTime.now().toUtc().toIso8601String()]);
    row('Export notes', ['Cases', rows.length]);
    row('Export notes', [
      'Preparation',
      'Raw data preserved. Unknown and invalid values become system missing. Review warnings.'
    ]);
    for (final warning in warnings) {
      row('Export notes', [warning]);
    }
    book.delete('Sheet1');
    book.setDefaultSheet('Dataset');
    return book.encode()!;
  }

  /// Uncompressed SPSS system file (little endian, UTF-8 dictionary).
  /// Strings over 255 bytes are rejected rather than silently truncated.
  Uint8List savBytes() {
    final out = BytesBuilder();
    void i32(int n) {
      out.add(
          (ByteData(4)..setInt32(0, n, Endian.little)).buffer.asUint8List());
    }

    void f64(double n) {
      out.add(
          (ByteData(8)..setFloat64(0, n, Endian.little)).buffer.asUint8List());
    }

    void fixed(String s, int width) {
      final b = utf8.encode(s);
      if (b.length > width)
        throw FormatException(
            'Text exceeds SPSS field width ($width bytes). Export Excel for unrestricted text.');
      out.add(b);
      out.add(List.filled(width - b.length, 32));
    }

    final widths = List.generate(variables.length, (c) {
      if (variables[c].numeric) return 0;
      return rows.fold<int>(1, (max, r) {
        final length = utf8.encode(r[c]?.toString() ?? '').length;
        return length > max ? length : max;
      });
    });
    if (widths.any((w) => w > 255))
      throw const FormatException(
          'SPSS export supports text up to 255 UTF-8 bytes. Deselect long-text questions or use Excel.');
    final slots = widths.map((w) => w == 0 ? 1 : (w + 7) ~/ 8).toList();
    fixed(r'$FL2', 4);
    fixed('@(#) SPSS DATA FILE GoHow Research', 60);
    i32(2);
    i32(slots.fold(0, (a, b) => a + b));
    i32(0);
    i32(0);
    i32(rows.length);
    f64(100);
    fixed('12 SEP 26', 9);
    fixed('00:00:00', 8);
    fixed('GoHow Research prepared dataset', 64);
    out.add([0, 0, 0]);
    final indices = <int>[];
    var slot = 1;
    for (var c = 0; c < variables.length; c++) {
      final v = variables[c];
      indices.add(slot);
      slot += slots[c];
      final label = utf8.encode(v.label);
      if (label.length > 120)
        throw FormatException(
            'Shorten the label for ${v.name} to at most 120 UTF-8 bytes for SPSS, or export Excel.');
      i32(2);
      i32(widths[c]);
      i32(1);
      i32(0);
      final format =
          v.numeric ? (5 << 16) | (16 << 8) | 4 : (1 << 16) | (widths[c] << 8);
      i32(format);
      i32(format);
      fixed(v.name.toUpperCase(), 8);
      i32(label.length);
      out.add(label);
      out.add(List.filled((4 - label.length % 4) % 4, 0));
      for (var j = 1; j < slots[c]; j++) {
        i32(2);
        i32(-1);
        i32(0);
        i32(0);
        i32(0);
        i32(0);
        fixed('', 8);
      }
    }
    for (var c = 0; c < variables.length; c++) {
      final codes = variables[c].codes;
      if (codes.isEmpty) continue;
      i32(3);
      i32(codes.length);
      for (final e in codes.entries) {
        final label = utf8.encode(e.value);
        if (label.length > 255)
          throw const FormatException('SPSS category label exceeds 255 bytes.');
        f64(e.key.toDouble());
        out.add([label.length]);
        out.add(label);
        out.add(List.filled((8 - (label.length + 1) % 8) % 8, 32));
      }
      i32(4);
      i32(1);
      i32(indices[c]);
    }
    i32(7);
    i32(3);
    i32(4);
    i32(8);
    for (final n in [1, 0, 0, -1, 1, 1, 2, 65001]) {
      i32(n);
    }
    i32(7);
    i32(11);
    i32(4);
    i32(variables.length * 3);
    for (final v in variables) {
      i32(v.measure == 'scale'
          ? 3
          : v.measure == 'ordinal'
              ? 2
              : 1);
      i32(16);
      i32(v.numeric ? 1 : 0);
    }
    i32(7);
    i32(20);
    i32(1);
    i32(5);
    out.add(utf8.encode('UTF-8'));
    i32(999);
    i32(0);
    for (final row in rows) {
      for (var c = 0; c < variables.length; c++) {
        if (variables[c].numeric) {
          f64((row[c] as num?)?.toDouble() ?? -double.maxFinite);
        } else {
          fixed(row[c]?.toString() ?? '', slots[c] * 8);
        }
      }
    }
    return out.takeBytes();
  }
}
