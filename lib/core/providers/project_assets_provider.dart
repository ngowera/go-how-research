import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_provider.dart';

final projectAssetsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, projectId) async {
  ref.watch(currentUserProvider.select((user) => user?.id));
  final client = Supabase.instance.client;
  if (client.auth.currentSession == null) return const [];
  return (await client
          .from('project_assets')
          .select()
          .eq('project_id', projectId)
          .eq('status', 'ready')
          .order('captured_at', ascending: false))
      .cast<Map<String, dynamic>>();
});
