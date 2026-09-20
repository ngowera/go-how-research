import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart' show AppDatabase, databaseProvider;
import '../models/app_models.dart';
import 'app_settings_provider.dart';
import 'interviews_provider.dart';

enum SyncStateStatus { idle, syncing, success, error, offline }

class SyncState {
  final SyncStateStatus status;
  final String? message;
  final DateTime? lastSyncTime;
  final DateTime? lastAttemptTime;
  final int pendingCount;

  const SyncState({
    this.status = SyncStateStatus.idle,
    this.message,
    this.lastSyncTime,
    this.lastAttemptTime,
    this.pendingCount = 0,
  });

  SyncState copyWith({
    SyncStateStatus? status,
    String? message,
    DateTime? lastSyncTime,
    DateTime? lastAttemptTime,
    int? pendingCount,
  }) {
    return SyncState(
      status: status ?? this.status,
      message: message ?? this.message,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastAttemptTime: lastAttemptTime ?? this.lastAttemptTime,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final AppDatabase _db;
  final bool _automaticSyncEnabled;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicSyncTimer;

  SyncNotifier(this._db, this._automaticSyncEnabled)
      : super(const SyncState()) {
    _init();
  }

  void _init() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isOffline = results.contains(ConnectivityResult.none);
      if (isOffline) {
        state =
            state.copyWith(status: SyncStateStatus.offline, message: 'Offline');
      } else {
        if (state.status == SyncStateStatus.offline) {
          state = state.copyWith(
              status: SyncStateStatus.idle, message: 'Connected');
          if (_automaticSyncEnabled) syncAll();
        }
      }
    });
    refreshPendingCount();
    if (_automaticSyncEnabled) {
      _periodicSyncTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (state.status != SyncStateStatus.syncing &&
            state.status != SyncStateStatus.offline) {
          syncAll();
        }
      });
    }
  }

  Future<void> refreshPendingCount() async {
    try {
      final pProjects = await _db.getPendingProjects();
      final pQuestionnaires = await _db.getPendingQuestionnaires();
      final pResponses = await _db.getPendingResponses();
      final pParticipants = await _db.getPendingParticipants();
      final pDeletions = await _db.getPendingDeletions();
      final total = pProjects.length +
          pQuestionnaires.length +
          pResponses.length +
          pParticipants.length +
          pDeletions.length;
      state = state.copyWith(pendingCount: total);
    } catch (_) {}
  }

  Future<void> syncAll() async {
    if (state.status == SyncStateStatus.syncing) return;
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    final configured =
        Uri.tryParse(url)?.host.endsWith('.supabase.co') == true &&
            !url.contains('your-project') &&
            key.isNotEmpty &&
            !key.contains('your-anon-key');
    if (!configured) {
      state = state.copyWith(
        status: SyncStateStatus.idle,
        message: 'Local mode - cloud sync is not configured',
      );
      return;
    }
    state =
        state.copyWith(status: SyncStateStatus.syncing, message: 'Syncing...');

    try {
      final supabase = Supabase.instance.client;
      final authUser = supabase.auth.currentUser;
      if (authUser == null) {
        state = state.copyWith(
          status: SyncStateStatus.error,
          message: 'Sign in to synchronize cloud data',
        );
        return;
      }
      var failures = 0;
      final failureDetails = <String>[];
      void recordFailure(String group, Object error) {
        failures++;
        if (failureDetails.length >= 3) return;
        failureDetails.add('$group: ${_safeSyncError(error)}');
      }

      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('pending_profile_${authUser.id}') == true) {
        final localUser = await _db.getCurrentUser();
        if (localUser?.id == authUser.id) {
          try {
            await supabase.from('users').update({
              'name': localUser!.name,
              'avatar_url': localUser.avatarUrl,
              'institution_id': localUser.institutionId
            }).eq('id', authUser.id);
            await prefs.remove('pending_profile_${authUser.id}');
          } catch (error) {
            recordFailure('Profile', error);
          }
        }
      }

      // Apply durable offline deletions before uploads and downloads. Table
      // names come only from the local whitelist below, never from user input.
      const deletableTables = {
        'projects',
        'questionnaires',
        'questions',
        'responses',
        'participants',
      };
      final pendingDeletions = await _db.getPendingDeletions();
      for (final deletion in pendingDeletions) {
        if (!deletableTables.contains(deletion.entityType)) {
          recordFailure(
              'Deletion', StateError('Unsupported local record type'));
          continue;
        }
        try {
          await supabase
              .from(deletion.entityType)
              .delete()
              .eq('id', deletion.entityId);
          await _db.removePendingDeletion(
            deletion.entityType,
            deletion.entityId,
          );
        } catch (error) {
          recordFailure('Delete ${deletion.entityType}', error);
        }
      }

      // 1. Sync Pending Projects
      final pendingProjects = await _db.getPendingProjects();
      for (final project in pendingProjects) {
        try {
          await supabase.from('projects').upsert(project.toJson());
          await _db.markProjectSynced(project.id);
        } catch (error) {
          recordFailure('Project "${project.title}"', error);
        }
      }

      // 2. Sync Pending Questionnaires
      final pendingQuestionnaires = await _db.getPendingQuestionnaires();
      for (final q in pendingQuestionnaires) {
        try {
          await _db.normalizeQuestionOrder(q.id);
          await supabase.from('questionnaires').upsert(q.toJson());
          final questions = await _db.getQuestions(questionnaireId: q.id);
          if (questions.isNotEmpty) {
            await supabase.from('questions').upsert(
                  questions.map((question) => question.toJson()).toList(),
                );
          }
          await _db.markQuestionnaireSynced(q.id);
        } catch (error) {
          recordFailure('Questionnaire "${q.title}"', error);
        }
      }

      // 3. Sync Pending Responses
      final pendingResponses = await _db.getPendingResponses();
      for (final r in pendingResponses) {
        try {
          await supabase.from('responses').upsert(r.toJson());
          await _db.markResponseSynced(r.id);
        } catch (error) {
          recordFailure('Response', error);
        }
      }

      // 4. Sync Pending Participants
      final pendingParticipants = await _db.getPendingParticipants();
      for (final part in pendingParticipants) {
        try {
          await supabase.from('participants').upsert(part.toJson());
          await _db.markParticipantSynced(part.id);
        } catch (error) {
          recordFailure('Participant', error);
        }
      }

      try {
        await uploadInterviewDrafts(_db, supabase);
      } catch (error) {
        recordFailure('Interview', error);
      }

      // Pull the authenticated user's server copy after every successful push.
      // A failed push is never followed by a pull, so unsent local edits cannot
      // be replaced by an older server record.
      if (failures == 0) {
        await _pullCloudData(supabase, authUser.id);
      }

      await refreshPendingCount();
      state = state.copyWith(
        status: failures == 0 ? SyncStateStatus.success : SyncStateStatus.error,
        message: failures == 0
            ? 'Sync completed'
            : '$failures record groups could not be synced. ${failureDetails.join(' | ')}',
        lastSyncTime: failures == 0 ? DateTime.now() : state.lastSyncTime,
        lastAttemptTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStateStatus.error,
        message: 'Sync error: ${_safeSyncError(e)}',
        lastAttemptTime: DateTime.now(),
      );
    }
  }

  String _safeSyncError(Object error) {
    if (error is PostgrestException) {
      final parts = <String>[
        error.message,
        if (error.code != null && error.code!.isNotEmpty) 'code ${error.code}',
        if (error.details != null && '${error.details}'.trim().isNotEmpty)
          '${error.details}',
        if (error.hint != null && '${error.hint}'.trim().isNotEmpty)
          'Hint: ${error.hint}',
      ];
      return parts.join(' — ');
    }
    final text = error
        .toString()
        .replaceFirst(RegExp(r'^(Exception|StateError):\\s*'), '');
    return text.length <= 300 ? text : '${text.substring(0, 300)}…';
  }

  Future<void> _pullCloudData(SupabaseClient supabase, String userId) async {
    final membershipRows = await supabase
        .from('project_members')
        .select('project_id,user_id,project_role')
        .eq('user_id', userId);
    for (final rawMembership in membershipRows) {
      await _db.upsertProjectMembership(
        projectId: rawMembership['project_id'] as String,
        userId: rawMembership['user_id'] as String,
        projectRole: rawMembership['project_role'] as String,
      );
    }

    // RLS now limits this query to owned, supervised, or accepted shared projects.
    final projectRows = await supabase.from('projects').select();

    for (final rawProject in projectRows) {
      final projectJson = Map<String, dynamic>.from(rawProject);
      projectJson['sync_status'] = SyncStatus.synced.name;
      final project = ResearchProject.fromJson(projectJson);
      await _db.insertProject(project);

      final questionnaireRows = await supabase
          .from('questionnaires')
          .select()
          .eq('project_id', project.id);
      for (final rawQuestionnaire in questionnaireRows) {
        final questionnaireJson = Map<String, dynamic>.from(rawQuestionnaire);
        questionnaireJson['sync_status'] = SyncStatus.synced.name;
        final questionnaire = Questionnaire.fromJson(questionnaireJson);
        await _db.insertQuestionnaire(questionnaire);

        final questionRows = await supabase
            .from('questions')
            .select()
            .eq('questionnaire_id', questionnaire.id);
        for (final rawQuestion in questionRows) {
          await _db.insertQuestion(
            Question.fromJson(Map<String, dynamic>.from(rawQuestion)),
          );
        }

        final responseRows = await _readAllRows(
            supabase, 'responses', 'questionnaire_id', questionnaire.id);
        for (final rawResponse in responseRows) {
          final responseJson = Map<String, dynamic>.from(rawResponse);
          responseJson['sync_status'] = SyncStatus.synced.name;
          await _db.insertResponse(
            QuestionnaireResponse.fromJson(responseJson),
          );
        }
      }

      final participantRows = await _readAllRows(
          supabase, 'participants', 'project_id', project.id);
      for (final rawParticipant in participantRows) {
        final participantJson = Map<String, dynamic>.from(rawParticipant);
        participantJson['sync_status'] = SyncStatus.synced.name;
        await _db.insertParticipant(Participant.fromJson(participantJson));
      }
    }
  }

  Future<List<Map<String, dynamic>>> _readAllRows(
      SupabaseClient client, String table, String column, String value) async {
    final rows = <Map<String, dynamic>>[];
    for (var offset = 0;; offset += 1000) {
      final page = await client
          .from(table)
          .select()
          .eq(column, value)
          .order('id')
          .range(offset, offset + 999);
      rows.addAll(page);
      if (page.length < 1000) return rows;
    }
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _periodicSyncTimer?.cancel();
    super.dispose();
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final db = ref.watch(databaseProvider);
  final automaticSync = ref.watch(
      appSettingsProvider.select((settings) => settings.autoSyncOnReconnect));
  return SyncNotifier(db, automaticSync);
});
