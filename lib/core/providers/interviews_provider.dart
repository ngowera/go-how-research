import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import 'auth_provider.dart';

final interviewRecordingProvider = StateProvider<bool>((ref) => false);

final interviewsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  ref.watch(currentUserProvider.select((user) => user?.id));
  final client = Supabase.instance.client;
  if (client.auth.currentSession == null) return [];
  return await client
      .from('interviews')
      .select('*, participants(name,code)')
      .neq('status', 'uploading')
      .order('recorded_at', ascending: false)
      .limit(500);
});

/// Runs after projects and participants sync. Local audio survives failed uploads.
Future<void> uploadInterviewDrafts(
    AppDatabase db, SupabaseClient client) async {
  final userId = client.auth.currentUser?.id;
  if (userId == null) return;
  final drafts = await (db.select(db.interviewDrafts)
        ..where((t) => t.ownerId.equals(userId) & t.ready.equals(true)))
      .get();
  for (final draft in drafts) {
    final metadata = Map<String, dynamic>.from(jsonDecode(draft.metadata));
    // Preserve an existing server transcript on retries after partial success.
    await client.from('interviews').upsert(metadata, ignoreDuplicates: true);
    await client.storage.from('interview-audio').uploadBinary(
        metadata['storage_path'], draft.audio,
        fileOptions:
            FileOptions(contentType: metadata['mime_type'], upsert: true));
    await client
        .from('interviews')
        .update({'status': 'uploaded'})
        .eq('id', draft.id)
        .eq('status', 'uploading');
    await (db.delete(db.interviewDrafts)..where((t) => t.id.equals(draft.id)))
        .go();
  }
}
