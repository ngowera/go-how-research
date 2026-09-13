import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<void> exportFile(
  String filename,
  List<int> bytes,
  String mimeType,
  String subject,
) async {
  final saved = await FilePicker.saveFile(
      fileName: filename,
      bytes: Uint8List.fromList(bytes),
      mimeType: mimeType,
      dialogTitle: subject);
  if (saved == null) throw StateError('Export cancelled; no file was saved.');
}
