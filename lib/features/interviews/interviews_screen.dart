import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/interviews_provider.dart';
import '../../core/providers/participants_provider.dart';
import '../../core/providers/project_assets_provider.dart';
import '../../core/providers/projects_provider.dart';
import '../../core/providers/sync_provider.dart';
import '../../core/utils/export_utils.dart';
import '../../core/utils/interview_audio.dart';

class InterviewsScreen extends ConsumerStatefulWidget {
  const InterviewsScreen({super.key});
  @override
  ConsumerState<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends ConsumerState<InterviewsScreen> {
  final recorder = AudioRecorder(), player = AudioPlayer();
  final imagePicker = ImagePicker();
  final title = TextEditingController();
  final audio = BytesBuilder(copy: false);
  String? projectId, participantId, message, playingId;
  bool consent = false, recording = false, busy = false, stopping = false;
  int seconds = 0;
  Map<String, dynamic>? metadata;
  final Set<String> deletingIds = <String>{};
  final Set<String> deletingAssetIds = <String>{};
  final Map<String, Future<Uint8List>> imagePreviews = {};
  final Set<String> deletedIds = <String>{};
  Timer? timer;
  StreamSubscription<Uint8List>? subscription;
  Future<void> writes = Future.value();
  @override
  void dispose() {
    timer?.cancel();
    subscription?.cancel();
    recorder.dispose();
    player.dispose();
    title.dispose();
    super.dispose();
  }

  void notice(String value) {
    if (mounted) setState(() => message = value);
  }

  Map<String, dynamic> newMetadata(String mime, int size) {
    final uid = ref.read(currentUserProvider)!.id, id = const Uuid().v4();
    return {
      'id': id,
      'owner_id': uid,
      'project_id': projectId,
      'participant_id': participantId,
      'title': title.text.trim().isEmpty
          ? 'Interview ${DateTime.now().toIso8601String().split('T').first}'
          : title.text.trim(),
      'storage_path': '$uid/$projectId/$id/audio',
      'mime_type': mime,
      'byte_size': size,
      'recording_consent': true,
      'recorded_at': DateTime.now().toUtc().toIso8601String(),
      'status': 'uploading',
    };
  }

  Future<void> save(Uint8List bytes, Map<String, dynamic> data, bool ready) {
    final db = ref.read(databaseProvider);
    writes = writes.catchError((_) {}).then((_) async {
      await db.into(db.interviewDrafts).insertOnConflictUpdate(
            InterviewDraftsCompanion.insert(
              id: data['id'],
              ownerId: data['owner_id'],
              metadata: jsonEncode({...data, 'byte_size': bytes.length}),
              audio: bytes,
              ready: Value(ready),
            ),
          );
    });
    return writes;
  }

  Future<void> start() async {
    setState(() => busy = true);
    try {
      if (!await recorder.hasPermission())
        throw StateError(
          'Microphone permission was denied. Allow it in your browser or device settings.',
        );
      audio.clear();
      seconds = 0;
      metadata = newMetadata('audio/wav', 44);
      final stream = await recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      subscription = stream.listen(
        (chunk) {
          if (audio.length + chunk.length + 44 > 18000000) {
            if (!stopping) stop();
            return;
          }
          audio.add(chunk);
        },
        onError: (Object e) {
          notice('Microphone interrupted: $e');
          stop();
        },
        onDone: () {
          if (recording && !stopping) stop();
        },
      );
      setState(() => recording = true);
      ref.read(interviewRecordingProvider.notifier).state = true;
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (mounted) setState(() => seconds++);
        if (t.tick % 10 == 0 && audio.length > 0)
          save(interviewWav(audio.toBytes()), metadata!, false).catchError((
            Object e,
          ) {
            notice('Local checkpoint failed. Stop and save a backup: $e');
          });
      });
    } catch (e) {
      notice(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> stop() async {
    if (stopping) return;
    stopping = true;
    timer?.cancel();
    try {
      await recorder.stop();
      await subscription?.cancel();
      if (audio.length > 0) {
        await save(interviewWav(audio.toBytes()), metadata!, true);
        notice('Recording saved locally. It will upload during sync.');
      }
      if (mounted) {
        setState(() => recording = false);
        await sync();
      }
    } catch (e) {
      notice(
        'Could not finish saving. Audio is still in memory; use Save backup. $e',
      );
    } finally {
      stopping = false;
      if (mounted) ref.read(interviewRecordingProvider.notifier).state = false;
      if (mounted) setState(() => recording = false);
    }
  }

  Future<void> sync() async {
    await ref.read(syncProvider.notifier).syncAll();
    if (mounted) ref.invalidate(interviewsProvider);
  }

  bool get _supportsDirectCapture =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  String _extensionFor(String name) {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }

  String? _mimeForExtension(String extension) => {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'webp': 'image/webp',
        'mp4': 'video/mp4',
        'mov': 'video/quicktime',
        'pdf': 'application/pdf',
        'doc': 'application/msword',
        'docx':
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'xls': 'application/vnd.ms-excel',
        'xlsx':
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      }[extension];

  Future<String?> _captureComment(String heading) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(heading),
        content: TextField(
          controller: controller,
          maxLength: 1000,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Comment or field note (optional)',
            hintText:
                'Describe what this evidence shows and where it was captured.',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Continue')),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<bool> _withinFreeStorage(int incomingBytes) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) throw StateError('Sign in to store project evidence.');
    final existing = await Supabase.instance.client
        .from('project_assets')
        .select('byte_size')
        .eq('owner_id', uid)
        .neq('status', 'uploading');
    final used = existing.fold<int>(
        0, (sum, row) => sum + ((row['byte_size'] as num?)?.toInt() ?? 0));
    const limit = 10 * 1024 * 1024;
    if (used + incomingBytes > limit) {
      notice(
          'Your free 10 MB Data Capture storage is full. Remove unneeded assets or upgrade your storage plan.');
      return false;
    }
    return true;
  }

  Future<void> _uploadAsset({
    required Uint8List bytes,
    required String fileName,
    required String assetType,
    required String comment,
  }) async {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null || projectId == null) {
      throw StateError('Select a project before capturing data.');
    }
    if (bytes.isEmpty) throw StateError('The selected file is empty.');
    if (!await _withinFreeStorage(bytes.length)) return;
    final extension = _extensionFor(fileName);
    final mime = _mimeForExtension(extension);
    if (mime == null) throw StateError('This file type is not supported.');
    final id = const Uuid().v4();
    final timestamp = DateTime.now().toUtc();
    final path = '$uid/$projectId/$id.$extension';
    final row = {
      'id': id,
      'project_id': projectId,
      'owner_id': uid,
      'asset_type': assetType,
      'title': fileName,
      'comment': comment.isEmpty ? null : comment,
      'storage_path': path,
      'mime_type': mime,
      'byte_size': bytes.length,
      'captured_at': timestamp.toIso8601String(),
      'status': 'uploading',
    };
    setState(() => busy = true);
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentSession == null) {
        throw StateError('Sign in online to upload project evidence.');
      }
      await client.from('project_assets').insert(row);
      await client.storage.from('project-assets').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: mime, upsert: false),
          );
      await client
          .from('project_assets')
          .update({'status': 'ready'})
          .eq('id', id)
          .eq('owner_id', uid);
      ref.invalidate(projectAssetsProvider(projectId!));
      notice(
          '${assetType[0].toUpperCase()}${assetType.substring(1)} saved with a ${timestamp.toLocal()} timestamp.');
    } catch (e) {
      try {
        await Supabase.instance.client
            .from('project_assets')
            .delete()
            .eq('id', id);
      } catch (_) {}
      rethrow;
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      final file =
          await imagePicker.pickImage(source: source, imageQuality: 88);
      if (file == null) return;
      final comment = await _captureComment('Add a note to this image');
      if (comment == null) return;
      await _uploadAsset(
        bytes: await file.readAsBytes(),
        fileName: file.name.isEmpty
            ? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg'
            : file.name,
        assetType: 'image',
        comment: comment,
      );
    } catch (e) {
      notice('Image was not saved: $e');
    }
  }

  Future<void> _captureVideo(ImageSource source) async {
    try {
      final file = await imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 7),
      );
      if (file == null) return;
      final comment =
          await _captureComment('Add a note to this 7-second video');
      if (comment == null) return;
      await _uploadAsset(
        bytes: await file.readAsBytes(),
        fileName: file.name.isEmpty
            ? 'video_${DateTime.now().millisecondsSinceEpoch}.mp4'
            : file.name,
        assetType: 'video',
        comment: comment,
      );
    } catch (e) {
      notice('Video was not saved: $e');
    }
  }

  Future<void> _importDocument() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
        withData: true,
      );
      if (result.isEmpty) return;
      final file = result.single;
      final bytes = await file.readAsBytes();
      final comment = await _captureComment('Add a note to this document');
      if (comment == null) return;
      await _uploadAsset(
        bytes: bytes,
        fileName: file.name,
        assetType: 'document',
        comment: comment,
      );
    } catch (e) {
      notice('Document was not saved: $e');
    }
  }

  Future<void> _deleteAsset(Map<String, dynamic> asset) async {
    final approved = await confirmDelete(asset['title']?.toString() ?? 'asset',
        uploaded: true);
    if (!approved || !mounted) return;
    final id = asset['id'].toString();
    setState(() => deletingAssetIds.add(id));
    try {
      final client = Supabase.instance.client;
      await client.storage
          .from('project-assets')
          .remove([asset['storage_path'].toString()]);
      await client.from('project_assets').delete().eq('id', id);
      ref.invalidate(projectAssetsProvider(projectId!));
      notice('Project asset deleted.');
    } catch (e) {
      notice('Could not delete the project asset: $e');
    } finally {
      if (mounted) setState(() => deletingAssetIds.remove(id));
    }
  }

  Widget _buildAssetCaptureCard() {
    final projectSelected = projectId != null && !busy && !recording;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Icon(Icons.perm_media_outlined),
                Text('Photos, video & documents',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Every item is assigned to the selected project, has a capture timestamp and can include a field note. Free student storage is limited to 10 MB.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (_supportsDirectCapture)
                  FilledButton.icon(
                    onPressed: projectSelected
                        ? () => _captureImage(ImageSource.camera)
                        : null,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Take photo'),
                  ),
                OutlinedButton.icon(
                  onPressed: projectSelected
                      ? () => _captureImage(ImageSource.gallery)
                      : null,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Import image'),
                ),
                if (_supportsDirectCapture)
                  FilledButton.icon(
                    onPressed: projectSelected
                        ? () => _captureVideo(ImageSource.camera)
                        : null,
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text('Record 7-sec video'),
                  ),
                OutlinedButton.icon(
                  onPressed: projectSelected
                      ? () => _captureVideo(ImageSource.gallery)
                      : null,
                  icon: const Icon(Icons.video_library_outlined),
                  label: const Text('Import video'),
                ),
                OutlinedButton.icon(
                  onPressed: projectSelected ? _importDocument : null,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Upload PDF, Word or Excel'),
                ),
              ],
            ),
            if (projectId == null) ...[
              const SizedBox(height: 8),
              const Text(
                  'Select a project above to capture or upload evidence.',
                  style: TextStyle(color: Colors.orange)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssetLibrary() {
    final assets = ref.watch(projectAssetsProvider(projectId!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Project data library',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              tooltip: 'Refresh project assets',
              onPressed: () =>
                  ref.invalidate(projectAssetsProvider(projectId!)),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        assets.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => Text(
            'Could not load project assets. Run project_assets_setup.sql and sign in online. $error',
          ),
          data: (rows) {
            if (rows.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                    'No photos, videos or documents have been saved for this project yet.'),
              );
            }
            return Column(
              children: rows.map(_buildAssetTile).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssetTile(Map<String, dynamic> asset) {
    final type = asset['asset_type']?.toString() ?? 'document';
    final id = asset['id'].toString();
    final captured =
        DateTime.tryParse(asset['captured_at']?.toString() ?? '')?.toLocal();
    final icon = switch (type) {
      'image' => Icons.image_outlined,
      'video' => Icons.videocam_outlined,
      _ => Icons.description_outlined,
    };
    return Card(
      child: ListTile(
        leading: type == 'image'
            ? _buildTimestampedImagePreview(asset, captured)
            : Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(width: 58, height: 58, child: Icon(icon, size: 34)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    color: Colors.black87,
                    child: const Text('TIMESTAMPED',
                        style: TextStyle(color: Colors.white, fontSize: 7)),
                  ),
                ],
              ),
        title: Text(asset['title']?.toString() ?? 'Project asset'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${type.toUpperCase()} • ${((asset['byte_size'] as num?)?.toInt() ?? 0) ~/ 1024} KB'),
            Text('Timestamp: ${captured?.toString() ?? 'Unavailable'}'),
            if (asset['comment']?.toString().isNotEmpty == true)
              Text('Note: ${asset['comment']}'),
          ],
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 2,
          children: [
            IconButton(
              tooltip: 'Download asset',
              icon: const Icon(Icons.download_outlined),
              onPressed: () async {
                try {
                  final bytes = await Supabase.instance.client.storage
                      .from('project-assets')
                      .download(asset['storage_path'].toString());
                  await ExportUtils.exportFile(
                    asset['title'].toString(),
                    bytes,
                    mimeType: asset['mime_type'].toString(),
                    subject: 'Project data capture asset',
                  );
                } catch (e) {
                  notice('Could not download asset: $e');
                }
              },
            ),
            IconButton(
              tooltip: 'Delete asset',
              color: Colors.red.shade700,
              onPressed: deletingAssetIds.contains(id)
                  ? null
                  : () => _deleteAsset(asset),
              icon: deletingAssetIds.contains(id)
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampedImagePreview(
      Map<String, dynamic> asset, DateTime? captured) {
    final id = asset['id'].toString();
    final preview = imagePreviews.putIfAbsent(
      id,
      () => Supabase.instance.client.storage
          .from('project-assets')
          .download(asset['storage_path'].toString()),
    );
    return FutureBuilder<Uint8List>(
      future: preview,
      builder: (context, snapshot) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: snapshot.hasData
                  ? Image.memory(snapshot.data!, fit: BoxFit.cover)
                  : const ColoredBox(
                      color: Color(0xFFE7EDF5),
                      child: Icon(Icons.image_outlined),
                    ),
            ),
            Container(
              width: 58,
              color: Colors.black87,
              padding: const EdgeInsets.all(2),
              child: Text(
                captured?.toString().substring(0, 16) ?? 'TIMESTAMPED',
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(color: Colors.white, fontSize: 6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> importAudio() async {
    setState(() => busy = true);
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'm4a', 'webm', 'ogg', 'flac'],
        withData: true,
      );
      if (result.isEmpty) return;
      final file = result.single;
      final bytes = await file.readAsBytes();
      if (bytes == null || bytes.isEmpty || bytes.length > 18000000)
        throw StateError(
          'Choose a non-empty audio file up to 18 MB. Split longer interviews into clips.',
        );
      final mime = {
        'wav': 'audio/wav',
        'mp3': 'audio/mpeg',
        'm4a': 'audio/mp4',
        'webm': 'audio/webm',
        'ogg': 'audio/ogg',
        'flac': 'audio/flac',
      }[file.extension?.toLowerCase()];
      if (mime == null) throw StateError('Unsupported audio format.');
      await save(bytes, newMetadata(mime, bytes.length), true);
      await sync();
      notice('Audio saved and queued for upload.');
    } catch (e) {
      notice(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> transcribe(Map<String, dynamic> row) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transcribe with Research Assistant?'),
        content: const Text(
          'This sends the interview audio to Research Assistant. Confirm that your study permissions and participant consent cover this use. The transcript will be a draft for you to check against the recording.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Transcribe'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    setState(() => busy = true);
    try {
      final result = await Supabase.instance.client.functions.invoke(
        'transcribe-interview',
        body: {'interviewId': row['id'], 'consent': true},
      );
      if (result.data is! Map || result.data['transcript'] == null)
        throw StateError('No transcript returned.');
      ref.invalidate(interviewsProvider);
      notice('Transcript saved. Review it against the audio.');
    } on FunctionException catch (e) {
      notice(
        e.details is Map
            ? e.details['error']?.toString() ?? 'Transcription failed.'
            : 'Research Assistant transcription is unavailable. Deploy transcribe-interview and configure its server secret.',
      );
    } catch (e) {
      notice(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> review(Map<String, dynamic> row) async {
    final editor = TextEditingController(text: row['transcript']);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review transcript'),
        content: SizedBox(
          width: 650,
          child: TextField(
            controller: editor,
            minLines: 8,
            maxLines: 18,
            decoration: const InputDecoration(
              helperText:
                  'Check the words and speaker labels against the original recording.',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await Supabase.instance.client.from('interviews').update({
                  'transcript': editor.text,
                  'transcript_reviewed': true,
                }).eq('id', row['id']);
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(interviewsProvider);
              } catch (e) {
                notice('Transcript could not be saved: $e');
              }
            },
            child: const Text('Save reviewed transcript'),
          ),
        ],
      ),
    );
    editor.dispose();
  }

  Future<bool> confirmDelete(String title, {required bool uploaded}) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete recording?'),
            content: Text(
              uploaded
                  ? '“$title” and its stored audio will be permanently deleted. This cannot be undone.'
                  : '“$title” will be permanently removed from this device. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete'),
              ),
            ],
          ),
        ) ==
        true;
  }

  Future<void> deleteDraft(InterviewDraft draft) async {
    final data = Map<String, dynamic>.from(jsonDecode(draft.metadata));
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null || draft.ownerId != userId) {
      notice('This recording does not belong to the signed-in account.');
      return;
    }
    if (!await confirmDelete(
      data['title']?.toString() ?? 'Interview',
      uploaded: false,
    )) return;
    try {
      final db = ref.read(databaseProvider);
      await (db.delete(db.interviewDrafts)
            ..where((row) => row.id.equals(draft.id))
            ..where((row) => row.ownerId.equals(userId)))
          .go();
      notice('Local recording deleted.');
    } catch (e) {
      notice('The local recording could not be deleted: $e');
    }
  }

  Future<void> deleteUploaded(Map<String, dynamic> row) async {
    final id = row['id']?.toString();
    final titleValue = row['title']?.toString() ?? 'Interview';
    final appUserId = ref.read(currentUserProvider)?.id;
    final authUserId = Supabase.instance.client.auth.currentUser?.id;
    if (id == null ||
        appUserId == null ||
        authUserId == null ||
        authUserId != appUserId) {
      notice('Sign in online with the recording owner account to delete it.');
      return;
    }
    if (!await confirmDelete(titleValue, uploaded: true) || !mounted) return;
    setState(() => deletingIds.add(id));
    var audioRemoved = false;
    try {
      final client = Supabase.instance.client;
      // Fetch through RLS and explicitly scope by owner before touching storage.
      final owned = await client
          .from('interviews')
          .select('id,storage_path,owner_id')
          .eq('id', id)
          .eq('owner_id', authUserId)
          .maybeSingle();
      if (owned == null) {
        throw StateError('Recording not found or you are not its owner.');
      }
      final storagePath = owned['storage_path']?.toString();
      if (storagePath == null ||
          !storagePath.startsWith('$authUserId/') ||
          storagePath != row['storage_path']) {
        throw StateError('The stored audio path failed its ownership check.');
      }
      if (playingId == id) {
        await player.stop();
        if (mounted) setState(() => playingId = null);
      }
      // Storage must be removed while the interview row still exists because
      // the storage DELETE policy verifies ownership through that row.
      await client.storage.from('interview-audio').remove([storagePath]);
      audioRemoved = true;
      final deleted = await client
          .from('interviews')
          .delete()
          .eq('id', id)
          .eq('owner_id', authUserId)
          .select('id');
      if (deleted.isEmpty) {
        throw StateError('The database record was not deleted.');
      }
      if (!mounted) return;
      setState(() => deletedIds.add(id));
      ref.invalidate(interviewsProvider);
      notice('Recording and stored audio deleted.');
    } catch (e) {
      notice(
        audioRemoved
            ? 'The audio was removed, but its database record still needs cleanup. Try delete again. $e'
            : 'Nothing was deleted. Check your connection and ownership, then try again. $e',
      );
    } finally {
      if (mounted) setState(() => deletingIds.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(syncProvider.select((s) => s.lastSyncTime), (previous, next) {
      if (next != null && previous != next) ref.invalidate(interviewsProvider);
    });
    final user = ref.watch(currentUserProvider);
    final projects = ref
        .watch(projectsProvider)
        .projects
        .where((p) => p.ownerId == user?.id)
        .toList();
    final participants = ref
        .watch(participantsProvider)
        .participants
        .where((p) => p.projectId == projectId)
        .toList();
    final remote = ref.watch(interviewsProvider);
    final db = ref.watch(databaseProvider);
    final ready = projectId != null &&
        participantId != null &&
        consent &&
        !busy &&
        !recording;
    return PopScope(
      canPop: !recording,
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 130),
          children: [
            const Text(
              'Data Capture',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Keep interviews, images, 7-second videos and documents safely with the research project they belong to.',
            ),
            if (message != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(message!),
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: projectId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Project for captured data',
                      ),
                      items: projects
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.title),
                            ),
                          )
                          .toList(),
                      onChanged: recording || busy
                          ? null
                          : (v) => setState(() {
                                projectId = v;
                                participantId = null;
                              }),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey(projectId),
                      initialValue: participantId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Interview participant',
                      ),
                      items: participants
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(
                                '${p.name.isEmpty ? 'Participant' : p.name} — ${p.code}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: recording || busy
                          ? null
                          : (v) => setState(() => participantId = v),
                    ),
                    if (participants.isEmpty)
                      TextButton(
                        onPressed: () => context.go('/participants'),
                        child: const Text('Register a participant first'),
                      ),
                    TextField(
                      controller: title,
                      enabled: !recording && !busy,
                      decoration: const InputDecoration(
                        labelText: 'Interview title / topic',
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'The participant agreed to audio recording and storage',
                      ),
                      value: consent,
                      onChanged: recording
                          ? null
                          : (v) => setState(() => consent = v!),
                    ),
                    const Text(
                      'Microphone clips: up to 9 minutes at 16 kHz mono. For longer interviews, save successive clips. Import audio up to 18 MB. Keep this screen open while recording. Local checkpoints save every 10 seconds.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: recording
                              ? stop
                              : ready
                                  ? start
                                  : null,
                          icon: Icon(recording ? Icons.stop : Icons.mic),
                          label: Text(
                            recording
                                ? 'Stop & save (${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')})'
                                : 'Start recording',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: ready ? importAudio : null,
                          icon: const Icon(Icons.audio_file),
                          label: const Text('Import audio'),
                        ),
                        OutlinedButton(
                          onPressed: audio.length == 0
                              ? null
                              : () async => ExportUtils.exportFile(
                                    'interview_backup.wav',
                                    interviewWav(audio.toBytes()),
                                    mimeType: 'audio/wav',
                                    subject: 'Interview recording backup',
                                  ),
                          child: const Text('Save backup'),
                        ),
                        TextButton(
                          onPressed: busy || recording ? null : sync,
                          child: const Text('Sync now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAssetCaptureCard(),
            if (projectId != null) ...[
              const SizedBox(height: 20),
              _buildAssetLibrary(),
            ],
            StreamBuilder<List<InterviewDraft>>(
              stream: (db.select(
                db.interviewDrafts,
              )..where((t) => t.ownerId.equals(user?.id ?? '')))
                  .watch(),
              builder: (context, snapshot) {
                final drafts = snapshot.data ?? [];
                return Column(
                  children: drafts.map((d) {
                    final meta = jsonDecode(d.metadata) as Map;
                    return Card(
                      child: ListTile(
                        title: Text(meta['title'] ?? 'Interview'),
                        subtitle: Text(
                          d.ready
                              ? 'Saved on this device • waiting to upload'
                              : 'Local recording checkpoint • not uploaded',
                        ),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              tooltip: 'Download local backup',
                              onPressed: () => ExportUtils.exportFile(
                                'interview_${d.id}.${meta['mime_type'] == 'audio/wav' ? 'wav' : 'audio'}',
                                d.audio,
                                mimeType: meta['mime_type'],
                                subject: 'Interview backup',
                              ),
                              icon: const Icon(Icons.download),
                            ),
                            if (!d.ready && !recording)
                              TextButton(
                                onPressed: () async {
                                  await (db.update(
                                    db.interviewDrafts,
                                  )..where((t) => t.id.equals(d.id)))
                                      .write(
                                    const InterviewDraftsCompanion(
                                      ready: Value(true),
                                    ),
                                  );
                                  await sync();
                                },
                                child: const Text('Recover & upload'),
                              ),
                            IconButton(
                              tooltip: 'Delete local recording',
                              onPressed: recording || busy
                                  ? null
                                  : () => deleteDraft(d),
                              color: Colors.red.shade700,
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Server recordings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh recordings',
                  onPressed: () => ref.invalidate(interviewsProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            remote.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text(
                'Could not load recordings. Sign in online and run interviews_setup.sql on the server. $e',
              ),
              data: (rows) {
                final visible = rows
                    .where(
                      (r) =>
                          !deletedIds.contains(r['id']) &&
                          (projectId == null || r['project_id'] == projectId),
                    )
                    .toList();
                if (visible.isEmpty)
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No uploaded interviews yet. Select a project and participant above to record or import your first interview.',
                    ),
                  );
                return Column(
                  children: visible.map((row) {
                    final participant = row['participants'] as Map?;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row['title'],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${participant?['name'] ?? 'Participant'} — ${participant?['code'] ?? ''} • ${row['recorded_at']}',
                            ),
                            Wrap(
                              spacing: 10,
                              children: [
                                TextButton.icon(
                                  icon: Icon(
                                    playingId == row['id']
                                        ? Icons.stop
                                        : Icons.play_arrow,
                                  ),
                                  label: Text(
                                    playingId == row['id']
                                        ? 'Stop'
                                        : 'Play recording',
                                  ),
                                  onPressed: () async {
                                    try {
                                      if (playingId == row['id']) {
                                        await player.stop();
                                        setState(() => playingId = null);
                                      } else {
                                        final signed = await Supabase
                                            .instance.client.storage
                                            .from('interview-audio')
                                            .createSignedUrl(
                                              row['storage_path'],
                                              3600,
                                            );
                                        await player.play(UrlSource(signed));
                                        setState(() => playingId = row['id']);
                                      }
                                    } catch (e) {
                                      notice('Playback failed: $e');
                                    }
                                  },
                                ),
                                TextButton(
                                  onPressed: busy
                                      ? null
                                      : () async {
                                          try {
                                            final bytes = await Supabase
                                                .instance.client.storage
                                                .from('interview-audio')
                                                .download(row['storage_path']);
                                            await ExportUtils.exportFile(
                                              'interview_${row['id']}.${row['mime_type'] == 'audio/wav' ? 'wav' : 'audio'}',
                                              bytes,
                                              mimeType: row['mime_type'],
                                              subject: row['title'],
                                            );
                                          } catch (e) {
                                            notice('Download failed: $e');
                                          }
                                        },
                                  child: const Text('Download audio'),
                                ),
                                if (row['transcript'] == null)
                                  FilledButton(
                                    onPressed:
                                        busy ? null : () => transcribe(row),
                                    child: Text(
                                      busy ? 'Working…' : 'Transcribe',
                                    ),
                                  ),
                                IconButton(
                                  tooltip: 'Delete recording and stored audio',
                                  color: Colors.red.shade700,
                                  onPressed: deletingIds.contains(row['id'])
                                      ? null
                                      : () => deleteUploaded(row),
                                  icon: deletingIds.contains(row['id'])
                                      ? const SizedBox.square(
                                          dimension: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                            if (row['transcript'] != null) ...[
                              Text(
                                row['transcript_reviewed'] == true
                                    ? 'Reviewed transcript'
                                    : 'AI draft — check against the recording',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ExpansionTile(
                                title: const Text('Read transcript'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SelectableText(row['transcript']),
                                  ),
                                ],
                              ),
                              Wrap(
                                children: [
                                  TextButton(
                                    onPressed: () => review(row),
                                    child: const Text('Edit & mark reviewed'),
                                  ),
                                  TextButton(
                                    onPressed: () => ExportUtils.exportFile(
                                      'transcript_${row['id']}.txt',
                                      utf8.encode(row['transcript']),
                                      mimeType: 'text/plain',
                                      subject: row['title'],
                                    ),
                                    child: const Text('Export transcript'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
