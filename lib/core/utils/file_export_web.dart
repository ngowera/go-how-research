// ignore_for_file: deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

Future<void> exportFile(
  String filename,
  List<int> bytes,
  String mimeType,
  String subject,
) async {
  final blob = html.Blob([Uint8List.fromList(bytes)], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = filename
    ..click();
  html.Url.revokeObjectUrl(url);
}
