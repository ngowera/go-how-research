import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/interviews_provider.dart';
import '../../core/providers/participants_provider.dart';
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
  final title = TextEditingController();
  final audio = BytesBuilder(copy: false);
  String? projectId, participantId, message, playingId;
  bool consent = false, recording = false, busy = false, stopping = false;
  int seconds = 0;
  Map<String, dynamic>? metadata;
  final Set<String> deletingIds = <String>{};
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
        title: const Text('Transcribe with Gemini?'),
        content: const Text(
          'This sends the interview audio to Google Gemini. Confirm that your study permissions and participant consent cover this use. The transcript will be a draft for you to check against the recording.',
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
            : 'Deploy transcribe-interview and add the Gemini server secret.',
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
              'Qualitative interviews',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Record an interview, keep it with the participant, and read it later on any signed-in device.',
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
                      decoration: const InputDecoration(labelText: 'Project'),
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
