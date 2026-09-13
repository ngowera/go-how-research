import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart' show AppDatabase, databaseProvider;
import '../models/app_models.dart';
import 'sync_provider.dart';

class ResponsesState {
  final List<QuestionnaireResponse> responses;
  final bool isLoading;
  final String? error;

  const ResponsesState({
    this.responses = const [],
    this.isLoading = false,
    this.error,
  });

  ResponsesState copyWith({
    List<QuestionnaireResponse>? responses,
    bool? isLoading,
    String? error,
  }) {
    return ResponsesState(
      responses: responses ?? this.responses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ResponsesNotifier extends StateNotifier<ResponsesState> {
  final AppDatabase _db;
  final Ref _ref;
  final String questionnaireId;
  static const _uuid = Uuid();

  ResponsesNotifier(this._db, this._ref, this.questionnaireId)
      : super(const ResponsesState()) {
    loadResponses();
    _ref.listen<DateTime?>(
      syncProvider.select((sync) => sync.lastSyncTime),
      (previous, next) {
        if (next != null && next != previous) loadResponses();
      },
    );
  }

  Future<void> loadResponses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _db.getResponses(questionnaireId: questionnaireId);
      state = state.copyWith(responses: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveResponse({
    required String participantId,
    required Map<String, dynamic> responses,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = QuestionnaireResponse(
        id: _uuid.v4(),
        questionnaireId: questionnaireId,
        participantId: participantId,
        responses: responses,
        collectedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        latitude: latitude,
        longitude: longitude,
      );
      await _db.insertResponse(response);
      await loadResponses();
      _ref.read(syncProvider.notifier).refreshPendingCount();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteResponse(String id) async {
    try {
      await _db.deleteResponse(id);
      await loadResponses();
      _ref.read(syncProvider.notifier).refreshPendingCount();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final responsesProvider =
    StateNotifierProvider.family<ResponsesNotifier, ResponsesState, String>(
        (ref, questionnaireId) {
  ref.watch(currentUserProvider.select((user) => user?.id));
  final db = ref.watch(databaseProvider);
  return ResponsesNotifier(db, ref, questionnaireId);
});
