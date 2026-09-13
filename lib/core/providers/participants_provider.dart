import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'app_settings_provider.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart' show AppDatabase, databaseProvider;
import '../models/app_models.dart';
import 'sync_provider.dart';

class ParticipantsState {
  final List<Participant> participants;
  final bool isLoading;
  final String? error;

  const ParticipantsState({
    this.participants = const [],
    this.isLoading = false,
    this.error,
  });

  ParticipantsState copyWith({
    List<Participant>? participants,
    bool? isLoading,
    String? error,
  }) {
    return ParticipantsState(
      participants: participants ?? this.participants,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ParticipantsNotifier extends StateNotifier<ParticipantsState> {
  final AppDatabase _db;
  final Ref _ref;
  static const _uuid = Uuid();

  ParticipantsNotifier(this._db, this._ref) : super(const ParticipantsState()) {
    loadParticipants();
    _ref.listen<DateTime?>(
      syncProvider.select((sync) => sync.lastSyncTime),
      (previous, next) {
        if (next != null && next != previous) loadParticipants();
      },
    );
  }

  Future<void> loadParticipants({String? projectId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _db.getParticipants(projectId: projectId);
      state = state.copyWith(participants: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addParticipant({
    required String projectId,
    required String code,
    required String name,
    String? phone,
    String? email,
    bool hasConsented = false,
    DateTime? consentDate,
    String? notes,
  }) async {
    try {
      final participant = Participant(
        id: _uuid.v4(),
        projectId: projectId,
        code: code,
        name: name,
        phone: phone,
        email: email,
        hasConsented: hasConsented,
        consentDate: consentDate ?? (hasConsented ? DateTime.now() : null),
        notes: notes,
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );
      await _db.insertParticipant(participant);
      await loadParticipants(projectId: projectId);
      _ref.read(syncProvider.notifier).refreshPendingCount();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateParticipant(Participant participant) async {
    try {
      final updated = participant.copyWith(syncStatus: SyncStatus.pending);
      await _db.updateParticipant(updated);
      await loadParticipants(projectId: participant.projectId);
      _ref.read(syncProvider.notifier).refreshPendingCount();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteParticipant(String id, {String? projectId}) async {
    try {
      await _db.deleteParticipant(id);
      await loadParticipants(projectId: projectId);
      _ref.read(syncProvider.notifier).refreshPendingCount();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<String> generateParticipantCode(String projectId) async {
    final list = await _db.getParticipants(projectId: projectId);
    final prefix = _ref.read(appSettingsProvider).participantPrefix;
    final codes = list.map((p) => p.code).toSet();
    var count = 1;
    while (codes.contains('$prefix${count.toString().padLeft(3, '0')}')) {
      count++;
    }
    return '$prefix${count.toString().padLeft(3, '0')}';
  }
}

final participantsProvider =
    StateNotifierProvider<ParticipantsNotifier, ParticipantsState>((ref) {
  ref.watch(currentUserProvider.select((user) => user?.id));
  final db = ref.watch(databaseProvider);
  return ParticipantsNotifier(db, ref);
});

final participantsByProjectProvider =
    Provider.family<List<Participant>, String>((ref, projectId) {
  final all = ref.watch(participantsProvider).participants;
  return all.where((p) => p.projectId == projectId).toList();
});
